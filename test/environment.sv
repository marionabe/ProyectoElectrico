/*
 * Copyright (c) 2024 Mario Navarro
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/*
 * Universidad de Costa Rica.
 * Escuela de Ingeniería Eléctrica: IE0499 - Proyecto Eléctrico.
 *
 * Description: This document is part of the project: Functional verification of
 * PicoRV; It contains the environment and all the sub_modules, like the UVC for
 * the memory, the PCPI and the reset functions.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 9/9/2024
 */
 `include "uvm_macros.svh"

class environment extends uvm_env;
    `uvm_component_utils(environment)

    function new (string name = "environment", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    virtual mem_if intf_mem_if;
    virtual pcpi_if intf_pcpi_if;
    virtual reset_if intf_reset_if;

    agent_mem agt_mem;
    agent_reset agt_reset;
    agent_pcpi agt_pcpi;
    virtual_sequencer virtual_seqr;
    scoreboard scb;
    funct_coverage funct_cov;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual mem_if)::get(this,
                                                "",
                                                "VIRTUAL_M_INTERFACE",
                                                intf_mem_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                       "Could not get from the database the virtual interface for the TB")
        end

        if(uvm_config_db #(virtual reset_if)::get(this,
                                                "",
                                                "VIRTUAL_R_INTERFACE",
                                                intf_reset_if) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT",
        "Could not get from the database the virtual interface for the TB")
        end

        if(uvm_config_db #(virtual pcpi_if)::get(this,
                                                  "",
                                                  "VIRTUAL_P_INTERFACE",
                                                  intf_pcpi_if) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT",
        "Could not get from the database the virtual interface for the TB")
        end

        agt_mem = agent_mem::type_id::create ("agt_mem", this);
        agt_reset = agent_reset::type_id::create ("agt_reset", this);
        agt_pcpi = agent_pcpi::type_id::create ("agt_pcpi", this);
        virtual_seqr = virtual_sequencer::type_id::create ("virtual_seqr", this);
        scb = scoreboard::type_id::create("scb", this);
        funct_cov = funct_coverage::type_id::create("funct_cov", this);

        uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
        print();
      endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        virtual_seqr.reset_seqr = agt_reset.seqr_reset;
        virtual_seqr.pcpi_seqr = agt_pcpi.seqr_pcpi;
        virtual_seqr.mem_seqr = agt_mem.seqr_mem;

        agt_mem.mon_mem.instr_analysis_port.connect(scb.mc_mem);
        agt_mem.mon_mem.reg_state_port.connect(scb.mc_reg);
        agt_reset.mon_reset.reset_analysis_port.connect(scb.mc_rset);
        agt_pcpi.mon_pcpi.pcpi_analysis_port.connect(scb.mc_pcpi);
    endfunction: connect_phase

endclass: environment
