`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_agent extends uvm_agent;

    AXI4Lite_wr_sequencer wr_seqr;
    AXI4Lite_wr_driver wr_drv;
    AXI4Lite_wr_monitor wr_mon;

    `uvm_component_utils(AXI4Lite_wr_agent)

    function new(string name = "AXI4Lite_wr_agent", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);

        build_phase(phase);

        wr_seqr = AXI4Lite_wr_sequencer :: type_id :: create("wr_seqr",this);

        wr_drv = AXI4Lite_wr_driver :: type_id :: create("wr_drv",this);

        wr_mon = AXI4Lite_wr_monitor :: type_id :: create("wr_mon",this);
        
    endfunction

    function void connect_phase(uvm_phase phase);
        
        super.connect_phase(phase);

        wr_drv.seq_item_port.connect(wr_seqr.seq_item_export);
        
    endfunction
endclass