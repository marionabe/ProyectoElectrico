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

class agent_pcpi extends uvm_agent;
    `uvm_component_utils(agent_pcpi)

    function new(string name="agent_pcpi", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual pcpi_if intf_if;
    pcpi_driver driv_pcpi;
    pcpi_sequencer seqr_pcpi;
    monitor_pcpi mon_pcpi;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual pcpi_if)::get(this,
                                                      "",
                                                      "VIRTUAL_P_INTERFACE",
                                                      intf_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                       "Could not get from the database the virtual interface (PCPI) for the TB")
        end
        driv_pcpi = pcpi_driver ::type_id::create ("driv_pcpi", this);
        seqr_pcpi = pcpi_sequencer::type_id::create("seqr_pcpi", this);
        mon_pcpi = monitor_pcpi::type_id::create("mon_pcpi", this);
      endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
        driv_pcpi.seq_item_port.connect(seqr_pcpi.seq_item_export);
        mon_pcpi.pcpi_port.connect(seqr_pcpi.pcpi_export);
    endfunction

endclass: agent_pcpi





