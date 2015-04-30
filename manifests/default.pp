define append_if_no_such_line($file, $line, $refreshonly = 'false') {
   exec { "/bin/echo '$line' >> '$file'":
      unless      => "/bin/grep -Fxqe '$line' '$file'",
      path        => "/bin",
      refreshonly => $refreshonly
   }
}

# Update APT Cache
class { 'apt':
  always_apt_update => true,
}

exec { 'apt-get update':
  before  => [ Class['logstash'] ],
  command => '/usr/bin/apt-get update -qq'
}

file { '/vagrant/elasticsearch':
  ensure => 'directory',
  group  => 'vagrant',
  owner  => 'vagrant',
}

# Java is required
class { 'java': }

# Elasticsearch
class { 'elasticsearch':
  manage_repo  => true,
  repo_version => '1.5',
}

elasticsearch::instance { 'es-01':
  config        => { # Configuration hash
  'cluster.name'                         => 'vagrant_elasticsearch',
  'index.number_of_replicas'             => '0',
  'index.number_of_shards'               => '1',
  'network.host'                         => '0.0.0.0',
  'discovery.zen.ping.multicast.enabled' => false,
  },
  init_defaults => { }, # Init defaults hash
  before        => Exec['start kibana']
}

elasticsearch::plugin{'royrusso/elasticsearch-HQ':
  module_dir => 'HQ',
  instances  => 'es-01'
}

# Logstash
class { 'logstash':
  # autoupgrade  => true,
  ensure       => 'present',
  manage_repo  => true,
  repo_version => '1.4',
  require      => [ Class['java'], Class['elasticsearch'] ],
}

logstash::configfile { 'sample_logs ':
  content => '
input {
  exec {
    interval => 5
    command  => "bash -c \'for x in `seq 1 $(((RANDOM%10)+1))` ; do echo {\"message\":\"Number is: $x\",\"number\":$x} ; done\'"
    codec    => "json_lines"
  }
}

filter {
  mutate {
    remove_field => "command"
  }
}

output {
  elasticsearch {
    cluster => "vagrant_elasticsearch"
    host    => "localhost"
  }
}
',
}

# Kibana
package { 'curl':
  ensure  => 'present',
  require => [ Class['apt'] ],
}

file { '/opt/kibana':
  ensure => 'directory',
  group  => 'vagrant',
  owner  => 'vagrant',
}

exec { 'download_kibana':
  command => '/usr/bin/curl -L https://download.elasticsearch.org/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz | /bin/tar xvz -C /opt/kibana --strip-components 1',
  require => [ Package['curl'], File['/opt/kibana'], Class['elasticsearch'] ],
  timeout => 1800
}

exec {'start kibana':
  command => '/bin/sleep 10 && /opt/kibana/bin/kibana & ',
  require => [ Exec['download_kibana']]
}
