proc Server {channel clientaddr clientport} {
   puts "conn from $clientaddr registered"
   puts $channel [clock format [clock seconds]]
   close $channel
}

socket -server Server 5002
vwait forever
