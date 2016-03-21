library verilog;
use verilog.vl_types.all;
entity CacheController_vlg_check_tst is
    port(
        addressOUT      : in     vl_logic_vector(11 downto 0);
        data_out_cpu    : in     vl_logic_vector(15 downto 0);
        delayReq        : in     vl_logic;
        done_out        : in     vl_logic;
        hit_out         : in     vl_logic;
        replaceStatusOut: in     vl_logic;
        state_d         : in     vl_logic_vector(3 downto 0);
        sampler_rx      : in     vl_logic
    );
end CacheController_vlg_check_tst;
