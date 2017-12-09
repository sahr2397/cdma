set ns [new Simulator]
set tf [open out.tr w]
$ns trace-all $tf
set nf [open out.nam w]
$ns namtrace-all-wireless $nf 1500 1500

set f0 [open out02.tr w]
set f1 [open lost02.tr w]
set f2 [open delay02.tr w]


set topo [new Topography]
$topo load_flatgrid 1500 1500
	
create-god 10
$ns color 0 red
$ns node-config -adhocRouting AODV \
                 -llType LL \
                 -macType Mac/802_11 \
                 -ifqType Queue/DropTail/PriQueue \
                 -ifqLen 1000 \
                 -antType Antenna/OmniAntenna \
                 -propType Propagation/TwoRayGround \
                 -phyType Phy/WirelessPhy \
                 -channelType Channel/WirelessChannel \
	       	 -energyModel EnergyModel \
		 -initialEnergy 100 \
		 -rxPower 0.3 \
		 -txPower 0.6 \
		 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF 


for {set i 0} {$i < 10 } {incr i} {
	set node_($i) [$ns node]	
			
}


 set X1(0) 0 
 set Y1(0) 0
 set X1(1) 100
 set Y1(1) 100
 set X1(2) -18.1268
 set Y1(2) 300.612
 set X1(3) 723.89
 set Y1(3) 343.533
 set X1(4) 122.34
 set Y1(4) 311.755
 set X1(5) 373.498
 set Y1(5) 472.206
 set X1(6) 548.549 
 set Y1(6) 361.062
 set X1(7) 389.995
 set Y1(7) 381.178
 set X1(8) 494.798
 set Y1(8) 477.771
 set X1(9) 275.01
 set Y1(9) 381.99


for {set i 0} {$i < 10 } {incr i} {
	$node_($i) set X_ $X1($i)
        $node_($i) set Y_ $Y1($i)
        $node_($i) set Z_ 0.0
	

}

 for {set i 0} {$i < 10 } {incr i} {
    $ns at 5.0 "$node_($i) reset";
}

#set m 0
#puts "|    Node      |  One hop neighbour    |"
#for {set i 0} {$i < 10 } {incr i} {
#set k 0
#for {set j 0} {$j < 10 } {incr j} {
#set a [ expr $X1($j)-$X1($i)]
#set b [ expr $a*$a]
#set c [ expr $Y1($j)-$Y1($i)]
#set d [ expr $c*$c]
#set e [ expr $b+$d]
#set f 0.5
#set g [expr pow($e,$f)]
#if {$g <= 200 && $i != $j} {
#puts "|    node($i)     |     node($j)       |"
#set nei($m) $j    
#set k [expr $k+1]  
#set m [ expr $m+1]                               
#} 
#}
#puts "----------------------------------------"
#}

set udp0 [new Agent/UDP]
$ns attach-agent $node_(2) $udp0
set sink [new Agent/LossMonitor]
$ns attach-agent $node_(3) $sink
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.1
$cbr0 set maxpkts_ 1000
$cbr0 attach-agent $udp0
$ns connect $udp0 $sink
$ns at 1.00 "$cbr0 start"

set holdtime 0
set holdseq 0
set holdrate1 0

proc record {} {
global sink  f0 f1 f2 holdtime holdseq holdrate1 

set ns [Simulator instance]
set time 0.9 ;#Set Sampling Time to 0.9 Sec

set bw0 [$sink set bytes_]
set bw1 [$sink set nlost_]

set bw2 [$sink set lastPktTime_]
set bw3 [$sink set npkts_]

set now [$ns now]
        # Record Bit Rate in Trace Files
        puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time*1000000)]"
        # Record Packet Loss Rate in File
        puts $f1 "$now [expr $bw1/$time]"

if { $bw3 > $holdseq } {
                puts $f2 "$now [expr ($bw2 - $holdtime)/($bw3 - $holdseq)]"
        } else {
                puts $f2 "$now [expr ($bw3 - $holdseq)]"
        }

$sink set bytes_ 0
$sink set nlost_ 0

set holdtime $bw2
set holdseq $bw3
 
set  holdrate1 $bw0
    $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec
}
 
# Start Recording at Time 0
$ns at 0.0 "record"

source link5.tcl

proc stop {} {
        global ns tf f0 f1 f2 
 
        # Close Trace Files
        close $f0 
        close $f1
        close $f2
        exec nam out.nam &
 # Plot Recorded Statistics

        exec xgraph out02.tr -geometry -x TIME -y thr -t Throughput 800x400 &
        exec xgraph lost02.tr  -geometry -x TIME -y loss -t Packet_loss 800x400 &
        exec xgraph delay02.tr  -geometry -x TIME -y delay -t End-to-End-Delay 800x400 &

$ns flush-trace
       
}
 
$ns at 5.0 "stop"
$ns at  5.0002 "puts \"NS EXITING...\" ; $ns halt"
$ns run
