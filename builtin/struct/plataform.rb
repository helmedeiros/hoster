#!/usr/bin/env ruby


class Plataform

  private
  def getExpression
    /##<#{@project}(.)*>##(.|\n)*##<\/#{@project}(.)*>##/
  end


  public
  def initialize( name = "dev", project = 'no-name' )
    @name = name
    @hosts = Hash.new
    @project = project
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

  def edit(host)
    if(@hosts.keys.include? host.getDomain)
      puts "#{host.getDomain} already exists inside the plataform #{host.getPlataform.getName}, updating registry"
    end
    @hosts[host.getDomain] = host
    return true
  end

  #remove by key
  def rem(host)
    @hosts.delete(host)
  end

  def getHosts
    @hosts
  end

  def toString
    block = "##<"+@project+'-'+@name+">##\n";
    @hosts.each{|key, host| block += host.toString() + "\n" }
    block += "##</"+@project+'-'+@name+">##\n";
    return block;
  end




  def apply!(hostFile)
    text = File.read(hostFile)
    if(text.index(/##<#{@project}(.)*>##/) == nil)
      hsText = text + toString
    else
      hsText = text.gsub(getExpression, toString)
    end
    File.open(hostFile, "w") {|file| file.puts hsText}
  end


  def clean!(hostFile)
    text = File.read(hostFile)
    hsText = text.gsub(getExpression, '')
    File.open(hostFile, "w") {|file| file.puts hsText}
  end


end
