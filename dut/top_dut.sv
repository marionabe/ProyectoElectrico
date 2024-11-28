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
 * PicoRV; top_dut contains the conection between the DUT and the interface.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
*/

`include "picorv32.v"
import uvm_pkg::*;

module top_dut();

    mem_if   intf_mem_if;
    reset_if intf_reset_if;
    pcpi_if  intf_pcpi_if;

    initial begin
        intf_reset_if.clk = 0;
    end
    always #5 begin
        intf_reset_if.clk = ~intf_reset_if.clk;
    end

    picorv32 dut (
        .clk          (intf_reset_if.clk),
        .resetn       (intf_reset_if.resetn),
        .trap         (intf_reset_if.trap),
        .mem_valid    (intf_mem_if.mem_valid),
        .mem_instr    (intf_mem_if.mem_instr),
        .mem_ready    (intf_mem_if.mem_ready),
        .mem_addr     (intf_mem_if.mem_addr),
        .mem_wdata    (intf_mem_if.mem_wdata),
        .mem_wstrb    (intf_mem_if.mem_wsrtb),
        .mem_rdata    (intf_mem_if.mem_rdata),
        .mem_la_read  (intf_mem_if.mem_la_read),
        .mem_la_write (intf_mem_if.mem_la_write),
        .mem_la_addr  (intf_mem_if.mem_la_addr),
        .mem_la_wdata (intf_mem_if.mem_la_wdata),
        .mem_la_wstrb (intf_mem_if.mem_la_wstrb),
        .pcpi_valid   (intf_pcpi_if.pcpi_valid),
        .pcpi_insn    (intf_pcpi_if.pcpi_insn),
        .pcpi_rs1     (intf_pcpi_if.pcpi_rs1),
        .pcpi_rs2     (intf_pcpi_if.pcpi_rs2),
        .pcpi_wr      (intf_pcpi_if.pcpi_wr),
        .pcpi_rd      (intf_pcpi_if.pcpi_rd),
        .pcpi_wait    (intf_pcpi_if.pcpi_wait),
        .pcpi_ready   (intf_pcpi_if.pcpi_ready),
        .irq          (intf_mem_if.irq),
        .eoi          (intf_mem_if.eoi),
        .dbg_reg_x0   (intf_mem_if.dbg_reg_x0),
        .dbg_reg_x1   (intf_mem_if.dbg_reg_x1),
        .dbg_reg_x2   (intf_mem_if.dbg_reg_x2),
        .dbg_reg_x3   (intf_mem_if.dbg_reg_x3),
        .dbg_reg_x4   (intf_mem_if.dbg_reg_x4),
        .dbg_reg_x5   (intf_mem_if.dbg_reg_x5),
        .dbg_reg_x6   (intf_mem_if.dbg_reg_x6),
        .dbg_reg_x7   (intf_mem_if.dbg_reg_x7),
        .dbg_reg_x8   (intf_mem_if.dbg_reg_x8),
        .dbg_reg_x9   (intf_mem_if.dbg_reg_x9),
        .dbg_reg_x10  (intf_mem_if.dbg_reg_x10),
        .dbg_reg_x11  (intf_mem_if.dbg_reg_x11),
        .dbg_reg_x12  (intf_mem_if.dbg_reg_x12),
        .dbg_reg_x13  (intf_mem_if.dbg_reg_x13),
        .dbg_reg_x14  (intf_mem_if.dbg_reg_x14),
        .dbg_reg_x15  (intf_mem_if.dbg_reg_x15),
        .dbg_reg_x16  (intf_mem_if.dbg_reg_x16),
        .dbg_reg_x17  (intf_mem_if.dbg_reg_x17),
        .dbg_reg_x18  (intf_mem_if.dbg_reg_x18),
        .dbg_reg_x19  (intf_mem_if.dbg_reg_x19),
        .dbg_reg_x20  (intf_mem_if.dbg_reg_x20),
        .dbg_reg_x21  (intf_mem_if.dbg_reg_x21),
        .dbg_reg_x22  (intf_mem_if.dbg_reg_x22),
        .dbg_reg_x23  (intf_mem_if.dbg_reg_x23),
        .dbg_reg_x24  (intf_mem_if.dbg_reg_x24),
        .dbg_reg_x25  (intf_mem_if.dbg_reg_x25),
        .dbg_reg_x26  (intf_mem_if.dbg_reg_x26),
        .dbg_reg_x27  (intf_mem_if.dbg_reg_x27),
        .dbg_reg_x28  (intf_mem_if.dbg_reg_x28),
        .dbg_reg_x29  (intf_mem_if.dbg_reg_x29),
        .dbg_reg_x30  (intf_mem_if.dbg_reg_x30),
        .dbg_reg_x31  (intf_mem_if.dbg_reg_x31)
    );
    initial begin
      // uvm_config_db #(virtual interface_if)::set (null, "*","VIRTUAL_INTERFACE", intf_mem_if);
    end
endmodule: top_dut
