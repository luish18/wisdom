
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.wisdom_package.ALL; -- adotar os mesmos tipos declarados no projeto do wisdom circuit   
ENTITY disciple_datapath IS
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
END disciple_datapath;
ARCHITECTURE structure OF disciple_datapath IS

	COMPONENT disc_num_gen IS
		GENERIC (
			WIDTH : NATURAL := 8;
			SEED_i : NATURAL := 4095; -- semente  binaria 111111111111      --   
			TAP_i : NATURAL := 1380;
			FFBIT : NATURAL := 1
		);

		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			alu_2_ng : IN STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0);
			canal : IN disc_ctrl_2_dp_flags;
			ng_2_RB : OUT STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT alu
		GENERIC (WIDTH : NATURAL := 8);
		PORT (
			one_op : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			rb_op : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			alu_ctrl : IN STD_LOGIC;
			alu_result : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT reg
		GENERIC (WIDTH : NATURAL := 8);
		PORT (
			clk : IN STD_LOGIC;
			clr : IN STD_LOGIC;
			load : IN STD_LOGIC;
			d : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			q : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT disciple_reg_bank
		GENERIC (
			WIDTH : NATURAL := 8
		);

		PORT (
			clk : IN STD_LOGIC;
			res : IN STD_LOGIC;
			ng_2_RB : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			load_INIT : IN STD_LOGIC;
			load_DISC : IN STD_LOGIC;
			load_PRE_DISC : IN STD_LOGIC;
			out_sel : IN RB_SEL;
			disc_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			disc_prev_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			rb_out : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT code_gen IS
		PORT (
			ctrl_code_sel : IN CODE;
			mem_code_w : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT disciple_row_udf IS
		PORT (
			clk : IN STD_LOGIC;
			res : IN STD_LOGIC;
			disc_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			ctrl_flags : OUT disc_dp_2_ctrl_flags
		);
	END COMPONENT;

	-- Sinais internos

	SIGNAL clk_s : STD_LOGIC;
	SIGNAL rst_s : STD_LOGIC;

	SIGNAL ng_2_RB_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	SIGNAL alu_2_ng_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	SIGNAL rb_2_alu_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);

	SIGNAL end_of_disciple_s : STD_LOGIC;

	SIGNAL flags_from_ctrl_s : disc_ctrl_2_dp_flags;
	SIGNAL disc_2_ref_flags_s : disc_2_ref_flags;
	SIGNAL disc_2_mem_flags_s : disc_2_mem_flags;
	SIGNAL flags_2_ctrl_s : disc_dp_2_ctrl_flags;

BEGIN

	-- Entradas
	clk_s <= clk;
	rst_s <= rst;

	-- Sinais do controle para o datapath
	flags_from_ctrl_s <= flags_from_ctrl;


	-- Saidas

	-- Para o controle
	flags_2_ctrl_s.end_of_disciple <= end_of_disciple_s;

	-- Para o referee
	-- end_of_disc : OUT STD_LOGIC;
	-- disc_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	-- disc_addr_prev : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	flags_2_ref <= disc_2_ref_flags_s;
	disc_2_ref_flags_s.end_of_disc <= end_of_disciple_s;

	-- Sinais para a memoria
	-- mem_b_addr : OUT STD_LOGIC_VECTOR(WIDTH - 3 DOWNTO 0);
	-- mem_wr_en : OUT STD_LOGIC;
	-- data_b : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	-- cg_sel : OUT CODE;
	flags_2_mem.mem_b_addr <= disc_2_mem_flags_s.mem_b_addr;
	flags_2_mem.data_b <= disc_2_mem_flags_s.data_b;
	disc_2_mem_flags_s.mem_b_addr <= disc_2_ref_flags_s.disc_addr(5 DOWNTO 0); -- enderecos de memoria sao de 6 bits


	-- Instancias

	num_gen_inst : disc_num_gen
	GENERIC MAP(WIDTH, SEED_i => 4095, TAP_i => 1380, FFBIT => 1)
	PORT MAP(
		clk => clk,
		reset => rst_s,
		alu_2_ng => alu_2_ng_s,
		canal => flags_from_ctrl_s,
		ng_2_RB => ng_2_RB_s
	);

	-- ALU adiciona 0111 0000 para subir uma linha no endereco (subtrair 1 de y) sem alterar o valor de x

	alu_inst : alu
	GENERIC MAP(WIDTH => WIDTH)
	PORT MAP(
		one_op => "01110000",
		rb_op => rb_2_alu_s,
		alu_ctrl => flags_from_ctrl_s.alu_ctrl,
		alu_result => alu_2_ng_s
	);

	register_bank_inst : disciple_reg_bank
	GENERIC MAP(WIDTH => WIDTH)
	PORT MAP(
		clk => clk,
		res => rst_s,
		ng_2_RB => ng_2_RB_s,
		load_DISC => flags_from_ctrl_s.rb_DISC_en,
		load_PRE_DISC => flags_from_ctrl_s.rb_PRE_DISC_en,
		out_sel => flags_from_ctrl_s.rb_out_sel,
		disc_addr => disc_2_ref_flags_s.disc_addr,
		disc_prev_addr => disc_2_ref_flags_s.disc_prev_addr,
		rb_out => rb_2_alu_s
	);

	code_gen_inst : code_gen
	PORT MAP(
		ctrl_code_sel => flags_from_ctrl_s.cg_sel,
		mem_code_w => disc_2_mem_flags_s.data_b 
	);

	disc_row_udf_inst : disciple_row_udf
	PORT MAP(
		clk => clk,
		res => rst_s,
		disc_addr => disc_2_ref_flags_s.disc_addr,
		ctrl_flags => end_of_disciple_s
	);




END structure;