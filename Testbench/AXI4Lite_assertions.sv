module AXI4Lite_assertions #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32)
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
    localparam int MAX_RESP_CYC = 16;

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
    else if (AWVALID && WVALID)
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
    endproperty // >okafpo

    property outputs_idle_in_reset(logic CLK, logic RESET, logic flag);
        @(posedge CLK) !RESET |=> !flag;
    endproperty

    property resp_is_okay_when_valid_is_active(logic CLK, logic VALID, logic [1:0] RESP);
        @(posedge CLK) disable iff(!ARESETN)
        VALID |-> RESP == RESP_OKAY;
    endproperty
    
    a_aw_valid_held : assert property (no_low_VALID_until_READY_high(ACLK, AWVALID, AWREADY))
        else $error("AW: AWVALID deasserted before AWREADY was seen");

    a_w_valid_held : assert property (no_low_VALID_until_READY_high(ACLK, WVALID, WREADY))
        else $error("W: WVALID deasserted before WREADY was seen");

    a_b_valid_held : assert property (no_low_VALID_until_READY_high(ACLK, BVALID, BREADY))
        else $error("B: BVALID deasserted before BREADY was seen");

    a_ar_valid_held : assert property (no_low_VALID_until_READY_high(ACLK, ARVALID, ARREADY))
        else $error("AR: ARVALID deasserted before ARREADY was seen");

    a_r_valid_held : assert property (no_low_VALID_until_READY_high(ACLK, RVALID, RREADY))
        else $error("R: RVALID deasserted before RREADY was seen");

    a_awaddr_stable : assert property (no_change_until_handshake_finishes(ACLK, AWVALID, AWREADY, awaddr_stable))
        else $error("AW: AWADDR changed while AWVALID was high and AWREADY low");

    a_wdata_stable : assert property (no_change_until_handshake_finishes(ACLK, WVALID, WREADY, wdata_stable))
        else $error("W: WDATA changed while WVALID was high and WREADY low");

    a_bresp_stable : assert property (no_change_until_handshake_finishes(ACLK, BVALID, BREADY, bresp_stable))
        else $error("B: BRESP changed while BVALID was high and BREADY low");

    a_araddr_stable : assert property (no_change_until_handshake_finishes(ACLK, ARVALID, ARREADY, araddr_stable))
        else $error("AR: ARADDR changed while ARVALID was high and ARREADY low");

    a_rdata_stable : assert property (no_change_until_handshake_finishes(ACLK, RVALID, RREADY, rdata_stable))
        else $error("R: RDATA changed while RVALID was high and RREADY low");

    a_rresp_stable : assert property (no_change_until_handshake_finishes(ACLK, RVALID, RREADY, rresp_stable))
        else $error("R: RRESP changed while RVALID was high and RREADY low");

    a_awaddr_known : assert property (no_undefined_while_VALID_active(ACLK, AWVALID, AWADDR))
        else $error("AW: AWADDR contains X/Z while AWVALID is active");

    a_wdata_known : assert property (no_undefined_while_VALID_active(ACLK, WVALID, WDATA))
        else $error("W: WDATA contains X/Z while WVALID is active");

    a_bresp_known : assert property (no_undefined_while_VALID_active(ACLK, BVALID, BRESP))
        else $error("B: BRESP contains X/Z while BVALID is active");

    a_araddr_known : assert property (no_undefined_while_VALID_active(ACLK, ARVALID, ARADDR))
        else $error("AR: ARADDR contains X/Z while ARVALID is active");

    a_rdata_known : assert property (no_undefined_while_VALID_active(ACLK, RVALID, RDATA))
        else $error("R: RDATA contains X/Z while RVALID is active");

    a_rresp_known : assert property (no_undefined_while_VALID_active(ACLK, RVALID, RRESP))
        else $error("R: RRESP contains X/Z while RVALID is active");

    a_bvalid_bounded : assert property (valid_must_occur_after_addr_data_accepted(
                           ACLK, (AWVALID && AWREADY && WVALID && WREADY), BVALID, MAX_RESP_CYC))
        else $error("B: BVALID did not appear within %0d cycles after the write was accepted", MAX_RESP_CYC);

    a_rvalid_bounded : assert property (valid_must_occur_after_addr_data_accepted(
                           ACLK, (ARVALID && ARREADY), RVALID, MAX_RESP_CYC))
        else $error("R: RVALID did not appear within %0d cycles after the read address was accepted", MAX_RESP_CYC);

    a_no_bvalid_without_request : assert property (no_valid_while_low_flag(ACLK, BVALID, wr_pending))
        else $error("B: BVALID is active with no outstanding write request");

    a_no_rvalid_without_request : assert property (no_valid_while_low_flag(ACLK, RVALID, rd_pending))
        else $error("R: RVALID is active with no outstanding read request");

    a_reset_awready : assert property (outputs_idle_in_reset(ACLK, ARESETN, AWREADY))
        else $error("RESET: AWREADY is not low during reset");

    a_reset_wready : assert property (outputs_idle_in_reset(ACLK, ARESETN, WREADY))
        else $error("RESET: WREADY is not low during reset");

    a_reset_bvalid : assert property (outputs_idle_in_reset(ACLK, ARESETN, BVALID))
        else $error("RESET: BVALID is not low during reset");

    a_reset_arready : assert property (outputs_idle_in_reset(ACLK, ARESETN, ARREADY))
        else $error("RESET: ARREADY is not low during reset");

    a_reset_rvalid : assert property (outputs_idle_in_reset(ACLK, ARESETN, RVALID))
        else $error("RESET: RVALID is not low during reset");

    a_bresp_okay : assert property (resp_is_okay_when_valid_is_active(ACLK, BVALID, BRESP))
        else $error("B: BRESP is %0b, expected OKAY", BRESP);

    a_rresp_okay : assert property (resp_is_okay_when_valid_is_active(ACLK, RVALID, RRESP))
        else $error("R: RRESP is %0b, expected OKAY", RRESP);
endmodule

    bind AXI4Lite_slave AXI4Lite_assertions u_assertions (.*);