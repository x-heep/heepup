# Part 1: configure X-HEEP

X-HEEP is generated from a Python configuration (`mcu-gen`). In this part you write one configuration,
measure a matrix multiplication in simulation, then compare three configurations on the PYNQ-Z2.

| Config | CPU | Bus | Memory |
|--------|-----|-----|--------|
| A (baseline) | cv32e20 | one-to-M | 4 x 32 KiB contiguous |
| B (you write it) | cv32e40p | N-to-M | 2 x 32 KiB contiguous + 4 x 16 KiB interleaved |
| C | cv32e40px + XPULP | N-to-M | as B |

All commands run from `x-heep/`, with `conda activate x-heep`.

## Hands-on 1: configuration and simulation (10-15')

1. Read `../configs/A.py`: it describes CPU, bus, memory, peripherals and interrupts.
2. Complete the three `TODO`s in `../exercises/B.py`, using `A.py` as a reference.
3. Generate X-HEEP and check the summary that `mcu-gen` prints (CPU, bus, memory banks):

   ```bash
   make mcu-gen X_HEEP_CFG=../exercises/B.py
   ```

4. Build the model, then run the matrix multiplication.
   To see the cycles in simulation, first set `PRINTF_IN_SIM` to `1` in `sw/applications/example_matmul/main.c`.

   ```bash
   make verilator-build
   make app PROJECT=example_matmul
   make verilator-run
   ```

   Expected: `program finished with 0 errors and <N> cycles`. Write down `<N>`.

Stuck? Use `../configs/B.py`, which is the solution.

## Hands-on 2: on the FPGA (10-15')

### Connections

Your bench has one of two setups. Use the bitstreams that match it.

| Setup | JTAG (debug) | UART | Bitstream suffix | OpenOCD config |
|-------|--------------|------|------------------|----------------|
| PYNQ-Z2 only | PYNQ micro-USB | USB-UART adapter on PMOD JB: adapter RX to pin 1, adapter TX to pin 7, GND to pin 5 | `_bscane` | `tb/core-v-mini-mcu-pynq-z2-bscan.cfg` |
| EPFL programmer | programmer on PMOD JA/JB | programmer | `_epflp` | `tb/core-v-mini-mcu-esl-programmer.cfg` |

In both setups the PYNQ micro-USB powers and programs the board.

### Run an application

Use three terminals.

Terminal 1, UART (find the port with `ls /dev/ttyUSB*` on Linux, `ls /dev/tty.usbserial*` on macOS):

```bash
picocom -b 9600 --imap lfcrlf <uart-port>
```

Terminal 2, program the FPGA and build the software for the **same** configuration:

```bash
openFPGALoader -b pynq_z2 ../bitstreams/pynq-z2_A_bscane.bit
make mcu-gen X_HEEP_CFG=../configs/A.py
make app PROJECT=hello_world TARGET=pynq-z2
openocd -f tb/core-v-mini-mcu-pynq-z2-bscan.cfg
```

Terminal 3, load and run the application:

```bash
make gdb_connect
```

`hello world!` appears on the UART. Leave GDB with `quit` and stop OpenOCD with `Ctrl+C`.

### Compare A, B and C

For each configuration: program its bitstream, run `mcu-gen` with its config, then build and run `example_matmul`:

```bash
make app PROJECT=example_matmul TARGET=pynq-z2                 # A and B
make app PROJECT=example_matmul TARGET=pynq-z2 \
    ARCH=rv32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip   # C
```

| Config | Cycles (simulation) | Cycles (FPGA) |
|--------|---------------------|---------------|
| A | - | |
| B | | |
| C | - | |

Questions:
- Do simulation and FPGA agree on B?
- Which change makes the difference: the CPU, the bus or the memory? Why does a single-core matmul not benefit from the N-to-M bus and the interleaved banks?
