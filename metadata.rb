name             'whats-fresh'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache 2.0'
description      "Installs/Configures What's Fresh dependencies"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'postgresql'
depends          'python'
depends          'yum-ius'
depends          'postgis'
depends          'geos'
depends          'magic_shell'
depends          'database'
depends          'yum-epel'
depends          'git'
