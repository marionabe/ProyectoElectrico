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

class agent_mem extends uvm_agent;
    `uvm_component_utils(agent_mem)

    function new(string name="agent_mem", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual mem_if intf_if;
    picorv_driver driv_mem;
    mem_sequencer seqr_mem;
    monitor_mem mon_mem;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual mem_if)::get(this,
                                                "",
                                                "VIRTUAL_M_INTERFACE",
                                                intf_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                       "Could not get from the database the virtual interface for the TB")
        end
        driv_mem = picorv_driver::type_id::create ("driv_mem", this);
        seqr_mem = mem_sequencer::type_id::create("seqr_mem", this);
        mon_mem = monitor_mem::type_id::create("mon_mem", this);
      endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
        driv_mem.seq_item_port.connect(seqr_mem.seq_item_export);
        mon_mem.request_port.connect(seqr_mem.request_export);
    endfunction

endclass: agent_mem





