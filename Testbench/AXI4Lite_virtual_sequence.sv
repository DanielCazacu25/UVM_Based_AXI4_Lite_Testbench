`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_virtual_sequence extends uvm_sequence;

    `uvm_object_utils(AXI4Lite_virtual_sequence)
    `uvm_declare_p_sequencer(AXI4Lite_virtual_sequencer)

    AXI4Lite_wr_seq wr_seq;

    AXI4Lite_rd_seq rd_seq;

    irq_sequence irq_seq;
    
    function new(string name = "AXI4Lite_virtual_sequence");

        super.new(name);
        
    endfunction

    task pre_body();

        wr_seq = AXI4Lite_wr_seq :: type_id :: create("wr_seq");

        rd_seq = AXI4Lite_rd_seq :: type_id :: create("rd_seq");

        irq_seq = irq_sequence :: type_id :: create("irq_seq");

        wr_seq.addr_lock = p_sequencer.addr_lock;

        rd_seq.addr_lock = p_sequencer.addr_lock;
      
    endtask

    task body();

        fork
            
            wr_seq.start(p_sequencer.wr_seqr);

            rd_seq.start(p_sequencer.rd_seqr);

            irq_seq.start(p_sequencer.irq_seqr);

        join
      
    endtask
    
endclass