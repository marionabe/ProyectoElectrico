`include "uvm_macros.svh"
import uvm_pkg::*;



`include "..\test\mem_if.sv"
`include "..\test\reset_if.sv"
`include "..\test\pcpi_if.sv"
`include "..\test\request_item.sv"
`include "..\test\reset_req.sv"
`include "..\test\pcpi_req.sv"
`include "..\test\storage.sv"
`include "..\test\picorv_driver.sv"
`include "..\test\reg_state.sv"
`include "..\test\monitor_mem.sv"
`include "..\test\reset_driver.sv"
`include "..\test\monitor_reset.sv"
`include "..\test\pcpi_driver.sv"
`include "..\test\monitor_pcpi.sv"
`include "..\test\scoreboard.sv"
`include "..\test\agent_mem.sv"
`include "..\test\agent_pcpi.sv"
`include "..\test\agent_reset.sv"
`include "..\test\virtual_seqr.sv"
`include "..\test\virtual_seq.sv"
`include "..\test\coverage.sv"
`include "..\test\environment.sv"
`include "..\test\test_basic.sv"
`include "..\test\test_from_document.sv"
`include "..\test\assertion.sv"




module top_test();
  mem_if intf_mem_if();
  reset_if intf_reset_if();
  pcpi_if  intf_pcpi_if();
  int cyc_count;
  logic clk;

  initial begin
    uvm_config_db #(virtual mem_if)::set (null, "*","VIRTUAL_M_INTERFACE", intf_mem_if);
    uvm_config_db #(virtual reset_if)::set (null, "*","VIRTUAL_R_INTERFACE", intf_reset_if);
    uvm_config_db #(virtual pcpi_if)::set (null, "*","VIRTUAL_P_INTERFACE", intf_pcpi_if);
      clk = 0;
      cyc_count=0;
  end

  always #5 begin
      clk = ~clk;
      cyc_count++;
      if (cyc_count==1000)begin
          intf_reset_if.stop_sim=1;
      end
  end


  assign intf_mem_if.clk = clk;
  assign intf_pcpi_if.clk = clk;
  assign intf_reset_if.clk = clk;


  picorv32 dut (
      .clk          (clk),
      .resetn       (intf_reset_if.resetn),
      .trap         (intf_reset_if.trap),
      .mem_valid    (intf_mem_if.mem_valid),
      .mem_instr    (intf_mem_if.mem_instr),
      .mem_ready    (intf_mem_if.mem_ready),
      .mem_addr     (intf_mem_if.mem_addr),
      .mem_wdata    (intf_mem_if.mem_wdata),
      .mem_wstrb    (intf_mem_if.mem_wstrb),
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

  assertion assrt(
    .clk          (clk),
    .resetn       (intf_reset_if.resetn),
    .trap         (intf_reset_if.trap),
    .mem_valid    (intf_mem_if.mem_valid),
    .mem_instr    (intf_mem_if.mem_instr),
    .mem_ready    (intf_mem_if.mem_ready),
    .mem_addr     (intf_mem_if.mem_addr),
    .mem_wdata    (intf_mem_if.mem_wdata),
    .mem_wstrb    (intf_mem_if.mem_wstrb),
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
    .pcpi_ready   (intf_pcpi_if.pcpi_ready)
  );

  initial begin
    run_test();
  end

  endmodule: top_test
