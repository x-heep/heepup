//////////////////////////////////////////////////////////////////////////////////////////
// Engineer:      Alessandra Dolmeta - alessandra.dolmeta@polito.it                     //
//                                                                                      //
// Design Name:    Top level module                                                     //
// Project Name:   keccak:                                                             //
//                 Tightly-coupled Accelerator for RISC-V                               //
// File name:      commit_stage.sv                                                      //
// Language:       SystemVerilog                                                        //
//                                                                                      //
// Description:    keccak commit_stage.                                                //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

module commit_stage
  import keccak_tightly_pkg::*;
  (
    input logic clk_i,
    input logic rst_ni,

    input logic [1:0] select_op_i,

    input logic [4:0] rd_i,
    input logic [3:0] id_i,
    input keccak_tightly_pkg::out_t result_i,
    input keccak_tightly_pkg::keccak_insn insn_i,
    input logic done_i,
    input logic continued_i,
    
    if_xif.coproc_result xif_result_if

);

  typedef enum logic [1:0] {
    IDLE_S,
    COMP_S
  } state_t;

  state_t present_state, next_state;

  always @(present_state, select_op_i) begin
    case (present_state)
      IDLE_S: begin
        if (select_op_i == 2'b01) begin 
          next_state = COMP_S;
        end else if (select_op_i == 2'b10) begin 
          next_state = COMP_S;
        end else 
          next_state = IDLE_S;
      end
      COMP_S: begin

        if (continued_i == 1'b0) begin
          next_state = IDLE_S;
        end else
          next_state = COMP_S;
        //if (done_i == 1'b1 && continued_i == 1'b0) begin
        //  next_state = IDLE_S;
        //end else if (done_i == 1'b1 && continued_i == 1'b1) begin
        //  next_state = COMP_S;
        //end else if (done_i == 1'b0 && continued_i == 1'b1) begin
        //  next_state = COMP_S;
        //end else
        //  next_state = IDLE_S;
          
      end
      default: next_state = IDLE_S;
    endcase
  end

  //always @(present_state) begin
  always_comb begin
    xif_result_if.result_valid = '0;
    xif_result_if.result.we = '0;
    xif_result_if.result.rd = '0;
    xif_result_if.result.id = '0;

    xif_result_if.result.ecsdata = '0;
    xif_result_if.result.exc = '0;
    xif_result_if.result.ecswe = '0;
    xif_result_if.result.exccode = '0;
    xif_result_if.result.err = '0;
    xif_result_if.result.dbg = '0;
    xif_result_if.result.data = result_i.rd1;

    case (present_state)
      IDLE_S: begin
      end
      COMP_S: begin
        if (done_i) begin
          xif_result_if.result_valid = '1;
          xif_result_if.result.we = done_i;
          xif_result_if.result.rd = rd_i;
          xif_result_if.result.id = id_i;
          //end
        end
      end
      default: ;
    endcase
  end

  always @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) present_state <= IDLE_S;
    else present_state <= next_state;
  end

endmodule
