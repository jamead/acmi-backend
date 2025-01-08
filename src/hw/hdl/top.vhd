
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library desyrdl;
use desyrdl.common.all;
use desyrdl.pkg_pl_regs.all;

library xil_defaultlib;
use xil_defaultlib.acmi_package.ALL;


entity top is
generic(
    FPGA_VERSION			: integer := 9;
    SIM_MODE				: integer := 0
    );
  port (  

    --evr transceiver
    gth_evr_refclk_p        : in std_logic;
    gth_evr_refclk_n        : in std_logic;
    gth_evr_tx_p            : out std_logic;
    gth_evr_tx_n            : out std_logic;
    gth_evr_rx_p            : in std_logic;
    gth_evr_rx_n            : in std_logic;   
    
    
    sfp_led                 : out std_logic_vector(11 downto 0);
    sfp_rxlos               : in std_logic_vector(5 downto 0);
    
    fp_in                   : in std_logic_vector(3 downto 0);
    fp_out                  : out std_logic_vector(3 downto 0);
    fp_led                  : out std_logic_vector(7 downto 0);
    dbg                     : out std_logic_vector(19 downto 0) 

  );
end top;
 

architecture behv of top is

  
  signal pl_clk0         : std_logic;
  signal pl_clk1         : std_logic;
  signal adc_clk         : std_logic;
  signal pl_resetn       : std_logic;
  signal pl_reset        : std_logic;
  signal ps_leds         : std_logic_vector(7 downto 0);
  
  signal m_axi4_m2s      : t_pl_regs_m2s;
  signal m_axi4_s2m      : t_pl_regs_s2m;
  
  signal reg_o_evr       : t_reg_o_evr;
  signal reg_i_evr       : t_reg_i_evr;
  
  signal reg_i_chaina_fifo : t_reg_i_chaina_fifo_rdout;
  signal reg_o_chaina_fifo : t_reg_o_chaina_fifo_rdout;

   
  
  signal evr_tbt_trig    : std_logic;
  signal evr_fa_trig     : std_logic;
  signal evr_sa_trig     : std_logic;
  signal evr_gps_trig    : std_logic;
  signal evr_dma_trig    : std_logic;  
  signal evr_ts          : std_logic_vector(63 downto 0); 
  signal evr_rcvd_clk    : std_logic;
  signal evr_ref_clk     : std_logic;
   
 
  
  signal inttrig_enb     : std_logic_vector(3 downto 0);
  signal trig_evrintsel  : std_logic;
  signal tbt_gate        : std_logic;
  signal tbt_trig        : std_logic;
  signal pt_trig         : std_logic;
  signal fa_trig         : std_logic;
  signal sa_trig         : std_logic;
  signal sa_trig_stretch : std_logic;
  signal ps_fpled_stretch: std_logic;
  signal dma_trig        : std_logic;





  --attribute mark_debug     : string;
  --attribute mark_debug of reg_o: signal is "true";

 

begin




dbg(0) <= pl_clk0;
dbg(1) <= '0';
dbg(2) <= '0';
dbg(3) <= '0';
dbg(4) <= '0';
dbg(5) <= '0';
dbg(6) <= '0'; 
dbg(7) <= '0'; 
dbg(8) <= '0'; 
dbg(9) <= evr_tbt_trig;
dbg(10) <= evr_fa_trig;
dbg(11) <= evr_sa_trig;
dbg(12) <= tbt_trig; 
dbg(13) <= fa_trig;
dbg(14) <= sa_trig;
dbg(15) <= '0';
dbg(16) <= fp_in(0);
dbg(17) <= fp_in(1);
dbg(18) <= fp_in(2);
dbg(19) <= fp_in(3);


fp_out(0) <= pl_clk0;
fp_out(1) <= evr_rcvd_clk; --pl_clk1; --adc_clk_in;
fp_out(2) <= '0';
fp_out(3) <= '0'; 

fp_led(7) <= '0';
fp_led(6) <= '0'; 
fp_led(5) <= '0'; 
fp_led(4) <= '0'; 
fp_led(3) <= '0';
fp_led(2) <= '0'; 
fp_led(1) <= '0';
fp_led(0) <= '0';



pl_reset <= not pl_resetn;



reg_i_evr.ts_s <= evr_ts(63 downto 32);
reg_i_evr.ts_ns <= evr_ts(31 downto 0);





--embedded event receiver
evr: entity work.evr_top 
  generic map (
    SIM_MODE => SIM_MODE
  )
  port map(
    sys_clk => pl_clk0,
    sys_rst => pl_reset, 
    reg_o => reg_o_evr,
    --gth_reset => gth_reset,

    gth_refclk_p => gth_evr_refclk_p,  -- 312.5 MHz reference clock
    gth_refclk_n => gth_evr_refclk_n,
    gth_tx_p => gth_evr_tx_p,
    gth_tx_n => gth_evr_tx_n,
    gth_rx_p => gth_evr_rx_p,
    gth_rx_n => gth_evr_rx_n,
      
    --trignum => evr_dma_trignum, 
    trigdly => (x"00000001"), 
    tbt_trig => evr_tbt_trig, 
    fa_trig => evr_fa_trig, 
    sa_trig => evr_sa_trig, 
    usr_trig => evr_dma_trig, 
    gps_trig => evr_gps_trig, 
    timestamp => evr_ts,  
    evr_rcvd_clk => evr_rcvd_clk
);	




ps_pl: entity work.ps_io
  port map (
    pl_clock => pl_clk0, 
    pl_reset => not pl_resetn, 
    m_axi4_m2s => m_axi4_m2s, 
    m_axi4_s2m => m_axi4_s2m, 
    fp_leds => ps_leds,   
    reg_o_chaina_fifo => reg_o_chaina_fifo, 
	reg_i_chaina_fifo => reg_i_chaina_fifo,
	reg_o_evr => reg_o_evr, 
	reg_i_evr => reg_i_evr
          
  );




system_i: component system
  port map (
    pl_clk0 => pl_clk0,
    pl_clk1 => pl_clk1,
    pl_resetn => pl_resetn,
     
    m_axi_araddr => m_axi4_m2s.araddr, 
    m_axi_arprot => m_axi4_m2s.arprot,
    m_axi_arready => m_axi4_s2m.arready,
    m_axi_arvalid => m_axi4_m2s.arvalid,
    m_axi_awaddr => m_axi4_m2s.awaddr,
    m_axi_awprot => m_axi4_m2s.awprot,
    m_axi_awready => m_axi4_s2m.awready,
    m_axi_awvalid => m_axi4_m2s.awvalid,
    m_axi_bready => m_axi4_m2s.bready,
    m_axi_bresp => m_axi4_s2m.bresp,
    m_axi_bvalid => m_axi4_s2m.bvalid,
    m_axi_rdata => m_axi4_s2m.rdata,
    m_axi_rready => m_axi4_m2s.rready,
    m_axi_rresp => m_axi4_s2m.rresp,
    m_axi_rvalid => m_axi4_s2m.rvalid,
    m_axi_wdata => m_axi4_m2s.wdata,
    m_axi_wready => m_axi4_s2m.wready,
    m_axi_wstrb => m_axi4_m2s.wstrb,
    m_axi_wvalid => m_axi4_m2s.wvalid 
    );




--stretch the sa_trig signal so can be seen on LED
sa_led : entity work.stretch
  port map (
	clk => adc_clk,
	reset => pl_reset, 
	sig_in => sa_trig, 
	len => 3000000, -- ~25ms;
	sig_out => sa_trig_stretch
);	  	

--stretch the pscmsg (ioc write to device) signal so can be seen on LED
pscmsg_led : entity work.stretch
  port map (
	clk => pl_clk0,
	reset => pl_reset, 
	sig_in => ps_leds(0), 
	len => 3000000, -- ~25ms;
	sig_out => ps_fpled_stretch
);	  	



end behv;
