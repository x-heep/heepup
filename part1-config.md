# Part 1: X-HEEP Hands-on

In X-HEEP, you can describe the microcontroller (MCU) that best suits your use case with a simple Python script that describes which peripherals are instantiated, what the bus architecture is, which CPU and instruction set extensions you want, etc. The `mcu-gen` tool, a modular framework built with Python classes, loads your configurations and renders the hardware and software source files for the MCU you described, along with the software libraries needed to build applications for it. Once that's done, you can write your applications, compile them with the provided `make` flow, and run them in RTL simulation or on one of the supported FPGA target boards.

In this part of the hands-on tutorial, you will learn how to write the MCU configuration and tailor it for different application use cases. This repository already instantiates the core part of X-HEEP (CPU, memory, peripherals) inside a chip-ready System on Chip (SoC) that also integrates a pad ring (GPIOs) to communicate with the external world. This system, called GR-HEEP, is meant to be the starting point for extending and deploying X-HEEP on silicon.

At the end of this section, you will have the necessary knowledge to move to the last part of the tutorial, where you will extend the generated MCU with an external accelerator.

## Prerequisites

To be able to follow this part, you must have access to the X-HEEP Python environment, the Verilator RTL simulator, and the _CORE-V_ RISC-V toolchain.
- If you are following the tutorial using one of the lab's computers, all of those requirements have already been installed for you.
- If you are following alone on your own laptop, you must have completed all the steps in the [setup](./part0-setup.md) part of this tutorial.

Once you have all the prerequisites, you are ready to start with the real stuff in the following sections.

First of all, let's jump into the `gr-heep` directory that contains all the files required to build our MCU and activate the `conda` environment that contains all the required dependencies to run the X-HEEP build system:

```bash
cd gr-heep
conda activate x-heep
```

You are now ready to get into the real stuff in following sections. _Happy HEEPing!_

## Hands-on 1: MCU configuration and RTL simulation (~1h)

### 1.1 Base configuration

The backbone of any MCU consists of the following components:
- A CPU to run your application code
- Some form of memory, most commonly on-chip SRAM, to hold the code and data for your application.
- Some communication peripherals to acquire or send data, control external actuators, etc.
- A _bus_ to expose memory and peripherals in the address space that the CPU can reach.

At first, we are going to use such a minimal configuration to run a simple _Hello world!_ application.

To speed up the process, we already prepared the configuration for you in [`gr-heep/config/custom.py`](./gr-heep/config/custom.py). Take a look at it and try to understand what each part describes. Pay particular attention to the lines describing the core components of the MCU:

```python
system.set_bus_type(BusType.onetoM)
system.set_cpu(cv32e20())
memory_ss.add_ram_banks([32] * 1)
```

These lines instruct the X-HEEP build system that we would like our MCU to have:
- A small and energy-efficient single-channel bus architecture where the memory requests from all the master ports (e.g., the CPU instruction and data interfaces) are routed through a single arbiter and address decoder.
- A minimal 2-stage RISC-V CPU, called `cv32e20`.
- A single memory bank with a 32kiB capacity to hold our application's code and data.

We can generate the hardware and software source files that implement the described MCU using the `mcu-gen` tool, which can be called using the dedicated `make` target. To do this, let's call `mcu-gen` providing the path to our MCU description:

```bash
make mcu-gen X_HEEP_CFG=config/custom.py
```

This command populates the templated RTL and C files with the correct modules and values from the `custom.py` configuration. You can take a look at how the rendered files appear by checking a couple of them, for example:
- The [`memory_subsystem.sv`](./gr-heep/hw/vendor/x-heep/hw/core-v-mini-mcu/memory_subsystem.sv), instantiating the specified number of memory banks from our configuration.
- The [`core_v_mini_mcu.h`](./gr-heep/sw/device/lib/runtime/core_v_mini_mcu.h), containing C definitions with the addresses of all the instantiated memory mapped peripherals and other useful definitions.

Once the MCU is generated, we can build the RTL simulation model where we can test our applications. To do that, we are using the open-source Verilator tool, invoked by the dedicated `make` target. Run:

```bash
make verilator-build
```

Finally, we need to build an application to run on our model. For this initial step, we are going to compile a simple [_Hello world_](./gr-heep/sw/applications/gr_heep_hello_world/main.c) application. Run:

```bash
make app PROJECT=gr_heep_hello_world
```

At this point, we are ready to run the RTL simulation. Run:

```bash
make verilator-opt # no waveform dump (faster)
#make verilator-run # enable waveform dump for debugging (slower)
```

You should then see information about the simulation and the output of the `printf()` on your screen:

```
Simulation finished after 17302 clock cycles
Program Finished with value 0
INFO: Running post_run script print_uart_log
Hello World from the GR-HEEP template repo!
```


### 1.2 More memory

Now that we know that our MCU works as expected, let's try to run a beefier application. Since everybody loves AI, let's use one of its fundamental building blocks as an example: the [_matrix multiplication_](./gr-heep/sw/applications/matmul/main.c).

Since we are not changing the hardware configuration, we just need to rebuild the software. Run:

```bash
make app PROJECT=matmul
```

If you did everything correctly, things should have broken... You should see some error message on the screen.

Inspect the log. _What happened?_

The key line is the following:

```
/tools/riscv/corev-openhw-gcc/bin/../lib/gcc/riscv32-corev-elf/14.1.0/../../../../riscv32-corev-elf/bin/ld: main.elf section `.bss' will not fit in region `ram1'
```

In human words, the toolchain, or more precisely the linker, is telling us that our application does not fit in our MCU's memory. Luckily, increasing the memory size is a simple one-line change in the configuration. Open [`gr-heep/config/custom.py`](./gr-heep/config/custom.py#L61) and change line 61 to instantiate two 32kiB memory banks:

```diff
-memory_ss.add_ram_banks([32] * 1)
+memory_ss.add_ram_banks([32] * 2)
```

Since we changed the hardware configuration, we need to re-generate the hardware and software source files and re-build the RTL simulation model. Run:

```bash
make mcu-gen X_HEEP_CFG=config/custom.py
make verilator-build
```

While the simulation model builds, check [`memory_subsystem.sv`](./gr-heep/hw/vendor/x-heep/hw/core-v-mini-mcu/memory_subsystem.sv). _What has changed?_

You should now see two memory banks instantiated in this file.

Now we should have enough memory to build the `matmul` application. Let's try again:

```bash
make app PROJECT=matmul
```

_Yikes!_ The simulation should complete successfully and report the number of cycles that the CPU took to execute the matrix multiplication:

```
Simulation finished after 17302 clock cycles
Program Finished with value 0
INFO: Running post_run script print_uart_log
Hello World from the GR-HEEP template repo!
```

All good, but 5 million clock cycles are a lot! Let's try to improve the execution time.

> [!NOTE]
> Note down the reported number of cycles in the table at the end of this document. 

_Can you guess what bottlenecks we are hitting?_

### 1.3 Better CPU and parallel bus architecture

As mentioned before, a CPU has (at least) two ports sending requests to the system bus: an _instruction_ port to fetch the application code from memory and a _data_ port to read and write data to/from the memory or the memory mapped peripherals. In a certain cycle, the CPU might try to both fetch new instructions and execute previously fetched data load or store instructions. 

However, our bus architecture can route only one master request at a time, regardless of the addresses that the masters are trying to access. This means that concurrent _instruction_ and _data_ requests are serialized and executed in different clock cycles, stalling the CPU.

To improve performance, let's change the bus architecture to support multiple master requests at the same time, switching to an M-to-N architecture. Change the following line in [`gr-heep/config/custom.py`](./gr-heep/config/custom.py#L61):

```diff
-system.set_bus_type(BusType.onetoM)
+system.set_bus_type(BusType.NtoM)
```

As we are here, let's also instantiate a faster CPU to bump the performance a little more. Modify the following line as well:
```diff
-system.set_cpu(cv32e20())
+system.set_cpu(cv32e40p(
        corev_pulp=True,
    ))
```

Again, let's re-build the hardware and software:
```bash
make mcu-gen X_HEEP_CFG=config/custom.py
make verilator-build
make app PROJECT=matmul
```

Once that's done, we can run the simulation again. Run:

```bash
make verilator-opt
```

Note the number of cycles. _What's the speedup that we obtained?_

### 1.4 Software optimization: SIMD instructions

The CPU that we instantiated in the last step supports DSP-like SIMD instructions that can process multiple 8-bit or 16-bit elements with a single instruction, besides supporting hardware loops and fused multiply-add instructions.

To make use of those features, we need to change the compiler settings to enable the ISA extensions. Let's recompile the application with those extensions and rerun the simulation:

```bash
make app PROJECT=matmul \
    ARCH=rv32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip
```

Again, what is the speedup that we obtained? Can you spot the new instructions in the disassembled executable in `gr-heep/sw/build/main.S`?

## Performance Record

| Config | Matmul Cycles |
|--------|---------------|
| 1.2    |               |
| 1.3    |               |
| 1.4    |               |
