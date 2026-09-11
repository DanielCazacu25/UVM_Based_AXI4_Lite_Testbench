module AXI4Lite_assertions #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4)
(

    input logic AWVALID,
    input logic AWREADY,
    input logic [ADDR_WIDTH - 1:0] AWADDR,
    input logic WVALID,
    input logic WREADY,
    input logic [DATA_WIDTH -1 :0] WDATA,
    input logic BVALID,
    input logic BREADY,
    input logic [1:0] BRESP,
    input logic ARVALID,
    input logic ARREADY,
    input logic [ADDR_WIDTH -1:0] ARADDR,
    input logic RVALID,
    input logic RREADY,
    input logic [DATA_WIDTH -1:0] RDATA,
    input logic [1:0] RRESP,
    input logic ACLK,
    input logic ARESETN

);

    logic wr_pending;
    logic rd_pending;
    logic [ADDR_WIDTH-1:0] awaddr_q, araddr_q;
    logic [DATA_WIDTH-1:0] wdata_q,  rdata_q;
    logic [1:0]            bresp_q,  rresp_q;
    localparam [1:0] RESP_OKAY = 2'b00;

    always @(posedge ACLK) begin
        awaddr_q <= AWADDR;
        wdata_q  <= WDATA;
        bresp_q  <= BRESP;
        araddr_q <= ARADDR;
        rdata_q  <= RDATA;
        rresp_q  <= RRESP;
    end

    wire awaddr_stable = (AWADDR === awaddr_q);
    wire wdata_stable = (WDATA === wdata_q);
    wire bresp_stable = (BRESP === bresp_q);
    wire araddr_stable = (ARADDR === araddr_q);
    wire rdata_stable = (RDATA === rdata_q);
    wire rresp_stable = (RRESP === rresp_q);

    always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN)
        wr_pending <= 1'b0;
    else if (AWVALID && AWREADY && WVALID && WREADY)
        wr_pending <= 1'b1;
    else if (BVALID  && BREADY)
        wr_pending <= 1'b0;
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN)
            rd_pending <= 1'b0;
        else if(ARVALID && ARREADY)
            rd_pending <= 1'b1;
        else if(RVALID  && RREADY)
            rd_pending <= 1'b0;
    end

    property no_low_VALID_until_READY_high(logic CLK, logic VALID, logic READY);
        @(posedge CLK) disable iff(!ARESETN)
        (VALID && !READY) |=> VALID;
    endproperty

    property no_change_until_handshake_finishes(logic CLK, logic VALID,logic READY, logic stable_flag);
        @(posedge CLK) disable iff(!ARESETN)
        (VALID && !READY) |=> stable_flag;
    endproperty

    property no_undefined_while_VALID_active(logic CLK, logic VALID, logic [DATA_WIDTH-1:0] payload);
        @(posedge CLK) disable iff(!ARESETN)
        VALID |-> !$isunknown(payload);
    endproperty

    property valid_must_occur_after_addr_data_accepted(logic CLK, logic accepted, logic VALID, int N);
        @(posedge CLK) disable iff(!ARESETN)
        accepted |-> ##[0:N] VALID;
    endproperty
    //NOTE: VALID within 1'b1[*N] would also work

    property no_valid_while_low_flag(logic CLK, logic VALID, logic flag);
        @(posedge CLK) disable iff(!ARESETN)
        VALID |-> flag;
    endproperty

    property outputs_idle_in_reset(logic CLK, logic RESET, logic flag);
        @(posedge CLK) !RESET |=> !flag;
    endproperty

    property resp_is_okay_when_valid_is_active(logic CLK, logic VALID, logic [1:0] RESP);
        @(posedge CLK) disable iff(!ARESETN)
        VALID |-> RESP == RESP_OKAY;
    endproperty
    
endmodule

    bind AXI4Lite_slave AXI4Lite_assertions u_assertions (.*);