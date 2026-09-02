`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AXI4Lite_slave
// Description: A simple AXI4-Lite slave. Simplified FSMs: a write is only
//   accepted once BOTH AWVALID and WVALID are asserted in the same cycle
//   (address and data must arrive together - no support for them arriving
//   on different cycles).
//
//   The read path has an extra "wait" state (RD_WAIT) to account for the
//   1-cycle latency of AXI4Lite_regfile's registered read mux: reg_rd_en
//   pulses in one cycle, but reg_rd_data only becomes valid one cycle
//   later - exactly the same class of latency handled at the FIFO project's
//   read monitor.
//////////////////////////////////////////////////////////////////////////////////

module AXI4Lite_slave #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32)(
    input                       ACLK,
    input                       ARESETN,

    // Write Address Channel
    input      [ADDR_WIDTH-1:0] AWADDR,
    input                       AWVALID,
    output reg                  AWREADY,

    // Write Data Channel
    input      [DATA_WIDTH-1:0] WDATA,
    input                       WVALID,
    output reg                  WREADY,

    // Write Response Channel
    output reg [1:0]            BRESP,
    output reg                  BVALID,
    input                       BREADY,

    // Read Address Channel
    input      [ADDR_WIDTH-1:0] ARADDR,
    input                       ARVALID,
    output reg                  ARREADY,

    // Read Data Channel
    output reg [DATA_WIDTH-1:0] RDATA,
    output reg [1:0]            RRESP,
    output reg                  RVALID,
    input                       RREADY,

    // External stimulus for IRQ_STATUS_REG demonstration
    input                       irq_set_i
);

    localparam [1:0] RESP_OKAY = 2'b00;

    // ------------------------------------------------------------------
    // Write path: simple 3-state FSM (IDLE -> RESP -> IDLE)
    // Accepts AW+W only when BOTH are valid simultaneously.
    // ------------------------------------------------------------------
    localparam WR_IDLE = 1'b0;
    localparam WR_RESP = 1'b1;

    reg wr_state;
    reg reg_wr_en;
    reg [ADDR_WIDTH-1:0] reg_wr_addr;
    reg [DATA_WIDTH-1:0] reg_wr_data;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            wr_state    <= WR_IDLE;
            AWREADY     <= 1'b0;
            WREADY      <= 1'b0;
            BVALID      <= 1'b0;
            BRESP       <= RESP_OKAY;
            reg_wr_en   <= 1'b0;
            reg_wr_addr <= {ADDR_WIDTH{1'b0}};
            reg_wr_data <= {DATA_WIDTH{1'b0}};
        end else begin

            reg_wr_en <= 1'b0;   // default: pulse for exactly 1 cycle

            case (wr_state)

                WR_IDLE: begin
                    AWREADY <= 1'b0;
                    WREADY  <= 1'b0;

                    if (AWVALID && WVALID) begin
                        AWREADY     <= 1'b1;
                        WREADY      <= 1'b1;
                        reg_wr_en   <= 1'b1;
                        reg_wr_addr <= AWADDR;
                        reg_wr_data <= WDATA;

                        BVALID   <= 1'b1;
                        BRESP    <= RESP_OKAY;
                        wr_state <= WR_RESP;
                    end
                end

                WR_RESP: begin
                    AWREADY <= 1'b0;
                    WREADY  <= 1'b0;

                    if (BVALID && BREADY) begin
                        BVALID   <= 1'b0;
                        wr_state <= WR_IDLE;
                    end
                end

                default: wr_state <= WR_IDLE;

            endcase
        end
    end

    // ------------------------------------------------------------------
    // Read path: 4-state FSM (IDLE -> WAIT -> DATA -> IDLE)
    // RD_WAIT exists purely to absorb the regfile's 1-cycle read latency
    // (reg_rd_en pulses during RD_IDLE->RD_WAIT transition; regfile
    // captures reg_rd_data during the RD_WAIT cycle; by the time we enter
    // RD_DATA, reg_rd_data is guaranteed stable and correct).
    // ------------------------------------------------------------------
    localparam RD_IDLE = 2'd0;
    localparam RD_WAIT = 2'd1;
    localparam RD_DATA = 2'd2;

    reg [1:0] rd_state;
    reg reg_rd_en;
    reg [ADDR_WIDTH-1:0] reg_rd_addr;
    wire [DATA_WIDTH-1:0] reg_rd_data;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            rd_state    <= RD_IDLE;
            ARREADY     <= 1'b0;
            RVALID      <= 1'b0;
            RRESP       <= RESP_OKAY;
            RDATA       <= {DATA_WIDTH{1'b0}};
            reg_rd_en   <= 1'b0;
            reg_rd_addr <= {ADDR_WIDTH{1'b0}};
        end else begin

            reg_rd_en <= 1'b0;   // default: pulse for exactly 1 cycle

            case (rd_state)

                RD_IDLE: begin
                    ARREADY <= 1'b0;

                    if (ARVALID) begin
                        ARREADY     <= 1'b1;
                        reg_rd_en   <= 1'b1;
                        reg_rd_addr <= ARADDR;
                        rd_state    <= RD_WAIT;
                    end
                end

                RD_WAIT: begin
                    ARREADY <= 1'b0;
                    // single-cycle pass-through: lets the regfile's
                    // registered read mux capture reg_rd_data (enabled by
                    // reg_rd_en, which was high during this very cycle)
                    rd_state <= RD_DATA;
                end

                RD_DATA: begin
                    if (!RVALID) begin
                        RVALID <= 1'b1;
                        RRESP  <= RESP_OKAY;
                        RDATA  <= reg_rd_data;   // reg_rd_data is stable here
                    end else if (RVALID && RREADY) begin
                        RVALID   <= 1'b0;
                        rd_state <= RD_IDLE;
                    end
                end

                default: rd_state <= RD_IDLE;

            endcase
        end
    end

    // ------------------------------------------------------------------
    // Register file instance
    // ------------------------------------------------------------------
    AXI4Lite_regfile #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) u_regfile (
        .ACLK        (ACLK),
        .ARESETN     (ARESETN),
        .reg_wr_en   (reg_wr_en),
        .reg_wr_addr (reg_wr_addr),
        .reg_wr_data (reg_wr_data),
        .reg_rd_en   (reg_rd_en),
        .reg_rd_addr (reg_rd_addr),
        .reg_rd_data (reg_rd_data),
        .irq_set_i   (irq_set_i)
    );

endmodule