
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity artix_data_rdout is
  port (
    sys_clk         : in std_logic; 
    gth_rxusr_clk   : in std_logic;
    gth_rx_data     : in std_logic_vector(31 downto 0);
    gth_rx_data_enb : in std_logic;
    fifo_rst        : in std_logic; 
    fifo_rdstr      : in std_logic; 
    fifo_dout       : out std_logic_vector(31 downto 0); 
    fifo_rdcnt      : out std_logic_vector(15 downto 0)
 );
end artix_data_rdout;

architecture behv of artix_data_rdout is


component wvfm_fifo
  port (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
end component; 


  type state_type is (IDLE, FIFO_WRITE_HDR, FIFO_WRITE_DATA);                    
  signal   state   : state_type   := idle;

  signal fifo_rdstr_prev  : std_logic  := '0';
  signal fifo_rdstr_fe    : std_logic  := '0';
  signal fifo_din         : std_logic_vector(15 downto 0) := 16d"0";
  signal fifo_wren        : std_logic := '0'; 
  signal fifo_readcnt     : std_logic_vector(14 downto 0); 

  



  attribute mark_debug                 : string;

  attribute mark_debug of gth_rx_data: signal is "true";
  attribute mark_debug of gth_rx_data_enb: signal is "true";
  attribute mark_debug of fifo_rdcnt: signal is "true";
  attribute mark_debug of fifo_dout: signal is "true";
  attribute mark_debug of fifo_rdstr_fe: signal is "true";
  attribute mark_debug of fifo_rst: signal is "true";
  

begin

fifo_rdcnt <= '0' & fifo_readcnt;


--since fifo is fall-through mode, want the rdstr
--to happen after the current word is read.
process (sys_clk)
  begin
    if (rising_edge(sys_clk)) then
      fifo_rdstr_prev <= fifo_rdstr;
      if (fifo_rdstr = '0' and fifo_rdstr_prev = '1') then
        fifo_rdstr_fe <= '1'; --falling edge
      else
        fifo_rdstr_fe <= '0';
      end if;
    end if;
end process;
        




fifo_inst : wvfm_fifo
  PORT MAP (
    rst => fifo_rst,
    wr_clk => gth_rxusr_clk, 
    rd_clk => sys_clk,
    din => gth_rx_data, 
    wr_en => gth_rx_data_enb, 
    rd_en => fifo_rdstr, --fifo_rdstr_fe,
    dout => fifo_dout,
    full => open,
    empty => open,
    rd_data_count => fifo_readcnt
  );



end behv;
