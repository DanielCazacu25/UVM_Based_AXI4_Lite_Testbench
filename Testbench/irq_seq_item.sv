`include "uvm_macros.svh"
import uvm_pkg::*;

class irq_seq_item extends uvm_sequence_item;

    rand bit irq_set_i;

    `uvm_object_utils(irq_seq_item)

    function new(string name = "irq_seq_item");
        
        super.new(name);

    endfunction

    constraint irq_dist {

        irq_set_i dist{
            1'b1 := 4,
            1'b0 := 96
        };
    }
    
endclass