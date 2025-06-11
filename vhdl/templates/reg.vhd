--Descrição do circuito feito por:
--MSc. Mario Raffo, Ex-membro do GSEIS
--Universidade de São Paulo

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.NUMERIC_STD.ALL;

ENTITY reg IS
	GENERIC (NUMBITS	: NATURAL := 32);
	PORT( SIGNAL clr :  IN STD_LOGIC;   
		  SIGNAL clk :  IN STD_LOGIC;
		  SIGNAL load  :  IN STD_LOGIC;
		  SIGNAL d	 :  IN STD_LOGIC_VECTOR(NUMBITS-1 DOWNTO 0);
		  SIGNAL q   : OUT STD_LOGIC_VECTOR(NUMBITS-1 DOWNTO 0));
END reg;

ARCHITECTURE behavior OF reg IS

BEGIN

	PROCESS (clr,clk,load)
	BEGIN
		IF (clr = '1') THEN
			q <= (OTHERS => '0');
		ELSIF Rising_Edge(clk) THEN
			IF (load = '1') THEN
				q <= d;
			END IF;
		END IF;
	END PROCESS;

END behavior;

