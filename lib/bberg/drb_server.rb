require 'drb'
require 'socket'

require 'bberg'

hostname = Socket.gethostbyname(Socket.gethostname).first
port = ARGV.size == 1 ? ARGV.shift : 9000

uri = "druby://#{hostname}:#{port}"

puts "Starting server using URI = '#{uri}'"

DRb.start_service uri, Bberg::Client.new

puts "Ready to accept requests!"

DRb.thread.join
