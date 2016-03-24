onerror {quit -f}
vlib work
vlog -work work Cache.vo
vlog -work work Cache.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Cache_vlg_vec_tst
vcd file -direction Cache.msim.vcd
vcd add -internal Cache_vlg_vec_tst/*
vcd add -internal Cache_vlg_vec_tst/i1/*
add wave /*
run -all
