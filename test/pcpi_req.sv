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
 * PicoRV; It contains the pcpi item used to send a response to pcpi_valid
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 22/9/2024
 */
 `include "uvm_macros.svh"

class pcpi_req extends uvm_sequence_item;
    bit [31:0] pcpi_valid;
    bit [31:0] pcpi_insn;
    bit [31:0] pcpi_rs2;
    bit [31:0] pcpi_rs1;

    `uvm_object_utils_begin(pcpi_req)
        `uvm_field_int (pcpi_valid, UVM_DEFAULT)
        `uvm_field_int (pcpi_insn, UVM_DEFAULT)
        `uvm_field_int (pcpi_rs2, UVM_DEFAULT)
        `uvm_field_int (pcpi_rs1, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "pcpi_req");
        super.new(name);
    endfunction: new
endclass: pcpi_req



