#!/bin/bash

sudo apt install -y tmux git

# устанавливаем tmux-plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

yes | cp -vfa .tmux.conf ~/.tmux.conf
