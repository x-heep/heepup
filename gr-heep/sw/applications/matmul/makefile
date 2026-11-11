# Copyright 2023 EPFL and Politecnico di Torino.
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# File: makefile
# Author: Michele Caon
# Date: 24/07/2023
# Description: Makefile for NM-Carus matrix multiplication app

#############################
# ----- CONFIGURATION ----- #
#############################

KERNEL_PARAMS 		?= int8 --row_a 64 --col_a 64 --col_b 64

#####################
# ----- RULES ----- #
#####################

# Default alias
.PHONY: all
all: data.h

# Generate data.h
data.h: .force
	@echo "## Generating data.h..."
	PYTHONPATH=../../../hw/vendor/x-heep/util python3 datagen.py $(KERNEL_PARAMS)

# Dummy rule to force recompilation (because of parameters)
.force:

# Clean
.PHONY: clean
clean:
	$(RM) data.h
