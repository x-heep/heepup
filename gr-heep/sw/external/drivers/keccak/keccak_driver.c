// Copyright 2025 Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Authors: Alessandra Dolmeta, Valeria Piscopo
// Date: 30/07/2025
// Description: Driver for Keccak

#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "gr_heep.h"
#include "core_v_mini_mcu.h"
#include "keccak_driver.h"
#include "keccak_auto.h"


// To manage interrupt
#include "csr.h"
#include "rv_plic.h"
#include "rv_plic_regs.h"
#include "rv_plic_structs.h"
#include "hart.h"


#define KECCAK_BUSY 0
#define DATA_SIZE 50

// Interrupt controller variables
plic_result_t plic_res;

/* ISR that just sets a flag */
volatile int keccak_done = 0;
static void isr_keccak_done(uint32_t id)
{
    /* 1.  Clear the pending bit *inside* the accelerator           */
    //((volatile uint32_t *)KECCAK_STATUS_START_ADDR)[0] =
    //    1 << KECCAK_STATUS_DONE_BIT;

    /* 2.  Tell the main thread we finished                          */
    keccak_done = 1;
}

// Own defined ext interrupt handler
void handler_irq_ext(uint32_t id){
  //printf("D\n");
}
  
int KeccakF1600_StatePermute(uint32_t* Din, uint32_t* Dout)
{

  uint32_t volatile *Din_reg_start = (uint32_t*)KECCAK_PERIPH_START_ADDRESS;
  uint32_t volatile *ctrl_reg = (uint32_t*)(KECCAK_PERIPH_START_ADDRESS + KECCAK_CTRL_REG_OFFSET);
  uint32_t volatile *status_reg = (uint32_t*)(KECCAK_PERIPH_START_ADDRESS + KECCAK_STATUS_REG_OFFSET);
  uint32_t current_status;


  //uint32_t* ext_addr_4B_PTR = (uint32_t*)KECCAK_PERIPH_START_ADDRESS;
 
  // Keccak accelerator send interrupt on ext_intr line 0
  plic_res = plic_Init();
  if (plic_res != kPlicOk) {return -1;}
  
  // Set Keccak priority to 1 (target threshold is by default 0) to trigger an interrupt to the target (the processor)
  plic_res = plic_irq_set_priority(EXT_INTR_0, 1);
  if (plic_res == kPlicOk) {
  } else {}

  // Enable the interrupt in reg 0 
  plic_res = plic_irq_set_enabled(EXT_INTR_0, kPlicToggleEnabled);
  if (plic_res == kPlicOk) {
  } else {}

  // Enable interrupt on processor side
  CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
  // Set mie.MEIE bit to one to enable machine-level external interrupts
  const uint32_t mask = 1 << 11;//IRQ_EXT_ENABLE_OFFSET;
  CSR_SET_BITS(CSR_REG_MIE, mask);

  plic_assign_external_irq_handler(EXT_INTR_0, isr_keccak_done); 

  //volatile int i;
  for (int i = 0; i < 50; i++)
  {
  //  //printf("Din[%d]=%04X\n", i, Din[i]);
    Din_reg_start[i] = Din[i];
  //  //printf("Din_reg_start[%d]=%04X\n", i, Din_reg_start[i]);
  }


  keccak_done = 0;
  asm volatile ("": : : "memory");
  *ctrl_reg = (1 << 0);
  //////printf("ctrl_reg=%04x\n", ctrl_reg);
  //////printf("ctrl_reg=%04x\n", *ctrl_reg);
  asm volatile ("": : : "memory");
  *ctrl_reg = (0 << 0);
  //// Wait till keccak is done

  // while(keccak_done==0) {
     wait_for_interrupt();
  // }

  //printf("after interrupt\n");
  for (volatile int i = 0; i<DATA_SIZE; i++){
    Dout[i] = Din_reg_start[i];
  }


  
}