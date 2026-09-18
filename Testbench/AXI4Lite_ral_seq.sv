`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_ral_seq extends uvm_sequence;

    `uvm_object_utils(AXI4Lite_ral_seq)

    `uvm_declare_p_sequencer(AXI4Lite_virtual_sequencer)

    AXI4Lite_reg_block reg_block;
    irq_seq_item irq_set_itm;
    irq_seq_item irq_clear_itm;
    uvm_reg_bit_bash_seq bit_bash_seq;
    uvm_reg_hw_reset_seq reset_seq;
    uvm_reg_data_t rdata;
    uvm_status_e status;

    function new(string name = "AXI4Lite_ral_seq");

        super.new(name);
        
    endfunction

    virtual task body();

        if(!uvm_config_db#(AXI4Lite_reg_block)::get(m_sequencer, "", "reg_block", reg_block)) begin
            
            `uvm_fatal(get_type_name(),"ERROR : reg_block not found")
        end

        reg_block.reset();

        uvm_resource_db#(bit)::set({"REG::", reg_block.irq.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);

        //bit bash test automaticly changes every bit in the register but irq has W1C policy which means it can change automaticly(by the DUT) during testing
        //it's already tested by default UVM classes

        //also status_reg will not contain .write method since it's set as RO

        reset_seq = uvm_reg_hw_reset_seq :: type_id :: create("reset_seq");
        reset_seq.model = reg_block;
        reset_seq.start(null);

        bit_bash_seq = uvm_reg_bit_bash_seq :: type_id :: create("bit_bash_seq");
        bit_bash_seq.model = reg_block;
        bit_bash_seq.start(null);

        reg_block.ctrl.write(status, 8'hF);
        if(status != UVM_IS_OK)
            `uvm_error(get_type_name(),"ERROR while writing on CTRL_REG")
        reg_block.data.write(status, 8'hA);
        if(status != UVM_IS_OK)
            `uvm_error(get_type_name(),"ERROR while writing on DATA_REG")
        reg_block.irq.write(status, 1'b1);
        if(status != UVM_IS_OK)
            `uvm_error(get_type_name(),"ERROR while writing on IRQ_STATUS_REG")

        reg_block.ctrl.mirror(status, UVM_CHECK);
        if(status != UVM_IS_OK)
            `uvm_error(get_type_name(),"ERROR while reading from CTRL_REG")
        reg_block.data.mirror(status, UVM_CHECK);
        if(status != UVM_IS_OK)
            `uvm_error(get_type_name(),"ERROR while reading from DATA_REG")
        reg_block.irq.read(status,rdata);
        if(rdata[0] != 1'b0)
            `uvm_error(get_type_name(),"ERROR while reading from IRQ_STATUS_REG")

        reg_block.ctrl.write(status, 32'hFFFF_FFFF);
        reg_block.ctrl.mirror(status, UVM_CHECK);
        if(status != UVM_IS_OK)
            `uvm_error(get_type_name(),"ERROR bits 31-3 should be RO")

        irq_set_itm = irq_seq_item :: type_id :: create("irq_set_itm");
        start_item(irq_set_itm, -1, p_sequencer.irq_seqr);
        irq_set_itm.irq_set_i = 1;
        finish_item(irq_set_itm);

        irq_clear_itm = irq_seq_item :: type_id :: create("irq_clear_itm");
        start_item(irq_clear_itm, -1, p_sequencer.irq_seqr);
        irq_clear_itm.irq_set_i = 0;
        finish_item(irq_clear_itm);

        reg_block.irq.read(status,rdata);
        if(rdata[0] != 1'b1)
            `uvm_error(get_type_name(),"ERROR the pulse did not reach the DUT")

        reg_block.irq.write(status, 1'b0);
        reg_block.irq.read(status,rdata);
        if(rdata[0] != 1'b1)
            `uvm_error(get_type_name(),"ERROR W1C: only write 1 clears")

        reg_block.irq.write(status, 1'b1);
        reg_block.irq.read(status,rdata);
        if(rdata[0] != 1'b0)
            `uvm_error(get_type_name(),"ERROR W1C: write 1 clears")
      
    endtask

endclass