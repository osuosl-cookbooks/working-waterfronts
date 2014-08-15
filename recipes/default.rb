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

include_recipe 'git'
include_recipe 'python'
include_recipe "database::postgresql"

node['whats_fresh']['package_list'].each do |pkg|
  package pkg
end

include_recipe 'postgis'

venv_dir = node['whats_fresh']['virtualenv_dir']

python_virtualenv venv_dir do
  interpreter 'python2.7'
  owner "vagrant"
  group "vagrant"
  action :create
end

magic_shell_environment 'PATH' do
  value '/usr/pgsql-9.3/bin:$PATH'
end

pg = Chef::EncryptedDataBag.item('whats_fresh', 'pgsql')

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

