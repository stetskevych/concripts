#!/usr/bin/env ruby

# Sorts a list of IP addresses in files with random comments

require "resolv"

FILES = ['iplist1.txt', 'iplist2.txt']
IP_PREFIX = /212|217/

@iplist ||= []

FILES.each do |file|
  File.open(file).each_line do |line|
    ip, junk = line.split
    @iplist << ip if ip =~ Resolv::IPv4::Regex && ip =~ IP_PREFIX
  end
end

puts @iplist.uniq!.sort!
