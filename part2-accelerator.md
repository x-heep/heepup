# Part 2: integrate an accelerator with GR-HEEP

GR-HEEP extends X-HEEP without touching it: your hardware lives next to X-HEEP and connects to its
external ports. Here you integrate a SHA-3 (Keccak) accelerator in two ways and compare them with software:

| Variant | How it connects | Application |
|---------|-----------------|-------------|
| software | none, Keccak runs on the CPU | `SHA3-384-baseline` |
| loosely coupled | memory-mapped peripheral + interrupt | `SHA3-384-loosely` |
| tightly coupled | coprocessor on the CPU's CORE-V-XIF | `SHA3-384-tightly` |

The accelerators are already vendored in `hw/vendor/keccak` and `hw/vendor/keccak_tightly`,
the applications in `sw/applications`. All commands run from `gr-heep/`, with `conda activate x-heep`.

## Hands-on 3: integration and simulation (15-20')

### 1. Configuration: `config/mcu-gen-config.py`

- Enable the XIF: uncomment `system.set_xif(...)` and set `x_num_rs=3` (the Keccak coprocessor reads 3 registers).
- In `ext_periph`, add the loosely coupled peripheral:

  ```python
  "keccak": {
      "offset": 0x00000000,
      "length": 0x00001000,
  },
  ```

- Set `external_interrupts = 1`: the peripheral raises an interrupt when it is done.

### 2. Hardware: `hw/gr-heep/gr_heep_peripherals.sv.tpl`

This template already contains a commented example for each kind of accelerator. Replace them:

- in the loop over `gr_heep["peripherals"]`, instantiate `keccak_top` when `a_slave['name'] == "Keccak"`.
  Ports: `clk_i`, `rst_ni`, `reg_req_i`/`reg_rsp_o` (use index `gr_heep_pkg::KeccakPeriphIdx`
  of `gr_heep_peripheral_req`/`gr_heep_peripheral_rsp`), `keccak_intr_o` to `gr_heep_peripheral_vec_int[0]`;
- in the `cv32e40px and xif` block, instantiate `keccak_tightly_wrapper`.
  Ports: `clk_i`, `rst_ni` and the six `xif_*_if` interfaces.

### 3. Generate, build, run

```bash
make mcu-gen
make verilator-build
make app PROJECT=SHA3-384-baseline
make verilator-run
```

Repeat `make app` and `make verilator-run` with `SHA3-384-loosely` and `SHA3-384-tightly`.
Each run checks the digest and prints the cycles.

Stuck? Copy the solution and regenerate:

```bash
cp ../solutions/part2/mcu-gen-config.py config/
cp ../solutions/part2/gr_heep_peripherals.sv.tpl hw/gr-heep/
```

## Hands-on 4: on the FPGA (15-20')

Same connections and terminals as in [Part 1](part1-config.md#hands-on-2-on-the-fpga-10-15). Bitstream: `pynq-z2_keccak_<bscane|epflp>.bit`.

```bash
openFPGALoader -b pynq_z2 ../bitstreams/pynq-z2_keccak_bscane.bit
make app PROJECT=SHA3-384-baseline TARGET=pynq-z2
openocd -f hw/vendor/x-heep/tb/core-v-mini-mcu-pynq-z2-bscan.cfg   # or core-v-mini-mcu-esl-programmer.cfg
make -C hw/vendor/x-heep gdb_connect                               # in another terminal
```

Repeat with `SHA3-384-loosely` and `SHA3-384-tightly`, and fill the table:

| Application | Cycles (simulation) | Cycles (FPGA) |
|-------------|---------------------|---------------|
| SHA3-384-baseline | | |
| SHA3-384-loosely | | |
| SHA3-384-tightly | | |

Questions:
- Where does the loosely coupled version spend its time? (hint: moving data over the bus)
- What does the tightly coupled version save, and what does it cost in terms of integration?
