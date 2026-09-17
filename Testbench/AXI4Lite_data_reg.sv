`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_data_reg extends uvm_reg;

    `uvm_object_utils(AXI4Lite_data_reg)

    rand uvm_reg_field data;


    function new(string name = "AXI4Lite_data_reg");

        super.new(name,32,UVM_NO_COVERAGE);
        
    endfunction

    virtual function void build();

        data = uvm_reg_field :: type_id :: create("data");

        data.configure(this, 32, 0, "RW", 1'b0, 'h0, 1'b1, 1'b1, 1'b0);
      
    endfunction
endclass