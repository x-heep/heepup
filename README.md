# X-HEEP hands-on tutorial

Configure [X-HEEP](https://github.com/x-heep/x-heep), extend it with an accelerator through
[GR-HEEP](https://github.com/x-heep/gr-heep), and run everything in simulation and on a PYNQ-Z2.

| Part | Where | Time | Guide |
|------|-------|------|-------|
| 0. Setup and `hello_world` in simulation | at home, before the tutorial | ~1-2 h | [part0-setup.md](part0-setup.md) |
| 1. Configuration: simulation, then FPGA | lab | 10-15' + 10-15' | [part1-config.md](part1-config.md) |
| 2. Accelerator integration: simulation, then FPGA | lab | 15-20' + 15-20' | [part2-accelerator.md](part2-accelerator.md) |

## Repository layout

```
x-heep/        X-HEEP (submodule, b3eb3c8d)
gr-heep/       GR-HEEP (copy of 2a29e8a) with the Keccak accelerators already vendored
configs/       X-HEEP configurations A, B, C used in Part 1
exercises/     files you complete during the hands-on
solutions/     reference solutions
bitstreams/    ready-to-use PYNQ-Z2 bitstreams
scripts/       environment check and bitstream build
```

Clone with the submodules:

```bash
git clone --recursive https://github.com/x-heep/heepup.git
```
