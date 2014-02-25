#
# Cookbook Name:: nginx-static
# Attributes:: default
#

override['nginx']['default_site_enabled']   = false

default['nginx-static']['deploy_dir']          = '/var/www/static'
default['nginx-static']['deploy_repo']          = 'git@github.com/deploy/project'
default['nginx-static']['deploy_user']          = 'deploy'
default['nginx-static']['deploy_keep_releases']          = 10
default['nginx-static']['deploy_action']          = :deploy # or :rollback
