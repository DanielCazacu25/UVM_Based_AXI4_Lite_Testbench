package AXI4Lite_pkg;

    `include 
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "AXI4Lite_wr_item.sv"
    `include "AXI4Lite_wr_sequencer.sv"
    `include "AXI4Lite_wr_driver.sv"
    `include "AXI4Lite_wr_monitor.sv"
    `include "AXI4Lite_wr_seq.sv"
    `include "AXI4Lite_wr_agent.sv"
    `include "AXI4Lite_rd_item.sv"
    `include "AXI4Lite_rd_sequencer.sv"
    `include "AXI4Lite_rd_driver.sv"
    `include "AXI4Lite_rd_monitor.sv"
    `include "AXI4Lite_rd_seq.sv"
    `include "AXI4Lite_rd_agent.sv"
    `include "irq_seq_item.sv"
    `include "irq_sequencer.sv"
    `include "irq_driver.sv"
    `include "irq_monitor.sv"
    `include "irq_seq.sv"
    `include "irq_agent.sv"
    `include "AXI4Lite_scoreboard.sv"        // foloseste wr_item, rd_item, irq_seq_item
    `include "AXI4Lite_virtual_sequencer.sv"
    `include "AXI4Lite_env.sv"
    `include "AXI4Lite_virtual_sequence.sv"
    `include "AXI4Lite_test.sv"

endpackage

