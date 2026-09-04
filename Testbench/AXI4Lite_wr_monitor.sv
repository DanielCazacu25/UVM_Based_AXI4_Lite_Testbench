`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_monitor extends uvm_monitor;

    `uvm_component_utils(AXI4Lite_wr_monitor)

    uvm_analysis_port#(AXI4Lite_wr_item) mon_wr;

    virtual AXI4Lite_inf.MONITOR_AXI4Lite inf;

    function new(string name = "AXI4Lite_wr_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon_wr = new("mon_wr",this);

        if(!uvm_config_db#(virtual AXI4Lite_inf.MONITOR_AXI4Lite) :: get(this,"","inf",inf))
            `uvm_fatal("NOINF","Interface not found")
        
    endfunction

    task run_phase(uvm_phase phase);

        AXI4Lite_wr_item wr_itm;

        forever begin

            wr_itm = AXI4Lite_wr_item::type_id::create("wr_itm",this);

            @(inf.mon_cb);

            while(!(inf.mon_cb.AWVALID && inf.mon_cb.AWREADY))
                @(inf.mon_cb);

            wr_itm.AWADDR = inf.mon_cb.AWADDR;
            wr_itm.WDATA  = inf.mon_cb.WDATA;

            @(inf.mon_cb);
            while(!(inf.mon_cb.BVALID && inf.mon_cb.BREADY))
                @(inf.mon_cb);

            wr_itm.BRESP = inf.mon_cb.BRESP;

            `uvm_info(get_type_name(),$sformatf("WR MONITOR: AWADDR = %0d | WDATA = %0d | BRESP = %0d",wr_itm.AWADDR,wr_itm.WDATA,wr_itm.BRESP),UVM_HIGH)

            mon_wr.write(wr_itm);

        end

    endtask

endclass