#!/bin/bash -i

path=$(pwd)
bashrc="$HOME/.bashrc"
echo '# run tdl' >> $bashrc
echo "alias tdl='sh $path/tdl.sh'" >> $bashrc
source $bashrc
