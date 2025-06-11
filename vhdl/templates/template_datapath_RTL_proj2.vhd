
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.wisdom_package.all;    -- adotar os mesmos tipos declarados no projeto do wisdom circuit   


ENTITY <nome_entidade> IS
	GENERIC NOME		: TIPO:= valor_deault);
	PORT ( 	rst			: IN STD_LOGIC;
			clk 		: IN STD_LOGIC;
			
			entrada0 	: IN <tipo de dado>;
			...
			entradaN 	: IN <tipo de dado>;
			
			saida0 		: OUT <tipo de dado>;
			..
			saidaN 		: OUT <tipo de dado>);
END <nome_entidade>;


ARCHITECTURE structure OF <nome_entidade> IS

	COMPONENT modulo_0
		GENERIC (NOME		: TIPO:= valor_deault);
		PORT (	
			entrada0 	: IN <tipo de dado>;
			...
			entradaN 	: IN <tipo de dado>;
			
			saida0 		: OUT <tipo de dado>;
			..
			saidaN 		: OUT <tipo de dado>);
	END COMPONENT;

	COMPONENT modulo_1
		GENERIC NOME		: TIPO:= valor_deault);
		PORT (	
			entrada0 	: IN <tipo de dado>;
			...
			entradaN 	: IN <tipo de dado>;
			
			saida0 		: OUT <tipo de dado>;
			..
			saidaN 		: OUT <tipo de dado>;
	END COMPONENT;
	

	


//completar com todos os sinais necessarios para as conexoes
	SIGNAL <nome>		: <tipo>;
	SIGNAL <nome>		: <tipo>;


BEGIN

// completar com designações de sinais e comandos data-flow que necessitar

	saida_a 	<= sinal_x;
	sinal_z		<= sinal_y;
	sinl_w 		<= entrada_b;


// instanciar modulos necessarios
	
	item_0: modulo_0 GENERIC MAP(
						PARAMETRO => Valor real)	
					PORT MAP ( 
						entrada0	=> nome real,
						...
						entradaN	=> nome real,										...
						saida0		=> nome real,
						...	
						saidaN		=> nome real);
					

	item_1: modulo_1 GENERIC MAP(
						PARAMETRO => Valor real)	
			  PORT MAP ( 
						entrada0	=> nome real,
						...
						entradaN	=> nome real,										...
						saida0		=> nome real,
						...	
						saidaN		=> nome real);


				  

END structure;

