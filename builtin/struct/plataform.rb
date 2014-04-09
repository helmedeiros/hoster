#!/usr/bin/env ruby


class Plataform

  def initialize( name = "dev" )
    @name = name
    @hosts = Hash.new
  end

  def getName()
    return @name
  end

  #DO NOT LET MORE THAN 1 DOMAIN INSTANCE PER PLATAFORM
  def add(host)
    if(@hosts.keys.include? host.getDomain)
      puts "#{host.getDomain} already exists inside the plataform #{host.getPlataform.getName}"
      return false
    end
    @hosts[host.getDomain] = host
    return true
  end

  def rem(host)
    @hosts.delete(host)
  end

  def getHosts
    @hosts
  end

  def toString
    block = "##<"+@name+">##\n";
    @hosts.each{|key, host| block += host.toString() + "\n" }
    block += "##</"+@name+">##\n";
    return block;
  end



end
