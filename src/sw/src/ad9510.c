/********************************************************************
*  Mem-Map
*  8-17-2016
*  Tony Caracappa
*  This program reads the shared memory space
********************************************************************/
#include "xil_printf.h"
#include "sleep.h"
#include "../inc/pl_regs.h"



void prog_ad9510()
{



   xil_printf("Programming AD9510...\r\n");

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0010);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5800);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4500);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3c08);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4b80);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3d08);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4980);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3e08);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4d80);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3f08);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4f80);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4002);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5180);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4102);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5380);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4202);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5580);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3800);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x391b);  //0x3900
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x3a0a);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x4302);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5780);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0400);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0501);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0636);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0877);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0930);    //0x0900
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0a02);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0b00);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0c01);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x0d00);
   usleep(5000);

   Xil_Out32(XPAR_M_AXI_BASEADDR + AD9510_REG, 0x5a01);
   usleep(5000);
   xil_printf("Programming Complete\r\n");

   return;

}
