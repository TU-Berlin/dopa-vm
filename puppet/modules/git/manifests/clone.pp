
# Definition: git::clone
#
# Creates a git clone of a specified origin into a top level directory.
#
# === Required parameters
#
# $+directory+:: path to clone the repository into.
#
# === Optional parameters
# $+remote+:: Remote URL for the repository. If unspecified, the resource title
#   			will be interpolated into $git::urlformat.
# $+branch+:: Branch you would like to check out.
# $+ensure+:: _absent_, _present_, or _latest_.  Defaults to _present_.
#             - _present_ (default) will just clone once.
#             - _latest_ will execute a git pull if there are any changes.
#             - _absent_ will ensure the directory is deleted.
# $+owner+:: Owner of $directory, default: _root_.  git commands will be run
#  by this user.
# $+group+:: Group owner of $directory, default: 'root'
# $+mode+:: Permission mode of $directory, default: 0755
# $+ssh+:: SSH command/wrapper to use when checking out, default: ''
# $+timeout+:: Time out in seconds for the exec command, default: 300
#
# === Example usage
#
#   git::clone{ 'my_clone_name':
#       directory => '/path/to/clone/container',
#       origin    => 'http://blabla.org/core.git',
#       branch    => 'the_best_branch'
#   }
#
# Will clone +http://blabla.org/core.git+ branch +the_best_branch+ at
#  +/path/to/clone/container/core+
define git::clone(
    $directory,
    $remote=undef,
    $branch='',
    $ssh='',
    $ensure='present',
    $owner='vagrant',
    $group='vagrant',
    $timeout='0',
    $depth='full',
    $mode=0755) {
    include git
    $url = $remote ? {
		undef   => sprintf($git::urlformat, $title),
		default => $remote,
	}


    case $ensure {
        'absent': {
            # make sure $directory does not exist
            file { $directory:
                ensure  => 'absent',
                recurse => true,
                force   => true,
            }
        }

        # otherwise clone the repository
        default: {
            # if branch was specified
            if $branch {
                $brancharg = "-b $branch "
            }
            # else don't checkout a non-default branch
            else {
                $brancharg = ''
            }
            if $ssh {
                $env = "GIT_SSH=$ssh"
            }

            $deptharg = $depth ?  {
                'full'  => '',
                default => " --depth=$depth"
            }

            # set PATH for following execs
            Exec { path => '/usr/bin:/bin' }
            # clone the repository
            exec { "git_clone_${title}":
                command     => "git clone ${brancharg}${url}${deptharg} $directory",
                logoutput   => on_failure,
                cwd         => '/tmp',
                environment => $env,
                creates     => "$directory/.git/config", #differenct to vagrant version but should be ok
                user        => $owner,
                group       => $group,
                timeout     => $timeout,
                require     => Package['git'], #change due to vagrant environment
            }

            if (!defined(File[$directory])) {
                file { $directory:
                    ensure  => 'directory',
                    mode    => $mode,
                    owner   => $owner,
                    group   => $group,
                    require => Exec["git_clone_${title}"],
                }
            }

            # pull if $ensure == latest and if there are changes to merge in.
            if $ensure == 'latest' {
                exec { "git_pull_${title}":
                    cwd       => $directory,
                    command   => "git pull --quiet${deptharg}",
                    logoutput => on_failure,
                    # git diff --quiet will exit 1 (return false)
                    #  if there are differences
                    unless    => 'git fetch && git diff --quiet remotes/origin/HEAD',
                    user      => $owner,
                    group     => $group,
                    require   => Exec["git_clone_${title}"],
                }
            }
        }
    }
}
