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
    $packagesDir = '/dopa-vm/packages-dev'
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

    @git::clone { 'TU-Berlin/dopa-packages':
        directory => $packagesDir
    }

    file { '/dopa-vm/compile':
        ensure => present,
        mode   => '0755',
        source => 'puppet:///files/compile',
    }
    package { [ 'maven' ]:
        ensure => present,
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
    #include ::apt
    include my::hadoop::master
    include my::hbase
}

