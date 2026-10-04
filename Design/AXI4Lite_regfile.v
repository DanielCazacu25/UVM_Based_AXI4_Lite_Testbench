`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AXI4Lite_regfile
// Description: Holds the four registers accessible over AXI4-Lite:
//   0x0  CTRL_REG        RW  - bit0: enable, bits[2:1]: mode, bits[31:3]: unused
//   0x4  STATUS_REG      RO  - bit0: busy (driven internally, e.g. by a
//                               free-running counter, just to give it a
//                               changing value for demonstration purposes)
//   0x8  DATA_REG        RW  - full 32-bit read/write scratch register
//   0xC  IRQ_STATUS_REG  W1C - each set bit clears itself when written with a 1
//                               (Write-1-to-Clear); set internally by
//                               irq_set_i (external stimulus for testing)
//////////////////////////////////////////////////////////////////////////////////

module AXI4Lite_regfile #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32)(
    input                       ACLK,
    input                       ARESETN,

    // Write side (from FSMs)
    input                       reg_wr_en,      // pulses for 1 cycle when a write should happen
    input      [ADDR_WIDTH-1:0] reg_wr_addr,
    input      [DATA_WIDTH-1:0] reg_wr_data,

    // Read side (from FSMs)
    input                       reg_rd_en,      // pulses for 1 cycle when a read should happen
    input      [ADDR_WIDTH-1:0] reg_rd_addr,
    output reg [DATA_WIDTH-1:0] reg_rd_data,

    // External stimulus, purely for demonstration of RO / W1C behavior
    input                       irq_set_i       // pulses to set a bit in IRQ_STATUS_REG
);

    localparam CTRL_ADDR       = 4'h0;
    localparam STATUS_ADDR     = 4'h4;
    localparam DATA_ADDR       = 4'h8;
    localparam IRQ_STATUS_ADDR = 4'hC;

    // ------------------------------------------------------------------
    // CTRL_REG - fully RW, only bits [2:0] are meaningful (enable + mode)
    // ------------------------------------------------------------------
    reg [2:0] ctrl_reg;   // bit0 = enable, bits[2:1] = mode

    // ------------------------------------------------------------------
    // STATUS_REG - RO. busy is driven by a small free-running counter's
    // MSB here, purely so the register has a changing value to observe -
    // in a real design this would reflect real internal DUT activity.
    // ------------------------------------------------------------------
    reg [3:0] busy_counter;
    wire      busy = busy_counter[3];

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN)
            busy_counter <= 4'h0;
        else
            busy_counter <= busy_counter + 1'b1;
    end

    // ------------------------------------------------------------------
    // DATA_REG - fully RW, no special behavior
    // ------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] data_reg;

    // ------------------------------------------------------------------
    // IRQ_STATUS_REG - W1C. irq_set_i sets bit0. A write of 1 to bit0
    // clears it. A write of 0 has no effect (standard W1C semantics).
    // ------------------------------------------------------------------
    reg irq_status_reg;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_reg        <= 3'h0;
            data_reg        <= {DATA_WIDTH{1'b0}};
            irq_status_reg  <= 1'b0;
        end else begin

            // irq_set_i has priority to SET the bit; a W1C write in the
            // same cycle would clear it - set wins here since it's the
            // more common convention (a new event overrides an in-flight
            // clear), and it's a corner case unlikely to be hit in tests.
            if (irq_set_i)
                irq_status_reg <= 1'b1;

            if (reg_wr_en) begin
                case (reg_wr_addr)
                    CTRL_ADDR:
                        ctrl_reg <= reg_wr_data[2:0];

                    DATA_ADDR:
                        data_reg <= reg_wr_data;

                    IRQ_STATUS_ADDR:
                        if (!irq_set_i && reg_wr_data[0])   // W1C: write 1 clears
                            irq_status_reg <= 1'b0;

                    // STATUS_ADDR: read-only, writes silently ignored
                    default: ;
                endcase
            end
        end
    end

    // ------------------------------------------------------------------
    // Read mux
    // ------------------------------------------------------------------
    always @(posedge ACLK) begin
        if (reg_rd_en) begin
            case (reg_rd_addr)
                CTRL_ADDR:       reg_rd_data <= {{(DATA_WIDTH-3){1'b0}}, ctrl_reg};
                STATUS_ADDR:     reg_rd_data <= {{(DATA_WIDTH-1){1'b0}}, busy};
                DATA_ADDR:       reg_rd_data <= data_reg;
                IRQ_STATUS_ADDR: reg_rd_data <= {{(DATA_WIDTH-1){1'b0}}, irq_status_reg};
                default:         reg_rd_data <= {DATA_WIDTH{1'b0}};
            endcase
        end
    end

endmodule