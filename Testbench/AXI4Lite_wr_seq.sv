`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_seq extends uvm_sequence #(AXI4Lite_wr_item);

    `uvm_object_utils(AXI4Lite_wr_seq)

    int num_trans = 1000;

    function new(string name = "AXI4Lite_wr_seq");

        super.new(name);

    endfunction

    task body();

        AXI4Lite_wr_item wr_itm;

        repeat(num_trans) begin
            
            wr_itm = AXI4Lite_wr_item :: type_id :: create("wr_itm");

            start_item(wr_itm);

            assert(wr_itm.randomize() with {AWADDR inside {4'h0, 4'h4, 4'h8, 4'hC}});

            finish_item(wr_itm);

        end
      
    endtask
endclass