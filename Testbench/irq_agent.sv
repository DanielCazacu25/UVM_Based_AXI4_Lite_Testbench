`include "uvm_macros.svh"
import uvm_pkg::*;

class irq_agent extends uvm_agent;

    irq_sequencer seqr;
    irq_driver drv;
    irq_monitor mon;

    `uvm_component_utils(irq_agent)

    function new(string name = "irq_agent", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        seqr = irq_sequencer :: type_id :: create("seqr",this);

        drv = irq_driver :: type_id :: create("drv",this);

        mon = irq_monitor :: type_id :: create("mon",this);
        
    endfunction

    function void connect_phase(uvm_phase phase);
        
        super.connect_phase(phase);

        drv.seq_item_port.connect(seqr.seq_item_export);
        
    endfunction
endclass