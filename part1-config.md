# Part 1: configure X-HEEP

X-HEEP is generated from a Python configuration (`mcu-gen`): CPU, bus, memory, peripherals and interrupts.
In this part you generate X-HEEP with the configurations provided by EPFL and compare them in simulation.

All commands run from `x-heep/`, with `conda activate x-heep`.

## Hands-on 1: configurations in simulation (10-15')

To see the cycles in simulation, first set `PRINTF_IN_SIM` to `1` in `sw/applications/example_matmul/main.c`.

For each configuration:

```bash
make mcu-gen X_HEEP_CFG=<config>.py   # check the summary it prints: CPU, bus, memory banks
make verilator-build
make app PROJECT=example_matmul
make verilator-run
```

Expected: `program finished with 0 errors and <N> cycles`. Write down `<N>`.

With a cv32e40px CPU, use its XPULP SIMD kernel:

```bash
make app PROJECT=example_matmul \
    ARCH=rv32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip \
    COMPILER_FLAGS="-D__COREV_OPT_ASM -DMATMUL8"
```

| Config | Cycles |
|--------|--------|
| | |
| | |
| | |

Question: which change makes the difference, the CPU, the bus or the memory? Why?
