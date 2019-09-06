#!/usr/bin/env ruby
# * Create a list of 1000 random numbers from 1 to 100
# * Count how many times each number in the list appears there
# * Write your own sorting function and print each number with how many times it occurs in the list, sorted descendingly by number of occurrences
# Written by Vyacheslav Stetskevych, 2014

class MyHash < Hash

  # Converts hash to a nested array of [key, value] arrays and sorts it by the second value descendingly
  # Mimics the semantics of Hash.sort in ruby 1.8.7
  def sort_desc
    largest = [0, 0]
    unsortedarray = self.to_a
    sortedarray = []

    while unsortedarray.any?
      unsortedarray.each do |x|
        if x[1] > largest[1]
          largest = x
        end
      end
      unsortedarray.delete largest
      sortedarray << largest
      largest = [0, 0]
    end

    sortedarray
  end

end

numbers = []

TIMES = 1000
LOW = 1
HIGH = 100

TIMES.times do |n|
  numbers << LOW + rand(HIGH)
end

counter = MyHash.new(0)

numbers.each do |n|
 counter[n] += 1 
end

puts "#{TIMES} randomly generated numbers from #{LOW} to #{HIGH} sorted by the number of occurences:"
counter.sort_desc.each do |a|
  print "#{a[0]}=>#{a[1]} "
end
puts

# vim: set ts=2 sw=2 et bg=dark:
