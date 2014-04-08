#!/usr/bin/env ruby


class Plataform

  def initialize( name = "dev" )
    @name = name
    @hosts = Array.new
  end

  def getName()
    return @name
  end

  def add(host)
    @hosts.push(host)
  end

  def rem(host)
    @hosts.delete(host)
  end

  def toString
    block = "##<"+@name+">##\n";
    @hosts.each{|host| block += host.toString() + "\n" }
    block += "##</"+@name+">##\n";
    return block;
  end



end
