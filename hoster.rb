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

#Add the builtin dir
$:.push File.expand_path(File.dirname(__FILE__) + '/builtin')
#Add the root directory
$:.push File.expand_path(File.dirname(__FILE__))

PROGNAME = File.basename('hoster')

#include the commands main script
require "commands.rb"


class Launcher

  def initialize args
    cmds = Commands.new(args)

    #empty, show help
    if args.empty?
      cmds.showHelp()
    else
      #process input args

    end

  end


end

launcher = Launcher.new(ARGV)


#cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
#cmd_handle_options $@;
#cmd_execute_options $@;
