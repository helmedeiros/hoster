#!/bin/bash
rm /Library/Caches/Homebrew/hoster-0.1.tar.gz 
brew remove hoster
brew install --verbose --debug hoster
brew test hoster


ls -lsa /usr/local/Cellar/hoster/0.1/
