//////////////////////////////////////////////////////////////////////////////////////////
// Engineer:      Alessandra Dolmeta - alessandra.dolmeta@polito.it                     //
//                                                                                      //
// Design Name:    Top level module                                                     //
// Project Name:   keccak:                                                             //
//                 Tightly-coupled Accelerator for RISC-V with Code-based Algorithms    //
// File name:      id_stage.sv                                                          //
// Language:       SystemVerilog                                                        //
//                                                                                      //
// Description:    keccak id_stage.                                                    //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////


module id_stage
  import keccak_tightly_pkg::*;
  (
    input clk_i,
    input rst_ni,

    if_xif.coproc_issue xif_issue_if,

    output keccak_tightly_pkg::in_t rs_values_o,
    output logic [4:0] rd_o,
    output logic [3:0] id_o,
    output keccak_tightly_pkg::keccak_insn select_insn_o,

    output logic save_rd_o,
    output logic done_o,
    output logic continued_o,
    output logic result_reg_en_o,

    output logic [1:0] select_op_o
);

  keccak_tightly_pkg::instruction_u instruction;
  keccak_tightly_pkg::in_t rs_values;
  keccak_tightly_pkg::keccak_insn select_insn;

  logic [1:0] select_op;
  logic sample_in;
  logic save_rd;
  logic result_reg_en;
  logic done;
  logic continued;

  assign instruction = xif_issue_if.issue_req.instr;

  // INSTRUCTION DECODER
  always_comb begin : decoder
    
    xif_issue_if.issue_resp.loadstore = '0;
    xif_issue_if.issue_resp.ecswrite = '0;
    xif_issue_if.issue_resp.exc = '0;
  
    xif_issue_if.issue_resp.accept = '0;
    xif_issue_if.issue_resp.writeback = '0;
    xif_issue_if.issue_resp.dualread = '0;
    xif_issue_if.issue_resp.dualwrite = '0;
    xif_issue_if.issue_resp.loadstore = '0;
    xif_issue_if.issue_resp.ecswrite = '0;
    xif_issue_if.issue_resp.exc = '0;


    xif_issue_if.issue_ready = '0;

    sample_in = '0;
    select_op = 2'b00;
    select_insn = nada;
    save_rd = '0;
    rs_values = '0;
    rd_o <= '0;
    id_o <= '0;

    if (xif_issue_if.issue_valid == 1'b1) begin
      case (instruction.raw[6:0])
      
        keccak_tightly_pkg::keccak_R: begin
          xif_issue_if.issue_ready = '1;
    
          xif_issue_if.issue_resp.accept = 1'b1;
          xif_issue_if.issue_resp.writeback = 1'b1;
          select_op = 2'b01;
          sample_in = '1;
          save_rd = '1;
    
          rs_values.rs1_0 = xif_issue_if.issue_req.rs[0];
          rs_values.rs2_0 = xif_issue_if.issue_req.rs[1];
          rs_values.rs3_0 = xif_issue_if.issue_req.rs[2];
    
          rd_o <= instruction.as_keccak_R.rd;
          id_o <= xif_issue_if.issue_req.id;
    
          if (instruction.as_keccak_R.funct7 == FUNCT7_1) begin
            if (instruction.as_keccak_R.funct3 == OP_R_R0) begin
              select_insn = montg_k;
            end else if (instruction.as_keccak_R.funct3 == OP_R_R1) begin
              select_insn = montg_d;
            end else if (instruction.as_keccak_R.funct3 == OP_R_R2) begin
              select_insn = barrett;
            end else begin
              select_insn = nada;
            end
          end
        end

        keccak_tightly_pkg::keccak_R4: begin
          xif_issue_if.issue_ready = '1;
    
          xif_issue_if.issue_resp.accept = 1'b1;
          xif_issue_if.issue_resp.writeback = 1'b1;
          select_op = 2'b10;
          sample_in = '1;
          save_rd = '1;
    
          rs_values.rs1_0 = xif_issue_if.issue_req.rs[0];
          rs_values.rs2_0 = xif_issue_if.issue_req.rs[1];
          rs_values.rs3_0 = xif_issue_if.issue_req.rs[2];
    
          rd_o <= instruction.as_keccak_R4.rd;
          id_o <= xif_issue_if.issue_req.id;
    
          if (instruction.as_keccak_R4.funct3 == FUNCT3_1) begin
            if (instruction.as_keccak_R4.funct2 == OP_R4_R0) begin
              select_insn = rol32_1;
            end else if (instruction.as_keccak_R4.funct2 == OP_R4_R1) begin
              select_insn = rol32_2;
            end else if (instruction.as_keccak_R4.funct2 == OP_R4_R2) begin
              select_insn = bcop32;
            end else begin
              select_insn = nada;
            end
          end
        end

    
        default: begin
          xif_issue_if.issue_resp.accept = 1'b0;
          select_insn = nada;
        end
      endcase
    end
  end
    

  always @(posedge clk_i or negedge rst_ni) begin : pipe_reg_ID_EX
    if (~rst_ni) begin
      rs_values_o <= '0;
      select_insn_o <= nada;
    end else begin
      //if (sample_in) begin
        rs_values_o <= rs_values;
        select_insn_o <= select_insn;
      //end
    end
  end

  //We have:
  // - done=1 and continue=1: not finished, but write
  // - done=1 and continue=0: finished, and write
  // - done=0 and continue=1: not finished, not write
  // - done=0 and continue=0: nothing
  generate
    always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        done       <= '0;
        continued  <= '0;
        result_reg_en <= '0;
      end else begin
        if (select_op== 2'b01) begin
          done      <= '1;
          continued <= '0;
          result_reg_en <= '0;
        end else if (select_op== 2'b10) begin
          done       <= '1;

          if (select_insn == keccak_tightly_pkg::rol32_1) begin
            continued     <= '1;
            result_reg_en <= '1;
          end 
          else if (select_insn == keccak_tightly_pkg::rol32_2) begin
            continued     <= '0;
            result_reg_en <= '0;
          end else begin
            done          <= '1;
            continued     <= '0;
            result_reg_en <= '0;
          end

        end else begin
          done       <= '0;
          continued  <= '0;
          result_reg_en <= '0;
        end
      end
    end
  endgenerate 


  assign save_rd_o       = save_rd;
  assign select_op_o     = select_op;
  assign result_reg_en_o = result_reg_en;
  assign done_o          = done;
  assign continued_o     = continued;

endmodule
