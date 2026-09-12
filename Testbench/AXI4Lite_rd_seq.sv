`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_seq extends uvm_sequence #(AXI4Lite_rd_item);

    `uvm_object_utils(AXI4Lite_rd_seq)

    int num_trans = 1000;

    semaphore addr_lock [bit [3:0]];

    function new(string name = "AXI4Lite_rd_seq");

        super.new(name);

    endfunction

    task body();

        AXI4Lite_rd_item rd_itm;

        repeat(num_trans) begin
            
            rd_itm = AXI4Lite_rd_item :: type_id :: create("rd_itm");

            assert(rd_itm.randomize() with {ARADDR inside {4'h0, 4'h4, 4'h8, 4'hC};})
                else `uvm_fatal("WR_SEQ","Randomization failed")

            addr_lock[rd_itm.ARADDR].get(1);

            start_item(rd_itm);

            finish_item(rd_itm);

            addr_lock[rd_itm.ARADDR].put(1);
            
        end
      
    endtask
endclass