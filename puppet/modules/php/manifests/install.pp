class php::install {
  define php::install::source {
    include php::params

    $version = $name

    $short_version = $version ? {
      /^5\.3/ => '53',
      /^5\.4/ => '54',
    }

    $url = "http://www.php.net/get/php-${version}.tar.gz/from/this/mirror"

    $configure = $version ? {
      /^5\.3/ => $php::params::configure_53,
      /^5\.4/ => $php::params::configure_54,
    }

    $xdebug = $version ? {
      /^5\.3/ => '/usr/local/php53/lib/php/extensions/no-debug-non-zts-20090626/xdebug.so',
      /^5\.4/ => '/usr/local/php54/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so',
    }

    if ! defined(Package['build-essential']) {
      package { 'build-essential':
        ensure => present,
      }
    }

    if ! defined(Package['autoconf']) {
      package { 'autoconf':
        ensure => present,
      }
    }

    if ! defined(Package['libxml2-dev']) {
      package { 'libxml2-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libpcre3-dev']) {
      package { 'libpcre3-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libbz2-dev']) {
      package { 'libbz2-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libcurl4-openssl-dev']) {
      package { 'libcurl4-openssl-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libjpeg-dev']) {
      package { 'libjpeg-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libpng12-dev']) {
      package { 'libpng12-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libxpm-dev']) {
      package { 'libxpm-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libfreetype6-dev']) {
      package { 'libfreetype6-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libmysqlclient-dev']) {
      package { 'libmysqlclient-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libt1-dev']) {
      package { 'libt1-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libgd2-xpm-dev']) {
      package { 'libgd2-xpm-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libgmp-dev']) {
      package { 'libgmp-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libsasl2-dev']) {
      package { 'libsasl2-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libmhash-dev']) {
      package { 'libmhash-dev':
        ensure => present,
      }
    }

    if ! defined(Package['freetds-dev']) {
      package { 'freetds-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libpspell-dev']) {
      package { 'libpspell-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libsnmp-dev']) {
      package { 'libsnmp-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libtidy-dev']) {
      package { 'libtidy-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libxslt1-dev']) {
      package { 'libxslt1-dev':
        ensure => present,
      }
    }

    if ! defined(Package['libmcrypt-dev']) {
      package { 'libmcrypt-dev':
        ensure => present,
      }
    }

    exec { "download-${version}":
      cwd       => '/tmp',
      command   => "wget -O php-${version}.tar.gz ${url}",
      creates   => "/usr/local/php${short_version}",
      timeout   => 3600,
      notify    => Exec["extract-${version}"],
      logoutput => 'on_failure',
    }

    exec { "extract-${version}":
      cwd         => '/tmp',
      command     => "tar xzvpf php-${version}.tar.gz -C /usr/src",
      unless      => "ls /usr/src/php-${version}",
      logoutput   => on_failure,
      refreshonly => true,
      notify      => Exec["configure-${version}"],
      require     => Exec["download-${version}"],
    }

    exec { "configure-${version}":
      cwd         => "/usr/src/php-${version}",
      command     => "./configure $configure",
      path        => [ "/usr/src/php-${version}", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout     => 0,
      refreshonly => true,
      logoutput   => on_failure,
      notify      => Exec["make-${version}"],
      require     => [ Exec["extract-${version}"], Package['build-essential'], Package['autoconf'], Package['libxml2-dev'], Package['libpcre3-dev'], Package['libbz2-dev'], Package['libcurl4-openssl-dev'], Package['libjpeg-dev'], Package['libpng12-dev'], Package['libxpm-dev'], Package['libfreetype6-dev'], Package['libmysqlclient-dev'], Package['libt1-dev'], Package['libgd2-xpm-dev'], Package['libgmp-dev'], Package['libsasl2-dev'], Package['libmhash-dev'], Package['freetds-dev'], Package['libpspell-dev'], Package['libsnmp-dev'], Package['libtidy-dev'], Package['libxslt1-dev'], Package['libmcrypt-dev'] ],
    }

    exec { "make-${version}":
      cwd         => "/usr/src/php-${version}",
      command     => "make",
      timeout     => 0,
      refreshonly => true,
      logoutput   => on_failure,
      notify      => Exec["make-install-${version}"],
      require     => Exec["configure-${version}"],
    }

    exec { "make-install-${version}":
      cwd         => "/usr/src/php-${version}",
      command     => "make install",
      timeout     => 0,
      refreshonly => true,
      logoutput   => on_failure,
      require     => Exec["make-${version}"],
    }

    exec { "pear-channel-update-${version}":
      cwd         => "/usr/local/php${short_version}/bin",
      command     => 'pear channel-update pear.php.net',
      path        => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout     => 0,
      refreshonly => true,
      logoutput   => on_failure,
      notify      => Exec["pear-upgrade-all-${version}"],
      require     => Exec["make-install-${version}"],
    }

    exec { "pear-upgrade-all-${version}":
      cwd         => "/usr/local/php${short_version}/bin",
      command     => 'pear upgrade-all',
      path        => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout     => 0,
      refreshonly => true,
      logoutput   => on_failure,
      require     => Exec["pear-channel-update-${version}"],
    }

    exec { "pear-discover-phpunit-${version}":
      cwd       => "/usr/local/php${short_version}/bin",
      command   => 'pear channel-discover pear.phpunit.de',
      path      => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout   => 0,
      logoutput => on_failure,
      creates   => "/usr/local/php${short_version}/bin/phpunit",
      require   => Exec["pear-upgrade-all-${version}"],
    }

    exec { "pear-discover-symfony-${version}":
      cwd       => "/usr/local/php${short_version}/bin",
      command   => 'pear channel-discover pear.symfony.com',
      path      => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout   => 0,
      logoutput => on_failure,
      creates   => "/usr/local/php${short_version}/bin/phpunit",
      require   => Exec["pear-upgrade-all-${version}"],
    }

    exec { "pear-discover-ez-${version}":
      cwd       => "/usr/local/php${short_version}/bin",
      command   => 'pear channel-discover components.ez.no',
      path      => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout   => 0,
      logoutput => on_failure,
      creates   => "/usr/local/php${short_version}/bin/phpunit",
      require   => Exec["pear-upgrade-all-${version}"],
    }

    exec { "pear-install-phpunit-${version}":
      cwd         => "/usr/local/php${short_version}/bin",
      command     => 'pear install phpunit/PHPUnit',
      path        => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout     => 0,
      logoutput   => on_failure,
      creates     => "/usr/local/php${short_version}/bin/phpunit",
      require     => [ Exec["pear-discover-phpunit-${version}"], Exec["pear-discover-symfony-${version}"], Exec["pear-discover-ez-${version}"] ],
    }

    exec { "install-composer-${version}":
      cwd       => "/usr/local/php${short_version}/bin",
      command   => "php -r \"eval('?>'.file_get_contents('https://getcomposer.org/installer'));\"",
      path      => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout   => 0,
      logoutput => on_failure,
      creates   => "/usr/local/php${short_version}/bin/composer.phar",
      require   => Exec["make-install-${version}"],
    }

    exec { "install-xdebug-${version}":
      cwd       => "/usr/local/php${short_version}/bin",
      command   => "pecl install xdebug",
      path      => [ "/usr/local/php${short_version}/bin", '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ],
      timeout   => 0,
      logoutput => on_failure,
      creates   => "${xdebug}",
      require   => Exec["make-install-${version}"],
    }
  }

  php::install::source { '5.3.22': }
  php::install::source { '5.4.12': }
}