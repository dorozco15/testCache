library verilog;
use verilog.vl_types.all;
entity Cache is
    port(
        cache_en        : in     vl_logic;
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        Mre             : in     vl_logic;
        Mwe             : in     vl_logic;
        address         : in     vl_logic_vector(11 downto 0);
        data_in         : in     vl_logic_vector(15 downto 0);
        data_out        : out    vl_logic_vector(15 downto 0);
        delayReq        : out    vl_logic;
        state_con_d     : out    vl_logic_vector(3 downto 0);
        state_d         : out    vl_logic_vector(3 downto 0);
        done_cache      : out    vl_logic;
        done_controller_d: out    vl_logic;
        controller_en_d : out    vl_logic;
        done_check_d    : out    vl_logic;
        replaceStatusOut_d: out    vl_logic;
        replaceStatusIn_d: out    vl_logic;
        mem_block_out_d : out    vl_logic_vector(63 downto 0);
        slowClock_d     : out    vl_logic;
        write_block_d   : out    vl_logic;
        cont_out_block  : out    vl_logic_vector(63 downto 0);
        write_back_mem_d: out    vl_logic;
        done_write_back_d: out    vl_logic;
        write_address_mem_d: out    vl_logic_vector(9 downto 0)
    );
end Cache;
