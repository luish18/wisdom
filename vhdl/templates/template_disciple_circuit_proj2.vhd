
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.wisdom_package.all;


ENTITY xx_top IS
	GENERIC (WIDTH	: NATURAL := 8;
			etc..);
	PORT 	(SIGNAL rst				:  IN STD_LOGIC;
			SIGNAL clk				:  IN STD_LOGIC;
			SIGNAL start			:  IN STD_LOGIC;
			SIGNAL etc... );
END rxx_top;

ARCHITECTURE structure OF xx_top IS

	COMPONENT <nome_fsm>
	// seguir a descricao da entity do componente
	PORT ( 	rst			: IN STD_LOGIC;
			clk 		: IN STD_LOGIC;
			
			entrada0 	: IN <tipo de dado>;
			...
			entradaN 	: IN <tipo de dado>;
			
			saida0 		: OUT <tipo de dado>;
			..
			saidaN 		: OUT <tipo de dado>);
	END COMPONENT;	
	
	COMPONENT <nome_datapath>
	GENERIC NOME		: TIPO:= valor_deault);
	PORT ( 	rst			: IN STD_LOGIC;
			clk 		: IN STD_LOGIC;
			
			entrada0 	: IN <tipo de dado>;
			...
			entradaN 	: IN <tipo de dado>;
			
			saida0 		: OUT <tipo de dado>;
			..
			saidaN 		: OUT <tipo de dado>);
	END COMPONENT;

	SIGNAL clk_s			: STD_LOGIC;
	SIGNAL rst_s			: STD_LOGIC;
	SIGNAL <nome>		: <tipo>;
	SIGNAL <nome>		: <tipo>;



BEGIN

	clk <= clk_s;
	rst <= rst_s;
	
	fsm0: <nome_fsm> PORT MAP(
				rst					=> rst_s,
				clk					=> clk_s,);
	
	
	dp0: <nome_datapath> GENERIC MAP (
					PARAMETRO => escolher valores)
				PORT MAP (
					rst				=> rst_s,
					clk				=> clk_s);


END structure;
