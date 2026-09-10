module AXI4Lite_assertion #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4)(

    input logic AWVALID;
    input logic AWREADY;
    input logic [ADDR_WIDTH - 1:0] AWADDR;
    input logic WVALID;
    input logic WREADY;
    input logic [DATA_WIDTH -1 :0] WDATA;
    input logic BVALID;
    input logic BREADY;
    input logic [1:0] BRESP;
    input logic ARVALID;
    input logic ARREADY;
    input logic [ADDR_WIDTH -1:0] ARADDR;
    input logic RVALID;
    input logic RREADY;
    input logic [DATA_WIDTH -1:0] RDATA;
    input logic [1:0] RRESP;
    input logic ACLK;

);

    property no_low_VALID_until_READY_high(CLK, VALID, READY);
        @(posedge CLK) (VALID && !READY) |=> VALID;
    endproperty

    property no_change_until_handshake_finishes(CLK, VALID, READY, payload);
        @(posedge CLK)  (VALID && !READY) |=> $stable(payload);
    endproperty

    property no_undefined_while_VALID_active(CLK, VALID, payload);
        @(posedge CLK) VALID |-> !$isunknown(payload);
    endproperty

    property valid_must_occur_after_addr_data_accepted(CLK, accepted, VALID, N);
        @(posedge CLK) accepted |-> ##[0:N] VALID;
    endproperty
    //NOTE: VALID within 1'b1[*N] would also work

    
    
endmodule

