default['php-fpm']['pools'] = [
  {
    :name => "www",
    :listen => "127.0.0.1:9000",
    :max_requests => "500"
  }
]