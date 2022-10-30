source colors.var

# Colors array
COLORS=(1 2 3 4 5 7 8 9 30 31 32 33 34 35 36 37 40 41 42 43 44 45 46 47 90 91 92 93 94 95 96 97 100 101 102 103 104 105 106 107)

COLOR() {
if [[ $1 == "list" ]]; then
       for (( I=0; I<${#COLORS[@]}; I++ ));do
              echo -en "${COLORS[$I]}. \e[${COLORS[$I]}m Text \e[0m\t"
              ((I++))
              echo -en "${COLORS[$I]}. \e[${COLORS[$I]}m Text \e[0m\n"
       done
       return 0
elif [[ $1 == code ]]; then
       for i in {000..255};do 
          echo -e "\e[48;05;${i}m ${i} \e[0m"
       done | column -c 200 $2
       return 0
elif [[ $1 == 256 ]]; then
       for (( i=0; i<256; i++ )); do
             echo -en "${i}.\e[38;05;${i}m Text $NC\tCode: "
             echo -n "\033[38;05;${i}m "
             echo -e "$NC"
       done
       return 0
elif [[ $1 == 256b ]]; then
       for (( i=0; i<256; i++ )); do
             echo -en "${i}.\e[48;05;${i}m Text $NC\tCode: "
             echo -n "\033[48;05;${i}m "
             echo -e "$NC"
       done
else
COL=$(echo ${1^^})
BG=$(echo BG${1^^})
 if [[ $COL =~ "RED" ]]; then
    echo -en "Color: ${!COL} $COL $NC "
    echo -n "Code: ${!COL} "
    echo -e "$NC"
    echo -en "Inverted: ${!COL}$INVERT $COL ${NC} "
    echo -n "Code: ${!COL}$INVERT "
    echo -e "$NC"
    echo -en "BG Color: ${!BG} $BG ${NC} "
    echo -n "Code: ${!BG} "
    echo -e "$NC"
 else
    echo -en "Color: $BLACK${!COL} $COL ${NC} "
    echo -n "Code: ${!COL} "
    echo -e "$NC"
    echo -en "Inverted: $BLACK${!COL}$INVERT $COL ${NC} "
    echo -n "Code: ${!COL}$INVERT "
    echo -e "$NC"
    echo -en "BG Color: $BLACK${!BG} $BG ${NC} "
    echo -n "Code: ${!BG} "
    echo -e "$NC"
 fi
fi
}

function showcolors256() {
    local row col blockrow blockcol red green blue
    local showcolor=_showcolor256_${1:-bg}
    local white="\033[1;37m"
    local reset="\033[0m"

    echo -e "Set foreground color: \\\\033[38;5;${white}NNN${reset}m"
    echo -e "Set background color: \\\\033[48;5;${white}NNN${reset}m"
    echo -e "Reset color & style:  \\\\033[0m"
    echo

    echo 16 standard color codes:
    for row in {0..1}; do
        for col in {0..7}; do
            $showcolor $(( row*8 + col )) $row
        done
        echo
    done
    echo

    echo 6·6·6 RGB color codes:
    for blockrow in {0..2}; do
        for red in {0..5}; do
            for blockcol in {0..1}; do
                green=$(( blockrow*2 + blockcol ))
                for blue in {0..5}; do
                    $showcolor $(( red*36 + green*6 + blue + 16 )) $green
                done
                echo -n "  "
            done
            echo
        done
        echo
    done

    echo 24 grayscale color codes:
    for row in {0..1}; do
        for col in {0..11}; do
            $showcolor $(( row*12 + col + 232 )) $row
        done
        echo
    done
    echo
}

function _showcolor256_fg() {
    local code=$( printf %03d $1 )
    echo -ne "\033[38;5;${code}m"
    echo -nE " $code "
    echo -ne "\033[0m"
}

function _showcolor256_bg() {
    if (( $2 % 2 == 0 )); then
        echo -ne "\033[1;37m"
    else
        echo -ne "\033[0;30m"
    fi
    local code=$( printf %03d $1 )
    echo -ne "\033[48;5;${code}m"
    echo -nE " $code "
    echo -ne "\033[0m"
}

redprint() { printf "${RED}%s${NC}\n" "$1"; }
greenprint() { printf "${GREEN}%s${NC}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${NC}\n" "$1"; }
blueprint() { printf "${BLUE}%s${NC}\n" "$1"; }
purpleprint() { printf "${PURPLE}%s${NC}\n" "$1"; } 
cyanprint() { printf "${CYAN}%s${NC}\n" "$1"; }
whiteprint() { printf "${WHITE}%s${NC}\n" "$1"; }

cat <<EOF
  Usage:  source $0
      COLOR [ list / code (-x) / 256 / 256b ] # -x horizontal listing
      COLOR [ black / red / green / yellow / blue / purple / cyan / white ]
      showcolors256 [ fg / bg ]
      _showcolor256_fg N       # N Color value [ 0 / 256 ]
      _showcolor256_bg N N  # 1st. N bgcolor [ 0 / 256 ]. 2nd. N ( 0. White text  1. Black text )
EOF
