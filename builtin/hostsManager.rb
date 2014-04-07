#!/usr/bin/env ruby

#External Libary
require "yaml"


class HostManager

  def initialize
    @plataforms = Array.new
    @verbose = false
    @workingDir = nil
  end

  #Initialize Repository
  def initRepository
    currDir = Dir.pwd
    workdir = getWorkingDir unless nil
    puts workdir
  end


  def setVerbosity(v)
    @verbose = v
  end


  #remove plataform form HOST File
  def remove plataform
  end

  #aply (add|update) a plataform inside hosts file
  def apply plataform

  end

  def persist
    YAML::dump(c)
  end


  #validate working dirs
  #return working dir from hoster
  def getWorkingDir
    currDir = Dir.pwd

    dr = ""
    currDir.split("/").each{ |entry|
      dr = dr+entry+"/"
      #puts dr
      if(File.directory? dr+".hoster")
        @workingDir = dr+".hoster"
      end
    }
    @workingDir
  end



end
