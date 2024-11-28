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
 * It contains the scoreboard for the picoRV
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 22/9/2024
 */
`include "uvm_macros.svh"
import uvm_pkg::*;

typedef struct{
    bit signed [31:0] regs [32];
} regs_t;

`uvm_analysis_imp_decl( _mem )
`uvm_analysis_imp_decl( _rset )
`uvm_analysis_imp_decl( _pcpi )
`uvm_analysis_imp_decl( _reg )

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils (scoreboard)

    bit unsigned [31:0] op_uns_1;
    bit unsigned [31:0] op_uns_2;
    bit signed [31:0] op_sgn_1;
    bit signed [31:0] op_sgn_2;
    bit        [63:0] op_1_64b;
    bit        [63:0] op_2_64b;
    bit signed   [63:0] temp_res_u;
    bit signed   [63:0] temp_res;
    bit          [31:0] exp_addr;
    bit          [31:0] last_addr;
    regs_t regs_queue [$];
    regs_t temp_ref_regs;
    regs_t ref_regs;
    regs_t t2_ref_regs;
    bit branch_pend;
    int key;

    int temp_res_int;
    int op_1;
    int op_2;

    int history_file;



    function new (string name, uvm_component parent=null);
         super.new (name, parent);
         exp_addr=0;
         branch_pend=0;
    endfunction: new

    uvm_analysis_imp_mem #(instr_item, scoreboard) mc_mem;
    uvm_analysis_imp_rset #(reset_item, scoreboard) mc_rset;
    uvm_analysis_imp_pcpi #(pcpi_item, scoreboard) mc_pcpi;
    uvm_analysis_imp_reg #(reg_state, scoreboard) mc_reg;


    function void build_phase (uvm_phase phase);
        mc_mem = new ("mc_mem", this);
        mc_rset = new ("mc_rset", this);
        mc_pcpi = new ("mc_pcpi", this);
        mc_reg = new ("mc_reg", this);
        // Open file to store the instructions
        history_file = $fopen("../test/instruction_history.txt", "w");
    endfunction: build_phase



    virtual function void write_mem (instr_item instr);

        // Check if DUT re-fetch the instruction from the same addr
        if (instr.mem_addr == last_addr && last_addr != 0) begin
        branch_pend = 0;
        exp_addr=instr.mem_addr;
        // Undo changes to regs
        if (regs_queue.size()==1)begin
            regs_queue.pop_back();
            temp_ref_regs=ref_regs;
        end else if (regs_queue.size()>=2)begin
            regs_queue.pop_back();
            temp_ref_regs=regs_queue.pop_back();
            regs_queue.push_back(temp_ref_regs);
        end
        end

        // Check if a branch is pending, in that case ignore the instr
        `uvm_info("SCB", $sformatf(
            "Instruction received R_addr= %h, Exp_addr= %h", instr.mem_addr, exp_addr), UVM_LOW);
        if ((instr.mem_addr == exp_addr) && branch_pend)begin
            branch_pend=0;
        end else if ((instr.mem_addr != exp_addr) && branch_pend)begin
            return;
        end
        if ((instr.mem_addr != exp_addr) && !branch_pend)begin
            `uvm_error("SCB", $sformatf(
                "Received address does not match: R= %h, Exp= %h", instr.mem_addr, exp_addr));
        end

        //Change the reg0 to 0
        temp_ref_regs.regs[0]=32'b0;



        // Proccess the instructions based on opcode
        `uvm_info("SCB", $sformatf("Instruction received %h", instr.rdata), UVM_LOW)
        case (instr.rdata[6:0])
           // LUI instr
            7'b0110111: begin
               temp_ref_regs.regs[instr.rdata[11:7]] = {instr.rdata[31:12], 12'b0};
               regs_queue.push_back(temp_ref_regs);
               `uvm_info("SCB", "Queue write", UVM_LOW)
               exp_addr += 4;
               $fdisplay(history_file, "%h : lui x%d, 0x%h",
                         instr.rdata,
                         $unsigned(instr.rdata[11:7]),
                         $signed(instr.rdata[31:12]));
               end
            7'b0010011:begin
               // Select the instr based on funct3
               case(instr.rdata[14:12])
                    //ADDI
                    3'b000: begin
                        temp_ref_regs.regs[instr.rdata[11:7]] =
                            {{20{instr.rdata[31]}}, instr.rdata[31:20]} +
                             temp_ref_regs.regs[instr.rdata[19:15]];
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : addi x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $unsigned(instr.rdata[19:15]),
                                  $signed(instr.rdata[31:20]));
                        end
                    // SLTI
                    3'b010: begin
                        if (temp_ref_regs.regs[instr.rdata[19:15]] <
                            $signed({{20{instr.rdata[31]}}, instr.rdata[31:20]}) ) begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=1;
                            end else begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=0;
                            end
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : slti x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $unsigned(instr.rdata[19:15]),
                                  $signed(instr.rdata[31:20]));
                        end
                    // SLTIU
                    3'b011: begin
                        if ($unsigned(temp_ref_regs.regs[instr.rdata[19:15]]) <
                            $unsigned({{20{instr.rdata[31]}}, instr.rdata[31:20]}) ) begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=1;
                            end else begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=0;
                            end
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : sltiu x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[31:20]));
                        end
                    //XORI
                    3'b100: begin
                        temp_ref_regs.regs[instr.rdata[11:7]] =
                            {{20{instr.rdata[31]}}, instr.rdata[31:20]} ^
                            temp_ref_regs.regs[instr.rdata[19:15]];
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : xori x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $unsigned(instr.rdata[19:15]),
                                  $signed(instr.rdata[31:20]));
                        end
                    //ORI
                    3'b110: begin
                        temp_ref_regs.regs[instr.rdata[11:7]] =
                        {{20{instr.rdata[31]}}, instr.rdata[31:20]} |
                        temp_ref_regs.regs[instr.rdata[19:15]];
                                                regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : ori x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $unsigned(instr.rdata[19:15]),
                                  $signed(instr.rdata[31:20]));
                        end
                    //ANDI
                    3'b111: begin
                        temp_ref_regs.regs[instr.rdata[11:7]] =
                            {{20{instr.rdata[31]}}, instr.rdata[31:20]} &
                            temp_ref_regs.regs[instr.rdata[19:15]];
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : andi x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $unsigned(instr.rdata[19:15]),
                                  $signed(instr.rdata[31:20]));
                        end
                    //SLLI
                    3'b001: begin
                        temp_ref_regs.regs[instr.rdata[11:7]]=
                            temp_ref_regs.regs[instr.rdata[19:15]]<<
                            instr.rdata[24:20];
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr += 4;
                        $fdisplay(history_file, "%h : slli x%d, x%d, 0x%h",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7 ]),
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]));
                        end
                    3'b101: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            //SRLI
                            7'b0000000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]>>
                                    instr.rdata[24:20];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : srli x%d, x%d, 0x%h",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            //SRAI
                            7'b0100000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]>>>
                                    instr.rdata[24:20];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SRAI", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : srai x%d, x%d, 0x%h",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase
                        end
                    default:;
               endcase
               end
            7'b0110011: begin
                // Select the instr based on funct3
                case(instr.rdata[14:12])
                    3'b000: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            //ADD
                            7'b0000000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    $signed(temp_ref_regs.regs[instr.rdata[19:15]]) +
                                    $signed(temp_ref_regs.regs[instr.rdata[24:20]]);
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : add x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            //SUB
                            7'b0100000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    $signed(temp_ref_regs.regs[instr.rdata[19:15]]) -
                                    $signed(temp_ref_regs.regs[instr.rdata[24:20]]);
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : sub x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            // MUL
                            7'b0000001: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]*
                                    temp_ref_regs.regs[instr.rdata[24:20]];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : mul x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase
                        end
                    3'b001:begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            // SLL
                            7'b0000000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]<<
                                    temp_ref_regs.regs[instr.rdata[24:20]][4:0];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : sll x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            // MULH
                            7'b0000001: begin
                                temp_res =0;
                                temp_res = temp_ref_regs.regs[instr.rdata[24:20]] *
                                          temp_ref_regs.regs[instr.rdata[19:15]];
                                temp_ref_regs.regs[instr.rdata[11:7]] = temp_res[63:32];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : mulh x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase
                        end
                    3'b011: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            //SLTU
                            7'b0000000:begin
                                if ($unsigned(temp_ref_regs.regs[instr.rdata[19:15]]) <
                                    $unsigned(temp_ref_regs.regs[instr.rdata[24:20]])) begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=1;
                                end else begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=0;
                                end
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : sltu x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            //MULHU
                            7'b0000001: begin
                                temp_res_u = 0;
                                op_uns_1 = temp_ref_regs.regs[instr.rdata[24:20]];
                                op_uns_2 = temp_ref_regs.regs[instr.rdata[19:15]];
                                temp_res_u = $unsigned(op_uns_1) * $unsigned(op_uns_2);
                                temp_ref_regs.regs[instr.rdata[11:7]] = temp_res_u[63:32];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : mulhu x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase
                        end
                    3'b010: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            //SLT
                            7'b0000000:begin
                                if (temp_ref_regs.regs[instr.rdata[19:15]] <
                                    temp_ref_regs.regs[instr.rdata[24:20]]) begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=1;
                                end else begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=0;
                                end
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : slt x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            // MULHSU
                            7'b0000001:begin
                                temp_res =0;
                                // Sign-Extend op1, to 64b;
                                op_1_64b[31:0] = {temp_ref_regs.regs[instr.rdata[19:15]]};
                                op_1_64b[63:32] = {32{op_1_64b[31]}};
                                // Zero-Extend op2, to 64b;
                                op_2_64b = {32'b0, temp_ref_regs.regs[instr.rdata[24:20]]};
                                temp_res = $signed(op_1_64b) * $unsigned(op_2_64b);

                                temp_ref_regs.regs[instr.rdata[11:7]] = temp_res[63:32];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : mulhsu x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase
                        end
                    3'b100:begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            //XOR
                            7'b0000000:begin
                                temp_ref_regs.regs[instr.rdata[11:7]] =
                                    temp_ref_regs.regs[instr.rdata[24:20]] ^
                                    temp_ref_regs.regs[instr.rdata[19:15]];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : xori x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            //DIV
                            7'b0000001:begin
                                //if rs2=0 => rd=32'h1
                                if (temp_ref_regs.regs[instr.rdata[24:20]]==0)begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=32'hFFFFFFFF;
                                end else if(
                                    // Overflow condition: rd=rs1;
                                        temp_ref_regs.regs[instr.rdata[19:15]]==32'h80000000 &&
                                        temp_ref_regs.regs[instr.rdata[24:20]]==32'hFFFFFFFF)begin
                                            temp_ref_regs.regs[instr.rdata[11:7]]=
                                            temp_ref_regs.regs[instr.rdata[19:15]];
                                end else begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]/
                                    temp_ref_regs.regs[instr.rdata[24:20]];
                                end
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : div x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase;
                        end
                    3'b101: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            //SRL
                            7'b0000000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]>>
                                    temp_ref_regs.regs[instr.rdata[24:20]][4:0];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : srl x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            //SRA
                            7'b0100000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]>>>
                                    temp_ref_regs.regs[instr.rdata[24:20]][4:0];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : sra x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            //DIVU
                            7'b0000001:begin
                                //if rs2=0 => rd=32'h1
                                if (temp_ref_regs.regs[instr.rdata[24:20]]==0)begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=32'hFFFFFFFF;
                                end else begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=
                                    $unsigned(temp_ref_regs.regs[instr.rdata[19:15]])/
                                    $unsigned(temp_ref_regs.regs[instr.rdata[24:20]]);
                                end
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : divu x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase;
                        end
                    3'b110: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            // OR
                            7'b0000000: begin
                                temp_ref_regs.regs[instr.rdata[11:7]] =
                                    temp_ref_regs.regs[instr.rdata[24:20]] |
                                    temp_ref_regs.regs[instr.rdata[19:15]];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : sra x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            // REM
                            7'b0000001: begin
                                //if rs2=0 => rd=rs1
                                if (temp_ref_regs.regs[instr.rdata[24:20]]==0)begin
                                    temp_ref_regs.regs[instr.rdata[11:7]] =
                                        temp_ref_regs.regs[instr.rdata[19:15]];
                                end else begin
                                    temp_ref_regs.regs[instr.rdata[11:7]]=
                                    temp_ref_regs.regs[instr.rdata[19:15]]%
                                    temp_ref_regs.regs[instr.rdata[24:20]];
                                end
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : rem x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase;
                        end
                    3'b111: begin
                        // Select the instr based on funct7
                        case (instr.rdata[31:25])
                            // AND
                            7'b0000000:begin
                                temp_ref_regs.regs[instr.rdata[11:7]] =
                                    temp_ref_regs.regs[instr.rdata[24:20]] &
                                    temp_ref_regs.regs[instr.rdata[19:15]];
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : and x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            // REMU
                            7'b0000001: begin
                                //if rs2=0 => rd=rs1
                                if (temp_ref_regs.regs[instr.rdata[24:20]]==0)begin
                                    temp_ref_regs.regs[instr.rdata[11:7]] =
                                        temp_ref_regs.regs[instr.rdata[19:15]];
                                end else begin
                                    temp_ref_regs.regs[instr.rdata[11:7]] =
                                    $unsigned(temp_ref_regs.regs[instr.rdata[19:15]])%
                                    $unsigned(temp_ref_regs.regs[instr.rdata[24:20]]);
                                end;
                                regs_queue.push_back(temp_ref_regs);
                                `uvm_info("SCB", "Queue write", UVM_LOW)
                                exp_addr += 4;
                                $fdisplay(history_file, "%h : remu x%d, x%d, x%d",
                                          instr.rdata,
                                          $unsigned(instr.rdata[11:7 ]),
                                          $unsigned(instr.rdata[19:15]),
                                          $unsigned(instr.rdata[24:20]));
                                end
                            default:;
                        endcase
                        end
                    default:;
                endcase
                end
            // JALR
            7'b1100111: begin
                exp_addr=
                    $signed(temp_ref_regs.regs[instr.rdata[19:15]])+
                    $signed({{21{instr.rdata[31]}}, instr.rdata[31:20]});
                exp_addr[1:0] = 2'b00;
                temp_ref_regs.regs[instr.rdata[11:7]] = instr.mem_addr + 4'b0100;
                regs_queue.push_back(temp_ref_regs);
                `uvm_info("SCB", "Queue write", UVM_LOW)
                $fdisplay(history_file, "%h : jalr x%d, %d(x%d)",
                          instr.rdata,
                          $unsigned(instr.rdata[11:7 ]),
                          $signed(instr.rdata[31:20]),
                          $unsigned(instr.rdata[19:15]));
                end
            // JAL
            7'b1101111: begin
                exp_addr=
                    $unsigned(instr.mem_addr)+
                    $signed({{12{instr.rdata[31]}}, instr.rdata[19:12],
                              instr.rdata[20], instr.rdata[30:21], 1'b0});
                temp_ref_regs.regs[instr.rdata[11:7]] = instr.mem_addr + 4'b0100;
                regs_queue.push_back(temp_ref_regs);
                `uvm_info("SCB", "Queue write", UVM_LOW)
                $fdisplay(history_file, "%h : jal x%d, %d",
                          instr.rdata,
                          $unsigned(instr.rdata[11:7]),
                          $signed({instr.rdata[31], instr.rdata[19:12],
                                  instr.rdata[20], instr.rdata[30:21],1'b0}));
                end
            // AUIPC
            7'b0010111: begin
                temp_res = 63'b0;
                temp_res = {44'b0, instr.rdata[31:12]};
                temp_res = temp_res << 12;
                temp_res = temp_res + instr.mem_addr;
                temp_ref_regs.regs[instr.rdata[11:7]] = temp_res[31:0];
                regs_queue.push_back(temp_ref_regs);
                `uvm_info("SCB", "Queue write", UVM_LOW)
                exp_addr += 4;
                $fdisplay(history_file, "%h : auipc x%d, %d",
                          instr.rdata,
                          $unsigned(instr.rdata[11:7]),
                          $signed(instr.rdata[31:12]));
                end
            7'b1100011: begin
                // Select the instr based on funct3
                case(instr.rdata[14:12])
                    //BEQ
                    3'b000: begin
                        if (temp_ref_regs.regs[instr.rdata[24:20]]==
                            temp_ref_regs.regs[instr.rdata[19:15]])begin
                            exp_addr=
                                {{20{instr.rdata[31]}},instr.rdata[7],
                                    instr.rdata[30:25], instr.rdata[11:8], 1'b0}+
                                    instr.mem_addr;
                            exp_addr[1:0] = 2'b00;
                            branch_pend=1;
                        end else begin
                            exp_addr+=4;
                        end
                        $fdisplay(history_file, "%h : beq x%d, x%d, %d",
                                  instr.rdata,
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31], instr.rdata[7],
                                           instr.rdata[30:25], instr.rdata[11:8], 1'b0}));
                        end
                    //BNE
                    3'b001: begin
                        if (temp_ref_regs.regs[instr.rdata[24:20]]!=
                            temp_ref_regs.regs[instr.rdata[19:15]])begin
                            exp_addr=
                                {{20{instr.rdata[31]}},instr.rdata[7],
                                    instr.rdata[30:25], instr.rdata[11:8], 1'b0}+
                                    instr.mem_addr;
                            exp_addr[1:0] = 2'b00;
                            branch_pend=1;
                        end else begin
                            exp_addr+=4;
                        end
                        $fdisplay(history_file, "%h : bne x%d, x%d, %d",
                                  instr.rdata,
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31], instr.rdata[7],
                                           instr.rdata[30:25], instr.rdata[11:8], 1'b0}));
                        end
                    //BLT
                    3'b100: begin
                        if (temp_ref_regs.regs[instr.rdata[19:15]]<
                            temp_ref_regs.regs[instr.rdata[24:20]])begin
                            exp_addr=
                                {{20{instr.rdata[31]}},instr.rdata[7],
                                    instr.rdata[30:25], instr.rdata[11:8], 1'b0}+
                                    instr.mem_addr;
                            exp_addr[1:0] = 2'b00;
                            branch_pend=1;
                        end else begin
                            exp_addr+=4;
                        end
                        $fdisplay(history_file, "%h : blt x%d, x%d, %d",
                                  instr.rdata,
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31], instr.rdata[7],
                                           instr.rdata[30:25], instr.rdata[11:8], 1'b0}));
                        end
                    //BGE
                    3'b101: begin
                        if (temp_ref_regs.regs[instr.rdata[19:15]]>=
                            temp_ref_regs.regs[instr.rdata[24:20]])begin
                            exp_addr=
                                {{20{instr.rdata[31]}},instr.rdata[7],
                                    instr.rdata[30:25], instr.rdata[11:8], 1'b0}+
                                    instr.mem_addr;
                            exp_addr[1:0] = 2'b00;
                            branch_pend=1;
                        end else begin
                            exp_addr+=4;
                        end
                        $fdisplay(history_file, "%h : bge x%d, x%d, %d",
                                  instr.rdata,
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31], instr.rdata[7],
                                           instr.rdata[30:25], instr.rdata[11:8], 1'b0}));
                    end
                    //BLTU
                    3'b110: begin
                        if ($unsigned(temp_ref_regs.regs[instr.rdata[19:15]])<
                            $unsigned(temp_ref_regs.regs[instr.rdata[24:20]]))begin
                            exp_addr=
                                {{20{instr.rdata[31]}},instr.rdata[7],
                                    instr.rdata[30:25], instr.rdata[11:8], 1'b0}+
                                    instr.mem_addr;
                                exp_addr[1:0] = 2'b00;
                            branch_pend=1;
                        end else begin
                            exp_addr+=4;
                        end
                        $fdisplay(history_file, "%h : bltu x%d, x%d, %d",
                                  instr.rdata,
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31], instr.rdata[7],
                                           instr.rdata[30:25], instr.rdata[11:8], 1'b0}));
                    end
                    //BGEU
                    3'b111: begin
                        if ($unsigned(temp_ref_regs.regs[instr.rdata[19:15]])>=
                            $unsigned(temp_ref_regs.regs[instr.rdata[24:20]]))begin
                            exp_addr=
                                {{20{instr.rdata[31]}},instr.rdata[7],
                                    instr.rdata[30:25], instr.rdata[11:8], 1'b0}+
                                    instr.mem_addr;
                            exp_addr[1:0] = 2'b00;
                            branch_pend=1;
                        end else begin
                            exp_addr+=4;
                        end
                        $fdisplay(history_file, "%h : bgeu x%d, x%d, %d",
                                  instr.rdata,
                                  $unsigned(instr.rdata[19:15]),
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31], instr.rdata[7],
                                           instr.rdata[30:25], instr.rdata[11:8], 1'b0}));
                    end
                    default:;
                endcase
            end
            7'b0000011: begin
                // Select the instr based on funct3
                case(instr.rdata[14:12])
                    //LB
                    3'b000: begin
                        // Calculate the addr
                        op_sgn_1 = temp_ref_regs.regs[instr.rdata[19:15]]+
                                   {{20{instr.rdata[31]}}, instr.rdata[31:20]};
                        // Get 1 byte from storage
                        op_sgn_2[7:0] = instr.stg.mem[op_sgn_1];
                        // Sign extend
                        op_sgn_2[31:8] = {24{op_sgn_2[7]}};
                        temp_ref_regs.regs[instr.rdata[11:7]]= op_sgn_2;

                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : lb x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $signed(instr.rdata[31:20]),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    //LH
                    3'b001: begin
                        // Calculate the addr
                        op_sgn_1 = temp_ref_regs.regs[instr.rdata[19:15]]+
                                   {{20{instr.rdata[31]}}, instr.rdata[31:20]};
                                   `uvm_info("SCB", $sformatf(
                                    "Addr for LH: %h", op_sgn_1, exp_addr), UVM_LOW);
                        // Align 2-bytes
                        op_sgn_1[0]=1'b0;
                        // Get the 2 bytes from storage
                        op_sgn_2[15:0] = {instr.stg.mem[op_sgn_1 + 1], instr.stg.mem[op_sgn_1]};
                        `uvm_info("SCB", $sformatf(
                                    "Data load: %h", op_sgn_2, exp_addr), UVM_LOW);
                        // Sign extend
                        op_sgn_2[31:16] = {16{op_sgn_2[15]}};
                        temp_ref_regs.regs[instr.rdata[11:7]] = op_sgn_2;
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : lh x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $signed(instr.rdata[31:20]),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    //LW
                    3'b010: begin
                        op_sgn_1 = temp_ref_regs.regs[instr.rdata[19:15]]+
                                   {{20{instr.rdata[31]}}, instr.rdata[31:20]};
                        // Align memory
                        op_sgn_1[1:0]=2'b0;
                        // Get the word from storage
                        op_sgn_2 = {instr.stg.mem[op_sgn_1 + 3],
                                    instr.stg.mem[op_sgn_1 + 2],
                                    instr.stg.mem[op_sgn_1 + 1],
                                    instr.stg.mem[op_sgn_1]};
                        temp_ref_regs.regs[instr.rdata[11:7]]=op_sgn_2;
                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : lw x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $signed(instr.rdata[31:20]),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    //LBU
                    3'b100: begin
                        // Calculate the addr
                        op_sgn_1 = temp_ref_regs.regs[instr.rdata[19:15]]+
                                   {{20{instr.rdata[31]}}, instr.rdata[31:20]};
                        // Get 1 byte from storage
                        op_sgn_2[7:0] = instr.stg.mem[op_sgn_1];
                        // zero extend
                        op_sgn_2[31:8] = 24'b0;
                        temp_ref_regs.regs[instr.rdata[11:7]]= op_sgn_2;

                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : lbu x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $signed(instr.rdata[31:20]),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    //LHU
                    3'b101: begin
                        // Calculate the addr
                        op_sgn_1 = temp_ref_regs.regs[instr.rdata[19:15]]+
                                   {{20{instr.rdata[31]}}, instr.rdata[31:20]};
                        // Align 4-bytes
                        op_sgn_1[0]=1'b0;
                        // Get the 2 bytes from storage
                        op_sgn_2[15:0] = {instr.stg.mem[op_sgn_1+1], instr.stg.mem[op_sgn_1]};
                        // zero extend
                        op_sgn_2[31:16] = 16'b0;
                        temp_ref_regs.regs[instr.rdata[11:7]] = op_sgn_2;
                        //foreach (instr.stg.mem[key]) begin
                        //    `uvm_info("SCB", $sformatf("addr %h, data: %h", key, instr.stg.mem[key]), UVM_LOW)
                        //end

                        regs_queue.push_back(temp_ref_regs);
                        `uvm_info("SCB", "Queue write", UVM_LOW)
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : lhu x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[11:7]),
                                  $signed(instr.rdata[31:20]),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    default:;
                endcase;
            end
            7'b0100011: begin
                // Select the instr based on funct3
                case(instr.rdata[14:12])
                    //SB
                    3'b000: begin
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : sb x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31:25], instr.rdata[11:7]}),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    //SH
                    3'b001: begin
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : sh x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31:25], instr.rdata[11:7]}),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    //SW
                    3'b010: begin
                        exp_addr+=4;
                        $fdisplay(history_file, "%h : sw x%d, %d(x%d)",
                                  instr.rdata,
                                  $unsigned(instr.rdata[24:20]),
                                  $signed({instr.rdata[31:25], instr.rdata[11:7]}),
                                  $unsigned(instr.rdata[19:15]));
                        end
                    default:;
                endcase;
            end
            // Fake instr
            7'b1111111:begin
                if (instr.rdata[21])begin
                    temp_ref_regs.regs[instr.rdata[11:7]] = 32'hFFFFFFFF;
                end
                regs_queue.push_back(temp_ref_regs);
                exp_addr+=4;
                $fdisplay(history_file, "%h : fake", instr.rdata);
            end
           default:begin
            `uvm_error("SCB", $sformatf("Unknown opcode"))
           end
       endcase

       `uvm_info("SCB", $sformatf(
        "queue size %d", regs_queue.size()), UVM_LOW);

       //Remove the last item from queue if rd=0 for those instruction that use it (instead of imm)
       if (instr.rdata[6:0]  != 7'b1100011 &&
           instr.rdata[6:0]  != 7'b0100011 &&
           instr.rdata[11:7] == 5'b0         )begin
           regs_queue.pop_back();
           `uvm_info("SCB", $sformatf(
            "regs remove from queue. instr %h", instr.rdata), UVM_LOW);
            `uvm_info("SCB", $sformatf(
                "queue size %d", regs_queue.size()), UVM_LOW);
       end
       // Remove last item if it isn't different from the last one group of regs
        if (regs_queue.size()>=2)begin
            if (regs_queue[regs_queue.size()-1]==regs_queue[regs_queue.size()-2])begin
                regs_queue.pop_back();
                `uvm_info("SCB", $sformatf(
                    "Remove last item of the queue because it's the same"), UVM_LOW);
            end
        end else if (regs_queue.size()==1)begin
            if (regs_queue[0]==ref_regs)begin
                regs_queue.pop_back();
                `uvm_info("SCB", $sformatf(
                    "Remove last item of the queue because it's equal to ref_regs"), UVM_LOW);
            end
        end

        last_addr=instr.mem_addr;


    endfunction: write_mem;

    virtual function void write_rset (reset_item rst_item);
        //FIXME: add the data process
    endfunction: write_rset;

    virtual function void write_pcpi (pcpi_item pcpi_itm);
        //FIXME: add the data process
    endfunction: write_pcpi;

    virtual function void write_reg (reg_state reg_stte);
        if (regs_queue.size()!=0)begin
            ref_regs = regs_queue.pop_front();
        end
        reg_stte.print();
        if (ref_regs.regs[1 ] != reg_stte.reg_state_x1  ||
            ref_regs.regs[2 ] != reg_stte.reg_state_x2  ||
            ref_regs.regs[3 ] != reg_stte.reg_state_x3  ||
            ref_regs.regs[4 ] != reg_stte.reg_state_x4  ||
            ref_regs.regs[5 ] != reg_stte.reg_state_x5  ||
            ref_regs.regs[6 ] != reg_stte.reg_state_x6  ||
            ref_regs.regs[7 ] != reg_stte.reg_state_x7  ||
            ref_regs.regs[8 ] != reg_stte.reg_state_x8  ||
            ref_regs.regs[9 ] != reg_stte.reg_state_x9  ||
            ref_regs.regs[10] != reg_stte.reg_state_x10 ||
            ref_regs.regs[11] != reg_stte.reg_state_x11 ||
            ref_regs.regs[12] != reg_stte.reg_state_x12 ||
            ref_regs.regs[13] != reg_stte.reg_state_x13 ||
            ref_regs.regs[14] != reg_stte.reg_state_x14 ||
            ref_regs.regs[15] != reg_stte.reg_state_x15 ||
            ref_regs.regs[16] != reg_stte.reg_state_x16 ||
            ref_regs.regs[17] != reg_stte.reg_state_x17 ||
            ref_regs.regs[18] != reg_stte.reg_state_x18 ||
            ref_regs.regs[19] != reg_stte.reg_state_x19 ||
            ref_regs.regs[20] != reg_stte.reg_state_x20 ||
            ref_regs.regs[21] != reg_stte.reg_state_x21 ||
            ref_regs.regs[22] != reg_stte.reg_state_x22 ||
            ref_regs.regs[23] != reg_stte.reg_state_x23 ||
            ref_regs.regs[24] != reg_stte.reg_state_x24 ||
            ref_regs.regs[25] != reg_stte.reg_state_x25 ||
            ref_regs.regs[26] != reg_stte.reg_state_x26 ||
            ref_regs.regs[27] != reg_stte.reg_state_x27 ||
            ref_regs.regs[28] != reg_stte.reg_state_x28 ||
            ref_regs.regs[29] != reg_stte.reg_state_x29 ||
            ref_regs.regs[30] != reg_stte.reg_state_x30 ||
            ref_regs.regs[31] != reg_stte.reg_state_x31
        ) begin
            `uvm_error("SCB", $sformatf("The regs are not the same"))

            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[1]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[2]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[3]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[4]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[5]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[6]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[7]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[8]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[9]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[10]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[11]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[12]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[13]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[14]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[15]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[16]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[17]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[18]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[19]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[20]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[21]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[22]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[23]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[24]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[25]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[26]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[27]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[28]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[29]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[30]), UVM_LOW)
            `uvm_info("SCB", $sformatf("reg: %h", ref_regs.regs[31]), UVM_LOW)

        end else begin
            `uvm_info("SCB", $sformatf("The regs match"), UVM_LOW)
        end

        // Check if it necessary to remove the next item on the queue because it is equal
        if (regs_queue.size()!=0)begin
            t2_ref_regs = regs_queue.pop_front();
            if (ref_regs.regs[1 ] != t2_ref_regs.regs[1 ] ||
                ref_regs.regs[2 ] != t2_ref_regs.regs[2 ] ||
                ref_regs.regs[3 ] != t2_ref_regs.regs[3 ] ||
                ref_regs.regs[4 ] != t2_ref_regs.regs[4 ] ||
                ref_regs.regs[5 ] != t2_ref_regs.regs[5 ] ||
                ref_regs.regs[6 ] != t2_ref_regs.regs[6 ] ||
                ref_regs.regs[7 ] != t2_ref_regs.regs[7 ] ||
                ref_regs.regs[8 ] != t2_ref_regs.regs[8 ] ||
                ref_regs.regs[9 ] != t2_ref_regs.regs[9 ] ||
                ref_regs.regs[10] != t2_ref_regs.regs[10] ||
                ref_regs.regs[11] != t2_ref_regs.regs[11] ||
                ref_regs.regs[12] != t2_ref_regs.regs[12] ||
                ref_regs.regs[13] != t2_ref_regs.regs[13] ||
                ref_regs.regs[14] != t2_ref_regs.regs[14] ||
                ref_regs.regs[15] != t2_ref_regs.regs[15] ||
                ref_regs.regs[16] != t2_ref_regs.regs[16] ||
                ref_regs.regs[17] != t2_ref_regs.regs[17] ||
                ref_regs.regs[18] != t2_ref_regs.regs[18] ||
                ref_regs.regs[19] != t2_ref_regs.regs[19] ||
                ref_regs.regs[20] != t2_ref_regs.regs[20] ||
                ref_regs.regs[21] != t2_ref_regs.regs[21] ||
                ref_regs.regs[22] != t2_ref_regs.regs[22] ||
                ref_regs.regs[23] != t2_ref_regs.regs[23] ||
                ref_regs.regs[24] != t2_ref_regs.regs[24] ||
                ref_regs.regs[25] != t2_ref_regs.regs[25] ||
                ref_regs.regs[26] != t2_ref_regs.regs[26] ||
                ref_regs.regs[27] != t2_ref_regs.regs[27] ||
                ref_regs.regs[28] != t2_ref_regs.regs[28] ||
                ref_regs.regs[29] != t2_ref_regs.regs[29] ||
                ref_regs.regs[30] != t2_ref_regs.regs[30] ||
                ref_regs.regs[31] != t2_ref_regs.regs[31] ) begin
                // If they are not the same, return the group of regs to queue
                regs_queue.push_front(t2_ref_regs);
            end
        end

    endfunction: write_reg;

    function final_phase (uvm_phase phase);
        $fclose(history_file);
    endfunction: final_phase


endclass: scoreboard





