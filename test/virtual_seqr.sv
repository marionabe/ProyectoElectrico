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
 * PicoRV; It contains the virtual sequencer
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
 */

`include "uvm_macros.svh"

 class virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer)

    mem_sequencer  mem_seqr;
    pcpi_sequencer pcpi_seqr;
    reset_sequencer reset_seqr;

    function new (string name = "virtual_sequencer", uvm_component parent = null);
        super.new (name, parent);
      endfunction

 endclass: virtual_sequencer



