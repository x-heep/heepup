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

All commands run from `gr-heep/`, with `conda activate x-heep`.

## Hands-on 3: integration and simulation (15-20')

### 0. Baseline

Before touching anything, measure the software version on the model you built at home in Part 0:

```bash
make app PROJECT=matmul_sw
make verilator-run
```

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

### 3. Generate, build, run

```bash
make mcu-gen
make verilator-build
make app PROJECT=matmul_hw
make verilator-run
```

Expected: one line per element type, `HW int8  32x32: <N> cycles, checksum ..., 0 errors`,
with the same checksum as `matmul_sw`.

Stuck? Copy the solution and regenerate:

```bash
cp ../solutions/part2/mcu-gen-config.py config/
cp ../solutions/part2/gr_heep_peripherals.sv.tpl hw/gr-heep/
```

## Hands-on 4: on the FPGA (15-20')

Same connections and terminals as in [Part 1](part1-config.md#hands-on-2-on-the-fpga-10-15).
Bitstream: `pynq-z2_matmul_<bscane|epflp>.bit`.

```bash
openFPGALoader -b pynq_z2 ../bitstreams/pynq-z2_matmul_bscane.bit
make app PROJECT=matmul_hw TARGET=pynq-z2
openocd -f hw/vendor/x-heep/tb/core-v-mini-mcu-pynq-z2-bscan.cfg   # or core-v-mini-mcu-esl-programmer.cfg
make -C hw/vendor/x-heep gdb_connect                               # in another terminal
```

Repeat with `matmul_sw` and fill the table:

| Elements | `matmul_sw` (simulation) | `matmul_hw` (simulation) | `matmul_sw` (FPGA) | `matmul_hw` (FPGA) |
|----------|--------------------------|--------------------------|--------------------|--------------------|
| int8 | | | | |
| int16 | | | | |
| int32 | | | | |

Questions:
- Why does the element type change the accelerator time so much, and the CPU time so little?
- How many cycles per MAC does the accelerator need with int8? Where does it spend the rest?
