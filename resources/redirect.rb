#
# Cookbook Name:: techdivision-websever
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

actions :add, :remove

def initialize(*args)
  super
  @action = :add
end

attribute :source_domain, :kind_of => String, :name_attribute => true
attribute :server_aliases, :kind_of => [Array, NilClass], :default => nil
attribute :target_domain, :kind_of => String
