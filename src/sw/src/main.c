
#include <sleep.h>
#include <stdbool.h>
#include "netif/xadapter.h"
//#include "platform_config.h"
#include "xil_printf.h"
#include "lwip/init.h"
#include "lwip/inet.h"
#include "FreeRTOS.h"

#include "xparameters.h"
#include "xsysmonpsu.h"
#include "xiicps.h"

#include "xstatus.h"       // For XStatus
#include "pm_defs.h"
#include "pm_common.h"       // PM API functions
#include "pm_api_sys.h"


/* Hardware support includes */
#include "../inc/zubpm_defs.h"
#include "../inc/pl_regs.h"
#include "../inc/psc_msg.h"




#define PLATFORM_EMAC_BASEADDR XPAR_XEMACPS_0_BASEADDR
#define SYSMON_DEVICE_ID XPAR_XSYSMONPSU_0_DEVICE_ID


#define PLATFORM_ZYNQMP

//#define DEFAULT_IP_ADDRESS "10.0.142.43"
//#define DEFAULT_IP_MASK "255.255.255.0"
//#define DEFAULT_GW_ADDRESS "10.0.142.1"



#define DELAY_100_MS            100UL
#define DELAY_1_SECOND          (10*DELAY_100_MS)



static sys_thread_t main_thread_handle;



#define THREAD_STACKSIZE 2048

struct netif server_netif;

//global buffers
char msgid30_buf[1024];
char msgid31_buf[1024];
char msgid32_buf[1024];

char msgid51_buf[MSGID51LEN];
char msgid52_buf[MSGID52LEN];
char msgid53_buf[MSGID53LEN];
char msgid54_buf[MSGID54LEN];
char msgid55_buf[MSGID55LEN];

//float thermistors[6];
bool wvfm_debug;



ip_t ip_settings;



XIicPs IicPsInstance;	    // Instance of the IIC Device
XSysMonPsu SysMonInstance;  // Instance of the Sysmon Device


TimerHandle_t xUptimeTimer;  // Timer handle
u32 UptimeCounter = 0;  // Uptime counter



// Timer callback function
void vUptimeTimerCallback(TimerHandle_t xTimer) {
    UptimeCounter++;  // Increment uptime counter
}


static void print_ip(char *msg, ip_addr_t *ip)
{
	xil_printf(msg);
	xil_printf("%d.%d.%d.%d\n\r", ip4_addr1(ip), ip4_addr2(ip),
				ip4_addr3(ip), ip4_addr4(ip));
}


static void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	print_ip("Board IP:       ", ip);
	print_ip("Netmask :       ", mask);
	print_ip("Gateway :       ", gw);
}


static void assign_ip_settings()
{
	u8 data[4];

	xil_printf("Getting IP Address from EEPROM\r\n");
	//IP address is stored in EEPROM locations 0,1,2,3
	i2c_eeprom_readBytes(0, data, 4);
	//xil_printf("IP Addr: %u.%u.%u.%u\r\n",data[0],data[1],data[2],data[3]);
	//data[0] = 10;
	//data[1] = 0;
	//data[2] = 142;
	//data[3] = 43;
	IP4_ADDR(&server_netif.ip_addr, data[0],data[1],data[2],data[3]);

	xil_printf("Getting IP Netmask from EEPROM\r\n");
	//IP netmask is stored in EEPROM locations 16,17,18,19
	i2c_eeprom_readBytes(16, data, 4);
	//xil_printf("IP Netmask: %u.%u.%u.%u\r\n",data[0],data[1],data[2],data[3]);
	//data[0] = 255;
	//data[1] = 255;
	//data[2] = 254;
	//data[3] = 0;
	IP4_ADDR(&server_netif.netmask, data[0],data[1],data[2],data[3]);

	xil_printf("Getting IP Netmask from EEPROM\r\n");
	i2c_eeprom_readBytes(32, data, 4);
	//IP gw is stored in EEPROM locations 32,33,34,35
	//xil_printf("IP Gateway: %u.%u.%u.%u\r\n",data[0],data[1],data[2],data[3]);
	//data[0] = 10;
	//data[1] = 0;
	//data[2] = 142;
	//data[3] = 51;
	IP4_ADDR(&server_netif.gw, data[0],data[1],data[2],data[3]);

}

void print_firmware_version()
{

  time_t epoch_time;
  struct tm *human_time;
  char timebuf[80];

  xil_printf("Module ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + MOD_ID_NUM));
  xil_printf("Module Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + MOD_ID_VER));
  xil_printf("Project ID Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PROJ_ID_NUM));
  xil_printf("Project Version Number: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + PROJ_ID_VER));
  //compare to git commit with command: git rev-parse --short HEAD
  xil_printf("Git Checksum: %x\r\n", Xil_In32(XPAR_M_AXI_BASEADDR + GIT_SHASUM));
  epoch_time = Xil_In32(XPAR_M_AXI_BASEADDR + COMPILE_TIMESTAMP);
  human_time = localtime(&epoch_time);
  strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M:%S", human_time);
  xil_printf("Project Compilation Timestamp: %s\r\n", timebuf);
}




void main_thread(void *p)
{

	// the mac address of the board. this should be unique per board
	u8_t mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x11, 0x11, 0x12 };
    i2c_get_mac_address(mac_ethernet_address);

	// initialize lwIP before calling sys_thread_new
	lwip_init();

	// Add network interface to the netif_list, and set it as default
	if (!xemac_add(&server_netif, NULL, NULL, NULL, mac_ethernet_address,
		PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\r\n");
		return;
	}

	netif_set_default(&server_netif);

	// specify that the network if is up
	netif_set_up(&server_netif);

	// start packet receive thread - required for lwIP operation
	sys_thread_new("xemacif_input_thread",
			(void(*)(void*))xemacif_input_thread, &server_netif,
			THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

	//IP address are read in from EEPROM
	assign_ip_settings(&(server_netif.ip_addr),&(server_netif.netmask),&(server_netif.gw));
	print_ip_settings(&(server_netif.ip_addr),&(server_netif.netmask),&(server_netif.gw));


    //Delay for 100ms
	vTaskDelay(pdMS_TO_TICKS(100));

    // Start the Menu Thread.  Handles all Console Printing and Menu control
    xil_printf("\r\n");
    sys_thread_new("menu_thread", menu_thread, 0,THREAD_STACKSIZE, 0);


    // Start the PSC Status Thread.  Handles 1Hz status info
    vTaskDelay(pdMS_TO_TICKS(100));
    xil_printf("\r\n");
    sys_thread_new("psc_status_thread", psc_status_thread, 0,THREAD_STACKSIZE, 1);


    // Delay for 100ms
    vTaskDelay(pdMS_TO_TICKS(100));
    // Start the PSC Waveform Thread.  Handles incoming commands from IOC
    xil_printf("\r\n");
    sys_thread_new("psc_wvfm_thread", psc_wvfm_thread, 0, THREAD_STACKSIZE, 1);


    // Delay for 100 ms
    vTaskDelay(pdMS_TO_TICKS(100));
    // Start the PSC Control Thread.  Handles incoming commands from IOC
    xil_printf("\r\n");
    sys_thread_new("psc_cntrl_thread", psc_control_thread, 0, THREAD_STACKSIZE, 3);


	//setup an Uptime Timer
	xUptimeTimer = xTimerCreate("UptimeTimer", pdMS_TO_TICKS(1000), pdTRUE, (void *)0, vUptimeTimerCallback);
	// Check if the timer was created successfully
	if (xUptimeTimer == NULL)
	    // Handle error (e.g., log, assert, etc.)
	    printf("Failed to create uptime timer.\n");
	else
	    // Start the timer with a block time of 0 (non-blocking)
	    if (xTimerStart(xUptimeTimer, 0) != pdPASS)
	       // Handle error (e.g., log, assert, etc.)
	       printf("Failed to start uptime timer.\n");



	vTaskDelete(NULL);
	return;
}




s32 init_sysmon() {

	s32 Status;
    XSysMonPsu_Config *SysMonConfig;

	// Initialize the SYSMON driver
	SysMonConfig = XSysMonPsu_LookupConfig(SYSMON_DEVICE_ID);
	if (SysMonConfig == NULL) {
		return XST_FAILURE;
	}

	Status = XSysMonPsu_CfgInitialize(&SysMonInstance, SysMonConfig, SysMonConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// Self-Test the System Monitor/ADC device
	Status = XSysMonPsu_SelfTest(&SysMonInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("SysMonPsu self-test failed.\n");
		return XST_FAILURE;
	}

    return XST_SUCCESS;
}


void read_artix_fifo() {

    int i;

    int regval, wordcnt, pollcnt;

    pollcnt = 0;
    xil_printf("Read Artix FIFO...\r\n");
    do {
    	wordcnt = Xil_In32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_CNT_REG);
        usleep(1000);
        xil_printf("PollCnt: %d\r\n", pollcnt);
    	pollcnt++;
    } while ((wordcnt == 0) && (pollcnt < 3000));

    xil_printf("PollCnt: %d     Num FIFO Words: %d\r\n", pollcnt, wordcnt);


    for (i=0;i<20;i++) {
        //chA and chB are in a single 32 bit word
    	regval = Xil_In32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_DATA_REG);
    	xil_printf("%x\r\n", regval);

    }

    xil_printf("Resetting FIFO...\r\n");
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_RST_REG, 1);
    usleep(1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_RST_REG, 0);
    usleep(10);
    
    wordcnt = Xil_In32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_CNT_REG);
    xil_printf("Num FIFO Words: %d\r\n", wordcnt);


}









void write_artix_spi()
{
	Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_DATA, 0x1);
	Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_ADDR, 0x0);
	Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_WE, 0x1);
	Xil_Out32(XPAR_M_AXI_BASEADDR + ARTIX_SPI_WE, 0x0);

}





int main()
{

    u32 ts_s, ts_ns, wordcnt;
    u32 i;

	xil_printf("ACMI Backend ...\r\n");
    print_firmware_version();

    wvfm_debug = false;

	init_i2c();
	init_sysmon();
    write_lmk61e2();
    write_si5347();


	//EVR reset
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RST_REG, 1);
	Xil_Out32(XPAR_M_AXI_BASEADDR + EVR_RST_REG, 2);
    usleep(1000);

    //Reset the Artix receive FIFO
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_RST_REG, 1);
    usleep(1);
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_RST_REG, 0);
    usleep(10);

    //Enable the Artix receive FIFO
    Xil_Out32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_STREAMENB_REG, 0);
    sleep(1);
    
    //Read Number of words in FIFO
    wordcnt = Xil_In32(XPAR_M_AXI_BASEADDR + CHAINA_FIFO_CNT_REG);
    xil_printf("Num FIFO Words: %d\r\n", wordcnt);


    //read Timestamp
    for (i=0;i<5;i++) {
      ts_s = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_S_REG);
      ts_ns = Xil_In32(XPAR_M_AXI_BASEADDR + EVR_TS_NS_REG);
      xil_printf("ts= %d    %d\r\n",ts_s,ts_ns);
      sleep(1);
    }
      //write_artix_spi();

      //usleep(10000);
      //read_artix_fifo();

      sleep(1);
    //}


    // TODO:  This doesn't work
    //xil_printf("System is about to reset...\n");
    // Perform the system reset
    //XPm_ResetAssert(XILPM_RESET_SOFT,XILPM_RESET_ACTION_PULSE);


	main_thread_handle = sys_thread_new("main_thread", main_thread, 0, THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

	vTaskStartScheduler();

	while(1);

	return 0;
}
