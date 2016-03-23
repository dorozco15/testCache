library verilog;
use verilog.vl_types.all;
entity Cache_vlg_check_tst is
    port(
        cont_out_block  : in     vl_logic_vector(63 downto 0);
        controller_en_d : in     vl_logic;
        data_out        : in     vl_logic_vector(15 downto 0);
        delayReq        : in     vl_logic;
        done_cache      : in     vl_logic;
        done_check_d    : in     vl_logic;
        done_controller_d: in     vl_logic;
        done_write_back_d: in     vl_logic;
        mem_block_out_d : in     vl_logic_vector(63 downto 0);
        replaceStatusIn_d: in     vl_logic;
        replaceStatusOut_d: in     vl_logic;
        slowClock_d     : in     vl_logic;
        state_con_d     : in     vl_logic_vector(3 downto 0);
        state_d         : in     vl_logic_vector(3 downto 0);
        write_address_mem_d: in     vl_logic_vector(9 downto 0);
        write_back_mem_d: in     vl_logic;
        write_block_d   : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end Cache_vlg_check_tst;
