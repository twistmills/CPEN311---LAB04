vlog -work work shared_access_simulation.vwf.vt
vsim -novopt -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.shared_s_access_vlg_vec_tst -voptargs="+acc"
add wave /*
run -all
