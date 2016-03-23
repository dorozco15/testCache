library	ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 
use work.MP_lib.all;

entity CacheController is
port (
		clock_en				:in std_logic;
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
		----debug lines
--		 read_data_d : out std_logic; 
-- write_data_d : out std_logic;
-- write_tag_d :  out std_logic;
-- read_tag_d : out std_logic;
-- write_block_d:  out std_logic;

---- tempDataIn_d : out std_logic_vector(15 downto 0);
---- tempDataOut_d : out std_logic_vector(15 downto 0);
-- --tagIndex_d: out std_logic_vector(6 downto 0);
-- --lineIndex_d: out std_logic_vector(2 downto 0);
---- wordIndex_d: out std_logic_vector(1 downto 0);
-- hit_d: out STD_LOGIC; 
--send_block_out_d : out std_logic;
--tag_enable_d: out std_logic;
-- data_enable_d: out std_logic;
-- blockReplaced_d: out std_logic;
---- read_var_d :out std_logic;
---- write_var_d :out std_logic;
state_d : out std_logic_vector(3 downto 0)
  	
		);
		
end CacheController;

architecture behav of CacheController is
signal read_data :  std_logic := '0'; 
signal write_data :  std_logic:=  '0';
signal write_tag :   std_logic;
signal read_tag :  std_logic;
signal write_block:  std_logic;
signal data_block: std_logic_vector(63 downto 0);
signal tempDataIn : std_logic_vector(15 downto 0);
signal tempDataOut : std_logic_vector(15 downto 0);
signal tagIndex: std_logic_vector(6 downto 0);
signal lineIndex: std_logic_vector(2 downto 0);
signal wordIndex: std_logic_vector(1 downto 0);
signal hit: STD_LOGIC; 
signal tagWrote: std_logic;
signal tag_enable: std_logic;
signal data_enable: std_logic;
signal blockReplaced: std_logic;
type state_type is (sWait,sReset, Sdelay,s0,s1, s1b, s1c,s2,s3,s4, s5, s6,s6b,s7,s8);
type line_array is array (0 to 7, 0 to 3) of std_logic;
signal state: state_type;	
signal done: std_logic;
  signal nextState: state_type;
  signal delayNum : integer := 2;
  signal useDelay : std_logic; 
--signal replaceStatus : std_logic;
signal read_in : std_logic;
signal write_in: std_logic;
signal dirtybit_mem : line_array;
signal send_block_out: std_logic:= '0';
signal read_var: std_logic;		
signal write_var: std_logic;
signal saved_dirty_block : std_logic_vector(63 downto 0);
signal tag_out : std_logic_vector (6 downto 0);
begin 
tagIndex <= addressIN(11 downto 5);
lineIndex <= addressIN(4 downto 2);
wordIndex <= addressIN (1 downto 0);
send_block_out_mem <= send_block_out;
done_out <= done;
	

 
unit1 : TagMemory port map(tag_enable, clock, reset, 
tagIndex, hit, lineIndex, write_tag, tag_out, read_tag);
unit2 : DataMemory port map(data_enable, clock, reset,
 read_data,write_data, lineIndex, tempDataOut, tempDataIn, wordIndex, 
 write_block, blockReplaced, data_block, send_block_out, data_block_out);

process (clock, reset)

	
begin 
			
	if (reset = '1')then
		write_tag <= '0';
		--data_enable <='1';
		delayReq <= '0';
		replaceStatusOut <='0';
		state <=sReset;
		done <= '0';
		send_block_out <='0';
		dirtybit_mem <= (others =>(others =>'0'));
--		read_var <= MreIn;
--		write_var <= MweIn;
	else
--	if (clock_en = '1') then
	
		if (rising_edge(clock)) then
			tag_enable <='1';
			data_enable <= hit;
			read_tag <= '1';
			write_tag <= '0';
			if (done_write_back = '1') then 
				send_block_out <= '0';
			end if;
			if (clock_en = '1') then
				
				
--				read_data <= MreIn;
--				write_data <= MweIn;
				
				case state is
					when sReset =>
						state_d <= "1111";
						state <= s0;
						data_enable <= '0';
						done <= '0';
						delayReq <= '0';
						replaceStatusOut <='0';
						read_data <= MreIn;
						write_data <= MweIn;
--						read_data <= read_var;
--						write_data <= write_var;
						tag_enable <= '1';
						read_tag <= '1';
						write_tag <= '0';
					when s0 =>-- initialize the tagMemory and desable the data memory;
					
					
					data_enable <='0';
					delayReq <= '0';
					replaceStatusOut <='0';
	
					state_d <= "0000";
					
					done <= '0';
					read_data <= MreIn;
					write_data <= MweIn;
					
--					read_data <= read_var;
--					write_data <= write_var;
					state <= s1;
						
				when s1 => ----check if theres a hit or miss
					state_d <= "0001";

					read_data <= MreIn;
					write_data <=MweIn;
					if (hit ='1') then 
						data_enable <= '1';
						delayReq <= '0';
					   state <= s1b;

					elsif (hit ='0') then  --- if hit = 0 / miss
						if (dirtybit_mem(to_integer(unsigned (lineIndex)), to_integer(unsigned (wordIndex))) = '1')then
								send_block_out <= '1';
--								saved_dirty_block(15 downto 0)<= memory(line_check, 0);
--								saved_dirty_block(31 downto 16) <= memory(line_check, 1);
--								saved_dirty_block(47 downto 32) <= memory(line_check, 2) ;
--								saved_dirty_block(63 downto 48)<= memory(line_check, 3);
						end if;
						
						state <= s1c;
						
					else 
						state <= s1;
					end if;
					
				when s1b => 
						state_d <= "0010";
--						read_data <= MreIn;
--						write_data <= MweIn;

						if ((read_data = '1') and (write_data = '0')) then

								state <= s2;
						elsif ((read_data = '0') and (write_data = '1')) then 

								dirtybit_mem(to_integer(unsigned (lineIndex)), to_integer(unsigned (wordIndex))) <= '1';
								state <= s3;

						end if;
						
				when s1c => 
						state_d <= "0011";
--						read_data <= MreIn;
--						write_data <=MweIn;
--						send_block_out <= '0';
						blockAddressOut(9 downto 3) <= tag_out;
						blockAddressOut(2 downto 0) <= lineIndex;
						addressOUT <= addressIN;
						replaceStatusOut <= '1';
						delayReq <= '1';
						state <= s4;
						
				when s2 => ---send data to cpu
						data_out_cpu <= tempDataOut;
						state <= sReset;----------
--						read_data <= '0';
						done <= '1';
						state_d <= "0100";
				when s3=> --- send data to dataMemory
						tempDataIn <= data_in;
						done <= '1';
--						write_data <='0';
						state <= sReset;------------------
						state_d <= "0101";
				when s4 => ---if block from MainMemory is available
						state_d <= "0110";
--						read_data <= MreIn;
--						write_data <=MweIn;
						--send_block_out <= '0';
						state <= sWait; --- go to state that waits for memory block  to be available;
				when s5 => --enable writing the new tag
					state_d <= "0111";
					replaceStatusOut <= '0';
					write_tag <= '1';
					read_tag <= '0'; 
--					read_data<= '0';
--					write_data<= '0';
					
					state <= s6;

				when s6 => --write the block to the dataMemory
					state_d <= "1000";
					write_block <= '1';
					data_block <= data_block_in;
					state <= s6b;
					--send_block_out <= '0';
				when s6b => -- desable the write_block;
					state_d <= "1001";
					write_block <= '0';
					-------
					dirtybit_mem(to_integer(unsigned (lineIndex)), 0) <= '0';
					dirtybit_mem(to_integer(unsigned (lineIndex)), 1) <= '0';
					dirtybit_mem(to_integer(unsigned (lineIndex)),2) <= '0';
					dirtybit_mem(to_integer(unsigned (lineIndex)), 3) <= '0';
					--------
					state <= s7;
					
				when s7 => -- check if block was replaced;
					state_d <= "1010";
--					if (blockReplaced ='1') then 
						
						data_enable <= '1';--enable the dataMemory
						state <= s8;
--						read_data <= read_in;
--						write_data <= write_in;
--					else 
--						state <= s7;
--					end if;
				when s8 => --read or write the new block;
					state_d <= "1011";
						if ((read_data = '1') and (write_data ='0')) then
--								read_data <= '1';
--								write_data <= '0';
								state <= sDelay;
								nextState <= s2;
						elsif ((read_data = '0') and (write_data ='1')) then 
--								write_data <= '1';
--								read_data <= '0';
								state <= sDelay;
								nextState <=s3;
							
						end if;
				when sDelay => 
						state <= nextState;
						state_d <= "1100";
						
				when sWait =>
						state_d <= "1101";
						if (replaceStatusIn = '1') then 
							state <= s5;
						else 
							state<= sWait; --stay in this state if not available
						end if;
				when others =>
				end case;
			else 
				state <= sReset;
				read_data <= '0';
				write_data<= '0';
				done <= '0';
			end if;
		end if;
--		else 
--		state <= sReset;
--		end if;
		end if;
	end process;

--	read_data_d <= read_data;
-- write_data_d <= write_data;
-- write_tag_d <= write_tag;
-- read_tag_d <= read_tag;
-- write_block_d <= write_block;
-- 
---- tempDataIn_d <=	tempDataIn;
---- tempDataOut_d <= tempDataOut;
---- tagIndex_d <= tagIndex;
---- lineIndex_d <= lineIndex;
---- wordIndex_d <= wordIndex;
--
-- hit_d <= hit;
-- send_block_out_d <= send_block_out;
--tag_enable_d <= tag_enable;
-- data_enable_d <= data_enable;
-- blockReplaced_d <=blockReplaced;
end behav;