ok_ctxt="test_context"
ko_ctxt="unexistant"

ok_lbl="test_label"
ko_lbl="unexistant"

ok_dir_path=$HOME
ko_dir_path="~/foo/"

ok_file_path="~/test_tdl"
ko_file_path="~/foo"

tdl #E: missing arguments

tdl -u #E: invalid command

tdl ok_context -u #E: invalid command



tdl -l #OK



tdl -c ko_ctxt #OK
tdl -c ok_ctxt #E: context already exists
tdl -c #E: too few arguments



tdl -o ok_ctxt #OK if ok_ctxt is not empty
tdl -o ok_ctxt #E: context empty if empty
tdl -o ko_ctxt #E: context not found
tdl -o #E: too few arguments



tdl -d ok_ctxt #OK
tdl -d ko_ctxt #E: context not found
tdl -d #E: too few arguments



tdl -r ok_ctxt ko_ctxt #OK
tdl -r ko_ctxt ok_ctxt #E: context not found
tdl -r ok_ctxt #E: too few arguments
tdl -r #E: too few arguments



tdl ok_ctxt -l #OK
tdl ko_ctxt -l #E: context not found



tdl ok_ctxt -a ko_label -f "google.com" #OK
tdl ko_ctxt -a ko_label -f "google.com" #E: context not found
tdl ok_ctxt -a ok_label -f "google.com" #E: label already exists
tdl ok_ctxt -a ok_label -f #E: too few arguments

tdl ok_ctxt -a ko_label -v ok_dir_path #OK
tdl ok_ctxt -a ko_label -v ok_file_path #OK
tdl ok_ctxt -a ko_label -v ko_file_path #E: invalid path
tdl ok_ctxt -a ko_label -v ko_dir_path #E: invalid path
tdl ko_ctxt -a ko_label -v ok_dir_path #E: context not found
tdl ok_ctxt -a ok_label -v ok_dir_path #E: label already exists
tdl ok_ctxt -a ok_label -v #E: too few arguments


tdl ok_ctxt -a ko_label -t ok_dir_path #OK
tdl ok_ctxt -a ko_label -t ok_file_path #E: can't open file as terminal

tdl ok_ctxt -a ko_label -ccmd[cmd] #OK
tdl ok_ctxt -a ko_label -ccmd[bad_cmd] #OK but watch out when opening the project



tdl ok_ctxt -r ok_label ko_label #OK
tdl ko_ctxt -r ok_label ko_label #E: context not found
tdl ok_ctxt -r ko_label ko_label #E: label unfound
tdl ok_ctxt -r ok_label ok_label #E: label already exists
tdl ok_ctxt -r ok_label #E: too few arguments




tdl ok_ctxt -t ok_label #OK
tdl ko_ctxt -t ok_label #E: context not found
tdl ok_ctxt -t ko_label #E: label not found

tdl ok_ctxt -t ok_label ok_label ok_label #OK
tdl ok_ctxt -t ok_label ko_label ok_label #W: label 2 not found


tdl ok_ctxt -t -all #OK
tdl ko_ctxt -t -all #E: context not found 



tdl ok_ctxt -d ok_label #OK
tdl ko_ctxt -d ok_label #E: context not found
tdl ok_ctxt -d ko_label #E: label not found

tdl ok_ctxt -d ok_label ok_label ok_label #OK
tdl ok_ctxt -d ok_label ko_label ok_label #W: label 2 not found

tdl ok_ctxt -d -all #OK
tdl ko_ctxt -d -all #E: context not found 





