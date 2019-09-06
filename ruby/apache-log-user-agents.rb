#!/usr/bin/env ruby
# Log parser, prints user agent count
# 54.227.183.252 www.example.com [16/Aug/2013:04:59:07 -0400] "GET /en-us/default.aspx HTTP/1.1" 302 165 "-" "Mozilla/5.0 (Windows NT 5.1; rv:5.0) Gecko/20100101 Firefox/5.0" "-" 10.85.39.233:80 | 0.002 0.002
# Written by Vyacheslav Stetskevych, 2014

counter = Hash.new { |h, k| h[k] = 0 }

ARGF.each do |line|
  user_agent = line.scan(/\"([^\"]*)\"/)[2]
  counter[user_agent] += 1
end

sorted_list = counter.sort_by { |key, value| value }.reverse.first(5)

sorted_list.each do |a|
  puts "#{a[0]} => #{a[1]}"
end

# vim: set ts=2 sw=2 et bg=dark:
