#!/bin/bash

#Update Repositories and Packages
apt-get update && sudo apt-get upgrade

#Install Tasksel manager 
apt-get install tasksel

#Install Display manager
apt-get install slim

#Install Mate Core Server Desktop
tasksel install ubuntu-mate-core

#Start display manager
service display_manager start