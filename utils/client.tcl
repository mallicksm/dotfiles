set server 10.111.13.2
set sockChan [socket $server 6002]
gets $sockChan line
close $sockChan
puts "The time on $server is $line"
