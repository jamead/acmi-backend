/********************************************************************
*  PSC Waveform Thread
*  J. Mead
*  4-17-24
*
*  This thread is responsible for sending all waveform data to the IOC.   It does
*  this over to message ID's (51 = ADC Data, 52 = TbT data)
*
*  It starts a listening server on
*  port 600.  Upon establishing a connection with a client, it begins to send out
*  packets.
********************************************************************/

#include <stdio.h>
#include <string.h>
#include <sleep.h>
#include "xil_cache.h"
#include "xparameters.h"

#include "lwip/sockets.h"
#include "netif/xadapter.h"
#include "lwipopts.h"
#include "xil_printf.h"
#include "FreeRTOS.h"
#include "task.h"

/* Hardware support includes */
#include "../inc/zubpm_defs.h"
#include "../inc/pl_regs.h"
#include "../inc/psc_msg.h"


#define PORT  20




void Host2NetworkConvWvfm(char *inbuf, int len) {

    int i;
    u8 temp;
    //Swap bytes to reverse the order within the 4-byte segment
    //Start at byte 8 (skip the PSC Header)
    for (i=8;i<len;i=i+4) {
    	temp = inbuf[i];
    	inbuf[i] = inbuf[i + 3];
    	inbuf[i + 3] = temp;
    	temp = inbuf[i + 1];
    	inbuf[i + 1] = inbuf[i + 2];
    	inbuf[i + 2] = temp;
    }

}





void ReadLiveTbTWvfm(char *msg) {

    int i;
    u32 *msg_u32ptr;

    //Enable TbT FIFO write
    Xil_Out32(XPAR_M_AXI_BASEADDR + TBTFIFO_STREAMENB_REG, 1);
    usleep(30000);

    //printf("Reading TbT FIFO...\n");
    //regval = Xil_In32(XPAR_M_AXI_BASEADDR + TBTFIFO_CNT_REG);
    //printf("\tWords in TbT FIFO = %d\n",regval);

    //write the PSC Header
     msg_u32ptr = (u32 *)msg;
     msg[0] = 'P';
     msg[1] = 'S';
     msg[2] = 0;
     msg[3] = (short int) MSGID52;
     *++msg_u32ptr = htonl(MSGID52LEN); //body length
 	 msg_u32ptr++;


    // Get TbT Waveform
    for (i=0;i<8000*2;i++)
	   *msg_u32ptr++ = Xil_In32(XPAR_M_AXI_BASEADDR + TBTFIFO_DATA_REG);

    //printf("TbT FIFO Read Complete...\n");
    //printf("Resetting FIFO...\n");
    Xil_Out32(XPAR_M_AXI_BASEADDR + TBTFIFO_RST_REG, 1);
    usleep(1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + TBTFIFO_RST_REG, 0);
    usleep(10);

}



void ReadLiveADCWvfm(char *msg) {

    int i;
    u16 *msg_u16ptr;
    u32 *msg_u32ptr;
    int regval;
    s16 cha,chb,chc,chd;

    Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_STREAMENB_REG, 1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_STREAMENB_REG, 0);
    usleep(10000);
    //xil_printf("Reading ADC FIFO...\r\n");
    //regval = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_CNT_REG);
    //xil_printf("\tWords in ADC FIFO = %d\r\n",regval);

    //write the PSC Header
     msg_u32ptr = (u32 *)msg;
     msg[0] = 'P';
     msg[1] = 'S';
     msg[2] = 0;
     msg[3] = (short int) MSGID51;
     *++msg_u32ptr = htonl(MSGID51LEN); //body length



    msg_u16ptr = (u16 *) &msg[MSGHDRLEN];
    for (i=0;i<8000;i++) {
        //chA and chB are in a single 32 bit word
    	regval = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
    	cha = (short int) ((regval & 0xFFFF0000) >> 16);
    	chb = (short int) (regval & 0xFFFF);
        regval = Xil_In32(XPAR_M_AXI_BASEADDR + ADCFIFO_DATA_REG);
    	chc = (short int) ((regval & 0xFFFF0000) >> 16);
    	chd = (short int) (regval & 0xFFFF);

        //chC and chD are in a single 32 bit word
        *msg_u16ptr++ = chc;
        *msg_u16ptr++ = chd;
        *msg_u16ptr++ = cha;
        *msg_u16ptr++ = chb;


    }

    //printf("Resetting FIFO...\n");
    Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_RST_REG, 1);
    usleep(1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + ADCFIFO_RST_REG, 0);
    usleep(10);


}






void psc_wvfm_thread()
{

	int sockfd, newsockfd;
	int clilen;
	struct sockaddr_in serv_addr, cli_addr;
    u32 loopcnt=0;
    s32 n;


    xil_printf("Starting PSC Waveform Server...\r\n");

	// Initialize socket structure
	memset(&serv_addr, 0, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(PORT);
	serv_addr.sin_addr.s_addr = INADDR_ANY;

    // First call to socket() function
	if ((sockfd = lwip_socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		xil_printf("PSC Waveform : Error Creating Socket\r\n");
		//vTaskDelete(NULL);
	}

    // Bind to the host address using bind()
	if (lwip_bind(sockfd, (struct sockaddr *)&serv_addr, sizeof (serv_addr)) < 0) {
		xil_printf("PSC Waveform : Error Creating Socket\r\n");
		//vTaskDelete(NULL);
	}

    // Now start listening for the clients
	lwip_listen(sockfd, 0);

    xil_printf("PSC Waveform:  Server listening on port %d...\r\n",PORT);


reconnect:

	clilen = sizeof(cli_addr);

	newsockfd = lwip_accept(sockfd, (struct sockaddr *)&cli_addr, (socklen_t *)&clilen);
	if (newsockfd < 0) {
	    xil_printf("PSC Waveform: ERROR on accept\r\n");
	    //vTaskDelete(NULL);
	}
	/* If connection is established then start communicating */
	xil_printf("PSC Waveform: Connected Accepted...\r\n");
    xil_printf("PSC Waveform: Entering while loop...\r\n");




	while (1) {

		//xil_printf("Wvfm: In main waveform loop...\r\n");
		loopcnt++;
		vTaskDelay(pdMS_TO_TICKS(1000));


        //xil_printf("Wvfm(%d) Sending Live Data...\r\n",loopcnt);
        ReadLiveADCWvfm(msgid51_buf);
        //write out Live ADC data (msg51)
        Host2NetworkConvWvfm(msgid51_buf,sizeof(msgid51_buf)+MSGHDRLEN);
        n = write(newsockfd,msgid51_buf,MSGID51LEN+MSGHDRLEN);
        if (n < 0) {
        	printf("PSC Waveform: ERROR writing MSG 51 - ADC Waveform\n");
        	close(newsockfd);
        	goto reconnect;
        }


        //xil_printf("%8d:  Reading TbT Waveform...\r\n",loopcnt);
        ReadLiveTbTWvfm(msgid52_buf);
        //write out Live TbT data (msg52)
        Host2NetworkConvWvfm(msgid52_buf,sizeof(msgid52_buf)+MSGHDRLEN);
        n = write(newsockfd,msgid52_buf,MSGID52LEN+MSGHDRLEN);
        if (n < 0) {
        	printf("PSC Waveform: ERROR writing MSG 52 - TbT Waveform\n");
        	close(newsockfd);
        	goto reconnect;
        }



	}

	/* close connection */
	close(newsockfd);
	vTaskDelete(NULL);
}


