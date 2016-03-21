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
		----debug lines
		 read_data_d : out std_logic; 
 write_data_d : out std_logic;
 write_tag_d :  out std_logic;
 read_tag_d : out std_logic;
 write_block_d:  out std_logic;
-- data_block_d: out std_logic_vector(63 downto 0);
 tempDataIn_d : out std_logic_vector(15 downto 0);
 tempDataOut_d : out std_logic_vector(15 downto 0);
 tagIndex_d: out std_logic_vector(6 downto 0);
 lineIndex_d: out std_logic_vector(2 downto 0);
 wordIndex_d: out std_logic_vector(1 downto 0);
 hit_d: out STD_LOGIC; 
 --tagWrote_d: out std_logic;
tag_enable_d: out std_logic;
 data_enable_d: out std_logic;
 blockReplaced_d: out std_logic;
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
type state_type is (sIdle,sReset, Sdelay,s0,s1, s1b, s1c,s2,s3,s4, s5, s6,s6b,s7,s8);
signal state: state_type;	
signal done: std_logic;
  signal nextState: state_type;
  signal delayNum : integer := 2;
  signal useDelay : std_logic; 
--signal replaceStatus : std_logic;
signal read_in : std_logic;
signal write_in: std_logic;


begin 
tagIndex <= addressIN(11 downto 5);
lineIndex <= addressIN(4 downto 2);
wordIndex <= addressIN (1 downto 0);

done_out <= done;
--write_tag <= '0';
--write_block<='0';
----debug assigns
write_data <= MweIn;
read_data <= MreIn;		

 
unit1 : TagMemory port map(tag_enable, clock, reset, 
tagIndex, hit, lineIndex, write_tag, read_tag);
unit2 : DataMemory port map(data_enable, clock, reset,
 read_data,write_data, lineIndex, tempDataOut, tempDataIn, wordIndex, 
 write_block, blockReplaced, data_block);

process (clock, reset)

	
begin 
			
	if (reset = '1')then
		write_tag <= '0';
		--data_enable <='1';
		delayReq <= '0';
		replaceStatusOut <='0';
		state <=sReset;
		done <= '0';
--		read_data <='0';
--		write_data <= '0';
	else
--	if (clock_en = '1') then
	
		if (rising_edge(clock)) then
			if (clock_en = '1') then
				data_enable <= hit;
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
--						write_data <= MweIn;
--						read_data <= MreIn;
					when s0 =>-- initialize the tagMemory and desable the data memory;
					tag_enable <= '1';
					read_tag <= '1';
					write_tag <= '0';
					
					data_enable <='0';
					delayReq <= '0';
					replaceStatusOut <='0';
	
					state_d <= "0000";
					
					done <= '0';
					state <= s1;
						
				when s1 => ----check if theres a hit or miss
					state_d <= "0001";
					if (hit ='1') then 
						data_enable <= '1';
						delayReq <= '0';
					   state <= s1b;
						
					elsif (hit ='0') then  --- if hit = 0 / miss
--						addressOUT <= addressIN;
--						replaceStatusOut <= '1';
--						delayReq <= '1';
--						if ((MreIn = '1') and (MweIn ='0')) then

--								read_data <= '1'; 
--								write_data<= '0';
--						else	
--							if ((MweIn = '1') and (MreIn ='0')) then 
--								read_data <= '0'; 
--								write_data<= '1';
--							end if;
							
--						end if;
						state <= s1c;
					else 
						state <= s1;
					end if;
					
				when s1b => 
						state_d <= "0010";
						if ((read_data = '1') and (write_data ='0')) then
--								read_data <= '1';
--								write_data <= '0';
								state <= s2;
						else	
							if ((write_data = '1') and (read_data ='0')) then 
--								write_data <= '1';
--								read_data <= '0';
								state <= s3;
							end if;
							
						end if;
				when s1c => 
						addressOUT <= addressIN;
						replaceStatusOut <= '1';
						delayReq <= '1';
						state <= s4;
						state_d <= "0011";
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
						
						if (replaceStatusIn = '1') then 
							state <= s5;
						else 
							state<= s4; --stay in this state if not available
						end if;
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
				when s6b => -- desable the write_block;
					state_d <= "1001";
					write_block <= '0';
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
								state <= s2;
					else	
						if ((write_data = '1') and (read_data ='0')) then 
--								write_data <= '1';
--								read_data <= '0';
								state <= s3;
						end if;
					end if;
				when others =>
			end case;
		else 
			state <= sReset;
		end if;
			end if;
--		else 
--		state <= sReset;
--		end if;
		end if;
	end process;

	read_data_d <= read_data;
 write_data_d <= write_data;
 write_tag_d <= write_tag;
 read_tag_d <= read_tag;
 write_block_d <= write_block;
 --data_block_d 	<= data_block;
 tempDataIn_d <=	tempDataIn;
 tempDataOut_d <= tempDataOut;
 tagIndex_d <= tagIndex;
 lineIndex_d <= lineIndex;
 wordIndex_d <= wordIndex;
 hit_d <= hit;
 --tagWrote_d <= tagWrote;
tag_enable_d <= tag_enable;
 data_enable_d <= data_enable;
 blockReplaced_d <=blockReplaced;
end behav;