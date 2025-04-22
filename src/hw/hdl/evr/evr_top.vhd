----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/25/2018 03:41:53 PM
-- Design Name: 
-- Module Name: gtx_wrapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.acmi_package.ALL;



entity evr_top is
  generic (
    SIM_MODE      : integer := 0
  );
  port (
  sys_clk        : in std_logic;
  sys_rst        : in std_logic;
  reg_o          : in t_reg_o_evr;
  reg_i          : out t_reg_i_evr;
  --gth_reset      : in std_logic_vector(7 downto 0);
  
  gth_refclk_p   : in std_logic;
  gth_refclk_n   : in std_logic;
  gth_tx_p       : out std_logic;
  gth_tx_n       : out std_logic;
  gth_rx_p       : in std_logic;
  gth_rx_n       : in std_logic;
  
  --trignum        : in std_logic_vector(7 downto 0);
  trigdly        : in std_logic_vector(31 downto 0);
   

  tbt_trig       : out std_logic;
  fa_trig        : out std_logic;
  sa_trig        : out std_logic;
  usr_trig       : out std_logic;
  usr_trig_nodly : out std_logic;
  gps_trig       : out std_logic;
  timestamp      : out std_logic_vector(63 downto 0);
    
  evr_rcvd_clk   : out std_logic  

);  
 

end evr_top;

architecture behv of evr_top is



component timeofDayReceiver is
   port (
       clock        : in std_logic;
       reset        : in std_logic; 
       eventstream  : in std_logic_vector(7 downto 0);
       timestamp    : out std_logic_vector(63 downto 0); 
       seconds      : out std_logic_vector(31 downto 0); 
       offset       : out std_logic_vector(31 downto 0); 
       position     : out std_logic_vector(4 downto 0);
       eventclock   : out std_logic
 );
end component;


component EventReceiverChannel is 
    port (
       clock        : in std_logic;
       reset        : in std_logic;
       eventstream  : in std_logic_vector(7 downto 0); 
       myevent      : in std_logic_vector(7 downto 0);
       mydelay      : in std_logic_vector(31 downto 0); 
       mywidth      : in std_logic_vector(31 downto 0); 
       mypolarity   : in std_logic;
       trigger      : out std_logic 
);
end component;





component gth_wiz 
  port (
    gthrxn_in                            : in std_logic; 
    gthrxp_in                            : in std_logic;  
    gthtxn_out                           : out std_logic;  
    gthtxp_out                           : out std_logic;    
    gtwiz_reset_clk_freerun_in           : in std_logic;  
    gtwiz_reset_all_in                   : in std_logic;           
    drpclk_in                            : in std_logic; 
    gtrefclk0_in                         : in std_logic;  
    gtpowergood_out                      : out std_logic;  
    cpllfbclklost_out                    : out std_logic;  
    cplllock_out                         : out std_logic;  
    cpllrefclklost_out                   : out std_logic;       
     
    gtwiz_reset_tx_pll_and_datapath_in   : in std_logic;  
    gtwiz_reset_tx_datapath_in           : in std_logic;  
    gtwiz_reset_rx_pll_and_datapath_in   : in std_logic;  
    gtwiz_reset_rx_datapath_in           : in std_logic;  
    gtwiz_reset_rx_cdr_stable_out        : out std_logic;  
    gtwiz_reset_tx_done_out              : out std_logic;  
    gtwiz_reset_rx_done_out              : out std_logic;  
     
     gtwiz_userdata_tx_in                : in std_logic_vector(15 downto 0);  
     txctrl0_in                          : in std_logic_vector(15 downto 0);  
     txctrl1_in                          : in std_logic_vector(15 downto 0);   
     txctrl2_in                          : in std_logic_vector(7 downto 0);      
     tx8b10ben_in                        : in std_logic;  
     txoutclk_out                        : out std_logic;  
     txusrclk_in                         : in std_logic;  
     txusrclk2_in                        : in std_logic;  
     txpmaresetdone_out                  : out std_logic;       
     gtwiz_userclk_tx_reset_in           : in std_logic;  
     gtwiz_userclk_tx_active_in          : in std_logic; 

     gtwiz_userdata_rx_out               : out std_logic_vector(15 downto 0); 
     rxctrl0_out                         : out std_logic_vector(15 downto 0);     
     rxctrl1_out                         : out std_logic_vector(15 downto 0);  
     rxctrl2_out                         : out std_logic_vector(7 downto 0);  
     rxctrl3_out                         : out std_logic_vector(7 downto 0);   
     rxpolarity_in                       : in std_logic;
     rx8b10ben_in                        : in std_logic; 
     rxcommadeten_in                     : in std_logic;  
     rxmcommaalignen_in                  : in std_logic;  
     rxpcommaalignen_in                  : in std_logic; 
     rxoutclk_out                        : out std_logic;        
     rxusrclk_in                         : in std_logic;  
     rxusrclk2_in                        : in std_logic;  
     rxbyteisaligned_out                 : out std_logic; 
     rxbyterealign_out                   : out std_logic;  
     rxcommadet_out                      : out std_logic;  
     rxpmaresetdone_out                  : out std_logic;  
     gtwiz_userclk_rx_active_in          : in std_logic

);
end component; 





   
 
  signal gth_powergood   :  std_logic;
  signal gth_cpllfbclklost : std_logic;
  signal gth_cplllock      : std_logic;
  signal gth_cpllrefclklost  : std_logic;  
   
  signal gth_userclk_tx_srcclk : std_logic;
  signal gth_userclk_tx_usrclk : std_logic;
  signal gth_userclk_tx_usrclk2 : std_logic;
  signal gth_userclk_tx_active : std_logic; 
  signal gth_reset_tx_done     : std_logic;
  signal gth_txpmaresetdone    : std_logic;
  signal gth_txdata_in        : std_logic_vector(15 downto 0);
  signal gth_txcharisk_in      : std_logic_vector(7 downto 0);

  signal gth_userclk_rx_srcclk : std_logic;
  signal gth_userclk_rx_usrclk : std_logic;
  signal gth_userclk_rx_usrclk2 : std_logic;
  signal gth_userclk_rx_active : std_logic;
  signal gth_reset_rx_done     : std_logic;
  signal gth_rxpmaresetdone    : std_logic;
  signal gth_reset_rx_cdr_stable : std_logic;  
  signal gth_rxbyteisaligned   : std_logic;
  signal gth_rxbyterealign     : std_logic;
  signal gth_rxcommadet        : std_logic; 
  signal gth_rx_userdata       : std_logic_vector(15 downto 0);
  signal gth_rxctrl0           : std_logic_vector(15 downto 0);
  signal gth_rxctrl1           : std_logic_vector(15 downto 0);
  signal gth_rxctrl2           : std_logic_vector(7 downto 0);
  signal gth_rxctrl3           : std_logic_vector(7 downto 0);

  signal gth_refclk            : std_logic;
  signal gth_rxusr_clk         : std_logic;
  signal gth_rxout_clk         : std_logic;
  signal gth_txusr_clk         : std_logic;
  signal gth_txout_clk         : std_logic;
  signal gth_rxusr_clk_i       : std_logic;
 
  signal txcnt                 : std_logic_vector(15 downto 0) := 16d"0";
  
  
  signal tbt_trig_i        : std_logic;
  signal datastream        : std_logic_vector(7 downto 0);
  signal eventstream       : std_logic_vector(7 downto 0);
  signal eventclock        : std_logic;
   
  signal prev_datastream   : std_logic_vector(3 downto 0);
  signal cnt               : integer range 3 downto 0;
  signal trigactive        : std_logic;
  signal fe_trigno         : std_logic_vector(7 downto 0);
  signal fe_trigdly        : std_logic_vector(31 downto 0);
  
  signal usr_trig_last     : std_logic;
  
  
  

   attribute mark_debug     : string;
   attribute mark_debug of gth_txdata_in: signal is "true";  
   attribute mark_debug of gth_txcharisk_in: signal is "true";
   attribute mark_debug of gth_rx_userdata: signal is "true";
   attribute mark_debug of gth_rxctrl2: signal is "true";
   attribute mark_debug of gth_cplllock: signal is "true";
   attribute mark_debug of gth_powergood: signal is "true";
   attribute mark_debug of gth_reset_rx_done: signal is "true";

   attribute mark_debug of eventstream: signal is "true";
   attribute mark_debug of datastream: signal is "true";
   attribute mark_debug of timestamp: signal is "true";
   attribute mark_debug of eventclock: signal is "true";
   attribute mark_debug of prev_datastream: signal is "true";
   attribute mark_debug of tbt_trig: signal is "true";
   attribute mark_debug of tbt_trig_i: signal is "true";
   attribute mark_debug of fe_trigno: signal is "true";
   attribute mark_debug of fe_trigdly: signal is "true";
   attribute mark_debug of usr_trig: signal is "true";




begin 

evr_rcvd_clk <= gth_rxusr_clk;

fe_trigno <= reg_o.fe_trigno;
fe_trigdly <= reg_o.fe_trigdly;

reg_i.ts_s <= timestamp(63 downto 32);
reg_i.ts_ns <= timestamp(31 downto 0);
        


refclk0_buf : IBUFDS_GTE4
  generic map (
    REFCLK_EN_TX_PATH => '0',   -- Refer to Transceiver User Guide
    REFCLK_HROW_CK_SEL => "00", -- Refer to Transceiver User Guide
    REFCLK_ICNTL_RX => "00"     -- Refer to Transceiver User Guide
 )
  port map (
      O => gth_refclk,         -- 1-bit output: Refer to Transceiver User Guide
      ODIV2 => open, --gth_refclk_odiv2,  -- 1-bit output: Refer to Transceiver User Guide
      CEB => '0',     -- 1-bit input: Refer to Transceiver User Guide
      I => gth_refclk_p,         -- 1-bit input: Refer to Transceiver User Guide
      IB => gth_refclk_n        -- 1-bit input: Refer to Transceiver User Guide
   );   
   
--for debug, sends refclk to debug header   
--BUFG_GT_refclk : BUFG_GT
--   port map (
--      O => gth_refclk_buf,             -- 1-bit output: Buffer
--      CE => '1',           -- 1-bit input: Buffer enable
--      CEMASK => '0',   -- 1-bit input: CE Mask
--      CLR => '0', --gth_reset(0),         -- 1-bit input: Asynchronous clear
--      CLRMASK => '0', -- 1-bit input: CLR Mask
--      DIV => "000",         -- 3-bit input: Dynamic divide Value
--      I => gth_refclk_odiv2              -- 1-bit input: Buffer
--   );



--latch timestamp --...
process (gth_rxusr_clk)
begin
  if (rising_edge(gth_rxusr_clk)) then
    if (sys_rst = '1') then
      usr_trig_last <= '0';
    else
      usr_trig_last <= usr_trig;
      if (usr_trig = '1') and (usr_trig_last = '0') then
        reg_i.lat_ts_s <= timestamp(63 downto 32);
        reg_i.lat_ts_ns <= timestamp(31 downto 0);
      end if;
    end if;
  end if;
end process;








-- tx a counter
process (gth_txusr_clk)
begin
  if (rising_edge(gth_txusr_clk)) then
    if (sys_rst = '1') then
      gth_txdata_in <= x"50BC";
      gth_txcharisk_in <= x"01";
      txcnt <= 16d"0";
    else
      if (txcnt = 16d"500") then
        gth_txdata_in <= x"50BC";
        gth_txcharisk_in <= x"01";
        txcnt <= 16d"0"; 
      else
        gth_txdata_in <= txcnt;
        gth_txcharisk_in <= x"00";
        txcnt <= txcnt + 1;
      end if;
    end if;
  end if;
end process;
             


BUFG_GT_rx : BUFG_GT
   port map (
      O => gth_rxusr_clk,             -- 1-bit output: Buffer
      CE => '1',           -- 1-bit input: Buffer enable
      CEMASK => '0',   -- 1-bit input: CE Mask
      CLR => reg_o.reset, --gth_reset(0),         -- 1-bit input: Asynchronous clear
      CLRMASK => '0', -- 1-bit input: CLR Mask
      DIV => "000",         -- 3-bit input: Dynamic divide Value
      I => gth_rxout_clk              -- 1-bit input: Buffer
   );

BUFG_GT_tx : BUFG_GT
   port map (
      O => gth_txusr_clk,             -- 1-bit output: Buffer
      CE => '1',           -- 1-bit input: Buffer enable
      CEMASK => '0',   -- 1-bit input: CE Mask
      CLR => reg_o.reset, --gth_reset(0),         -- 1-bit input: Asynchronous clear
      CLRMASK => '0', -- 1-bit input: CLR Mask
      DIV => "000",         -- 3-bit input: Dynamic divide Value
      I => gth_txout_clk              -- 1-bit input: Buffer
   );



--stretch tbt_trig for a few clock cycles
process (gth_rxusr_clk)
begin 
   if (rising_edge(gth_rxusr_clk)) then
      if (sys_rst = '1') then
         tbt_trig <= '0';
         cnt <= 0;
         trigactive <= '0';
      else        
         if (tbt_trig_i = '1') then
            tbt_trig <= '1';
            trigactive <= '1';
         end if;
         if (trigactive = '1') then
           if (cnt = 3) then
             tbt_trig <= '0';
             trigactive <= '0';
             cnt <= 0;
           else
             cnt <= cnt + 1;
           end if;
         end if;
      end if;
   end if;
end process;

 


evr_sim: if (SIM_MODE = 1) generate evr_tb:

-- generate evr clock - need to adjust to correct frequency, use internal tbt-trig for simulation
 process
     begin
         gth_rxusr_clk <= '0';
         wait for 4 ns;
         gth_rxusr_clk <= '1';
         wait for 4 ns;
end process;

--tbt gen 
process 
  begin
    tbt_trig_i <= '0';
    wait for 4 ns;
    tbt_trig_i <= '1';
    wait for 8 ns;
    tbt_trig_i <= '0';
    wait for 8*310 ns;

end process;

end generate;



evr_syn: if (SIM_MODE = 0) generate evr_logic:

--tbt_trig <= datastream(0);
--datastream 0 toggles high/low for half of Frev.  Filter on the first low to high transition
--and ignore the rest
process (gth_rxusr_clk)
begin
  if rising_edge(gth_rxusr_clk) then
    if (sys_rst = '1') then
      tbt_trig_i <= '0'; 
    else
      prev_datastream(0) <= datastream(0);
      prev_datastream(1) <= prev_datastream(0);
      prev_datastream(2) <= prev_datastream(1);
      prev_datastream(3) <= prev_datastream(2);
      if (prev_datastream = "0001") then
        tbt_trig_i <= '1';
      else
        tbt_trig_i <= '0';
      end if;
    end if;
   end if;
end process;


--datastream <= gt0_rxdata(7 downto 0);
--eventstream <= gt0_rxdata(15 downto 8);
--switch byte locations of datastream and eventstream  9-20-18
datastream <= gth_rx_userdata(15 downto 8);
eventstream <= gth_rx_userdata(7 downto 0);



	
-- timestamp decoder
ts : timeofDayReceiver
   port map(
       clock => gth_rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       timestamp => timestamp,
       seconds => open, 
       offset => open, 
       position => open, 
       eventclock => eventclock
 );


-- 1 Hz GPS tick	
event_gps : EventReceiverChannel
    port map(
       clock => gth_rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => (x"7D"),     -- 125d
       mydelay => (x"00000001"),
       mywidth => (x"00000175"),   -- //creates a pulse about 3us long
       mypolarity => ('0'),
       trigger => gps_trig
);


-- 10 Hz 	
event_10Hz : EventReceiverChannel
    port map(
       clock => gth_rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => (x"1E"),     -- 30d
       mydelay => (x"00000001"),
       mywidth => (x"00000175"),   -- //creates a pulse about 3us long
       mypolarity => ('0'),
       trigger => sa_trig
);


-- 10 KHz 	
event_10KHz : EventReceiverChannel
    port map(
       clock => gth_rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => (x"1F"),     -- 31d
       mydelay => (x"00000001"),
       mywidth => (x"00000175"),   -- //creates a pulse about 3us long
       mypolarity => ('0'),
       trigger => fa_trig
);
		
		
-- On demand 	
event_usr : EventReceiverChannel
    port map(
       clock => gth_rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => fe_trigno, 
       mydelay => fe_trigdly, 
       mywidth => (x"00000175"),   -- //creates a pulse about 3us long
       mypolarity => ('0'),
       trigger => usr_trig
);

event_usr_nodly : EventReceiverChannel --creusr_trig_nodlyate a evr trig w/o delay
    port map(
       clock => gth_rxusr_clk,
       reset => sys_rst,
       eventstream => eventstream,
       myevent => fe_trigno, 
       mydelay => (x"00000000"), 
       mywidth => (x"00000175"),   -- //creates a pulse about 3us long
       mypolarity => ('0'),
       trigger => usr_trig_nodly
);


  gth : gth_wiz 
    port map(
     gthrxn_in => gth_rx_n,
     gthrxp_in => gth_rx_p, 
     gthtxn_out => gth_tx_n, 
     gthtxp_out => gth_tx_p,   
     gtwiz_reset_clk_freerun_in => sys_clk, 
     gtwiz_reset_all_in => reg_o.reset, --gth_reset(0),          
     drpclk_in => sys_clk,
     gtrefclk0_in => gth_refclk, 
     gtpowergood_out => gth_powergood, 
     cpllfbclklost_out => gth_cpllfbclklost, 
     cplllock_out => gth_cplllock, 
     cpllrefclklost_out => gth_cpllrefclklost,      
     
     gtwiz_reset_tx_pll_and_datapath_in => reg_o.reset, --gth_reset(0), 
     gtwiz_reset_tx_datapath_in => reg_o.reset, --gth_reset(0), 
     gtwiz_reset_rx_pll_and_datapath_in => reg_o.reset, --gth_reset(0), 
     gtwiz_reset_rx_datapath_in => reg_o.reset, --gth_reset(0), 
     gtwiz_reset_rx_cdr_stable_out => gth_reset_rx_cdr_stable, 
     gtwiz_reset_tx_done_out => gth_reset_tx_done, 
     gtwiz_reset_rx_done_out => gth_reset_rx_done, 
     
     gtwiz_userdata_tx_in => gth_txdata_in, 
     txctrl0_in  => x"0000",
     txctrl1_in => x"0000", 
     txctrl2_in => gth_txcharisk_in,      
     tx8b10ben_in => '1', 
     txoutclk_out => gth_txout_clk, 
     txusrclk_in => gth_txusr_clk, 
     txusrclk2_in => gth_txusr_clk, 
     txpmaresetdone_out => gth_txpmaresetdone,      
     gtwiz_userclk_tx_reset_in => reg_o.reset, --gth_reset(0), 
     gtwiz_userclk_tx_active_in => not reg_o.reset, --gth_reset(0),

     gtwiz_userdata_rx_out => gth_rx_userdata,
     rxctrl0_out => gth_rxctrl0, 
     rxctrl1_out => gth_rxctrl1, 
     rxctrl2_out => gth_rxctrl2, 
     rxctrl3_out => gth_rxctrl3,  
     rxpolarity_in => '1',
     rx8b10ben_in  => '1',
     rxcommadeten_in => '1', 
     rxmcommaalignen_in => '1', 
     rxpcommaalignen_in => '1',
     rxoutclk_out => gth_rxout_clk,       
     rxusrclk_in => gth_rxusr_clk, 
     rxusrclk2_in => gth_rxusr_clk, 
     rxbyteisaligned_out => gth_rxbyteisaligned, 
     rxbyterealign_out => gth_rxbyterealign, 
     rxcommadet_out => gth_rxcommadet, 
     rxpmaresetdone_out => gth_rxpmaresetdone, 
     gtwiz_userclk_rx_active_in  => not reg_o.reset --gth_reset(0) --*

);

end generate;

end behv;
