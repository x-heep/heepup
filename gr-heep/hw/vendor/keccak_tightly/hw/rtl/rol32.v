//////////////////////////////////////////////////////////////////////////////////////////
// Engineer:      Alessandra Dolmeta - alessandra.dolmeta@polito.it                     //
//                                                                                      //
// Design Name:    Top level module                                                     //
// Project Name:   horcrux:                                                             //
//                 Tightly-coupled Accelerator for RISC-V                               //
// File name:      rol32.sv                                                             //
// Language:       SystemVerilog                                                        //
//                                                                                      //
// Description:    rol32 - instruction.                                                 //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

module rol32(
    input  wire [31:0] high,
    input  wire [31:0] low,
    input  wire [31:0]  offset,    
    output reg  [31:0] result1,    // MSB (upper 32 bits)
    output reg  [31:0] result2     // LSB (lower 32 bits)
);

    reg [63:0] ab;                 // Concatenated 64-bit value
    reg [63:0] leftShifted;
    reg [63:0] rightShifted;
    reg [63:0] result;

    always @(*) begin
        // Concatenate `a` and `b` to form a 64-bit value
        ab = {high, low};
        // Perform left shift by the offset
        leftShifted = ab << offset;
        // Perform right shift by (64 - offset)
        rightShifted = ab >> (64 - offset);
        // XOR the left and right shifted values
        result = leftShifted ^ rightShifted;

        // Extract the upper and lower 32 bits of the result
        result1 = result[63:32];    // Upper 32 bits
        result2 = result[31:0];     // Lower 32 bits
    end

endmodule
