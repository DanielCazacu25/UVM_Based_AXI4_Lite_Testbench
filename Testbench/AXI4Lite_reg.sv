`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_reg extends uvm_reg;

    `uvm_object_utils(AXI4Lite_reg)

    rand uvm_reg_field CTRL_REG;
    rand uvm_reg_field STATUS_REG;
    rand uvm_reg_field DATA_REG;
    rand uvm_reg_field IRQ_STATUS_REG;


    function new(string name = "AXI4Lite_reg");

        super.new(name,32,UVM_NO_COVERAGE);
        
    endfunction

    virtual function void build();

        CTRL_REG = uvm_reg_field :: type_id :: create("CTRL_REG");
        STATUS_REG = uvm_reg_field :: type_id :: create("STATUS_REG");
        DATA_REG = uvm_reg_field :: type_id :: create("DATA_REG");
        IRQ_STATUS_REG = uvm_reg_field :: type_id :: create("IRQ_STATUS_REG");

        CTRL_REG.configure(this, )
      
    endfunction
endclass