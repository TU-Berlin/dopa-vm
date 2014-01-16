# == Roles for DOPA-VM
#
# A 'role' represents a set of software configurations required for
# giving this machine some special function.
#
# To enable a particular role on your instance, include it in the
# mediawiki-vagrant node definition in 'site.pp'.
#
# include my::hadoop::master

# == Class: role::generic
# Configures common tools and shell enhancements.
class role::generic {
    include ::apt
    include ::env
    include ::misc
    class { 'oraclejava':
        version => "7",
        isdefault => true,
    }
}


# == Class: role::stratosphere
# Provisions a Stratosphere instance powered by Oracle Java.
class role::stratodev {
    include role::generic
    class { 'git': }
    $ozoneDir = '/dopa-vm/stratosphere-dev'
    $meteorDir = '/dopa-vm/meteor-dev'
    $schedulerDir = '/dopa-vm/scheduler-dev'
    $testingDir = '/dopa-vm/testing-dev'

    @git::clone { 'TU-Berlin/stratosphere':
        directory => $ozoneDir,
        branch => 'IMRproduction'
    }

    @git::clone { 'TU-Berlin/stratosphere-sopremo':
        directory => $meteorDir,
        branch => 'IMRproduction'
    }

    @git::clone { 'TU-Berlin/stratosphere-testing':
        directory => $testingDir,
        branch => 'IMRproduction'
    }

    @git::clone { 'TU-Berlin/dopa-scheduler':
        directory => $schedulerDir
    }


    file { '/dopa-vm/compile':
        ensure => present,
        mode   => '0755',
        source => 'puppet:///files/compile',
    }

    package { [ 'maven', 'rabbitmq-server' ]:
        ensure => present,
        notify => Exec['view-rabbits'],
    }

    exec{ 'kill-rabbits':
        command => '/usr/sbin/rabbitmqctl stop_app && /usr/sbin/rabbitmqctl reset && /usr/sbin/rabbitmqctl start_app',
        user    => 'root'
    }

    exec{ 'view-rabbits':
        command => '/usr/lib/rabbitmq/lib/rabbitmq_server-2.7.1/sbin/rabbitmq-plugins enable rabbitmq_management && service rabbitmq-server restart && touch /srv/rabbit_mq_mgnt_installed',
        user    => 'root',
        creates => '/srv/rabbit_mq_mgnt_installed',
    }
	
}
# == Class: role::stratotester
# Provisions a Stratosphere instance powered by Oracle Java.
class role::stratotester {
    include role::generic
    class { 'stratodist': }

}
# == Class: role::stratodata
# Provisions a Stratosphere instance powered by Oracle Java.
class role::stratodata {
    include role::generic
    $datadir   = '/dopa-vm/data'
    $url   = 'http://dopa.dima.tu-berlin.de'
    $usr = 'data'
    $password = '' #enter password here

    exec { 'get-data':
        command => "/usr/bin/wget -r -nH --reject \"index.html*\" --http-user=${usr} --http-password=${password} --no-parent ${url}/dopadata/ -P ${datadir}",
        creates => "${datadir}/dopadata"
    }

}
# == Class: role::opendata
# Provisions a Stratosphere instance powered by Oracle Java.
class role::opendata {
    include role::generic
    $datadir   = '/dopa-vm/data'
    $url   = 'http://demo.formulasearchengine.com/images/'

    exec { 'get-opendata':
        command => "/usr/bin/wget ${url}wikienmath.xml -P ${datadir}/opendata",
        creates => "${datadir}/opendata"
    }

}

# == Class: role::cdh4pseudo
# Provisions a pseudo distributes Cloudera 4 instanstace.
class role::cdh4pseudo {
    import 'hadoop.pp'
    include my::hadoop::master
    include my::hbase
}

# == Class: role::dopaprivate
# Enables roles that require access to the private dopa
# repositories
class role::dopaprivate {
    $packagesDir = '/dopa-vm/packages-dev'
    $okkamDir = '/dopa-vm/okkam-dev'

    file { '/home/vagrant/.ssh/id_rsa':
  source => 'puppet:///files/dopa.ppk',
  mode => 700,
  owner => 'vagrant'
}
    file { '/dopa-vm/dompile':
        ensure => present,
        mode   => '0755',
        source => 'puppet:///files/dompile',
    }
    @git::clone { 'TU-Berlin/dopa-packages':
        directory => $packagesDir
    }

    @git::clone { 'TU-Berlin/dopa-okkam':
        remote => 'git@github.com:TU-Berlin/dopa-okkam.git',
        ssh => '/dopa-vm/puppet/files/ssh.sh',
        directory => $okkamDir,
        require => File['/home/vagrant/.ssh/id_rsa']
    }

}
