`include "uvm_macros.svh"
import uvm_pkg::*;

class AXI4Lite_ral_test extends uvm_test;

    `uvm_component_utils(AXI4Lite_ral_test)

    AXI4Lite_env env;
    AXI4Lite_ral_seq ral_seq;
    virtual AXI4Lite_inf inf;

    function new(string name = "AXI4Lite_ral_test", uvm_component parent);

        super.new(name,parent);
        
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        
        env = AXI4Lite_env :: type_id :: create("env",this);

        if(!uvm_config_db#(virtual AXI4Lite_inf) :: get(this,"","inf",inf))
            `uvm_fatal("NOINF","Interface not found")
      
    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        ral_seq = AXI4Lite_ral_seq :: type_id :: create("ral_seq");

        wait(inf.ARESETN === 1'b1);
        @(posedge inf.ACLK);

        ral_seq.start(env.virt_seqr);

        phase.phase_done.set_drain_time(this, 200ns);

        phase.drop_objection(this);
      
    endtask
endclass