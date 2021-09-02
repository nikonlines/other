#!/bin/bash

#Update Repositories and Packages
sudo apt-get update && sudo apt-get upgrade

#Install Tasksel manager 
sudo apt-get install tasksel

#Install Display manager
sudo apt-get install slim

#Install Mate Core Server Desktop
sudo tasksel install ubuntu-mate-core

#Start display manager
sudo service display_manager start
