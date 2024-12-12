
`default_nettype none
module processor( input         clk, reset,
                  output [31:0] PC,
                  input  [31:0] instruction,
                  output        WE,
                  output [31:0] address_to_mem,
                  output [31:0] data_to_mem,
                  input  [31:0] data_from_mem
                );

wire [31:0] pc_next, result, srcA, immOp, srcB, imm_plus_pc, branchTarget, pc_plus4, address_skok;

wire regWrite, aluSource, zero, branchJalr, branchJalx, branchJal, memToReg, branchOutcome, branchBeq;

wire [2:0] immControl, aluControl;

pr_counter counter (pc_next, clk, reset, PC);

control_unit controlUnit ( instruction[31:0], branchBeq, branchJal, branchJalr, regWrite, memToReg, WE, aluSource, aluControl, immControl );

reg_file regFile (clk, regWrite, instruction[19:15], instruction[24:20], instruction[11:7], result, srcA, data_to_mem);

imm_dec immDec (instruction[31:7], immControl, immOp);

mux muxAlu (immOp, data_to_mem, aluSource, srcB);

alu alu ( srcA, srcB, aluControl, address_to_mem, zero );

assign imm_plus_pc = immOp + PC;

mux muxBranchtarget (address_to_mem, imm_plus_pc, branchJalr, branchTarget);

assign pc_plus4 = PC + 4;

assign branchJalx = (branchJal || branchJalr);

mux muxbranchJalx ( pc_plus4, address_to_mem, branchJalx, address_skok );

mux muxResult ( data_from_mem, address_skok, memToReg, result );

assign branchOutcome = ((branchBeq && zero) || branchJalx);

mux muxPcNext ( branchTarget, pc_plus4, branchOutcome, pc_next );


endmodule

// Program Counter
module pr_counter (input [31:0] pc_next, input clk, reset, output reg [31:0] pc);
always @ (posedge clk)
pc = reset ? 0 : pc_next;

endmodule


// Control Unit

module control_unit( input [31:0] instruction, output reg branchBeq, branchJal, branchJalr, regWrite, memToReg, memWrite, aluSource, output reg [2:0] aluControl, immControl );

wire [6:0] opcode;
assign opcode = instruction[6:0];

wire [2:0] funct3;
assign funct3 = instruction[14:12];
reg [6:0] funct7;


always@(*)
begin

aluSource = 0;
aluControl = 3'b000; // +
memWrite = 0;
memToReg = 0;
regWrite = 1;
branchBeq = 0;
branchJal = 0;
branchJalr = 0;
immControl = 3'b000;



if (opcode == 7'b0110011)             //typ R
begin
immControl = 3'b000;


if (funct3 == 3'b111) aluControl = 3'b001; // and

if (funct3 == 3'b101) aluControl = 3'b011; // srl

else 
begin
funct7 = instruction[31:25];
if (funct7 == 7'b0100000) aluControl = 3'b010; // sub
end
end

if (opcode == 7'b0010011)      //addi
begin
aluSource = 1; 
immControl = 3'b001;
end

if (opcode == 7'b0000011)     //lw
begin
aluSource = 1;
memToReg = 1;
immControl = 3'b001;
end

if (opcode == 7'b1100111)       //jalr
begin
aluSource = 1;
branchJalr = 1;
immControl = 3'b001;
end

if (opcode == 7'b1100011)     // typ B
begin
regWrite = 0;
immControl = 3'b010;
 
if (funct3 == 3'b000)        //beq
begin
aluControl = 3'b010;
branchBeq =1;
end

else 
begin
aluControl = 3'b100;     //blt
branchBeq = 1;
end
end

if (opcode == 7'b0100011)      // typ S, sw
begin
aluSource = 1;
memWrite = 1;
regWrite = 0;
immControl = 3'b011;
end

if (opcode == 7'b0110111)      // typ U (lui)
begin
aluSource = 1;
aluControl = 3'b101;
immControl = 3'b100;
end


if (opcode == 7'b1101111)      // typ J, jal
begin
branchJal = 1;
immControl = 3'b101;
end

if (opcode == 7'b0001011)     // floor_log
begin
aluControl = 3'b110;
end

end

endmodule

// Soubor 32 registrů

module reg_file( input clk, regWrite, input [4:0] a1,a2,a3, input [31:0] res, output [31:0] rd1, rd2 );

reg [31:0] reg_array[31:0];

assign rd1 = a1 ? reg_array[a1] : 0;
assign rd2 = a2 ? reg_array[a2] : 0;

always @(posedge clk)
if (regWrite) reg_array[a3] = res;
endmodule

// Imm. Decode

module imm_dec ( input [31:7] inst, input [2:0] immControl, output reg [31:0] immOp );

always @(*)

case (immControl)
3'b001: immOp = {{21{inst[31]}} , inst[30:20]}; // typ I
3'b010: immOp = {{20{inst[31]}} , inst[7], inst[30:25], inst[11:8], 1'b0} ; // typ B
3'b011: immOp = {{21{inst[31]}},inst[30:25], inst[11:7]}; // typ S
3'b100: immOp = {inst[31:12], {12{1'b0}}}; // typ U
3'b101: immOp = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // typ J
endcase

endmodule

// Multiplexor

module mux ( input [31:0] a, b, input select, output [31:0] y );
assign y = select ? a : b;
endmodule

// ALU 

module alu ( input [31:0] srcA, srcB, input [2:0] aluControl, output reg [31:0] aluOut, output reg zero );

reg[7:0] exponent;

always @ (*)
begin
case (aluControl)

3'b000: aluOut = (srcA + srcB); // add, addi, lw, sw, jal, jalr
3'b001: aluOut = (srcA & srcB); // and
3'b010: aluOut = (srcA - srcB); // sub, beq
3'b011: aluOut = (srcA >> srcB); // srl (unsigned)
3'b100: aluOut = ($signed(srcA) < $signed(srcB)) ? 0 : 1; // blt
3'b101: aluOut = srcB; // lui
3'b110: 
begin
exponent = srcA[30:23];
aluOut = exponent - 127;
end

endcase

if (!aluOut) zero =1;
else zero = 0;

end
endmodule



`default_nettype wire




