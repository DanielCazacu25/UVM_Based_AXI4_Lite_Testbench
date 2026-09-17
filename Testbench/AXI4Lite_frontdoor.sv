`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_frontdoor extends uvm_reg_frontdoor;

    `uvm_object_utils(AXI4Lite_frontdoor)
    `uvm_declare_p_sequencer(AXI4Lite_virtual_sequencer)

    uvm_reg reg_handle;
    uvm_reg_addr_t addr;

    function new(string name = "AXI4Lite_frontdoor");

        super.new(name);
        
    endfunction

    virtual task body();

        if(!$cast(reg_handle, rw_info.element)) begin
            `uvm_fatal(get_type_name(),"ERROR WHILE TRYING TO CAST")
        end

        addr = reg_handle.get_address(rw_info.local_map);
        if(rw_info.kind == UVM_WRITE) begin
            
            AXI4Lite_wr_item wr_itm;
            wr_itm = AXI4Lite_wr_item :: type_id :: create("wr_itm");
            start_item(wr_itm, -1, p_sequencer.wr_seqr);
            wr_itm.AWADDR = addr;
            wr_itm.WDATA = rw_info.value[0];
            finish_item(wr_itm);
            rw_info.status = (wr_itm.BRESP == RESP_OKAY)? UVM_IS_OK : UVM_NOT_OK;

        end

        else begin
            
            AXI4Lite_rd_item rd_itm;
            rd_itm = AXI4Lite_rd_item :: type_id :: create("rd_itm");
            start_item(rd_itm, -1, p_sequencer.rd_seqr);
            rd_itm.ARADDR = addr;
            finish_item(rd_itm);
            rw_info.value[0] = rd_itm.RDATA;
            rw_info.status = (rd_itm.RRESP == RESP_OKAY)? UVM_IS_OK : UVM_NOT_OK;

        end

    endtask
endclass