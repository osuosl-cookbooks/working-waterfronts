#
# Cookbook Name:: whats-fresh
# Recipe:: default
#
# Copyright 2014, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform_family?("rhel")
  include_recipe "whats-fresh::_centos"
end

include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'python'
include_recipe 'postgresql::client'
include_recipe 'database::postgresql'
include_recipe 'postgis'


magic_shell_environment 'PATH' do
  value '/usr/pgsql-9.3/bin:$PATH'
end

if node['whats_fresh']['make_db']
  pg = Chef::EncryptedDataBagItem.load('whats_fresh', 'pgsql')

  postgresql_connection_info = {
    :host     => pg['host'],
    :port     => pg['port'],
    :username => pg['user'],
    :password => pg['pass']
  }

  # Create Postgres database
  database 'whats_fresh' do
    connection postgresql_connection_info
    provider   Chef::Provider::Database::Postgresql
    action     :create
  end

  # Add Postgis extension to database
  bash "create Postgis extension in whats_fresh database" do
    code <<-EOH
      runuser -l postgres -c 'psql whats_fresh -c "CREATE EXTENSION postgis;"'
    EOH
  end
end

include_recipe "whats-fresh::_monkey_patch"

application 'whats_fresh' do
  path       node['whats_fresh']['application_dir']
  owner      node['whats_fresh']['venv_owner']
  group      node['whats_fresh']['venv_group']
  repository 'https://github.com/osu-cass/whats-fresh-api'
  revision   node['whats_fresh']['git_branch']
  migrate    true

  django do
    requirements      'requirements.txt'
    debug             node['whats_fresh']['debug']
  end
end
