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
		done_controller_d : out std_logic;
		controller_en_d : out std_LOGIC;
		done_check_d : out std_logic;
		replaceStatusOut_d : out std_logic; 
		replaceStatusIn_d : out std_logic;
		mem_block_out_d : out std_logic_vector(63 downto 0);
		slowClock_d : out std_logic;
		write_block_d : out std_logic;
		cont_out_block : out std_logic_vector(63 downto 0);
		write_back_mem_d : out std_logic;
		done_write_back_d : out std_logic;
		write_address_mem_d : out std_LOGIC_VECTOR(9 downto 0)
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
signal done_out :  std_logic;
signal controller_en : std_logic;
signal hit : std_ulogic;
signal nextState: state_type;
signal done_check: std_logic;
signal state_controller : std_logic_vector(3 downto 0);
signal block_out_cont : std_logic_vector( 63 downto 0);
signal block_out_cont_en: std_logic;
signal write_back_mem :std_logic:= '0';
signal data_in_mem : std_logic_vector(63 downto 0);
signal done_write_back: std_logic; 
signal write_address_mem : std_logic_vector (9 downto 0);

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
	write_block_d <= block_out_cont_en;
	write_back_mem_d <= write_back_mem; 
	done_write_back_d <= done_write_back;
	write_address_mem_d <= write_address_mem;
	
	Unit1: CacheController port map(controller_en, clock,reset,Mre, Mwe, address, address_mem, 
	data_in, data_out_cpu, replaceStatusIn, replaceStatusOut, data_block_in, address_block_in, 
	delayReq, done_out, block_out_cont, block_out_cont_en, done_write_back, write_address_mem, state_controller);
	Unit2: MainMemory port map( clock,reset, replaceStatusOut, write_back_mem, 
	address_mem, write_address_mem, data_in_mem, data_out_mem, slowClock_d);

	process(clock, reset, Mre, Mwe, done_out, done_check, state_controller)
	variable NumDelayCycles: integer;	


	begin

		if (reset = '1') then
			state <= sReset;
			--done_check <= '0';
			
		else 
			
			if (rising_edge(clock)) then
				done_write_back <= '0';
				Case state is 
						
						when sReset => 
								state<= s1;
								--controller_en <= '1';
								state_d <= x"f";
--						when s0 =>
--								state_d <= x"0";
--								if (hit ='0') then 
--									state <= s1;
--								end if;
--						
						when s1 =>
								state_d <= x"1";
								if (replaceStatusOut = '1') then
									state <= sDelay;
									numDelayCycles := 6;
									nextState <= s2;
								end if;
								
						when s2 =>
								state_d <= x"2";
								replaceStatusIn <= '1';
								if (block_out_cont_en ='1')  then
									state <= s3;
								end if;
						when s3 =>
								done_write_back <= '1';
								state_d <= x"3";
								data_in_mem <= block_out_cont;
								write_back_mem <= '1';
								nextState <= s4;
								state<= sDelay;
								numDelayCycles:= 6;
						when s4 => 
								write_back_mem <= '0';
								state_d <= x"4";
								
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
				if (state_controller = "1111") then
						
						replaceStatusIn <= '0';
						done_write_back <= '0';
						write_back_mem <= '0';
					end if;
			end if;
					
			if ((Mre = '1') or (Mwe = '1')) then
		
				

				controller_en <= '1';
				state <= sreset;
					

			else 
					--controller_en<= '0';
					if ((done_out = '0') ) then 
						controller_en <= '1';
					end if;
					if (state_controller = "1111") then
						controller_en <= '0';
--						replaceStatusIn <= '0';
--						done_write_back <= '0';
--						write_back_mem <= '0';
					end if;
			end if;
			data_out <= data_out_cpu;
		end if;
		
		
	end process;
cont_out_block <= block_out_cont;
replaceStatusIn_d <= replaceStatusIn;
replaceStatusOut_d<= replaceStatusOut;
mem_block_out_d <= data_out_mem;
end behav;