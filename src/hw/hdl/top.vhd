
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
    FPGA_VERSION			: integer := 1;
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
    
    --artix transceiver
    gth_fe_refclk_p         : in std_logic;
    gth_fe_refclk_n         : in std_logic;
    gth_fe0_tx_p            : out std_logic;
    gth_fe0_tx_n            : out std_logic;
    gth_fe0_rx_p            : in std_logic;
    gth_fe0_rx_n            : in std_logic;    
    
    
    
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
  signal gth_freerun_clk : std_logic;
  signal pl_resetn       : std_logic;
  signal pl_reset        : std_logic;
  signal gth_clk_plllocked : std_logic;
  
  signal ps_leds         : std_logic_vector(7 downto 0);
  
  signal m_axi4_m2s      : t_pl_regs_m2s;
  signal m_axi4_s2m      : t_pl_regs_s2m;
  
  signal reg_o_evr       : t_reg_o_evr;
  signal reg_i_evr       : t_reg_i_evr;
  
  signal reg_i_chaina    : t_reg_i_chaina;
  signal reg_o_chaina    : t_reg_o_chaina;
   
  
  signal evr_tbt_trig         : std_logic;
  signal evr_fa_trig          : std_logic;
  signal evr_sa_trig          : std_logic;
  signal evr_sa_trig_stretch  : std_logic;
  signal evr_gps_trig         : std_logic;
  signal evr_usr_trig         : std_logic;
  signal evr_usr_trig_nodly   : std_logic;  
  signal evr_usr_trig_stretch : std_logic;
  signal evr_ts               : std_logic_vector(63 downto 0); 
  signal evr_rcvd_clk         : std_logic;
  signal evr_ref_clk          : std_logic;
   
  signal fe_trigsrc           : std_logic;
  
  signal inttrig_enb     : std_logic_vector(3 downto 0);
  signal trig_evrintsel  : std_logic;
--  signal tbt_gate        : std_logic;
--  signal tbt_trig        : std_logic;
--  signal pt_trig         : std_logic;
--  signal fa_trig         : std_logic;
--  signal sa_trig         : std_logic;
--  signal sa_trig_stretch : std_logic;
  signal ps_fpled_stretch: std_logic;
--  signal dma_trig        : std_logic;

  signal gth_tx_data     : std_logic_vector(31 downto 0);
  signal gth_tx_data_enb : std_logic;
  signal gth_txusr_clk   : std_logic;
   
  signal gth_rx_data     : std_logic_vector(31 downto 0);
  signal gth_rx_data_enb : std_logic;
  signal gth_rxusr_clk   : std_logic; 




  --attribute mark_debug     : string;
  --attribute mark_debug of reg_o: signal is "true";

 

begin




dbg(0) <= pl_clk0;
dbg(1) <= gth_freerun_clk;
dbg(2) <= '0';
dbg(3) <= evr_usr_trig;
dbg(4) <= '0';
dbg(5) <= '0';
dbg(6) <= '0'; 
dbg(7) <= '0'; 
dbg(8) <= '0'; 
dbg(9) <= evr_tbt_trig;
dbg(10) <= evr_fa_trig;
dbg(11) <= evr_sa_trig;
dbg(12) <= '0'; 
dbg(13) <= '0';
dbg(14) <= '0';
dbg(15) <= '0';
dbg(16) <= fp_in(0);
dbg(17) <= fp_in(1);
dbg(18) <= fp_in(2);
dbg(19) <= fp_in(3);


fp_out(0) <= evr_usr_trig; --pl_clk0;
fp_out(1) <= '0'; --evr_rcvd_clk; --pl_clk1; --adc_clk_in;
fp_out(2) <= '0'; --gth_txusr_clk; --'0';
fp_out(3) <= '0'; --gth_rxusr_clk; --'0'; 

fp_led(7) <= evr_sa_trig_stretch;
fp_led(6) <= evr_usr_trig_stretch;  
fp_led(5) <= ps_fpled_stretch;  
fp_led(4) <= '0'; 
fp_led(3) <= '0';
fp_led(2) <= '0'; 
fp_led(1) <= '0';
fp_led(0) <= fe_trigsrc; --gth_clk_plllocked;



pl_reset <= not pl_resetn;


--moved to EVR 
--reg_i_evr.ts_s <= evr_ts(63 downto 32);
--reg_i_evr.ts_ns <= evr_ts(31 downto 0);




chaina_io: entity work.gth_artix_io
  port map(
  sys_clk => pl_clk0, 
  sys_rst => pl_reset,   
  gth_reset => reg_o_evr.reset,
  
  reg_o => reg_o_chaina,  
  reg_i => reg_i_chaina,       
  
  evr_usr_trig => evr_usr_trig,
  
  gth_txusr_clk => gth_txusr_clk, 
  gth_rxusr_clk => gth_rxusr_clk, 
  
  gth_refclk_p => gth_fe_refclk_p, 
  gth_refclk_n => gth_fe_refclk_n, 

  gth_rx_p => gth_fe0_rx_p, 
  gth_rx_n => gth_fe0_rx_n, 
  gth_tx_p => gth_fe0_tx_p, 
  gth_tx_n => gth_fe0_tx_n   

);  
 


--embedded event receiver
evr: entity work.evr_top 
  generic map (
    SIM_MODE => SIM_MODE
  )
  port map(
    sys_clk => pl_clk0,
    sys_rst => pl_reset, 
    reg_o => reg_o_evr,
    reg_i => reg_i_evr,
    --gth_reset => gth_reset,

    gth_refclk_p => gth_evr_refclk_p,  -- 312.5 MHz reference clock
    gth_refclk_n => gth_evr_refclk_n,
    gth_tx_p => gth_evr_tx_p,
    gth_tx_n => gth_evr_tx_n,
    gth_rx_p => gth_evr_rx_p,
    gth_rx_n => gth_evr_rx_n,

    trigdly => (x"00000001"), 
    tbt_trig => evr_tbt_trig, 
    fa_trig => evr_fa_trig, 
    sa_trig => evr_sa_trig, 
    usr_trig => evr_usr_trig, 
    usr_trig_nodly => evr_usr_trig_nodly,
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
    fe_trigsrc => fe_trigsrc,   --0=internal, 1=evr
    reg_o_chaina => reg_o_chaina, 
	reg_i_chaina => reg_i_chaina,
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
	clk => pl_clk0,
	reset => pl_reset, 
	sig_in => evr_sa_trig, 
	len => 3000000, -- ~25ms;
	sig_out => evr_sa_trig_stretch
);	  	


--stretch the usr_trig signal so can be seen on LED
use_led : entity work.stretch
  port map (
	clk => pl_clk0,
	reset => pl_reset, 
	sig_in => evr_usr_trig, 
	len => 3000000, -- ~25ms;
	sig_out => evr_usr_trig_stretch
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
