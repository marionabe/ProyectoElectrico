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
 * It contains three classes: the driver, the sequence_item and the sequencer.
 * All these classes are UVM components.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 1/9/2024
 */

`include "uvm_macros.svh"
import uvm_pkg::*;

class instr_item extends uvm_sequence_item;
    rand int type_instr;
    rand bit [6:0] opcode;
    rand bit [4:0] rd;
    rand bit [2:0] funct3;
    rand bit [4:0] rs1;
    rand bit [4:0] rs2;
    rand bit [19:0] inm;
    rand bit [6:0] funct7;
    bit write_cycle;
    bit read_cycle;
    // This is used to send te instruction from the monitor to scoreboard
    // and to send data from sim_mem to dut
    bit [31:0] rdata;
    bit [31:0] mem_addr;
    storage_t stg;
    bit [31:0] storage_data;

    constraint imm_dist_c {
      inm dist {[20'h0    :20'h1]   := 49  ,
                [20'h2   :20'hFFFD] := 2  ,
                [20'hFFFFE :20'hFFFFF] := 49} ;
    }

    // This section used to generate the next instruction
    constraint distr_type_intr_c{
        type_instr inside{[0:6]};
    }

    // After selecting the type of instruction, generate the specific fields
    // for each instruction
    constraint constr_opcode_c{
        // Type R instr
        if      (type_instr==0) opcode inside{7'b0110011            };
        // Type I instr
        else if (type_instr==1) opcode inside{7'b0010011, 7'b0000011};
        // Type S instr
        else if (type_instr==2) opcode inside{7'b0100011            };
        // Type B instr
        else if (type_instr==3) opcode inside{7'b1100011            };
        // Type U instr
        else if (type_instr==4) opcode inside{7'b0110111, 7'b0010111};
        // Type J instr
        else if (type_instr==5) opcode inside{7'b1101111, 7'b1100111};
        // Fake instruction
        else if (type_instr==6) opcode inside{7'b1111111           };
    }
    constraint constr_funct3_c{
        if      (opcode==7'b1100111) funct3 inside{3'b000};
        else if (opcode==7'b1100011) funct3 inside{3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
        else if (opcode==7'b0000011) funct3 inside{3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
        else if (opcode==7'b0100011) funct3 inside{3'b000, 3'b001, 3'b010};
        else if (opcode==7'b0010011) funct3 inside{[0:8]};
        else if (opcode==7'b0010011) funct3 inside{3'b101};
    }
    constraint constr_funct7_c{
        if       (funct3==3'b101 && opcode==7'b0010011)
                                  funct7 inside {7'b0000000, 7'b0100000             };
        else if  (funct3==3'b101) funct7 inside {7'b0000000, 7'b0100000, 7'b0000001 };
        else if  (funct3==3'b000) funct7 inside {7'b0000000, 7'b0100000, 7'b0000001 };
        else                      funct7 inside {7'b0000000, 7'b0000001             };
    }
    `uvm_object_utils_begin(instr_item)
        `uvm_field_int (type_instr, UVM_DEFAULT)
        `uvm_field_int (opcode, UVM_DEFAULT)
        `uvm_field_int (rd, UVM_DEFAULT)
        `uvm_field_int (funct3, UVM_DEFAULT)
        `uvm_field_int (rs1, UVM_DEFAULT)
        `uvm_field_int (rs2, UVM_DEFAULT)
        `uvm_field_int (inm, UVM_DEFAULT)
        `uvm_field_int (funct7, UVM_DEFAULT)
        `uvm_field_int (rdata, UVM_DEFAULT)
        `uvm_field_int (mem_addr, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "instr_item");
        super.new(name);
        write_cycle=0;
        read_cycle=0;
    endfunction: new
endclass: instr_item


class mem_sequencer extends uvm_sequencer #(instr_item);
    `uvm_component_utils(mem_sequencer)

    uvm_analysis_port #(request_item) request_export;
    uvm_tlm_analysis_fifo #(request_item) request_fifo;

    function new (string name = "mem_sequencer", uvm_component parent = null);
        super.new (name, parent);
        request_export = new("request_export", this);
        request_fifo = new("request_fifo", this);
    endfunction: new

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        request_export.connect(request_fifo.analysis_export);
    endfunction: connect_phase

endclass: mem_sequencer


class instr_item_seq extends uvm_sequence;
    `uvm_object_utils(instr_item_seq)
    `uvm_declare_p_sequencer (mem_sequencer)
    request_item req_item;
    int instr_count;
    int last_instr;
    int last_instr_2;


    function new(string name="instr_item_seq");
        super.new(name);
        instr_count=0;
        last_instr=7;
        last_instr_2=7;
    endfunction: new

    virtual task body();
        // max tested= 200 000
        while (instr_count<800000) begin
            instr_item instr_1 = instr_item::type_id::create("instr_item");

            `uvm_info("M_SEQ", $sformatf("Transaction number: %d", instr_count), UVM_LOW)
            `uvm_info("M_SEQ", $sformatf("Waiting for request"), UVM_LOW)
            p_sequencer.request_fifo.get(req_item);

            if(req_item.instr_fetch || req_item.mem_write || req_item.mem_read)begin
                req_item.print();
                if (req_item.mem_write)begin
                    // This is to indicate to driver if this is a write-to-mem cycle
                    instr_1.write_cycle=1;
                end else if (req_item.mem_read)begin
                    // This is to send data from mem to DUT
                    instr_1.read_cycle=1;
                    instr_1.rdata=req_item.rdata;
                end
                start_item(instr_1);
                instr_1.randomize();
                if ((last_instr==2 && instr_1.type_instr==1)||
                    (last_instr_2==2 && instr_1.type_instr==1))begin
                    instr_1.opcode=7'b1111111;
                end
                `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
                instr_1.print();
                finish_item(instr_1);
                `uvm_info("SEQ", $sformatf("Done generation of new instruction"), UVM_LOW)
                instr_count++;
                last_instr_2=last_instr;
                last_instr=instr_1.type_instr;
            end
        end
    endtask: body
endclass: instr_item_seq



class picorv_driver extends uvm_driver #(instr_item);
    `uvm_component_utils (picorv_driver)
    virtual mem_if intf_if;
    bit [4:0] act_reg_fill= 5'b00000;
    bit sim_mem [bit[31:0]];


    function new(string name = "picorv_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(uvm_config_db #(virtual mem_if)::get(
                                                this,
                                                "",
                                                "VIRTUAL_M_INTERFACE",
            intf_if) == 0) begin
            `uvm_fatal("INTERFACE_CONNECT",
                      "Could not get from the database the virtual interface for the TB")
        end else begin
            `uvm_info("DRV", $sformatf("Interface obtained"), UVM_LOW)
        end
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            instr_item  instr_1;
            seq_item_port.get_next_item(instr_1);
            send_instr(instr_1);
            `uvm_info("DRV", $sformatf("Instruction has been sent to the DUT"), UVM_LOW)
            seq_item_port.item_done();
        end
    endtask: run_phase


    // This is the task used to send the instructions to the picorv
    virtual task send_instr(instr_item item_1);
        intf_if.mem_ready <= 0;

        // Fixme: change this to a more stetic delay
        @(posedge intf_if.clk);
        @(posedge intf_if.clk);
        @(posedge intf_if.clk);
        @(posedge intf_if.clk);
        @(posedge intf_if.clk);
        intf_if.mem_ready <= 1;
        if (item_1.write_cycle)begin
            intf_if.mem_rdata <= 'hx;
        end else if (item_1.read_cycle)begin
            intf_if.mem_rdata <= item_1.rdata;
        end else begin
            // Before starting, it's necessary to fill all the regs
            if (act_reg_fill<31)begin
                act_reg_fill++;
                intf_if.mem_rdata <= {item_1.inm[11:0],
                                      5'b00000,
                                      3'b000,
                                      act_reg_fill,
                                      7'b0010011};
            end else begin
                // Choose the instruction format based on the opcode
                case (item_1.opcode)
                    7'b0110011: begin
                        // R type instr
                        intf_if.mem_rdata <= {item_1.funct7,
                                              item_1.rs2,
                                              item_1.rs1,
                                              item_1.funct3,
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    7'b0110111:begin
                        // LUI instr
                        intf_if.mem_rdata <= {item_1.inm,
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    7'b0010111:begin
                        // AUIPC instr
                        intf_if.mem_rdata <= {item_1.inm,
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    7'b1101111:begin
                        // JAL instr
                        // Send 2 0's to avoid misaligned jump address
                        intf_if.mem_rdata <= {{item_1.inm[19:11],2'b00,item_1.inm[8:0]},
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    7'b1100111:begin
                        // JALR instr
                        intf_if.mem_rdata <= {item_1.inm[11:0],
                                              item_1.rs1,
                                              item_1.funct3,
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    7'b1100011:begin
                        // Type B instr
                        intf_if.mem_rdata <= {item_1.inm[11:5],
                                              item_1.rs2,
                                              item_1.rs1,
                                              item_1.funct3,
                                              item_1.inm[4:0],
                                              item_1.opcode};
                    end
                    7'b0000011:begin
                        // Type I instr
                    intf_if.mem_rdata <= {item_1.inm[11:0],
                                              item_1.rs1,
                                              item_1.funct3,
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    7'b0100011:begin
                        // Type S instr
                        intf_if.mem_rdata <= {item_1.inm[11:5],
                                              item_1.rs2,
                                              item_1.rs1,
                                              item_1.funct3,
                                              item_1.inm[4:0],
                                              item_1.opcode};
                    end
                    7'b0010011:begin
                        // Type I instr
                        if (item_1.funct3 == 3'b001 || item_1.funct3 == 3'b101)begin
                            if (item_1.funct3 == 3'b001)begin
                                //SLLI specific case
                                intf_if.mem_rdata <= {7'b0,
                                                      // Use rs2 as shamt
                                                      item_1.rs2,
                                                      item_1.rs1,
                                                      item_1.funct3,
                                                      item_1.rd,
                                                      item_1.opcode};
                            end else begin
                                // SRLI and SRAI
                                intf_if.mem_rdata <= {item_1.funct7,
                                                      // Use rs2 as shamt
                                                      item_1.rs2,
                                                      item_1.rs1,
                                                      item_1.funct3,
                                                      item_1.rd,
                                                      item_1.opcode};
                            end

                        end else begin
                            intf_if.mem_rdata <= {item_1.inm[11:0],
                                                  item_1.rs1,
                                                  item_1.funct3,
                                                  item_1.rd,
                                                  item_1.opcode};
                        end
                    end
                    // Fake instruction. Similar to type R instruction
                    7'b1111111:begin
                        intf_if.mem_rdata <= {item_1.funct7,
                                              item_1.rs2,
                                              item_1.rs1,
                                              item_1.funct3,
                                              item_1.rd,
                                              item_1.opcode};
                    end
                    default: begin
                        `uvm_info("DRV", $sformatf("Wrong opcode detected"), UVM_WARNING)
                        item_1.print();
                    end
                endcase
            end
        end
        @ (negedge intf_if.clk);
        @ (posedge intf_if.clk);
        intf_if.mem_ready <= 0;
    endtask: send_instr

endclass: picorv_driver
