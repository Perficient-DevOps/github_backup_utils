#
# Cookbook:: github_backup_utils
# Recipe:: install
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# prerequisites
package 'git'
package 'rsync'


local_file = File.join( Chef::Config[:file_cache_path], node['github_backup_utils']['package']['filename'] )
extract_filename = File.basename(node['github_backup_utils']['package']['filename'], '.tar.gz')
install_path = File.join(node['github_backup_utils']['install']['path'], extract_filename)
install_symlink = File.join(node['github_backup_utils']['install']['path'], 'github-backup-utils')

#FIXME:
# group node['github_backup_utils']['group'] do
#   action :create
# end

#FIXME: Issue where useradd wants to create the matching group is causing a problem
user node['github_backup_utils']['user'] do
  comment 'GitHub user for running backup utilities.'
  shell '/bin/bash'
  manage_home true
end

# group node['github_backup_utils']['group'] do
#   action :modify
#   members node['github_backup_utils']['user']
#   append true
# end

remote_file local_file do
  source node['github_backup_utils']['package']['source']
  mode '0755'
  action :create
end

bash 'extract_installer' do
  code "tar xzf #{local_file} -C #{node['github_backup_utils']['install']['path']}"
  not_if { ::File.exist?(install_path) }
end

directory install_path do
  owner node['github_backup_utils']['user']
  group node['github_backup_utils']['group']
  mode '0755'
  recursive true
  action :create
end

link install_symlink do
  to install_path
  owner node['github_backup_utils']['user']
  group node['github_backup_utils']['group']
end

directory node['github_backup_utils']['install']['config'] do
  action :create
end

template File.join(node['github_backup_utils']['install']['config'], 'backup.config') do
  source 'backup.config.erb'
  variables(
    ghe_host: node['github_backup_utils']['config']['ghe_host'],
    ghe_data_path: node['github_backup_utils']['config']['ghe_data_path'],
    ghe_numbackups: node['github_backup_utils']['config']['numbackups']
  )
end

# setup scheduled backup

backup_script = File.join(node['github_backup_utils']['install']['config'], 'ghe-backup-scripts.sh')

template backup_script do
  source 'ghe-backup-script.sh.erb'
  variables(
    ghe_admin_email: node['github_backup_utils']['config']['admin_email'],
    ghe_path: install_symlink,
    ghe_logs: node['github_backup_utils']['logs']
  )
end

file backup_script do
  mode '0755'
end

# Install backup script in cron with schedule, backups calls chef-server-ctl
# which requires root to execute.
cron 'ghe-backup' do
  minute  node['github_backup_utils']['backup']['minute']
  hour    node['github_backup_utils']['backup']['hour']
  command backup_script
  user 'root'
end
