//////////////////////////////////////////////////////////////////////////////////////////
// Engineer:      Alessandra Dolmeta - alessandra.dolmeta@polito.it                     //
//                                                                                      //                            
// Design Name:    Top level module                                                     //
// File name:      keccak_top.sv                                                         //
// Language:       SystemVerilog                                                        //
//////////////////////////////////////////////////////////////////////////////////////////



module keccak_tightly_top 
  import cv32e40px_core_v_xif_pkg::*;
(
  input clk_i,
  input rst_ni,

  if_xif.coproc_compressed xif_compressed_if,
  if_xif.coproc_issue      xif_issue_if,
  if_xif.coproc_commit     xif_commit_if,
  if_xif.coproc_mem        xif_mem_if,
  if_xif.coproc_mem_result xif_mem_result_if,
  if_xif.coproc_result     xif_result_if
);


keccak_tightly_pkg::in_t rs_values;
keccak_tightly_pkg::out_t rd_values;
//result_to_commit;
keccak_tightly_pkg::keccak_insn select_insn;
logic [4:0] rd_idex, rd_excom;
logic [3:0] id_idex, id_excom;
logic [1:0] select_op;
logic save_rd;
logic done;
logic continued;
logic result_reg_en;

//not used
//*****COMPRESSED INTERFACE*********************************************
assign xif_compressed_if.compressed_ready = '0;
assign xif_compressed_if.compressed_resp = '0;
//*****MEMORY INTERFACE**************************************************
assign xif_mem_if.mem_valid = '0;
assign xif_mem_if.mem_req = '0;




id_stage id_stage_i (
  .clk_i,
  .rst_ni,

  .xif_issue_if(xif_issue_if),

  .rs_values_o(rs_values),
  .rd_o(rd_idex),
  .id_o(id_idex),
  .select_insn_o(select_insn), 
  .save_rd_o(save_rd),

  .done_o(done),
  .continued_o(continued),
  .result_reg_en_o(result_reg_en),

  .select_op_o(select_op)
);

keccak_tightly i_keccak_tightly (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    
    .rs_values_i(rs_values),
    .insn_i(select_insn),
    .result_reg_en_i(result_reg_en),
    .rd_values_o(rd_values)
);


generate
  always @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      rd_excom <= '0;
      id_excom <= '0;
    end else begin
      if (save_rd) begin
        rd_excom <= rd_idex;
        id_excom <= id_idex;
      end else begin
        rd_excom <= rd_excom;
        id_excom <= id_excom;
      end
    end
  end
endgenerate

//assign result_to_commit.rd1 = rd_values.rd1;
//assign result_to_commit.rd2 = rd_values.rd2;


commit_stage commit_stage_i (
  .clk_i,
  .rst_ni,

  .select_op_i(select_op),

  .rd_i(rd_excom),
  .id_i(id_excom),
  .result_i(rd_values),
  .insn_i(select_insn),
  .done_i(done),
  .continued_i(continued),

  .xif_result_if(xif_result_if)
);

endmodule
