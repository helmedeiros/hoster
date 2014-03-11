#!/usr/bin/python
####
# Instalation Script for Brew
# 
# @Version 0.1-beta
# @Author Iuri Andreazza {@iuriandreazza}
#
import os
import subprocess

def install():
    print '################################################################'
    print '    Inicializing Install Hoster: '+ hVersion + ' on ' + hLocation
    print '################################################################'
    # bestway to execute commands to OS and it's the only way to get the locations
    # from .bashrc profile when running the installer to brew
    proc = subprocess.Popen(["ls ~/.bashrc"], stdout=subprocess.PIPE, shell=True)
    (bashrcPath, err) = proc.communicate()
    # BUG: There is a \n at the end of line we need to remove to ensure the correct file location
    bashrcPath = bashrcPath.replace("\n", "")
    print '-> Entering Directory:'
    os.system("ln -sf "+hLocation+"/"+hVersion+"/hoster.sh "+hLocation+"/"+hVersion+"/hoster")
    print '-> Applying file permissions'
    os.system("chmod +x "+hLocation+"/"+hVersion+"/hoster")
    print '-> Altering bashrc profile'
    print '->     located at: '+bashrcPath
    # Append Mode Only
    with open(bashrcPath, 'a') as bashfile:
        bashfile.write("export PATH=${PATH}:"+hLocation+"/"+hVersion)
    print '-> Reloading the profile'
    os.system("source "+bashrcPath)
    
# Current version
hVersion = '0.1'
# defining the location from particular OS (like MacOS, Linux)
# the os.name gives posix to all *nix systems
# and the others we will handle as not suported.
if(os.name == 'posix'):
    hLocation = '/usr/local/Cellar/hoster'
    install()
else:
    print 'Your OS is not suported YET.'
    print 'try building by hand, to learn more visit: https://github.com/helmedeiros/hoster'
    

