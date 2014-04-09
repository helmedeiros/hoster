#!/usr/bin/env ruby

require "builtin/struct/plataform.rb"

#Representaion of the HOST entry
class Host


  def initialize( ip = "127.0.0.1", domain = "default.local", plataform = Plataform.new("dev") )
    @ip = ip
    @domain = domain
    @plataform = plataform
  end

  def getIp
    @ip
  end

  def getDomain
    @domain
  end

  def getPlataform
    @plataform
  end

  def toString
    return "\t"+@ip+"\t"+@domain+"  # --"+@plataform.getName()
  end

end
