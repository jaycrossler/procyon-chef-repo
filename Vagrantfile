# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Add this to ~/.bash_login:
# export AWS_ACCESS_KEY_ID=XXXX
# export AWS_SECRET_ACCESS_KEY=XXXXX
# export AWS_AMI=ami-xxxxxxxx
# export DEPLOY_TO_AWS=true


host_cache_path = File.expand_path("../.cache", __FILE__)
guest_cache_path = "/tmp/vagrant-cache"

# ensure the cache path exists
FileUtils.mkdir(host_cache_path) unless File.exist?(host_cache_path)

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.berkshelf.enabled = true  

  if ENV['DEPLOY_TO_AWS']
    config.vm.box = "ubuntu_aws"
    config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    config.vm.provider :aws do |aws, override|
      aws.instance_type = "t1.micro"
      aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
      aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      aws.keypair_name = "macbookair-aws-ssh"
      aws.security_groups = ["mywebserver"]
      aws.ami = ENV['AWS_AMI']
      aws.tags = {
        'Name' => 'Procyon',
        'Maturity' => 'Development'
      }
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = "~/.ssh/macbookair-aws-ssh.pem"
    end
  else
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

  config.vm.network :public_network

  config.vm.provision :shell, :path => "scripts/install_rvm.sh",  :args => "stable"
  config.vm.provision :shell, :path => "scripts/install_ruby.sh", :args => "1.9.3"
  config.vm.provision :shell, :path => "scripts/install_PIL.sh"
  config.vm.provision :shell, :inline => "gem install chef --version 11.6.0 --no-rdoc --no-ri --conservative"

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "apt"
    chef.add_recipe "python"
    chef.add_recipe "git"
    chef.add_recipe "procyon"
  end

end
