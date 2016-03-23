library	ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 
use work.MP_lib.all;

entity TagMemory is
port ( 
	clock_en: in std_logic;
	clock: in std_logic; 
	reset: in std_logic;
	tag_in: in std_logic_vector(6 downto 0);
	hit : out std_ulogic; 
	line_in: in std_logic_vector(2 downto 0);
	write_en  : in std_logic;
	tag_out : out std_logic_vector(6 downto 0);
	read_en : in std_logic
		);
		
end TagMemory;

architecture behav of TagMemory is

type line_array is array (0 to 7) of std_logic_vector(6 downto 0) ;
signal memory: line_array;
signal tagFound : std_logic;
signal line_check: integer;

begin 
line_check <= to_integer(unsigned(line_in));
	write: process(clock, reset, clock_en, write_en)
	begin 
	if (reset ='1') then 
		memory  <= (
			0 =>"0000000" ,
			1 =>"0000000",
			2 =>"0000000",
			3 =>"0000000",
			4 =>"0000000",
			5 =>"0000000",
			6 =>"0000000",
			7 =>"0000000");
	else
		if (clock_en = '1') then 
			if (rising_edge(clock))then
				if ((write_en = '1')and (read_en ='0')) then
					memory(line_check) <= tag_in;
				end if;
			end if;
		end if;
	end if;
	end process;
	read: process(clock, reset, read_en, clock_en)
	begin
	
	if (clock_en ='1')then
		if (rising_edge(clock)) then
			hit <= 'Z';
			if ((read_en = '1') and (write_en ='0')) then
				if (memory(line_check) = tag_in) then 
					hit <= '1';
				else
					hit <= '0';
				end if;
				tag_out <= memory(line_check);
			end if;
		end if;
	end if;
	
	end process;
	

	
		
end behav; 