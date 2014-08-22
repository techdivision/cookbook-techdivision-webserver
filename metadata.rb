name             "techdivision-webserver"
maintainer       "Robert Lemke"
maintainer_email "r.lemke@techdivision.com"
license          "MIT License"
description      "Installs/Configures techdivision-webserver"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "1.0.0"

depends "techdivision-base"
depends "nginx"
depends "php"
depends "php-fpm"
depends "techdivision-typo3flow"