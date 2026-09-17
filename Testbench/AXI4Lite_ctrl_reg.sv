`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_ctrl_reg extends uvm_reg;

    `uvm_object_utils(AXI4Lite_ctrl_reg)

    rand uvm_reg_field enable;
    rand uvm_reg_field mode;
    uvm_reg_field reserved;


    function new(string name = "AXI4Lite_ctrl_reg");

        super.new(name,32,UVM_NO_COVERAGE);
        
    endfunction

    virtual function void build();

        enable = uvm_reg_field :: type_id :: create("enable");
        mode = uvm_reg_field :: type_id :: create("mode");
        reserved = uvm_reg_field :: type_id :: create("reserved");

        enable.configure(this, 1, 0, "RW", 1'b0, 'h0, 1'b1, 1'b1, 1'b0);
        mode.configure(this, 2, 1, "RW", 1'b0, 'h0, 1'b1, 1'b1, 1'b0);
        reserved.configure(this, 29, 3, "RO", 1'b0, 'h0, 1'b1, 1'b0, 1'b0);
      
    endfunction
endclass
