
$php_version = '7.0'

class { 'apache':
  server_tokens    => 'Prod',
  server_signature => 'Off',
  default_vhost    => false,
  mpm_module       => false,
}

apache::vhost { 'localhost':
  port           => 80,
  docroot        => '/var/www/html',
  docroot_owner  => 'www-data',
  docroot_group  => 'www-data',
  directoryindex => 'index.php',
  override       => 'All',
  options        => ['-Indexes', '+ExecCGI']
}

$default_modules = ['rewrite', 'actions', 'ssl', 'worker']
$default_modules.each |String $module| {
  class { "apache::mod::${module}": }
}


# Use fcgid run php
class { 'apache::mod::fcgid':
  options => {
    'AddHandler'          => 'fcgid-script .php',
    'FcgidWrapper'        => '/usr/local/bin/php-wrapper .php',
    'FcgidConnectTimeout' => 20,
  }
}


file { '/usr/local/bin/php-wrapper':
  ensure  => file,
  owner   => root,
  group   => root,
  mode    => '0755',
  content => "#!/bin/bash\nPHP_FCGI_MAX_REQUESTS=10000\nexport PHP_FCGI_MAX_REQUESTS\nexec /usr/bin/php-cgi";
}

# add 'ppa:ondrej/php' repository
$dependency_apt = ['locales', 'software-properties-common', 'python-software-properties']
package { $dependency_apt: ensure => present }

exec { 'install-ppa':
  provider    => 'shell',
  environment => ['LANG=en_US.UTF-8'],
  path        => '/bin:/usr/sbin:/usr/bin:/sbin',
  command     => "/usr/sbin/locale-gen en_US.UTF-8 && add-apt-repository -y ppa:ondrej/php && apt-get update",
  user        => 'root',
  unless      => 'apt-cache policy | grep ondrej/php',
  require     => Package[$dependency_apt]
}

$php_package_list = [ "php${php_version}",
                      "libapache2-mod-php${php_version}",
                      "php${php_version}-mysql",
                      "php${php_version}-cli",
                      "php${php_version}-cgi",
                      "php${php_version}-common",
                      "php${php_version}-mcrypt",
                      "php${php_version}-gd",
                      "php${php_version}-json",
                      "php${php_version}-bcmath",
                      "php${php_version}-mbstring",
                      "php${php_version}-xml",
                      "php${php_version}-xmlrpc",
                      "php${php_version}-zip",
                      "php${php_version}-soap",
                      "php${php_version}-sqlite3",
                      "php${php_version}-curl",
                      "php${php_version}-opcache",
                      "php${php_version}-readline",
                      'php-mongodb',
                      'php-memcached'
]

package { $php_package_list:
  ensure  => present,
  require => Exec['install-ppa'],
}


file { '/var/www/html/index.php':
  ensure  => present,
  content => '<?php phpinfo(); ?>',
}
