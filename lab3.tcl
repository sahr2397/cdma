set ns [new Simulator]
set nf [open lab3.nam w]
$ns namtrace-all $nf
set tf [open lab3.tr w]
$ns trace-all $tf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

puts "Nodes created..."	
	
$ns make-lan "$n0 $n1 $n2 $n3" 10Mb 10ms LL Queue/DropTail Mac/802_3

puts  "LAN Assembled..."

$ns color 1 "red"
$ns color 2 "blue"

$n0 label "Sorce/TCP0"
$n1 label "Destination/Sink1"

$n2 label "Sorce/TCP2"
$n3 label "Destination/Sink3"

set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1

set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3

$ns connect $tcp0 $sink3
$ns connect $tcp2 $sink1

set file1 [open file1.tr w]
$tcp0 attach $file1
$tcp0 trace cwnd_ 
$tcp0 set maxcwnd_ 10

set file2 [open file2.tr w]
$tcp2 attach $file2
$tcp2 trace cwnd_

$tcp0 set class_ 1
$tcp2 set class_ 2

proc finish {} {

global ns tf nf

$ns flush-trace

exec nam lab3.nam &
close $nf
close $tf
exit 0
}

$ns at 0.1 "$ftp0 start"
$ns at 1.5 "$ftp0 stop"
$ns at 2 "$ftp0 start"
$ns at 3 "$ftp0 stop"
$ns at 0.2 "$ftp2 start"
$ns at 2 "$ftp2 stop"
$ns at 2.5 "$ftp2 start"
$ns at 4 "$ftp2 stop"
$ns at 5 "finish"
$ns run






