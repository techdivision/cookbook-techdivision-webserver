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

directory "/etc/php5/conf.d" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
end

directory "/etc/php5/fpm" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
  recursive true
end

directory "/etc/php5/cli" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
  recursive true
end

directory "/etc/php5/fpm/conf.d" do
  action :delete
  recursive true
  only_if { File.directory?("/etc/php5/fpm/conf.d") && !File.symlink?("/etc/php5/fpm/conf.d")}
end

link "/etc/php5/fpm/conf.d" do
  action :create
  to "../conf.d"
end

directory "/etc/php5/cli/conf.d" do
  action :delete
  recursive true
  only_if { File.directory?("/etc/php5/cli/conf.d") && !File.symlink?("/etc/php5/cli/conf.d")}
end

link "/etc/php5/cli/conf.d" do
  action :create
  to "../conf.d"
end

#
# PHP configuration and additional modules:
#

template "100-general-additions.ini" do
  path "/etc/php5/conf.d/100-general-additions.ini"
  source "100-general-additions.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
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
# PECL extensions
#

# PECL: igbinary

execute "pecl install igbinary" do
  not_if "test -e `pecl config-get ext_dir`/igbinary.so"
end

template "igbinary.ini" do
  path "/etc/php5/mods-available/igbinary.ini"
  source "igbinary.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

link "/etc/php5/conf.d/20-igbinary.ini" do
  action :create
  to "../mods-available/igbinary.ini"
end

# PECL: yaml

package "libyaml-dev" do
  action :install
end

execute "pecl install yaml" do
  not_if "test -e `pecl config-get ext_dir`/yaml.so"
end

template "yaml.ini" do
  path "/etc/php5/mods-available/yaml.ini"
  source "yaml.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

link "/etc/php5/conf.d/20-yaml.ini" do
  action :create
  to "../mods-available/yaml.ini"
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
