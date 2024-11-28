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
 * PicoRV; It contains the monitor for the pcpi interface.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 22/9/2024
 */
 `include "uvm_macros.svh"

class monitor_pcpi extends uvm_monitor;
    `uvm_component_utils(monitor_pcpi)

    virtual pcpi_if intf_if;

    uvm_analysis_port #(pcpi_item) pcpi_analysis_port;
    uvm_analysis_port #(pcpi_req)  pcpi_port;

    function new (string name, uvm_component parent = null);
        super.new (name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);

        pcpi_port = new ("pcpi_port", this);
        pcpi_analysis_port = new ("pcpi_analysis_port", this);

        if(uvm_config_db #(virtual pcpi_if)::get(
                                                this,
                                                "",
                                                "VIRTUAL_P_INTERFACE",
            intf_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                      "Could not get from the database the virtual interface for the TB")
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        pcpi_req pcpi_req_item = pcpi_req::type_id::create("pcpi_req_item", this);
        pcpi_item pcpi_itm = pcpi_item::type_id::create("pcpi_itm", this);
        fork
            pcpi_req_obsv (pcpi_req_item);
            pcpi_obsv (pcpi_itm);
        join

    endtask: run_phase

    virtual task pcpi_req_obsv (pcpi_req pcpi_req_item);
        forever begin
            @(posedge intf_if.clk);
            if (intf_if.pcpi_valid && intf_if.pcpi_insn[6:0]==7'b1111111)begin
                `uvm_info("test", $sformatf("PCPI req detect"), UVM_LOW)
                // Send a request only when the fake instruction is received
                // Div and Mul instr also use this interface
                pcpi_req_item.pcpi_valid = intf_if.pcpi_valid;
                pcpi_req_item.pcpi_insn  = intf_if.pcpi_insn;
                pcpi_req_item.pcpi_rs2   = intf_if.pcpi_rs2;
                pcpi_req_item.pcpi_rs1   = intf_if.pcpi_rs1;
                pcpi_port.write(pcpi_req_item);
                @(negedge intf_if.pcpi_valid);
            end else begin
                pcpi_req_item.pcpi_valid = 0;
                pcpi_req_item.pcpi_insn  = 0;
                pcpi_req_item.pcpi_rs2   = 0;
                pcpi_req_item.pcpi_rs1   = 0;
                pcpi_port.write(pcpi_req_item);
            end
        end
    endtask: pcpi_req_obsv

    virtual task pcpi_obsv (pcpi_item pcpi_itm);
        forever begin
            @(posedge intf_if.clk);
            if (intf_if.pcpi_ready)begin
                //FIXME: add the rest of the code to send the correct item
                pcpi_itm.return_value=0;
                pcpi_analysis_port.write(pcpi_itm);
            end
        end
    endtask: pcpi_obsv

endclass: monitor_pcpi
