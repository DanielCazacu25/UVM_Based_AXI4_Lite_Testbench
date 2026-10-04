`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_item #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 4) extends uvm_sequence_item;

    rand logic [ADDR_WIDTH-1:0] ARADDR;
    logic [DATA_WIDTH-1:0] RDATA;

    logic [1:0] RRESP;

    typedef AXI4Lite_rd_item #(DATA_WIDTH, ADDR_WIDTH) axi_rd_itm;
    `uvm_object_param_utils(axi_rd_itm)

    function new(string name = "AXI4Lite_rd_item");

        super.new(name);
        
    endfunction

endclass