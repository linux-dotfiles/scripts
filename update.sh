#!/bin/bash

sudo apt update -y \
  && sudo apt upgrade -y \
  && sudo apt dist-upgrade -y \
  && sudo apt-get autoremove -y \
  && sudo apt-get autoclean -y
