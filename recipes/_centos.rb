include_recipe 'yum-ius'
include_recipe 'yum-epel'
include_recipe 'yum-osuosl'
include_recipe 'postgresql::client' # needed for libpqxx-devel

# Install gdal package
package "gdal"

%w{python27 python27-devel}.each do |pkg|
  package pkg
end
