// Generated register defines for matmul_acc

// Copyright information found in source file:
// Copyright 2026 Politecnico di Torino.

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _MATMUL_ACC_REG_DEFS_
#define _MATMUL_ACC_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define MATMUL_ACC_PARAM_REG_WIDTH 32

// Control
#define MATMUL_ACC_CTRL_REG_OFFSET 0x0
#define MATMUL_ACC_CTRL_START_BIT 0

// Status
#define MATMUL_ACC_STATUS_REG_OFFSET 0x4
#define MATMUL_ACC_STATUS_BUSY_BIT 0

// End of computation, also drives the interrupt
#define MATMUL_ACC_DONE_REG_OFFSET 0x8
#define MATMUL_ACC_DONE_DONE_BIT 0

// Interrupt enable
#define MATMUL_ACC_IRQ_EN_REG_OFFSET 0xc
#define MATMUL_ACC_IRQ_EN_IRQ_EN_BIT 0

// Address of A (N x N, row-major, word aligned)
#define MATMUL_ACC_A_ADDR_REG_OFFSET 0x10

// Address of B transposed (N x N, row-major, word aligned)
#define MATMUL_ACC_B_ADDR_REG_OFFSET 0x14

// Address of C (N x N int32, row-major)
#define MATMUL_ACC_C_ADDR_REG_OFFSET 0x18

// Matrix size N, multiple of 4, at most 128
#define MATMUL_ACC_SIZE_REG_OFFSET 0x1c
#define MATMUL_ACC_SIZE_SIZE_MASK 0xff
#define MATMUL_ACC_SIZE_SIZE_OFFSET 0
#define MATMUL_ACC_SIZE_SIZE_FIELD \
  ((bitfield_field32_t) { .mask = MATMUL_ACC_SIZE_SIZE_MASK, .index = MATMUL_ACC_SIZE_SIZE_OFFSET })

// Element type of A and B (packed SIMD)
#define MATMUL_ACC_MODE_REG_OFFSET 0x20
#define MATMUL_ACC_MODE_MODE_MASK 0x3
#define MATMUL_ACC_MODE_MODE_OFFSET 0
#define MATMUL_ACC_MODE_MODE_FIELD \
  ((bitfield_field32_t) { .mask = MATMUL_ACC_MODE_MODE_MASK, .index = MATMUL_ACC_MODE_MODE_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _MATMUL_ACC_REG_DEFS_
// End generated register defines for matmul_acc