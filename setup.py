#!/usr/bin/python
####
# Instalation Script for Brew
# 
# @Version 0.1-alpha
# @Author Iuri Andreazza {@iuriandreazza}
#
import os

def install():
    print '################################################################'
    print '    Inicializing Install Hoster: '+ hVersion + ' on ' + hLocation
    print '################################################################'
    
    
    

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
    

