# matmul-acc

Matrix multiplication accelerator for [X-HEEP](https://github.com/x-heep/x-heep), to integrate with
[GR-HEEP](https://github.com/x-heep/gr-heep).

It computes `C = A x B`, with `A` and `B` `N x N` (`N` multiple of 4, at most `MaxN` = 128) and `C` int32.
The elements of `A` and `B` are packed in 32-bit words, chosen at run time with `MODE`:
4 x int8, 2 x int16 or 1 x int32. `B` is stored **transposed**, so rows of `A` and `B^T` are both read as
consecutive words.

For each row of `A`, the accelerator:
1. loads the row into a local buffer;
2. for each row of `B^T`, streams it one word per cycle (a new read as soon as the previous one returns)
   and accumulates the packed SIMD dot product with the buffered row;
3. writes the result to `C`.

## Interfaces

| Port | Type | Use |
|------|------|-----|
| `reg_req_i` / `reg_rsp_o` | `xheep_reg_pkg` register interface | configuration registers |
| `obi_req_o` / `obi_rsp_i` | `xheep_obi_pkg` OBI master | reads `A`, `B^T`, writes `C` |
| `intr_o` | level | high while `DONE` and `IRQ_EN` are set |

## Registers

Described in `data/matmul_acc.hjson`; `rtl/matmul_acc_reg_*.sv` and `sw/matmul_acc_regs.h` are generated with
`./regs-gen.sh <path-to-x-heep>`.

| Offset | Register | Description |
|--------|----------|-------------|
| `0x00` | `CTRL` | write 1 to `START` |
| `0x04` | `STATUS` | `BUSY` |
| `0x08` | `DONE` | set at the end, write 1 to clear (clears the interrupt) |
| `0x0C` | `IRQ_EN` | enable the interrupt |
| `0x10` | `A_ADDR` | address of `A` |
| `0x14` | `B_ADDR` | address of `B` transposed |
| `0x18` | `C_ADDR` | address of `C` |
| `0x1C` | `SIZE` | `N` |
| `0x20` | `MODE` | 0: int8, 1: int16, 2: int32 |

## Software

`sw/matmul_acc.h`: `matmul_acc_start()`, `matmul_acc_is_done()`, `matmul_acc_clear_done()`.
