set ns [new Simulator]
set tf [open p6.tr w]
$ns trace-all $tf

set nf [open p6.nam w]
$ns namtrace-all-wireless $nf 1500 1500

set topo [new Topography]
$topo load_flatgrid 1500 1500

set f0 [open out.tr w]
set f1 [open lost.tr w]
set f2 [open delay.tr w]

Mac/802_11 set cdma_code_bw_start_ 0
Mac/802_11 set cdma_code_bw_stop_ 63
Mac/802_11 set cdma_code_init_start_ 64
Mac/802_11 set cdma_code_init_stop_ 127
Mac/802_11 set cdma_code_cqich_start_ 128
Mac/802_11 set cdma_code_cqich_stop_ 225

$ns node-config -adhocRouting AODV \
	-llType LL \
	-ifqType Queue/DropTail/PriQueue \
	-ifqLen 1000 \
	-macType Mac/802_11 \
	-phyType Phy/WirelessPhy \
	-propType Propagation/TwoRayGround \
	-channelType Channel/WirelessChannel \
	-antType Antenna/OmniAntenna \
	-energyModel EnergyModel \
		-initialEnergy 100 \
		-rxPower 0.3 \
		-txPower 0.6 \
	-topoInstance $topo \
	-agentTrace ON \
	-routerTrace ON \
	-macTrace OFF

create-god 25

for {set i 0} {$i < 25 } { incr i } {
	set node_($i) [ $ns node ]
	$node_($i) set X_ [expr rand() * 1500]
	$node_($i) set Y_ [expr rand() * 1000]
	$node_($i) set Z_ 0
}



for { set i 0 } { $i < 25 } { incr i } {
	set xx [expr rand() * 1500]
	set yy [expr rand() * 1000]
	$ns at 0.1 "$node_($i) setdest $xx $yy 5"
}

for { set i 0 } { $i < 25 } { incr i } {
	$ns at 10 "$node_($i) reset"
}

puts "Loading Connection Pattern..."
puts "Loading Scenario file..."

for { set i 0 } { $i < 25 } { incr i } {
	$ns initial_node_pos $node_($i) 55
}


set udp [new Agent/UDP]
$ns attach-agent $node_(4) $udp
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1000
$cbr set interval_ 0.1

$cbr set maxpkts_ 10000
$cbr attach-agent $udp
$ns at 1.00 "$cbr start"

set sink [new Agent/LossMonitor]
$ns attach-agent $node_(20) $sink

$ns connect $udp $sink

$ns color 1 "red"

$udp set class_ 1

set holdtime 0
set holdseq 0
set holdcap 0
puts "Almost there..."
proc record {} {

global sink f0 f1 f2 holdtime holdseq holdcap

set ns_ [Simulator instance]
puts "inside record..."
set time 0.9

set now [$ns_ now]

set nob [$sink set bytes_ ]
set nopl [$sink set nlost_ ]
set nop [$sink set npkts_ ]
set lptime [$sink set lastPktTime_ ]

puts $f0 "$now [expr (($nob + $holdcap)*8)/($time*1000000*2) ]"

puts $f1 "$now [expr $nopl/$time]"

if {$nop>$holdseq} {
	puts $f2 " $now [expr ($lptime-$holdtime)/($nop-$holdseq)]"
} else {
	puts $f2 " $now [expr ($nop-$holdseq)]"
}

$sink set bytes_ 0
$sink set nlost_ 0

set holdtime $lptime
set holdseq $nop
set holdcap $nob
puts "[expr $now+$time]"
$ns_ at [expr $now+$time] "record"
}

proc finish {} {
global ns tf nf f0 f1 f2 
$ns flush-trace
puts "Finishing ..."
exec nam p6.nam &
exec xgraph out.tr -geometry -x Time -y Bytes -t Throughput 800x400 &
exec xgraph lost.tr -geometry -x Time -y No_of_Pkts_Lost -t Packet_Loss 800x400 &
exec xgraph delay.tr -geometry -x Time -y delay -t Delay 800x400 &
close $nf
close $tf
close $f0
close $f1
close $f2

}

$ns at 0 "record"
$ns at 0.01 "$ns trace-annotate \"Network Deployment\""
$ns at 1 "$node_(4) add-mark m blue square"
$ns at 1 "$node_(20) add-mark m magenta square"
$ns at 1 "$node_(4) label Sender"
$ns at 1 "$node_(20) label Receiver"

$ns at 10 "finish"
$ns run

