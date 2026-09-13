`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)
`uvm_analysis_imp_decl(_irq)
`uvm_analysis_imp_decl(_addr)

class AXI4Lite_scoreboard #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32) extends uvm_scoreboard;

    typedef AXI4Lite_scoreboard #(ADDR_WIDTH,DATA_WIDTH) this_sb;
    `uvm_component_utils(this_sb)

    logic [DATA_WIDTH-1:0] expected_regs [bit [ADDR_WIDTH-1:0]];
    logic irq_ref_model;
    logic irq_ref_copy;
    logic irq_copy;
    int pass_count, fail_count;
    localparam CTRL_ADDR       = 4'h0;
    localparam STATUS_ADDR     = 4'h4;
    localparam DATA_ADDR       = 4'h8;
    localparam IRQ_STATUS_ADDR = 4'hC;

    uvm_analysis_imp_wr #(AXI4Lite_wr_item, this_sb) wr_imp;

    uvm_analysis_imp_rd #(AXI4Lite_rd_item, this_sb) rd_imp;

    uvm_analysis_imp_irq #(irq_seq_item, this_sb) irq_imp;

    uvm_analysis_imp_addr #(AXI4Lite_rd_item, this_sb) addr_imp;

    function new(string name = "AXI4Lite_scoreboard",uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        pass_count = 0;
        fail_count = 0;
        irq_ref_model = 0;
        irq_ref_copy  = 0;
        irq_copy = 0;

        // Valorile de reset ale DUT-ului. Fara ele, o citire care ajunge
        // inaintea primei scrieri gaseste 'x in array-ul asociativ, iar
        // comparatia cu !== ar raporta o eroare falsa.
        expected_regs[CTRL_ADDR] = '0;
        expected_regs[DATA_ADDR] = '0;

        wr_imp = new("wr_imp",this);
        rd_imp = new("rd_imp",this);
        irq_imp = new("irq_imp",this);
        addr_imp = new("addr_imp",this);
        
    endfunction

    function void write_addr(AXI4Lite_rd_item itm);

        if(itm.ARADDR == IRQ_STATUS_ADDR) begin
            
           irq_ref_copy = irq_ref_model;

        end
      
    endfunction

    function void write_irq(irq_seq_item itm);
        
        if(itm.irq_set_i)

            irq_ref_model = 1'b1;

        irq_copy = itm.irq_set_i;
        
    endfunction

    function void write_wr(AXI4Lite_wr_item wr_itm);
        
        case(wr_itm.AWADDR)
            CTRL_ADDR : expected_regs[wr_itm.AWADDR] = {{(DATA_WIDTH-3){1'b0}},wr_itm.WDATA[2:0]};
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

        logic [DATA_WIDTH-1:0] exp;

        case (rd_itm.ARADDR)

        CTRL_ADDR : begin
            exp = expected_regs[CTRL_ADDR];
            if(rd_itm.RDATA !== exp) begin
                `uvm_error(get_type_name(), $sformatf(
                    "CTRL_REG: read mismatch - expected 0x%0h, got 0x%0h | enable exp/got = %0b/%0b, mode exp/got = %0b/%0b | prediction comes from the last write to CTRL_REG",
                    exp, rd_itm.RDATA,
                    exp[0], rd_itm.RDATA[0],
                    exp[2:1], rd_itm.RDATA[2:1]))
                fail_count++;
            end
            else pass_count++;
        end

        DATA_ADDR : begin
            exp = expected_regs[DATA_ADDR];
            if(rd_itm.RDATA !== exp) begin
                `uvm_error(get_type_name(), $sformatf(
                    "DATA_REG: read mismatch - expected 0x%08h, got 0x%08h | prediction comes from the last write to DATA_REG",
                    exp, rd_itm.RDATA))
                fail_count++;
            end
            else pass_count++;
        end

        STATUS_ADDR : begin
            if($isunknown(rd_itm.RDATA)) begin
                `uvm_error(get_type_name(), $sformatf(
                    "STATUS_REG: RDATA contains X/Z - got 0x%08h | the busy bit is not modelled, only definedness is checked here",
                    rd_itm.RDATA))
                fail_count++;
            end
            else pass_count++;
        end

        IRQ_STATUS_ADDR : begin
            exp = {{(DATA_WIDTH-1){1'b0}}, irq_ref_copy};
            if(rd_itm.RDATA !== exp) begin
                `uvm_error(get_type_name(), $sformatf(
                    "IRQ_STATUS_REG: read mismatch - expected 0x%0h, got 0x%0h | prediction is the snapshot taken at the read address handshake",
                    exp, rd_itm.RDATA))
                fail_count++;
            end
            else pass_count++;
        end

        default : begin
            exp = '0;
            if(rd_itm.RDATA !== exp) begin
                `uvm_error(get_type_name(), $sformatf(
                    "Unmapped ADDR 0x%0h: spec requires RDATA = 0 - expected 0x%08h, got 0x%08h",
                    rd_itm.ARADDR, exp, rd_itm.RDATA))
                fail_count++;
            end
            else pass_count++;
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