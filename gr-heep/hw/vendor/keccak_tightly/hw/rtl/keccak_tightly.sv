/////////////////////////////////////////////////////////////////////////////////
//
// Auth: Valeria Piscopo - Politecnico di Torino
// Date: October 2024
// Desc: Generate the keccak system depending on which algorithms are going to be
//       run
//
/////////////////////////////////////////////////////////////////////////////////

module keccak_tightly
  import cv32e40px_core_v_xif_pkg::*;
  import keccak_tightly_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,

    input keccak_tightly_pkg::in_t rs_values_i,
    input keccak_tightly_pkg::keccak_insn insn_i,
    input logic result_reg_en_i,
    output keccak_tightly_pkg::out_t rd_values_o
);

  //--------always-present signals declarations ----------------------------------------------------------------------------
  keccak_tightly_pkg::out_t out;
  logic [31:0] a1, b1, c1;


  //-------- input declarations ---------------------------------------------------------------------------
  assign a1 = rs_values_i.rs1_0;
  assign b1 = rs_values_i.rs2_0;
  assign c1 = rs_values_i.rs3_0;

  //-------- blocks instantiations ---------------------------------------------------------------------------
  logic [31:0] rol32_1_result, rol32_2_result;
  logic [31:0] result_reg;
  rol32 rol32_inst (
      .high(b1),
      .low(a1),
      .offset(c1),
      .result1(rol32_1_result),
      .result2(rol32_2_result)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        result_reg <= 32'b0; // Reset the register to 0 on reset
      end else if (result_reg_en_i) begin
        result_reg <= rol32_2_result; // Update result_reg when enable is high
      end else begin
        result_reg <= result_reg;
      end
  end

  //-------- output assignment ---------------------------------------------------------------------------

  always_comb begin
    // Default assignment (optional)
    out.rd1 = '0;
    out.rd2 = '0;

    // Case statement to evaluate selector
    case (insn_i)
        keccak_tightly_pkg::nada: begin
          out.rd1 = '0;
          out.rd2 = '0;
        end
        keccak_tightly_pkg::rol32_1: begin
          out.rd2 = '0;
          out.rd1 = rol32_1_result;
        end
        keccak_tightly_pkg::rol32_2: begin
          out.rd2 = '0;
          out.rd1 = result_reg;
        end
    endcase
  end

  assign rd_values_o.rd1 = out.rd1;
  assign rd_values_o.rd2 = out.rd2;


endmodule
