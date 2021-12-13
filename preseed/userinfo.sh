#!/bin/sh
echo > /dev/pts/0
echo " Welcome Read below and follow instructions to continue" > /dev/pts/0
echo > /dev/pts/0
echo "-------------------------------------" > /dev/pts/0
echo "| LUKS2 Crypt password = r00tme123  |" > /dev/pts/0
echo "|                                   |" > /dev/pts/0
echo "| Username = user                   |" > /dev/pts/0
echo "| Password = user123                |" > /dev/pts/0
echo "-------------------------------------" > /dev/pts/0
echo > /dev/pts/0
echo " After installation is finished First login tty2 to Finalize package installation!!." > /dev/pts/0
echo " If you understand " > /dev/pts/0
echo " And have written this information down!!" > /dev/pts/0
echo > /dev/pts/0
echo "Oke Then open tty2 ( alt+f2 ). and type ~ # touch /tmp/agree" > /dev/pts/0
while [ ! -f /tmp/agree ]; do
sleep 10
echo > /dev/pts/0
echo "Still waiting. Press ctrl+c if you missed instructions" > /dev/pts/0
done
exit 0
