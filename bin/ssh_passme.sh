#!/bin/bash

# ssh-keygen -R $ip
ip=$1
if [[ ! -d $HOME/.ssh ]]; then
mkdir -p $HOME/.ssh
cd ~/.ssh
fi
if [[ ! -f $HOME/.ssh/id_rsa ]]; then
ssh-keygen -t rsa
fi

## need some work to code for multiple ip adresses
multi() {
ips=( "$@" )
echo "############################################"
echo "# ${ips[@]} "
echo "############################################"
i=0
while [ $i -lt ${#ips[@]} ]; do
echo " Creating directory .ssh in ${ips[$i]} "
ssh ${ips[$i]} mkdir -p .ssh
cat $HOME/.ssh/id_rsa.pub | ssh ${ips[$i]} 'cat >> .ssh/authorized_keys'
(( i++ ))
done
}

read -p "   SSH username: " user

if [ -z $ip ]; then
read -p "   Enter Server IP: " ip
else
echo "   ip is: $ip"
fi

echo "   Copy ID to Server $ip"
ssh-copy-id -i ~/.ssh/id_rsa.pub $user@$ip

echo "   Finished"
