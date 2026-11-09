// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Authors: Alessandra Dolmeta, Valeria Piscopo
// Date: 30/07/2025
// Description: Driver for Keccak

#ifndef _KECCAK_H_
#define _KECCAK_H_

#include <stdint.h>

int KeccakF1600_StatePermute(uint32_t Din[50], uint32_t Dout[50]);

#endif