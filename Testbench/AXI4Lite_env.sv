`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_env extends uvm_env;

    `uvm_component_utils(AXI4Lite_env)

    AXI4Lite_scoreboard scorb;

    AXI4Lite_wr_agent wr_agn;

    AXI4Lite_rd_agent rd_agn;

    irq_agent irq_agn;

    AXI4Lite_virtual_sequencer virt_seqr;

    AXI4Lite_wr_coverage wr_cov;

    AXI4Lite_rd_coverage rd_cov;

    AXI4Lite_reg_block reg_block;

    AXI4Lite_wr_adapter wr_adapter;

    AXI4Lite_rd_adapter rd_adapter;

    AXI4Lite_frontdoor fd_ctrl;

    AXI4Lite_frontdoor fd_status;

    AXI4Lite_frontdoor fd_data;

    AXI4Lite_frontdoor fd_irq;

    uvm_reg_predictor #(AXI4Lite_wr_item) wr_predictor;

    uvm_reg_predictor #(AXI4Lite_rd_item) rd_predictor;

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

        wr_cov = AXI4Lite_wr_coverage :: type_id :: create("wr_cov",this);

        rd_cov = AXI4Lite_rd_coverage :: type_id :: create("rd_cov",this);

        reg_block = AXI4Lite_reg_block :: type_id :: create("reg_block");
        reg_block.build();
        uvm_config_db #(AXI4Lite_reg_block) :: set(this, "*", "reg_block", reg_block);

        wr_adapter = AXI4Lite_wr_adapter :: type_id :: create("wr_adapter");

        rd_adapter = AXI4Lite_rd_adapter :: type_id :: create("rd_adapter");

        fd_ctrl = AXI4Lite_frontdoor :: type_id :: create("fd_ctrl");

        fd_status = AXI4Lite_frontdoor :: type_id :: create("fd_status");

        fd_data = AXI4Lite_frontdoor :: type_id :: create("fd_data");

        fd_irq = AXI4Lite_frontdoor :: type_id :: create("fd_irq");

        wr_predictor = uvm_reg_predictor#(AXI4Lite_wr_item) :: type_id :: create("wr_predictor",this);

        rd_predictor = uvm_reg_predictor#(AXI4Lite_rd_item) :: type_id :: create("rd_predictor",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        wr_agn.wr_mon.mon_wr.connect(scorb.wr_imp);

        wr_agn.wr_mon.cmd_wr.connect(scorb.cmd_imp);

        rd_agn.rd_mon.mon_rd.connect(scorb.rd_imp);

        rd_agn.rd_mon.addr_port.connect(scorb.addr_imp);

        wr_agn.wr_mon.mon_wr.connect(wr_cov.analysis_export);

        rd_agn.rd_mon.mon_rd.connect(rd_cov.analysis_export);

        irq_agn.mon.irq_ap.connect(scorb.irq_imp);

        virt_seqr.wr_seqr = wr_agn.wr_seqr;

        virt_seqr.rd_seqr = rd_agn.rd_seqr;

        virt_seqr.irq_seqr = irq_agn.seqr;

        reg_block.axi_map.set_sequencer(virt_seqr, null);

        wr_predictor.map = reg_block.axi_map;
        wr_predictor.adapter = wr_adapter;

        rd_predictor.map = reg_block.axi_map;
        rd_predictor.adapter = rd_adapter;

        wr_agn.wr_mon.mon_wr.connect(wr_predictor.bus_in);

        rd_agn.rd_mon.mon_rd.connect(rd_predictor.bus_in);

        reg_block.ctrl.set_frontdoor(fd_ctrl, reg_block.axi_map);

        reg_block.status.set_frontdoor(fd_status, reg_block.axi_map);

        reg_block.data.set_frontdoor(fd_data, reg_block.axi_map);

        reg_block.irq.set_frontdoor(fd_irq, reg_block.axi_map);

    endfunction
    
endclass