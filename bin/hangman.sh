#!/usr/bin/bash
source copyright.inc
source colors.var
SOURCE="/usr/share/dict/wordlist-probable.txt"
NOLIST="cGFzc3dvcmQKc3Vuc2hpbmUKZm9vdGJhbGwKY29tcHV0ZXIKc3VwZXJtYW4KaW50ZXJuZXQKYmFz
ZWJhbGwKd2hhdGV2ZXIKcHJpbmNlc3MKc3RhcndhcnMK"
EXITKEY="@"
if [[ -f ${SOURCE} ]]; then
mapfile -t WORDS < $SOURCE
else
WORDS=($(echo "${NOLIST}"|base64 -d))
NOLIST=1
fi
source hangman.gfx

## <DEBUG>
DEBUG_TXT() {
MSG="$@"
[[ $NOLIST == 1 ]] && MSG+="\n${NC}Using No List"
if [[ $DEBUG == TRUE ]]; then
    printf "${RED}DEBUG${NC}: ${YELLOW}${MSG}${NC}\n"
fi
}
## </DEBUG>

## <RESTART>
RESTART() {
echo -en "\n"
[[ -z $1 ]] && read -n1 -p " Quit [y/N]: " quit || quit=$1
quit=${quit:-n}
[[ $quit =~ (y|Y) ]] && { tput cup 35 0; CLEAR 35; echo; exit 0; } || INIT
}
## </RESTART>

## <CLEAR [N] LINES>
CLEAR() {
CL="\033[K" # clear line
LB="\033[1A" # go back x line(s) 1 in this case
N=$1
RML=${CL}  
for (( i=0; i<$N; i++ )); do 
RML+=${LB}${CL}
done
echo -en "${RML}"
}
## <CLEAR [N] LINES>

## <DRAW HANGMAN GFX>
HANGEM() {
if [[ $1 < 2 ]]; then
   LVL=${BASE}
elif [[ $1 == 2 ]] || [[ $1 == 3 ]] || [[ $1 == 4 ]]; then
   LVL=${BEAM}
elif [[ $1 == 5 ]]; then
   LVL=${ROPE}
elif [[ $1 == 6 ]]; then
   LVL=${ROPEO}
elif [[ $1 == 7 ]]; then
   LVL=${HANG}
elif [[ $1 == 9 ]]; then
   LVL=${WINNER}
fi
[[ $1 < 7 ]] && echo
base64 -d <<<"${LVL}"
}
## </DRAW HANGMAN GFX>

## <INITIALIZE GAME>
INIT() {
echo -en "\nTYPE ${BOLD}${HGREEN}${EXITKEY}${NC} TO QUIT"
sleep 3
clear
WORD="${WORDS[RANDOM % ${#WORDS[@]}]}"
DEBUG_TXT "${BOLD}${WHITE}word = ${YELLOW}$WORD"
solution=()
wrong=()
for (( i=0; i<${#WORD}; i++ )); do
solution+=('_')
done
}
## </INITIALIZE GAME>

## <CHECK INPUT>
CHECK() {
for (( i=0; i<${#WORD}; i++ )); do
  if [[ ${WORD:${i}:1} == $1 ]]; then
     solution[$i]=$1
     COMPARE=$(echo ${solution[@]}| sed 's/ //g')
  else
     if ! [[ ${wrong[*]} =~ $1 ]] && ! [[ ${WORD[*]} =~ $1 ]]; then
        wrong+=( $1 )
     fi
  fi
done

## Too many wrong tries 
if [[ ${#wrong[@]} > 6 ]]; then
HANGEM 7
[[ $LEARN ]] && echo -e "\n\t${BOLD}${HRED}GameOver${NC}\n\t${WHITE}Word was: ${BOLD}${UNDERLINE}${GREEN}${WORD}${NC}." || echo -e "\n\t${BOLD}${RED}Gameover${NC} HANGMAN!!"
RESTART
fi

## Completed
if [[ ${COMPARE} == ${WORD} ]]; then
tput cup 27 0
CLEAR 26
HANGEM 9
echo -e "\n\t${GREEN}Congratulations${NC}.\n\tThe word was: \"${BOLD}${UNDERLINE}${HGREEN}${COMPARE}${NC}\" "
RESTART
fi
}
## </CHECK INPUT>

while getopts ":vhlf:" OPTIONS ; do
    case "$OPTIONS" in
      v) DEBUG=TRUE ;;
       l) LEARN=TRUE ;;
       f) [[ -f ${OPTARG} ]] && mapfile -t WORDS < ${OPTARG} || { echo "No such file ${OPTARG}"; exit 0; } ;;
      h) echo -en "USAGE $0 [OPTION]\n\n\t-h\tShow this help\n\t-v\tShow the word DEBUG MODE\n\t-l\tShow the word if not guessed right.\n\t-f [FILE]\tFile containing words,\n\n\tWhile playing send '${EXITKEY}' to QUIT\n"; exit 0;;
       :) echo "Error: -${OPTARG} requires a file"; exit 1 ;;
       *) echo "Unknown option: -${OPTARG}" ; exit 1 ;;
       ?) echo "Too many arguments"; exit 1 ;;
    esac
done

INIT

while : ; do
echo -en "$(HANGEM ${#wrong[@]})\nmissed: ${BOLD}${YELLOW}${wrong[@]}${NC} [${#wrong[@]}/7]\n${solution[@]}\n${BOLD}${HBLUE}Choose a letter${NC}${BOLD}${WHITE}:${NC} "
read -n1 letter
CLEAR 26
if [[ $letter == "${EXITKEY}" ]]; then
RESTART Y
fi
CHECK $letter
done
