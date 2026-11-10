#!/usr/bin/env bash
# Build the Part 2 PYNQ-Z2 bitstreams (GR-HEEP with the Part 2 solution), in parallel,
# in two debug variants: bscane (on-board USB JTAG) and epflp (EPFL programmer).
# Needs Vivado and the x-heep environment (conda env, RISC-V toolchain, verible) loaded.
# Usage: scripts/build-bitstreams.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=$ROOT/bitstreams
mkdir -p "$OUT" "$ROOT/build"

build() {
    local variant=$1 flags=""
    local dir=$ROOT/build/matmul-$variant
    [ "$variant" = bscane ] && flags="--flag=use_bscane_xilinx"

    rm -rf "$dir"
    rsync -a --exclude build --exclude .git "$ROOT/gr-heep/" "$dir/"
    cp "$ROOT/solutions/part2/mcu-gen-config.py" "$dir/config/"
    cp "$ROOT/solutions/part2/gr_heep_peripherals.sv.tpl" "$dir/hw/gr-heep/"
    cd "$dir"
    make mcu-gen
    make vivado-fpga FPGA_BOARD=pynq-z2 FUSESOC_FLAGS="$flags"
    cp "$(find build -path '*impl_1*' -name '*.bit' | head -1)" "$OUT/pynq-z2_matmul_${variant}.bit"
}

pids=()
for variant in bscane epflp; do
    build "$variant" > "$ROOT/build/matmul-$variant.log" 2>&1 &
    pids+=($!)
done

failed=0
for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
ls -l "$OUT"
[ $failed -eq 0 ] || { echo "Some builds failed, see $ROOT/build/*.log"; exit 1; }
