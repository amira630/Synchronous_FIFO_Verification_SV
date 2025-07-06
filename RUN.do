vlib work
vlog -f src_files.list +define+SIM +cover -covercells
vsim -voptargs=+acc work.top -cover
add wave /top/fifo_if/*
coverage save FIFO_SV.ucdb -onexit -du work.FIFO
vcover report FIFO_SV.ucdb -details -annotate -all -output FIFO_SV_cvr_rpt.txt
run -all