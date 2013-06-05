#
# Cookbook Name:: sphinx
# Recipe:: thinking_sphinx
#

# setup thinking sphinx on each app (see attributes)
node[:sphinx][:apps].each do |app_name|
  # variables
  current_path = "/data/#{app_name}/current"
  shared_path = "/data/#{app_name}/shared"
  env = node[:environment][:framework_env]
  
  # check that application is deployed
  if File.symlink?(current_path)
    # config yml
    template "#{shared_path}/config/thinking_sphinx.yml" do
      source "thinking_sphinx.yml.erb"
      owner node[:owner_name]
      group node[:owner_name]
      mode "0644"
      backup 0
      variables({
        :environment => env,
        :address => node[:sphinx][:node][:private_hostname],
        :pid_file => "#{shared_path}/log/#{node[:environment][:framework_env]}.sphinx.pid"
      })
    end
    
    # configure thinking sphinx
    execute "configure sphinx" do 
      command "bundle exec rake ts:configure"
      user node[:owner_name]
      environment 'RAILS_ENV' => env
      cwd current_path
    end
    
    # index unless index already exists
    execute "indexing" do
      command "bundle exec rake ts:index"
      user node[:owner_name]
      environment 'RAILS_ENV' => env
      cwd current_path
    end
  else
    Chef::Log.info "Thinking Sphinx was not configured because the application (#{app_name}) must be deployed first. Please deploy your application and then re-run the custom chef recipes."
  end
end