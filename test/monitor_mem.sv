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
 * PicoRV; It contains the monitor for the memory interface.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 21/9/2024
 */
 `include "uvm_macros.svh"

class monitor_mem extends uvm_monitor;
    `uvm_component_utils(monitor_mem)

    uvm_analysis_port #(instr_item)   instr_analysis_port;
    uvm_analysis_port #(request_item) request_port;
    uvm_analysis_port #(reg_state)    reg_state_port;
    virtual mem_if intf_if;
    int empty_counter;
    storage stg;
    int key;


    function new (string name, uvm_component parent = null);
        super.new (name, parent);
        empty_counter = 0;
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        request_port = new ("request_port", this);
        instr_analysis_port= new("instr_analysis_port", this);
        reg_state_port = new("reg_state_port", this);
        stg = storage::type_id::create("stg", this);

        if(uvm_config_db #(virtual mem_if)::get(
                this,
                "",
                "VIRTUAL_M_INTERFACE",
                intf_if) == 0)
        begin
            `uvm_fatal("INTERFACE_CONNECT",
                      "Could not get from the database the virtual interface for the TB")
        end

    endfunction

    virtual task run_phase (uvm_phase phase);
        request_item req_item =request_item::type_id::create("req_item", this);
        instr_item instr_itm = instr_item::type_id::create("instr_itm", this);
        reg_state reg_stte = reg_state::type_id::create("reg_stte", this);
        fork
            request_resp(req_item);
            security_stop(req_item);
            instr_obsvr(instr_itm);
            reg_state_obsvr(reg_stte);
        join
        // FIXME: Add the logic to the rest of the monitor
    endtask: run_phase

    virtual task request_resp(request_item req_item);
    forever begin
        @(posedge intf_if.mem_valid);
        if (intf_if.mem_valid && intf_if.mem_instr)begin
            // Instruction fetch
            req_item.instr_fetch=1;
            req_item.mem_write=0;
            req_item.mem_read=0;
            empty_counter=0;
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

    virtual task security_stop(request_item req_item);
        forever begin
            @(posedge intf_if.clk)
            empty_counter++;
            if (empty_counter==300)begin
                `uvm_fatal("DUT BLOCKED",
                "Too many cycles without DUT request")
            end
        end
    endtask: security_stop

    virtual task instr_obsvr(instr_item instr);
        forever begin
            @(posedge intf_if.clk);
            if (intf_if.mem_ready && intf_if.mem_instr)begin
                // instr fetch
                instr.rdata=intf_if.mem_rdata;
                instr.mem_addr = intf_if.mem_addr;


                // Create a copy of the storage to send it to scoreboard
                foreach (stg.stg_cl.mem[key]) begin
                    instr.stg.mem[key] = stg.stg_cl.mem[key];
                end
                instr_analysis_port.write(instr);

            end
        end
    endtask: instr_obsvr

    virtual task reg_state_obsvr (reg_state reg_stte);
    forever begin
        @ (intf_if.dbg_reg_x1  or
           intf_if.dbg_reg_x2  or
           intf_if.dbg_reg_x3  or
           intf_if.dbg_reg_x4  or
           intf_if.dbg_reg_x5  or
           intf_if.dbg_reg_x6  or
           intf_if.dbg_reg_x7  or
           intf_if.dbg_reg_x8  or
           intf_if.dbg_reg_x9  or
           intf_if.dbg_reg_x10 or
           intf_if.dbg_reg_x11 or
           intf_if.dbg_reg_x12 or
           intf_if.dbg_reg_x13 or
           intf_if.dbg_reg_x14 or
           intf_if.dbg_reg_x15 or
           intf_if.dbg_reg_x16 or
           intf_if.dbg_reg_x17 or
           intf_if.dbg_reg_x18 or
           intf_if.dbg_reg_x19 or
           intf_if.dbg_reg_x20 or
           intf_if.dbg_reg_x21 or
           intf_if.dbg_reg_x22 or
           intf_if.dbg_reg_x23 or
           intf_if.dbg_reg_x24 or
           intf_if.dbg_reg_x25 or
           intf_if.dbg_reg_x26 or
           intf_if.dbg_reg_x27 or
           intf_if.dbg_reg_x28 or
           intf_if.dbg_reg_x29 or
           intf_if.dbg_reg_x30 or
           intf_if.dbg_reg_x31
           );
        reg_stte.reg_state_x1  = intf_if.dbg_reg_x1;
        reg_stte.reg_state_x2  = intf_if.dbg_reg_x2;
        reg_stte.reg_state_x3  = intf_if.dbg_reg_x3;
        reg_stte.reg_state_x4  = intf_if.dbg_reg_x4;
        reg_stte.reg_state_x5  = intf_if.dbg_reg_x5;
        reg_stte.reg_state_x6  = intf_if.dbg_reg_x6;
        reg_stte.reg_state_x7  = intf_if.dbg_reg_x7;
        reg_stte.reg_state_x8  = intf_if.dbg_reg_x8;
        reg_stte.reg_state_x9  = intf_if.dbg_reg_x9;
        reg_stte.reg_state_x10 = intf_if.dbg_reg_x10;
        reg_stte.reg_state_x11 = intf_if.dbg_reg_x11;
        reg_stte.reg_state_x12 = intf_if.dbg_reg_x12;
        reg_stte.reg_state_x13 = intf_if.dbg_reg_x13;
        reg_stte.reg_state_x14 = intf_if.dbg_reg_x14;
        reg_stte.reg_state_x15 = intf_if.dbg_reg_x15;
        reg_stte.reg_state_x16 = intf_if.dbg_reg_x16;
        reg_stte.reg_state_x17 = intf_if.dbg_reg_x17;
        reg_stte.reg_state_x18 = intf_if.dbg_reg_x18;
        reg_stte.reg_state_x19 = intf_if.dbg_reg_x19;
        reg_stte.reg_state_x20 = intf_if.dbg_reg_x20;
        reg_stte.reg_state_x21 = intf_if.dbg_reg_x21;
        reg_stte.reg_state_x22 = intf_if.dbg_reg_x22;
        reg_stte.reg_state_x23 = intf_if.dbg_reg_x23;
        reg_stte.reg_state_x24 = intf_if.dbg_reg_x24;
        reg_stte.reg_state_x25 = intf_if.dbg_reg_x25;
        reg_stte.reg_state_x26 = intf_if.dbg_reg_x26;
        reg_stte.reg_state_x27 = intf_if.dbg_reg_x27;
        reg_stte.reg_state_x28 = intf_if.dbg_reg_x28;
        reg_stte.reg_state_x29 = intf_if.dbg_reg_x29;
        reg_stte.reg_state_x30 = intf_if.dbg_reg_x30;
        reg_stte.reg_state_x31 = intf_if.dbg_reg_x31;

        reg_state_port.write(reg_stte);
    end
    endtask: reg_state_obsvr




endclass: monitor_mem
