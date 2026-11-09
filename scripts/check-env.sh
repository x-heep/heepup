#!/usr/bin/env bash
# Check that the tools needed by the tutorial are installed.
# Usage: scripts/check-env.sh

fail=0
ok()   { printf "  OK    %s\n" "$1"; }
bad()  { printf "  FAIL  %s: %s\n" "$1" "$2"; fail=1; }
warn() { printf "  WARN  %s: %s\n" "$1" "$2"; }

echo "Simulation (needed at home):"
[ "$CONDA_DEFAULT_ENV" = x-heep ] && ok "conda env x-heep" || bad "conda env x-heep" "run 'conda activate x-heep'"
ls "$RISCV_XHEEP"/bin/riscv32-*-gcc > /dev/null 2>&1 && ok "RISC-V toolchain" || bad "RISC-V toolchain" "set RISCV_XHEEP to the toolchain folder"
verilator --version 2> /dev/null | grep -q "5.040" && ok "Verilator 5.040" || bad "Verilator 5.040" "not found or wrong version"
command -v verible-verilog-format > /dev/null && ok "Verible" || bad "Verible" "not in PATH"
command -v fusesoc > /dev/null && ok "FuseSoC" || bad "FuseSoC" "activate the x-heep conda env"

echo "FPGA (needed in the lab):"
for tool in openocd openFPGALoader picocom; do
    command -v $tool > /dev/null && ok $tool || warn $tool "not in PATH"
done

[ $fail -eq 0 ] && echo "All good." || echo "Fix the FAIL lines before the tutorial."
exit $fail
