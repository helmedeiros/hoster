#!/usr/bin/ruby
#
# hoster version definition.
#Altering to read from hoster.version

#  Version and help.
def version()
  version  = File.read("hoster.version")
  progname = File.basename('./hoster')
  puts progname + " version " + version
end
