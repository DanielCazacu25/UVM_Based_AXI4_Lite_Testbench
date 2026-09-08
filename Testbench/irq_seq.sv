`include "uvm_macros.svh"
import uvm_pkg::*;

class irq_sequence extends uvm_sequence #(irq_seq_item);

    `uvm_object_utils(irq_sequence)

    int num_trans = 1000;

    function new(string name = "irq_sequence");

        super.new(name);

    endfunction

    task body();

        irq_seq_item seq_itm;

        repeat(num_trans) begin
            
            seq_itm = irq_seq_item :: type_id :: create("seq_itm");

            start_item(seq_itm);

            assert(seq_itm.randomize());

            finish_item(seq_itm);
            
        end
      
    endtask
endclass