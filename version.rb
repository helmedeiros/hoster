#!/usr/bin/ruby
#
# hoster version definition.
#Altering to read from hoster.version

#  Version and help.
def version
  p
  version  = File.read(HOSTER_PATH+"/hoster.version")
  puts PROGNAME + " version " + version
end
