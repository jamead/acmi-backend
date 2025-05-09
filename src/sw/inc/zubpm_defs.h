
#define RFATTEN 0
#define PTATTEN 1
#define HOR 0
#define VERT 1
#define CHA 0
#define CHB 1
#define CHC 2
#define CHD 3

#define ADC 0
#define TBT 1
#define FA 2

#define STRAIGHT 0
#define RING 1

#define BRDTEMP0_ADDR 0x48
#define BRDTEMP1_ADDR 0x49
#define BRDTEMP2_ADDR 0x4A
#define BRDTEMP3_ADDR 0x4B

#define I2C_PORTEXP0_ADDR 0x70
#define I2C_PORTEXP1_ADDR 0x71



#define SPI_DATA_ADDR 0
#define SPI_ADDR_ADDR 1
#define SPI_RW_ADDR   2
#define EEPROM_WRDATA  0x51
#define EEPROM_TRIG    0x50
#define EEPROM_READALL 0x52


// opcodes for CAT25320 EEPROM
#define EEPROM_OPCODE_RDSR 5
#define EEPROM_OPCODE_WRSR 1
#define EEPROM_OPCODE_WREN 6
#define EEPROM_OPCODE_WRDI 4
#define EEPROM_OPCODE_READ 3
#define EEPROM_OPCODE_WRITE 2





typedef struct {
  u8 ipaddr[4];
  u8 ipmask[4];
  u8 ipgw[4];
} ip_t;


void setup_thermistors(u8);
void trig_thermistors(u8);
void read_thermistors(u8, float *, float *);


void i2c_get_mac_address();
void i2c_eeprom_readBytes(u8, u8 *, u8);
void i2c_eeprom_writeBytes(u8, u8 *, u8);
void eeprom_dump();
void menu_get_ipaddr();

void prog_ad9510();
void ltc2195_init();

void dma_arm();
void menu_thread();
void set_eventno(u32);
void set_eventdly(u32);
void psc_control_thread();
void psc_status_thread();
void psc_wvfm_thread();
void read_thermistor_thread();

void init_i2c();
s32 i2c_read(u8 *, u8, u8);
s32 i2c_write(u8 *, u8, u8);
void i2c_set_port_expander(u32, u32);
float read_i2c_temp(u8);
void write_lmk61e2();
void write_si5347();

float L11_to_float(s32);

void i2c_configure_ltc2991();
void i2c_get_ltc2991();
float i2c_ltc2991_reg1_temp();
float i2c_ltc2991_reg2_temp();
float i2c_ltc2991_reg3_temp();
float i2c_ltc2991_vcc_vin();
float i2c_ltc2991_vcc_vin_current();
float i2c_ltc2991_vcc_mgt_2v5();
float i2c_ltc2991_vcc_mgt_2v5_current();
float i2c_ltc2991_vcc_2v5();
float i2c_ltc2991_vcc_2v5_current();
float i2c_ltc2991_vcc_mgt_1v2();
float i2c_ltc2991_vcc_mgt_1v2_current();
float i2c_ltc2991_vcc_mgt_0v9();
float i2c_ltc2991_vcc_mgt_0v9_current();
float i2c_ltc2991_vcc_1v2_ddr();
float i2c_ltc2991_vcc_1v2_ddr_current();
float i2c_ltc2991_vcc_1v8();
float i2c_ltc2991_vcc_1v8_current();
float i2c_ltc2991_vcc_3v3();
float i2c_ltc2991_vcc_3v3_current();
float i2c_ltc2991_vcc_0v85();
float i2c_ltc2991_vcc_0v85_current();

//void i2c_sfp_get_stats(struct *, u8);




