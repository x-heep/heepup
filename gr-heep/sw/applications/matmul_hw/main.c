// C = A x B on the matmul_acc accelerator, with A and B int8, int16 or int32 (N x N)
// and C int32, checked against the software result. B is stored transposed.

#include <stdint.h>
#include <stdio.h>

#include "core_v_mini_mcu.h"
#include "csr.h"
#include "gr_heep.h"
#include "matmul_acc.h"
#include "rv_plic.h"

#define N 32
#define ACC MATMUL_PERIPH_START_ADDRESS
#define ACC_IRQ EXT_INTR_0

// The same values (int8 range) in the three element types, as in matmul_sw
int8_t a8[N * N] __attribute__((aligned(4))), bt8[N * N] __attribute__((aligned(4)));
int16_t a16[N * N] __attribute__((aligned(4))), bt16[N * N] __attribute__((aligned(4)));
int32_t a32[N * N], bt32[N * N];
int32_t c_hw[N * N], c_ref[N * N];

volatile int acc_done = 0;

static void init_matrices(void)
{
    uint32_t x = 1;
    for (int i = 0; i < N * N; i++) {
        x = x * 1103515245 + 12345;
        a8[i] = a16[i] = a32[i] = (int8_t)(x >> 24);
        x = x * 1103515245 + 12345;
        bt8[i] = bt16[i] = bt32[i] = (int8_t)(x >> 24);
    }
}

static void matmul_ref(void)
{
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            int32_t acc = 0;
            for (int k = 0; k < N; k++) acc += a8[i * N + k] * bt8[j * N + k];
            c_ref[i * N + j] = acc;
        }
    }
}

static void isr_matmul_acc(uint32_t id)
{
    matmul_acc_clear_done(ACC);
    acc_done = 1;
}

static void enable_acc_interrupt(void)
{
    plic_Init();
    plic_irq_set_priority(ACC_IRQ, 1);
    plic_irq_set_enabled(ACC_IRQ, kPlicToggleEnabled);
    plic_assign_external_irq_handler(ACC_IRQ, isr_matmul_acc);
    CSR_SET_BITS(CSR_REG_MIE, 1 << 11);  // machine external interrupts
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);  // global interrupts
}

static uint32_t cycles(void)
{
    uint32_t t;
    CSR_READ(CSR_REG_MCYCLE, &t);
    return t;
}

// Run the accelerator, check the result, return the number of errors
static int run(const char *name, const void *a, const void *bt, matmul_acc_mode_t mode)
{
    for (int i = 0; i < N * N; i++) c_hw[i] = 0;
    acc_done = 0;

    uint32_t t = cycles();
    matmul_acc_start(ACC, a, bt, c_hw, N, mode, 1);
    // Busy wait for the interrupt handler: with wfi the core clock stops and mcycle with it.
    while (!acc_done) {
    }
    t = cycles() - t;

    int errors = 0;
    uint32_t checksum = 0;
    for (int i = 0; i < N * N; i++) {
        if (c_hw[i] != c_ref[i]) errors++;
        checksum += (uint32_t)c_hw[i];
    }
    printf("HW %s %dx%d: %u cycles, checksum %08x, %d errors\n", name, N, N, (unsigned)t,
           (unsigned)checksum, errors);
    return errors;
}

int main(void)
{
    init_matrices();
    matmul_ref();
    enable_acc_interrupt();
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);

    int errors = run("int8 ", a8, bt8, MATMUL_ACC_INT8);
    errors += run("int16", a16, bt16, MATMUL_ACC_INT16);
    errors += run("int32", a32, bt32, MATMUL_ACC_INT32);
    return errors;
}
