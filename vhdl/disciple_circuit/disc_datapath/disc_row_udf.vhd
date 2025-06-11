LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.wisdom_package.ALL;

ENTITY disciple_row_udf IS
    PORT (
        clk : IN STD_LOGIC; --from system
        res : IN STD_LOGIC; --from system
        disc_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        ctrl_flags : OUT disc_dp_2_ctrl_flags --to control unit
    );
END disciple_row_udf;
ARCHITECTURE arch OF disciple_row_udf IS

    --***********************************
    --*	INTERNAL SIGNAL DECLARATIONS	*
    --***********************************

    SIGNAL disc_addr_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ctrl_flags_s : disc_dp_2_ctrl_flags;

BEGIN

    --*******************************
    --*	SIGNAL ASSIGNMENTS			*
    --*******************************

    --                             7,    6   ,  5  ,  4  ,  3  ,  2  ,  1  ,  0
    -- endereco representado como [0, ov_of_y, y(2), y(1), y(0), x(2), x(1), x(0)]
    -- ovf_of_y ocorre quando disc_addr(6)='1' e indica que o valor de y(2) foi incrementado
    -- no caso do discipulo, end_of_disc ocorre em underflow de y
    -- como os valores de x para o discipulo podem ir de 4 a 7 (0100, 0101, 0110, 0111)
    -- sempre temos garantido que o bit indice 2 do endereco sera '0' (end_of_disc)
    -- quando subtraimos 8 do endereco (adicionar 1111 1000 subtrai 8)
    -- se o endereco em y for 0 (0000 0xxx) temos o seguinte resultado:
    -- 0000 0xxx + 1111 1000 = 1111 1xxx (end_of_disc='1', ovf_of_y='0')
    -- logo, end_of_disc ocorre quando disc_addr(3)='1' e indica que o discipulo chegou ao final do tabuleiro

    disc_addr_s <= disc_addr;

    ctrl_flags_s.end_of_disc <= '1' WHEN disc_addr_s(3) = '1' ELSE
    '0';
    ctrl_flags <= ctrl_flags_s;

END arch;