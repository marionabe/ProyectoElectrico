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
 * PicoRV; It contains the monitor for the reset interface.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 21/9/2024
 */
 `include "uvm_macros.svh"

class monitor_reset extends uvm_monitor;
    `uvm_component_utils(monitor_reset)

    virtual reset_if intf_if;
    bit init_reset;

    uvm_analysis_port #(reset_item)   reset_analysis_port;
    uvm_analysis_port #(reset_req)  reset_port;

    function new (string name, uvm_component parent = null);
        super.new (name, parent);
        init_reset=1;
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);

        reset_port = new ("reset_port", this);
        reset_analysis_port = new ("reset_analysis_port", this);

        if(uvm_config_db #(virtual reset_if)::get(
                                                this,
                                                "",
                                                "VIRTUAL_R_INTERFACE",
            intf_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                      "Could not get from the database the virtual interface for the TB")
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        reset_req rst_item = reset_req::type_id::create("rst_item", this);
        reset_item reset_itm = reset_item::type_id::create("reset_itm", this);
        fork
            reset_req_obsv (rst_item);
            reset_obsv (reset_itm);
        join

    endtask: run_phase

    virtual task reset_req_obsv (reset_req rst_item);
        forever begin
            @(posedge intf_if.clk);
            if (init_reset)begin
                rst_item.reset_required=1;
                init_reset=0;
            end else if (intf_if.trap)begin
                rst_item.reset_required=1;
            end else begin
                rst_item.reset_required=0;
            end
            reset_port.write (rst_item);
        end
    endtask: reset_req_obsv

    virtual task reset_obsv (reset_item rst_item);
        forever begin
            @(posedge intf_if.clk);
            rst_item.reset_time = 0;
            reset_analysis_port.write(rst_item);
        end
    endtask: reset_obsv

endclass: monitor_reset
