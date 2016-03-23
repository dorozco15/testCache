library	ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;

package MP_lib is

component TagMemory is 
port(	clock_en: in std_logic;
	clock: in std_logic; 
	reset: in std_logic;
	tag_in: in std_logic_vector(6 downto 0);
	hit : out std_ulogic; 
	line_in: in std_logic_vector(2 downto 0);
	write_en  : in std_logic;
	tag_out : out std_logic_vector(6 downto 0);
	read_en : in std_logic
	);
end component;

component DataMemory is 
port(	clock_en : in std_logic;
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
	data_block_out : out std_logic_vector (63 downto 0));
end component;

component CacheController is 
port(	clock_en				:in std_logic;
		clock					: in std_logic;
		reset					: in std_LOGIC;
		MreIn					:	in STD_LOGIC;
		MweIn					:	in STD_LOGIC;
		addressIN			:	in STD_LOGIC_VECTOR(11 downto 0);
		addressOUT			:  out STD_LOGIC_VECTOR (11 downto 0);
		data_in				:  in STD_LOGIC_VECTOR(15 downto 0);
		data_out_cpu		:  out STD_LOGIC_VECTOR(15 downto 0);
		replaceStatusIn   :  in std_logic; 
		replaceStatusOut  :  out std_logic;
		data_block_in     :  in std_logic_vector(63 downto 0);
		address_block_in  :  in std_logic_vector(11 downto 0);
		delayReq				: out std_logic;
		done_out             : out std_logic;
		data_block_out     : out std_logic_vector(63 downto 0);
		send_block_out_mem     : out std_logic;
		done_write_back     : in std_logic;
		blockAddressOut : out std_logic_vector(9 downto 0); 
		state_d					: out std_logic_vector(3 downto 0)
		);
end component;

component MainMemory IS
	PORT
	(
--clock_en : in std_logic; 
	clock		: 	in std_logic;
	rst		: 	in std_logic;
	Mre		:	in std_logic;
	Mwe		:	in std_logic;
	addressIn	:	in std_logic_vector(11 downto 0);
	writeAddress : in std_logic_vector(9 downto 0);
	data_in	:	in std_logic_vector(63 downto 0);
	data_out:	out std_logic_vector (63 downto 0);
	slowClock_out : out std_logic
	);
END component;

end MP_lib;

package body MP_lib is 

end MP_lib;
