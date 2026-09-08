`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(AXI4Lite_virtual_sequencer)

    AXI4Lite_wr_sequencer wr_seqr;

    AXI4Lite_rd_sequencer rd_seqr;

    irq_sequencer irq_seqr;

    function new(string name = "AXI4Lite_virtual_sequencer", uvm_component parent);

        super.new(name,parent);
        
    endfunction
    
endclass