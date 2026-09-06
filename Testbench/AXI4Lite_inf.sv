interface AXI4Lite_inf #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32) (input logic ACLK, input logic ARESETN);
    
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic AWVALID;
    logic AWREADY;
    
    logic [DATA_WIDTH-1:0] WDATA;
    logic WVALID;
    logic WREADY;

    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;

    logic [ADDR_WIDTH-1:0] ARADDR;
    logic ARVALID;
    logic ARREADY;

    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic RREADY;

    logic irq_set_i;

    clocking drv_cb @(posedge ACLK);
        default input #1step output #1;
        input AWREADY, WREADY, BRESP, BVALID, ARREADY, RDATA, RRESP, RVALID;
        output AWADDR, AWVALID, WDATA, WVALID, BREADY, ARADDR, ARVALID, RREADY;
    endclocking

    clocking drv_irq_cb @(posedge ACLK);
        default input #1step output #1;
        output irq_set_i;
    endclocking

    clocking mon_cb @(posedge ACLK);
        default input #1step output #1;
        input AWADDR, AWVALID, AWREADY,
              WDATA, WVALID, WREADY,
              BRESP, BVALID, BREADY,
              ARADDR, ARVALID, ARREADY,
              RDATA, RRESP, RVALID, RREADY,
              irq_set_i;
    endclocking

    modport DRIVER_AXI4Lite(clocking drv_cb);
    modport MONITOR_AXI4Lite(clocking mon_cb);
    modport IRQ_AXI4Lite(clocking drv_irq_cb);

endinterface