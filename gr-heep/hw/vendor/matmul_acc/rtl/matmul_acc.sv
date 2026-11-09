// Copyright 2026 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Matrix multiplication accelerator: C = A x B, with A and B N x N and C int32.
// B is stored transposed, so rows of A and of B^T are both read as consecutive words.
// The elements are packed in 32-bit words (MODE: 4 x int8, 2 x int16 or 1 x int32) and
// each word pair feeds a packed SIMD dot product.
// For each row of A: the row is loaded once into a local buffer, then every row of B^T is
// streamed (one word per cycle) and each result is written to C.
// The CPU configures it through registers, the accelerator reads and writes memory through
// its OBI master port and raises an interrupt when done.

module matmul_acc
  import matmul_acc_reg_pkg::*;
#(
    parameter int unsigned MaxN = 128
) (
    input logic clk_i,
    input logic rst_ni,

    // Configuration registers
    input  xheep_reg_pkg::xheep_reg_req_t reg_req_i,
    output xheep_reg_pkg::xheep_reg_rsp_t reg_rsp_o,

    // Memory access
    output xheep_obi_pkg::xheep_obi_req_t obi_req_o,
    input  xheep_obi_pkg::xheep_obi_rsp_t obi_rsp_i,

    output logic intr_o
);

  localparam int unsigned CntW = $clog2(MaxN + 1);  // words in a row: up to MaxN (int32)
  localparam int unsigned IdxW = $clog2(MaxN);

  matmul_acc_reg2hw_t reg2hw;
  matmul_acc_hw2reg_t hw2reg;

  matmul_acc_reg_top #(
      .reg_req_t(xheep_reg_pkg::xheep_reg_req_t),
      .reg_rsp_t(xheep_reg_pkg::xheep_reg_rsp_t)
  ) matmul_acc_reg_top_i (
      .clk_i,
      .rst_ni,
      .reg_req_i,
      .reg_rsp_o,
      .reg2hw,
      .hw2reg,
      .devmode_i(1'b1)
  );

  typedef enum logic [1:0] {
    IDLE,
    LOAD_A,    // read a row of A into the buffer
    STREAM_B,  // read a row of B^T and accumulate
    WRITE_C    // write one element of C
  } state_e;

  typedef enum logic [1:0] {
    INT8  = 2'd0,
    INT16 = 2'd1,
    INT32 = 2'd2
  } mode_e;

  state_e state_q, state_d;
  logic [7:0] i_q, i_d, j_q, j_d;  // row and column of C
  logic [CntW-1:0] req_k_q, req_k_d, rsp_k_q, rsp_k_d;  // words requested / received in the row
  logic pending_q, pending_d;  // a request was granted, its response has not arrived yet
  logic [31:0] a_row_q, a_row_d, b_row_q, b_row_d, c_ptr_q, c_ptr_d;
  logic signed [31:0] acc_q, acc_d;
  logic [31:0] a_buf_q[MaxN];
  logic done, start, gnt, last_word;

  logic [7:0] n;
  mode_e mode;
  logic [CntW-1:0] row_words;  // words in a row of A or B^T
  assign n = reg2hw.size.q;
  assign mode = mode_e'(reg2hw.mode.q);
  always_comb begin
    unique case (mode)
      INT8:    row_words = CntW'(n >> 2);
      INT16:   row_words = CntW'(n >> 1);
      default: row_words = CntW'(n);
    endcase
  end

  assign start = reg2hw.ctrl.q & reg2hw.ctrl.qe & (state_q == IDLE);
  assign gnt = obi_req_o.req & obi_rsp_i.gnt;
  assign last_word = obi_rsp_i.rvalid & (rsp_k_q == row_words - CntW'(1));

  // Packed SIMD dot product of the buffered word of A and the incoming word of B^T
  logic [31:0] a_word, b_word;
  logic signed [31:0] dot;
  assign a_word = a_buf_q[rsp_k_q[IdxW-1:0]];
  assign b_word = obi_rsp_i.rdata;
  always_comb begin
    dot = '0;
    unique case (mode)
      INT8:
      for (int e = 0; e < 4; e++) begin
        dot += 32'($signed(a_word[8*e+:8])) * 32'($signed(b_word[8*e+:8]));
      end
      INT16:
      for (int e = 0; e < 2; e++) begin
        dot += 32'($signed(a_word[16*e+:16])) * 32'($signed(b_word[16*e+:16]));
      end
      default: dot = $signed(a_word) * $signed(b_word);
    endcase
  end

  // Memory requests: one per cycle, a new one as soon as the previous response arrives
  always_comb begin
    obi_req_o.req = 1'b0;
    obi_req_o.we = 1'b0;
    obi_req_o.be = 4'hF;
    obi_req_o.wdata = acc_q;
    obi_req_o.addr = c_ptr_q;
    unique case (state_q)
      LOAD_A: begin
        obi_req_o.req = (req_k_q < row_words) & (~pending_q | obi_rsp_i.rvalid);
        obi_req_o.addr = a_row_q + 32'({req_k_q, 2'b00});
      end
      STREAM_B: begin
        obi_req_o.req = (req_k_q < row_words) & (~pending_q | obi_rsp_i.rvalid);
        obi_req_o.addr = b_row_q + 32'({req_k_q, 2'b00});
      end
      WRITE_C: begin
        obi_req_o.req = ~pending_q;
        obi_req_o.we = 1'b1;
      end
      default: ;
    endcase
  end

  always_comb begin
    state_d = state_q;
    i_d = i_q;
    j_d = j_q;
    req_k_d = req_k_q + CntW'(gnt);
    rsp_k_d = rsp_k_q + CntW'(obi_rsp_i.rvalid & (state_q != WRITE_C));
    pending_d = gnt | (pending_q & ~obi_rsp_i.rvalid);
    a_row_d = a_row_q;
    b_row_d = b_row_q;
    c_ptr_d = c_ptr_q;
    acc_d = acc_q;
    done = 1'b0;

    unique case (state_q)
      IDLE: begin
        if (start) begin
          i_d = '0;
          j_d = '0;
          req_k_d = '0;
          rsp_k_d = '0;
          a_row_d = reg2hw.a_addr.q;
          b_row_d = reg2hw.b_addr.q;
          c_ptr_d = reg2hw.c_addr.q;
          acc_d = '0;
          if (n == '0) done = 1'b1;
          else state_d = LOAD_A;
        end
      end

      LOAD_A: begin
        if (last_word) begin
          req_k_d = '0;
          rsp_k_d = '0;
          state_d = STREAM_B;
        end
      end

      STREAM_B: begin
        if (obi_rsp_i.rvalid) acc_d = acc_q + dot;
        if (last_word) begin
          req_k_d = '0;
          rsp_k_d = '0;
          state_d = WRITE_C;
        end
      end

      WRITE_C: begin
        if (obi_rsp_i.rvalid) begin
          acc_d = '0;
          req_k_d = '0;
          rsp_k_d = '0;
          c_ptr_d = c_ptr_q + 32'd4;
          if (j_q + 8'd1 < n) begin  // next column
            j_d = j_q + 8'd1;
            b_row_d = b_row_q + 32'({row_words, 2'b00});
            state_d = STREAM_B;
          end else if (i_q + 8'd1 < n) begin  // next row
            j_d = '0;
            i_d = i_q + 8'd1;
            a_row_d = a_row_q + 32'({row_words, 2'b00});
            b_row_d = reg2hw.b_addr.q;
            state_d = LOAD_A;
          end else begin
            state_d = IDLE;
            done = 1'b1;
          end
        end
      end

      default: state_d = IDLE;
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q <= IDLE;
      i_q <= '0;
      j_q <= '0;
      req_k_q <= '0;
      rsp_k_q <= '0;
      pending_q <= 1'b0;
      a_row_q <= '0;
      b_row_q <= '0;
      c_ptr_q <= '0;
      acc_q <= '0;
    end else begin
      state_q <= state_d;
      i_q <= i_d;
      j_q <= j_d;
      req_k_q <= req_k_d;
      rsp_k_q <= rsp_k_d;
      pending_q <= pending_d;
      a_row_q <= a_row_d;
      b_row_q <= b_row_d;
      c_ptr_q <= c_ptr_d;
      acc_q <= acc_d;
    end
  end

  // Row buffer of A, no reset needed
  always_ff @(posedge clk_i) begin
    if (state_q == LOAD_A && obi_rsp_i.rvalid) a_buf_q[rsp_k_q[IdxW-1:0]] <= obi_rsp_i.rdata;
  end

  // Status, done flag and interrupt
  assign hw2reg.status.d = (state_q != IDLE);
  assign hw2reg.status.de = 1'b1;
  assign hw2reg.done.d = done;  // set at the end, cleared at start
  assign hw2reg.done.de = done | start;
  assign intr_o = reg2hw.done.q & reg2hw.irq_en.q;

endmodule
