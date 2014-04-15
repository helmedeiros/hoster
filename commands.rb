#!/usr/bin/env ruby

#global libs
require 'optparse'
#require 'optparse/subcommand'
require 'pp'

#local requires
require 'version.rb'
require 'help.rb'
require 'builtin/struct/host.rb'
require 'builtin/struct/plataform.rb'
require 'builtin/hostsManager.rb'
require 'builtin/commandParser.rb'

#require './builtin/defaults.rb'
#require './builtin/handle_options.rb'
#require './builtin/host_actions.rb'
#require './builtin/host_apply.rb'
#require './builtin/paths.rb'


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

    options[:add     ] = false
    options[:edit    ] = false
    options[:ip      ] = '127.0.0.1'
    options[:host    ] = nil
    options[:plat    ] = "dev"

    options[:remove  ] = false

    options[:list   ] = false

    options[:apply  ] = false
    options[:clean  ] = false

    #subcommands
    #https://gist.github.com/rkumar/445735
    #http://stackoverflow.com/questions/2732894/using-rubys-optionparser-to-parse-sub-commands
    #https://github.com/bjeanes/optparse-subcommand

    opt = SubcommandParser.new do |opts|

      @help.setOpts(opts)

      opts.banner = @help.getUsageString

      opts.separator ""
      opts.separator "Commands:"

      #subcommand INIT
      opts.cmd_on("init", "Create an empty host repository in the current folder.") do |cmd|
        options[:init] = true
      end

      #sucommand ADD
      opts.cmd_on("add", "Add a new HOST to current repository into a specific environment.") do |cmd|
        options[:add] = true

        opts.separator ""
        opts.separator "Add Options:"

        opts.on("--ip [IP]", String, "set the IP address, default is 127.0.0.1") do |op|
          options[:ip] = op
        end
        opts.on("--domain HOST", String, "set the HOST address") do |op|
          options[:host] = op
        end

        opts.on("--pl [PLATAFORM]", String, "set the PLATAFORM name, default dev") do |op|
          options[:plat] = op
        end

      end

      #sucommand EDIT
      opts.cmd_on("edit", "Edit an HOST inside the current repository into a specific environment.") do |cmd|
        options[:edit] = true

        opts.separator ""
        opts.separator "Edit Options:"

        opts.on("--new-ip [IP]", String, "set the IP address, default is 127.0.0.1") do |op|
          options[:ip] = op
        end
        opts.on("--domain HOST", String, "set the HOST address") do |op|
          options[:host] = op
        end

        opts.on("--pl [PLATAFORM]", String, "set the PLATAFORM name, default dev") do |op|
          options[:plat] = op
        end

      end

      #subcommand REMOVE
      opts.cmd_on("remove", "Remove the host entry from the plataform.") do |cmd|
        options[:remove] = true

        opts.separator ""
        opts.separator "Remove Options:"

        opts.on("--domain HOST", String, "set the HOST address") do |op|
          options[:host] = op
        end

        opts.on("--pl [PLATAFORM]", String, "set the PLATAFORM name, default dev") do |op|
          options[:plat] = op
        end

      end

      #subcommand LIST
      opts.cmd_on("list", "List all hosts for a specific project.") do |cmd|
        options[:list] = true
      end

      #subcommand LIST
      opts.cmd_on("apply", "Apply the plataform to HOSTs file.") do |cmd|
        options[:apply] = true

        opts.separator ""
        opts.separator "Apply Options:"

        opts.on("--pl [PLATAFORM]", Array, "set the PLATAFORM name, default dev") do |op|
          options[:plat] = op
        end

      end

      #subcommand LIST
      opts.cmd_on("clean", "Remove the plataform from HOSTs file.") do |cmd|
        options[:clean] = true

        opts.separator ""
        opts.separator "Clean Options:"

        opts.on("--pl [PLATAFORM]", Array, "set the PLATAFORM name, default dev") do |op|
          options[:plat] = op
        end

      end


      opts.separator ""
      opts.separator "Global Arguments:"

      opts.on_tail("-v", "--version", "Display the #{PROGNAME} version") do
        options[:version] = true
      end

       opts.on_tail("-h", "--help", "--usage", "Display the #{PROGNAME} help") do
         options[:help] = true
       end

      #mark to show more messages
      opts.on_tail("--[no-]verbose", "Set to show hoster output or not.") do
        options[:verbose] = true
      end
    end


    #start parsin the commands
    begin
      opt.parse!(args)

      if(args.length == 1 && args[0] == "init")
        options[:init] = true
      end

      #subcommands[args.shift].order!(args)

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
    #puts options
    options
  end

  #run commands
  def run!
    #intialize repository, after that we can begin load and persisting data
    @hostManager.setVerbosity(@options[:verbose])
    if(@options[:init])
      @hostManager.initRepository()
    end

    #loadData from persistence file
    if(!@hostManager.loadData!)
      @help.repositoryError
      showHelp()
      exit 1
    end

    if(@options[:help])
      showHelp()
      exit 0
    end

    if(@options[:version])
      version()
      exit 0
    end

    if(@options[:add])
      @hostManager.add(@options[:host],@options[:ip],@options[:plat])
    end

    if(@options[:edit])
      @hostManager.edit(@options[:host],@options[:ip],@options[:plat])
    end

    if(@options[:remove])
      @hostManager.remove(@options[:host],@options[:plat])
    end

    if(@options[:apply])
      @hostManager.apply(@options[:plat])
    end

    if(@options[:clean])
      @hostManager.clean(@options[:plat])
    end


    if(@options[:list])
      @hostManager.show!
    end

    @hostManager.persistData!

    self
  end

end
