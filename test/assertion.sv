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
 * It contains assertions for the dut.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 13/11/2024
 */

`include "uvm_macros.svh"
import uvm_pkg::*;

module assertion(
    input        clk,
    input        resetn,
    input        trap,
    input        mem_valid,
    input        mem_instr,
    input        mem_ready,
    input [31:0] mem_addr,
    input [31:0] mem_wdata,
    input [ 3:0] mem_wstrb,
    input [31:0] mem_rdata,
    input        mem_la_read,
    input        mem_la_write,
    input [31:0] mem_la_addr,
    input [31:0] mem_la_wdata,
    input [ 3:0] mem_la_wstrb,
    input        pcpi_valid,
    input [31:0] pcpi_insn,
    input [31:0] pcpi_rs1,
    input [31:0] pcpi_rs2,
    input        pcpi_wr,
    input [31:0] pcpi_rd,
    input        pcpi_wait,
    input        pcpi_ready
);


    // This block of assertion checks that the output signals, remain stable while mem_valid==1
    property mem_instr_stable;
        @(negedge clk)
        disable iff (!resetn || $isunknown(mem_instr) || !mem_valid)
        mem_valid |-> ##1 (mem_instr  == $past(mem_instr));
    endproperty

    property mem_addr_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_addr) || !mem_valid)
        mem_valid |-> ##1 (mem_addr   == $past(mem_addr)  );
    endproperty

    property mem_wdata_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_wdata) || !mem_valid)
        mem_valid |-> ##1 (mem_wdata  == $past(mem_wdata) );
    endproperty

    property mem_wstrb_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_wstrb) || !mem_valid)
        mem_valid |-> ##1 (mem_wstrb  == $past(mem_wstrb) );
    endproperty

    property pcpi_valid_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(pcpi_valid) || !mem_valid)
        mem_valid |-> ##1 (pcpi_valid == $past(pcpi_valid));
    endproperty

    property pcpi_insn_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(pcpi_insn) || !mem_valid)
         mem_valid |-> ##1 (pcpi_insn  == $past(pcpi_insn) );
    endproperty

    property pcpi_rs1_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(pcpi_rs1) || !mem_valid)
        mem_valid |=> (pcpi_rs1   == $past(pcpi_rs1));
    endproperty

    property pcpi_rs2_stable;
        @(posedge clk)
        disable iff (!resetn || $isunknown(pcpi_rs2) || !mem_valid)
        mem_valid |-> ##1 (pcpi_rs2   == $past(pcpi_rs2)  );
    endproperty

    asrt_mem_instr_stable:  assert property (mem_instr_stable);
    asrt_mem_addr_stable:   assert property (mem_addr_stable);
    asrt_mem_wdata_stable:  assert property (mem_wdata_stable);
    asrt_mem_wstrb_stable:  assert property (mem_wstrb_stable);
    //asrt_pcpi_valid_stable: assert property (pcpi_valid_stable);
    asrt_pcpi_insn_stable:  assert property (pcpi_insn_stable);
    //asrt_pcpi_rs1_stable:   assert property (pcpi_rs1_stable);
    asrt_pcpi_rs2_stable:   assert property (pcpi_rs2_stable);

    // This block checks the correct use of mem_valid. While mem_valid==1, the mem_instr==1 or
    // mem_wstrb should be different than x but should be one of the allowed values
    property mem_valid_use;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_wstrb) || !mem_valid)
        mem_valid |=> (mem_instr ||
                       mem_wstrb==4'b0000 ||
                       mem_wstrb==4'b1111 ||
                       mem_wstrb==4'b1100 ||
                       mem_wstrb==4'b0011 ||
                       mem_wstrb==4'b1000 ||
                       mem_wstrb==4'b0100 ||
                       mem_wstrb==4'b0010 ||
                       mem_wstrb==4'b0001);
    endproperty

    asrt_mem_valid_use:   assert property (mem_valid_use);

    // This block check the proper function of the look-ahead interface
    property mem_la_addr_use;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_addr))
        !$stable(mem_addr) |->  mem_addr == $past(mem_la_addr);
    endproperty

    property mem_la_wdata_use;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_wdata))
        !$stable(mem_wdata) |->  mem_wdata == $past(mem_la_wdata);
    endproperty

    // This specific property also checks mem_la_write
    property mem_la_wstrb_use;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_wstrb))
        mem_la_write |=>  mem_wstrb == $past(mem_la_wstrb);
    endproperty

    property mem_la_read_use;
        @(posedge clk)
        disable iff (!resetn || $isunknown(mem_la_read))
        mem_la_read |=> mem_instr || (mem_wstrb==0);
    endproperty

    asrt_mem_la_addr_use:  assert property (mem_la_addr_use);
    asrt_mem_la_wdata_use: assert property (mem_la_wdata_use);
    asrt_mem_la_wstrb_use: assert property (mem_la_wstrb_use);
    asrt_mem_la_read_use: assert property (mem_la_read_use);

    // This block check that mem_la_write and mem_la_read activate 1 cycle before mem_valid
    property mem_la_write_active;
        @(posedge clk)
        disable iff (!resetn)
        $rose(mem_la_write) |=> $rose (mem_valid);
    endproperty

    property mem_la_read_active;
        @(posedge clk)
        disable iff (!resetn)
        $rose(mem_la_read) |=> $rose (mem_valid);
    endproperty

    asrt_mem_la_write_active: assert property (mem_la_read_active);
    asrt_mem_la_read_active: assert property (mem_la_read_active);


endmodule: assertion
