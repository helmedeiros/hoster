About
=====

**hoster** is a new auxiliary project pattern to control and keep closer to new application all its host configrations.

It is not always easy to discover the hosts needed for an application to run. This project helps you to mantain developers updated in a central point, about all addresses used and needed for it to work.

Using this pattern will be possible to you and your company to keep local, development, homologation and production specific pairs of hostnames and ip addresses versioned into your code repository, applying one of these into your main Host file.

Build
=====
The project use the maven assembly plugin to gather scripts and organize the package. First you need to have maven installed on the system and then to build just follow the steps:

1.
	```$ mvn clean```

2.
	```$ mvn package```

Ignore the target folder, it's just trash left behind by maven.


Install
=====
1. First, clone down the repository:

    ```$ git clone https://github.com/helmedeiros/hoster```

2. Next, you need to make the command executable:

    ```$ chmod +x hoster```

3. To make sure my shell knows where to find hoster you will need to add the addres from where you've cloned the project to your .bashrc file's PATH variable. Here's how mine looks:

    ```$ export PATH=${PATH}:/Users/helmed/Projects/workspaceShell/hoster/```

4. Make sure you reload your shell with:

    ```$ source ~/.bashrc```


Usage
=====

There are different ways to use the hoster to create and keep your applications' hosts running and beeing applied.

1. A project needs to know that it will start to run in hoster's standard:

    ```$ hoster init```

2. After defining the use of the default, you must add Hosts into a specific environment:

    ```$ hoster add 10.1.0.5 www.github.com --dev```

3. A project needs to list the configured hosts.

    ```$ hoster list```

    ```$ hoster list --dev```

4. It may be more efficient to use an editor to work on adding and removing hosts.

    ```$ hoster edit --dev --tool sublime```

5. After setup is complete the host should be applied..

    ```$ hoster apply --dev```
