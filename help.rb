#!/usr/bin/env ruby
#
# hoster helps messages.
class Help

  @@hoster_usage_string=PROGNAME + " [--help] [--version] <command> [<args>]\n";

  def list_commands
    print "usage: ".concat(PROGNAME)+"\n\n".concat(@@hoster_usage_string)+" \n\n"
    self.list_common_cmds_help
  end

  def list_common_cmds_help
    print "The most commonly used `basename $0` commands are\n";
    print "    add 	Add a new HOST to current repository into a specific environment.\n";
    print "    edit	Open the host file defined to be used.\n";
    print "    init	Create an empty host repository in the current folder.\n";
    print "    list	List all hosts for a specific project.\n";
  end
end
