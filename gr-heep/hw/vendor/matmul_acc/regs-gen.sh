#!/usr/bin/env bash
# Regenerate the register file RTL and C header from data/matmul_acc.hjson.
# Usage: ./regs-gen.sh <path-to-x-heep>
set -e
REGTOOL=$1/hw/vendor/pulp_platform/register_interface/vendor/lowrisc_opentitan/util/regtool.py
cd "$(dirname "$0")"
$REGTOOL -r -t rtl data/matmul_acc.hjson
$REGTOOL --cdefines -o sw/matmul_acc_regs.h data/matmul_acc.hjson
