#!/usr/bin/env ruby

require 'version.rb'
require 'help.rb'
#require './builtin/defaults.rb'
#require './builtin/handle_options.rb'
#require './builtin/host_actions.rb'
#require './builtin/host_apply.rb'
#require './builtin/paths.rb'

class Commands

  def showHelp
    help = Help.new
    help.list_commands
  end

  def parseArgs
    
  end

end
