default['whats_fresh']['virtualenv_dir'] = "/home/vagrant/venv"
default['postgis']['template_name'] = nil

if platform_family?("rhel")
  default['whats_fresh']['manual_install_list'] = "https://staff.osuosl.org/~tschuy/noarch/gdal-doc-1.9.2-4.el6.noarch.rpm https://staff.osuosl.org/~tschuy/noarch/gdal-javadoc-1.9.2-4.el6.noarch.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-1.9.2-4.el6.x86_64.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-devel-1.9.2-4.el6.x86_64.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-java-1.9.2-4.el6.x86_64.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-libs-1.9.2-4.el6.x86_64.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-perl-1.9.2-4.el6.x86_64.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-python-1.9.2-4.el6.x86_64.rpm http://staff.osuosl.org/~tschuy/x86_64/gdal-ruby-1.9.2-4.el6.x86_64.rpm"
  default['whats_fresh']['package_list'] = %w{postgresql93-server postgresql93-devel}
else
  default['whats_fresh']['package_list'] = nil
end

default['postgis']['package'] = 'postgis2_93'
