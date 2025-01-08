
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library desyrdl;
use desyrdl.common.all;
use desyrdl.pkg_pl_regs.all;

library xil_defaultlib;
use xil_defaultlib.acmi_package.ALL;

library work;
use work.acmi_package.ALL;


entity ps_io is
  port (  
     pl_clock          : in std_logic;
     pl_reset          : in std_logic;
   
     m_axi4_m2s        : in t_pl_regs_m2s;
     m_axi4_s2m        : out t_pl_regs_s2m;   
     	
	 reg_o_chaina_fifo : out t_reg_o_chaina_fifo_rdout;
	 reg_i_chaina_fifo : in  t_reg_i_chaina_fifo_rdout; 

	 reg_o_evr         : out t_reg_o_evr;
	 reg_i_evr         : in  t_reg_i_evr;
 
     fp_leds           : out std_logic_vector(7 downto 0)
  );
end ps_io;


architecture behv of ps_io is

  

  
  signal reg_i        : t_addrmap_pl_regs_in;
  signal reg_o        : t_addrmap_pl_regs_out;

  --attribute mark_debug     : string;
  --attribute mark_debug of reg_o: signal is "true";



begin

fp_leds <= reg_o.FP_LEDS.val.data;

reg_o_chaina_fifo.enb <= reg_o.chaina_fifo_streamenb.data.swmod;
reg_o_chaina_fifo.rst <= reg_o.chaina_fifo_reset.data.data(0);
reg_o_chaina_fifo.rdstr <= reg_o.chaina_fifo_data.data.swacc;
reg_i.chaina_fifo_rdcnt.data.data <= reg_i_chaina_fifo.rdcnt;
reg_i.chaina_fifo_data.data.data <= reg_i_chaina_fifo.dout;

reg_i.ts_ns.val.data <= reg_i_evr.ts_ns; --x"12345678";
reg_i.ts_s.val.data <= reg_i_evr.ts_s; --x"deadbeef";
reg_i.lat_ts_ns.val.data <= reg_i_evr.lat_ts_ns; --x"0123face";
reg_i.lat_ts_s.val.data <= reg_i_evr.lat_ts_s; --x"ba5eba11";

reg_o_evr.reset <= reg_o.evr_reset.data.data(0);
reg_o_evr.dma_trigno <= reg_o.dma_trig_eventno.val.data;
reg_o_evr.event_src_sel <= reg_o.event_src_sel.val.data(0);





regs: pl_regs
  port map (
    pi_clock => pl_clock, 
    pi_reset => pl_reset, 

    pi_s_top => m_axi4_m2s, 
    po_s_top => m_axi4_s2m, 
    -- to logic interface
    pi_addrmap => reg_i,  
    po_addrmap => reg_o
  );





end behv;
