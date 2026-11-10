# Part 2: integrate an accelerator with GR-HEEP

GR-HEEP extends X-HEEP without touching it: your hardware lives next to X-HEEP and connects to its
external ports. Here you integrate `matmul_acc`, a matrix multiplication accelerator:

- the CPU writes the addresses of A, B, C, the size N and the element type in its **registers** and starts it;
- the accelerator reads A and B and writes C through its **OBI master port**, one word per cycle;
- each word holds 4 int8, 2 int16 or 1 int32 elements (**packed SIMD**, register `MODE`);
- at the end it raises an **interrupt**.

The accelerator is already vendored in `hw/vendor/matmul_acc` (see its `README.md`). Two applications:

| Application | What it does |
|-------------|--------------|
| `matmul_sw` | C = A x B (32x32) on the CPU with int8, int16 and int32 elements, prints the cycles |
| `matmul_hw` | the same on the accelerator, prints the cycles and checks the results |

You integrate the accelerator, then run it on the FPGA with the bitstream we give you.
All commands run from `gr-heep/`, with `conda activate x-heep`.

## Hands-on 2: integration (15-20')

### 1. Configuration: `config/mcu-gen-config.py`, function `gr_heep_config()`

- `ext_xbar_nmasters = 1`: one external master port, for the accelerator.
- In `ext_periph`, add the accelerator registers:

  ```python
  "matmul": {
      "offset": 0x00000000,
      "length": 0x00001000,
  },
  ```

- `external_interrupts = 1`: one interrupt line, for the accelerator.

### 2. Hardware: `hw/gr-heep/gr_heep_peripherals.sv.tpl`

In the loop over `gr_heep["peripherals"]` there is a commented example (`TestIp`). Next to it, instantiate
`matmul_acc` when `a_slave['name'] == "Matmul"`:

| Port | Connect to |
|------|------------|
| `clk_i`, `rst_ni` | `clk_i`, `rst_ni` |
| `reg_req_i`, `reg_rsp_o` | `gr_heep_peripheral_req` / `gr_heep_peripheral_rsp` at index `gr_heep_pkg::MatmulPeriphIdx` |
| `obi_req_o`, `obi_rsp_i` | `gr_heep_master_req_o[0]` / `gr_heep_master_resp_i[0]` |
| `intr_o` | `gr_heep_peripheral_vec_int[0]` |

### 3. Generate and check

```bash
make mcu-gen
make app PROJECT=matmul_hw TARGET=pynq-z2
```

If the accelerator is missing from the configuration, `make app` fails with `MATMUL_PERIPH_START_ADDRESS` undeclared.
Then compare your files with the solution:

```bash
diff -w config/mcu-gen-config.py ../solutions/part2/mcu-gen-config.py
diff -w hw/gr-heep/gr_heep_peripherals.sv.tpl ../solutions/part2/gr_heep_peripherals.sv.tpl
```

The bitstream is built from the solution. If your files differ, or you are stuck, copy the solution and regenerate:

```bash
cp ../solutions/part2/mcu-gen-config.py config/
cp ../solutions/part2/gr_heep_peripherals.sv.tpl hw/gr-heep/
make mcu-gen
```

## Hands-on 3: on the FPGA (15-20')

### Connections

Your bench has one of two setups. Use the bitstream that matches it.

| Setup | JTAG (debug) | UART | Bitstream | OpenOCD config |
|-------|--------------|------|-----------|----------------|
| PYNQ-Z2 only | PYNQ micro-USB | USB-UART adapter on PMOD JB: adapter RX to pin 1, adapter TX to pin 7, GND to pin 5 | `pynq-z2_matmul_bscane.bit` | `core-v-mini-mcu-pynq-z2-bscan.cfg` |
| EPFL programmer | programmer on PMOD JA/JB | programmer | `pynq-z2_matmul_epflp.bit` | `core-v-mini-mcu-esl-programmer.cfg` |

In both setups the PYNQ micro-USB powers and programs the board.

### Run the applications

Use three terminals.

Terminal 1, UART (find the port with `ls /dev/ttyUSB*` on Linux, `ls /dev/tty.usbserial*` on macOS):

```bash
picocom -b 9600 --imap lfcrlf <uart-port>
```

Terminal 2, program the FPGA, build the software and start OpenOCD:

```bash
openFPGALoader -b pynq_z2 ../bitstreams/pynq-z2_matmul_bscane.bit
make app PROJECT=matmul_sw TARGET=pynq-z2
openocd -f hw/vendor/x-heep/tb/core-v-mini-mcu-pynq-z2-bscan.cfg
```

Terminal 3, load and run the application:

```bash
make -C hw/vendor/x-heep gdb_connect
```

The cycles appear on the UART. Leave GDB with `quit`. OpenOCD keeps running: in terminal 3, run `matmul_hw`:

```bash
make app PROJECT=matmul_hw TARGET=pynq-z2
make -C hw/vendor/x-heep gdb_connect
```

Expected for `matmul_hw`: one line per element type, `HW int8  32x32: <N> cycles, checksum ..., 0 errors`,
with the same checksum as `matmul_sw`.

| Elements | `matmul_sw` | `matmul_hw` |
|----------|-------------|-------------|
| int8 | | |
| int16 | | |
| int32 | | |

Questions:
- Why does the element type change the accelerator time so much, and the CPU time so little?
- How many cycles per MAC does the accelerator need with int8? Where does it spend the rest?
