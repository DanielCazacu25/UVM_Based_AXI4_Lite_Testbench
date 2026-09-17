`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_wr_adapter extends uvm_reg_adapter;

    `uvm_object_utils(AXI4Lite_wr_adapter)

    function new(string name = "AXI4Lite_wr_adapter");
    
        super.new(name);
        
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

        AXI4Lite_wr_item wr_itm;
        if(!$cast(wr_itm,bus_item)) begin
            `uvm_fatal(get_type_name(),"ERROR : provided item is not AXI4Lite_wr_item type")
        end
        rw.kind = UVM_WRITE;
        rw.addr = wr_itm.AWADDR;
        rw.data = wr_itm.WDATA;
        rw.status = (wr_itm.BRESP == RESP_OKAY)? UVM_IS_OK : UVM_NOT_OK;
        rw.n_bits = DATA_WIDTH;
        rw.byte_en = '1;
      
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

        `uvm_fatal(get_type_name(),"ERROR : reg2bus should not be called")

        return wr_itm;
      
    endfunction

endclass