#!/bin/bash 

if [[ "$#" -eq 0 ]]; then 
  exit 0 
fi
if [[ "$1" =~ ^- ]]; then
  echo "c'est une option — soit list ; soit create NAME"
  if [[ ! ($1 == "-c" && -n $2) && ! $1 == "-l" ]]; then
    echo 'invalid command'
    exit 0
  elif [[ $1 == '-l' ]]; then
    echo 'on liste les projects'
  else echo "on cree le project $2"
  fi
else echo "c'est le projet $1"
fi

