`include "uvm_macros.svh"
import uvm_pkg::*;

class irq_sequencer extends uvm_sequencer #(irq_seq_item);

    `uvm_component_utils(irq_sequencer)

    function new(string name = "irq_sequencer", uvm_component parent);

        super.new(name,parent);
        
    endfunction

endclass