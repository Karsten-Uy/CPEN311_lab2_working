onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DUT /tb_rtl_circle/DUT/clk
add wave -noupdate -expand -group DUT /tb_rtl_circle/DUT/rst_n
add wave -noupdate -expand -group DUT -radix unsigned /tb_rtl_circle/DUT/DP/centre_x
add wave -noupdate -expand -group DUT -radix unsigned -childformat {{{/tb_rtl_circle/DUT/DP/centre_y[7]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[6]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[5]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[4]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[3]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[2]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[1]} -radix unsigned} {{/tb_rtl_circle/DUT/DP/centre_y[0]} -radix unsigned}} -subitemconfig {{/tb_rtl_circle/DUT/DP/centre_y[7]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[6]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[5]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[4]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[3]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[2]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[1]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/DP/centre_y[0]} {-height 15 -radix unsigned}} /tb_rtl_circle/DUT/DP/centre_y
add wave -noupdate -expand -group DUT /tb_rtl_circle/DUT/DP/radius
add wave -noupdate -expand -group DUT -radix unsigned /tb_rtl_circle/DUT/vga_x
add wave -noupdate -expand -group DUT -radix unsigned -childformat {{{/tb_rtl_circle/DUT/vga_y[6]} -radix unsigned} {{/tb_rtl_circle/DUT/vga_y[5]} -radix unsigned} {{/tb_rtl_circle/DUT/vga_y[4]} -radix unsigned} {{/tb_rtl_circle/DUT/vga_y[3]} -radix unsigned} {{/tb_rtl_circle/DUT/vga_y[2]} -radix unsigned} {{/tb_rtl_circle/DUT/vga_y[1]} -radix unsigned} {{/tb_rtl_circle/DUT/vga_y[0]} -radix unsigned}} -subitemconfig {{/tb_rtl_circle/DUT/vga_y[6]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/vga_y[5]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/vga_y[4]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/vga_y[3]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/vga_y[2]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/vga_y[1]} {-height 15 -radix unsigned} {/tb_rtl_circle/DUT/vga_y[0]} {-height 15 -radix unsigned}} /tb_rtl_circle/DUT/vga_y
add wave -noupdate -expand -group DUT /tb_rtl_circle/DUT/CIRCLE_FSM/state
add wave -noupdate -expand -group DUT -radix decimal /tb_rtl_circle/DUT/DP/offset_x
add wave -noupdate -expand -group DUT -radix decimal /tb_rtl_circle/DUT/DP/offset_y
add wave -noupdate -expand -group DUT -radix decimal -childformat {{{/tb_rtl_circle/DUT/DP/crit[8]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[7]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[6]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[5]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[4]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[3]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[2]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[1]} -radix decimal} {{/tb_rtl_circle/DUT/DP/crit[0]} -radix decimal}} -subitemconfig {{/tb_rtl_circle/DUT/DP/crit[8]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[7]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[6]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[5]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[4]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[3]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[2]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[1]} {-height 15 -radix decimal} {/tb_rtl_circle/DUT/DP/crit[0]} {-height 15 -radix decimal}} /tb_rtl_circle/DUT/DP/crit
add wave -noupdate -expand -group DUT /tb_rtl_circle/DUT/vga_colour
add wave -noupdate /tb_rtl_circle/DUT/vga_plot
add wave -noupdate -expand -group REF -radix unsigned /tb_rtl_circle/circle_monitor/ref_model/vif/vga_x
add wave -noupdate -expand -group REF -radix unsigned /tb_rtl_circle/circle_monitor/ref_model/vif/vga_y
add wave -noupdate /tb_rtl_circle/circle_monitor/ref_model/vif/ref_state
add wave -noupdate /tb_rtl_circle/circle_monitor/Mismatch
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct1_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct1_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct2_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct2_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct3_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct3_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct4_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct4_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct5_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct5_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct6_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct6_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct7_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct7_y
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct8_x
add wave -noupdate -group {octant ALU} /tb_rtl_circle/DUT/DP/oct8_y
add wave -noupdate /tb_rtl_circle/dut_if/start
add wave -noupdate /tb_rtl_circle/circle_monitor/ref_model/run/start_trig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {761424 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 10
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {756152 ns} {766697 ns}
