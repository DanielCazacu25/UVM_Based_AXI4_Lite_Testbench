`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_driver extends uvm_driver #(AXI4Lite_rd_item);

    virtual AXI4Lite_inf.DRIVER_AXI4Lite inf;

    `uvm_component_utils(AXI4Lite_rd_driver)

    function new(string name = "AXI4Lite_rd_driver", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        if(!uvm_config_db#(virtual AXI4Lite_inf.DRIVER_AXI4Lite) :: get(this,"","inf",inf))

            `uvm_fatal("NOINF","Interface not found")
        
    endfunction

    task read_drv(AXI4Lite_rd_item rd_itm);

        inf.drv_cb.ARADDR <= rd_itm.ARADDR;
        inf.drv_cb.ARVALID <= 1'b1;
        inf.drv_cb.RREADY <= 1'b1;

        @(inf.drv_cb);
        while (!inf.drv_cb.ARREADY)
            @(inf.drv_cb);

        inf.drv_cb.ARVALID <= 1'b0;

        @(inf.drv_cb);
        while (!inf.drv_cb.RVALID)
            @(inf.drv_cb);

        inf.drv_cb.RDATA <= rd_itm.RDATA;
        inf.drv_cb.RRESP <= rd_itm.RRESP;

        @(inf.drv_cb);
        while (inf.drv_cb.RVALID)
            @(inf.drv_cb);

        inf.drv_cb.RREADY <= 1'b0;
        
        
    endtask

    task run_phase(uvm_phase phase);

        AXI4Lite_rd_item rd_itm;

        forever begin
            
            seq_item_port.get_next_item(rd_itm);

            read_drv(rd_itm);

            seq_item_port.item_done();

            `uvm_info(get_type_name(),$sformatf("RD DRIVER:ARADDR = %0d | RDATA = %0d",rd_itm.ARADDR,rd_itm.RDATA),UVM_HIGH)

        end
        
    endtask

endclass