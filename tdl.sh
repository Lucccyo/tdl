#!/bin/bash 

project_dir="$HOME/.config/tdl/"

if [[ "$#" -eq 0 ]]; then 
  exit 0 
fi
if [[ "$1" =~ ^- ]]; then
  if [[ ! (($1 == "-c" || $1 == "-o" || $1 == "-r") && -n $2) && ! $1 == "-l" ]]; then
    echo 'invalid command'
    exit 0
  elif [[ $1 == '-l' ]]; then
    ls $project_dir | grep -v $project_dir
  else 
    case "$1" in
      '-c' ) 
	mkdir "$project_dir$2"
	touch "$project_dir$2/paths.sh"
	echo '#!/bin/bash' > "$project_dir$2/paths.sh";;
      '-o' ) 
	setsid sh "$project_dir$2/paths.sh" &
	kill -9 $(ps -o ppid= -p $$)
	;;
      '-r' ) 
	rm -rf "$project_dir$2";;
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
    grep -v '^\s*$\|^#' "$project_dir$1/paths.sh"
  else 
    case "$2" in
      '-a' ) 
	if [[ "$#" -lt 5 ]]; then
	  exit 0
	else
	  echo "#$3" >> "$project_dir$1/paths.sh"
	  case "$4" in
  	    '-f' ) echo "firefox -new-window $5 &" >> "$project_dir$1/paths.sh" ;;
  	    '-v' ) echo "alacritty -e nvim $5 &" >> "$project_dir$1/paths.sh" ;;
  	    '-t' ) echo "alacritty --working-directory $5 &" >> "$project_dir$1/paths.sh" ;;
	  esac
	fi

	;;
      '-g' ) echo "on ghost les paths ... dans $1" ;;
      '-r' )
	if [[ $3 == "-all" ]]; then
	  echo "#!/bin/bash" > "$project_dir$1/paths.sh"
	else
	  l=$(grep -n "^#$3" "$project_dir$1/paths.sh" | head -c 1)
	  if [[ $l -gt 1 ]]; then
	    sed -i "${l}d" "$project_dir$1/paths.sh"
	    sed -i "${l}d" "$project_dir$1/paths.sh"
	  fi
	fi ;;
    esac
  fi
fi

