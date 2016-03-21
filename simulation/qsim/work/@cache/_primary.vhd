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
        done_check_d    : out    vl_logic
    );
end Cache;
