## DOPA Virtual Machine (Alpha Version)

[http://www.dopa-project.eu](http://www.dopa-project.eu "dopa-project.eu")

This is a portable DOPA testing and development environment. It consists
of a set of configuration scripts that automate the creation of a virtual
machine that runs Stratosphere.

The virtual machine makes it easy to learn about using, modify, and improving the
DOPA platform software Stratosphere.


## Prerequisites

You'll need to install recent versions of Vagrant and VirtualBox.

 * VirtualBox: https://www.virtualbox.org/wiki/Downloads
 * Vagrant: http://www.vagrantup.com/downloads.html

Next, you'll need a copy of the vm that you can download from this GIT repository.


## Installation

Download the content of this repository and extract it to a directory of your choice.
Once you have done that, open up a terminal or a command-prompt, and change your
working directory to the location of the extracted (or git-cloned) files.
From there, run `vagrant up` to provision and boot the virtual machine.

You'll now have to wait a bit (15-20 min), as Vagrant needs to retrieve the base image from
Canonical, retrieve some additional packages, and installs and configures each of
them.

If it all worked, you should be able to browse to http://localhost:8090/ and
see the main page of your DOPA test instance.

You can close the vagrant session by the command 'vagrant halt'.


## Shell Usage

To access a command shell on your virtual environment, run `vagrant ssh` from
the root the directory you downloaded the virtual machine to.

From Windows this might cause problems see:
http://stackoverflow.com/questions/9885108/ssh-to-vagrant-box-in-windows


## Developing the Stratosphere platform

Follow the installation instructions.
Run `vagrant list-roles` to see the available roles.
Use `vagrant enable-role stratodev` to enable the developer role and
`vagrant provision` to apply the changes.

Vagrant will download the essential source directories from the remote GIT repository.

1. To submit changes to the source, you have to fork the project you want to change.
* Create a private key inside the VM and add it to your account settings. `ssh-keygen && cat ~/.ssh/id-rsa.pub`
* Add your repository as remote e.g. `git remote add myrepo git@github.com:USERNAME/stratosphere-sopremo.git`
* Push the changes to your forked repository. `git push myrepo master:featurename`
* Create a pull request.

## Getting started

There are two main entries for new users. If you are an experienced JAVA developer,
are familar with the MapReduce concept and you want to model your data flow graphs
by yourself you probably want to work on the PACT level.
Otherwise, it might be easier to start with a simple meteor program.

### PACT

To access the PACT web interface navigate to

[http://localhost:8081/launch.html](http://localhost:8081/launch.html)

You should see a page titled *Stratosphere Query Interface*.
Now you can start with the *hello world* analogon for MapReduce *WordCount*.
The wordcount example is preshipped with your Stratosphere installation. Upload

> stratosphere\examples\pact\pact-examples-${Version}-WordCount.jar

from the your local download copy of the DOPA-VM to the web interface.

Check the checkbox in the right frame of the new word count example and specify e.g.

> 4 file:///dopa-vm/data/opendata/wikienmath.xml file:///dopa-vm/data/output/wordcount1.csv

as arguments.
Click *run job* and click run on the next page again.

## Meteor
### submitting a simple meteor job via command line

> cd /dopa-vm

> sudo ./stratosphere/bin/meteor-client.sh script.meteor --wait

this should copy test.json to test_result.json

## DOPA (private)
If you want to use the features that are accessible by DOPA members only
you have to copy your private key for the git repositories to
dopa-vm/puppet/files/dopa.ppk. In unix this can be done with the following command
> cp ~/.ssh/id_rsa dopa-vm/puppet/files/dopa.ppk && chmod 700 dopa-vm/puppet/files/dopa.ppk

## HDFS and HBASE

The dopa-vm is equipped with a standalone cloundera (cdh4) installation.

Access 
* the [HDFS web frontend](http://localhost:50071) - 50070 was used for another service on windows -
* the [MapReduce JobTracker](http://localhost:8088).

The HBASE support is limit at the moment and needs some manual tuning.
See this [changeset.](https://gerrit.wikimedia.org/r/#/c/99381/)

##Troubleshooting

If you have problem to access the internet from inside the vm (you can test that via ping google.com ) run the following command to reset the virtual nic:

>sudo ifdown eth0 && sudo ifup eth0



## Bug Reporting

Bugs can be reported at

[https://github.com/TU-Berlin/dopa-vm/issues](https://github.com/TU-Berlin/dopa-vm/issues)
