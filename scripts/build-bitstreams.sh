#!/usr/bin/env bash
# Build the PYNQ-Z2 bitstreams of the given configs (default: A B C keccak), in parallel,
# in two debug variants: bscane (on-board USB JTAG) and epflp (EPFL programmer).
# A, B, C are X-HEEP configs in configs/; keccak is GR-HEEP with the Part 2 solution.
# Needs Vivado and the x-heep environment (conda env, RISC-V toolchain, verible) loaded.
# Usage: scripts/build-bitstreams.sh [CONFIG...]
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=$ROOT/bitstreams
mkdir -p "$OUT" "$ROOT/build"

build() {
    local cfg=$1 variant=$2 flags=""
    local dir=$ROOT/build/$cfg-$variant
    [ "$variant" = bscane ] && flags="--flag=use_bscane_xilinx"

    rm -rf "$dir"
    if [ "$cfg" = keccak ]; then
        rsync -a --exclude build --exclude .git "$ROOT/gr-heep/" "$dir/"
        cp "$ROOT/solutions/part2/mcu-gen-config.py" "$dir/config/"
        cp "$ROOT/solutions/part2/gr_heep_peripherals.sv.tpl" "$dir/hw/gr-heep/"
        cd "$dir"
        make mcu-gen
    else
        rsync -a --exclude build --exclude .git "$ROOT/x-heep/" "$dir/"
        cd "$dir"
        make mcu-gen X_HEEP_CFG="$ROOT/configs/$cfg.py"
    fi
    make vivado-fpga FPGA_BOARD=pynq-z2 FUSESOC_FLAGS="$flags"
    cp "$(find build -path '*impl_1*' -name '*.bit' | head -1)" "$OUT/pynq-z2_${cfg}_${variant}.bit"
}

configs=("$@")
[ $# -eq 0 ] && configs=(A B C keccak)

pids=()
for cfg in "${configs[@]}"; do
    for variant in bscane epflp; do
        build "$cfg" "$variant" > "$ROOT/build/$cfg-$variant.log" 2>&1 &
        pids+=($!)
    done
done

failed=0
for pid in "${pids[@]}"; do wait "$pid" || failed=1; done
ls -l "$OUT"
[ $failed -eq 0 ] || { echo "Some builds failed, see $ROOT/build/*.log"; exit 1; }
