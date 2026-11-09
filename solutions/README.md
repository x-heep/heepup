# Solutions

| Part | Files |
|------|-------|
| 1 | `part1/B.py`: config B (`make mcu-gen X_HEEP_CFG=../solutions/part1/B.py`) |
| 2 | `part2/mcu-gen-config.py` and `part2/gr_heep_peripherals.sv.tpl`: copy them into `gr-heep/config/` and `gr-heep/hw/gr-heep/` |

## Expected results (Verilator)

Part 1, `example_matmul` (32x32 int8):

| Config | Kernel | Cycles |
|--------|--------|--------|
| A | standard | 505073 |
| B | standard | 370932 |
| C | XPULP SIMD (`-D__COREV_OPT_ASM -DMATMUL8`) | 50707 |

Part 2, GR-HEEP (cv32e40px), 32x32, checksum `0008dc8a` for every element type:

| Elements | `matmul_sw` | `matmul_hw` |
|----------|-------------|-------------|
| int8 | 334057 | 12753 |
| int16 | 334051 | 23284 |
| int32 | 302275 | 43345 |
