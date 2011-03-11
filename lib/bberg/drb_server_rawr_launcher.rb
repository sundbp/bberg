# find the base of the current jar file
base = __FILE__.split('!').first + '!'

# first setup LOAD_PATH

# add our gem's lib dir
$LOAD_PATH << File.join(base, 'lib')

# look through all bundled gems
Dir[File.join(base, 'vendor/bundle') + '/**/lib'].each do |dir|
  $LOAD_PATH << dir
end

# then launch server
require 'bberg/drb_server'