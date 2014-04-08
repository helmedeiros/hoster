#!/usr/bin/env ruby

#global libs
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

#local requires
require 'version.rb'
require 'help.rb'
require 'builtin/struct/host.rb'
require 'builtin/struct/plataform.rb'
require 'builtin/hostsManager.rb'

#require './builtin/defaults.rb'
#require './builtin/handle_options.rb'
#require './builtin/host_actions.rb'
#require './builtin/host_apply.rb'
#require './builtin/paths.rb'

# pl = Plataform.new
# pl.add(Host.new('127.0.0.1', 'local.pense.com.br', pl))
# pl.add(Host.new('127.0.0.1', 'www.teste.com.br', pl))
# puts YAML::dump(pl)
# puts Marshal::dump(pl)
# print pl.toString()



#Main Class that parse commands and
class Commands

  def initialize(args)
    @help = Help.new
    @command = nil
    @options = parse(args)
    @hostManager = HostManager.new
  end

  def showHelp
    @help.list_commands
  end

  #represent if the args passed to Hoster script is blank
  def empty?
    @options[:empty]
  end

  def parse(args)
    options = {}
    options[:empty  ] = args.empty?
    options[:version] = false
    options[:help   ] = false
    options[:init   ] = false
    options[:verbose] = false


    options[:list   ] = false
    options[:add    ] = false
    options[:edit   ] = false
    options[:apply  ] = false


    opt = OptionParser.new do |opts|

      @help.setOpts(opts)

      opts.banner = @help.getUsageString

      opts.separator ""
      opts.separator "Commands:"

      opts.on_tail("-v", "--version", "Display the #{PROGNAME} version") do
        options[:version] = true
      end

       opts.on_tail("-h", "--help", "--usage", "Display the #{PROGNAME} help") do
         options[:help] = true
       end

      #mark to initialize hoster repository
      opts.on("-i","--init", "Create an empty host repository in the current folder.") do
        options[:init] = true
      end

      #mark to initialize hoster repository
      opts.on("--[no]verbose", "Set to show hoster output or not.") do
        options[:verbose] = true
      end


      #mark to initialize hoster repository
      # opts.on("-a IP DOMAIN PLATAFORM","--add IP DOMAIN PLATAFORM", "Add a new HOST to current repository into a specific environment.") do |arg|
      #   p arg
      #   options[:add] = true
      # end

    end

    #start parsin the commands
    begin
      opt.parse!(args)

      #if there is a invalid Option, help should be printed
      rescue OptionParser::InvalidOption
        @help.invalidOption
        showHelp()
      #if there a missing argument, show help
      rescue OptionParser::MissingArgument
        @help.missingArgument
        showHelp()
    end
    #end Parsing
    options
  end

  def run!

    if(@options[:help])
      showHelp()
    end

    if(@options[:version])
      version()
    end

    if(@options[:init])
      @hostManager.setVerbosity(@options[:verbose])
      @hostManager.initRepository()
    end

  end

end
