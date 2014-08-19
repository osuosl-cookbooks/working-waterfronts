include_recipe 'yum-ius'
include_recipe 'yum-epel'

include_recipe 'postgresql::client' # needed for libpqxx-devel

# Install gdal package
bash "install gdal" do
  code <<-EOH
    mkdir /tmp/gdal-rpms
    cd /tmp/gdal-rpms
    wget #{node['whats_fresh']['manual_install_list']}
    yum localinstall --nogpgcheck -y *.rpm
    cd ..
    rm -rf /tmp/gdal-rpms
  EOH
end

%w{python27 python27-devel}.each do |pkg|
  package pkg
end
