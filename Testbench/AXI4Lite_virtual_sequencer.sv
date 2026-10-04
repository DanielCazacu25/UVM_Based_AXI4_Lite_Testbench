`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(AXI4Lite_virtual_sequencer)

    AXI4Lite_wr_sequencer wr_seqr;

    AXI4Lite_rd_sequencer rd_seqr;

    semaphore addr_lock [bit [3:0]];

    const bit [3:0] addr_list [4] = '{4'h0, 4'h4, 4'h8, 4'hC};

    irq_sequencer irq_seqr;

    function new(string name = "AXI4Lite_virtual_sequencer", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        foreach(addr_list[i])
            addr_lock[addr_list[i]] = new(1);
      
    endfunction
    
endclass