`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_monitor extends uvm_monitor;

    `uvm_component_utils(AXI4Lite_rd_monitor)

    uvm_analysis_port#(AXI4Lite_rd_item) mon_rd;

    virtual AXI4Lite_inf.MONITOR_AXI4Lite inf;

    function new(string name = "AXI4Lite_rd_monitor", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        mon_rd = new("mon_rd",this);

        if(!uvm_config_db#(virtual AXI4Lite_inf.MONITOR_AXI4Lite) :: get(this,"","inf",inf))
            `uvm_fatal("NOINF","Interface not found")
        
    endfunction

    task run_phase(uvm_phase phase);

    AXI4Lite_rd_item rd_itm;

    forever begin

        rd_itm = AXI4Lite_rd_item::type_id::create("rd_itm",this);

        @(inf.mon_cb);

        while(!(inf.mon_cb.ARVALID && inf.mon_cb.ARREADY))
            @(inf.mon_cb);

        rd_itm.ARADDR = inf.mon_cb.ARADDR;

        @(inf.mon_cb);

        while(!(inf.mon_cb.RVALID && inf.mon_cb.RREADY))
            @(inf.mon_cb);

        rd_itm.RDATA = inf.mon_cb.RDATA;
        rd_itm.RRESP = inf.mon_cb.RRESP;

        `uvm_info(get_type_name(),$sformatf("RD MONITOR: ARADDR = %0d | RDATA = %0d | RRESP = %0d",rd_itm.ARADDR,rd_itm.RDATA,rd_itm.RRESP),UVM_HIGH)

        mon_rd.write(rd_itm);

    end

endtask

endclass