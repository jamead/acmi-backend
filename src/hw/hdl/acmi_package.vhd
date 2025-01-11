
library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


  
package acmi_package is




type t_reg_i_chaina is record
   fifo_dout     : std_logic_vector(31 downto 0);
   fifo_rdcnt    : std_logic_vector(15 downto 0); 
end record t_reg_i_chaina;

type t_reg_o_chaina is record
   spi_data      : std_logic_vector(31 downto 0);
   spi_addr      : std_logic_vector(31 downto 0);
   spi_we        : std_logic;
   fifo_enb      : std_logic;
   fifo_rst      : std_logic;
   fifo_rdstr    : std_logic;
end record t_reg_o_chaina;




type t_reg_o_evr is record
   reset         : std_logic;
   dma_trigno    : std_logic_vector(7 downto 0);
   event_src_sel : std_logic;
end record t_reg_o_evr;

type t_reg_i_evr is record
   ts_ns      : std_logic_vector(31 downto 0);
   ts_s       : std_logic_vector(31 downto 0);
   lat_ts_ns  : std_logic_vector(31 downto 0);
   lat_ts_s   : std_logic_vector(31 downto 0);
end record t_reg_i_evr;







--type brd_temps_type is record
--   temp0 : std_logic_vector(15 downto 0);
--   temp1 : std_logic_vector(15 downto 0);
--   temp2 : std_logic_vector(15 downto 0);
--   temp3 : std_logic_vector(15 downto 0);
--end record brd_temps_type;


--type afe_regs_type is record
--   temp0 : std_logic_vector(15 downto 0);
--   temp1 : std_logic_vector(15 downto 0);
--   temp2 : std_logic_vector(15 downto 0);
--   temp3 : std_logic_vector(15 downto 0);
--   Vreg0 : std_logic_vector(15 downto 0);
--   Vreg1 : std_logic_vector(15 downto 0);
--   Vreg2 : std_logic_vector(15 downto 0);
--   Vreg3 : std_logic_vector(15 downto 0);
--   Vreg4 : std_logic_vector(15 downto 0);
--   Vreg5 : std_logic_vector(15 downto 0);
--   Vreg6 : std_logic_vector(15 downto 0);
--   Vreg7 : std_logic_vector(15 downto 0);
--   Ireg0 : std_logic_vector(15 downto 0);
--   Ireg1 : std_logic_vector(15 downto 0);
--   Ireg2 : std_logic_vector(15 downto 0);
--   Ireg3 : std_logic_vector(15 downto 0);
--   Ireg4 : std_logic_vector(15 downto 0);
--   Ireg5 : std_logic_vector(15 downto 0);
--   Ireg6 : std_logic_vector(15 downto 0);
--   Ireg7 : std_logic_vector(15 downto 0);
--end record afe_regs_type;





component system is
  port (
    pl_clk0 : out STD_LOGIC;
    pl_clk1 : out std_logic;
    pl_resetn : out STD_LOGIC;
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC                
  );
  end component system;





	


end acmi_package;
  
