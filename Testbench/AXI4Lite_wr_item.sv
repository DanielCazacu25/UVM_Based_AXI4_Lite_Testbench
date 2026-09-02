`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_item #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4) extends uvm_sequence_item;

    rand logic [ADDR_WIDTH-1:0] AWADDR;
    rand logic [DATA_WIDTH-1:0] WDATA;

    logic [1:0] BRESP;

    typedef AXI4Lite_wr_item #(DATA_WIDTH, ADDR_WIDTH) axi_wr_itm;
    `uvm_object_param_utils(axi_wr_itm)

    function new(string name = "AXI4Lite_wr_item");
        super.new(name);
    endfunction

endclass