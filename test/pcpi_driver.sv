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

class pcpi_item extends uvm_sequence_item;
    // Fake instr always return 0xFFFFFFFF to rd
    int return_value = 32'hFFFFFFFF;
    // If the instr returns a value, is decided by bit 21 of the instr
    // bit21==1 => return a value
    // bit21==0 => don't return a value
    int is_write;
    rand int wait_time;

    // Wait time in clock cycles
    constraint constr_wait_time_c{
        wait_time inside {[7:30]};
    }



    `uvm_object_utils_begin(pcpi_item)
        `uvm_field_int (return_value, UVM_DEFAULT)
        `uvm_field_int (is_write, UVM_DEFAULT)
        `uvm_field_int (wait_time, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "pcpi_item");
        super.new(name);
    endfunction: new
endclass: pcpi_item


class pcpi_sequencer extends uvm_sequencer #(pcpi_item);
    `uvm_component_utils(pcpi_sequencer)

    uvm_analysis_port #(pcpi_req) pcpi_export;
    uvm_tlm_analysis_fifo #(pcpi_req) pcpi_fifo;

    function new (string name = "pcpi_sequencer", uvm_component parent = null);
      super.new (name, parent);
      pcpi_export = new ("pcpi_export", this);
      pcpi_fifo = new ("pcpi_fifo", this);
    endfunction: new

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        pcpi_export.connect(pcpi_fifo.analysis_export);
    endfunction: connect_phase
endclass: pcpi_sequencer


class pcpi_item_seq extends uvm_sequence;
    `uvm_object_utils(pcpi_item_seq)
    `uvm_declare_p_sequencer (pcpi_sequencer)
    pcpi_req pcpi_req_item;

    function new(string name="pcpi_item_seq");
        super.new(name);
    endfunction: new

    virtual task body();
        while (1) begin
            pcpi_item pcp_itm = pcpi_item::type_id::create("pcpi_item");
            p_sequencer.pcpi_fifo.get(pcpi_req_item);

            //FIXME:Add some logic to respond to pcpi req
            if (pcpi_req_item.pcpi_valid)begin
                start_item(pcp_itm);
                pcp_itm.is_write = pcpi_req_item.pcpi_insn[21];
                pcp_itm.randomize();
                `uvm_info("P_SEQ", $sformatf("Generate new pcpi response: "), UVM_LOW)
                pcp_itm.print();
                finish_item(pcp_itm);
                `uvm_info("P_SEQ", $sformatf("Done generation of pcpi response"), UVM_LOW)
            end
        end
    endtask: body
endclass: pcpi_item_seq

class pcpi_driver extends uvm_driver #(pcpi_item);
    `uvm_component_utils (pcpi_driver)
    virtual pcpi_if intf_if;

    function new(string name = "pcpi_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual pcpi_if)::get(
            this,
            "",
            "VIRTUAL_P_INTERFACE",
            intf_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                      "Could not get from the database the virtual interface (PCPI) for the TB")
        end else begin
            `uvm_info("P_DRV", $sformatf("Interface obtained"), UVM_LOW)
        end
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            pcpi_item  pcp_itm;
            seq_item_port.get_next_item(pcp_itm);
            `uvm_info("test", $sformatf("sending pcpi answ"), UVM_LOW)
            send_response(pcp_itm);
            `uvm_info("P_DRV", $sformatf("Response has been sent to the DUT"), UVM_LOW)
            seq_item_port.item_done();
        end
    endtask: run_phase

    virtual task send_response(pcpi_item pcp_itm);
        @(posedge intf_if.clk);
        intf_if.pcpi_wait <=  (pcp_itm.wait_time>15) ? 1'b1 : 1'b0;
        for(int i=0; i<=(pcp_itm.wait_time-5); i++) begin
            @(posedge intf_if.clk);
        end
            intf_if.pcpi_wr <= pcp_itm.is_write;
            intf_if.pcpi_rd <= pcp_itm.return_value;
            intf_if.pcpi_ready <= 1;

        @ (negedge intf_if.clk);
        @ (posedge intf_if.clk);
        intf_if.pcpi_ready <= 0;
    endtask: send_response

endclass: pcpi_driver
