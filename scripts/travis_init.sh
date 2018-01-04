#!/bin/bash
sudo apt-get update -q
sudo apt-get install -qy virtualbox virtualbox-dkms linux-headers-generic linux-headers-$(uname -r)
wget https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.deb
sudo dpkg -i vagrant_2.0.1_x86_64.deb
sudo vagrant plugin install vagrant-plugin-bundler
