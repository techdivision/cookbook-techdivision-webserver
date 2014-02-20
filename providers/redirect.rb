#
# Cookbook Name:: techdivision-webserver
# Provider:: redirect
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

action :add do

  source_domain = new_resource.source_domain
  target_domain = new_resource.target_domain
  server_aliases = new_resource.server_aliases
  app_username = source_domain.gsub('.', '')

  recipe_eval do

    user app_username do
      comment "Site owner user"
      shell "/bin/zsh"
      home "/var/www/#{source_domain}"
    end

    group "www-data" do
      action :modify
      members app_username
      append true
    end

    directory "/var/www/#{source_domain}" do
      user app_username
      group "www-data"
      mode 00775
    end

    file "/var/www/#{source_domain}/index.php" do
      content "some placeholder"
      owner app_username
      group "www-data"
      mode 00775
    end

  end

  web_app source_domain do
    cookbook "robertlemke-webserver"
    template "redirect_app.conf.erb"

    docroot "/var/www/#{source_domain}"
    source_domain "#{source_domain}"
    target_domain "#{target_domain}"
    server_aliases server_aliases
  end

end

action :remove do

end
