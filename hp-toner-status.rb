require 'snmp'
require 'rest-client'

printers = {:P1 => 'IP1', :P2 => 'IP2', :P3 => 'IP3', :P4 => 'IP4'}
# Black, cyan, magenta, yellow
toners = [0,0,0,0]
colors = ["Black", "Cyan", "Magenta", "Yellow"]

shortmsg = ""

printers.each do |name,ip|
begin
	SNMP::Manager.open(:host => ip) do |manager|
	    response = manager.get(['SNMPv2-SMI::mib-2.43.11.1.1.9.1.1',
	    						'SNMPv2-SMI::mib-2.43.11.1.1.9.1.2',
	    						'SNMPv2-SMI::mib-2.43.11.1.1.9.1.3',
                                'SNMPv2-SMI::mib-2.43.11.1.1.9.1.4'])
        response.each_varbind.each_with_index do |varbind, index|
        	if varbind.value.to_i.between?(10,20)
        		toners[index] += 1
        		shortmsg = shortmsg + name.to_s + " needs " + colors[index] + "\n"
        	end
          	if varbind.value.to_i.between?(0,10)
        		toners[index] += 1
        		shortmsg = shortmsg + name.to_s + " URGENTLY needs " + colors[index] + "\n"
        	end
        end

	end
rescue => ex
end
end

if toners[0] == 0 and toners[1] == 0 and toners[2] and toners[3] == 0
	message = "No toners needed"
else
	message = "Hi, this is your HP printer bot checking in.

Please order:
-------------------
#{toners[0]} | Black
#{toners[1]} | Cyan
#{toners[2]} | Magenta
#{toners[3]} | Yellow

#{shortmsg}"
end

RestClient.post "https://api:key-XXXXX@api.mailgun.net/v2/domain.com/messages",
:from => "Full Name <name@domain.com>",
:to => "rcpt@domain.com",
:subject => "Printer Toner Information",
:text => message
