#
# Cookbook Name:: working-waterfronts
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

include_recipe 'working-waterfronts::_centos' if platform_family?('rhel')
include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'python'
include_recipe 'postgresql::client'
include_recipe 'database::postgresql'
include_recipe 'postgis'
include_recipe 'osl-nginx'

magic_shell_environment 'PATH' do
  value "/usr/pgsql-9.3/bin:$PATH"
end

pg = Chef::EncryptedDataBagItem.load('working_waterfronts',
                                     node['working_waterfronts']['databag'])

if node['working_waterfronts']['make_db']
  postgresql_connection_info = {
    host: pg['host'],
    port: pg['port'],
    username: pg['root_user'],
    password: pg['root_pass']
  }

  # Create Postgres database
  database pg['database_name'] do
    connection postgresql_connection_info
    provider Chef::Provider::Database::Postgresql
    action :create
  end

  # Add Postgis extension to database
  bash 'create Postgis extension in database' do
    code <<-EOH
      runuser -l postgres -c 'psql #{pg['database_name']} -c "CREATE EXTENSION IF NOT EXISTS postgis;"'
    EOH
  end

  postgresql_database_user pg['user'] do
    connection postgresql_connection_info
    database_name pg['database_name']
    password pg['pass']
    privileges [:all]
    action :create
  end
end

%w(shared static media config).each do |path|
  directory "#{node['working_waterfronts']['application_dir']}/#{path}" do
    owner node['working_waterfronts']['venv_owner']
    group node['working_waterfronts']['venv_group']
    mode 0755
    recursive true
  end
end

template "#{node['working_waterfronts']['application_dir']}/config/config.yml" do
  source 'config.yml.erb'
  owner node['working_waterfronts']['venv_owner']
  group node['working_waterfronts']['venv_group']
  variables(
    host: pg['host'],
    port: pg['port'],
    username: pg['user'],
    password: pg['pass'],
    db_name: pg['database_name'],
    secret_key: pg['secret_key']
  )
end

application 'working_waterfronts' do
  path node['working_waterfronts']['application_dir']
  owner node['working_waterfronts']['venv_owner']
  group node['working_waterfronts']['venv_group']
  repository node['working_waterfronts']['repository']
  revision node['working_waterfronts']['git_branch']
  migrate true
  rollback_on_error false

  django do
    requirements 'requirements.txt'
    debug node['working_waterfronts']['debug']
  end

  gunicorn do
    app_module :django
    autostart true
    port node['working_waterfronts']['gunicorn_port']
    loglevel 'debug'
  end
end

nginx_app 'working_waterfronts' do
  template 'working_waterfronts.conf.erb'
  cookbook 'working-waterfronts'
end

node.default['nginx']['default_site_enabled'] = false

# Collect static files (css, js, etc)
python_path = File.join(node['working_waterfronts']['application_dir'],
                        'shared', 'env', 'bin', 'python')
manage_py_path = File.join(node['working_waterfronts']['application_dir'],
                           'current',
                           node['working_waterfronts']['subdirectory'],
                           'manage.py')

execute 'collect static files' do
  command "#{python_path} #{manage_py_path} collectstatic --noi"
  user node['working_waterfronts']['venv_owner']
  group node['working_waterfronts']['venv_group']
end

selinux_policy_boolean 'httpd_can_network_connect' do
  value true
  notifies :start, 'service[nginx]', :immediate
end
