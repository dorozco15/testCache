library	ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 
--use work.MP_lib.all;

entity DataMemory is
port ( 
	clock_en : in std_logic;
	clock : in std_logic;
	reset:     in std_logic;
	read_en : in std_logic;
	write_en: in std_logic;
	line_in: in std_logic_vector(2 downto 0);
	data_out: out std_logic_vector(15 downto 0);
	data_in: in std_logic_vector(15 downto 0);
	word_in: in std_logic_vector(1 downto 0);
	write_block: in std_logic;
	blockReplaced: out std_logic;
	data_block : in std_logic_vector(63 downto 0);
	send_block_out  : in std_logic ; 
	data_block_out : out std_logic_vector (63 downto 0)
		);
		
end DataMemory;

architecture behav of DataMemory is

type data_array is array (0 to 7, 0 to 3) of std_logic_vector(15 downto 0);
signal memory: data_array;
signal line_check: integer;
signal word_check: integer;


begin 

line_check <= to_integer(unsigned(line_in));
word_check <= to_integer(unsigned (word_in));
	
	   write1: process(clock, reset, clock_en, write_block, write_en, read_en, line_check, word_check)
	begin 
	if (reset = '1') then 
		for i in 0 to 7 loop 
			for j in 0 to 3 loop
				memory(i,j) <= "0000000000000000";
			end loop;
		end loop;
	else 
		if (write_block ='1') then 
					memory(line_check, 0) <= data_block(15 downto 0);
					memory(line_check, 1) <= data_block(31 downto 16);
					memory(line_check, 2) <= data_block(47 downto 32);
					memory(line_check, 3) <= data_block(63 downto 48);
					blockReplaced <= '1';
		else	
			blockReplaced <= '0';
			if (clock_en = '1') then 
				if (rising_edge(clock)) then
					if ((write_en = '1') and (read_en = '0')) then
						memory(line_check, word_check) <= data_in ;
					end if;
				end if;
			end if;
		end if;
	end if;
	end process;
	
	read1: process(clock, reset, clock_en, write_block, write_en, read_en, line_check, word_check)
	begin 
	if (clock_en ='1') then 
		if (rising_edge(clock)) then 
			if ((read_en = '1') and (write_en = '0')) then
				data_out <= memory(line_check, word_check);
			end if;
		end if;
	end if;

	end process;
	
	sendblock : process (send_block_out)
	begin
	if (send_block_out = '1') then 
						data_block_out(15 downto 0)<= memory(line_check, 0);
					  data_block_out(31 downto 16) <= memory(line_check, 1);
						data_block_out(47 downto 32) <= memory(line_check, 2) ;
					  data_block_out(63 downto 48)<= memory(line_check, 3);
					  
	end if;
	end process;
end behav;