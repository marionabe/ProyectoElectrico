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
 * PicoRV;
 * It contains three classes: the driver, the sequence_item and the sequencer.
 * All these classes are UVM components.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
 */

`include "uvm_macros.svh"
import uvm_pkg::*;

class reset_item extends uvm_sequence_item;
    rand int reset_time;
    // FIXME: Add constraint for reset_time
    `uvm_object_utils_begin(reset_item)
        `uvm_field_int (reset_time, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "reset_item");
        super.new(name);
    endfunction: new
endclass: reset_item


class reset_sequencer extends uvm_sequencer #(reset_item);
    `uvm_component_utils(reset_sequencer)

    uvm_analysis_port #(reset_req) rst_export;
    uvm_tlm_analysis_fifo #(reset_req) rst_fifo;

    function new (string name = "reset_sequencer", uvm_component parent = null);
        super.new (name, parent);
        rst_export = new("rst_export", this);
        rst_fifo = new("rst_fifo", this);
    endfunction:new

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        rst_export.connect(rst_fifo.analysis_export);
    endfunction: connect_phase
endclass: reset_sequencer



class reset_item_seq extends uvm_sequence;
    `uvm_object_utils(reset_item_seq)
    `uvm_declare_p_sequencer (reset_sequencer)
    reset_req rst_req;

    function new(string name="reset_item_seq");
        super.new(name);
    endfunction: new

    virtual task body();
        while(1)begin
            reset_item r_item = reset_item::type_id::create("reset_item");
            p_sequencer.rst_fifo.get(rst_req);
            if (rst_req.reset_required)begin
                `uvm_info("R_SEQ", $sformatf("Reset Required"), UVM_LOW)
                start_item(r_item);
                r_item.randomize();
                `uvm_info("R_SEQ", $sformatf("Generate new reset item: "), UVM_LOW)
                r_item.print();
                finish_item(r_item);
                `uvm_info("R_SEQ", $sformatf("Done generation of new reset item"), UVM_LOW)
            end
        end

    endtask: body
endclass: reset_item_seq


class reset_driver extends uvm_driver #(reset_item);
    `uvm_component_utils (reset_driver)
    virtual reset_if intf_if;

    function new(string name = "reset_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual reset_if)::get(
            this,
            "",
            "VIRTUAL_R_INTERFACE",
            intf_if) == 0) begin
            `uvm_fatal("INTERFACE_R_CONNECT",
                      "Could not get from the database the virtual interface (Reset) for the TB")
        end else begin
            `uvm_info("R_DRV", $sformatf("Interface obtained"), UVM_LOW)
        end
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
          //  @ (posedge intf_if.clk)
          //  if (1)begin
          //      `uvm_info("R_DRV", $sformatf("Reset run_phase"), UVM_LOW)
                reset_item  r_item;
                seq_item_port.get_next_item(r_item);
                apply_reset(r_item);
                `uvm_info("R_DRV", $sformatf("Reset applied"), UVM_LOW)
                seq_item_port.item_done();
          //  end
        end
    endtask: run_phase

    virtual task apply_reset(reset_item r_item);
        `uvm_info("DRV", $sformatf("Sending a reset"), UVM_LOW)
        intf_if.resetn <= 0;
        //FIXME: Remember to reemplace this
        #100
        intf_if.resetn <= 1;
    endtask: apply_reset

endclass: reset_driver
