--! Standard library
library ieee;
--! Standard package
use ieee.std_logic_1164.all;
--! Signed/unsigned calculations
use ieee.numeric_std.all;
--! Math real
use ieee.math_real.all;
--! TextIO
use ieee.std_logic_textio.all;
--! Standard functions
library std;
--! Standard TextIO functions
use std.textio.all;

--! Xilinx library
library unisim;
--! Xilinx package
use unisim.vcomponents.all;

--! User packages
use work.tf_pkg.all;
use work.memUtil_pkg.all;

--! @brief TB
entity tb_tf_top is
end tb_tf_top;

--! @brief TB
architecture behaviour of tb_tf_top is

  -- ########################### Constant Definitions ###########################
  -- ############ Please change the constants in this section ###################

  --=========================================================================
  -- Specify version of chain to run from TB:
  --    0 = SectorProcessor.vhd from python script.
  --    1 = SectorProcessorFull.vhd from python script (gives intermediate MemPrints).
  --    N.B. Change this also in makeProject.tcl !
  constant INST_TOP_TF          : integer := 0; 
  --=========================================================================

  constant CLK_PERIOD   : time    := 25.0 ns; --! 40 MHz
  constant DEBUG        : boolean := False;   --! Debug off/on

  -- Paths of data files specified relative to Vivado project's xsim directory.
  -- e.g. IntegrationTests/PRMEMC/script/Work/Work.sim/sim_1/behav/xsim/
  constant memPrintsDir         : string := "../../../../../MemPrints/";
  constant dataOutDir           : string := "../../../../../dataOut/";

  -- File directories and the start of the file names that memories have in common
  -- Input files
  constant FILE_IN_DL_39        : string := memPrintsDir&"InputStubs/Link_";
  -- Output files
  constant FILE_OUT_DL_39       : string := dataOutDir;
  constant FILE_OUT_IL_36       : string := dataOutDir;
  constant FILE_OUT_AS_36       : string := dataOutDir;
  constant FILE_OUT_AS_51       : string := dataOutDir;
  constant FILE_OUT_VMSTE_16    : string := dataOutDir;
  constant FILE_OUT_VMSTE_17    : string := dataOutDir;
  constant FILE_OUT_TPAR_73     : string := dataOutDir;
  -- Debug output files to check input was correctly read.
  constant FILE_OUT_DL_debug    : string := dataOutDir;

  -- File name endings
  constant inputFileNameEnding  : string := "_04.dat"; -- 04 specifies the nonant/sector the testvectors represent
  constant outputFileNameEnding : string := ".txt";
  constant debugFileNameEnding  : string := ".debug.txt";


  -- ########################### Signals ###########################
  -- ### UUT signals ###
  signal clk                           : std_logic := '0';
  signal clk360                        : std_logic;
  signal clk240                        : std_logic;
  signal locked                        : std_logic;
  signal reset                      : std_logic := '1';
  signal IR_start                   : std_logic := '0';
  signal IR_idle                    : std_logic := '0';
  signal IR_ready                   : std_logic := '0';
  signal IR_bx_in                   : std_logic_vector(2 downto 0) := (others => '1');
  signal IR_bx_out                  : std_logic_vector(2 downto 0) := (others => '1');
  signal IR_bx_out_vld              : std_logic := '0';
  signal IR_done                    : std_logic := '0';
  signal VMR_bx_out                 : std_logic_vector(2 downto 0) := (others => '1');
  signal VMR_bx_out_vld             : std_logic := '0';
  signal VMR_done                   : std_logic := '0';
  signal TP_bx_out                  : std_logic_vector(2 downto 0) := (others => '1');
  signal TP_bx_out_vld              : std_logic := '0';
  signal TP_done                    : std_logic := '0';

  -- Signals matching ports of top-level VHDL
  signal DL_PS10G_1_A_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_1_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_1_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_1_B_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_1_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_1_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_2_A_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_2_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_2_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_2_B_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_2_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_2_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_3_A_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_3_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_3_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_3_B_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_3_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_3_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_4_A_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_4_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_4_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS10G_4_B_link_read     : t_DL_39_1b           := '0';
  signal DL_PS10G_4_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_PS10G_4_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_PS_1_A_link_read        : t_DL_39_1b           := '0';
  signal DL_PS_1_A_link_empty_neg   : t_DL_39_1b           := '0';
  signal DL_PS_1_A_link_AV_dout     : t_DL_39_DATA         := (others => '0');
  signal DL_PS_1_B_link_read        : t_DL_39_1b           := '0';
  signal DL_PS_1_B_link_empty_neg   : t_DL_39_1b           := '0';
  signal DL_PS_1_B_link_AV_dout     : t_DL_39_DATA         := (others => '0');
  signal DL_PS_2_A_link_read        : t_DL_39_1b           := '0';
  signal DL_PS_2_A_link_empty_neg   : t_DL_39_1b           := '0';
  signal DL_PS_2_A_link_AV_dout     : t_DL_39_DATA         := (others => '0');
  signal DL_PS_2_B_link_read        : t_DL_39_1b           := '0';
  signal DL_PS_2_B_link_empty_neg   : t_DL_39_1b           := '0';
  signal DL_PS_2_B_link_AV_dout     : t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_1_A_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_1_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_1_A_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_1_B_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_1_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_1_B_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_2_A_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_2_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_2_A_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_2_B_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_2_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_2_B_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_3_A_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_3_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_3_A_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_3_B_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_3_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_3_B_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_4_A_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_4_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_4_A_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS10G_4_B_link_read  : t_DL_39_1b           := '0';
  signal DL_negPS10G_4_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS10G_4_B_link_AV_dout: t_DL_39_DATA         := (others => '0');
  signal DL_negPS_1_A_link_read     : t_DL_39_1b           := '0';
  signal DL_negPS_1_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS_1_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_negPS_1_B_link_read     : t_DL_39_1b           := '0';
  signal DL_negPS_1_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS_1_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_negPS_2_A_link_read     : t_DL_39_1b           := '0';
  signal DL_negPS_2_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS_2_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_negPS_2_B_link_read     : t_DL_39_1b           := '0';
  signal DL_negPS_2_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_negPS_2_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_1_A_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_1_A_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_1_A_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_1_B_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_1_B_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_1_B_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_2_A_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_2_A_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_2_A_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_2_B_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_2_B_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_2_B_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_3_A_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_3_A_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_3_A_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_3_B_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_3_B_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_3_B_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_4_A_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_4_A_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_4_A_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_4_B_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_4_B_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_4_B_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_5_A_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_5_A_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_5_A_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_5_B_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_5_B_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_5_B_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_6_A_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_6_A_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_6_A_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_twoS_6_B_link_read      : t_DL_39_1b           := '0';
  signal DL_twoS_6_B_link_empty_neg : t_DL_39_1b           := '0';
  signal DL_twoS_6_B_link_AV_dout   : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_1_A_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_1_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_1_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_1_B_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_1_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_1_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_2_A_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_2_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_2_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_2_B_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_2_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_2_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_3_A_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_3_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_3_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_3_B_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_3_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_3_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_4_A_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_4_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_4_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_4_B_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_4_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_4_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_5_A_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_5_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_5_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_5_B_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_5_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_5_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_6_A_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_6_A_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_6_A_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal DL_neg2S_6_B_link_read     : t_DL_39_1b           := '0';
  signal DL_neg2S_6_B_link_empty_neg: t_DL_39_1b           := '0';
  signal DL_neg2S_6_B_link_AV_dout  : t_DL_39_DATA         := (others => '0');
  signal IL_L1PHIA_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIA_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIA_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIB_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIB_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIB_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIC_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIC_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIC_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHID_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHID_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHID_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIE_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIE_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIE_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIG_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIG_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIG_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIH_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIH_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIH_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIA_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIA_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIA_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIB_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIB_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIC_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIC_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHID_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHID_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHID_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIA_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIA_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIA_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIB_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIB_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIC_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIC_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHID_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHID_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHID_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIA_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIA_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIA_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIB_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIB_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_PS10G_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIC_PS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_PS10G_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIC_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHID_PS10G_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHID_PS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHID_PS10G_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIA_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIA_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIA_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIB_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIB_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIB_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIC_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIC_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIC_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHID_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHID_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHID_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHID_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHID_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHID_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIE_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIE_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIE_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIE_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIE_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIE_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIF_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIF_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIF_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIG_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIG_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIG_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIH_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L1PHIH_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIH_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIA_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHID_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIA_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIA_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIA_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIB_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIB_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_PS10G_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIC_PS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_PS10G_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIC_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHID_PS10G_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHID_PS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHID_PS10G_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIA_PS10G_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_L2PHIA_PS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIA_PS10G_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIB_PS10G_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_L2PHIB_PS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIB_PS10G_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIB_PS10G_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_L2PHIB_PS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIB_PS10G_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIC_PS10G_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_L2PHIC_PS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIC_PS10G_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIC_PS10G_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_L2PHIC_PS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIC_PS10G_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHID_PS10G_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_L2PHID_PS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHID_PS10G_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_PS10G_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIA_PS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_PS10G_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_PS10G_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_PS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_PS10G_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_PS10G_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_PS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_PS10G_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_PS10G_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_PS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_PS10G_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_PS10G_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_PS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_PS10G_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_PS10G_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHID_PS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_PS10G_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIA_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIA_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIA_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIB_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIB_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIC_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIC_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHID_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHID_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHID_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIA_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIA_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIA_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIB_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIB_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIC_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIC_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHID_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHID_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHID_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIA_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIA_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIA_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIB_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIB_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_PS10G_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIC_PS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_PS10G_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIC_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHID_PS10G_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHID_PS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHID_PS10G_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIA_PS_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIA_PS_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIA_PS_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_PS_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIB_PS_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_PS_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIC_PS_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIC_PS_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIC_PS_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHID_PS_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHID_PS_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHID_PS_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_PS_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIA_PS_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_PS_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_PS_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIB_PS_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_PS_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_PS_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIB_PS_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_PS_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_PS_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIC_PS_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_PS_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_PS_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIC_PS_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_PS_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_PS_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHID_PS_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_PS_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIA_PS_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIA_PS_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIA_PS_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_PS_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIB_PS_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_PS_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_PS_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIB_PS_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_PS_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIC_PS_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHIC_PS_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIC_PS_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHID_PS_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_L3PHID_PS_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHID_PS_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIA_PS_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIA_PS_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIA_PS_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_PS_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIB_PS_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_PS_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_PS_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIB_PS_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_PS_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_PS_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIC_PS_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_PS_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_PS_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIC_PS_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_PS_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHID_PS_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHID_PS_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHID_PS_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIA_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIA_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIA_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIB_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIB_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIB_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHID_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHID_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHID_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIE_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIE_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIE_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIF_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIF_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIF_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIG_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIG_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIG_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIA_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIA_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIA_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIB_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIB_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIC_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIC_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHID_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D1PHID_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHID_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIA_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIA_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIA_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIB_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIB_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIC_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIC_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHID_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D3PHID_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHID_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIA_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIA_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIA_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIB_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIB_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_negPS10G_1_A_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIC_negPS10G_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_negPS10G_1_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIC_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHID_negPS10G_1_B_wea : t_IL_36_1b           := '0';
  signal IL_D5PHID_negPS10G_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHID_negPS10G_1_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIA_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIA_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIA_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIB_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIB_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIB_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIC_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIC_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIC_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHID_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHID_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHID_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHID_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHID_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHID_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIE_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIE_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIE_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIE_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIE_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIE_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIF_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIF_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIF_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIG_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIG_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIG_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L1PHIH_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_L1PHIH_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L1PHIH_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIA_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIB_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIB_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIC_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIC_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_D2PHID_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIA_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_D4PHIA_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIA_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_D4PHIB_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_D4PHIB_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_negPS10G_2_A_wea : t_IL_36_1b           := '0';
  signal IL_D4PHIC_negPS10G_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_negPS10G_2_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_D4PHIC_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHID_negPS10G_2_B_wea : t_IL_36_1b           := '0';
  signal IL_D4PHID_negPS10G_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHID_negPS10G_2_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIA_negPS10G_3_A_wea : t_IL_36_1b           := '0';
  signal IL_L2PHIA_negPS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIA_negPS10G_3_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIB_negPS10G_3_A_wea : t_IL_36_1b           := '0';
  signal IL_L2PHIB_negPS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIB_negPS10G_3_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIB_negPS10G_3_B_wea : t_IL_36_1b           := '0';
  signal IL_L2PHIB_negPS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIB_negPS10G_3_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIC_negPS10G_3_A_wea : t_IL_36_1b           := '0';
  signal IL_L2PHIC_negPS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIC_negPS10G_3_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHIC_negPS10G_3_B_wea : t_IL_36_1b           := '0';
  signal IL_L2PHIC_negPS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHIC_negPS10G_3_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L2PHID_negPS10G_3_B_wea : t_IL_36_1b           := '0';
  signal IL_L2PHID_negPS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L2PHID_negPS10G_3_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_negPS10G_3_A_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIA_negPS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_negPS10G_3_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_negPS10G_3_A_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIB_negPS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_negPS10G_3_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_negPS10G_3_B_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIB_negPS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_negPS10G_3_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_negPS10G_3_A_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIC_negPS10G_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_negPS10G_3_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_negPS10G_3_B_wea : t_IL_36_1b           := '0';
  signal IL_D2PHIC_negPS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_negPS10G_3_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_negPS10G_3_B_wea : t_IL_36_1b           := '0';
  signal IL_D2PHID_negPS10G_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_negPS10G_3_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIA_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIA_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIA_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIB_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIB_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIC_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D1PHIC_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHID_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D1PHID_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHID_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIA_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIA_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIA_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIB_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIB_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIC_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D3PHIC_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHID_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D3PHID_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHID_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIA_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIA_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIA_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIB_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIB_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_negPS10G_4_A_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIC_negPS10G_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_negPS10G_4_A_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D5PHIC_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHID_negPS10G_4_B_wea : t_IL_36_1b           := '0';
  signal IL_D5PHID_negPS10G_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHID_negPS10G_4_B_din : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIA_negPS_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIA_negPS_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIA_negPS_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_negPS_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIB_negPS_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_negPS_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_negPS_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIB_negPS_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_negPS_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIC_negPS_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIC_negPS_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIC_negPS_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHID_negPS_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHID_negPS_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHID_negPS_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_negPS_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIA_negPS_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_negPS_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_negPS_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_negPS_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_negPS_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_negPS_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_negPS_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_negPS_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_negPS_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_negPS_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_negPS_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_negPS_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_negPS_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_negPS_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_negPS_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHID_negPS_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_negPS_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIA_negPS_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIA_negPS_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIA_negPS_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_negPS_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIB_negPS_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_negPS_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIB_negPS_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIB_negPS_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIB_negPS_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHIC_negPS_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHIC_negPS_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHIC_negPS_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L3PHID_negPS_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L3PHID_negPS_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L3PHID_negPS_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIA_negPS_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIA_negPS_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIA_negPS_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_negPS_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIB_negPS_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_negPS_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_negPS_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIB_negPS_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_negPS_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_negPS_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIC_negPS_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_negPS_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_negPS_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIC_negPS_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_negPS_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHID_negPS_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHID_negPS_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHID_negPS_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIA_2S_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_L4PHIA_2S_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIA_2S_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIB_2S_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_L4PHIB_2S_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIB_2S_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIB_2S_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_L4PHIB_2S_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIB_2S_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIC_2S_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_L4PHIC_2S_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIC_2S_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIC_2S_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_L4PHIC_2S_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIC_2S_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHID_2S_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_L4PHID_2S_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHID_2S_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIA_2S_1_A_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHIA_2S_1_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIA_2S_1_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHID_2S_1_B_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHID_2S_1_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHID_2S_1_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIA_2S_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHIA_2S_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIA_2S_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIB_2S_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHIB_2S_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIB_2S_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIB_2S_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHIB_2S_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIB_2S_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIC_2S_2_A_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHIC_2S_2_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIC_2S_2_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIC_2S_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHIC_2S_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIC_2S_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHID_2S_2_B_wea       : t_IL_36_1b           := '0';
  signal IL_L5PHID_2S_2_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHID_2S_2_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIA_2S_3_A_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIA_2S_3_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIA_2S_3_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIB_2S_3_A_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIB_2S_3_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIB_2S_3_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIC_2S_3_A_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIC_2S_3_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIC_2S_3_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIC_2S_3_B_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIC_2S_3_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIC_2S_3_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHID_2S_3_B_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHID_2S_3_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHID_2S_3_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIA_2S_4_A_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIA_2S_4_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIA_2S_4_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIB_2S_4_A_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIB_2S_4_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIB_2S_4_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIB_2S_4_B_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIB_2S_4_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIB_2S_4_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIC_2S_4_B_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHIC_2S_4_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIC_2S_4_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHID_2S_4_B_wea       : t_IL_36_1b           := '0';
  signal IL_L6PHID_2S_4_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHID_2S_4_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIA_2S_4_A_wea       : t_IL_36_1b           := '0';
  signal IL_D3PHIA_2S_4_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIA_2S_4_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_2S_4_A_wea       : t_IL_36_1b           := '0';
  signal IL_D3PHIB_2S_4_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_2S_4_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_2S_4_B_wea       : t_IL_36_1b           := '0';
  signal IL_D3PHIB_2S_4_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_2S_4_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_2S_4_A_wea       : t_IL_36_1b           := '0';
  signal IL_D3PHIC_2S_4_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_2S_4_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_2S_4_B_wea       : t_IL_36_1b           := '0';
  signal IL_D3PHIC_2S_4_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_2S_4_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHID_2S_4_B_wea       : t_IL_36_1b           := '0';
  signal IL_D3PHID_2S_4_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHID_2S_4_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIA_2S_5_A_wea       : t_IL_36_1b           := '0';
  signal IL_D1PHIA_2S_5_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIA_2S_5_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_2S_5_A_wea       : t_IL_36_1b           := '0';
  signal IL_D1PHIB_2S_5_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_2S_5_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_2S_5_B_wea       : t_IL_36_1b           := '0';
  signal IL_D1PHIB_2S_5_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_2S_5_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_2S_5_A_wea       : t_IL_36_1b           := '0';
  signal IL_D1PHIC_2S_5_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_2S_5_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_2S_5_B_wea       : t_IL_36_1b           := '0';
  signal IL_D1PHIC_2S_5_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_2S_5_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHID_2S_5_B_wea       : t_IL_36_1b           := '0';
  signal IL_D1PHID_2S_5_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHID_2S_5_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIA_2S_5_A_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIA_2S_5_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIA_2S_5_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_2S_5_A_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIB_2S_5_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_2S_5_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_2S_5_B_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIB_2S_5_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_2S_5_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_2S_5_A_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIC_2S_5_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_2S_5_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_2S_5_B_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHIC_2S_5_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_2S_5_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHID_2S_5_B_wea       : t_IL_36_1b           := '0';
  signal IL_D4PHID_2S_5_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHID_2S_5_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_2S_6_A_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIA_2S_6_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_2S_6_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_2S_6_A_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIB_2S_6_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_2S_6_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_2S_6_B_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIB_2S_6_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_2S_6_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_2S_6_A_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIC_2S_6_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_2S_6_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_2S_6_B_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHIC_2S_6_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_2S_6_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_2S_6_B_wea       : t_IL_36_1b           := '0';
  signal IL_D2PHID_2S_6_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_2S_6_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIA_2S_6_A_wea       : t_IL_36_1b           := '0';
  signal IL_D5PHIA_2S_6_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIA_2S_6_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_2S_6_A_wea       : t_IL_36_1b           := '0';
  signal IL_D5PHIB_2S_6_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_2S_6_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_2S_6_B_wea       : t_IL_36_1b           := '0';
  signal IL_D5PHIB_2S_6_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_2S_6_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_2S_6_A_wea       : t_IL_36_1b           := '0';
  signal IL_D5PHIC_2S_6_A_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_2S_6_A_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_2S_6_B_wea       : t_IL_36_1b           := '0';
  signal IL_D5PHIC_2S_6_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_2S_6_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHID_2S_6_B_wea       : t_IL_36_1b           := '0';
  signal IL_D5PHID_2S_6_B_writeaddr : t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHID_2S_6_B_din       : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIA_neg2S_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L4PHIA_neg2S_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIA_neg2S_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIB_neg2S_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L4PHIB_neg2S_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIB_neg2S_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIB_neg2S_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L4PHIB_neg2S_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIB_neg2S_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIC_neg2S_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L4PHIC_neg2S_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIC_neg2S_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHIC_neg2S_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L4PHIC_neg2S_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHIC_neg2S_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L4PHID_neg2S_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L4PHID_neg2S_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L4PHID_neg2S_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIA_neg2S_1_A_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHIA_neg2S_1_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIA_neg2S_1_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHID_neg2S_1_B_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHID_neg2S_1_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHID_neg2S_1_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIA_neg2S_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHIA_neg2S_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIA_neg2S_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIB_neg2S_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHIB_neg2S_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIB_neg2S_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIB_neg2S_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHIB_neg2S_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIB_neg2S_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIC_neg2S_2_A_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHIC_neg2S_2_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIC_neg2S_2_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHIC_neg2S_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHIC_neg2S_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHIC_neg2S_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L5PHID_neg2S_2_B_wea    : t_IL_36_1b           := '0';
  signal IL_L5PHID_neg2S_2_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L5PHID_neg2S_2_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIA_neg2S_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIA_neg2S_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIA_neg2S_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIB_neg2S_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIB_neg2S_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIB_neg2S_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIC_neg2S_3_A_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIC_neg2S_3_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIC_neg2S_3_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIC_neg2S_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIC_neg2S_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIC_neg2S_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHID_neg2S_3_B_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHID_neg2S_3_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHID_neg2S_3_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIA_neg2S_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIA_neg2S_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIA_neg2S_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIB_neg2S_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIB_neg2S_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIB_neg2S_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIB_neg2S_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIB_neg2S_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIB_neg2S_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHIC_neg2S_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHIC_neg2S_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHIC_neg2S_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_L6PHID_neg2S_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_L6PHID_neg2S_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_L6PHID_neg2S_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIA_neg2S_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIA_neg2S_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIA_neg2S_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_neg2S_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIB_neg2S_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_neg2S_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIB_neg2S_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIB_neg2S_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIB_neg2S_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_neg2S_4_A_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIC_neg2S_4_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_neg2S_4_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHIC_neg2S_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHIC_neg2S_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHIC_neg2S_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D3PHID_neg2S_4_B_wea    : t_IL_36_1b           := '0';
  signal IL_D3PHID_neg2S_4_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D3PHID_neg2S_4_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIA_neg2S_5_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIA_neg2S_5_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIA_neg2S_5_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_neg2S_5_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIB_neg2S_5_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_neg2S_5_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIB_neg2S_5_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIB_neg2S_5_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIB_neg2S_5_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_neg2S_5_A_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIC_neg2S_5_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_neg2S_5_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHIC_neg2S_5_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHIC_neg2S_5_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHIC_neg2S_5_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D1PHID_neg2S_5_B_wea    : t_IL_36_1b           := '0';
  signal IL_D1PHID_neg2S_5_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D1PHID_neg2S_5_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIA_neg2S_5_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIA_neg2S_5_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIA_neg2S_5_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_neg2S_5_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIB_neg2S_5_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_neg2S_5_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIB_neg2S_5_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIB_neg2S_5_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIB_neg2S_5_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_neg2S_5_A_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIC_neg2S_5_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_neg2S_5_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHIC_neg2S_5_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHIC_neg2S_5_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHIC_neg2S_5_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D4PHID_neg2S_5_B_wea    : t_IL_36_1b           := '0';
  signal IL_D4PHID_neg2S_5_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D4PHID_neg2S_5_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIA_neg2S_6_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIA_neg2S_6_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIA_neg2S_6_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_neg2S_6_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_neg2S_6_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_neg2S_6_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIB_neg2S_6_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIB_neg2S_6_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIB_neg2S_6_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_neg2S_6_A_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_neg2S_6_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_neg2S_6_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHIC_neg2S_6_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHIC_neg2S_6_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHIC_neg2S_6_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D2PHID_neg2S_6_B_wea    : t_IL_36_1b           := '0';
  signal IL_D2PHID_neg2S_6_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D2PHID_neg2S_6_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIA_neg2S_6_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIA_neg2S_6_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIA_neg2S_6_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_neg2S_6_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIB_neg2S_6_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_neg2S_6_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIB_neg2S_6_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIB_neg2S_6_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIB_neg2S_6_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_neg2S_6_A_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIC_neg2S_6_A_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_neg2S_6_A_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHIC_neg2S_6_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHIC_neg2S_6_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHIC_neg2S_6_B_din    : t_IL_36_DATA         := (others => '0');
  signal IL_D5PHID_neg2S_6_B_wea    : t_IL_36_1b           := '0';
  signal IL_D5PHID_neg2S_6_B_writeaddr: t_IL_36_ADDR         := (others => '0');
  signal IL_D5PHID_neg2S_6_B_din    : t_IL_36_DATA         := (others => '0');
  signal AS_L1PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHIEn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHIFn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHIGn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L1PHIHn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L2PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L2PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L2PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L2PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L3PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L3PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L3PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L3PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L4PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L4PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L4PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L4PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L5PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L5PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L5PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L5PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L6PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L6PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L6PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L6PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D1PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D1PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D1PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D1PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D2PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D2PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D2PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D2PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D3PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D3PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D3PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D3PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D4PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D4PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D4PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D4PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D5PHIAn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D5PHIBn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D5PHICn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_D5PHIDn1_stream_V_dout : std_logic_vector(36 downto 0) := (others => '0');
  signal AS_L2PHIA_B_L1A_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIA_B_L1A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIA_B_L1A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIA_B_L1B_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIA_B_L1B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIA_B_L1B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIA_B_L1C_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIA_B_L1C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIA_B_L1C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIB_B_L1D_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIB_B_L1D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIB_B_L1D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIB_B_L1E_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIB_B_L1E_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIB_B_L1E_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIB_B_L1F_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIB_B_L1F_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIB_B_L1F_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIC_B_L1G_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIC_B_L1G_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIC_B_L1G_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIC_B_L1H_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIC_B_L1H_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIC_B_L1H_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHIC_B_L1I_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHIC_B_L1I_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHIC_B_L1I_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHID_B_L1J_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHID_B_L1J_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHID_B_L1J_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHID_B_L1K_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHID_B_L1K_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHID_B_L1K_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L2PHID_B_L1L_wea        : t_AS_36_1b           := '0';
  signal AS_L2PHID_B_L1L_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L2PHID_B_L1L_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L3PHIA_B_L2A_wea        : t_AS_36_1b           := '0';
  signal AS_L3PHIA_B_L2A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L3PHIA_B_L2A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L3PHIB_B_L2B_wea        : t_AS_36_1b           := '0';
  signal AS_L3PHIB_B_L2B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L3PHIB_B_L2B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L3PHIC_B_L2C_wea        : t_AS_36_1b           := '0';
  signal AS_L3PHIC_B_L2C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L3PHIC_B_L2C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L3PHID_B_L2D_wea        : t_AS_36_1b           := '0';
  signal AS_L3PHID_B_L2D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L3PHID_B_L2D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L4PHIA_B_L3A_wea        : t_AS_36_1b           := '0';
  signal AS_L4PHIA_B_L3A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L4PHIA_B_L3A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L4PHIB_B_L3B_wea        : t_AS_36_1b           := '0';
  signal AS_L4PHIB_B_L3B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L4PHIB_B_L3B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L4PHIC_B_L3C_wea        : t_AS_36_1b           := '0';
  signal AS_L4PHIC_B_L3C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L4PHIC_B_L3C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L4PHID_B_L3D_wea        : t_AS_36_1b           := '0';
  signal AS_L4PHID_B_L3D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L4PHID_B_L3D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L6PHIA_B_L5A_wea        : t_AS_36_1b           := '0';
  signal AS_L6PHIA_B_L5A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L6PHIA_B_L5A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L6PHIB_B_L5B_wea        : t_AS_36_1b           := '0';
  signal AS_L6PHIB_B_L5B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L6PHIB_B_L5B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L6PHIC_B_L5C_wea        : t_AS_36_1b           := '0';
  signal AS_L6PHIC_B_L5C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L6PHIC_B_L5C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L6PHID_B_L5D_wea        : t_AS_36_1b           := '0';
  signal AS_L6PHID_B_L5D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_L6PHID_B_L5D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIA_O_L1A_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIA_O_L1A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIA_O_L1A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIA_O_L1B_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIA_O_L1B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIA_O_L1B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIA_O_L2A_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIA_O_L2A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIA_O_L2A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIB_O_L1C_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIB_O_L1C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIB_O_L1C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIB_O_L1D_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIB_O_L1D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIB_O_L1D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIB_O_L2B_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIB_O_L2B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIB_O_L2B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIC_O_L1E_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIC_O_L1E_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIC_O_L1E_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIC_O_L1F_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIC_O_L1F_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIC_O_L1F_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHIC_O_L2C_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHIC_O_L2C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHIC_O_L2C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHID_O_L1G_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHID_O_L1G_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHID_O_L1G_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHID_O_L1H_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHID_O_L1H_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHID_O_L1H_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D1PHID_O_L2D_wea        : t_AS_36_1b           := '0';
  signal AS_D1PHID_O_L2D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D1PHID_O_L2D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D2PHIA_D_D1A_wea        : t_AS_36_1b           := '0';
  signal AS_D2PHIA_D_D1A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D2PHIA_D_D1A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D2PHIB_D_D1B_wea        : t_AS_36_1b           := '0';
  signal AS_D2PHIB_D_D1B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D2PHIB_D_D1B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D2PHIC_D_D1C_wea        : t_AS_36_1b           := '0';
  signal AS_D2PHIC_D_D1C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D2PHIC_D_D1C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D2PHID_D_D1D_wea        : t_AS_36_1b           := '0';
  signal AS_D2PHID_D_D1D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D2PHID_D_D1D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D4PHIA_D_D3A_wea        : t_AS_36_1b           := '0';
  signal AS_D4PHIA_D_D3A_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D4PHIA_D_D3A_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D4PHIB_D_D3B_wea        : t_AS_36_1b           := '0';
  signal AS_D4PHIB_D_D3B_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D4PHIB_D_D3B_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D4PHIC_D_D3C_wea        : t_AS_36_1b           := '0';
  signal AS_D4PHIC_D_D3C_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D4PHIC_D_D3C_din        : t_AS_36_DATA         := (others => '0');
  signal AS_D4PHID_D_D3D_wea        : t_AS_36_1b           := '0';
  signal AS_D4PHID_D_D3D_writeaddr  : t_AS_36_ADDR         := (others => '0');
  signal AS_D4PHID_D_D3D_din        : t_AS_36_DATA         := (others => '0');
  signal AS_L1PHIA_BF_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIA_BF_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIA_BF_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIA_BE_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIA_BE_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIA_BE_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIA_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIA_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIA_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIB_BD_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIB_BD_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIB_BD_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIB_BC_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIB_BC_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIB_BC_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIB_BA_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIB_BA_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIB_BA_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIB_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIB_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIB_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIB_OR_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIB_OR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIB_OR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIC_BB_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIC_BB_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIC_BB_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIC_BF_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIC_BF_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIC_BF_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIC_BE_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIC_BE_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIC_BE_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIC_OL_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIC_OL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIC_OL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIC_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIC_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIC_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHID_BD_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHID_BD_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHID_BD_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHID_BC_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHID_BC_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHID_BC_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHID_BA_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHID_BA_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHID_BA_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHID_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHID_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHID_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHID_OR_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHID_OR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHID_OR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIE_BB_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIE_BB_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIE_BB_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIE_BF_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIE_BF_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIE_BF_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIE_BE_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIE_BE_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIE_BE_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIE_OL_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIE_OL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIE_OL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIE_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIE_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIE_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIF_BD_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIF_BD_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIF_BD_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIF_BC_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIF_BC_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIF_BC_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIF_BA_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIF_BA_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIF_BA_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIF_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIF_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIF_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIF_OR_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIF_OR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIF_OR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIG_BB_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIG_BB_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIG_BB_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIG_BF_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIG_BF_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIG_BF_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIG_BE_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIG_BE_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIG_BE_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIG_OL_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIG_OL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIG_OL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIG_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIG_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIG_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIH_BD_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIH_BD_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIH_BD_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIH_BC_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIH_BC_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIH_BC_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L1PHIH_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L1PHIH_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L1PHIH_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIA_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIA_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIA_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIA_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIA_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIA_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIB_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIB_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIB_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIB_BR_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIB_BR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIB_BR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIB_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIB_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIB_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIB_OR_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIB_OR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIB_OR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIC_BL_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIC_BL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIC_BL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIC_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIC_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIC_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIC_OL_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIC_OL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIC_OL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHIC_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHIC_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHIC_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHID_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHID_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHID_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L2PHID_OM_wea           : t_AS_51_1b           := '0';
  signal AS_L2PHID_OM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L2PHID_OM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L3PHIA_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L3PHIA_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L3PHIA_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L3PHIB_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L3PHIB_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L3PHIB_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L3PHIB_BR_wea           : t_AS_51_1b           := '0';
  signal AS_L3PHIB_BR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L3PHIB_BR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L3PHIC_BL_wea           : t_AS_51_1b           := '0';
  signal AS_L3PHIC_BL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L3PHIC_BL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L3PHIC_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L3PHIC_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L3PHIC_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L3PHID_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L3PHID_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L3PHID_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L5PHIA_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L5PHIA_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L5PHIA_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L5PHIB_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L5PHIB_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L5PHIB_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L5PHIB_BR_wea           : t_AS_51_1b           := '0';
  signal AS_L5PHIB_BR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L5PHIB_BR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L5PHIC_BL_wea           : t_AS_51_1b           := '0';
  signal AS_L5PHIC_BL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L5PHIC_BL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L5PHIC_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L5PHIC_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L5PHIC_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_L5PHID_BM_wea           : t_AS_51_1b           := '0';
  signal AS_L5PHID_BM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_L5PHID_BM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D1PHIA_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D1PHIA_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D1PHIA_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D1PHIB_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D1PHIB_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D1PHIB_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D1PHIB_DR_wea           : t_AS_51_1b           := '0';
  signal AS_D1PHIB_DR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D1PHIB_DR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D1PHIC_DL_wea           : t_AS_51_1b           := '0';
  signal AS_D1PHIC_DL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D1PHIC_DL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D1PHIC_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D1PHIC_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D1PHIC_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D1PHID_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D1PHID_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D1PHID_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D3PHIA_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D3PHIA_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D3PHIA_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D3PHIB_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D3PHIB_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D3PHIB_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D3PHIB_DR_wea           : t_AS_51_1b           := '0';
  signal AS_D3PHIB_DR_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D3PHIB_DR_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D3PHIC_DL_wea           : t_AS_51_1b           := '0';
  signal AS_D3PHIC_DL_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D3PHIC_DL_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D3PHIC_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D3PHIC_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D3PHIC_DM_din           : t_AS_51_DATA         := (others => '0');
  signal AS_D3PHID_DM_wea           : t_AS_51_1b           := '0';
  signal AS_D3PHID_DM_writeaddr     : t_AS_51_ADDR         := (others => '0');
  signal AS_D3PHID_DM_din           : t_AS_51_DATA         := (others => '0');
  signal VMSTE_L2PHIAn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIAn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIAn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIAn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIAn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIAn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIAn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIAn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIAn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIBn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIBn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIBn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIBn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIBn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIBn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIBn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIBn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIBn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHICn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHICn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHICn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHICn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHICn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHICn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHICn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHICn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHICn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIDn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIDn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIDn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIDn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIDn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIDn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L2PHIDn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L2PHIDn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L2PHIDn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L3PHIIn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L3PHIIn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L3PHIIn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L3PHIJn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L3PHIJn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L3PHIJn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L3PHIKn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L3PHIKn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L3PHIKn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L3PHILn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_L3PHILn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_L3PHILn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D2PHIAn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D2PHIAn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D2PHIAn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D2PHIBn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D2PHIBn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D2PHIBn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D2PHICn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D2PHICn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D2PHICn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D2PHIDn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D2PHIDn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D2PHIDn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D4PHIAn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D4PHIAn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D4PHIAn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D4PHIBn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D4PHIBn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D4PHIBn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D4PHICn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D4PHICn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D4PHICn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D4PHIDn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D4PHIDn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D4PHIDn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIXn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIXn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIXn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIXn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIXn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIXn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIYn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIYn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIYn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIYn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIYn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIYn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIZn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIZn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIZn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIZn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIZn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIZn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIWn1_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIWn1_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIWn1_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIWn2_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIWn2_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIWn2_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIXn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIXn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIXn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIYn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIYn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIYn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIZn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIZn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIZn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_D1PHIWn3_wea         : t_VMSTE_16_1b        := '0';
  signal VMSTE_D1PHIWn3_writeaddr   : t_VMSTE_16_ADDR      := (others => '0');
  signal VMSTE_D1PHIWn3_din         : t_VMSTE_16_DATA      := (others => '0');
  signal VMSTE_L4PHIAn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L4PHIAn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L4PHIAn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L4PHIBn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L4PHIBn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L4PHIBn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L4PHICn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L4PHICn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L4PHICn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L4PHIDn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L4PHIDn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L4PHIDn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L6PHIAn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L6PHIAn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L6PHIAn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L6PHIBn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L6PHIBn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L6PHIBn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L6PHICn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L6PHICn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L6PHICn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal VMSTE_L6PHIDn1_wea         : t_VMSTE_17_1b        := '0';
  signal VMSTE_L6PHIDn1_writeaddr   : t_VMSTE_17_ADDR      := (others => '0');
  signal VMSTE_L6PHIDn1_din         : t_VMSTE_17_DATA      := (others => '0');
  signal MPAR_L1L2ABC_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1L2DE_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1L2F_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1L2G_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1L2HI_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1L2JKL_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L2L3ABCD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L3L4AB_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L3L4CD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L5L6ABCD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_D1D2ABCD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_D3D4ABCD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1D1ABCD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L1D1EFGH_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;
  signal MPAR_L2D1ABCD_stream_V_dout: std_logic_vector(75 downto 0) := (others=> '0') ;

  -- Indicates that reading of DL of first event has started.
  signal START_FIRST_LINK : std_logic := '0';
  signal START_DL_PS10G_1_A : t_DL_39_1b := '0';
  signal START_DL_PS10G_1_B : t_DL_39_1b := '0';
  signal START_DL_PS10G_2_A : t_DL_39_1b := '0';
  signal START_DL_PS10G_2_B : t_DL_39_1b := '0';
  signal START_DL_PS10G_3_A : t_DL_39_1b := '0';
  signal START_DL_PS10G_3_B : t_DL_39_1b := '0';
  signal START_DL_PS10G_4_A : t_DL_39_1b := '0';
  signal START_DL_PS10G_4_B : t_DL_39_1b := '0';
  signal START_DL_PS_1_A : t_DL_39_1b := '0';
  signal START_DL_PS_1_B : t_DL_39_1b := '0';
  signal START_DL_PS_2_A : t_DL_39_1b := '0';
  signal START_DL_PS_2_B : t_DL_39_1b := '0';
  signal START_DL_negPS10G_1_A : t_DL_39_1b := '0';
  signal START_DL_negPS10G_1_B : t_DL_39_1b := '0';
  signal START_DL_negPS10G_2_A : t_DL_39_1b := '0';
  signal START_DL_negPS10G_2_B : t_DL_39_1b := '0';
  signal START_DL_negPS10G_3_A : t_DL_39_1b := '0';
  signal START_DL_negPS10G_3_B : t_DL_39_1b := '0';
  signal START_DL_negPS10G_4_A : t_DL_39_1b := '0';
  signal START_DL_negPS10G_4_B : t_DL_39_1b := '0';
  signal START_DL_negPS_1_A : t_DL_39_1b := '0';
  signal START_DL_negPS_1_B : t_DL_39_1b := '0';
  signal START_DL_negPS_2_A : t_DL_39_1b := '0';
  signal START_DL_negPS_2_B : t_DL_39_1b := '0';
  signal START_DL_twoS_1_A : t_DL_39_1b := '0';
  signal START_DL_twoS_1_B : t_DL_39_1b := '0';
  signal START_DL_twoS_2_A : t_DL_39_1b := '0';
  signal START_DL_twoS_2_B : t_DL_39_1b := '0';
  signal START_DL_twoS_3_A : t_DL_39_1b := '0';
  signal START_DL_twoS_3_B : t_DL_39_1b := '0';
  signal START_DL_twoS_4_A : t_DL_39_1b := '0';
  signal START_DL_twoS_4_B : t_DL_39_1b := '0';
  signal START_DL_twoS_5_A : t_DL_39_1b := '0';
  signal START_DL_twoS_5_B : t_DL_39_1b := '0';
  signal START_DL_twoS_6_A : t_DL_39_1b := '0';
  signal START_DL_twoS_6_B : t_DL_39_1b := '0';
  signal START_DL_neg2S_1_A : t_DL_39_1b := '0';
  signal START_DL_neg2S_1_B : t_DL_39_1b := '0';
  signal START_DL_neg2S_2_A : t_DL_39_1b := '0';
  signal START_DL_neg2S_2_B : t_DL_39_1b := '0';
  signal START_DL_neg2S_3_A : t_DL_39_1b := '0';
  signal START_DL_neg2S_3_B : t_DL_39_1b := '0';
  signal START_DL_neg2S_4_A : t_DL_39_1b := '0';
  signal START_DL_neg2S_4_B : t_DL_39_1b := '0';
  signal START_DL_neg2S_5_A : t_DL_39_1b := '0';
  signal START_DL_neg2S_5_B : t_DL_39_1b := '0';
  signal START_DL_neg2S_6_A : t_DL_39_1b := '0';
  signal START_DL_neg2S_6_B : t_DL_39_1b := '0';

  component clk_wiz_240_360
  port
   (
    clk    : in     std_logic;
    clk240 : out    std_logic;
    clk360 : out    std_logic;
    locked : out    std_logic
   );
  end component;

begin

--! @brief Make clock ---------------------------------------
  clk <= not clk after CLK_PERIOD/2.0;
  clk_wiz_240_360_0 : clk_wiz_240_360
     port map (
     clk    => clk,
     clk240 => clk240,
     clk360 => clk360,
     locked => locked
   );

  -- Get signals from input .txt files

    readDL_PS10G_1_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_1_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_1_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_1_A_link_read,
      DATA            => DL_PS10G_1_A_link_AV_dout,
      START           => START_DL_PS10G_1_A,
      EMPTY_NEG       => DL_PS10G_1_A_link_empty_neg
    );
    readDL_PS10G_1_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_1_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_1_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_1_B_link_read,
      DATA            => DL_PS10G_1_B_link_AV_dout,
      START           => START_DL_PS10G_1_B,
      EMPTY_NEG       => DL_PS10G_1_B_link_empty_neg
    );
    readDL_PS10G_2_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_2_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_2_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_2_A_link_read,
      DATA            => DL_PS10G_2_A_link_AV_dout,
      START           => START_DL_PS10G_2_A,
      EMPTY_NEG       => DL_PS10G_2_A_link_empty_neg
    );
    readDL_PS10G_2_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_2_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_2_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_2_B_link_read,
      DATA            => DL_PS10G_2_B_link_AV_dout,
      START           => START_DL_PS10G_2_B,
      EMPTY_NEG       => DL_PS10G_2_B_link_empty_neg
    );
    readDL_PS10G_3_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_3_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_3_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_3_A_link_read,
      DATA            => DL_PS10G_3_A_link_AV_dout,
      START           => START_DL_PS10G_3_A,
      EMPTY_NEG       => DL_PS10G_3_A_link_empty_neg
    );
    readDL_PS10G_3_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_3_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_3_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_3_B_link_read,
      DATA            => DL_PS10G_3_B_link_AV_dout,
      START           => START_DL_PS10G_3_B,
      EMPTY_NEG       => DL_PS10G_3_B_link_empty_neg
    );
    readDL_PS10G_4_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_4_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_4_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_4_A_link_read,
      DATA            => DL_PS10G_4_A_link_AV_dout,
      START           => START_DL_PS10G_4_A,
      EMPTY_NEG       => DL_PS10G_4_A_link_empty_neg
    );
    readDL_PS10G_4_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS10G_4_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS10G_4_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS10G_4_B_link_read,
      DATA            => DL_PS10G_4_B_link_AV_dout,
      START           => START_DL_PS10G_4_B,
      EMPTY_NEG       => DL_PS10G_4_B_link_empty_neg
    );
    readDL_PS_1_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS_1_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS_1_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS_1_A_link_read,
      DATA            => DL_PS_1_A_link_AV_dout,
      START           => START_DL_PS_1_A,
      EMPTY_NEG       => DL_PS_1_A_link_empty_neg
    );
    readDL_PS_1_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS_1_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS_1_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS_1_B_link_read,
      DATA            => DL_PS_1_B_link_AV_dout,
      START           => START_DL_PS_1_B,
      EMPTY_NEG       => DL_PS_1_B_link_empty_neg
    );
    readDL_PS_2_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS_2_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS_2_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS_2_A_link_read,
      DATA            => DL_PS_2_A_link_AV_dout,
      START           => START_DL_PS_2_A,
      EMPTY_NEG       => DL_PS_2_A_link_empty_neg
    );
    readDL_PS_2_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_PS_2_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_PS_2_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_PS_2_B_link_read,
      DATA            => DL_PS_2_B_link_AV_dout,
      START           => START_DL_PS_2_B,
      EMPTY_NEG       => DL_PS_2_B_link_empty_neg
    );
    readDL_negPS10G_1_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_1_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_1_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_1_A_link_read,
      DATA            => DL_negPS10G_1_A_link_AV_dout,
      START           => START_DL_negPS10G_1_A,
      EMPTY_NEG       => DL_negPS10G_1_A_link_empty_neg
    );
    readDL_negPS10G_1_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_1_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_1_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_1_B_link_read,
      DATA            => DL_negPS10G_1_B_link_AV_dout,
      START           => START_DL_negPS10G_1_B,
      EMPTY_NEG       => DL_negPS10G_1_B_link_empty_neg
    );
    readDL_negPS10G_2_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_2_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_2_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_2_A_link_read,
      DATA            => DL_negPS10G_2_A_link_AV_dout,
      START           => START_DL_negPS10G_2_A,
      EMPTY_NEG       => DL_negPS10G_2_A_link_empty_neg
    );
    readDL_negPS10G_2_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_2_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_2_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_2_B_link_read,
      DATA            => DL_negPS10G_2_B_link_AV_dout,
      START           => START_DL_negPS10G_2_B,
      EMPTY_NEG       => DL_negPS10G_2_B_link_empty_neg
    );
    readDL_negPS10G_3_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_3_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_3_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_3_A_link_read,
      DATA            => DL_negPS10G_3_A_link_AV_dout,
      START           => START_DL_negPS10G_3_A,
      EMPTY_NEG       => DL_negPS10G_3_A_link_empty_neg
    );
    readDL_negPS10G_3_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_3_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_3_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_3_B_link_read,
      DATA            => DL_negPS10G_3_B_link_AV_dout,
      START           => START_DL_negPS10G_3_B,
      EMPTY_NEG       => DL_negPS10G_3_B_link_empty_neg
    );
    readDL_negPS10G_4_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_4_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_4_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_4_A_link_read,
      DATA            => DL_negPS10G_4_A_link_AV_dout,
      START           => START_DL_negPS10G_4_A,
      EMPTY_NEG       => DL_negPS10G_4_A_link_empty_neg
    );
    readDL_negPS10G_4_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS10G_4_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS10G_4_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS10G_4_B_link_read,
      DATA            => DL_negPS10G_4_B_link_AV_dout,
      START           => START_DL_negPS10G_4_B,
      EMPTY_NEG       => DL_negPS10G_4_B_link_empty_neg
    );
    readDL_negPS_1_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS_1_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS_1_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS_1_A_link_read,
      DATA            => DL_negPS_1_A_link_AV_dout,
      START           => START_DL_negPS_1_A,
      EMPTY_NEG       => DL_negPS_1_A_link_empty_neg
    );
    readDL_negPS_1_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS_1_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS_1_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS_1_B_link_read,
      DATA            => DL_negPS_1_B_link_AV_dout,
      START           => START_DL_negPS_1_B,
      EMPTY_NEG       => DL_negPS_1_B_link_empty_neg
    );
    readDL_negPS_2_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS_2_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS_2_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS_2_A_link_read,
      DATA            => DL_negPS_2_A_link_AV_dout,
      START           => START_DL_negPS_2_A,
      EMPTY_NEG       => DL_negPS_2_A_link_empty_neg
    );
    readDL_negPS_2_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_negPS_2_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_negPS_2_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_negPS_2_B_link_read,
      DATA            => DL_negPS_2_B_link_AV_dout,
      START           => START_DL_negPS_2_B,
      EMPTY_NEG       => DL_negPS_2_B_link_empty_neg
    );
    readDL_twoS_1_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_1_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_1_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_1_A_link_read,
      DATA            => DL_twoS_1_A_link_AV_dout,
      START           => START_DL_twoS_1_A,
      EMPTY_NEG       => DL_twoS_1_A_link_empty_neg
    );
    readDL_twoS_1_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_1_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_1_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_1_B_link_read,
      DATA            => DL_twoS_1_B_link_AV_dout,
      START           => START_DL_twoS_1_B,
      EMPTY_NEG       => DL_twoS_1_B_link_empty_neg
    );
    readDL_twoS_2_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_2_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_2_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_2_A_link_read,
      DATA            => DL_twoS_2_A_link_AV_dout,
      START           => START_DL_twoS_2_A,
      EMPTY_NEG       => DL_twoS_2_A_link_empty_neg
    );
    readDL_twoS_2_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_2_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_2_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_2_B_link_read,
      DATA            => DL_twoS_2_B_link_AV_dout,
      START           => START_DL_twoS_2_B,
      EMPTY_NEG       => DL_twoS_2_B_link_empty_neg
    );
    readDL_twoS_3_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_3_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_3_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_3_A_link_read,
      DATA            => DL_twoS_3_A_link_AV_dout,
      START           => START_DL_twoS_3_A,
      EMPTY_NEG       => DL_twoS_3_A_link_empty_neg
    );
    readDL_twoS_3_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_3_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_3_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_3_B_link_read,
      DATA            => DL_twoS_3_B_link_AV_dout,
      START           => START_DL_twoS_3_B,
      EMPTY_NEG       => DL_twoS_3_B_link_empty_neg
    );
    readDL_twoS_4_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_4_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_4_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_4_A_link_read,
      DATA            => DL_twoS_4_A_link_AV_dout,
      START           => START_DL_twoS_4_A,
      EMPTY_NEG       => DL_twoS_4_A_link_empty_neg
    );
    readDL_twoS_4_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_4_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_4_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_4_B_link_read,
      DATA            => DL_twoS_4_B_link_AV_dout,
      START           => START_DL_twoS_4_B,
      EMPTY_NEG       => DL_twoS_4_B_link_empty_neg
    );
    readDL_twoS_5_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_5_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_5_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_5_A_link_read,
      DATA            => DL_twoS_5_A_link_AV_dout,
      START           => START_DL_twoS_5_A,
      EMPTY_NEG       => DL_twoS_5_A_link_empty_neg
    );
    readDL_twoS_5_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_5_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_5_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_5_B_link_read,
      DATA            => DL_twoS_5_B_link_AV_dout,
      START           => START_DL_twoS_5_B,
      EMPTY_NEG       => DL_twoS_5_B_link_empty_neg
    );
    readDL_twoS_6_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_6_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_6_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_6_A_link_read,
      DATA            => DL_twoS_6_A_link_AV_dout,
      START           => START_DL_twoS_6_A,
      EMPTY_NEG       => DL_twoS_6_A_link_empty_neg
    );
    readDL_twoS_6_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_2S_6_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_2S_6_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_twoS_6_B_link_read,
      DATA            => DL_twoS_6_B_link_AV_dout,
      START           => START_DL_twoS_6_B,
      EMPTY_NEG       => DL_twoS_6_B_link_empty_neg
    );
    readDL_neg2S_1_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_1_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_1_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_1_A_link_read,
      DATA            => DL_neg2S_1_A_link_AV_dout,
      START           => START_DL_neg2S_1_A,
      EMPTY_NEG       => DL_neg2S_1_A_link_empty_neg
    );
    readDL_neg2S_1_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_1_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_1_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_1_B_link_read,
      DATA            => DL_neg2S_1_B_link_AV_dout,
      START           => START_DL_neg2S_1_B,
      EMPTY_NEG       => DL_neg2S_1_B_link_empty_neg
    );
    readDL_neg2S_2_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_2_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_2_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_2_A_link_read,
      DATA            => DL_neg2S_2_A_link_AV_dout,
      START           => START_DL_neg2S_2_A,
      EMPTY_NEG       => DL_neg2S_2_A_link_empty_neg
    );
    readDL_neg2S_2_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_2_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_2_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_2_B_link_read,
      DATA            => DL_neg2S_2_B_link_AV_dout,
      START           => START_DL_neg2S_2_B,
      EMPTY_NEG       => DL_neg2S_2_B_link_empty_neg
    );
    readDL_neg2S_3_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_3_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_3_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_3_A_link_read,
      DATA            => DL_neg2S_3_A_link_AV_dout,
      START           => START_DL_neg2S_3_A,
      EMPTY_NEG       => DL_neg2S_3_A_link_empty_neg
    );
    readDL_neg2S_3_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_3_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_3_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_3_B_link_read,
      DATA            => DL_neg2S_3_B_link_AV_dout,
      START           => START_DL_neg2S_3_B,
      EMPTY_NEG       => DL_neg2S_3_B_link_empty_neg
    );
    readDL_neg2S_4_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_4_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_4_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_4_A_link_read,
      DATA            => DL_neg2S_4_A_link_AV_dout,
      START           => START_DL_neg2S_4_A,
      EMPTY_NEG       => DL_neg2S_4_A_link_empty_neg
    );
    readDL_neg2S_4_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_4_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_4_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_4_B_link_read,
      DATA            => DL_neg2S_4_B_link_AV_dout,
      START           => START_DL_neg2S_4_B,
      EMPTY_NEG       => DL_neg2S_4_B_link_empty_neg
    );
    readDL_neg2S_5_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_5_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_5_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_5_A_link_read,
      DATA            => DL_neg2S_5_A_link_AV_dout,
      START           => START_DL_neg2S_5_A,
      EMPTY_NEG       => DL_neg2S_5_A_link_empty_neg
    );
    readDL_neg2S_5_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_5_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_5_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_5_B_link_read,
      DATA            => DL_neg2S_5_B_link_AV_dout,
      START           => START_DL_neg2S_5_B,
      EMPTY_NEG       => DL_neg2S_5_B_link_empty_neg
    );
    readDL_neg2S_6_A : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_6_A"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_6_A"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_6_A_link_read,
      DATA            => DL_neg2S_6_A_link_AV_dout,
      START           => START_DL_neg2S_6_A,
      EMPTY_NEG       => DL_neg2S_6_A_link_empty_neg
    );
    readDL_neg2S_6_B : entity work.FileReaderFIFO
  generic map (
      FILE_NAME       => FILE_IN_DL_39&"DL_neg2S_6_B"&inputFileNameEnding,
      FIFO_WIDTH      => 39,
      DEBUG           => true,
      FILE_NAME_DEBUG => FILE_OUT_DL_debug&"DL_neg2S_6_B"&debugFileNameEnding,
      MAX_ENTRIES     => MAX_ENTRIES_360
    )
    port map (
      CLK             => CLK360,
      LOCKED          => LOCKED,
      READ_EN         => DL_neg2S_6_B_link_read,
      DATA            => DL_neg2S_6_B_link_AV_dout,
      START           => START_DL_neg2S_6_B,
      EMPTY_NEG       => DL_neg2S_6_B_link_empty_neg
    );
  -- As all DL signals start together, take first one, to determine when
  -- first event starts being read from the first link in the chain.
  START_FIRST_LINK <= START_DL_PS10G_1_A;

  procStart : process(CLK360)
    -- Process to start first module in chain & generate its BX counter input.
    -- Also releases reset flag.
    constant CLK_RESET : natural := 5; -- Any low number OK.
    variable CLK_COUNT : natural := MAX_ENTRIES_360 - CLK_RESET;
    variable EVENT_COUNT : integer := -1;
    variable v_line : line; -- Line for debug
  begin

    if START_FIRST_LINK = '1' then
      if rising_edge(CLK360) then
        if (CLK_COUNT < MAX_ENTRIES_360) then
          CLK_COUNT := CLK_COUNT + 1;
        else
          CLK_COUNT := 1;
          EVENT_COUNT := EVENT_COUNT + 1;

          IR_START <= '1';
          IR_BX_IN <= std_logic_vector(to_unsigned(EVENT_COUNT, IR_BX_IN'length));

          write(v_line, string'("=== Processing event ")); write(v_line,EVENT_COUNT); write(v_line, string'(" at SIM time ")); write(v_line, NOW); writeline(output, v_line);
        end if;
        -- Releae
        if (CLK_COUNT = MAX_ENTRIES_360) then 
          RESET <= '0';
        end if;
      end if;
    end if;
  end process procStart;

  -- ########################### Instantiation ###########################
  -- Instantiate the Unit Under Test (UUT)

  sectorProc : if INST_TOP_TF = 0 generate
  begin
    uut : entity work.SectorProcessor
      port map(
        clk240                        => clk240,
        clk360                        => clk360,
        reset                      => reset,
        IR_start                   => IR_start,
        IR_bx_in                   => IR_bx_in,
        TP_bx_out                  => TP_bx_out,
        TP_bx_out_vld              => TP_bx_out_vld,
        TP_done                    => TP_done,
        -- Input data
        DL_PS10G_1_A_link_AV_dout  => DL_PS10G_1_A_link_AV_dout,
        DL_PS10G_1_A_link_empty_neg=> DL_PS10G_1_A_link_empty_neg,
        DL_PS10G_1_A_link_read     => DL_PS10G_1_A_link_read,
        DL_PS10G_1_B_link_AV_dout  => DL_PS10G_1_B_link_AV_dout,
        DL_PS10G_1_B_link_empty_neg=> DL_PS10G_1_B_link_empty_neg,
        DL_PS10G_1_B_link_read     => DL_PS10G_1_B_link_read,
        DL_PS10G_2_A_link_AV_dout  => DL_PS10G_2_A_link_AV_dout,
        DL_PS10G_2_A_link_empty_neg=> DL_PS10G_2_A_link_empty_neg,
        DL_PS10G_2_A_link_read     => DL_PS10G_2_A_link_read,
        DL_PS10G_2_B_link_AV_dout  => DL_PS10G_2_B_link_AV_dout,
        DL_PS10G_2_B_link_empty_neg=> DL_PS10G_2_B_link_empty_neg,
        DL_PS10G_2_B_link_read     => DL_PS10G_2_B_link_read,
        DL_PS10G_3_A_link_AV_dout  => DL_PS10G_3_A_link_AV_dout,
        DL_PS10G_3_A_link_empty_neg=> DL_PS10G_3_A_link_empty_neg,
        DL_PS10G_3_A_link_read     => DL_PS10G_3_A_link_read,
        DL_PS10G_3_B_link_AV_dout  => DL_PS10G_3_B_link_AV_dout,
        DL_PS10G_3_B_link_empty_neg=> DL_PS10G_3_B_link_empty_neg,
        DL_PS10G_3_B_link_read     => DL_PS10G_3_B_link_read,
        DL_PS10G_4_A_link_AV_dout  => DL_PS10G_4_A_link_AV_dout,
        DL_PS10G_4_A_link_empty_neg=> DL_PS10G_4_A_link_empty_neg,
        DL_PS10G_4_A_link_read     => DL_PS10G_4_A_link_read,
        DL_PS10G_4_B_link_AV_dout  => DL_PS10G_4_B_link_AV_dout,
        DL_PS10G_4_B_link_empty_neg=> DL_PS10G_4_B_link_empty_neg,
        DL_PS10G_4_B_link_read     => DL_PS10G_4_B_link_read,
        DL_PS_1_A_link_AV_dout     => DL_PS_1_A_link_AV_dout,
        DL_PS_1_A_link_empty_neg   => DL_PS_1_A_link_empty_neg,
        DL_PS_1_A_link_read        => DL_PS_1_A_link_read,
        DL_PS_1_B_link_AV_dout     => DL_PS_1_B_link_AV_dout,
        DL_PS_1_B_link_empty_neg   => DL_PS_1_B_link_empty_neg,
        DL_PS_1_B_link_read        => DL_PS_1_B_link_read,
        DL_PS_2_A_link_AV_dout     => DL_PS_2_A_link_AV_dout,
        DL_PS_2_A_link_empty_neg   => DL_PS_2_A_link_empty_neg,
        DL_PS_2_A_link_read        => DL_PS_2_A_link_read,
        DL_PS_2_B_link_AV_dout     => DL_PS_2_B_link_AV_dout,
        DL_PS_2_B_link_empty_neg   => DL_PS_2_B_link_empty_neg,
        DL_PS_2_B_link_read        => DL_PS_2_B_link_read,
        DL_negPS10G_1_A_link_AV_dout=> DL_negPS10G_1_A_link_AV_dout,
        DL_negPS10G_1_A_link_empty_neg=> DL_negPS10G_1_A_link_empty_neg,
        DL_negPS10G_1_A_link_read  => DL_negPS10G_1_A_link_read,
        DL_negPS10G_1_B_link_AV_dout=> DL_negPS10G_1_B_link_AV_dout,
        DL_negPS10G_1_B_link_empty_neg=> DL_negPS10G_1_B_link_empty_neg,
        DL_negPS10G_1_B_link_read  => DL_negPS10G_1_B_link_read,
        DL_negPS10G_2_A_link_AV_dout=> DL_negPS10G_2_A_link_AV_dout,
        DL_negPS10G_2_A_link_empty_neg=> DL_negPS10G_2_A_link_empty_neg,
        DL_negPS10G_2_A_link_read  => DL_negPS10G_2_A_link_read,
        DL_negPS10G_2_B_link_AV_dout=> DL_negPS10G_2_B_link_AV_dout,
        DL_negPS10G_2_B_link_empty_neg=> DL_negPS10G_2_B_link_empty_neg,
        DL_negPS10G_2_B_link_read  => DL_negPS10G_2_B_link_read,
        DL_negPS10G_3_A_link_AV_dout=> DL_negPS10G_3_A_link_AV_dout,
        DL_negPS10G_3_A_link_empty_neg=> DL_negPS10G_3_A_link_empty_neg,
        DL_negPS10G_3_A_link_read  => DL_negPS10G_3_A_link_read,
        DL_negPS10G_3_B_link_AV_dout=> DL_negPS10G_3_B_link_AV_dout,
        DL_negPS10G_3_B_link_empty_neg=> DL_negPS10G_3_B_link_empty_neg,
        DL_negPS10G_3_B_link_read  => DL_negPS10G_3_B_link_read,
        DL_negPS10G_4_A_link_AV_dout=> DL_negPS10G_4_A_link_AV_dout,
        DL_negPS10G_4_A_link_empty_neg=> DL_negPS10G_4_A_link_empty_neg,
        DL_negPS10G_4_A_link_read  => DL_negPS10G_4_A_link_read,
        DL_negPS10G_4_B_link_AV_dout=> DL_negPS10G_4_B_link_AV_dout,
        DL_negPS10G_4_B_link_empty_neg=> DL_negPS10G_4_B_link_empty_neg,
        DL_negPS10G_4_B_link_read  => DL_negPS10G_4_B_link_read,
        DL_negPS_1_A_link_AV_dout  => DL_negPS_1_A_link_AV_dout,
        DL_negPS_1_A_link_empty_neg=> DL_negPS_1_A_link_empty_neg,
        DL_negPS_1_A_link_read     => DL_negPS_1_A_link_read,
        DL_negPS_1_B_link_AV_dout  => DL_negPS_1_B_link_AV_dout,
        DL_negPS_1_B_link_empty_neg=> DL_negPS_1_B_link_empty_neg,
        DL_negPS_1_B_link_read     => DL_negPS_1_B_link_read,
        DL_negPS_2_A_link_AV_dout  => DL_negPS_2_A_link_AV_dout,
        DL_negPS_2_A_link_empty_neg=> DL_negPS_2_A_link_empty_neg,
        DL_negPS_2_A_link_read     => DL_negPS_2_A_link_read,
        DL_negPS_2_B_link_AV_dout  => DL_negPS_2_B_link_AV_dout,
        DL_negPS_2_B_link_empty_neg=> DL_negPS_2_B_link_empty_neg,
        DL_negPS_2_B_link_read     => DL_negPS_2_B_link_read,
        DL_twoS_1_A_link_AV_dout   => DL_twoS_1_A_link_AV_dout,
        DL_twoS_1_A_link_empty_neg => DL_twoS_1_A_link_empty_neg,
        DL_twoS_1_A_link_read      => DL_twoS_1_A_link_read,
        DL_twoS_1_B_link_AV_dout   => DL_twoS_1_B_link_AV_dout,
        DL_twoS_1_B_link_empty_neg => DL_twoS_1_B_link_empty_neg,
        DL_twoS_1_B_link_read      => DL_twoS_1_B_link_read,
        DL_twoS_2_A_link_AV_dout   => DL_twoS_2_A_link_AV_dout,
        DL_twoS_2_A_link_empty_neg => DL_twoS_2_A_link_empty_neg,
        DL_twoS_2_A_link_read      => DL_twoS_2_A_link_read,
        DL_twoS_2_B_link_AV_dout   => DL_twoS_2_B_link_AV_dout,
        DL_twoS_2_B_link_empty_neg => DL_twoS_2_B_link_empty_neg,
        DL_twoS_2_B_link_read      => DL_twoS_2_B_link_read,
        DL_twoS_3_A_link_AV_dout   => DL_twoS_3_A_link_AV_dout,
        DL_twoS_3_A_link_empty_neg => DL_twoS_3_A_link_empty_neg,
        DL_twoS_3_A_link_read      => DL_twoS_3_A_link_read,
        DL_twoS_3_B_link_AV_dout   => DL_twoS_3_B_link_AV_dout,
        DL_twoS_3_B_link_empty_neg => DL_twoS_3_B_link_empty_neg,
        DL_twoS_3_B_link_read      => DL_twoS_3_B_link_read,
        DL_twoS_4_A_link_AV_dout   => DL_twoS_4_A_link_AV_dout,
        DL_twoS_4_A_link_empty_neg => DL_twoS_4_A_link_empty_neg,
        DL_twoS_4_A_link_read      => DL_twoS_4_A_link_read,
        DL_twoS_4_B_link_AV_dout   => DL_twoS_4_B_link_AV_dout,
        DL_twoS_4_B_link_empty_neg => DL_twoS_4_B_link_empty_neg,
        DL_twoS_4_B_link_read      => DL_twoS_4_B_link_read,
        DL_twoS_5_A_link_AV_dout   => DL_twoS_5_A_link_AV_dout,
        DL_twoS_5_A_link_empty_neg => DL_twoS_5_A_link_empty_neg,
        DL_twoS_5_A_link_read      => DL_twoS_5_A_link_read,
        DL_twoS_5_B_link_AV_dout   => DL_twoS_5_B_link_AV_dout,
        DL_twoS_5_B_link_empty_neg => DL_twoS_5_B_link_empty_neg,
        DL_twoS_5_B_link_read      => DL_twoS_5_B_link_read,
        DL_twoS_6_A_link_AV_dout   => DL_twoS_6_A_link_AV_dout,
        DL_twoS_6_A_link_empty_neg => DL_twoS_6_A_link_empty_neg,
        DL_twoS_6_A_link_read      => DL_twoS_6_A_link_read,
        DL_twoS_6_B_link_AV_dout   => DL_twoS_6_B_link_AV_dout,
        DL_twoS_6_B_link_empty_neg => DL_twoS_6_B_link_empty_neg,
        DL_twoS_6_B_link_read      => DL_twoS_6_B_link_read,
        DL_neg2S_1_A_link_AV_dout  => DL_neg2S_1_A_link_AV_dout,
        DL_neg2S_1_A_link_empty_neg=> DL_neg2S_1_A_link_empty_neg,
        DL_neg2S_1_A_link_read     => DL_neg2S_1_A_link_read,
        DL_neg2S_1_B_link_AV_dout  => DL_neg2S_1_B_link_AV_dout,
        DL_neg2S_1_B_link_empty_neg=> DL_neg2S_1_B_link_empty_neg,
        DL_neg2S_1_B_link_read     => DL_neg2S_1_B_link_read,
        DL_neg2S_2_A_link_AV_dout  => DL_neg2S_2_A_link_AV_dout,
        DL_neg2S_2_A_link_empty_neg=> DL_neg2S_2_A_link_empty_neg,
        DL_neg2S_2_A_link_read     => DL_neg2S_2_A_link_read,
        DL_neg2S_2_B_link_AV_dout  => DL_neg2S_2_B_link_AV_dout,
        DL_neg2S_2_B_link_empty_neg=> DL_neg2S_2_B_link_empty_neg,
        DL_neg2S_2_B_link_read     => DL_neg2S_2_B_link_read,
        DL_neg2S_3_A_link_AV_dout  => DL_neg2S_3_A_link_AV_dout,
        DL_neg2S_3_A_link_empty_neg=> DL_neg2S_3_A_link_empty_neg,
        DL_neg2S_3_A_link_read     => DL_neg2S_3_A_link_read,
        DL_neg2S_3_B_link_AV_dout  => DL_neg2S_3_B_link_AV_dout,
        DL_neg2S_3_B_link_empty_neg=> DL_neg2S_3_B_link_empty_neg,
        DL_neg2S_3_B_link_read     => DL_neg2S_3_B_link_read,
        DL_neg2S_4_A_link_AV_dout  => DL_neg2S_4_A_link_AV_dout,
        DL_neg2S_4_A_link_empty_neg=> DL_neg2S_4_A_link_empty_neg,
        DL_neg2S_4_A_link_read     => DL_neg2S_4_A_link_read,
        DL_neg2S_4_B_link_AV_dout  => DL_neg2S_4_B_link_AV_dout,
        DL_neg2S_4_B_link_empty_neg=> DL_neg2S_4_B_link_empty_neg,
        DL_neg2S_4_B_link_read     => DL_neg2S_4_B_link_read,
        DL_neg2S_5_A_link_AV_dout  => DL_neg2S_5_A_link_AV_dout,
        DL_neg2S_5_A_link_empty_neg=> DL_neg2S_5_A_link_empty_neg,
        DL_neg2S_5_A_link_read     => DL_neg2S_5_A_link_read,
        DL_neg2S_5_B_link_AV_dout  => DL_neg2S_5_B_link_AV_dout,
        DL_neg2S_5_B_link_empty_neg=> DL_neg2S_5_B_link_empty_neg,
        DL_neg2S_5_B_link_read     => DL_neg2S_5_B_link_read,
        DL_neg2S_6_A_link_AV_dout  => DL_neg2S_6_A_link_AV_dout,
        DL_neg2S_6_A_link_empty_neg=> DL_neg2S_6_A_link_empty_neg,
        DL_neg2S_6_A_link_read     => DL_neg2S_6_A_link_read,
        DL_neg2S_6_B_link_AV_dout  => DL_neg2S_6_B_link_AV_dout,
        DL_neg2S_6_B_link_empty_neg=> DL_neg2S_6_B_link_empty_neg,
        DL_neg2S_6_B_link_read     => DL_neg2S_6_B_link_read,
        -- Output data
        AS_L1PHIAn1_stream_V_dout  => AS_L1PHIAn1_stream_V_dout,
        AS_L1PHIBn1_stream_V_dout  => AS_L1PHIBn1_stream_V_dout,
        AS_L1PHICn1_stream_V_dout  => AS_L1PHICn1_stream_V_dout,
        AS_L1PHIDn1_stream_V_dout  => AS_L1PHIDn1_stream_V_dout,
        AS_L1PHIEn1_stream_V_dout  => AS_L1PHIEn1_stream_V_dout,
        AS_L1PHIFn1_stream_V_dout  => AS_L1PHIFn1_stream_V_dout,
        AS_L1PHIGn1_stream_V_dout  => AS_L1PHIGn1_stream_V_dout,
        AS_L1PHIHn1_stream_V_dout  => AS_L1PHIHn1_stream_V_dout,
        AS_L2PHIAn1_stream_V_dout  => AS_L2PHIAn1_stream_V_dout,
        AS_L2PHIBn1_stream_V_dout  => AS_L2PHIBn1_stream_V_dout,
        AS_L2PHICn1_stream_V_dout  => AS_L2PHICn1_stream_V_dout,
        AS_L2PHIDn1_stream_V_dout  => AS_L2PHIDn1_stream_V_dout,
        AS_L3PHIAn1_stream_V_dout  => AS_L3PHIAn1_stream_V_dout,
        AS_L3PHIBn1_stream_V_dout  => AS_L3PHIBn1_stream_V_dout,
        AS_L3PHICn1_stream_V_dout  => AS_L3PHICn1_stream_V_dout,
        AS_L3PHIDn1_stream_V_dout  => AS_L3PHIDn1_stream_V_dout,
        AS_L4PHIAn1_stream_V_dout  => AS_L4PHIAn1_stream_V_dout,
        AS_L4PHIBn1_stream_V_dout  => AS_L4PHIBn1_stream_V_dout,
        AS_L4PHICn1_stream_V_dout  => AS_L4PHICn1_stream_V_dout,
        AS_L4PHIDn1_stream_V_dout  => AS_L4PHIDn1_stream_V_dout,
        AS_L5PHIAn1_stream_V_dout  => AS_L5PHIAn1_stream_V_dout,
        AS_L5PHIBn1_stream_V_dout  => AS_L5PHIBn1_stream_V_dout,
        AS_L5PHICn1_stream_V_dout  => AS_L5PHICn1_stream_V_dout,
        AS_L5PHIDn1_stream_V_dout  => AS_L5PHIDn1_stream_V_dout,
        AS_L6PHIAn1_stream_V_dout  => AS_L6PHIAn1_stream_V_dout,
        AS_L6PHIBn1_stream_V_dout  => AS_L6PHIBn1_stream_V_dout,
        AS_L6PHICn1_stream_V_dout  => AS_L6PHICn1_stream_V_dout,
        AS_L6PHIDn1_stream_V_dout  => AS_L6PHIDn1_stream_V_dout,
        AS_D1PHIAn1_stream_V_dout  => AS_D1PHIAn1_stream_V_dout,
        AS_D1PHIBn1_stream_V_dout  => AS_D1PHIBn1_stream_V_dout,
        AS_D1PHICn1_stream_V_dout  => AS_D1PHICn1_stream_V_dout,
        AS_D1PHIDn1_stream_V_dout  => AS_D1PHIDn1_stream_V_dout,
        AS_D2PHIAn1_stream_V_dout  => AS_D2PHIAn1_stream_V_dout,
        AS_D2PHIBn1_stream_V_dout  => AS_D2PHIBn1_stream_V_dout,
        AS_D2PHICn1_stream_V_dout  => AS_D2PHICn1_stream_V_dout,
        AS_D2PHIDn1_stream_V_dout  => AS_D2PHIDn1_stream_V_dout,
        AS_D3PHIAn1_stream_V_dout  => AS_D3PHIAn1_stream_V_dout,
        AS_D3PHIBn1_stream_V_dout  => AS_D3PHIBn1_stream_V_dout,
        AS_D3PHICn1_stream_V_dout  => AS_D3PHICn1_stream_V_dout,
        AS_D3PHIDn1_stream_V_dout  => AS_D3PHIDn1_stream_V_dout,
        AS_D4PHIAn1_stream_V_dout  => AS_D4PHIAn1_stream_V_dout,
        AS_D4PHIBn1_stream_V_dout  => AS_D4PHIBn1_stream_V_dout,
        AS_D4PHICn1_stream_V_dout  => AS_D4PHICn1_stream_V_dout,
        AS_D4PHIDn1_stream_V_dout  => AS_D4PHIDn1_stream_V_dout,
        AS_D5PHIAn1_stream_V_dout  => AS_D5PHIAn1_stream_V_dout,
        AS_D5PHIBn1_stream_V_dout  => AS_D5PHIBn1_stream_V_dout,
        AS_D5PHICn1_stream_V_dout  => AS_D5PHICn1_stream_V_dout,
        AS_D5PHIDn1_stream_V_dout  => AS_D5PHIDn1_stream_V_dout,
        MPAR_L1L2ABC_stream_V_dout => MPAR_L1L2ABC_stream_V_dout,
        MPAR_L1L2DE_stream_V_dout  => MPAR_L1L2DE_stream_V_dout,
        MPAR_L1L2F_stream_V_dout   => MPAR_L1L2F_stream_V_dout,
        MPAR_L1L2G_stream_V_dout   => MPAR_L1L2G_stream_V_dout,
        MPAR_L1L2HI_stream_V_dout  => MPAR_L1L2HI_stream_V_dout,
        MPAR_L1L2JKL_stream_V_dout => MPAR_L1L2JKL_stream_V_dout,
        MPAR_L2L3ABCD_stream_V_dout=> MPAR_L2L3ABCD_stream_V_dout,
        MPAR_L3L4AB_stream_V_dout  => MPAR_L3L4AB_stream_V_dout,
        MPAR_L3L4CD_stream_V_dout  => MPAR_L3L4CD_stream_V_dout,
        MPAR_L5L6ABCD_stream_V_dout=> MPAR_L5L6ABCD_stream_V_dout,
        MPAR_D1D2ABCD_stream_V_dout=> MPAR_D1D2ABCD_stream_V_dout,
        MPAR_D3D4ABCD_stream_V_dout=> MPAR_D3D4ABCD_stream_V_dout,
        MPAR_L1D1ABCD_stream_V_dout=> MPAR_L1D1ABCD_stream_V_dout,
        MPAR_L1D1EFGH_stream_V_dout=> MPAR_L1D1EFGH_stream_V_dout,
        MPAR_L2D1ABCD_stream_V_dout=> MPAR_L2D1ABCD_stream_V_dout
      );
  end generate sectorProc;

  -- Write signals to output .txt files

  -- Write memories from end of chain.

    writeMPAR_L1L2ABC : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1L2ABC"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1L2ABC_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1L2ABC_stream_V_dout
    );
    writeMPAR_L1L2DE : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1L2DE"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1L2DE_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1L2DE_stream_V_dout
    );
    writeMPAR_L1L2F : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1L2F"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1L2F_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1L2F_stream_V_dout
    );
    writeMPAR_L1L2G : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1L2G"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1L2G_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1L2G_stream_V_dout
    );
    writeMPAR_L1L2HI : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1L2HI"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1L2HI_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1L2HI_stream_V_dout
    );
    writeMPAR_L1L2JKL : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1L2JKL"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1L2JKL_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1L2JKL_stream_V_dout
    );
    writeMPAR_L2L3ABCD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L2L3ABCD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L2L3ABCD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L2L3ABCD_stream_V_dout
    );
    writeMPAR_L3L4AB : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L3L4AB"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L3L4AB_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L3L4AB_stream_V_dout
    );
    writeMPAR_L3L4CD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L3L4CD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L3L4CD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L3L4CD_stream_V_dout
    );
    writeMPAR_L5L6ABCD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L5L6ABCD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L5L6ABCD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L5L6ABCD_stream_V_dout
    );
    writeMPAR_D1D2ABCD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_D1D2ABCD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_D1D2ABCD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_D1D2ABCD_stream_V_dout
    );
    writeMPAR_D3D4ABCD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_D3D4ABCD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_D3D4ABCD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_D3D4ABCD_stream_V_dout
    );
    writeMPAR_L1D1ABCD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1D1ABCD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1D1ABCD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1D1ABCD_stream_V_dout
    );
    writeMPAR_L1D1EFGH : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L1D1EFGH"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L1D1EFGH_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L1D1EFGH_stream_V_dout
    );
    writeMPAR_L2D1ABCD : entity work.FileWriterFIFO
    generic map (
      FILE_NAME => FILE_OUT_TPAR_73&"MPAR_L2D1ABCD"&outputFileNameEnding,
      FIFO_WIDTH=> 76
    )
    port map (
      CLK       => CLK240,
      DONE      => TP_DONE,
      WRITE_EN  => (MPAR_L2D1ABCD_stream_V_dout(75)),
      FULL_NEG  => open,
      DATA      => MPAR_L2D1ABCD_stream_V_dout
    );

end behaviour;
