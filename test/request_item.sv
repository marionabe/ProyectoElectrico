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
 * PicoRV; It contains the request item used to send information from the monitor
 * to sequence
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 21/9/2024
 */
 `include "uvm_macros.svh"

class request_item extends uvm_sequence_item;
    bit instr_fetch;
    bit mem_write;
    bit mem_read;
    bit [31:0] rdata;
    `uvm_object_utils_begin(request_item)
        `uvm_field_int (instr_fetch, UVM_DEFAULT)
        `uvm_field_int (mem_write, UVM_DEFAULT)
        `uvm_field_int (mem_read, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "request_item");
        super.new(name);
    endfunction: new
endclass: request_item



