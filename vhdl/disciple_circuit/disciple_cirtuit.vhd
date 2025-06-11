LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.wisdom_package.ALL;

ENTITY disciple_circuit IS
	GENERIC (
		WIDTH : NATURAL := 8
	);
	PORT (
		SIGNAL rst : IN STD_LOGIC;
		SIGNAL clk : IN STD_LOGIC;

		-- Entradas do base circuit extended
		SIGNAL start_step : IN STD_LOGIC;
		SIGNAL cnt_disc_rdy : IN STD_LOGIC;

		-- Entradas do referee
		-- go_disc : IN STD_LOGIC;
		-- duo_formed : IN STD_LOGIC;
		-- guru_right_behind : IN STD_LOGIC;
		SIGNAL ref_2_disc_flags : IN ref_2_disc_flags;

		-- Saidas para o referee
		-- end_of_disc : OUT STD_LOGIC;
		-- disc_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		-- disc_addr_prev : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		SIGNAL disc_2_ref_flags : OUT disc_2_ref_flags;

		-- Saidas para memoria
		SIGNAL disc_wr_en : OUT STD_LOGIC;
		SIGNAL disc_addres_2_mem : OUT STD_LOGIC_VECTOR(WIDTH - 3 DOWNTO 0);
		SIGNAL disc_data : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0));
END disciple_circuit;

ARCHITECTURE structure OF disciple_circuit IS

	COMPONENT disciple_control
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
	END COMPONENT;

	COMPONENT disciple_datapath
		GENERIC (WIDTH : NATURAL := 8);
		PORT (
			rst : IN STD_LOGIC;
			clk : IN STD_LOGIC;

			-- Entradas do controle
			-- ng_cte_decr : IN STD_LOGIC;
			-- rb_DISC_en : IN STD_LOGIC;
			-- rb_PRE_DISC_en : IN STD_LOGIC;
			-- rb_out_sel : IN RB_SEL;
			-- cg_sel : IN CODE;
			flags_from_ctrl : IN disc_ctrl_2_dp_flags;

			-- Saidas para o controle
			-- end_of_disciple : OUT STD_LOGIC;
			flags_2_ctrl : OUT disc_dp_2_ctrl_flags;

			-- Saidas para o referee
			-- end_of_disc : OUT STD_LOGIC;
			-- disc_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			-- disc_addr_prev : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			flags_2_ref : OUT disc_2_ref_flags;

			-- Saidas para a memoria
			-- mem_b_addr : OUT STD_LOGIC_VECTOR(WIDTH - 3 DOWNTO 0);
			-- mem_wr_en : OUT STD_LOGIC;
			-- data_b : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			-- cg_sel : OUT CODE;
			flags_2_mem : OUT disc_2_mem_flags;

		);
	END COMPONENT;

	SIGNAL clk_s : STD_LOGIC;
	SIGNAL rst_s : STD_LOGIC;

	-- Sinais intermediarios
	-- Entradas
	SIGNAL start_step_s : STD_LOGIC;
	SIGNAL cnt_disc_rdy_s : STD_LOGIC;

	-- go_disc : STD_LOGIC;
	-- duo_formed : STD_LOGIC;
	-- guru_right_behind : STD_LOGIC;
	SIGNAL ref_2_disc_flags_s : ref_2_disc_flags;

	-- Saidas
	-- end_of_disc : STD_LOGIC;
	-- disc_addr_prev : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	-- disc_addr : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	SIGNAL disc_2_ref_flags_s : disc_2_ref_flags;

	-- Sinais de controle para o datapath
	-- ng_cte_decr : STD_LOGIC;
	-- rb_DISC_en : STD_LOGIC;
	-- rb_PRE_DISC_en : STD_LOGIC;
	-- rb_out_sel : RB_SEL;
	-- cg_sel : CODE;
	SIGNAL ctrl_2_dp_flags_s : disc_ctrl_2_dp_flags;

	-- Sinais do datapath para o controle
	-- end_of_disciple : STD_LOGIC;
	SIGNAL dp_2_ctrl_flags_s : disc_dp_2_ctrl_flags;

	-- Sainais para a memoria
	SIGNAL disc_2_mem_flags_s : disc_2_mem_flags;

BEGIN

	clk_s <= clk;
	rst_s <= rst;

	-- Entradas
	start_step_s <= start_step;
	cnt_disc_rdy_s <= cnt_disc_rdy;

	-- Referee flags
	ref_2_disc_flags_s <= flags_from_ref;

	-- Saidas
	-- Para o referee
	disc_2_ref_flags <= disc_2_ref_flags_s;
	
	-- Para a memoria
	disc_wr_en <= disc_2_mem_flags_s.mem_wr_en;
	disc_addres_2_mem <= disc_2_mem_flags_s.mem_b_addr;
	disc_data <= disc_2_mem_flags_s.data_b;

	-- Instanciando componentes
	disc_control_inst : COMPONENT disc_control
		GENERIC MAP (WIDTH => WIDTH)
		PORT MAP (
			rst => rst_s,
			clk => clk_s,

			start_step => start_step_s,
			cnt_disc_rdy => cnt_disc_rdy_s,

			flags_from_ref => ref_2_disc_flags_s,
			flags_from_dp => dp_2_ctrl_flags_s,

			-- Saidas
			disc_wr_en => disc_2_mem_flags_s.mem_wr_en,
			flags_2_dp => ctrl_2_dp_flags_s
		);

	datapath_disciple_inst : COMPONENT datapath_disciple
		GENERIC MAP (WIDTH => WIDTH)
		PORT MAP (
			rst => rst_s,
			clk => clk_s,

			flags_from_ctrl => ctrl_2_dp_flags_s,

			-- Saidas para o controle
			flags_2_ctrl => dp_2_ctrl_flags_s,

			-- Saidas para o referee
			flags_2_ref => disc_2_ref_flags_s,

			-- Saidas para a memoria
			flags_2_mem => disc_2_mem_flags_s
		);


END structure;