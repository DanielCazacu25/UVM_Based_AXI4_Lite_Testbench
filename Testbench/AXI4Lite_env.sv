`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_env extends uvm_env;

    `uvm_component_utils(AXI4Lite_env)

    AXI4Lite_scoreboard scorb;

    AXI4Lite_wr_agent wr_agn;

    AXI4Lite_rd_agent rd_agn;

    irq_agent irq_agn;

    AXI4Lite_virtual_sequencer virt_seqr;

    function new(string name = "AXI4Lite_env", uvm_component parent);

        super.new(name,parent);

    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        scorb = AXI4Lite_scoreboard :: type_id :: create("scorb",this);

        wr_agn = AXI4Lite_wr_agent :: type_id :: create("wr_agn",this);

        rd_agn = AXI4Lite_rd_agent :: type_id :: create("rd_agn",this);

        irq_agn = irq_agent :: type_id :: create("irq_agn",this);

        virt_seqr = AXI4Lite_virtual_sequencer :: type_id :: create("virt_seqr",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        wr_agn.wr_mon.mon_wr.connect(scorb.wr_imp);

        rd_agn.rd_mon.mon_rd.connect(scorb.rd_imp);

        irq_agn.mon.irq_ap.connect(scorb.irq_imp);

        virt_seqr.wr_seqr = wr_agn.wr_seqr;

        virt_seqr.rd_seqr = rd_agn.rd_seqr;

        virt_seqr.irq_seqr = irq_agn.seqr;

    endfunction
    
endclass