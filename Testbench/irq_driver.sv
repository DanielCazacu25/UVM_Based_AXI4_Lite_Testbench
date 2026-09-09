`include "uvm_macros.svh"
import uvm_pkg::*;

class irq_driver extends uvm_driver #(irq_seq_item);

    virtual AXI4Lite_inf.IRQ_DRIVER_AXI4Lite inf;

    `uvm_component_utils(irq_driver)

    function new(string name = "irq_driver", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        if(!uvm_config_db#(virtual AXI4Lite_inf.IRQ_DRIVER_AXI4Lite) :: get(this,"","inf",inf))

            `uvm_fatal("NOVIF","Interface not found")
        
    endfunction

    task run_phase(uvm_phase phase);

    irq_seq_item seq_itm;

    forever begin
        seq_item_port.get_next_item(seq_itm);

        @(inf.drv_irq_cb);
        inf.drv_irq_cb.irq_set_i <= seq_itm.irq_set_i;

        seq_item_port.item_done();

        `uvm_info(get_type_name(),$sformatf("IRQ_DRIVER:irq_set_i = %0d",seq_itm.irq_set_i),UVM_HIGH)
    end

    endtask

endclass