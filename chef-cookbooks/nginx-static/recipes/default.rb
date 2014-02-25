#
# Cookbook Name:: nginx-static
# Recipe:: default
#

template "#{node['nginx']['dir']}/sites-available/static" do                   
  source 'static.erb'                                                     
  owner  'root'                                                                 
  group  'root'                                                                 
  mode   '0644'                                                                 
  notifies :reload, 'service[nginx]'                                            
end

nginx_site "static"

directory "/var/www" do
  owner "root"
  group "root"
  mode 00644
  action :create
end

# deploy files from git, they are now the same across nginx nodes

package "git" do                                                                
  action :install                                                             
end

directory "/tmp/private_code/.ssh" do                                           
  recursive true                                                                
end                                                                             

cookbook_file "/tmp/private_code/.ssh/deploykey" do                              
  source "deploykey"                                                             
  mode 0600                                                                     
end                                                                             

cookbook_file "/tmp/private_code/wrap-ssh4git.sh" do                            
  source "wrap-ssh4git.sh"                                                      
  mode 0700                                                                     
end

deploy node['nginx-static']['deploy_dir'] do
  repo node['nginx-static']['deploy_repo']
  user node['nginx-static']['deploy_user']
  keep_releases node['nginx-static']['deploy_keep_releases']
  action node['nginx-static']['deploy_action']
  migrate false
  git_ssh_wrapper "wrap-ssh4git.sh"
end
