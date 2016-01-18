# Run this with `sudo puppet apply <scriptname>.pp`.

$sudo_user = 'insites'
$weak_user = 'clusmon'
$common_group = 'common'
$project_root = "/home/${sudo_user}/cluster-monitor"


### define defaults ###
File {
  ensure => 'file',
  owner => "${sudo_user}",
  group => "${common_group}",
}
Package {
  ensure => 'installed',
  require => [ Exec['aptitude update'] ],
}
Exec {
  path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
}
Service {
  hasrestart => false,
}


### user/host management ###
host { 'cluster-monitor': }
exec { "groupadd ${common_group}":
  user => 'root',
  unless => "grep \"^${common_group}:\" /etc/group",
}
user { "${sudo_user}":
  ensure => 'present',
  groups => ['sudo', "${common_group}"],
  require => Exec["groupadd ${common_group}"],
}
user { "${weak_user}":
  ensure => 'present',
  groups => ["${common_group}"],
  require => Exec["groupadd ${common_group}"],
}
# puppet doesn't do home directory well
# http://docs.puppetlabs.com/references/latest/type.html#user-attribute-home
file { "/home/${weak_user}":
  ensure => 'directory',
  recurse => true,
  owner => "${weak_user}",
  group => "${common_group}",
  require => User["${weak_user}"],
}


### package management ###
file { 'sources.list':
  path   => '/etc/apt/sources.list',
  source => "${project_root}/configs/sources.list",
  mode   => '0644',
}
## Needed because we're installing our own unsigned packages and unable
## to have install_options attributes in this old version of puppet.
#file { 'apt.conf':
#  path => '/etc/apt/apt.conf',
#  content => 'APT::Get::Force-Yes "true";',
#}
exec { 'aptitude update':
  user => 'root',
  subscribe => File['sources.list'],
}


### ssh stuff ###
package { 'openssh-server': }
file { 'sshd_config':
  path => '/etc/ssh/sshd_config',
  source => "${project_root}/configs/sshd_config",
  mode => '0644',
  require => Package['openssh-server'],
}
service { 'sshd':
  name => 'ssh',
  ensure => 'running',
  enable => 'true',
  start => '/usr/sbin/service ssh start',
  stop => '/usr/sbin/service ssh stop',
  status => '/usr/sbin/service ssh status',
  subscribe => File['sshd_config'],
}


### apache stuff ###
package { 'apache2': }
package { 'libapache2-mod-wsgi': }
file { 'sites-available/default':
  path => '/etc/apache2/sites-available/default',
  source => "${project_root}/configs/graphite-vhost.conf",
  mode => '0644',
  require => Package['apache2'],
}
# http://code.google.com/p/modwsgi/wiki/ConfigurationDirectives#WSGISocketPrefix
file { 'run/wsgi':
  ensure => 'directory',
  path => '/etc/apache2/run',
  recurse => true,
  owner => 'www-data',
  group => 'www-data',
  ignore => "*.sock",
  require => Package['apache2'],
}
# https://github.com/colinbjohnson/graphite-apache-auth
file { 'auth.wsgi':
  path => '/opt/graphite/conf/auth.wsgi',
  source => "${project_root}/configs/auth.wsgi",
  mode => '0644',
  require => File['/opt/graphite'],
}
file { 'key.pem':
  path => '/etc/apache2/key.pem',
  source => "${project_root}/configs/key.pem",
  mode => '0640',
  owner => "${sudo_user}",
  group => 'www-data',
  require => Package['apache2'],
}
file { 'cert.pem':
  path => '/etc/apache2/cert.pem',
  source => "${project_root}/configs/cert.pem",
  mode => '0644',
  owner => "${sudo_user}",
  group => 'www-data',
  require => Package['apache2'],
}
exec { 'a2enmod':
  user => 'root',
  command => 'a2enmod wsgi ssl rewrite',
  require => [
    Package['apache2'],
    Package['libapache2-mod-wsgi'],
  ]
}
service { 'apache2':
  ensure => 'running',
  enable => 'true',
  start => '/usr/sbin/service apache2 start',
  stop => '/usr/sbin/service apache2 stop',
  status => '/usr/sbin/service apache2 status',
  #restart => '/usr/sbin/service apache2 stop; sleep 15; /usr/sbin/service apache2 start',
  subscribe => [
    Package['apache2'],
    Package['libapache2-mod-wsgi'],
    File['sites-available/default'],
    File['run/wsgi'],
    File['auth.wsgi'],
    File['key.pem'],
    File['cert.pem'],
    Exec['a2enmod'],
    File['local_settings.py'],
    File['initial_data.json'],
    Exec['syncdb'],
    Exec['carbon-cache.py'],
  ],
}


### statsd stuff ###
package { 'nodejs': }
file { 'statsd_config.js':
  path => "${project_root}/configs/statsd_config.js",
  group => "${common_group}",
  mode => '0644',
}
file { 'statsd_service.sh':
  path => "${project_root}/scripts/statsd_service.sh",
  group => "${common_group}",
  mode => '0755',
}
service { 'statsd_service.sh':
  ensure => 'running',
  start => "/usr/bin/sudo -u ${weak_user} ${project_root}/scripts/statsd_service.sh start",
  stop => "/usr/bin/sudo -u ${weak_user} ${project_root}/scripts/statsd_service.sh stop",
  status => "/usr/bin/sudo -u ${weak_user} ${project_root}/scripts/statsd_service.sh status",
  require => [
    Package['nodejs'],
    File['statsd_config.js'],
    File['statsd_service.sh'],
    File["/home/${weak_user}"],
  ],
}


### carbon/graphite stuff ###
package { 'python2.7-dev': }
package { 'python-cairo': }
package { 'python-pip':
  require => Package['python2.7-dev'],
}
package { 'graphite-web':
  name => 'graphite-web==0.9.12',
  provider => 'pip',
  require  => Package['python-pip'],
}
package { 'carbon':
  name => 'carbon==0.9.12',
  provider => 'pip',
  require  => Package['python-pip'],
}
package { 'whisper':
  name => 'whisper==0.9.12',
  provider => 'pip',
  require  => Package['python-pip'],
}
package { 'django':
  name => 'django==1.5',
  provider => 'pip',
  require  => Package['python-pip'],
}
package { 'django-tagging':
  name => 'django-tagging==0.3.2',
  provider => 'pip',
  require  => Package['python-pip'],
}
# need older version of twisted; http://stackoverflow.com/questions/19894708
package { 'Twisted':
  name => 'Twisted==13',
  provider => 'pip',
  require  => Package['python-pip'],
}
file { '/opt/graphite':
  ensure => 'directory',
  recurse => true,
  owner => "${sudo_user}",
  group => "${common_group}",
  require => Package['graphite-web'],
}
file { '/opt/graphite/storage':
  ensure => 'directory',
  recurse => true,
  owner => 'www-data',
  group => "${common_group}",
  mode => '0664',
  require => [
    File['/opt/graphite'],
    Package['apache2']
  ],
}
# required for initial_data.json since puppet doesn't create dirs if needed
file { 'fixtures':
  ensure => 'directory',
  recurse => true,
  path => '/opt/graphite/webapp/graphite/fixtures',
  mode => '0664',
  require => Package['graphite-web'],
}
# contains login info needed for initial syncdb
file { 'initial_data.json':
  path => '/opt/graphite/webapp/graphite/fixtures/initial_data.json',
  source => "${project_root}/configs/initial_data.json",
  mode => '0644',
  require => File['fixtures'],
}
file { 'local_settings.py':
  path => '/opt/graphite/webapp/graphite/local_settings.py',
  source => "${project_root}/configs/local_settings.py",
  mode => '0644',
  require => Package['graphite-web'],
}
file { 'carbon.conf':
  path => '/opt/graphite/conf/carbon.conf',
  source => "${project_root}/configs/carbon.conf",
  mode => '0644',
  require => [
    Package['graphite-web'],
    Package['carbon'],
  ],
}
file { 'storage-schemas.conf':
  path => '/opt/graphite/conf/storage-schemas.conf',
  source => "${project_root}/configs/storage-schemas.conf",
  mode => '0644',
  require => [
    Package['graphite-web'],
    Package['carbon'],
  ],
}
file { 'storage-aggregation.conf':
  path => '/opt/graphite/conf/storage-aggregation.conf',
  source => "${project_root}/configs/storage-aggregation.conf",
  mode => '0644',
  require => [
    Package['graphite-web'],
    Package['carbon'],
  ],
}
#file { 'relay-rules.conf':
#  path    => '/opt/graphite/conf/relay-rules.conf',
#  source => "${project_root}/configs/relay-rules.conf",
#  require => [
#    Package['graphite-web'],
#    Package['carbon'],
#  ],
#}
#file { 'aggregation-rules.conf':
#  path    => '/opt/graphite/conf/aggregation-rules.conf',
#  source => "${project_root}/configs/aggregation-rules.conf",
#  require => [
#    Package['graphite-web'],
#    Package['carbon'],
#  ],
#}
file { 'graphite.wsgi':
  path => '/opt/graphite/conf/graphite.wsgi',
  source => "${project_root}/configs/graphite.wsgi",
  require => Package['graphite-web'],
}
file { 'graphite.db':
  path => '/opt/graphite/storage/graphite.db',
  owner => 'www-data',
  group => "${common_group}",
  mode => '0664',
  require => [
    Package['graphite-web'],
    File['/opt/graphite/storage'],
    #Service['apache2'],
  ]
}
exec { 'syncdb':
  cwd => '/opt/graphite/webapp/graphite',
  command => "python manage.py syncdb --noinput",
  user => "${weak_user}",
  refreshonly => true,
  require => [
    User["${weak_user}"],
    Package['graphite-web'],
    Package['whisper'],
    File['graphite.db'],
    #Exec['carbon-cache.py'],
    #Exec['restart-carbon'],
    #Service['apache2'],
  ],
  subscribe => [
    File['local_settings.py'],
    File['initial_data.json'],
  ],
}
# For whatever reason, puppet does not want to run this if i set it up like
# a service.
exec { 'carbon-cache.py':
  user => "${weak_user}",
  command => 'python /opt/graphite/bin/carbon-cache.py start',
  unless => 'python /opt/graphite/bin/carbon-cache.py status',
  require => [
    User["${weak_user}"],
    File['carbon.conf'],
    Package['graphite-web'],
    Exec['syncdb'],
  ],
}


### collectd stuff ###
package { 'collectd': }
file { 'collectd.conf':
  path => '/etc/collectd/collectd.conf',
  source => "${project_root}/configs/collectd.conf",
  mode => '0644',
  require => Package['collectd'],
}
service { 'collectd':
  ensure => 'running',
  enable => 'true',
  start => '/usr/sbin/service collectd start',
  stop => '/usr/sbin/service collectd stop',
  status => '/usr/sbin/service collectd status',
  subscribe => File['collectd.conf'],
}


### puppet stuff ###
service { 'cron' :
  ensure => 'running',
  enable => 'true',
  start => '/usr/sbin/service cron start',
  stop => '/usr/sbin/service cron stop',
  status => '/usr/sbin/service cron status',
}
# run once per hour
cron { 'puppet':
  command => "puppet apply ${project_root}/configure.pp",
  minute => 0,
  hour => absent,
  monthday => absent,
  month => absent,
  weekday => absent,
  user => 'root',
}
# run on boot
file { 'rc.local':
  path => '/etc/rc.local',
  source => "${project_root}/configs/rc.local",
  mode => '0755',
}
# doing this doesn't seem to work:
#file { '/etc/default/puppet':
#  source => "${project_root}/configs/default_puppet",
#  mode => '0644',
#}
#service { 'puppet':
#  ensure => 'running',
#  enable => 'true',
#  start => '/usr/sbin/service puppet start',
#  stop => '/usr/sbin/service puppet stop',
#  status => '/usr/sbin/service puppet status',
#}


### iptables stuff ###
file { 'iptables.rules':
  path => '/etc/iptables.rules',
  source => "${project_root}/configs/iptables.rules",
  mode => '0644',
}
# needed to start iptables on boot
file { 'if-pre-up.d/iptables':
  path => '/etc/network/if-pre-up.d/iptables',
  source => "${project_root}/configs/if-pre-up.d_iptables",
  mode => '0755',
}


### workaround for bug https://github.com/gdbtek/setup-graphite/issues/2 ###
exec { 'fix_db_lock.sh':
  user => 'root',
  command => "${project_root}/scripts/fix_db_lock.sh",
  require => Service['apache2'],
}
