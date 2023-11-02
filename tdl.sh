#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREY='\033[0;90m'
UNDERLINED='\033[4m'
NC='\033[0m' # no colour

missing_operand() {
  echo -e "tdl: ${RED}missing operand${NC}"
  echo "Try 'tdl --help' for more information." 
  exit 0
}

invalid_command() {
  echo -e "tdl: ${RED}unrecognized option '$1'${NC}"
  echo "Try 'tdl --help' for more information." 
  exit 0 
}

too_few_arguments() {
  echo -e "tdl: ${RED}option requires $1 -- '$2'${NC}"
  echo "Try 'tdl --help' for more information." 
  exit 0 
}

invalid_path(){
  echo -e "$1: ${RED}path not found, impossible to add it${NC}"
  exit 0
}

context_error(){
  echo -e "tdl: ${RED}$1${NC}"
  if [ $# -eq 1 ]; then
    echo "Try 'tdl -l' to view existing contexts."
  else
    echo "Try 'tdl --help' for more information."
  fi
  exit 0
}

path_error() {
  echo -e "tdl: ${RED}$1${NC}"
  if [[ $3 != 1 ]]; then
    echo -e "Try 'tdl ${UNDERLINED}$2${NC} -l' to view existing paths of ${UNDERLINED}$2${NC}."
    exit 0
  fi
}

project_dir="$HOME/.config/tdl/"

if [[ "$#" -eq 0 ]]; then 
  missing_operand
fi
if [[ "$1" =~ ^- ]]; then
  context=$2
  case "$1" in
  # --- no parameters ---
    '-l'|'--list')
      # tdl -l
      ls -1 $project_dir;;
    '--help' )
      man tdl;;
  # --- one parameter ---
    '-c'|'--create' )
      # tdl -c <context>
      if [[ "$#" -lt 2 ]]; then
	too_few_arguments "an argument" $1
      elif [[ -d "$project_dir$context" ]]; then
	context_error "context $context already exists"
      fi
      mkdir "$project_dir$context"
      touch "$project_dir$context/paths.sh"
      echo '#!/bin/bash' > "$project_dir$context/paths.sh";;
    '-o'|'--open' )
      # tdl -o <context>
      if [[ "$#" -lt 2 ]]; then
	too_few_arguments "an argument" $1
      elif [[ ! -d "$project_dir$context" ]]; then
	context_error "context $context not found"
      elif [[ $(wc -l < "$project_dir$context/paths.sh") -eq 1 ]]; then
	context_error "$context: empty context" ""
      fi
      setsid sh "$project_dir$context/paths.sh" &
      kill -9 $(ps -o ppid= -p $$) ;;
    '-d'|'--delete')
      # tdl -d <context>
      if [[ "$#" -lt 2 ]]; then
	too_few_arguments "an argument" $1
      elif [[ ! -d "$project_dir$context" ]]; then
	context_error "context $context not found"
      fi
      rm -r "$project_dir$context";;
  # --- two parameters ---
    '-r'|'--rename' )
      # tdl -r <context> <new_context_name>
      new_context=$3
      if [[ "$#" -lt 3 ]]; then
	too_few_arguments "two arguments" $1
      elif [[ -d "$project_dir$new_context" ]]; then
	context_error "context $new_context already exists"
      elif [[ ! -d "$project_dir$context" ]]; then
	context_error "context $context not found"
      fi
      mv "$project_dir$context" "$project_dir$new_context";;
    *)
      invalid_command $1;;
  esac
else 
  context=$1
  if [[ ! -d "$project_dir$context" ]]; then
    context_error "context $context not found"
  elif [[ "$#" -eq 1 ]]; then
    missing_operand
  fi
  case "$2" in
  # --- no parameters ---
    '-l'|'--list')
      # tdl <context> -l
      while read -r label; do
	if [[ $label =~ ^#! ]]; then
	  continue
	fi
	read -r path
	if [[ $path =~ ^# ]]; then
	  echo -e "${GREY}$label${NC}"
	else
	  echo $label | sed 's/^..//'
	fi
      done < "$project_dir$context/paths.sh";;
  # --- custom parameters ---
    '-a'|'--add')
      # tdl <context> -a <label> -[f|v|t] <path>
      label=$3
      if [[ $(grep -n "^# $label$" "$project_dir$context/paths.sh" | wc -l) -gt 0 ]]; then
	path_error "label '$label' already exists" $context
      fi
      if [[ $4 =~ "^-f" || $4 =~ "^-v" || $4 =~ "^-t" ]]; then	
	if [[ "$#" -lt 5 ]]; then
	  too_few_arguments "a path" $2 
	fi
	option=$4
	path=$5
	if [[ "$option" != "-f" && ( ! -f "$path" && ! -d "$path" ) ]]; then 
	  invalid_path $path
	elif [[ ( "$option" == "-t" || "$option" == "--terminal" ) && -f "$path" ]]; then
	  echo -e "tdl: ${RED}$path is a file, impossible to open a terminal on a file${NC}"
	  echo "Try 'tdl --help' for more information." 
	  exit 0
	fi
	echo "# $label" >> "$project_dir$context/paths.sh"
	case "$option" in
  	  '-f'|'--firefox')
	    echo "firefox -new-window \"$path\" &" >> "$project_dir$context/paths.sh" ;;
  	  '-v'|'--vim')
	    echo "alacritty -e nvim \"$path\" &" >> "$project_dir$context/paths.sh" ;;
  	  '-t'|'--terminal')
	    echo "alacritty --working-directory \"$path\" &" >> "$project_dir$context/paths.sh" ;;
	  *)
	    invalid_command $option;;
	esac
      elif [[ $4 =~ ^-ccmd\[(.*?)\] ]]; then
	if [[ "$#" -lt 4 ]]; then
	  too_few_arguments " four arguments" $2
	fi
	  cmd=$(echo $4 | cut -d "[" -f2 | cut -d "]" -f1)
	  echo "# $label" >> "$project_dir$context/paths.sh"
	  echo "$cmd &" >> "$project_dir$context/paths.sh"
      else
	invalid_command $4
      fi;;
  # --- two parameters ---
     '-r'|'--rename')
      # tdl <context> -rename <label> <new_label>
      if [[ "$#" -lt 4 ]]; then
	too_few_arguments "two arguments" $2
      fi
      label=$3
      new_label=$4
      if [[ $(grep -n "^# $label$" "$project_dir$context/paths.sh" | wc -l) -eq 0 ]]; then
        path_error "label '$label' not found" $context
      elif [[ $(grep -n "^# $new_label$" "$project_dir$context/paths.sh" | wc -l) -gt 0 ]]; then
	path_error "path name '$new_label' already exists" $context
      else
	l=$(grep -n "^# $label$" "$project_dir$context/paths.sh" | cut -f 1 -d ':')
        sed -i "${l}s/\(\([^ ]* \)\{1\}\)[^ ]*/\1$new_label/" "$project_dir$context/paths.sh"
      fi;;
  # --- multi parameters ---
    '-t'|'--toggle')
      # tdl <context> -t --all
      # tdl <context> -t <label>...
      if [[ "$#" -lt 3 ]]; then
	too_few_arguments "arguments" $2
      fi
      if [[ $3 == "-all" ]]; then
	l=3
	sed -n "1~2p" "$project_dir$context/paths.sh" | while read -r line ; do
	  if [[ $line =~ "#!/bin" ]]; then 
	    continue
	  fi
	  if [[ "$line" =~ ^# ]]; then
	    sed -i "${l}s/^.//" "$project_dir$context/paths.sh"
	  else
	    sed -i "${l}s/^/#/" "$project_dir$context/paths.sh"
	  fi
	  l=$(( l+2 ))
	done
	exit 0
      fi
      shift; shift
      for label in "$@"; do
	if [[ $(grep -n "^# $label$" "$project_dir$context/paths.sh" | wc -l) -eq 0 ]]; then
	  path_error "${YELLOW}label '$label' not found, cannot toggle it" $context 1
	fi
	l=$(grep -n "^# $label$" "$project_dir$context/paths.sh" | cut -f 1 -d ':')
	l=$((l+1))
	line=$(sed -n "${l}p" < "$project_dir$context/paths.sh")
	if [[ "$line" =~ ^# ]]; then
	  sed -i "${l}s/^.//" "$project_dir$context/paths.sh"
	else
	  sed -i "${l}s/^/#/" "$project_dir$context/paths.sh"
	fi
      done;;
    '-d'|'--delete')
      # tdl <context> -d -all
      # tdl <context> -d <label>...
      if [[ "$#" -lt 3 ]]; then
	too_few_arguments "arguments" $2	
      fi
      if [[ $3 == "-all" ]]; then
	echo "#!/bin/bash" > "$project_dir$context/paths.sh"
	exit 0
      fi
      shift; shift
      for label in "$@"
      do
	if [[ $(grep -n "^# $label$" < "$project_dir$context/paths.sh" | wc -l) -eq 0 ]]; then
	  path_error "${YELLOW}label '$label' not found, cannot delete it" $context 1
	else
	  l=$(grep -n "^# $label$" "$project_dir$context/paths.sh" | cut -f 1 -d ':')
	  echo $l
	  if [[ $l -gt 1 ]]; then
	    seq 2 | xargs -I{} sed -i "${l}d" "$project_dir$context/paths.sh"
	  fi
	fi
      done;;
    *)
      invalid_command $2;;
  esac
fi

