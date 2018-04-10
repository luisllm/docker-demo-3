#!/bin/bash

# volume setup
vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then
	  # wait for the device to be attached
	    DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
	      DEVICEEXISTS=''
	        while [[ -z $DEVICEEXISTS ]]; do
			    echo "checking $DEVICENAME"
			        DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
				    if [[ $DEVICEEXISTS != "1" ]]; then
					          sleep 15
						      fi
						        done
							  pvcreate ${DEVICE}
							    vgcreate data ${DEVICE}
							      lvcreate --name volume1 -l 100%FREE data
							        mkfs.ext4 /dev/data/volume1
							fi
mkdir -p /var/lib/jenkins
echo '/dev/data/volume1 /var/lib/jenkins ext4 defaults 0 0' >> /etc/fstab
mount /var/lib/jenkins

# install jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list
apt-get update
apt-get install -y jenkins unzip

# install docker
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# enable docker and add perms
usermod -G docker jenkins
systemctl enable docker
service docker start
service jenkins restart

# install pip
wget -q https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python3 get-pip.py
rm -f get-pip.py

# install awscli
pip install awscli

# install terraform
cd /usr/local/bin
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# clean up
apt-get clean
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
