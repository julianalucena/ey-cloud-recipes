#
# Cookbook Name:: sphinx
# Attrbutes:: default
#

default[:sphinx] = {
  # Sphinx will be installed on to application/solo instances,
  # unless a utility name is set, in which case, Sphinx will
  # only be installed on to a utility instance that matches
  # the name
  :utility_name => 'sphinx',
  
  # The version of sphinx to install
  :version => '2.0.6',
  
  # Applications that are using sphinx. Leave this blank to
  # setup sphinx for each app in an environment
  # :apps => ['todo', 'admin'],
  :apps => [],
  
  # Index frequency. How often the indexer cron job should
  # be run. A value of 15 will reindex every 15 minutes
  :frequency => 15
}

# Note: You do not need to edit below this line

# Store sphinx node as attribute
if has_util?(default[:sphinx][:utility_name])
  default[:sphinx][:node] = node[:engineyard][:environment][:instances].find do |instance| 
    instance[:role][/util/] && instance[:name][default[:sphinx][:utility_name]]
  end
else
  default[:sphinx][:node] = node[:engineyard][:environment][:instances].find do |instance|
    instance[:role][/app_master|solo/]
  end
end

# Set apps key to all available apps if empty
if default[:sphinx][:apps].empty?
  default[:sphinx][:apps] = node[:engineyard][:environment][:apps].map{|a| a[:name]}
end