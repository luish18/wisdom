LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.wisdom_package.ALL;
ENTITY disc_reg_bank IS
	GENERIC (
		WIDTH : NATURAL := 8
	);

	PORT (
		clk : IN STD_LOGIC;
		res : IN STD_LOGIC;
		ng_2_RB : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		load_DISC : IN STD_LOGIC;
		load_PRE_DISC : IN STD_LOGIC;
		out_sel : IN RB_SEL;
		disc_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		disc_prev_addr : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
		rb_out : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
	);
END disc_reg_bank;
ARCHITECTURE arch OF disc_reg_bank IS

	--***********************************
	--*	TYPE DECLARATIONS				*
	--***********************************

	--***********************************
	--*	COMPONENT DECLARATIONS			*
	--***********************************

	COMPONENT reg
		GENERIC (
			WIDTH : NATURAL := 8
		);

		PORT (
			clk : IN STD_LOGIC;
			clr : IN STD_LOGIC;
			load : IN STD_LOGIC;
			d : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
			q : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
		);
	END COMPONENT;
	--***********************************
	--*	INTERNAL SIGNAL DECLARATIONS	*
	--***********************************
	SIGNAL DISC_out_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
	SIGNAL PRE_DISC_out_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
BEGIN

	--*******************************
	--*	COMPONENT INSTANTIATIONS	*
	--*******************************
	reg_DISC : reg GENERIC MAP
	(
		WIDTH => WIDTH
	)

	PORT MAP
	(
		clk => clk,
		clr => res,
		load => load_DISC,
		d => ng_2_RB,
		q => DISC_out_s
	);

	reg_PRE_DISC : reg GENERIC MAP
	(
		WIDTH => WIDTH
	)

	PORT MAP
	(
		clk => clk,
		clr => res,
		load => load_PRE_DISC,
		d => DISC_out_s,
		q => PRE_DISC_out_s
	);

	--*******************************
	--*	SIGNAL ASSIGNMENTS			*
	--*******************************

	rb_out <= DISC_out_s WHEN (out_sel = DISC_OUT) ELSE
		PRE_DISC_out_s WHEN (out_sel = DISC_PREV_OUT) ELSE
		(OTHERS => 'X');

	DISC_addr <= DISC_out_s;
	disc_prev_addr <= PRE_DISC_out_s;

END arch;