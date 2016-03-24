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
		done_out_d : out std_logic;
		controller_en_d : out std_LOGIC;

		replaceStatusOut_d : out std_logic; 
		replaceStatusIn_d : out std_logic;
		block_to_cache_d : out std_logic_vector(63 downto 0);
		slowClock_d : out std_logic;
		send_to_mem_d : out std_logic;
		block_to_mem_d : out std_logic_vector(63 downto 0);
		write_to_mem_d : out std_logic;
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
type state_type is (sIdle,sReset, Sdelay,sDelay2, sDelay3, s0,s1, s1b, s1c,s2,s3,s4, s5, s6,s6b,s7,s8);
signal state: state_type;
signal done_out :  std_logic;
signal controller_en : std_logic;
signal hit : std_ulogic;
signal nextState: state_type;

signal state_controller : std_logic_vector(3 downto 0);
signal block_to_mem : std_logic_vector( 63 downto 0);
signal send_to_mem: std_logic;
signal write_to_mem :std_logic:= '0';
signal data_in_mem : std_logic_vector(63 downto 0);
signal done_write_back: std_logic:='1'; 
signal write_address_mem : std_logic_vector (9 downto 0);
signal slowClock : std_logic ; 
begin 
	
	Mre_mem <= Mre;
	Mwe_mem <= Mwe;
	data_block_in <= data_out_mem;
--	MreIn <= Mre;
--	MweIn <= Mwe;
	controller_en_d <= controller_en;
	done_out_d <= done_out;
	state_con_d <= state_controller;

	send_to_mem_d <= send_to_mem;
	write_to_mem_d <= write_to_mem; 
	done_write_back_d <= done_write_back;
	write_address_mem_d <= write_address_mem;
	block_to_mem_d <= block_to_mem;
	replaceStatusIn_d <= replaceStatusIn;
	replaceStatusOut_d<= replaceStatusOut;
	block_to_cache_d <= data_out_mem;
	slowClock_d <= slowClock;
	
	Unit1: CacheController port map(controller_en, clock,reset,Mre, Mwe, address, address_mem, 
	data_in, data_out_cpu, replaceStatusIn, replaceStatusOut, data_block_in, address_block_in, 
	delayReq, done_out, block_to_mem, send_to_mem, done_write_back, write_address_mem, state_controller);
	Unit2: MainMemory port map( clock,reset, replaceStatusOut, write_to_mem, 
	address_mem, write_address_mem, data_in_mem, data_out_mem, slowClock);

	process(clock, reset, Mre, Mwe, done_out, cache_en, state_controller)

	begin

		if (reset = '1') then
			state <= sReset;
			--done_check <= '0';
			
		else 
			if (Cache_en = '1') then 
				controller_en <= '1';
				if (rising_edge(clock)) then
					
					Case state is 
						
						when sReset => 
								state<= s1;
								--controller_en <= '1';
								state_d <= x"f";

						when s1 =>
								state_d <= x"1";
								if (replaceStatusOut = '1') then
									state <= sDelay;
									nextState <= s2;
								end if;
								
						when s2 =>
								state_d <= x"2";
								replaceStatusIn <= '1';
								if (send_to_mem ='1')  then
									done_write_back <= '0';
									state <= s3;
								end if;
						when s3 =>
								
								state_d <= x"3";
								data_in_mem <= block_to_mem;
								write_to_mem <= '1';
								nextState <= s4;
								state<= sDelay;
								
						when s4 => 
								done_write_back <= '1';
								write_to_mem <= '0';
								state_d <= x"4";
								
						when sDelay=>
								state_d <= x"e";
--								
								if (slowClock = '1') then
									state <= sDelay2;
								end if;
						when sDelay2 => 
								if (slowClock = '0') then 
									state <= sDelay3 ;
								end if;
						when sDelay3 =>
								if (slowClock = '1') then
									state <= nextState;
								end if;
						when others =>
						end case;
						
				end if;
				if (done_out = '1') then 
					controller_en <= '0';
				end if;
		else 
			state <= sreset;
			replaceStatusIn <= '0';
			done_write_back <= '0';
			write_to_mem <= '0';
		end if;

			data_out <= data_out_cpu;
		end if;
		
		
	end process;

end behav;