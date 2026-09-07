`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_agent extends uvm_agent;

    AXI4Lite_rd_sequencer rd_seqr;
    AXI4Lite_rd_driver rd_drv;
    AXI4Lite_rd_monitor rd_mon;

    `uvm_component_utils(AXI4Lite_rd_agent)

    function new(string name = "AXI4Lite_rd_agent", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        rd_seqr = AXI4Lite_rd_sequencer :: type_id :: create("rd_seqr",this);

        rd_drv = AXI4Lite_rd_driver :: type_id :: create("rd_drv",this);

        rd_mon = AXI4Lite_rd_monitor :: type_id :: create("rd_mon",this);
        
    endfunction

    function void connect_phase(uvm_phase phase);
        
        super.connect_phase(phase);

        rd_drv.seq_item_port.connect(rd_seqr.seq_item_export);
        
    endfunction
endclass