library verilog;
use verilog.vl_types.all;
entity Cache_vlg_sample_tst is
    port(
        address         : in     vl_logic_vector(11 downto 0);
        cache_en        : in     vl_logic;
        clock           : in     vl_logic;
        data_in         : in     vl_logic_vector(15 downto 0);
        Mre             : in     vl_logic;
        Mwe             : in     vl_logic;
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end Cache_vlg_sample_tst;
