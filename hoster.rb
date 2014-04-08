#!/usr/bin/ruby
#
# hoster.rb - An host file controler;
#
# Usage:
#
#     # Edit the default host file
#      hoster.rb -e
#
#     # Edit an specific environment file (localhost -l; development -d; homologation -h; production -p)
#      hoster -p -e

#Add the builtin dir, to include path dir
$:.push File.expand_path(File.dirname(__FILE__) + '/builtin')
#Add the root directory
$:.push File.expand_path(File.dirname(__FILE__))


#CONSTANTS
HOSTER_PATH = File.expand_path(File.dirname(__FILE__))
PROGNAME = File.basename('hoster')

#include the commands main script
require "commands.rb"



class Launcher

  def initialize args
    @cmds = Commands.new(args)
  end

  def run!
    #empty, show help
    if @cmds.empty?
      @cmds.showHelp()
    else
      #run the process
      @cmds.run!
    end
  end

end

Launcher.new(ARGV).run!


#cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
#cmd_handle_options $@;
#cmd_execute_options $@;
