#!/usr/bin/python
####
# Instalation Script for Brew
# 
# @Version 0.1-beta
# @Author Iuri Andreazza {@iuriandreazza}
#
import sys
import os
import subprocess

def install():
    print '####################################################################'
    print '    Inicializing Install Hoster: '+ hVersion + ' on ' + hLocation
    print '####################################################################'
    # bestway to execute commands to OS and it's the only way to get the locations
    # from .bashrc profile when running the installer to brew
    proc = subprocess.Popen(["ls ~/.bashrc"], stdout=subprocess.PIPE, shell=True)
    (bashrcPath, err) = proc.communicate()
    # BUG: There is a \n at the end of line we need to remove to ensure the correct file location
    bashrcPath = bashrcPath.replace("\n", "")
    print '-> Entering Directory:'
    os.system("ln -sf "+hLocation+"/hoster.sh "+hLocation+"/hoster")
    print '-> Applying file permissions'
    os.system("chmod +x "+hLocation+"/hoster")
    print '-> Altering bashrc profile'
    print '->     located at: '+bashrcPath
    
    #execute a bkp the bashrc
    os.system("cp "+bashrcPath+" "+bashrcPath+".bk")
    
    #need to validate about the export, if it's there we will do nothing
    #if it's there we will replace it with the new export
    with open(bashrcPath, "wt+") as fout:
        with open(bashrcPath+".bk", "rt+") as fin:
            for line in fin:
                if( 'hoster' not in line):
                    fout.write(line)    
    # Append Mode Only
    with open(bashrcPath, 'a') as bashfile:
        bashfile.write("export PATH=${PATH}:"+hLocation+"/\n")
    print '-> Reloading bashrc profile for the install'
    os.system("source "+bashrcPath)
    
    #Warning user about the $PATH export
    print '-> To work without restarting the terminal execute:'
    print '->     $ source '+bashrcPath
    
# Current version
hVersion = sys.argv[2]
# defining the location from particular OS (like MacOS, Linux)
# the os.name gives posix to all *nix systems
# and the others we will handle as not suported.
if(os.name == 'posix'):
    hLocation = sys.argv[1]
    install()
else:
    print 'Your OS is not suported YET.'
    print 'try building by hand, to learn more visit: https://github.com/helmedeiros/hoster'
    

