`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)
`uvm_analysis_imp_decl(_irq)

class AXI4Lite_scoreboard #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32) extends uvm_scoreboard;

    typedef AXI4Lite_scoreboard #(ADDR_WIDTH,DATA_WIDTH) this_sb;
    `uvm_component_utils(this_sb)

    logic [DATA_WIDTH-1:0] expected_regs [bit [ADDR_WIDTH-1:0]];
    logic irq_ref_model;
    logic irq_copy;
    int pass_count, fail_count;

    uvm_analysis_imp_wr #(AXI4Lite_wr_item, this_sb) wr_imp;

    uvm_analysis_imp_rd #(AXI4Lite_rd_item, this_sb) rd_imp;

    uvm_analysis_imp_irq #(irq_seq_item, this_sb) irq_imp;

    function new(string name = "AXI4Lite_scoreboard",uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        pass_count = 0;
        fail_count = 0;

        wr_imp = new("wr_imp",this);
        rd_imp = new("rd_imp",this);
        irq_imp = new("irq_imp",this);
        
    endfunction

    function void write_irq(irq_seq_item itm);
        
        if(itm.irq_set_i)

            irq_ref_model = 1'b1;

        irq_copy = itm.irq_set_i;
        
    endfunction

    function void write_wr(AXI4Lite_wr_item wr_itm);
        
        case(wr_itm.AWADDR)
            CTRL_ADDR : expected_regs[wr_itm.AWADDR] = {(DATA_WIDTH-3){1'b0},wr_itm.WDATA[2:0]};
            DATA_ADDR : expected_regs[wr_itm.AWADDR] = wr_itm.WDATA;
            STATUS_ADDR : ;
            IRQ_STATUS_ADDR : begin
                if(!irq_copy && wr_itm.WDATA[0])
                    irq_ref_model = 1'b0;
            end 
            default : ;
        endcase
        
    endfunction

    function void write_rd(AXI4Lite_rd_item rd_itm);
        
        case (rd_itm.ARADDR)
        CTRL_ADDR : begin
            if(rd_itm.RDATA != {(DATA_WIDTH - 3){1'b0},expected_regs[rd_itm.ARADDR]})begin
                `uvm_error(get_type_name(),$sformatf("Error - CTRL_ADDR"))
                fail_count++;
            end
            else begin
                pass_count++;
            end
        end  
        DATA_ADDR : begin
            if(rd_itm.RDATA != expected_regs[rd_itm.ARADDR])begin
                `uvm_error(get_type_name(),$sformatf("Error - DATA_ADDR"))
                fail_count++;
            end
            else begin
                pass_count++;
            end
        end  
        STATUS_ADDR : begin
            if($isunknown(rd_itm.RDATA)) begin
                `uvm_error(get_type_name(),$sformatf("Error - STATUS_ADDR"))
                fail_count++;
            end
            else begin
                pass_count++;
            end
        end 
        IRQ_STATUS_ADDR : begin
            if(rd_itm.RDATA != {(DATA_WIDTH -1){1'b0},irq_ref_model}) begin
                `uvm_error(get_type_name(),$sformatf("Error - IRQ_STATUS_ADDR"))
                fail_count++;
            end
            else begin
                pass_count++;
            end
        end 
        endcase
    endfunction

    function void report_phase(uvm_phase phase);

        `uvm_info(get_type_name(), $sformatf("========== SUMMARY =========="), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Tranasctions: %0d", pass_count + fail_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("PASS: %0d", pass_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("FAIL: %0d", fail_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("=================================="), UVM_LOW)

    endfunction

endclass