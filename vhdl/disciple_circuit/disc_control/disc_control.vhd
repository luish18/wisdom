LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.wisdom_package.ALL;

ENTITY disc_control IS
	GENERIC (WIDTH : NATURAL := 8);
		PORT (
			rst : IN STD_LOGIC;
			clk : IN STD_LOGIC;

			-- Entradas do base circuit extended
			start_step : IN STD_LOGIC;
			cnt_disc_rdy : IN STD_LOGIC;

			-- Entradas do referee
			-- go_disc : IN STD_LOGIC;
			-- duo_formed : IN STD_LOGIC;
			-- guru_right_behind : IN STD_LOGIC;
			flags_from_ref : IN ref_2_disc_flags;

			-- Recebe sinal do datapath
			-- end_of_disciple : IN STD_LOGIC;
			flags_from_dp : IN disc_dp_2_ctrl_flags;

			-- Saidas para memoria
			disc_wr_en : OUT STD_LOGIC;

			-- Saida para o datapath
			-- rb_DISC_en : OUT STD_LOGIC;
			-- rb_PRE_DISC_en : OUT STD_LOGIC;
			-- rb_out_sel : OUT RB_SEL;
			-- cg_sel : OUT CODE
			flags_2_dp : OUT disc_ctrl_2_dp_flags
		);
END disc_control;

ARCHITECTURE arch OF disc_control IS
	--***********************************
	--*	COMPONENT DECLARATIONS			*
	--***********************************

	COMPONENT fsm_disc
		GENERIC (WIDTH : NATURAL := 8);
		PORT (
			rst : IN STD_LOGIC;
			clk : IN STD_LOGIC;

			-- Entradas do base circuit extended
			start_step : IN STD_LOGIC;
			cnt_disc_rdy : IN STD_LOGIC;

			-- Entradas do referee
			go_disc : IN STD_LOGIC;
			duo_formed : IN STD_LOGIC;
			guru_right_behind : IN STD_LOGIC;

			-- Recebe sinal do datapath
			end_of_disciple : IN STD_LOGIC;

			-- Saidas para memoria
			disc_wr_en : OUT STD_LOGIC;

			-- Saida para o datapath
			ng_cte_decr : OUT STD_LOGIC;
			rb_DISC_en : OUT STD_LOGIC;
			rb_PRE_DISC_en : OUT STD_LOGIC;
			rb_out_sel : OUT RB_SEL;
			cg_sel : OUT CODE
		);
	END COMPONENT;



BEGIN

	--*******************************
	--*	COMPONENT INSTANTIATIONS	*
	--*******************************

	fsm_inst : fsm_disc
		GENERIC MAP (WIDTH => WIDTH)
		PORT MAP (
			rst => rst,
			clk => clk,

			start_step => start_step,
			cnt_disc_rdy => cnt_disc_rdy,

			go_disc => flags_from_ref.go_disc,
			duo_formed => flags_from_ref.duo_formed,
			guru_right_behind => flags_from_ref.guru_right_behind,

			end_of_disciple => flags_from_dp.end_of_disc,

			disc_wr_en => disc_wr_en,

			ng_cte_decr => flags_2_dp.ng_cte_decr,
			rb_DISC_en => flags_2_dp.rb_DISC_en,
			rb_PRE_DISC_en => flags_2_dp.rb_PRE_DISC_en,
			rb_out_sel => flags_2_dp.rb_out_sel,
			cg_sel => flags_2_dp.cg_sel
		);

END arch;