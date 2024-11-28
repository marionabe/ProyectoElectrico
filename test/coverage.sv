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
 * PicoRV; It contains the functional coverage of this project.
 * Author: José Mario Navarro Bejarano.
 * Created: 9/9/2024
 */

`include "uvm_macros.svh"

class funct_coverage extends uvm_component;
    `uvm_component_utils(funct_coverage)

    virtual mem_if vir_mem_if;
    virtual reset_if vir_reset_if;
    virtual pcpi_if vir_pcpi_if;

    covergroup cov_type_instr;
        // Cover the opcodes
        type_R: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_R   = {7'b0110011};
        }
        type_I: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_I   = {7'b0000011};
        }
        type_I_2: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_I_2 = {7'b0010011};
        }
        type_S: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_S   = {7'b0100011};
        }
        type_B: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_B   = {7'b1100011};
        }
        type_U: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_U   = {7'b0110111};
        }
        type_U_2: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_U_2 = {7'b0010111};
        }
        type_J: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_J   = {7'b1101111};
        }
        type_J_2: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_J_2 = {7'b1100111};
        }
        type_fake: coverpoint vir_mem_if.mem_rdata[6:0]{
            bins type_fake = {7'b1111111};
        }

        // Cover each instr based on funct3
        funct3_000: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_0 = {3'b000};
        }
        funct3_001: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_1 = {3'b001};
        }
        funct3_010: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_2 = {3'b010};
        }
        funct3_011: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_3 = {3'b011};
        }
        funct3_100: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_4 = {3'b100};
        }
        funct3_101: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_5 = {3'b101};
        }
        funct3_110: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_6 = {3'b110};
        }
        funct3_111: coverpoint vir_mem_if.mem_rdata[14:12]{
            bins f_7 = {3'b111};
        }

        // Cover each instr based on funct7
        funct7_0000000: coverpoint vir_mem_if.mem_rdata[31:25]{
            bins f7_0 = {7'b0000000};
        }
        funct7_0100000: coverpoint vir_mem_if.mem_rdata[31:25]{
            bins f7_1 = {7'b0100000};
        }
        funct7_0000001: coverpoint vir_mem_if.mem_rdata[31:25]{
            bins f7_1 = {7'b0000001};
        }

        rd: coverpoint vir_mem_if.mem_rdata[11:7]{
            bins reg0  = {5'b00000};   bins reg1  = {5'b00001};   bins reg2  = {5'b00010};
            bins reg3  = {5'b00011};   bins reg4  = {5'b00100};   bins reg5  = {5'b00101};
            bins reg6  = {5'b00110};   bins reg7  = {5'b00111};   bins reg8  = {5'b01000};
            bins reg9  = {5'b01001};   bins reg10 = {5'b01010};   bins reg11 = {5'b01011};
            bins reg12 = {5'b01100};   bins reg13 = {5'b01101};   bins reg14 = {5'b01110};
            bins reg15 = {5'b11111};   bins reg16 = {5'b10000};   bins reg17 = {5'b10001};
            bins reg18 = {5'b10010};   bins reg19 = {5'b10011};   bins reg20 = {5'b10100};
            bins reg21 = {5'b10101};   bins reg22 = {5'b10110};   bins reg23 = {5'b10111};
            bins reg24 = {5'b11000};   bins reg25 = {5'b11001};   bins reg26 = {5'b11010};
            bins reg27 = {5'b11011};   bins reg28 = {5'b11100};   bins reg29 = {5'b11101};
            bins reg30 = {5'b11110};   bins reg31 = {5'b11111};
        }
        rs1: coverpoint vir_mem_if.mem_rdata[19:15]{
            bins reg0  = {5'b00000};   bins reg1  = {5'b00001};   bins reg2  = {5'b00010};
            bins reg3  = {5'b00011};   bins reg4  = {5'b00100};   bins reg5  = {5'b00101};
            bins reg6  = {5'b00110};   bins reg7  = {5'b00111};   bins reg8  = {5'b01000};
            bins reg9  = {5'b01001};   bins reg10 = {5'b01010};   bins reg11 = {5'b01011};
            bins reg12 = {5'b01100};   bins reg13 = {5'b01101};   bins reg14 = {5'b01110};
            bins reg15 = {5'b11111};   bins reg16 = {5'b10000};   bins reg17 = {5'b10001};
            bins reg18 = {5'b10010};   bins reg19 = {5'b10011};   bins reg20 = {5'b10100};
            bins reg21 = {5'b10101};   bins reg22 = {5'b10110};   bins reg23 = {5'b10111};
            bins reg24 = {5'b11000};   bins reg25 = {5'b11001};   bins reg26 = {5'b11010};
            bins reg27 = {5'b11011};   bins reg28 = {5'b11100};   bins reg29 = {5'b11101};
            bins reg30 = {5'b11110};   bins reg31 = {5'b11111};
        }

        rs2: coverpoint vir_mem_if.mem_rdata[24:20]{
            bins reg0  = {5'b00000};   bins reg1  = {5'b00001};   bins reg2  = {5'b00010};
            bins reg3  = {5'b00011};   bins reg4  = {5'b00100};   bins reg5  = {5'b00101};
            bins reg6  = {5'b00110};   bins reg7  = {5'b00111};   bins reg8  = {5'b01000};
            bins reg9  = {5'b01001};   bins reg10 = {5'b01010};   bins reg11 = {5'b01011};
            bins reg12 = {5'b01100};   bins reg13 = {5'b01101};   bins reg14 = {5'b01110};
            bins reg15 = {5'b11111};   bins reg16 = {5'b10000};   bins reg17 = {5'b10001};
            bins reg18 = {5'b10010};   bins reg19 = {5'b10011};   bins reg20 = {5'b10100};
            bins reg21 = {5'b10101};   bins reg22 = {5'b10110};   bins reg23 = {5'b10111};
            bins reg24 = {5'b11000};   bins reg25 = {5'b11001};   bins reg26 = {5'b11010};
            bins reg27 = {5'b11011};   bins reg28 = {5'b11100};   bins reg29 = {5'b11101};
            bins reg30 = {5'b11110};   bins reg31 = {5'b11111};
        }

        // All instr use all regs as rd, rs1 and rs2
        luiXrd: cross type_U, rd;

        auipcXrd: cross type_U_2, rd;

        jalXrd: cross type_J, funct3_000, rd;

        jalrXrd:  cross type_J_2, funct3_000, rd;
        jalrXrs1: cross type_J_2, funct3_000, rs1;

        beqXrs1: cross type_B, funct3_000, rs1;
        beqXrs2: cross type_B, funct3_000, rs2;

        bneXrs1: cross type_B, funct3_001, rs1;
        bneXrs2: cross type_B, funct3_001, rs2;

        bltXrs1: cross type_B, funct3_100, rs1;
        bltXrs2: cross type_B, funct3_100, rs2;

        bgeXrs1: cross type_B, funct3_101, rs1;
        bgeXrs2: cross type_B, funct3_101, rs2;

        bltuXrs1: cross type_B, funct3_110, rs1;
        bltuXrs2: cross type_B, funct3_110, rs2;

        bgeuXrs1: cross type_B, funct3_111, rs1;
        bgeuXrs2: cross type_B, funct3_111, rs2;

        lbXrd:  cross type_I, funct3_000, rd;
        lbXrs1: cross type_I, funct3_000, rs1;

        lhXrd:  cross type_I, funct3_001, rd;
        lhXrs1: cross type_I, funct3_001, rs1;

        lwXrd:  cross type_I, funct3_010, rd;
        lwXrs1: cross type_I, funct3_010, rs1;

        lbuXrd:  cross type_I, funct3_100, rd;
        lbuXrs1: cross type_I, funct3_100, rs1;

        lhuXrd:  cross type_I, funct3_101, rd;
        lhuXrs1: cross type_I, funct3_101, rs1;

        sbXrs1: cross type_S, funct3_000, rs1;
        sbXrs2: cross type_S, funct3_000, rs2;

        shXrs1: cross type_S, funct3_001, rs1;
        shXrs2: cross type_S, funct3_001, rs2;

        swXrs1: cross type_S, funct3_010, rs1;
        swXrs2: cross type_S, funct3_010, rs2;

        addiXrd:  cross type_I_2, funct3_000, rd;
        addiXrs1: cross type_I_2, funct3_000, rs1;

        sltiXrd:  cross type_I_2, funct3_010, rd;
        sltiXrs1: cross type_I_2, funct3_010, rs1;

        sltiuXrd:  cross type_I_2, funct3_011, rd;
        sltiuXrs1: cross type_I_2, funct3_011, rs1;

        xoriXrd:  cross type_I_2, funct3_100, rd;
        xoriXrs1: cross type_I_2, funct3_100, rs1;

        oriXrd:  cross type_I_2, funct3_110, rd;
        oriXrs1: cross type_I_2, funct3_110, rs1;

        andiXrd:  cross type_I_2, funct3_111, rd;
        andiXrs1: cross type_I_2, funct3_111, rs1;

        // rs2 use for shamt
        slliXrd:  cross type_I_2, funct3_001, funct7_0000000, rd;
        slliXrs1: cross type_I_2, funct3_001, funct7_0000000, rs1;
        slliXrs2: cross type_I_2, funct3_001, funct7_0000000, rs2;

        srliXrd:  cross type_I_2, funct3_101, funct7_0000000, rd;
        srliXrs1: cross type_I_2, funct3_101, funct7_0000000, rs1;
        srliXrs2: cross type_I_2, funct3_101, funct7_0000000, rs2;

        sraiXrd:  cross type_I_2, funct3_101, funct7_0100000, rd;
        sraiXrs1: cross type_I_2, funct3_101, funct7_0100000, rs1;
        sraiXrs2: cross type_I_2, funct3_101, funct7_0100000, rs2;

        addXrd:  cross type_R, funct3_000, funct7_0000000, rd;
        addXrs1: cross type_R, funct3_000, funct7_0000000, rs1;
        addXrs2: cross type_R, funct3_000, funct7_0000000, rs2;

        subXrd:  cross type_R, funct3_000, funct7_0100000, rd;
        subXrs1: cross type_R, funct3_000, funct7_0100000, rs1;
        subXrs2: cross type_R, funct3_000, funct7_0100000, rs2;

        sllXrd:  cross type_R, funct3_001, funct7_0000000, rd;
        sllXrs1: cross type_R, funct3_001, funct7_0000000, rs1;
        sllXrs2: cross type_R, funct3_001, funct7_0000000, rs2;

        sltXrd:  cross type_R, funct3_010, funct7_0000000, rd;
        sltXrs1: cross type_R, funct3_010, funct7_0000000, rs1;
        sltXrs2: cross type_R, funct3_010, funct7_0000000, rs2;

        sltuXrd:  cross type_R, funct3_011, funct7_0000000, rd;
        sltuXrs1: cross type_R, funct3_011, funct7_0000000, rs1;
        sltuXrs2: cross type_R, funct3_011, funct7_0000000, rs2;

        xorXrd:  cross type_R, funct3_100, funct7_0000000, rd;
        xorXrs1: cross type_R, funct3_100, funct7_0000000, rs1;
        xorXrs2: cross type_R, funct3_100, funct7_0000000, rs2;

        srlXrd:  cross type_R, funct3_101, funct7_0000000, rd;
        srlXrs1: cross type_R, funct3_101, funct7_0000000, rs1;
        srlXrs2: cross type_R, funct3_101, funct7_0000000, rs2;

        sraXrd:  cross type_R, funct3_101, funct7_0100000, rd;
        sraXrs1: cross type_R, funct3_101, funct7_0100000, rs1;
        sraXrs2: cross type_R, funct3_101, funct7_0100000, rs2;

        orXrd:  cross type_R, funct3_110, funct7_0000000, rd;
        orXrs1: cross type_R, funct3_110, funct7_0000000, rs1;
        orXrs2: cross type_R, funct3_110, funct7_0000000, rs2;

        andXrd:  cross type_R, funct3_111, funct7_0000000, rd;
        andXrs1: cross type_R, funct3_111, funct7_0000000, rs1;
        andXrs2: cross type_R, funct3_111, funct7_0000000, rs2;

        mulXrd:  cross type_R, funct3_000, funct7_0000001, rd;
        mulXrs1: cross type_R, funct3_000, funct7_0000001, rs1;
        mulXrs2: cross type_R, funct3_000, funct7_0000001, rs2;

        mulhXrd:  cross type_R, funct3_001, funct7_0000001, rd;
        mulhXrs1: cross type_R, funct3_001, funct7_0000001, rs1;
        mulhXrs2: cross type_R, funct3_001, funct7_0000001, rs2;

        mulhsuXrd:  cross type_R, funct3_010, funct7_0000001, rd;
        mulhsuXrs1: cross type_R, funct3_010, funct7_0000001, rs1;
        mulhsuXrs2: cross type_R, funct3_010, funct7_0000001, rs2;

        mulhuXrd:  cross type_R, funct3_011, funct7_0000001, rd;
        mulhuXrs1: cross type_R, funct3_011, funct7_0000001, rs1;
        mulhuXrs2: cross type_R, funct3_011, funct7_0000001, rs2;

        divXrd:  cross type_R, funct3_100, funct7_0000001, rd;
        divXrs1: cross type_R, funct3_100, funct7_0000001, rs1;
        divXrs2: cross type_R, funct3_100, funct7_0000001, rs2;

        divuXrd:  cross type_R, funct3_101, funct7_0000001, rd;
        divuXrs1: cross type_R, funct3_101, funct7_0000001, rs1;
        divuXrs2: cross type_R, funct3_101, funct7_0000001, rs2;

        remXrd:  cross type_R, funct3_110, funct7_0000001, rd;
        remXrs1: cross type_R, funct3_110, funct7_0000001, rs1;
        remXrs2: cross type_R, funct3_110, funct7_0000001, rs2;

        remuXrd:  cross type_R, funct3_111, funct7_0000001, rd;
        remuXrs1: cross type_R, funct3_111, funct7_0000001, rs1;
        remuXrs2: cross type_R, funct3_111, funct7_0000001, rs2;

        fakexrd:  cross type_fake, rd;
        fakexrs1: cross type_fake, rs1;
        fakexrs2: cross type_fake, rs2;

        // Check that type_I and JALR instr load values from 0 to 0xFFF
        load_values_12b: coverpoint vir_mem_if.mem_rdata[31:20]{
            bins min   = {12'h000};
            bins max   = {12'hFFF};
            bins inter = default;
        }
        addiXval_imm:  cross type_I_2, funct3_000, load_values_12b;
        sltiXval_imm:  cross type_I_2, funct3_010, load_values_12b;
        sltiuXval_imm: cross type_I_2, funct3_011, load_values_12b;
        xoriXval_imm:  cross type_I_2, funct3_100, load_values_12b;
        oriXval_imm:   cross type_I_2, funct3_110, load_values_12b;
        andiXval_imm:  cross type_I_2, funct3_111, load_values_12b;
        jalrXval_imm:  cross type_J_2, funct3_000, load_values_12b;
        lbXval_imm:   cross type_I, funct3_000, load_values_12b;
        lhXval_imm:   cross type_I, funct3_001, load_values_12b;
        lwXval_imm:   cross type_I, funct3_010, load_values_12b;
        lbuXval_imm:  cross type_I, funct3_100, load_values_12b;
        lhuXval_imm:  cross type_I, funct3_101, load_values_12b;


        // Check that LUI, AUIPC instr load values from 0 to 0xFFFFF
        load_values_20b: coverpoint vir_mem_if.mem_rdata[31:12]{
            bins min   = {20'h00000};
            bins max   = {20'hFFFFF};
            bins inter = default;
        }
        luiXimm:   cross type_U, load_values_20b;
        auipcXimm: cross type_U_2, load_values_20b;

        // This is similar to load_values_20b, but using bit 9-10 always as zero
        // this is how the driver send the instr to ovoid misaligned mem access.
        load_values_20b_00: coverpoint vir_mem_if.mem_rdata[31:12]{
            bins min   = {20'h00000};
            bins max   = {20'hFF9FF};
            bins inter = default;
        }
        jalXimm:   cross type_J, load_values_20b_00;

        // Check that type_S and type_B instr use values from 0 to 0xFFFFF
        load_values_5b: coverpoint vir_mem_if.mem_rdata[11:7]{
            bins min   = {5'h00};
            bins max   = {5'h1F};
            bins inter = default;
        }
        load_values_7b: coverpoint vir_mem_if.mem_rdata[31:25]{
            bins min   = {7'h00};
            bins max   = {7'h7F};
            bins inter = default;
        }

        beqXimm1:  cross type_B, funct3_000, load_values_5b;
        beqXimm2:  cross type_B, funct3_000, load_values_7b;
        bneXimm1:  cross type_B, funct3_001, load_values_5b;
        bneXimm2:  cross type_B, funct3_001, load_values_7b;
        bltXimm1:  cross type_B, funct3_100, load_values_5b;
        bltXimm2:  cross type_B, funct3_100, load_values_7b;
        bgeXimm1:  cross type_B, funct3_101, load_values_5b;
        bgeXimm2:  cross type_B, funct3_101, load_values_7b;
        bltuXimm1:  cross type_B, funct3_110, load_values_5b;
        bltuXimm2:  cross type_B, funct3_110, load_values_7b;
        bgeuXimm1:  cross type_B, funct3_111, load_values_5b;
        bgeuXimm2:  cross type_B, funct3_111, load_values_7b;

        sbXimm1: cross type_S, funct3_000, load_values_5b;
        sbXimm2: cross type_S, funct3_000, load_values_7b;

        shXimm1: cross type_S, funct3_001, load_values_5b;
        shXimm2: cross type_S, funct3_001, load_values_7b;

        swXimm1: cross type_S, funct3_010, load_values_5b;
        swXimm2: cross type_S, funct3_010, load_values_7b;

    endgroup: cov_type_instr


    function new (string name = "funct_coverage", uvm_component parent = null);
        super.new (name, parent);
        cov_type_instr = new ();
    endfunction: new

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        if(uvm_config_db #(virtual mem_if)::get(this,
                                                "",
                                                "VIRTUAL_M_INTERFACE",
                                                vir_mem_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                       "Could not get from the database the virtual interface for the TB")
        end
        if(uvm_config_db #(virtual pcpi_if)::get(this,
                                                 "",
                                                 "VIRTUAL_P_INTERFACE",
                                                 vir_pcpi_if) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT",
        "Could not get from the database the virtual interface (PCPI) for the TB")
        end
        if(uvm_config_db #(virtual reset_if)::get(this,
                                                  "",
                                                  "VIRTUAL_R_INTERFACE",
                                                  vir_reset_if) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT",
        "Could not get from the database the virtual interface (reset) for the TB")
        end
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
        @(posedge vir_mem_if.clk)begin
            cov_type_instr.sample();
        end
    end

    endtask: run_phase

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        $display("COV_type_instr Overall: %3.2f%% coverage achieved.",
        cov_type_instr.get_coverage());
    endfunction: report_phase

endclass: funct_coverage

        