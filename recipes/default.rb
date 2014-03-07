#
# Cookbook Name:: techdivision-websever
# Recipe:: default
# Author:: Robert Lemke <r.lemke@techdivision.com>
#
# Copyright (c) 2014 Robert Lemke, TechDivision GmbH
#
# Licensed under the MIT License (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://opensource.org/licenses/MIT
#

#
# NGINX
#

include_recipe "nginx"

directory "/var/www/nginx-default" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
  recursive true
end

file "/var/www/nginx-default/index.php" do
  content "<?php echo(gethostname()); ?>"
  owner "root"
  group "www-data"
  mode 00775
end

#
# PHP-FPM:
#

include_recipe "php"
include_recipe "php-fpm"

template "default-site.erb" do
  path "/etc/nginx/sites-available/default-custom"
  source "default-site.erb"
  owner "root"
  group "root"
  mode "0644"
end

nginx_site "default-custom" do
  enable true
end

#
# PHP configuration directory structure
#

#
# Create a directory "common" instead of using just "/etc/php5/conf.d" because all modules which are installed
# by DPKG will create symlinks to their module init files with "../../mods-available". That's because they expect
# to be in, for example, /etc/php5/cli/conf.d/ and not in /etc/php5/conf.d
#
directory "/etc/php5/common/conf.d" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
  recursive true
end

directory "/etc/php5/fpm" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
end

directory "/etc/php5/cli" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
end

directory "/etc/php5/fpm/conf.d" do
  action :delete
  recursive true
  only_if { File.directory?("/etc/php5/fpm/conf.d") && !File.symlink?("/etc/php5/fpm/conf.d")}
end

link "/etc/php5/fpm/conf.d" do
  action :create
  to "../common/conf.d"
end

directory "/etc/php5/cli/conf.d" do
  action :delete
  recursive true
  only_if { File.directory?("/etc/php5/cli/conf.d") && !File.symlink?("/etc/php5/cli/conf.d")}
end

link "/etc/php5/cli/conf.d" do
  action :create
  to "../common/conf.d"
end

#
# Re-create symlinks which usually would be created in ...fpm/conf.d and ...cli/conf.d
#

link "/etc/php5/common/conf.d/opcache.ini" do
  action :create
  to "../../mods-available/opcache.ini"
end

link "/etc/php5/common/conf.d/pdo.ini" do
  action :create
  to "../../mods-available/pdo.ini"
end


#
# PHP configuration and additional modules:
#

template "100-general-additions.ini" do
  path "/etc/php5/common/conf.d/100-general-additions.ini"
  source "100-general-additions.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

php_pear "igbinary" do
  channel "pecl.php.net"
  action :install
end

package "libyaml-dev" do
  action :install
end

php_pear "yaml" do
  channel "pecl.php.net"
  action :install
end

template "yaml.ini" do
  path "/etc/php5/mods-available/yaml.ini"
  source "yaml.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

link "/etc/php5/common/conf.d/20-yaml.ini" do
  action :create
  to "../../mods-available/yaml.ini"
end

package "php5-gd" do
  action :install
end

package "php5-mysqlnd" do
  action :install
end

package "php5-sqlite" do
  action :install
end

package "php5-readline" do
  action :install
end

package "php5-curl" do
  action :install
end

#
# RSYNC for Surf deployments
#

package "rsync" do
  action :install
end

#
# TYPO3 Neos websites
#

sites = search(:sites, "host:#{node.fqdn} AND delete:false")

sites.each do |site|
  techdivision_typo3flow_app site["host"] do
    database_name site["databaseName"]
    database_username site["databaseUsername"]
    database_password site["databasePassword"]
    rewrite_rules []
  end

  nginx_site site["host"] do
    enable true
  end

end
