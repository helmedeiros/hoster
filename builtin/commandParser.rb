#!/usr/bin/env ruby

#global libs
require 'optparse'
require 'pp'



class SubcommandParser < OptionParser



  def initialize
    super
    @commands = Array.new

  end

  def cmd_on(*cmds, &block)
    puts cmds
    puts '----'
    puts block
    puts '####'
    #define(command, block)
    self
  end

end
