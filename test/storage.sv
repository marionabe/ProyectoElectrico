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
 * PicoRV; It contains the simulated storage, used as a memory.
 *
 * Author: José Mario Navarro Bejarano.
 * Created: 9/9/2024
 */
`include "uvm_macros.svh"

typedef struct{
    bit [7:0] mem [int];
} storage_t;

class storage extends uvm_component;
    `uvm_component_utils (storage)

    //bit [7:0] mem [int];
    storage_t stg_cl;
    int addr_int;

    function new (string name, uvm_component parent=null);
        super.new (name, parent);
   endfunction: new

   function void write (int addr, bit [7:0] value);
    stg_cl.mem[addr] = value;
   endfunction: write

   function bit[7:0] read (bit [31:0] addr);
    addr_int = $unsigned(addr);
    if (stg_cl.mem.exists(addr_int))begin
        return(stg_cl.mem[addr_int]);
    end else begin
        //mem[addr_int]=8'b0;
        return(8'b0);
    end
   endfunction: read

   function storage_t read_all();
       return(stg_cl);
   endfunction: read_all


endclass: storage




//class storage extends uvm_component;
//    `uvm_component_utils (storage)
//
//    //bit [7:0] mem [int];
//    storage_t stg_cl;
//    int addr_int;
//
//    int addr_queue [$];
//    bit [7:0] data_queue[$];
//    int temp_addr;
//
//    function new (string name, uvm_component parent=null);
//        super.new (name, parent);
//   endfunction: new
//
//   function void write (int addr, bit [7:0] value);
//    //stg_cl.mem[addr] = value;
//   addr_queue.push_back(addr);
//   data_queue.push_back(value);
//
//   if (addr_queue.size()>=2)begin
//    stg_cl.mem[addr_queue.pop_front()] = data_queue.pop_front();
//   end
//   endfunction: write
//
//   function bit[7:0] read (bit [31:0] addr);
//    addr_int = $unsigned(addr);
//    temp_addr = addr_queue.pop_front();
//    `uvm_info("SCB", $sformatf("direccion que se va a leer %h, direccion que se sacó de la cola %h", addr_int, temp_addr), UVM_LOW)
//
//   if (addr_int == temp_addr ||
//       addr_int == (temp_addr +1) ||
//       addr_int == (temp_addr +2) ||
//       addr_int == (temp_addr +3) ||
//       addr_int == (temp_addr -1) ||
//       addr_int == (temp_addr -2) ||
//       addr_int == (temp_addr -3) )begin
//
//        data_queue.pop_front();
//        if (stg_cl.mem.exists(addr_int))begin
//           return(stg_cl.mem[addr_int]);
//        end else begin
//            //mem[addr_int]=8'b0;
//            return(8'b0);
//        end
//    end else begin
//        stg_cl.mem[temp_addr] = data_queue.pop_front();
//        `uvm_info("SCB", $sformatf("la direccion no es igual, escribiendo a la siguiente direccion %h",  temp_addr), UVM_LOW)
//        if (stg_cl.mem.exists(addr_int))begin
//            return(stg_cl.mem[addr_int]);
//         end else begin
//             //mem[addr_int]=8'b0;
//             return(8'b0);
//         end
//    end
//   endfunction: read
//
//   function storage_t read_all();
//       return(stg_cl);
//   endfunction: read_all
//
//
//endclass: storage
