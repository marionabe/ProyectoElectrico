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
 * PicoRV; It contains a test where instructions are obtain from a document
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 9/9/2024
 */
 `include "uvm_macros.svh"

class test_from_document extends uvm_test;
    `uvm_component_utils(test_from_document)
    environment env;

    function new (string name="test_from_document", uvm_component parent=null);
        super.new (name, parent);
    endfunction : new

    virtual mem_if intf_mem_if;
    virtual pcpi_if intf_pcpi_if;
    virtual reset_if intf_reset_if;

    virtual function void build_phase(uvm_phase phase);
        uvm_factory factory = uvm_factory::get();


        factory.set_type_override_by_name("monitor_mem"   , "monitor_mem_2"   );
        factory.set_type_override_by_name("instr_item_seq", "instr_item_seq_2");
        factory.set_type_override_by_name("picorv_driver" , "picorv_driver_2" );
        super.build_phase(phase);

        env  = environment::type_id::create ("env", this);

    endfunction: build_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
        print();
    endfunction : end_of_elaboration_phase

    virtual_sequence v_seq;

    virtual task run_phase(uvm_phase phase);

        phase.raise_objection (this);
        uvm_report_info(get_full_name(),"Start", UVM_LOW);
        v_seq = virtual_sequence::type_id::create("v_seq");
        v_seq.start(env.virtual_seqr);
        #1000
        phase.drop_objection (this);
      endtask: run_phase

endclass: test_from_document


class monitor_mem_2 extends monitor_mem;
    `uvm_component_utils(monitor_mem_2)

    int source_file;
    string s_instr;
    bit [31:0] b_instr;
    int temp_instr_addr;

    function new (string name, uvm_component parent = null);
        super.new (name, parent);
        empty_counter = 0;
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);


        if(uvm_config_db #(virtual mem_if)::get(
                this,
                "",
                "VIRTUAL_M_INTERFACE",
                intf_if) == 0)
        begin
            `uvm_fatal("INTERFACE_CONNECT",
                      "Could not get from the database the virtual interface for the TB")
        end
        // Open file to store the instructions
        //history_file = $fopen("../test/instruction_source.txt", "r");

        // Load instructions from file
        source_file = $fopen("../test/instruction_source.txt", "r");
        while (!$feof(source_file))begin
            $fgets(s_instr, source_file);
            `uvm_info("test", "Instruccion leída", UVM_LOW);
            `uvm_info("test", s_instr, UVM_LOW);
            s_instr={s_instr.getc(0),s_instr.getc(1),s_instr.getc(2),s_instr.getc(3),
                     s_instr.getc(4),s_instr.getc(5),s_instr.getc(6),s_instr.getc(7)};
            b_instr=s_instr.atohex();
           `uvm_info("test", $sformatf(
            "instruccion en hexadecimal %h", b_instr), UVM_LOW);
            stg.write(temp_instr_addr,   b_instr[7:0]);
            stg.write(temp_instr_addr+1, b_instr[15:8]);
            stg.write(temp_instr_addr+2, b_instr[23:16]);
            stg.write(temp_instr_addr+3, b_instr[31:24]);
            temp_instr_addr+=4;
        end
        $fclose(source_file);
    endfunction: build_phase

    virtual task request_resp(request_item req_item);
    forever begin
        @(posedge intf_if.mem_valid);
        if (intf_if.mem_valid && intf_if.mem_instr)begin
            // Instruction fetch
            req_item.instr_fetch=1;
            req_item.mem_write=0;
            req_item.mem_read=0;
            empty_counter=0;
            req_item.rdata={stg.read(intf_if.mem_addr+3),
                            stg.read(intf_if.mem_addr+2),
                            stg.read(intf_if.mem_addr+1),
                            stg.read(intf_if.mem_addr)};
            // Finish the simulation when all the instr have been executed
            if (intf_if.mem_addr+3==temp_instr_addr)begin
                intf_if.end_of_simulation=1;
            end
        end else if (intf_if.mem_valid && !intf_if.mem_wstrb && !intf_if.mem_instr)begin
            // Memory Read
            req_item.instr_fetch=0;
            req_item.mem_write=0;
            req_item.mem_read=1;
            empty_counter=0;
            req_item.rdata={stg.read(intf_if.mem_addr+3),
                            stg.read(intf_if.mem_addr+2),
                            stg.read(intf_if.mem_addr+1),
                            stg.read(intf_if.mem_addr)};
        end else if (intf_if.mem_valid && intf_if.mem_wstrb!=0)begin
            // Memory Write
            req_item.instr_fetch=0;
            req_item.mem_write=1;
            req_item.mem_read=0;
            // Save data to storage
            if (intf_if.mem_wstrb[3]==1) stg.write(intf_if.mem_addr+3, intf_if.mem_wdata[31:24]);
            if (intf_if.mem_wstrb[2]==1) stg.write(intf_if.mem_addr+2, intf_if.mem_wdata[23:15]);
            if (intf_if.mem_wstrb[1]==1) stg.write(intf_if.mem_addr+1, intf_if.mem_wdata[15:8 ]);
            if (intf_if.mem_wstrb[0]==1) stg.write(intf_if.mem_addr, intf_if.mem_wdata[7 :0 ]);

            empty_counter=0;
        end else begin
            req_item.instr_fetch=0;
            req_item.mem_write=0;
            req_item.mem_read=0;
            empty_counter++;
        end
        request_port.write (req_item);
    end
    endtask: request_resp

endclass: monitor_mem_2

class instr_item_seq_2 extends instr_item_seq;
    `uvm_object_utils(instr_item_seq_2)

    function new(string name="instr_item_seq_2");
        super.new(name);
        instr_count=0;
    endfunction: new

    virtual task body();
        forever begin
            instr_item instr_1 = instr_item::type_id::create("instr_item");
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
                end else if (req_item.instr_fetch)begin
                    instr_1.rdata=req_item.rdata;
                end
                start_item(instr_1);
                instr_1.randomize();
                `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
                instr_1.print();
                finish_item(instr_1);
                `uvm_info("SEQ", $sformatf("Done generation of new instruction"), UVM_LOW)
                instr_count++;
            end
        end
    endtask: body
endclass: instr_item_seq_2


class picorv_driver_2 extends picorv_driver;
    `uvm_component_utils (picorv_driver_2)

    function new(string name = "picorv_driver_2", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        while (!intf_if.end_of_simulation) begin
            instr_item  instr_1;
            seq_item_port.get_next_item(instr_1);
            send_instr(instr_1);
            `uvm_info("DRV", $sformatf("Instruction has been sent to the DUT"), UVM_LOW)
            seq_item_port.item_done();
        end
    endtask: run_phase

    // This is the task used to send the instructions to the picorv
    virtual task send_instr(instr_item item_1);

        intf_if.mem_ready <= 1;
        if (item_1.write_cycle)begin
            intf_if.mem_rdata <= 'hx;
        end else begin
            intf_if.mem_rdata <= item_1.rdata;
        end
        @ (negedge intf_if.clk);
        @ (posedge intf_if.clk);
        intf_if.mem_ready <= 0;
    endtask: send_instr

endclass: picorv_driver_2




