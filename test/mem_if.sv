/*
 * Copyright (c) 2024 Mario Navarro
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/*
 * Universidad de Costa Rica.
 * Escuela de Ingeniería Eléctrica: IE0499-Proyecto Eléctrico.
 *
 * Description: This document is part of the project: Functional verification of
 * PicoRV. The interface is used to connect with the DUT: PicoRV32-IMC.
 * It also contains some signals used to collect fuctional coverage.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
*/
`include "uvm_macros.svh"
interface mem_if();
    logic        clk;
    logic        mem_valid;
    logic        mem_instr;
    logic        mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [ 3:0] mem_wstrb;
    logic [31:0] mem_rdata;
// Look-Ahead Interface
    logic        mem_la_read;
    logic        mem_la_write;
    logic [31:0] mem_la_addr;
    logic [31:0] mem_la_wdata;
    logic [ 3:0] mem_la_wstrb;

// IRQ Interface
    logic [31:0] irq;
    logic [31:0] eoi;
// Registers
    logic [31:0] dbg_reg_x0;
    logic [31:0] dbg_reg_x1;
    logic [31:0] dbg_reg_x2;
    logic [31:0] dbg_reg_x3;
    logic [31:0] dbg_reg_x4;
    logic [31:0] dbg_reg_x5;
    logic [31:0] dbg_reg_x6;
    logic [31:0] dbg_reg_x7;
    logic [31:0] dbg_reg_x8;
    logic [31:0] dbg_reg_x9;
    logic [31:0] dbg_reg_x10;
    logic [31:0] dbg_reg_x11;
    logic [31:0] dbg_reg_x12;
    logic [31:0] dbg_reg_x13;
    logic [31:0] dbg_reg_x14;
    logic [31:0] dbg_reg_x15;
    logic [31:0] dbg_reg_x16;
    logic [31:0] dbg_reg_x17;
    logic [31:0] dbg_reg_x18;
    logic [31:0] dbg_reg_x19;
    logic [31:0] dbg_reg_x20;
    logic [31:0] dbg_reg_x21;
    logic [31:0] dbg_reg_x22;
    logic [31:0] dbg_reg_x23;
    logic [31:0] dbg_reg_x24;
    logic [31:0] dbg_reg_x25;
    logic [31:0] dbg_reg_x26;
    logic [31:0] dbg_reg_x27;
    logic [31:0] dbg_reg_x28;
    logic [31:0] dbg_reg_x29;
    logic [31:0] dbg_reg_x30;
    logic [31:0] dbg_reg_x31;
    // To indicate from monitor when to finish simulation
    bit end_of_simulation = 0;


endinterface: mem_if
