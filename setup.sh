#!/usr/bin/env bash

# Install the puppetlabs repo unless it's already there.
if [ ! -s /etc/yum.repos.d/puppetlabs.repo ] ; then
    yum install -y \
        https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
fi

# Install puppet if not installed
type puppet &>/dev/null || yum install -y puppet

# Look for needed, not-present modules and install each one.
for module in elasticsearch-{elasticsearch,logstash} \
              puppetlabs-java \
              puppetlabs-apache \
              lesaux-kibana4 ; do
    if [ ! -d /etc/puppet/modules/${module##*-} ]; then
        puppet module install $module
    fi
done
