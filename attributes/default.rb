default["php-fpm"]["pools"] = [
  {
    :name => "www",
    :listen => "127.0.0.1:9000",
    :max_requests => "500"
  }
]

default['nginx']['configure_flags'] = ["--add-module=#{Chef::Config['file_cache_path']}/ngx_http_redis-0.3.7"]
default['nginx']['source']['version'] = "1.7.6"
default['nginx']['source']['url'] = "http://nginx.org/download/nginx-#{node['nginx']['source']['version']}.tar.gz"
default['nginx']['source']['checksum'] = '08e2efc169c9f9d511ce53ea16f17d8478ab9b0f7a653f212c03c61c52101599'
