# == DOPA Puppet Manifest
#
# This manifest is the main entrypoint for Puppet, the configuration
# management tool that sets up this machine to run the DOPA VM. The
# manifest specifies which classes of services should be enabled on this
# virtual machine.
#
# By default, the DOPA virtual machine is configured to run
# a plain Stratosphere instance, with some small enhancements designed to
# make it easy to test Stratosphere and the  DOPA plattform. 
# However, other roles which
# are not enabled by default can be enabled
#
# To enable an optional role, simply uncomment its delcaration below by
# removing the leading '#' symbol and saving this file. Then, run
# 'vagrant up' to ensure your machine is active, and then 'vagrant
# provision' to apply the updated configuration to your instance.
#
#
import 'base.pp'
import 'roles.pp'
import 'manifests.d/*.pp'

node default { #relates to config.vm.hostname
    include role::stratotester
    include role::cdh4pseudo
}
