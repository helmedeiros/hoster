#!/usr/bin/env ruby
#
# hoster helps messages.
class Help

  @@hoster_usage_string=PROGNAME + " <command> [<args>]\n";
  @opts = nil

  def repositoryError
    puts "Repository #{PROGNAME} not initialized"
  end

  def invalidOption
    puts "Invalid Option detected, you should use #{PROGNAME} as showed bellow"
  end

  def missingArgument
    puts "Missing argument"
  end

  def getUsageString
    "usage: #{PROGNAME} \n\n #{@@hoster_usage_string}"
  end



  def setOpts(opts)
    @opts = opts
  end

  def list_commands
    self.list_common_cmds_help
  end

  def list_common_cmds_help
    puts @opts
    # print "The most commonly used `basename $0` commands are\n";
    # print "    add 	Add a new HOST to current repository into a specific environment.\n";
    # print "    edit	Open the host file defined to be used.\n";
    # print "    init	Create an empty host repository in the current folder.\n";
    # print "    list	List all hosts for a specific project.\n";
  end
end
