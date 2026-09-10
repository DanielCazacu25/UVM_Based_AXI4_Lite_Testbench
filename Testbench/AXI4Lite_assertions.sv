`timescale 1ns / 1ps
module AXI4Lite_assertion #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4)
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

    property no_low_VALID_until_READY_high(logic VALID, logic READY);
        @(posedge ACLK) (VALID && !READY) |=> VALID;
    endproperty

    property no_change_until_handshake_finishes(logic VALID,logic READY, logic [DATA_WIDTH-1:0] payload);
        @(posedge ACLK)  (VALID && !READY) |=> $stable(payload);
    endproperty

    property no_undefined_while_VALID_active(logic VALID, logic [DATA_WIDTH-1:0] payload);
        @(posedge ACLK) VALID |-> !$isunknown(payload);
    endproperty

    property valid_must_occur_after_addr_data_accepted(logic accepted, logic VALID, int N);
        @(posedge ACLK) accepted |-> ##[0:N] VALID;
    endproperty
    //NOTE: VALID within 1'b1[*N] would also work

    property no_valid_while_low_flag(VALID, flag);
        @(posedge ACLK) VALID |-> flag;
    endproperty
    
endmodule

    bind AXI4Lite_slave AXI4Lite_assertion u_assertions (.*);