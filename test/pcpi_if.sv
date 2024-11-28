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

interface pcpi_if();
    logic        clk;
    logic        pcpi_valid;
    logic [31:0] pcpi_insn;
    logic [31:0] pcpi_rs1;
    logic [31:0] pcpi_rs2;
    logic        pcpi_wr;
    logic [31:0] pcpi_rd;
    logic        pcpi_wait;
    logic        pcpi_ready;

endinterface: pcpi_if
