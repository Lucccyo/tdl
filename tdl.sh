#!/bin/bash 

invalid_command() {
  echo "tdl: missing operand"
  echo "Try 'tdl --help' for more information." 
  exit 0 
}

context_already_exists() {
  echo "tdl: context already exists"
  echo "Try 'tdl -l' to view existing contexts."
  exit 0
}

context_unfound(){
  echo "tdl: context not found"
  echo "Try 'tdl -l' to view existing contexts."
  exit 0
}

empty_context(){
  echo "tdl: empty context"
  echo "Try 'tdl --help' for more information."
  exit 0
 
}

path_unfound(){
  echo "tdl: path name not found"
  echo "Try 'tdl <context> -l' to view existing paths of <context>."
  exit 0
}

path_already_exists() {
  echo "tdl: path name already exists"
  echo "Try 'tdl <context> -l' to view existing paths of <context>."
  exit 0
}

project_dir="$HOME/.config/tdl/"

if [[ "$#" -eq 0 ]]; then 
  invalid_command
fi
if [[ "$1" =~ ^- ]]; then
  if [[ ! (($1 == "-c" || $1 == "-o" || $1 == "-d") && -n $2) && ! $1 == "-l" && ! $1 == "--help" ]]; then
    invalid_command
  elif [[ $1 == '-l' ]]; then
    # tdl -l
    ls $project_dir | grep -v $project_dir
  elif [[ $1 == "--help" ]]; then
    # tdl --help
    man tdl
  else 
    case "$1" in
      '-c' )
	# tdl -c <context>
	if [[ -d "$project_dir$2" ]]; then
	  context_already_exists
	fi
	mkdir "$project_dir$2"
	touch "$project_dir$2/paths.sh"
	echo '#!/bin/bash' > "$project_dir$2/paths.sh";;
      '-o' )
	# tdl -o <context>
	if [[ ! -d "$project_dir$2" ]]; then
	  context_unfound
	fi
	if [[ $(wc -l < "$project_dir$2/paths.sh") -eq 1 ]]; then
	  empty_context
	fi
	setsid sh "$project_dir$2/paths.sh" &
	kill -9 $(ps -o ppid= -p $$) ;;
      '-d' )
	# tdl -r <context>
	if [[ ! -d "$project_dir$2" ]]; then
	  context_unfound
	fi
	rm -rf "$project_dir$2";;
    esac 
  fi
else 
  if [[ "$#" -eq 1 ]]; then
    exit 0
  fi
  if [[ ! (($2 == "-a" || $2 == "-g" || $2 == "-d") && -n $3) && ! $2 == "-l" ]]; then
    invalid_command
  elif [[ $2 == '-l' ]]; then
    # tdl <context> -l
    #grep '^#\s' "$project_dir$1/paths.sh"
    # pour chaque ligne paire (a partir de 2) 
    while read -r path_name 
    do
      if [[ $path_name =~ ^#! ]]; then
	continue
      fi
      #echo "path name : " $path_name
      read -r path
      #echo "path : " $path
      if [[ $path =~ ^# ]]; then
	echo $path_name
      else
	# sed 's/^.\{2\}//' < $path_name
	# enlever le '# ' devant pathname
      fi
    done < "$project_dir$1/paths.sh"

    # 		on recup le nom
    # 		on recup le num de ligne
    # on verifie a la ligne d'apres si elle commence par un #
    # 		si oui, on print le nom direct
    # 		si non, on print le nom en elevant le '# ' devant



  else 
    case "$2" in
      '-a' )
	# tdl <context> -a <path_name> -[f|v|t] <path>
	if [[ "$#" -lt 5 ]]; then
	  exit 0
	elif [[ $(grep "# $3" < "$project_dir$1/paths.sh" | wc -l) -eq 1 ]]; then
	  path_already_exists
	else
	  echo "# $3" >> "$project_dir$1/paths.sh"
	  case "$4" in
  	    '-f' ) echo "firefox -new-window $5 &" >> "$project_dir$1/paths.sh" ;;
  	    '-v' ) echo "alacritty -e nvim $5 &" >> "$project_dir$1/paths.sh" ;;
  	    '-t' ) echo "alacritty --working-directory $5 &" >> "$project_dir$1/paths.sh" ;;
	  esac
	fi
	;;
      '-g' )
	# tdl <context> -g <path_name> <path_name>...
	for path in "$@"
	do
	  if [[ $path = $1 || $path = $2 ]]; then
	    continue
	  fi
	  if [[ $(grep "# $path" < "$project_dir$1/paths.sh" | wc -l) -eq 0 ]]; then
	    path_unfound
	  fi
	  l=$(grep -n "^# $path" "$project_dir$1/paths.sh" | head -c 1)
	  l=$((l+1))
	  line=$(sed -n "${l}p" < "$project_dir$1/paths.sh")
	  if [[ "$line" =~ ^# ]]; then
	    sed -i "${l}s/^.//" "$project_dir$1/paths.sh"
	  else
	    sed -i "${l}s/^/#/" "$project_dir$1/paths.sh"
	  fi
	done;;
      '-d' )
	# tdl <context> -r -all
	# tdl <context> -r <path_name> <path_name>...
	if [[ $3 == "-all" ]]; then
	  echo "#!/bin/bash" > "$project_dir$1/paths.sh"
	fi
	for path in "$@"
	do
	  if [[ $path = $1 || $path = $2 ]]; then
	    continue
	  fi
	  if [[ $(grep "# $path" < "$project_dir$1/paths.sh" | wc -l) -eq 0 ]]; then
	    path_unfound
	  else
	    l=$(grep -n "^# $path" "$project_dir$1/paths.sh" | head -c 1)
	    if [[ $l -gt 1 ]]; then
	      sed -i "${l}d" "$project_dir$1/paths.sh"
	      sed -i "${l}d" "$project_dir$1/paths.sh"
	    fi
	  fi
	done;;
    esac
  fi
fi

