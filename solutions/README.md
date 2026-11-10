# Solutions

Part 2: `part2/mcu-gen-config.py` and `part2/gr_heep_peripherals.sv.tpl`: copy them into `gr-heep/config/` and
`gr-heep/hw/gr-heep/`. The bitstreams in `../bitstreams/` are built from them.

## Expected results (Verilator, same RTL as the bitstreams)

GR-HEEP (cv32e40px), 32x32, checksum `0008dc8a` for every element type:

| Elements | `matmul_sw` | `matmul_hw` |
|----------|-------------|-------------|
| int8 | 334057 | 12753 |
| int16 | 334051 | 23284 |
| int32 | 302275 | 43345 |
