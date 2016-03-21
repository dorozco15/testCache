library	ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 
use work.MP_lib.all;

entity Cache is
port (
		cache_en				: in std_logic;
		clock					: 	in STD_LOGIC;
		reset					:  in STD_LOGIC;
		Mre					:	in STD_LOGIC;
		Mwe					:	in STD_LOGIC;
		address				:	in STD_LOGIC_VECTOR(11 downto 0);
		data_in				:	in STD_LOGIC_VECTOR(15 downto 0);
		data_out				:	out STD_LOGIC_VECTOR(15 downto 0);
		delayReq				: out std_logic;
		-----debug signals----
		state_con_d : out std_LOGIC_VECTOR(3 downto 0);
		state_d : out std_logic_vector(3 downto 0);
		done_cache : out std_LOGIC;
		done_controller_d : out std_ulogic;
		controller_en_d : out std_LOGIC;
		done_check_d : out std_logic
		);
		
end Cache;

architecture behav of Cache is
signal MreIn : std_logic;
signal MweIn : std_logic;

signal Mre_mem: std_logic;
signal Mwe_mem: std_logic;
--signal addressIn: std_LOGIC_VECTOR(11 downto 0);

signal dataIn : std_logic_vector(63 downto 0);
signal data_out_cpu : std_logic_vector(15 downto 0);
signal data_out_mem : std_logic_vector(63 downto 0);
signal address_mem: std_logic_vector(11 downto 0);
signal data_block_in: std_logic_vector(63 downto 0);
signal address_block_in : std_logic_vector(11 downto 0);
signal replaceStatusIn: STD_LOGIC:= '0';
signal replaceStatusOut: std_logic; 
type state_type is (sIdle,sReset, Sdelay,s0,s1, s1b, s1c,s2,s3,s4, s5, s6,s6b,s7,s8);
signal state: state_type;
signal done_out :  std_ulogic;
signal controller_en : std_logic;
signal hit : std_ulogic;
signal nextState: state_type;
signal done_check: std_logic;
signal state_controller : std_logic_vector(3 downto 0);
begin 
	
	Mre_mem <= Mre;
	Mwe_mem <= Mwe;
	data_block_in <= data_out_mem;
--	MreIn <= Mre;
--	MweIn <= Mwe;
	controller_en_d <= controller_en;
	done_controller_d <= done_out;
	state_con_d <= state_controller;
	done_check_d <= done_check;
	
	Unit1: CacheController port map(controller_en, clock,reset,Mre, Mwe, address, address_mem, 
	data_in, data_out_cpu, replaceStatusIn, replaceStatusOut, data_block_in, address_block_in, 
	delayReq, done_out, hit, state_controller);
	Unit2: MainMemory port map(replaceStatusOut, clock,reset, Mre_mem, Mwe_mem, address_mem, dataIn, data_out_mem);

	process(clock, reset, Mre, Mwe, done_out, done_check, state_controller)
	variable NumDelayCycles: integer;	
	variable read_var : std_logic;
	variable write_var : std_logic;

	begin
--		if ((Mre = '1') or (Mwe = '1')) then 
--					controller_en <= '1';
--					--state <= sReset;
--		else 
--				controller_en<= '0';
-- 		end if;
		if (reset = '1') then
			state <= sReset;
			done_check <= '0';
			
		else 
				
					
			if ((Mre = '1') or (Mwe = '1')) then
		
				

				controller_en <= '1';
--				if ((done_check = '1') and (state_controller = "1111" )) then 
--						controller_en <= '0';
--
--				end if;					
					
				if (rising_edge(clock)) then 
					
					
					if ((done_out = '0') and (state_controller = "1111")) then
						done_check <= '1';
					elsif (done_out = '1') then
						done_check <= '1';
					--elsif ((done_out = '0')and ((Mre = '1') or (Mwe = '1')))
					else 
						done_check <= '0';
					end if;
					
						Case state is 
						
						when sReset => 
								state<= s1;
								--controller_en <= '1';
								state_d <= x"f";
						when s0 =>
								state_d <= x"0";
								if (hit ='0') then 
									state <= s1;
								end if;
						
						when s1 =>
								state_d <= x"1";
								if (replaceStatusOut = '1') then
									state <= sDelay;
									numDelayCycles := 8;
									nextState <= s2;
								end if;
						
						when s2 =>
								state_d <= x"2";
								replaceStatusIn <= '1';
								
						
						when sDelay=>
								state_d <= x"e";
								numDelayCycles := numDelayCycles -1 ;
								if (numDelayCycles = 0) then
										state <= nextState;
								else 
										state <= Sdelay;
								end if;
						when others =>
						end case;
						
					end if;
				else 
					--controller_en<= '0';
					if ((done_out = '0') ) then 
						controller_en <= '1';
					end if;
					if (state_controller = "1111") then
						controller_en <= '0';
					end if;
			end if;
			data_out <= data_out_cpu;
		end if;
		
		
	end process;
--	process (replaceStatusOut, replaceStatusIn)
--	begin
--		
--		if (replaceStatusOut = '1') then 
--			replaceStatusIn <= '1';
--		end if;
--	end process;
--	data_out <= data_out_cpu;

--	replaceBlock: process(clock, replaceStatusOut, replaceStatusIn, data_out_mem, data_out_cpu)
--	begin 
--		if (replaceStatusOut = '1') then 
--			
--		Mre_mem <= '1';
--		replaceStatusIn <= '1';
--		data_block_in <= data_out_mem;
--		--data_out <= data_out_cpu;
--		end if;
--		replaceStatusIn <= '0';
--		--data_out <= data_out_cpu;
--		end process;
end behav;