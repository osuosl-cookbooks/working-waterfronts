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

pg = Chef::EncryptedDataBagItem.load('whats_fresh', 'pgsql')

if node['whats_fresh']['make_db']
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
      runuser -l postgres -c 'psql whats_fresh -c "CREATE EXTENSION IF NOT EXISTS postgis;"'
    EOH
  end
end

include_recipe "whats-fresh::_monkey_patch"

%w[ shared static media config ].each do |path|
  directory "#{node['whats_fresh']['application_dir']}/#{path}" do
    owner node['whats_fresh']['venv_owner']
    group node['whats_fresh']['venv_group']

    mode '0755'
    recursive true
  end
end

template "#{node['whats_fresh']['application_dir']}/config/config.yml" do
  source "config.yml.erb"
  owner node['whats_fresh']['venv_owner']
  group node['whats_fresh']['venv_group']

  variables({
    :host     => pg['host'],
    :port     => pg['port'],
    :username => pg['user'],
    :password => pg['pass']
  })
end

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

  gunicorn do
    app_module :django
    port 8080
    loglevel "debug"
  end

  nginx_load_balancer do
    application_port 8080
    hosts ['localhost']
  end
end

template "/etc/nginx/sites-available/whats_fresh.conf" do
  source "whats_fresh.conf.erb"
  owner "root"
  group "root"
end

file "/etc/nginx/conf.d/default.conf" do
  action :delete
end

execute "#{::File.join(node['whats_fresh']['application_dir'], "shared", "env", "bin", "python")} #{::File.join(node['whats_fresh']['application_dir'], "current", "whats_fresh", "manage.py")} collectstatic --noi" do
  user node['whats_fresh']['venv_owner']
  group node['whats_fresh']['venv_group']
end

service "nginx" do
  action :restart
end