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

include_recipe 'nginx'

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
# PHP configuration and additional modules:
#

directory "/etc/php5/conf.d" do
  action :create
  owner "root"
  group "www-data"
  mode 00755
end

template "100-general-additions.ini" do
  path "/etc/php5/conf.d/100-general-additions.ini"
  source "100-general-additions.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "php-fpm")
end

link "/etc/php5/fpm/conf.d/100-general-additions.ini" do
  to "/etc/php5/conf.d/100-general-additions.ini"
end

link "/etc/php5/cli/conf.d/100-general-additions.ini" do
  to "/etc/php5/conf.d/100-general-additions.ini"
end

# FIXME: igbinary is not included yet!
php_pear "igbinary" do
  channel "pecl.php.net"
  action :install
end

package 'php5-curl' do
  action :install
end

package 'php5-gd' do
  action :install
end

package 'php5-mysqlnd' do
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
