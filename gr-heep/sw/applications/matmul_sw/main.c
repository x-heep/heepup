// C = A x B in software, with A and B int8, int16 or int32 (N x N) and C int32.
// B is stored transposed, as for the accelerator.

#include <stdint.h>
#include <stdio.h>

#include "csr.h"

#define N 32

// The same values (int8 range) in the three element types, as in matmul_hw
int8_t a8[N * N], bt8[N * N];
int16_t a16[N * N], bt16[N * N];
int32_t a32[N * N], bt32[N * N];
int32_t c[N * N];

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

#define MATMUL_SW(T)                                                            \
    static void matmul_sw_##T(const T *a, const T *bt, int32_t *c)              \
    {                                                                           \
        for (int i = 0; i < N; i++) {                                           \
            for (int j = 0; j < N; j++) {                                       \
                int32_t acc = 0;                                                \
                for (int k = 0; k < N; k++) acc += a[i * N + k] * bt[j * N + k]; \
                c[i * N + j] = acc;                                             \
            }                                                                   \
        }                                                                       \
    }
MATMUL_SW(int8_t)
MATMUL_SW(int16_t)
MATMUL_SW(int32_t)

static uint32_t cycles(void)
{
    uint32_t t;
    CSR_READ(CSR_REG_MCYCLE, &t);
    return t;
}

static uint32_t checksum(void)
{
    uint32_t s = 0;
    for (int i = 0; i < N * N; i++) s += (uint32_t)c[i];
    return s;
}

int main(void)
{
    uint32_t t;
    init_matrices();
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);

    t = cycles();
    matmul_sw_int8_t(a8, bt8, c);
    t = cycles() - t;
    printf("SW int8  %dx%d: %u cycles, checksum %08x\n", N, N, (unsigned)t, (unsigned)checksum());

    t = cycles();
    matmul_sw_int16_t(a16, bt16, c);
    t = cycles() - t;
    printf("SW int16 %dx%d: %u cycles, checksum %08x\n", N, N, (unsigned)t, (unsigned)checksum());

    t = cycles();
    matmul_sw_int32_t(a32, bt32, c);
    t = cycles() - t;
    printf("SW int32 %dx%d: %u cycles, checksum %08x\n", N, N, (unsigned)t, (unsigned)checksum());
    return 0;
}
