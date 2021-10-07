LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
--------------------------------------
ENTITY cronometro IS
	PORT(			clk			: 	IN		STD_LOGIC;
					rst			: 	IN		STD_LOGIC;
					ena			: 	IN		STD_LOGIC;
					syn_clr		:	IN		STD_LOGIC;
					max_tick		: 	OUT	STD_LOGIC := '1';
					sseg_1		: 	OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0);
					sseg_2		:	OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
					sseg_3		:  OUT 	STD_LOGIC_VECTOR(6 DOWNTO 0));                                      
END ENTITY;
---------------------------------------
ARCHITECTURE rt1 OF cronometro IS
	SIGNAL min_tick0_s, min_tick1_s, min_tick2_s, min_tick3_s  	: STD_LOGIC;
	SIGNAL max_tick0_s, max_tick1_s, max_tick2_s, max_tick3_s  	: STD_LOGIC;
	SIGNAL ena1_s, ena2_s, ena3_s											: STD_LOGIC;
	SIGNAL rst_end_0 ,rst_end_1, rst_end_2, rst_end_3			  	: STD_LOGIC;
	SIGNAL counter0_s 													  	: STD_LOGIC_VECTOR(22 DOWNTO 0);
	SIGNAL counter1_s, counter2_s, counter3_s							: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reset_s, reset_v													: STD_LOGIC_VECTOR(2 DOWNTO 0);
	
BEGIN	
	-------------------------------Resets----------------------------
	reset_v(2)<= reset_s(2) OR (NOT (rst)) OR syn_clr;
	reset_v(0)<= reset_s(0) OR (NOT (rst)) OR syn_clr;
	reset_v(1)<= reset_s(1) OR (NOT (rst)) OR syn_clr;
	----------------------------------------------------------------
	
	-- contador de 100ms -------------------------------------------
	counter: ENTITY WORK.univ_bit_counter
					GENERIC MAP (  N => 23)
					PORT MAP		(  clk		=> clk,
										rst		=> (NOT (rst)),	
										ena		=> ena,	
										syn_clr	=> syn_clr,	
										max_tick	=> max_tick0_s,
										counter	=> counter0_s );	
		-- cuenta 900 ms ---------------------------------------------
	mili_sec:	ENTITY WORK.counter_to_9																						
					GENERIC MAP (  N => 4)
					PORT MAP		(  clk		=> clk,
										rst		=> reset_v(0),	
										ena		=> ena1_s,	
										syn_clr	=> syn_clr,	
										max_tick	=> max_tick1_s,
										counter	=> counter1_s );
	ena1_s <= max_tick0_s;
	-- cuenta 9 s --------------------------------------------------
	uni_sec:	ENTITY WORK.counter_to_9
					GENERIC MAP (  N => 4)
					PORT MAP		(  clk		=> clk,
										rst		=> reset_v(1),	
										ena		=> ena2_s,	
										syn_clr	=> syn_clr,	
										max_tick	=> max_tick2_s,
										counter	=> counter2_s );
	ena2_s <= (max_tick0_s AND max_tick1_s);
	-- cuenta 90 s ---------------------------------------------------
	dec_sec:	ENTITY WORK.counter_to_9
					GENERIC MAP (  N => 4)
					PORT MAP		(  clk		=> clk,
										rst		=> reset_v(2),	
										ena		=> ena3_s,	
										syn_clr	=> syn_clr,	
										max_tick	=> max_tick3_s,
										counter	=> counter3_s );
	ena3_s <= (max_tick0_s AND max_tick1_s AND max_tick2_s);									
										
	----------------------------------Muxes------------------------------
	with counter1_s SELECT
			reset_s(0) <= '1' when "1010",
								'0' WHEN OTHERS;							
	with counter2_s SELECT
			reset_s(1) <= '1' when "1010",
								'0' WHEN OTHERS;
	with counter3_s SELECT
			reset_s(2) <= '1' when "1010",
								'0' WHEN OTHERS;	
	----------------------------------------------------------------------
	-- 7_seg mili_sec ------------------------------------------------- 	
		WITH counter1_s SELECT
		sseg_1	<=	"1000000" when "0000", -- 0
						"1111001" when "0001", -- 1
						"0100100" when "0010", -- 2
						"0110000" when "0011", -- 3
						"0011001" when "0100", -- 4
						"0010010" when "0101", -- 5 
						"0000010" when "0110", -- 6
						"1111000" when "0111", -- 7
						"0000000" when "1000", -- 8
						"0010000" when OTHERS; -- 9				
	-- 7_seg uni_sec ------------------------------------------------- 	
		WITH counter2_s SELECT
		sseg_2	<=	"01000000" when "0000", -- 0
						"01111001" when "0001", -- 1
						"00100100" when "0010", -- 2
						"00110000" when "0011", -- 3
						"00011001" when "0100", -- 4
						"00010010" when "0101", -- 5 
						"00000010" when "0110", -- 6
						"01111000" when "0111", -- 7
						"00000000" when "1000", -- 8
						"00010000" when OTHERS; -- 9
	-- 7_seg dec_sec ------------------------------------------------- 	
		WITH counter3_s SELECT
		sseg_3	<=	"1000000" when "0000", -- 0
						"1111001" when "0001", -- 1
						"0100100" when "0010", -- 2
						"0110000" when "0011", -- 3
						"0011001" when "0100", -- 4
						"0010010" when "0101", -- 5 
						"0000010" when "0110", -- 6
						"1111000" when "0111", -- 7
						"0000000" when "1000", -- 8
						"0010000" when OTHERS; -- 9
END ARCHITECTURE;