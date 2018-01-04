VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provision "shell", path: "scripts/init.sh"
  config.vm.provision "shell", path: "scripts/puppet_install.sh"

  # Enable the Puppet provisioner, with will look in manifests
  config.vm.provision "puppet" do |puppet|
    puppet.environment_path = "environments"
    puppet.environment = "development"
    puppet.manifests_path = "environments/development/manifests"
    puppet.manifest_file = "init.pp"
    puppet.module_path = "modules"
  end

  config.vm.network "forwarded_port", guest: 80, host: 8080, protocol: "tcp"

  config.vm.provision "shell", inline: "echo Enjoy your new vbox."
end
