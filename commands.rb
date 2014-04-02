#!/usr/bin/ruby

require 'version.rb'
require 'help.rb'
#require './builtin/defaults.rb'
#require './builtin/handle_options.rb'
#require './builtin/host_actions.rb'
#require './builtin/host_apply.rb'
#require './builtin/paths.rb'

class Launcher

  def initialize app_map
    #@app_map = app_map
  end

  def initialize
    help = help.new
    #@app_map = app_map
  end

end

launcher = Launcher.new
