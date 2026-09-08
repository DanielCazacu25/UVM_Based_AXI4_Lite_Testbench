`include "uvm_macros.svh"
import uvm_pkg::*;

class irq_monitor extends uvm_monitor;

    `uvm_component_utils(irq_monitor)

    uvm_analysis_port#(irq_seq_item) irq_ap;

    virtual AXI4Lite_inf.MONITOR_AXI4Lite inf;

    function new(string name = "irq_monitor", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        irq_ap = new("irq_ap",this);

        if(!uvm_config_db#(virtual AXI4Lite_inf.MONITOR_AXI4Lite) :: get(this,"","inf",inf))

            `uvm_fatal("NOVIF","Interface not found")
        
    endfunction

    task run_phase(uvm_phase phase);

    irq_seq_item seq_itm;

    forever begin

        @(inf.mon_cb);

        seq_itm = irq_seq_item::type_id::create("seq_itm",this);
        seq_itm.irq_set_i = inf.mon_cb.irq_set_i;

        `uvm_info(get_type_name(),$sformatf("IRQ_MON:irq_set_i = %0d",seq_itm.irq_set_i),UVM_HIGH)

        irq_ap.write(seq_itm);

    end

endtask
endclass