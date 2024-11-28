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
 * PicoRV; It contains the register state, to send it to the scoreboard
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 21/9/2024
 */
 `include "uvm_macros.svh"

class reg_state extends uvm_sequence_item;
    bit [31:0] reg_state_x1;
    bit [31:0] reg_state_x2;
    bit [31:0] reg_state_x3;
    bit [31:0] reg_state_x4;
    bit [31:0] reg_state_x5;
    bit [31:0] reg_state_x6;
    bit [31:0] reg_state_x7;
    bit [31:0] reg_state_x8;
    bit [31:0] reg_state_x9;
    bit [31:0] reg_state_x10;
    bit [31:0] reg_state_x11;
    bit [31:0] reg_state_x12;
    bit [31:0] reg_state_x13;
    bit [31:0] reg_state_x14;
    bit [31:0] reg_state_x15;
    bit [31:0] reg_state_x16;
    bit [31:0] reg_state_x17;
    bit [31:0] reg_state_x18;
    bit [31:0] reg_state_x19;
    bit [31:0] reg_state_x20;
    bit [31:0] reg_state_x21;
    bit [31:0] reg_state_x22;
    bit [31:0] reg_state_x23;
    bit [31:0] reg_state_x24;
    bit [31:0] reg_state_x25;
    bit [31:0] reg_state_x26;
    bit [31:0] reg_state_x27;
    bit [31:0] reg_state_x28;
    bit [31:0] reg_state_x29;
    bit [31:0] reg_state_x30;
    bit [31:0] reg_state_x31;

    `uvm_object_utils_begin(reg_state)
        `uvm_field_int (reg_state_x1, UVM_DEFAULT)
        `uvm_field_int (reg_state_x2, UVM_DEFAULT)
        `uvm_field_int (reg_state_x3, UVM_DEFAULT)
        `uvm_field_int (reg_state_x4, UVM_DEFAULT)
        `uvm_field_int (reg_state_x5, UVM_DEFAULT)
        `uvm_field_int (reg_state_x6, UVM_DEFAULT)
        `uvm_field_int (reg_state_x7, UVM_DEFAULT)
        `uvm_field_int (reg_state_x8, UVM_DEFAULT)
        `uvm_field_int (reg_state_x9, UVM_DEFAULT)
        `uvm_field_int (reg_state_x10, UVM_DEFAULT)
        `uvm_field_int (reg_state_x11, UVM_DEFAULT)
        `uvm_field_int (reg_state_x12, UVM_DEFAULT)
        `uvm_field_int (reg_state_x13, UVM_DEFAULT)
        `uvm_field_int (reg_state_x14, UVM_DEFAULT)
        `uvm_field_int (reg_state_x15, UVM_DEFAULT)
        `uvm_field_int (reg_state_x16, UVM_DEFAULT)
        `uvm_field_int (reg_state_x17, UVM_DEFAULT)
        `uvm_field_int (reg_state_x18, UVM_DEFAULT)
        `uvm_field_int (reg_state_x19, UVM_DEFAULT)
        `uvm_field_int (reg_state_x20, UVM_DEFAULT)
        `uvm_field_int (reg_state_x21, UVM_DEFAULT)
        `uvm_field_int (reg_state_x22, UVM_DEFAULT)
        `uvm_field_int (reg_state_x23, UVM_DEFAULT)
        `uvm_field_int (reg_state_x24, UVM_DEFAULT)
        `uvm_field_int (reg_state_x25, UVM_DEFAULT)
        `uvm_field_int (reg_state_x26, UVM_DEFAULT)
        `uvm_field_int (reg_state_x27, UVM_DEFAULT)
        `uvm_field_int (reg_state_x28, UVM_DEFAULT)
        `uvm_field_int (reg_state_x29, UVM_DEFAULT)
        `uvm_field_int (reg_state_x30, UVM_DEFAULT)
        `uvm_field_int (reg_state_x31, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "reg_state");
        super.new(name);
    endfunction: new
endclass: reg_state



