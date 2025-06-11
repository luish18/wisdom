LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.wisdom_package.ALL; -- adotar os mesmos tipos declarados no projeto do wisdom circuit   
ENTITY fsm_disc IS
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
END fsm_disc;

ARCHITECTURE arch OF fsm_disc IS
    TYPE state_type IS (
                    WAITING, 
                    GEN_RAND, 
                    WRITE_RAND, 
                    WAIT_FOR_STEP, 
                    STEP, 
                    WRITE_DISC, 
                    CLEAR_PREV, 
                    WRITE_DUO, 
                    WRITE_GURU_RIGHT_BEHIND, 
                    CHECK_OVER_WALL, 
                    CHECK_GURU_BEHIND, 
                    CHECK_DUO_FORMED, 
                    END_STATE
                    );
    SIGNAL STATE, NEXT_STATE : state_type;

    -- Declara��es de sinais internos
    SIGNAL flags_2_dp : disc_ctrl_2_dp_flags; -- Sinais de controle para o datapath
    SIGNAL flags_2_mem : disc_2_mem_flags; -- Sinais de controle para a memoria

BEGIN
    ------------------------L�gica Sequencial-----------------------
    SEQ : PROCESS (rst, clk)
    BEGIN
        IF (rst = '1') THEN
            state <= WAITING;
        ELSIF Rising_Edge(clk) THEN
            state <= NEXT_STATE;
        END IF;
    END PROCESS SEQ;

    -----------------------L�gica Combinacional do estado siguinte--
    COMB : PROCESS (STATE)
    BEGIN
        CASE STATE IS

            WHEN WAITING =>
                IF start_step = '1' THEN
                    NEXT_STATE <= GEN_RAND;
                ELSE
                    NEXT_STATE <= WAITING;
                END IF;

            WHEN GEN_RAND =>
                NEXT_STATE <= WRITE_RAND;

            WHEN WRITE_RAND =>
                NEXT_STATE <= WAIT_FOR_STEP;

            WHEN WAIT_FOR_STEP =>
                IF cnt_disc_rdy = '1' THEN

                    NEX_STATE <= STEP;

                ELSE
                    NEXT_STATE <= WAIT_FOR_STEP;
                END IF;

            WHEN STEP =>
                NEXT_STATE <= CHECK_OVER_WALL;

            WHEN CHECK_OVER_WALL =>

                IF go_disc = '1' THEN
                    -- Se go_disc eh ativado, verifica se o disciple bateu na parede
                    IF end_of_disciple = '0' THEN
                        -- Se o disciple nao bateu na parede
                        NEXT_STATE <= CHECK_GURU_BEHIND;
                    ELSE
                        -- Se o disciple bateu na parede
                        NEXT_STATE <= END_STATE;
                    END IF;
                ELSE
                    -- Se go_disc nao � ativado, espera por go_disc
                    NEXT_STATE <= WAIT_FOR_STEP;
                END IF;

            WHEN CHECK_GURU_BEHIND =>

                IF guru_right_behind = '1' THEN
                    -- Se guru_right_behind eh ativado, escreve o guru right behind
                    NEXT_STATE <= WRITE_GURU_RIGHT_BEHIND;
                ELSE
                    -- Se guru_right_behind nao e ativado, verifica se duo_formed
                    NEXT_STATE <= CHECK_DUO_FORMED;
                END IF;

            WHEN CHECK_DUO_FORMED =>
                IF duo_formed = '0' THEN
                    -- Se duo_formed nao ativado, escreve o DISC
                    NEXT_STATE <= WRITE_DISC;
                ELSE
                    -- Se duo_formed nao eh ativado, escreve o DISC
                    NEXT_STATE <= WRITE_DUO;
                END IF;

            WHEN WRITE_DISC =>
                -- WRITE DISC and clear previous address
                NEXT_STATE <= CLEAR_PREV;

            WHEN CLEAR_PREV =>
                NEXT_STATE <= WAIT_FOR_STEP;

            WHEN WRITE_DUO =>
                -- WRITE DUO and clear previous address
                NEXT_STATE <= CLEAR_PREV;

            WHEN WRITE_GURU_RIGHT_BEHIND =>
                -- estado basicamente igual a WRITE_DISC, mas nao vai para CLEAR_PREV
                -- decrease addres but do not clear previous address
                NEXT_STATE <= WAIT_FOR_STEP;

            WHEN END_STATE =>
                NEXT_STATE <= WAITING; -- ou outro estado de reinicializacao

        END CASE;
    END PROCESS COMB;

    -----------------------Logica Combinacional saidas---------------------
    SAI : PROCESS (STATE)
    BEGIN
        CASE STATE IS
            WHEN WAITING =>

                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= BLANK;

                flags_2_mem.mem_wr_en <= '0';

            WHEN GEN_RAND =>

                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '1';
                flags_2_dp.rb_PRE_DISC_en <= '1';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.cg_sel <= DISC;
                flags_2_mem.mem_wr_en <= '0';

            WHEN WRITE_RAND =>

                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '1'; -- Habilita escrita na memoria
                flags_2_mem.cg_sel <= DISC; -- Seleciona o codigo DISC

            WHEN WAIT_FOR_STEP =>

                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= DISC;

            WHEN STEP =>

                flags_2_dp.ng_cte_decr <= '1';
                flags_2_dp.rb_DISC_en <= '1';
                flags_2_dp.rb_PRE_DISC_en <= '1';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= DISC;

            WHEN CHECK_OVER_WALL =>
                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= DISC;

            WHEN CHECK_GURU_BEHIND =>

                flags_2_dp.ng_cte_decr <= '1';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= DISC;

            WHEN CHECK_DUO_FORMED =>

                flags_2_dp.ng_cte_decr <= '1';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= DISC;

            WHEN WRITE_DISC =>

                flags_2_dp.ng_cte_decr <= '1';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '1'; -- Habilita escrita na memoria
                flags_2_mem.cg_sel <= DISC; -- Seleciona o codigo DISC

            WHEN CLEAR_PREV =>

                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_PREV_OUT;
                flags_2_dp.cg_sel <= BLANK;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= BLANK;

            WHEN WRITE_DUO =>

                flags_2_dp.ng_cte_decr <= '1';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DUO;

                flags_2_mem.mem_wr_en <= '1'; -- Habilita escrita na memoria
                flags_2_mem.cg_sel <= DUO; -- Seleciona o codigo DUO

            WHEN WRITE_GURU_RIGHT_BEHIND =>

                flags_2_dp.ng_cte_decr <= '1';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= DISC;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= DISC;

            WHEN END_STATE =>
                flags_2_dp.ng_cte_decr <= '0';
                flags_2_dp.rb_DISC_en <= '0';
                flags_2_dp.rb_PRE_DISC_en <= '0';
                flags_2_dp.rb_out_sel <= DISC_OUT;
                flags_2_dp.cg_sel <= BLANK;

                flags_2_mem.mem_wr_en <= '0'; -- Desabilita escrita na memoria
                flags_2_mem.cg_sel <= BLANK;

        END CASE;
    END PROCESS SAI

END arch;