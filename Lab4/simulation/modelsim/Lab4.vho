-- Copyright (C) 2019  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 19.1.0 Build 670 09/22/2019 SJ Lite Edition"

-- DATE "07/11/2023 15:22:22"

-- 
-- Device: Altera 10M02SCU169C8G Package UFBGA169
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY FIFTYFIVENM;
LIBRARY IEEE;
USE FIFTYFIVENM.FIFTYFIVENM_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	hard_block IS
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic
	);
END hard_block;

-- Design Ports Information
-- ~ALTERA_TMS~	=>  Location: PIN_G1,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_TCK~	=>  Location: PIN_G2,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_TDI~	=>  Location: PIN_F5,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_TDO~	=>  Location: PIN_F6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_nCONFIG~	=>  Location: PIN_E7,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_nSTATUS~	=>  Location: PIN_C4,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default
-- ~ALTERA_CONF_DONE~	=>  Location: PIN_C5,	 I/O Standard: 2.5 V Schmitt Trigger,	 Current Strength: Default


ARCHITECTURE structure OF hard_block IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL \~ALTERA_TMS~~padout\ : std_logic;
SIGNAL \~ALTERA_TCK~~padout\ : std_logic;
SIGNAL \~ALTERA_TDI~~padout\ : std_logic;
SIGNAL \~ALTERA_nCONFIG~~padout\ : std_logic;
SIGNAL \~ALTERA_nSTATUS~~padout\ : std_logic;
SIGNAL \~ALTERA_CONF_DONE~~padout\ : std_logic;
SIGNAL \~ALTERA_TMS~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TCK~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_TDI~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_nCONFIG~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_nSTATUS~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_CONF_DONE~~ibuf_o\ : std_logic;

BEGIN

ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
END structure;


LIBRARY FIFTYFIVENM;
LIBRARY IEEE;
USE FIFTYFIVENM.FIFTYFIVENM_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	Lab4 IS
    PORT (
	FFCLK : OUT std_logic;
	PH6 : IN std_logic;
	PK : IN std_logic_vector(7 DOWNTO 0);
	WE_L : IN std_logic;
	BufferEN : OUT std_logic;
	RE_L : IN std_logic
	);
END Lab4;

-- Design Ports Information
-- FFCLK	=>  Location: PIN_D11,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[5]	=>  Location: PIN_J2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[4]	=>  Location: PIN_B2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[3]	=>  Location: PIN_A10,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[2]	=>  Location: PIN_L5,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[1]	=>  Location: PIN_H6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[0]	=>  Location: PIN_A7,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- BufferEN	=>  Location: PIN_F12,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- WE_L	=>  Location: PIN_M11,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PH6	=>  Location: PIN_K8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[7]	=>  Location: PIN_L13,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- PK[6]	=>  Location: PIN_J13,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- RE_L	=>  Location: PIN_M10,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF Lab4 IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_FFCLK : std_logic;
SIGNAL ww_PH6 : std_logic;
SIGNAL ww_PK : std_logic_vector(7 DOWNTO 0);
SIGNAL ww_WE_L : std_logic;
SIGNAL ww_BufferEN : std_logic;
SIGNAL ww_RE_L : std_logic;
SIGNAL \PK[5]~input_o\ : std_logic;
SIGNAL \PK[4]~input_o\ : std_logic;
SIGNAL \PK[3]~input_o\ : std_logic;
SIGNAL \PK[2]~input_o\ : std_logic;
SIGNAL \PK[1]~input_o\ : std_logic;
SIGNAL \PK[0]~input_o\ : std_logic;
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \~QUARTUS_CREATED_UNVM~~busy\ : std_logic;
SIGNAL \FFCLK~output_o\ : std_logic;
SIGNAL \BufferEN~output_o\ : std_logic;
SIGNAL \PH6~input_o\ : std_logic;
SIGNAL \WE_L~input_o\ : std_logic;
SIGNAL \PK[7]~input_o\ : std_logic;
SIGNAL \PK[6]~input_o\ : std_logic;
SIGNAL \inst3~combout\ : std_logic;
SIGNAL \RE_L~input_o\ : std_logic;
SIGNAL \inst2~combout\ : std_logic;

COMPONENT hard_block
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic);
END COMPONENT;

BEGIN

FFCLK <= ww_FFCLK;
ww_PH6 <= PH6;
ww_PK <= PK;
ww_WE_L <= WE_L;
BufferEN <= ww_BufferEN;
ww_RE_L <= RE_L;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
auto_generated_inst : hard_block
PORT MAP (
	devoe => ww_devoe,
	devclrn => ww_devclrn,
	devpor => ww_devpor);

-- Location: LCCOMB_X11_Y9_N16
\~QUARTUS_CREATED_GND~I\ : fiftyfivenm_lcell_comb
-- Equation(s):
-- \~QUARTUS_CREATED_GND~I_combout\ = GND

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	combout => \~QUARTUS_CREATED_GND~I_combout\);

-- Location: IOOBUF_X18_Y14_N16
\FFCLK~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \inst3~combout\,
	devoe => ww_devoe,
	o => \FFCLK~output_o\);

-- Location: IOOBUF_X18_Y9_N23
\BufferEN~output\ : fiftyfivenm_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \inst2~combout\,
	devoe => ww_devoe,
	o => \BufferEN~output_o\);

-- Location: IOIBUF_X16_Y0_N29
\PH6~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PH6,
	o => \PH6~input_o\);

-- Location: IOIBUF_X14_Y0_N15
\WE_L~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_WE_L,
	o => \WE_L~input_o\);

-- Location: IOIBUF_X18_Y2_N8
\PK[7]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(7),
	o => \PK[7]~input_o\);

-- Location: IOIBUF_X18_Y3_N8
\PK[6]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(6),
	o => \PK[6]~input_o\);

-- Location: LCCOMB_X14_Y2_N0
inst3 : fiftyfivenm_lcell_comb
-- Equation(s):
-- \inst3~combout\ = (\WE_L~input_o\) # ((!\PH6~input_o\ & (!\PK[7]~input_o\ & !\PK[6]~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100110011001101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \PH6~input_o\,
	datab => \WE_L~input_o\,
	datac => \PK[7]~input_o\,
	datad => \PK[6]~input_o\,
	combout => \inst3~combout\);

-- Location: IOIBUF_X16_Y0_N8
\RE_L~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_RE_L,
	o => \RE_L~input_o\);

-- Location: LCCOMB_X14_Y2_N2
inst2 : fiftyfivenm_lcell_comb
-- Equation(s):
-- \inst2~combout\ = (\RE_L~input_o\) # ((!\PH6~input_o\ & (!\PK[7]~input_o\ & !\PK[6]~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100110011001101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \PH6~input_o\,
	datab => \RE_L~input_o\,
	datac => \PK[7]~input_o\,
	datad => \PK[6]~input_o\,
	combout => \inst2~combout\);

-- Location: IOIBUF_X0_Y5_N8
\PK[5]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(5),
	o => \PK[5]~input_o\);

-- Location: IOIBUF_X1_Y7_N15
\PK[4]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(4),
	o => \PK[4]~input_o\);

-- Location: IOIBUF_X16_Y17_N15
\PK[3]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(3),
	o => \PK[3]~input_o\);

-- Location: IOIBUF_X1_Y0_N15
\PK[2]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(2),
	o => \PK[2]~input_o\);

-- Location: IOIBUF_X0_Y5_N22
\PK[1]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(1),
	o => \PK[1]~input_o\);

-- Location: IOIBUF_X11_Y17_N1
\PK[0]~input\ : fiftyfivenm_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	listen_to_nsleep_signal => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_PK(0),
	o => \PK[0]~input_o\);

-- Location: UNVM_X0_Y8_N40
\~QUARTUS_CREATED_UNVM~\ : fiftyfivenm_unvm
-- pragma translate_off
GENERIC MAP (
	addr_range1_end_addr => -1,
	addr_range1_offset => -1,
	addr_range2_end_addr => -1,
	addr_range2_offset => -1,
	addr_range3_offset => -1,
	is_compressed_image => "false",
	is_dual_boot => "false",
	is_eram_skip => "false",
	max_ufm_valid_addr => -1,
	max_valid_addr => -1,
	min_ufm_valid_addr => -1,
	min_valid_addr => -1,
	part_name => "quartus_created_unvm",
	reserve_block => "true")
-- pragma translate_on
PORT MAP (
	nosc_ena => \~QUARTUS_CREATED_GND~I_combout\,
	busy => \~QUARTUS_CREATED_UNVM~~busy\);

ww_FFCLK <= \FFCLK~output_o\;

ww_BufferEN <= \BufferEN~output_o\;
END structure;


