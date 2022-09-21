#!/bin/bash
debug=0
running="LOCAL" # running variable = ONLINE or LOCAL or FAV
resolution="3840x2160" # Set YOUR OWN resolution here!
wptype="nature,water,wallpaper,experimental,textures-patterns"
url="https://source.unsplash.com/$resolution/?$wptype" # See unsplash.com for more ...
if [[ $debug == 1 ]]; then timer=20; dbtime=15000; else
timer=300  # Time in seconds to change the wallpaper
fi
wallp="$HOME/.wallpaper.jpg"
if ! [[ $running == "FAV" ]]; then
storage="$(xdg-user-dir PICTURES)/Wallpapers/$resolution"
else
storage="$(xdg-user-dir PICTURES)/Wallpapers/$resolution/fav"
fi
setwp="feh --bg-scale --no-fehbg $wallp"
arg=$1
####################################
# No need to edit bewlow this line #
####################################

setup_r() {
timesec=$(date +%s)
newfile="$storage/$timesec.jpg"
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 1" "   Downloading from: $url"; fi
wget -q -O $newfile $url
sleep 1
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 2" "   Saved file as: $newfile"; fi
ln -s $newfile $wallp
}

setup_l() {
flist=($storage/*.jpg)
randwp=${flist[$RANDOM % ${#flist[@]}]}
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 3" "   There are ${#flist[@]} files in $storage \n\n  Selected a random file: $randwp"; fi
ln -s $randwp $wallp
}

setup() {
if [ -e $wallp ]; then
	if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 4" "    Remove Symbolic link $wallp"; fi
	rm $wallp
fi
if [ $running == "ONLINE" ]; then
	if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 5" "    Scanning for Duplicates"; fdupes -f -d -I $storage ; else fdupes -f -d -q -I $storage > /dev/null; fi
fi
if [ $running == "LOCAL" ]; then
    if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 6" "   LOCAL Wallpaper Active"; fi
    setup_l

 elif [ $running == "ONLINE" ]; then
    if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 7" "   ONLINE Wallpaper Active"; fi
    setup_r
  else
    setup_l
    if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 8" "   Showing Favorites Wallpaper from: $randwp"; fi
    if [[ -e $wallp ]]; then
	rm $wallp
    fi
    ln -s $randwp $wallp
fi
$setwp
if [[ $arg -eq 1 ]]; then
    if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 9" "   New Wallpaper set "; fi
    exit 0
       if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 10" "  You Should NOT get this Message ! "; fi
fi
}

savefav() {
realwp=$(realpath $wallp)
favfile=$(realpath $wallp | rev | cut -d'/' -f1 | rev)
if [ ! -f "$storage/fav/$favfile" ]; then
   if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 11" "   New Wallpaper set \n  Saving \n    $realwp \n  to \n  $storage/fav/$favfile"; fi
cp $realwp $storage/fav/
else
   if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 12" "    Reeds in je favorieten "; fi
fi
}

if [ ! -d $(xdg-user-dir PICTURES)/Wallpapers/$resolution/fav ]; then
   if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 13" "    $storage/fav doesn't exist creating it"; fi
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
exit 1
fi

if [[ $1 -eq 4 ]]; then
notify-send -t 10000 -i image "Wallpaper.sh" "\n\n  QUIT Wallpaper changer  \n"
ps ax | grep wallpaper.sh | grep -E [0-9] -m1 | awk '{print $1}' | xargs kill
exit 0
fi

if [[ $1 -eq 3 ]]; then
realwp=$(realpath $wallp)
rm $realwp
rm $wallp
   if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 14" "   Deleted that ugly Wallpaper: $realwp"; fi
fi

if [[ $1 -eq 2 && $running != "FAV" ]]; then
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 15" "   Going to FAV"; fi
savefav

exit 0
elif [[ $1 -eq 2 ]]; then
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 16" "   Your already Running Favorite Wallpapers "; fi
exit 0
fi
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 17" "SESSION = $DESKTOP_SESSION "; fi
while [[ $DESKTOP_SESSION == compiz || $DESKTOP_SESSION == *"penbox"* ]] && [[ $1 -eq 0 ]]; do
setup
if [ $debug -eq "1" ]; then notify-send -t $dbtime -i image "Wallpaper -=DEBUG=- 18" "    Sleeping $timer"; fi
sleep $timer
done

setup
exit 0
