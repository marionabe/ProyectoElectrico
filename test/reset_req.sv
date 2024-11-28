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
 * PicoRV; It contains the reset item used to send a reset to DUT
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 21/9/2024
 */
 `include "uvm_macros.svh"

class reset_req extends uvm_sequence_item;
    bit reset_required;

    `uvm_object_utils_begin(reset_req)
        `uvm_field_int (reset_required, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "reset_item");
        super.new(name);
    endfunction: new
endclass: reset_req



