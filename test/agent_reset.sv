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
 * PicoRV; It contains the agent for the memory interface
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
 */
 `include "uvm_macros.svh"

class agent_reset extends uvm_agent;
    `uvm_component_utils(agent_reset)

    function new(string name="agent_reset", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual reset_if intf_if;
    reset_driver driv_reset;
    reset_sequencer seqr_reset;
    monitor_reset  mon_reset;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual reset_if)::get(this,
                                                  "",
                                                  "VIRTUAL_R_INTERFACE",
                                                  intf_if) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT",
                       "Could not get from the database the virtual interface (reset) for the TB")
        end
        driv_reset = reset_driver::type_id::create("driv_reset", this);
        seqr_reset = reset_sequencer::type_id::create("seqr_reset", this);
        mon_reset  = monitor_reset::type_id::create("mon_reset", this);
      endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driv_reset.seq_item_port.connect(seqr_reset.seq_item_export);
      mon_reset.reset_port.connect(seqr_reset.rst_export);
    endfunction

endclass: agent_reset
