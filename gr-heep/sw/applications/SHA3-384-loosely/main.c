#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "fips202.h"
#include "core_v_mini_mcu.h"
#include "csr.h"


static void print_hex_digest(const uint8_t *buf, size_t len) {
    for (size_t i = 0; i < len; i++) {
        printf("%02X", buf[i]);
        if ((i + 1U) % 8U == 0U && i + 1U < len) {
            printf(" ");
        }
    }
    printf("\n");
}


static const uint8_t t_expected[48] = {
    0xB1, 0x3F, 0xEB, 0xB1, 0xB3, 0xC5, 0x4A, 0x7C,
    0x6B, 0x69, 0x36, 0x7F, 0x69, 0x3A, 0x1D, 0x1F,
    0x31, 0x45, 0x70, 0x9B, 0x6D, 0xDE, 0xF2, 0x3F,
    0xF1, 0x58, 0x74, 0x13, 0x3E, 0xA1, 0xFB, 0x9C,
    0xFA, 0x48, 0xEE, 0x7F, 0xF4, 0xEC, 0x9A, 0xA9,
    0x87, 0xDE, 0xA6, 0x41, 0xE3, 0x3C, 0xCD, 0xF7
};

int main(void) {
    
    int result = 0;
    uint8_t input[200];
    uint8_t t[48];

    unsigned int cycles, cycles2;


    for (int i = 0; i < 200; i++) {
        input[i] = i;
    }

    printf("SHA3-384 short one-shot validation\n");
    printf("[KECCAK-LOOSELY TEST]\n");

    /*
     * Call chain note:
     * sha3_384() is implemented in fips202.c (FIPS202 software path).
     * It performs absorb+squeeze and internally reaches KeccakF1600_StatePermute(),
     * which is the permutation driver foundation used by the keccak driver stack.
     */

    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    sha3_384(t, input, 200);

    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("Cycles (sha3_384 call): %u\n", cycles);
    

    for (int i = 0; i < 48; i++) {
        if (t[i] != t_expected[i]) {
            result = 1;
            printf("Expected t[%d] = 0x%02X, but got 0x%02X.\n", i, t_expected[i], t[i]);
        }
    }
    //printf("Digest (received): ");
    //print_hex_digest(t, sizeof(t));
    //printf("Digest (expected): ");
    //print_hex_digest(t_expected, sizeof(t_expected));

    if (result == 0) {
        printf("RESULT: PASS\n");
    } else {
        printf("RESULT: FAIL\n");
    }
    printf("Test: terminated\n");

    return result;
}
