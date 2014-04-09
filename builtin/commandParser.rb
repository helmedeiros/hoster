#!/usr/bin/env ruby

#global libs
require 'optparse'
require 'pp'



class SubcommandParser < OptionParser


  def initialize
    @subcommands = Hash.new
    @subcommandsBlock = Hash.new
    super
  end

  def cmd_on(*cmds, &block)
    @subcommands[cmds[0]] = cmds
    @subcommandsBlock[cmds[0]] = block
    self
  end

  #override
  def parse!(*args)
    if(@subcommands.keys.include? args[0][0])
      @subcommandsBlock[args[0][0]].call(self)
    end
    super
  end

end
