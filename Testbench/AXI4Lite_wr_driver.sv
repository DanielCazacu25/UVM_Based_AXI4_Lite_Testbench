`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_driver extends uvm_driver #(AXI4Lite_wr_item);

    virtual AXI4Lite_inf.DRIVER_AXI4Lite inf;

    `uvm_component_utils(AXI4Lite_wr_driver)

    function new(string name = "AXI4Lite_wr_driver", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        if(!uvm_config_db#(virtual AXI4Lite_inf.DRIVER_AXI4Lite) :: get(this,"","inf",inf))

            `uvm_fatal("NOINF","Interface not found")
        
    endfunction

    task write_drv(AXI4Lite_wr_item wr_itm);

        inf.drv_cb.AWADDR <= wr_itm.AWADDR;
        inf.drv_cb.WDATA <= wr_itm.WDATA;
        inf.drv_cb.AWVALID <= 1'b1;
        inf.drv_cb.WVALID <= 1'b1;

        @(inf.drv_cb);
        while (!(inf.drv_cb.AWREADY && inf.drv_cb.WREADY))
            @(inf.drv_cb);

        inf.drv_cb.AWVALID <= 1'b0;
        inf.drv_cb.WVALID <= 1'b0;
        inf.drv_cb.BREADY <= 1'b1;

        @(inf.drv_cb);
        while (!inf.drv_cb.BVALID)
            @(inf.drv_cb);

        wr_itm.BRESP = inf.drv_cb.BRESP;

        inf.drv_cb.BREADY <= 1'b0;

        
    endtask

    task run_phase(uvm_phase phase);

        AXI4Lite_wr_item wr_itm;

        forever begin
            
            seq_item_port.get_next_item(wr_itm);

            write_drv(wr_itm);

            seq_item_port.item_done();

            `uvm_info(get_type_name(),$sformatf("WR DRIVER:AWADDR = %0d | WDATA = %0d",wr_itm.AWADDR,wr_itm.WDATA),UVM_HIGH)

        end
        
    endtask

endclass