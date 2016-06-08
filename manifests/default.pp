# Elasticsearch
class { 'elasticsearch':
  autoupgrade  => true,
  java_install => true,
  manage_repo  => true,
  repo_version => '2.x',
  config       => {
    'cluster' => {
      'name' => 'vagrant_elasticsearch',
    },
    'index' =>  {
      'number_of_replicas' => '0',
      'number_of_shards'   => '2',
    },
    'network' =>  {
      'host'  => '0.0.0.0',
    },
  },
}

Elasticsearch::Instance { before => Class['kibana4'] }
elasticsearch::instance { 'es-01': }

Elasticsearch::Plugin { instances => 'es-01' }
elasticsearch::plugin{
  'royrusso/elasticsearch-HQ':
    module_dir => 'HQ';
  'lmenezes/elasticsearch-kopf':
    module_dir => 'kopf';
  'karmi/elasticsearch-paramedic':
    module_dir => 'paramedic';
}

# Logstash
class { 'logstash':
  # autoupgrade => true,
  ensure        => 'present',
  manage_repo   => true,
  repo_version  => '2.3',
  require       => Class['elasticsearch'],
}

logstash::configfile { 'sample_logs ':
  require => Elasticsearch::Instance['es-01'],
  content => template('sample.conf.erb'),
}

# Kibana
include kibana4

# Apache
class { 'apache':
  logroot_mode => '744',
  before       => [
    Class['logstash'],
  ],
}
