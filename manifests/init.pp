class httpd(
		$listen_addr 		= 80,
		$doc_root			= '/var/www/html'
	) 
	{
	package { 'httpd':
		ensure  => present
	}
	
	exec { 'remove-old-vhosts':
		command => '/bin/rm -fr /etc/httpd/sites-enabled',
	}
	
	exec { 'httpd-security-tokens':
		command => '/bin/sed -i "s/ServerTokens .*/ServerTokens prod/g" /etc/httpd/conf/httpd.conf',
		require => [ Package['sed'], Package['httpd'] ],
	}

	exec { 'httpd-security-signature':
		command => '/bin/sed -i "s/ServerSignature .*/ServerSignature off/g" /etc/httpd/conf/httpd.conf',
		require => [ Package['sed'], Package['httpd'] ],
	}
	
	file { 'httpd-conf-file': 
		path => '/etc/httpd/conf/httpd.conf',
		ensure => file,
		content => template('httpd/httpd.conf.erb'),
		require => [ Package['httpd'] ],
		notify => Service['httpd'],
	}
	
	file { 'httpd-sites-available-dir':
		path => '/etc/httpd/sites-available',
		ensure => directory,
		owner => root,
		group => root,
		mode => 700,
	}
	
	file { 'httpd-sites-enabled-dir':
		path => '/etc/httpd/sites-enabled',
		ensure => directory,
		owner => root,
		group => root,
		mode => 700,
	}
	
	file { 'httpd-sites-enabled':
		path    => '/etc/httpd/conf.d/sites.conf',
		content => template('httpd/sites.conf.erb'),
		ensure  => present,
		require => File['httpd-sites-enabled-dir'],
		notify  => Service['httpd'],
	}
	
	service { 'httpd': 
		ensure => running,
		enable => true,
		require => [ Package['httpd'] ],
	}
	
	
	
}