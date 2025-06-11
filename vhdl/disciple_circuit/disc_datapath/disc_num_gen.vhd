LIBRARY IEEE;
USE work.wisdom_package.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY disc_num_gen IS
    GENERIC (
        WIDTH : NATURAL := 8;
        SEED_i : NATURAL := 4095; -- semente  bINaria 111111111111      --   
        TAP_i : NATURAL := 1380; -- n_usp 9837924 => mod(n_usp , 1380) --
        FFBIT : NATURAL := 1;
        DELAY_T : TIME := 4ns
    );

    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        alu_2_ng : IN STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0);
        canal : IN disc_ctrl_2_dp_flags; --datapath_ctrl_flags;
        ng_2_RB : OUT STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0)
    );
END disc_num_gen;

ARCHITECTURE arch OF disc_num_gen IS
    COMPONENT rand_num IS
        GENERIC (
            WIDTH : NATURAL := 8;
            SEED_i : NATURAL := 4095; -- semente  bINaria 111111111111      --   
            TAP_i : NATURAL := 1237; --  --
            FFBIT : NATURAL := 1;
            DELAY_T : TIME := 4ns
        );

        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            rand_number : OUT STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0)
        );

    END COMPONENT;

    SIGNAL rand_number_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
    SIGNAL number_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
    SIGNAL ng_2_RB_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
    SIGNAL alu_2_ng_s : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
    SIGNAL reset_s : STD_LOGIC;
BEGIN
    reset_s <= NOT reset;
    alu_2_ng_s <= alu_2_ng;

    rand_number_gen : rand_num
    GENERIC MAP(WIDTH, SEED_i, TAP_i, FFBIT, 0 ns)
    PORT MAP(
        clk => clk,
        reset => reset_s,
        rand_number => rand_number_s
    );

    number_s <= rand_number_s;

    ng_2_RB_s <= number_s WHEN (canal.ng_cte_decr = '0') ELSE
        alu_2_ng_s WHEN (canal.ng_cte_decr = '1') ELSE
        (OTHERS => 'X');
    ng_2_RB <= ng_2_RB_s;

END arch;