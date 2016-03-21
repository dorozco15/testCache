library verilog;
use verilog.vl_types.all;
entity CacheController_vlg_sample_tst is
    port(
        address_block_in: in     vl_logic_vector(11 downto 0);
        addressIN       : in     vl_logic_vector(11 downto 0);
        clock           : in     vl_logic;
        clock_en        : in     vl_logic;
        data_block_in   : in     vl_logic_vector(63 downto 0);
        data_in         : in     vl_logic_vector(15 downto 0);
        MreIn           : in     vl_logic;
        MweIn           : in     vl_logic;
        replaceStatusIn : in     vl_logic;
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end CacheController_vlg_sample_tst;
