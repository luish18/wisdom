
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.wisdom_package.all;    -- adotar os mesmos tipos declarados no projeto do wisdom circuit   


ENTITY <nome_entidade> IS
	PORT ( 	rst			: IN STD_LOGIC;
			clk 		: IN STD_LOGIC;);
END <nome_entidade>;

ARCHITECTURE <nome_arquitetura> OF <nome_entidade> IS
	TYPE state_type IS ();  
	SIGNAL state, next_state : state_type;
	
BEGIN
	------------------------Lógica Sequencial-----------------------
	SEQ: PROCESS (rst, clk)
	BEGIN
		IF (rst='1') THEN
			state <= estado0;
		ELSIF Rising_Edge(clk) THEN
			state <= next_state;
		END IF;
	END PROCESS SEQ;
	-----------------------Lógica Combinacional do estado siguinte--
	COMB: PROCESS ( state)  
	BEGIN
		CASE state IS

		END CASE;
	END PROCESS COMB;

	-----------------------Lógica Combinacional saidas---------------------
	SAI: PROCESS (state)
	BEGIN
		CASE state IS
			
		END CASE;
	END PROCESS SAI

END <nome_arquitetura>;