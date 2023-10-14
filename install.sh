#!/bin/bash -i

path=$(pwd)
bashrc="$HOME/.bashrc"

N=$(grep "^alias tdl" $bashrc | wc -l)
if [[ $N -eq 0 ]]; then 
  echo '# run tdl' >> $bashrc
  echo "alias tdl='sh $path/tdl.sh'" >> $bashrc
fi
source $bashrc

project_dir="$HOME/.config/tdl/"

if [[ ! -d $project_dir ]]; then
  mkdir $project_dir
fi

if [ -f '/usr/share/man/man1/tdl.1.gz' ]; then
  sudo cp tdl.1.gz /usr/share/man/man1 
fi

