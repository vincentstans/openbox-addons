#!/bin/bash

# Script depends on feh/xdg-user-dirs/fdupes packages

debug=0
running="ONLINE" # running variable = ONLINE or LOCAL or FAV
resolution="3840x2160" # currently 4k. Set YOUR OWN resolution here!
wptype="nature,water,wallpaper"
url="https://source.unsplash.com/$resolution/?$wptype" # See unsplash.com for more ...
timer=300  # Time in seconds to change the wallpaper
wallp="$HOME/.wallpaper.jpg"
storage="$(xdg-user-dir PICTURES)/Wallpapers/$resolution"
setwp="feh --bg-scale --no-fehbg $wallp"
arg=$1

####################################
# No need to edit bewlow this line #
####################################

setup_r() {
timesec=$(date +%s)
newfile="$storage/$timesec.jpg"
wget -q -O $newfile $url
if [ $debug -eq "1" ]; then echo; echo "   Saved file as: $newfile"; fi
}

setup_l() {
flist=($storage/*.jpg)
randwp=${flist[$RANDOM % ${#flist[@]}]}
if [ $debug -eq "1" ]; then echo; echo "   There are ${#flist[@]} files in $storage"; echo "   Selected a random file: $randwp"; echo ; fi
}

setup() {
if [ -f "$wallp" ]; then
if [ $debug -eq "1" ]; then echo; echo "    Remove Symbolic link $wallp"; fi
rm $wallp
fi
if [ $running == "LOCAL" ]; then
    if [ $debug -eq "1" ]; then echo; echo "   LOCAL Wallpaper Active"; fi
    setup_l
    ln -s $randwp $wallp
  elif [ $running == "ONLINE" ]; then
    if [ $debug -eq "1" ]; then echo; echo "   ONLINE Wallpaper Active"; fi
    setup_r
    ln -s $newfile $wallp
  else
    storage=$storage/fav
    setup_l
    if [ $debug -eq "1" ]; then echo; echo "   Showing Favorites Wallpaper from: $randwp"; fi
    ln -s $randwp $wallp
fi
$setwp
if [[ $arg -eq 1 ]]; then
    echo; echo "   New Wallpaper set "; echo
    exit 0
fi
}

savefav() {
realwp=$(realpath $wallp)
favfile=$(realpath $wallp | awk -F/ '{ print $7 }')
if [ ! -f "$storage/fav/$favfile" ]; then
echo; echo "    Saving $realwp"; echo "    to"; echo "    $storage/fav/$favfile"
cp $realwp $storage/fav/
else
echo; echo "    Reeds in je favorieten "
fi
echo
}

if [ ! -d $storage/fav ]; then
echo "    $storage/fav doesn't exist creating it"
mkdir -p $storage/fav
running="ONLINE"
setup_r
sleep 10
feh --bg-scale $newfile
fi

if [ ! $1 ]; then
echo "   Wallpaper Setting Script"
echo -e "\n   Wallpaper is set on: $running"
if [ $running == ONLINE ]; then
echo "   Getting Wallpaper from: $url"
else
#setup_l
echo "   Getting Wallpaper from: $wallp"
fi
echo -e "\n   To start the script type: $0 <num> "
echo "   Where <num> can be [0 or 1] "
echo -e "\n   0) run the script in the background apply & at the end "
echo "   1) directly change the wallpaper"
echo "   2) Save current wallpaper to $storage/fav/"
echo "   3) Delete this Ugly Wallpaper "
echo
exit 0
fi

if [[ $1 -eq 3 ]]; then
realwp=$(realpath $wallp)
if [ $debug -eq "1" ]; then echo; echo "    Scanning for Duplicates"; fdupes -f -d -I $storage; echo ; else fdupes -f -d -q -I $storage; fi
rm $realwp
rm $wallp
echo; echo "   Deleted that ugly Wallpaper: $realwp"; echo
fi

if [[ $1 -eq 2 && $running != "FAV" ]]; then
savefav
exit 0
elif [[ $1 -eq 2 ]]; then
echo; echo "   Your already Running Favorite Wallpapers "; echo
exit 0
fi
echo "SESSION = " $DESKTOP_SESSION
while [[ $DESKTOP_SESSION == compiz || $DESKTOP_SESSION == *"penbox"* ]] && [[ $1 -eq 0 ]]; do
setup
sleep $timer
done

exit 0
