///////////////////////////////////////////////////////////////////////////////////
//
// Auth: Valeria Piscopo - Politecnico di Torino
// Date: October 2024
// Desc: Generate the keccak system depending on which algorithms are going to be
//       run
//
//////////////////////////////////////////////////////////////////////////////////

package keccak_tightly_pkg;

localparam KYBER      = 1;        // KYBER Algorithm
localparam DILITHIUM  = 1;        // DILITHIUM Algorithm
localparam HQC        = 0;        // HQC Algorithm
localparam FALCON     = 0;        // FALCON Algorithm
localparam SPHINCS    = 0;        // SPHINCS+ Algorithm
localparam ASCON      = 0;        // ASCON Algorithm

// Opcode of the new instruction
typedef enum logic [6:0] {
  nada         = 7'b0000000,
  montg_k      = 7'b0000001,
  montg_d      = 7'b0000010,
  barrett      = 7'b0000011,
  rol32_1      = 7'b0000100,
  rol32_2      = 7'b0000101,
  bcop32       = 7'b0000110
} keccak_insn;


// funct3 for keccak_R intruction
typedef enum logic [2:0] {
  OP_R_R0 = 3'b000, //0
  OP_R_R1 = 3'b001, //1
  OP_R_R2 = 3'b010, //2
  OP_R_R3 = 3'b011, //3
  OP_R_R4 = 3'b100, //4
  OP_R_R5 = 3'b101, //5
  OP_R_R6 = 3'b110, //6
  OP_R_R7 = 3'b111  //7
} keccak_r_op;

// funct2 for keccak_R4 intruction
typedef enum logic [1:0] {
  OP_R4_R0 = 2'b00, //1
  OP_R4_R1 = 2'b01, //1
  OP_R4_R2 = 2'b10, //2
  OP_R4_R3 = 2'b11 //3
} keccak_r4_op;

// Mode of operation of keccak
typedef enum logic [6:0] {
  FUNCT7_0         = 7'b0000000, //0
  FUNCT7_1         = 7'b0000001, //1
  FUNCT7_2         = 7'b0000010, //2
  FUNCT7_3         = 7'b0000011, //3
  FUNCT7_4         = 7'b0000100, //4
  FUNCT7_5         = 7'b0000101, //5
  FUNCT7_6         = 7'b0000110, //6
  FUNCT7_7         = 7'b0000111, //7
  FUNCT7_8         = 7'b0001000, //8
  FUNCT7_9         = 7'b0001001, //9
  FUNCT7_10        = 7'b0001010, //10
  FUNCT7_11        = 7'b0001011, //11
  FUNCT7_12        = 7'b0001100, //12
  FUNCT7_13        = 7'b0001101, //13
  FUNCT7_14        = 7'b0001110, //14
  FUNCT7_15        = 7'b0001111, //15
  FUNCT7_16        = 7'b0010000, //16
  FUNCT7_17        = 7'b0010001, //17
  FUNCT7_18        = 7'b0010010, //18
  FUNCT7_19        = 7'b0010011, //19
  FUNCT7_20        = 7'b0010100, //20
  FUNCT7_21        = 7'b0010101, //21
  FUNCT7_22        = 7'b0010110, //22
  FUNCT7_23        = 7'b0010111, //23
  FUNCT7_24        = 7'b0011000, //24
  FUNCT7_25        = 7'b0011001, //25
  FUNCT7_26        = 7'b0011010, //26
  FUNCT7_27        = 7'b0011011, //27
  FUNCT7_28        = 7'b0011100, //28
  FUNCT7_29        = 7'b0011101, //29
  FUNCT7_30        = 7'b0011110, //30
  FUNCT7_31        = 7'b0011111, //31
  FUNCT7_32        = 7'b0100000, //32
  FUNCT7_33        = 7'b0100001, //33
  FUNCT7_34        = 7'b0100010, //34
  FUNCT7_35        = 7'b0100011, //35
  FUNCT7_36        = 7'b0100100, //36
  FUNCT7_37        = 7'b0100101, //37
  FUNCT7_38        = 7'b0100110, //38
  FUNCT7_39        = 7'b0100111 //39
} keccak_funct7;

// funct3 for keccak_I intruction
typedef enum logic [2:0] {
  FUNCT3_1   = 3'b001,
  FUNCT3_2   = 3'b010,
  FUNCT3_3   = 3'b011,
  FUNCT3_4   = 3'b100,
  FUNCT3_5   = 3'b101,
  FUNCT3_6   = 3'b110,
  FUNCT3_7   = 3'b111
} keccak_funct3;

// New instruction definition
typedef union packed {
  struct packed {
    keccak_funct7 funct7;  // 31:25
    logic [4:0] rs2;     // 24:20
    logic [4:0] rs1;     // 19:15
    keccak_r_op funct3;  // 14:12
    logic [4:0] rd;      // 11:7
    logic [6:0] opcode;  // 6:0
  } as_keccak_R;
  struct packed {
    logic [4:0] rs3;  // 31:27
    keccak_r4_op funct2;  // 26:25
    logic [4:0] rs2;     // 24:20
    logic [4:0] rs1;     // 19:15
    keccak_funct3 funct3;  // 14:12
    logic [4:0] rd;      // 11:7
    logic [6:0] opcode;  // 6:0
  } as_keccak_R4;
  logic [31:0] raw;
} instruction_u;

// Opcode of the new instruction
typedef enum logic [6:0] {
  keccak_R  = 7'b0111011, //3b
  keccak_R4  = 7'b1101011 //6b
} keccak_op;



// State of the FSM of the controller
typedef enum logic [2:0] {
  RESET_S,
  WAIT_S,
  LOAD_S,
  KECCAK_S,
  PROCESS_S,
  COMPUTE_S,
  STORE_S,
  DONE_S
} controller_state_t;


typedef struct packed {
  logic [2:0] mode_keccak;
} mode_t;

typedef struct packed {
  logic [6:0] funct7_keccak;
} funct7_t;

typedef struct packed {
  logic [1:0] funct2_keccak;
} funct2_t;

typedef struct packed {
  logic [11:0] immediate_keccak;
} immediate_t;


typedef struct packed {
  logic [31:0] rs1_0;
  logic [31:0] rs2_0;
  logic [31:0] rs3_0;
  logic [31:0] rs1_1;
  logic [31:0] rs2_1;
  logic [31:0] rs3_1;
} in_t;

typedef struct packed {
    logic [31:0] rd1;
    logic [31:0] rd2;
} out_t;


endpackage
