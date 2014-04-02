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

#include the commands main script
require "commands.rb"

#cmd_define_defaults "sublime" "/private/etc/" "Hosts" "Wi-Fi"
#cmd_handle_options $@;
#cmd_execute_options $@;
