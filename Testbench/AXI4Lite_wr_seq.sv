`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_seq extends uvm_sequence #(AXI4Lite_wr_item);

    `uvm_object_utils(AXI4Lite_wr_seq)

    int num_trans = 1000;

    semaphore addr_lock [bit [3:0]];

    function new(string name = "AXI4Lite_wr_seq");

        super.new(name);

    endfunction

    task body();

        AXI4Lite_wr_item wr_itm;

        repeat(num_trans) begin
            
            wr_itm = AXI4Lite_wr_item :: type_id :: create("wr_itm");

            assert(wr_itm.randomize() with {AWADDR inside {4'h0, 4'h4, 4'h8, 4'hC};})
                else `uvm_fatal("WR_SEQ","Randomization failed")
                
            addr_lock[wr_itm.AWADDR].get(1);

            start_item(wr_itm);

            finish_item(wr_itm);

            addr_lock[wr_itm.AWADDR].put(1);

        end
      
    endtask
endclass