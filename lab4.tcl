set ns [new Simulator]

set topo [new Topography]
$topo load_flatgrid 1500 1500

set tf [open lab4.tr w]
$ns trace-all $tf

set nf [open lab4.nam w]
$ns namtrace-all-wireless $nf 1500 1500

$ns node-config -adhocRouting DSDV \
	-llType LL \
	-ifqType Queue/DropTail \
	-ifqLen 50 \
	-macType Mac/802_11 \
	-phyType Phy/WirelessPhy \
	-propType Propagation/TwoRayGround \
	-channelType Channel/WirelessChannel \
	-antType Antenna/OmniAntenna \
	-topoInstance $topo \
	-agentTrace ON\
	-routerTrace ON

create-god 3

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$ns color 1 "red"
$ns color 2 "blue"

$n0 label "TCP0"
$n1 label "Sink1/TCP1"
$n2 label "Sink2"


$n0 set X_ 50
$n0 set Y_ 50
$n0 set Z_ 0

$n1 set X_ 100
$n1 set Y_ 100
$n1 set Z_ 0

$n2 set X_ 600
$n2 set Y_ 600
$n2 set Z_ 0

$ns at 0.1 "$n0 setdest 70 70 15"
$ns at 0.1 "$n1 setdest 100 100 25"
$ns at 0.1 "$n2 setdest 600 600 25"

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1

set sink2 [new Agent/TCPSink]
$ns attach-agent $n2 $sink2

$ns connect $tcp0 $sink1
$ns connect $tcp1 $sink2

$tcp0 set class_ 1
$tcp1 set class_ 2

proc finish {} {

global ns tf nf

$ns flush-trace

exec nam lab4.nam &
close $nf
close $tf
exit 0
}

$ns at 0.5 "$ftp0 start"
$ns at 0.5 "$ftp1 start"
$ns at 100 "$n1 setdest 550 550 25"
$ns at 190 "$n1 setdest 75 75 25"
$ns at 200 "finish"
$ns run




