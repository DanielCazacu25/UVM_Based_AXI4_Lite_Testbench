`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_sequencer extends uvm_sequencer #(AXI4Lite_rd_item);

    `uvm_component_utils(AXI4Lite_rd_sequencer)

    function new(string name = "AXI4Lite_rd_sequencer", uvm_component parent);

        super.new(name,parent);
        
    endfunction

endclass