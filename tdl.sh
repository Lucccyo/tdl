#!/bin/bash 

# -c -l -o -r 

project_dir="$HOME/.config/tdl/"

if [[ "$#" -eq 0 ]]; then 
  exit 0 
fi
if [[ "$1" =~ ^- ]]; then
  echo "c'est une option — soit list ; soit create NAME"
  if [[ ! (($1 == "-c" || $1 == "-o" || $1 == "-r") && -n $2) && ! $1 == "-l" ]]; then
    echo 'invalid command'
    exit 0
  elif [[ $1 == '-l' ]]; then
    echo 'on liste les projects'
  else 
    case "$1" in
      '-c' ) echo 'on crée un projet' ;;
      '-o' ) echo 'on ouvre un projet' ;;
      '-r' ) echo 'on suprimme un projet';;
    esac 
  fi
else 
  if [[ "$#" -eq 1 ]]; then
    exit 0
  fi
  if [[ ! (($2 == "-a" || $2 == "-g" || $2 == "-r") && -n $3) && ! $2 == "-l" ]]; then
    echo 'invalid command'
    exit 0
  elif [[ $2 == '-l' ]]; then
    echo "on liste les paths de $1"
  else 
    case "$2" in
      '-a' ) echo "on ajoute les paths ... a $1" ;;
      '-g' ) echo "on ghost les paths ... dans $1" ;;
      '-r' )
	if [[ $3 == "-all" ]]; then
	  echo "on remove tout les paths dans $1"
	else
	  echo "on remove les paths ... dans $1" 
	fi ;;
    esac
  fi
fi

