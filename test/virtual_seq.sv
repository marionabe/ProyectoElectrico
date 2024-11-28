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
 * PicoRV; It contains the virtual sequence
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
 */
 `include "uvm_macros.svh"

 class virtual_sequence extends uvm_sequence;
    `uvm_object_utils(virtual_sequence)
    `uvm_declare_p_sequencer(virtual_sequencer)

    function new(string name="virtual_sequence");
        super.new(name);
    endfunction

    reset_sequencer reset_seqr;
    mem_sequencer   mem_seqr;
    pcpi_sequencer  pcpi_seqr;

    reset_item_seq  reset_seq;
    pcpi_item_seq   pcpi_seq;
    instr_item_seq  instr_seq;

    virtual task body();
        reset_seq = reset_item_seq::type_id::create("reset_seq");
        reset_seq.randomize();

        instr_seq = instr_item_seq::type_id::create("instr_seq");
        instr_seq.randomize();

        pcpi_seq = pcpi_item_seq::type_id::create("pcpi_seq");
        pcpi_seq.randomize();

        `uvm_info("V_SEQ", $sformatf("Starting the fork...join_any"), UVM_LOW)
        fork
            reset_seq.start(p_sequencer.reset_seqr);
            pcpi_seq.start(p_sequencer.pcpi_seqr);
            instr_seq.start(p_sequencer.mem_seqr);
        join_any
      endtask: body

endclass: virtual_sequence
