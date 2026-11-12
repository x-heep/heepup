# Part 1: configure X-HEEP

X-HEEP is generated from a Python configuration, that is processed by the `mcu-gen` utility: CPU, bus, memory, peripherals and interrupts.
In this part you generate X-HEEP with the configurations provided by EPFL and compare them in simulation.

All commands run from `x-heep/`, with `conda activate x-heep`.

## Hands-on 1: configurations in simulation (10-15')

In this section of the tutorial you will experiment with different configuration of X-HEEP to see how its different parameters affect the performance of an application.

### 1.1 Base configuration

system.set_bus_type(BusType.onetoM)
system.set_cpu(cv32e20())
memory_ss.add_ram_banks([32] * 1)

make app PROJECT=gr_heep_hello_world

### 1.2 More memory
system.set_bus_type(BusType.onetoM)
system.set_cpu(cv32e20())
memory_ss.add_ram_banks([32] * 2)

make app PROJECT=matmul

### 1.3 Better CPU and parallel bus architecture
system.set_bus_type(BusType.NtoM)
system.set_cpu(cv32e40p())
memory_ss.add_ram_banks([32] * 2)

make app PROJECT=matmul

### 1.4 Software optimization: SIMD instructions
system.set_bus_type(BusType.NtoM)
system.set_cpu(cv32e40p(
        corev_pulp=True,
    ))
memory_ss.add_ram_banks([32] * 2)

make app PROJECT=matmul_sw \
    ARCH=rv32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip


#####################

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
