`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_coverage #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4)
    extends uvm_subscriber #(AXI4Lite_wr_item #(DATA_WIDTH, ADDR_WIDTH));

    typedef AXI4Lite_wr_coverage #(DATA_WIDTH, ADDR_WIDTH) this_cov;
    typedef AXI4Lite_wr_item     #(DATA_WIDTH, ADDR_WIDTH) wr_item_t;

    `uvm_component_utils(this_cov)

    localparam bit [ADDR_WIDTH-1:0] CTRL_ADDR       = 4'h0;
    localparam bit [ADDR_WIDTH-1:0] STATUS_ADDR     = 4'h4;
    localparam bit [ADDR_WIDTH-1:0] DATA_ADDR       = 4'h8;
    localparam bit [ADDR_WIDTH-1:0] IRQ_STATUS_ADDR = 4'hC;

    covergroup wr_cg with function sample(bit [ADDR_WIDTH-1:0] addr,
                                          bit [DATA_WIDTH-1:0] data,
                                          bit irq);


        mode_cp : coverpoint data[2:1] iff (addr == CTRL_ADDR) {
            bins mode_0 = {2'b00};
            bins mode_1 = {2'b01};
            bins mode_2 = {2'b10};
            bins mode_3 = {2'b11};
        }

        enable_cp : coverpoint data[0] iff (addr == CTRL_ADDR) {
            bins disabled = {1'b0};
            bins enabled  = {1'b1};
        }

        addr_check : coverpoint addr {
            bins CTRL       = {CTRL_ADDR};
            bins STATUS     = {STATUS_ADDR};
            bins DATA       = {DATA_ADDR};
            bins IRQ_STATUS = {IRQ_STATUS_ADDR};
            bins unmapped   = {[4'h1:4'h3], [4'h5:4'h7], [4'h9:4'hB], [4'hD:4'hF]};
        }

        w1c_cp : coverpoint data[0] iff (addr == IRQ_STATUS_ADDR) {
            bins clear_bit  = {1'b1};
            bins do_nothing = {1'b0};
        }

        irq_cp : coverpoint irq;

        w1c_cross : cross irq_cp , w1c_cp {
            ignore_bins ignore_w0_irq0 = binsof(w1c_cp) intersect {0} && binsof(irq_cp) intersect {0};
            ignore_bins ignore_w0_irq1 = binsof(w1c_cp) intersect {0} && binsof(irq_cp) intersect {1};
            ignore_bins ignore_w1_irq0 = binsof(w1c_cp) intersect {1} && binsof(irq_cp) intersect {0};
        }

    endgroup

    function new(string name = "AXI4Lite_wr_coverage", uvm_component parent);

        super.new(name, parent);

        wr_cg = new();

    endfunction

    function void write(wr_item_t t);

        wr_cg.sample(t.AWADDR, t.WDATA, t.irq_set_i);

    endfunction

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),
                  $sformatf("Write coverage: %0.2f%%", wr_cg.get_coverage()),
                  UVM_LOW)

    endfunction

endclass
