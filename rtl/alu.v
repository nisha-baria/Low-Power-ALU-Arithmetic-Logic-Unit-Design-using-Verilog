// src/alu.v
`timescale 1ns/1ps
module alu #(
  parameter integer WIDTH = 32,
  parameter         USE_CLA = 0,     // 0:ripple, 1:carry-lookahead
  parameter         APPROX_LSB = 0   // 0:exact, N>0: approximate N LSBs
)(
  input  wire                  clk,
  input  wire                  rst_n,
  input  wire                  en,        // Clock-enable (RTL Clock Gating)
  input  wire                  lp_mode,   // Low-power mode hint
  input  wire [WIDTH-1:0]      A,
  input  wire [WIDTH-1:0]      B,
  input  wire [3:0]            OPC,
  output reg  [WIDTH-1:0]      Y,
  output reg                   Z, N, C, V
);

  // --- Opcode decodes for operand isolation ---
  wire do_add  = (OPC == 4'b0000);
  wire do_sub  = (OPC == 4'b0001);
  wire do_and  = (OPC == 4'b0010);
  wire do_or   = (OPC == 4'b0011);
  wire do_xor  = (OPC == 4'b0100);
  wire do_nor  = (OPC == 4'b0101);
  wire do_sll  = (OPC == 4'b0110);
  wire do_srl  = (OPC == 4'b0111);
  wire do_sra  = (OPC == 4'b1000);
  wire do_slt  = (OPC == 4'b1001);
  wire do_a    = (OPC == 4'b1010);
  wire do_b    = (OPC == 4'b1011);

  // --- OPERAND ISOLATION: Gate inputs of inactive blocks to save dynamic power ---
  wire [WIDTH-1:0] A_add  = (do_add | do_sub) ? A : {WIDTH{1'b0}};
  wire [WIDTH-1:0] B_add  = (do_add | do_sub) ? B : {WIDTH{1'b0}};
  wire [WIDTH-1:0] A_log  = (do_and | do_or | do_xor | do_nor) ? A : {WIDTH{1'b0}};
  wire [WIDTH-1:0] B_log  = (do_and | do_or | do_xor | do_nor) ? B : {WIDTH{1'b0}};
  wire [WIDTH-1:0] A_sh   = (do_sll | do_srl | do_sra) ? A : {WIDTH{1'b0}};
  wire [WIDTH-1:0] B_sh   = (do_sll | do_srl | do_sra) ? B : {WIDTH{1'b0}};

  // --- Adder / Subtractor Instance ---
  wire [WIDTH-1:0] addB   = do_sub ? ~B_add : B_add;
  wire             cin    = do_sub ? 1'b1 : 1'b0;
  wire [WIDTH-1:0] sum;
  wire             cout, v_of;

  adder #(.WIDTH(WIDTH), .USE_CLA(USE_CLA), .APPROX_LSB(APPROX_LSB)) 
  u_adder (.A(A_add), .B(addB), .cin(cin), .Y(sum), .cout(cout), .ovf(v_of), .lp_mode(lp_mode));

  // --- Logic Unit ---
  wire [WIDTH-1:0] y_and = A_log & B_log;
  wire [WIDTH-1:0] y_or  = A_log | B_log;
  wire [WIDTH-1:0] y_xor = A_log ^ B_log;
  wire [WIDTH-1:0] y_nor = ~(A_log | B_log);

  // --- Shifter (Low-power masking: restrict to 1-bit step when lp_mode active) ---
  wire [4:0] shamt = lp_mode ? 5'd1 : B_sh[4:0];
  wire [WIDTH-1:0] y_sll = A_sh << shamt;
  wire [WIDTH-1:0] y_srl = A_sh >> shamt;
  wire [WIDTH-1:0] y_sra = $signed(A_sh) >>> shamt;

  // --- Comparator ---
  wire [WIDTH-1:0] y_slt = ($signed(A) < $signed(B)) ? {{(WIDTH-1){1'b0}},1'b1} : {WIDTH{1'b0}};

  // --- Output Combinational MUX ---
  reg [WIDTH-1:0] y_next;
  always @(*) begin
    case (OPC)
      4'b0000: y_next = sum;
      4'b0001: y_next = sum;
      4'b0010: y_next = y_and;
      4'b0011: y_next = y_or;
      4'b0100: y_next = y_xor;
      4'b0101: y_next = y_nor;
      4'b0110: y_next = y_sll;
      4'b0111: y_next = y_srl;
      4'b1000: y_next = y_sra;
      4'b1001: y_next = y_slt;
      4'b1010: y_next = A;
      4'b1011: y_next = B;
      default: y_next = {WIDTH{1'b0}};
    endcase
  end

  // --- Flag Generation ---
  wire Z_n = (y_next == {WIDTH{1'b0}});
  wire N_n = y_next[WIDTH-1];
  wire C_n = (do_add | do_sub) ? cout : 1'b0;
  wire V_n = (do_add | do_sub) ? v_of : 1'b0;

  // --- Synchronous Output Registers with Clock Gating (`en`) ---
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      Y <= {WIDTH{1'b0}}; Z <= 1'b0; N <= 1'b0; C <= 1'b0; V <= 1'b0;
    end else if (en) begin
      Y <= y_next; Z <= Z_n; N <= N_n; C <= C_n; V <= V_n;
    end
  end
endmodule