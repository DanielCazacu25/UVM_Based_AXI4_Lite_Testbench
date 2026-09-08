`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_test extends uvm_test;

    `uvm_component_utils(AXI4Lite_test)

    AXI4Lite_env env;

    AXI4Lite_virtual_sequence virt_seq;

    function new(string name = "AXI4Lite_test", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = AXI4Lite_env :: type_id :: create("env",this);
      
    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        virt_seq = AXI4Lite_virtual_sequence :: type_id :: create("virt_seq");

        virt_seq.start(env.virt_seqr);

        phase.drop_objection(this);
      
    endtask
endclass