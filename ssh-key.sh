#!/bin/bash

ssh-keygen -q -t rsa -C "$(whoami)@$(hostname)" -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
