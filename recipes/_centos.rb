include_recipe 'yum-ius'
include_recipe 'yum-epel'

include_recipe 'postgresql::client' # needed for libpqxx-devel

yum_repository "osl" do
  repositoryid  "osl"
  description "OSL repo $releasever - $basearch"
  url "http://ftp.osuosl.org/pub/osl/repos/yum/$releasever/$basearch"
  gpgkey "http://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-osuosl"
  action :add
end

# Install gdal package
package "gdal"

%w{python27 python27-devel}.each do |pkg|
  package pkg
end
