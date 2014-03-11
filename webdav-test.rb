#!/usr/bin/env ruby

# Test webdav access

require 'securerandom'
require 'tmpdir'
require 'rubygems'
# gem install net_dav
require 'net/dav'

URL = "http://ec2-54-195-253-221.eu-west-1.compute.amazonaws.com:4502/crx/repository/crx.default"
USER = "admin"
PASS = "admin"
PATH = '/content/dam/webdav-test'
ROUNDS = 10

class Net::DAV
  def list_remote_contents(path, recursive=true)
    puts ":: Listing remote contents"
    self.find(path, :recursive => recursive) do |item|
      puts "#{item.uri} is size #{item.size}"
    end
  end
end

dav = Net::DAV.new(URL, :curl => false)
dav.verify_server = false
dav.credentials(USER, PASS)

puts ":: Recreating webdav-test directory"
dav.exists? PATH and dav.delete PATH
dav.mkdir PATH
dav.cd PATH

puts ":: Generating and uploading files"
Dir.mktmpdir do |dir|
  ROUNDS.times do |round|
    filename = "#{dir}/file#{round}"
    puts filename
    file = File.open(filename, "w+")
    file.write(SecureRandom.hex)

    # BUG: Currently returns an exception
    dav.put(PATH, file, File.size(filename))

    file.close
  end
end

dav.list_remote_contents PATH
