`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_coverage #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4)
    extends uvm_subscriber #(AXI4Lite_rd_item #(DATA_WIDTH, ADDR_WIDTH));

    typedef AXI4Lite_rd_coverage #(DATA_WIDTH, ADDR_WIDTH) rd_cov;
    typedef AXI4Lite_rd_item     #(DATA_WIDTH, ADDR_WIDTH) rd_item_t;

    `uvm_component_utils(rd_cov)

    localparam bit [ADDR_WIDTH-1:0] CTRL_ADDR       = 4'h0;
    localparam bit [ADDR_WIDTH-1:0] STATUS_ADDR     = 4'h4;
    localparam bit [ADDR_WIDTH-1:0] DATA_ADDR       = 4'h8;
    localparam bit [ADDR_WIDTH-1:0] IRQ_STATUS_ADDR = 4'hC;

    covergroup rd_cg with function sample(bit [ADDR_WIDTH-1:0] addr,
                                          bit [DATA_WIDTH-1:0] data);


        busy_cp : coverpoint data[0] iff (addr == STATUS_ADDR) {
            bins idle = {1'b0};
            bins busy = {1'b1};
        }

        addr_check : coverpoint addr {
            bins CTRL       = {CTRL_ADDR};
            bins STATUS     = {STATUS_ADDR};
            bins DATA       = {DATA_ADDR};
            bins IRQ_STATUS = {IRQ_STATUS_ADDR};
            bins unmapped   = {[4'h1:4'h3], [4'h5:4'h7], [4'h9:4'hB], [4'hD:4'hF]};
        }

        irq_status_cp : coverpoint data[0] iff (addr == IRQ_STATUS_ADDR) {
            bins set     = {1'b1};
            bins cleared = {1'b0};
        }

    endgroup

    function new(string name = "AXI4Lite_rd_coverage", uvm_component parent);

        super.new(name, parent);

        rd_cg = new();

    endfunction

    function void write(rd_item_t t);

        rd_cg.sample(t.ARADDR, t.RDATA);

    endfunction

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),
                  $sformatf("Read coverage: %0.2f%%", rd_cg.get_coverage()),
                  UVM_LOW)

    endfunction

endclass
