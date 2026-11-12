// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: main.c
// Author: Michele Caon
// Date: 22/06/2023
// Description: Main file for the matrix multiplication application

#include <stdio.h>

#include "csr.h"
#include "fast_intr_ctrl.h"
#include "dma_sdk.h"
#include "timer_sdk.h"
#include "data.h"
#include "soc_ctrl.h"

data_t R_cpu[R_ROWS * R_COLS]; // Result computed by the CPU

// Software matrix multiplication
// NOTE: force alignment on 32-bit boundary to prevent the execution time from
// being affected by the amount of previous compressed instructions. This
// guarantees a stable baseline independent on the previous code.
void __attribute__((noinline, aligned(4))) cpuMatMul(data_t *A, data_t *B, data_t *R, unsigned int a_rows, unsigned int a_cols, unsigned int b_cols);

int main(void)
{
    unsigned int a_rows = A_ROWS;
    unsigned int a_cols = A_COLS;
    unsigned int b_cols = B_COLS;
    uint32_t cpu_cycles;
    
    // System initialization
    // ---------------------
    // Enable fast interrupts for DMA and PLIC
    if (enable_fast_interrupt(kDma_done_fic_e, true) != kFastIntrCtrlOk_e)
        return 1;
    
    // Initialize the timer
    timer_cycles_init();

    // Compute the matmul on the CPU
    // -----------------------------
    // Start the cycle counter
    timer_start();

    // Compute result on the CPU
    cpuMatMul(A, B, R_cpu, a_rows, a_cols, b_cols);

    // Stop the cycler counter
    cpu_cycles = timer_stop();

    // Print the number of CPU cycles
    printf("cycles: %u\n", cpu_cycles);

    // Return success
    return 0;
}

void cpuMatMul(data_t *A, data_t *B, data_t *R, unsigned int a_rows, unsigned int a_cols, unsigned int b_cols)
{
    for (unsigned int i = 0; i < a_rows; i++)
    {
        for (unsigned int j = 0; j < b_cols; j++)
        {
            R[i * b_cols + j] = 0;
            for (unsigned int k = 0; k < a_cols; k++)
            {
                R[i * b_cols + j] += A[i * a_cols + k] * B[k * b_cols + j];
            }
        }
    }
}
