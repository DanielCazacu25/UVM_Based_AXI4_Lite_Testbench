import uvm_pkg::*;
import AXI4Lite_pkg::*;

module AXI4Lite_top;

    bit ACLK;
    bit ARESETN;

    always #5 ACLK = ~ACLK;

    AXI4Lite_inf inf(ACLK,ARESETN);

    AXI4Lite_Slave DUT(.ACLK(inf.ACLK),
                         .ARESETN(inf.ARESETN),
                         .AWADDR(inf.AWADDR),
                         .AWVALID(inf.AWVALID),
                         .AWREADY(inf.AWREADY),
                         .WDATA(inf.WDATA),
                         .WVALID(inf.WVALID),
                         .WREADY(inf.WREADY),
                         .BRESP(inf.BRESP),
                         .BVALID(inf.BVALID),
                         .BREADY(inf.BREADY),
                         .ARADDR(inf.ARADDR),
                         .ARVALID(inf.ARVALID),
                         .ARREADY(inf.ARREADY),
                         .RDATA(inf.RDATA),
                         .RRESP(inf.RRESP),
                         .RVALID(inf.RVALID),
                         .RREADY(inf.RREADY),
                         .irq_set_i(inf.irq_set_i));

    initial begin

        uvm_config_db#(virtual AXI4Lite_inf.DRIVER_AXI4Lite) :: set(null,"*","inf",inf);
        uvm_config_db#(virtual AXI4Lite_inf.MONITOR_AXI4Lite) :: set(null,"*","inf",inf);
        uvm_config_db#(virtual AXI4Lite_inf.IRQ_DRIVER_AXI4Lite) :: set(null,"uvm_test_top.env.irq_agn.drv","inf",inf);
        run_test("AXI4Lite_test");
    
    end

endmodule