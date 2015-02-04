default['working_waterfronts']['application_dir'] = '/opt/working_waterfronts'
default['working_waterfronts']['venv_owner'] = 'root'
default['working_waterfronts']['venv_group'] = 'root'
default['working_waterfronts']['databag'] = 'pgsql'
default['postgis']['template_name'] = nil
default['working_waterfronts']['make_db'] = false

default['working_waterfronts']['debug'] = false
default['working_waterfronts']['git_branch'] = 'develop'
default['working_waterfronts']['repository'] = 'https://github.com/osu-cass/working-waterfronts-api'

default['working_waterfronts']['server_name'] = node['fqdn']
default['working_waterfronts']['gunicorn_port'] = 8000
default['working_waterfronts']['subdirectory'] = '' # add trailing slash if in a subdir

override['python']['pip_location'] = "#{node['python']['prefix_dir']}/bin/pip2.7"

if platform_family?('rhel')
  override['postgresql']['enable_pgdg_yum'] = true
  override['postgresql']['version'] = '9.3'
  override['postgresql']['server']['packages'] = %W(
    postgresql#{node['postgresql']['version'].gsub('.', '')}-server)
  override['postgresql']['client']['packages'] = %W(
    postgresql#{node['postgresql']['version'].gsub('.', '')}-devel
    libpqxx-devel)
  override['postgresql']['server']['service_name'] = 'postgresql-9.3'
end

default['postgis']['package'] = 'postgis2_93'

override['build-essential']['compile_time'] = true
