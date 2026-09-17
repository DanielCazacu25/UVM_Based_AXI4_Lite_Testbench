`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_reg_block extends uvm_reg_block;

    `uvm_object_utils(AXI4Lite_reg_block)

    rand AXI4Lite_ctrl_reg ctrl;
    rand AXI4Lite_status_reg status;
    rand AXI4Lite_data_reg data;
    rand AXI4Lite_irq_status_reg irq;
    uvm_reg_map axi_map;

    function new(string name = "AXI4Lite_reg_block");

        super.new(name, UVM_NO_COVERAGE);
        
    endfunction

    virtual function void build();

        axi_map = create_map("axi_map", 'h0, 4, UVM_LITTLE_ENDIAN, 3);

        ctrl = AXI4Lite_ctrl_reg :: type_id :: create("ctrl");
        ctrl.configure(this,null,"");
        ctrl.build();
        axi_map.add_reg(ctrl, 'h0, "RW");

        status = AXI4Lite_status_reg :: type_id :: create("status");
        status.configure(this,null,"");
        status.build();
        axi_map.add_reg(status, 'h4, "RO");

        data = AXI4Lite_data_reg :: type_id :: create("data");
        data.configure(this,null,"");
        data.build();
        axi_map.add_reg(data, 'h8, "RW");

        irq = AXI4Lite_irq_status_reg :: type_id :: create("irq");
        irq.configure(this,null,"");
        irq.build();
        axi_map.add_reg(irq, 'hC, "RW");

        lock_model();

    endfunction
endclass