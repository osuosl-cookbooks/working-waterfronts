include_recipe 'yum-ius'
include_recipe 'yum-epel'

bash "install Postgres repos" do
  code <<-EOH
    yum -y localinstall http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm
  EOH
end

yum_repository "pgsql" do
  description "Postgresql Repository 9.3"
  baseurl "http://yum.postgresql.org/9.3/redhat/rhel-$releasever-$basearch"
  gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-93"
  action :create
end

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
