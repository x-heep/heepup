// Copyright 2026 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Driver of the matmul_acc accelerator. `base` is the address of its registers.

#ifndef MATMUL_ACC_H_
#define MATMUL_ACC_H_

#include <stdint.h>
#include "matmul_acc_regs.h"

static inline void matmul_acc_write(uint32_t base, uint32_t offset, uint32_t value)
{
    *(volatile uint32_t *)(base + offset) = value;
}

static inline uint32_t matmul_acc_read(uint32_t base, uint32_t offset)
{
    return *(volatile uint32_t *)(base + offset);
}

// Element type of A and B, packed in 32-bit words
typedef enum {
    MATMUL_ACC_INT8 = 0,   // 4 elements per word
    MATMUL_ACC_INT16 = 1,  // 2 elements per word
    MATMUL_ACC_INT32 = 2,  // 1 element per word
} matmul_acc_mode_t;

// Start C = A x B. a: N x N, bt: B transposed (N x N), both of type `mode`; c: N x N int32.
// N must be a multiple of 4 and at most 128, the matrices word aligned.
static inline void matmul_acc_start(uint32_t base, const void *a, const void *bt, int32_t *c,
                                    uint32_t n, matmul_acc_mode_t mode, int irq_en)
{
    matmul_acc_write(base, MATMUL_ACC_A_ADDR_REG_OFFSET, (uint32_t)a);
    matmul_acc_write(base, MATMUL_ACC_B_ADDR_REG_OFFSET, (uint32_t)bt);
    matmul_acc_write(base, MATMUL_ACC_C_ADDR_REG_OFFSET, (uint32_t)c);
    matmul_acc_write(base, MATMUL_ACC_SIZE_REG_OFFSET, n);
    matmul_acc_write(base, MATMUL_ACC_MODE_REG_OFFSET, mode);
    matmul_acc_write(base, MATMUL_ACC_IRQ_EN_REG_OFFSET, irq_en ? 1 : 0);
    matmul_acc_write(base, MATMUL_ACC_CTRL_REG_OFFSET, 1 << MATMUL_ACC_CTRL_START_BIT);
}

static inline int matmul_acc_is_done(uint32_t base)
{
    return matmul_acc_read(base, MATMUL_ACC_DONE_REG_OFFSET) & (1 << MATMUL_ACC_DONE_DONE_BIT);
}

// Clear DONE, and with it the interrupt.
static inline void matmul_acc_clear_done(uint32_t base)
{
    matmul_acc_write(base, MATMUL_ACC_DONE_REG_OFFSET, 1 << MATMUL_ACC_DONE_DONE_BIT);
}

#endif // MATMUL_ACC_H_
