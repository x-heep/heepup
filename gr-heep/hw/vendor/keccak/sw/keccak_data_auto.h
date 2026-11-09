// Generated register defines for keccak

#ifndef _KECCAK_REG_DEFS_
#define _KECCAK_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define KECCAK_PARAM_REG_WIDTH 32

// Shared buffer for input/output of Keccak module (common parameters)
#define KECCAK_DATA_DATA_FIELD_WIDTH 32
#define KECCAK_DATA_DATA_FIELDS_PER_REG 1
#define KECCAK_DATA_MULTIREG_COUNT 50

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_0_REG_OFFSET 0x0

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_1_REG_OFFSET 0x4

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_2_REG_OFFSET 0x8

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_3_REG_OFFSET 0xc

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_4_REG_OFFSET 0x10

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_5_REG_OFFSET 0x14

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_6_REG_OFFSET 0x18

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_7_REG_OFFSET 0x1c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_8_REG_OFFSET 0x20

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_9_REG_OFFSET 0x24

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_10_REG_OFFSET 0x28

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_11_REG_OFFSET 0x2c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_12_REG_OFFSET 0x30

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_13_REG_OFFSET 0x34

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_14_REG_OFFSET 0x38

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_15_REG_OFFSET 0x3c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_16_REG_OFFSET 0x40

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_17_REG_OFFSET 0x44

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_18_REG_OFFSET 0x48

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_19_REG_OFFSET 0x4c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_20_REG_OFFSET 0x50

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_21_REG_OFFSET 0x54

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_22_REG_OFFSET 0x58

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_23_REG_OFFSET 0x5c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_24_REG_OFFSET 0x60

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_25_REG_OFFSET 0x64

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_26_REG_OFFSET 0x68

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_27_REG_OFFSET 0x6c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_28_REG_OFFSET 0x70

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_29_REG_OFFSET 0x74

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_30_REG_OFFSET 0x78

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_31_REG_OFFSET 0x7c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_32_REG_OFFSET 0x80

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_33_REG_OFFSET 0x84

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_34_REG_OFFSET 0x88

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_35_REG_OFFSET 0x8c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_36_REG_OFFSET 0x90

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_37_REG_OFFSET 0x94

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_38_REG_OFFSET 0x98

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_39_REG_OFFSET 0x9c

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_40_REG_OFFSET 0xa0

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_41_REG_OFFSET 0xa4

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_42_REG_OFFSET 0xa8

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_43_REG_OFFSET 0xac

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_44_REG_OFFSET 0xb0

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_45_REG_OFFSET 0xb4

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_46_REG_OFFSET 0xb8

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_47_REG_OFFSET 0xbc

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_48_REG_OFFSET 0xc0

// Shared buffer for input/output of Keccak module
#define KECCAK_DATA_49_REG_OFFSET 0xc4

// Trigger the Keccak
#define KECCAK_CTRL_REG_OFFSET 0xc8
#define KECCAK_CTRL_START_BIT 0

// Contains status information about the Keccak
#define KECCAK_STATUS_REG_OFFSET 0xcc
#define KECCAK_STATUS_STATUS_BIT 0

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _KECCAK_REG_DEFS_
// End generated register defines for keccak