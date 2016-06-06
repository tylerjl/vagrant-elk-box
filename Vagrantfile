# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure 2 do |config|

  config.vm.box = 'centos/7'
  config.vm.network :forwarded_port, guest: 5601, host: 5601
  config.vm.network :forwarded_port, guest: 9200, host: 9200
  config.vm.network :forwarded_port, guest: 9300, host: 9300
  config.vm.network :forwarded_port, guest: 80,   host: 8080

  config.vm.synced_folder 'templates',
    '/tmp/vagrant-puppet/templates'

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      'modifyvm', :id,
      '--cpus', '2',
      '--memory', '2048'
    ]
  end

  config.vm.provision 'shell',
    path: 'setup.sh'
  config.vm.provision 'puppet',
    manifests_path: 'manifests',
    manifest_file: 'default.pp',
    options: ['--templatedir', '/tmp/vagrant-puppet/templates']
end
