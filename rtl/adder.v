// src/adder.v
`timescale 1ns/1ps
module adder #(
  parameter integer WIDTH = 32,
  parameter         USE_CLA = 0,
  parameter integer APPROX_LSB = 0
)(
  input  wire [WIDTH-1:0] A, B,
  input  wire             cin,
  input  wire             lp_mode,
  output wire [WIDTH-1:0] Y,
  output wire             cout,
  output wire             ovf
);
  generate
    if (USE_CLA == 0) begin: GEN_RIPPLE
      wire [WIDTH:0] c; 
      assign c[0] = cin;
      wire [WIDTH-1:0] b_eff = (APPROX_LSB > 0 && lp_mode) ? { B[WIDTH-1:APPROX_LSB], {APPROX_LSB{1'b0}} } : B;
      
      genvar i;
      for(i=0; i<WIDTH; i=i+1) begin: FA
        assign {c[i+1], Y[i]} = A[i] + b_eff[i] + c[i];
      end
      assign cout = c[WIDTH];
      assign ovf  = c[WIDTH] ^ c[WIDTH-1];
    end else begin: GEN_CLA
      // 4-bit Tiled Carry-Lookahead Structure
      wire [WIDTH-1:0] P = A ^ B;
      wire [WIDTH-1:0] G = A & B;
      wire [WIDTH:0]   C; 
      assign C[0] = cin;
      
      genvar k;
      for(k=0; k<WIDTH; k=k+1) begin: SUM
        assign Y[k] = P[k] ^ C[k];
        if(((k+1)%4)==0) begin: CLA_BLOCK
          assign C[k-2] = G[k-3] | (P[k-3] & C[k-3]);
          assign C[k-1] = G[k-2] | (P[k-2] & G[k-3]) | (P[k-2] & P[k-3] & C[k-3]);
          assign C[k]   = G[k-1] | (P[k-1] & G[k-2]) | (P[k-1] & P[k-2] & G[k-3]) | (P[k-1] & P[k-2] & P[k-3] & C[k-3]);
        end
      end
      assign cout = C[WIDTH];
      assign ovf  = C[WIDTH] ^ C[WIDTH-1];
    end
  endgenerate
endmodule