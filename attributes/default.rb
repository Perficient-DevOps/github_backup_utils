
# installation from github releases
default['github_backup_utils']['version']             = '2.16.1'
default['github_backup_utils']['package']['filename'] = "github-backup-utils-v#{node['github_backup_utils']['version']}.tar.gz"
default['github_backup_utils']['package']['source']   = "https://github.com/github/backup-utils/releases/download/v#{node['github_backup_utils']['version']}/#{node['github_backup_utils']['package']['filename']}"

default['github_backup_utils']['user']                = 'github'
default['github_backup_utils']['group']               = 'github'

default['github_backup_utils']['install']['config']   = '/etc/github-backup-utils'
default['github_backup_utils']['install']['path']     = '/opt'

# configuration details
default['github_backup_utils']['config']['ghe_host']  = 'github.server'
default['github_backup_utils']['config']['ghe_data_path']  = '/data'
default['github_backup_utils']['config']['numbackups']  = '10'

# schedule
