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
 * PicoRV; It contains the basic test, made to test the ISA for the PicoRV32-IM
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 9/9/2024
 */
 `include "uvm_macros.svh"

class test_basic extends uvm_test;
    `uvm_component_utils(test_basic)

    function new (string name="test_basic", uvm_component parent=null);
        super.new (name, parent);
    endfunction : new

    virtual mem_if intf_mem_if;
    virtual pcpi_if intf_pcpi_if;
    virtual reset_if intf_reset_if;
    environment env;

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
        env  = environment::type_id::create ("env", this);

    endfunction: build_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
        print();
    endfunction : end_of_elaboration_phase

    virtual_sequence v_seq;

    virtual task run_phase(uvm_phase phase);

        phase.raise_objection (this);
        uvm_report_info(get_full_name(),"Start", UVM_LOW);
        v_seq = virtual_sequence::type_id::create("v_seq");
        v_seq.start(env.virtual_seqr);
        #1000
        phase.drop_objection (this);
      endtask: run_phase

endclass: test_basic





