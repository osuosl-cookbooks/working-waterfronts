name             'whats-fresh'
maintainer       'Oregon State University'
maintainer_email 'systems@osuosl.org'
license          'Apache 2.0'
description      "Installs/Configures What's Fresh dependencies"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'build-essential'
depends          'database'
depends          'geos'
depends          'git'
depends          'magic_shell'
depends          'postgis'
depends          'postgresql'
depends          'python'
depends          'yum'
depends          'yum-epel'
depends          'yum-ius'
