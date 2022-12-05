// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

wire clk;
wire [7:0] A,B;
wire [2:0] op;
wire [7:0] R;
assign {clk,A,B,op} = io_in[`MPRJ_IO_PADS-1:18];
assign io_out[`MPRJ_IO_PADS-1:30] = R;

iiitb_alu instance(clk,A,B,op,R);

endmodule

module iiitb_alu(
clk,
A,
B,
op,
R   );
    
//inputs,outputs and internal variables declared here
input clk;
input [7:0] A,B;
input [2:0] op;
output [7:0] R;
wire [7:0] Reg1,Reg2;
reg [7:0] Reg3;
    
//Assign A and B to internal variables for doing operations
assign Reg1 = A;
assign Reg2 = B;
//Assign the output 
assign R = Reg3;

//Always block with inputs in the sensitivity list.
always @(posedge clk)
begin
case (op)
0 : Reg3 = Reg1 + Reg2;  //addition
1 : Reg3 = Reg1 - Reg2; //subtraction
2 : Reg3 = ~Reg1;  //NOT gate
3 : Reg3 = ~(Reg1 & Reg2); //NAND gate 
4 : Reg3 = ~(Reg1 | Reg2); //NOR gate               
5 : Reg3 = Reg1 & Reg2;  //AND gate
6 : Reg3 = Reg1 | Reg2;  //OR gate    
7 : Reg3 = Reg1 ^ Reg2; //XOR gate  
endcase 
end
    
endmodule
    
`default_nettype wire
