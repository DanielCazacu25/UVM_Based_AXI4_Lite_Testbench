`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_status_reg extends uvm_reg;

    `uvm_object_utils(AXI4Lite_status_reg)

    uvm_reg_field busy;
    uvm_reg_field reserved;


    function new(string name = "AXI4Lite_status_reg");

        super.new(name,32,UVM_NO_COVERAGE);
        
    endfunction

    virtual function void build();

        busy = uvm_reg_field :: type_id :: create("busy");
        reserved = uvm_reg_field :: type_id :: create("reserved");

        busy.configure(this, 1, 0, "RO", 1'b1, 'h0, 1'b0, 1'b0, 1'b0);
        reserved.configure(this, 31, 1, "RO", 1'b0, 'h0, 1'b1, 1'b0, 1'b0);
      
    endfunction
endclass