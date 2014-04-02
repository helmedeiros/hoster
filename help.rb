#!/usr/bin/ruby
#
# hoster helps messages.
class help

  hoster_usage_string="$progname [--help] [--version] <command> [<args>]";

  def list_commands
    printf "usage: %s\n\n" "$hoster_usage_string";
    list_common_cmds_help
  end


  def list_common_cmds_help
    print "The most commonly used `basename $0` commands are";
    print "    add 	Add a new HOST to current repository into a specific environment.";
    print "    edit	Open the host file defined to be used.";
    print "    init	Create an empty host repository in the current folder.";
    print "    list	List all hosts for a specific project.";
  end
end
