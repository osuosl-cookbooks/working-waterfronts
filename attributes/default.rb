default['whats_fresh']['virtualenv_dir'] = "/home/vagrant/venv"
default['postgis']['template_name'] = nil
default['whats_fresh']['make_db'] = false

if platform_family?("rhel")
  override['postgresql']['enable_pgdg_yum'] = true
  override['postgresql']['version'] = '9.3'
  override['postgresql']['client']['packages'] = %W[
     postgresql#{node['postgresql']['version'].gsub('.','')}-devel
     libpqxx-devel]
end

default['postgis']['package'] = 'postgis2_93'

override['build-essential']['compile_time'] = true
