`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_rd_adapter extends uvm_reg_adapter;

    `uvm_object_utils(AXI4Lite_rd_adapter)

    function new(string name = "AXI4Lite_rd_adapter");
    
        super.new(name);
        
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

        AXI4Lite_rd_item rd_itm;
        if(!$cast(rd_itm,bus_item)) begin
            `uvm_fatal(get_type_name(),"ERROR : provided item is not AXI4Lite_rd_item type")
        end
        rw.kind = UVM_READ;
        rw.addr = rd_itm.ARADDR;
        rw.data = rd_itm.RDATA;
        rw.status = (rd_itm.RRESP == RESP_OKAY)? UVM_IS_OK : UVM_NOT_OK;
        rw.n_bits = DATA_WIDTH;
        rw.byte_en = '1;
      
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

        AXI4Lite_rd_item rd_itm;

        `uvm_fatal(get_type_name(),"ERROR : reg2bus should not be called")

        return rd_itm;
      
    endfunction

endclass