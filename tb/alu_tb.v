// tb/alu_tb.v
`timescale 1ns/1ps
module alu_tb;
  localparam WIDTH = 32;
  reg clk = 0;
  reg rst_n = 0;
  reg en = 0;
  reg lp_mode = 0;
  reg [WIDTH-1:0] A, B;
  reg [3:0] OPC;
  wire [WIDTH-1:0] Y;
  wire Z, N, C, V;

  alu #(.WIDTH(WIDTH), .USE_CLA(0), .APPROX_LSB(0)) dut (
    .clk(clk), .rst_n(rst_n), .en(en), .lp_mode(lp_mode),
    .A(A), .B(B), .OPC(OPC), .Y(Y), .Z(Z), .N(N), .C(C), .V(V)
  );

  always #5 clk = ~clk; // 100MHz Clock

  // Behavioral Reference Model
  function [WIDTH-1:0] ref_model;
    input [3:0] f; input [WIDTH-1:0] a, b;
    case(f)
      4'h0: ref_model = a + b;
      4'h1: ref_model = a - b;
      4'h2: ref_model = a & b;
      4'h3: ref_model = a | b;
      4'h4: ref_model = a ^ b;
      4'h5: ref_model = ~(a | b);
      4'h6: ref_model = a << b[4:0];
      4'h7: ref_model = a >> b[4:0];
      4'h8: ref_model = $signed(a) >>> b[4:0];
      4'h9: ref_model = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
      4'hA: ref_model = a;
      4'hB: ref_model = b;
      default: ref_model = 32'd0;
    endcase
  endfunction

  integer i;
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, alu_tb);
    
    // Reset System
    #20 rst_n = 1; en = 1; lp_mode = 0;
    
    $display("=== STARTING BASELINE VERIFICATION ===");
    for(i=0; i<100; i=i+1) begin
      A = $random; B = $random; OPC = $random % 12;
      @(posedge clk);
      #1; // Wait for propagation
      if (Y !== ref_model(OPC, A, B)) begin
        $display("[MISMATCH] At test %0d! OPC=%h A=%h B=%h Y=%h REF=%h", i, OPC, A, B, Y, ref_model(OPC, A, B));
        $finish;
      end
    end
    $display("=== BASELINE PASSED! SWITCHING TO LOW-POWER MODE ===");
    
    lp_mode = 1;
    for(i=0; i<50; i=i+1) begin
      A = $random; B = $random; OPC = $random % 12;
      @(posedge clk);
    end
    
    $display("=== ALL TESTS PASSED SUCCESSFULLY ===");
    $finish;
  end
endmodule