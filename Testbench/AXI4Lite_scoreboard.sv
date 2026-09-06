`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_write)
`uvm_analysis_imp_decl(_read)

class AXI4Lite_scoreboard #(parameter ADDR_WIDTH = 4, parameter DATA_WIDTH = 32) extends uvm_scoreboard;

    typedef AXI4Lite_scoreboard #(ADDR_WIDTH,DATA_WIDTH) this_sb;
    `uvm_component_utils(this_sb)

    logic [DATA_WIDTH-1:0] expected_regs [bit [ADDR_WIDTH-1:0]];
    int pass_count, fail_count;

    uvm_analysis_imp #(AXI4Lite_wr_item, this_sb) wr_imp;

    uvm_analysis_imp #(AXI4Lite_rd_item, this_sb) rd_imp;

    function new(string name = "AXI4Lite_scoreboard",uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);

        pass_cout = 0;
        fail_count = 0;

        wr_imp = new("wr_imp",this);
        rd_imp = new("rd_imp",this);
        
    endfunction

    function void write_wr(AXI4Lite_wr_item wr_itm);
        
        case(wr_itm.AWADDR)
            CTRL_ADDR : expected_regs = wr_itm.WDATA[2:0];
            DATA_ADDR : expected_regs = wr_itm.WDATA;
            IRQ_STATUS_ADDR begin
                if(wr_itm.)
            end 
        endcase
        
    endfunction

endclass