#!/usr/bin/env ruby

#External Libary
require "yaml"


class HostManager


  private
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

  def validateWorkingDir
    v = false

    return v
  end

  public
  def initialize
    @plataforms = Array.new
    @verbose = false
    @workingDir = nil
  end


  #Initialize Repository
  def initRepository
    currDir = Dir.pwd
    workdir = getWorkingDir unless nil
    if(workdir != nil)
      puts ".#{PROGNAME} is already initialized and located at #{workdir}"
    else
      #.hoster not located, so initialize the repository
      if(@verbose)
        puts ".Initializing #{PROGNAME} repository"
      end
      hDir = currDir+"/.hoster"
      Dir.mkdir(hDir)
      File.open(hDir+"/Hosts", "w"){ |f|
          f.write("#Auto-generated file, do not manualy alter.");
      }
      puts "Initialized empty Hosts repository in #{currDir}"
      File.open(hDir+"/data.host", "w"){ |f| }
      if(@verbose)
        puts "Initialized empty Data Hosts DB in #{currDir}"
        puts ".Done"
      end
    end
    #puts workdir
  end

  #controls the verbosity from Hoster
  def setVerbosity(v)
    @verbose = v
  end

  #load Data into memory
  def loadData!
    if(!validateWorkingDir)
      return false
    end
    @plataforms = YAML::load(File.open(getWorkingDir+'/.hoster/data.host', 'r'))
    return true
  end

  #persist data from memory
  def persistData!
    File.open(getWorkingDir+'/.hoster/data.host', 'w') do |f|
      YAML::dump(@plataforms)
    end
  end

  #Methods from Apply, Remove, Add


  #remove plataform form HOST File
  def remove plataform
  end

  #aply (add|update) a plataform inside hosts file
  def apply plataform

  end

  def add(host, ip, plataform)

  end





end
