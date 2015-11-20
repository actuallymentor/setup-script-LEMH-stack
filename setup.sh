echo "This script is made for Ubuntu 15.10 64x"
read -p "Press enter to get started"

########################## Variables #############################
workerprocesses=$(grep processor /proc/cpuinfo | wc -l)
workerconnections=$(ulimit -n)

global_nginx_conf="
user  www-data www-data;
worker_processes  $workerprocesses;

events {
    worker_connections  $workerconnections;
}


http {
    include       /usr/local/nginx/conf/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    #tcp_nopush     on;

    # Gzip configuration
    include /usr/local/nginx/conf/gzip.conf;

    # Add my servers
    include /usr/local/nginx/conf/conf.d/*;

    # Buffers
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;

    # Timeouts

    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;

    # Log off
    access_log off;

    # Security stuff
    # Don't send Nginx version
    server_tokens off;

}
"
nginx_conf='
server {
        listen 80;
 
        root /usr/local/nginx/html;
        index index.html index.htm index.php;
 
        server_name localhost;
        client_max_body_size 32M;
        large_client_header_buffers 4 16k;
     
        include /usr/local/nginx/conf/hhvmwithfallback.conf;
        include /usr/local/nginx/conf/mod_pagespeed.conf;
        include /usr/local/nginx/conf/cache.conf;
        include /usr/local/nginx/conf/gzip.conf;

        location @fallback {
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include /usr/local/nginx/conf/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_read_timeout 1500;
        }
 
        location / {
                try_files $uri $uri/ /index.php;
        }
        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        root /usr/share/nginx/html;
    }
}'
hhvmwithfallback='
location ~ \.(hh|php)$ {
    proxy_intercept_errors on;
    error_page 500 501 502 503 = @fallback;
 
    fastcgi_keep_conn on;
 
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include        fastcgi_params;
}
'
servercheck='
PIDhhvm=/var/run/hhvm/pid
PIDnginx=/var/run/nginx.pid
PIDfpm=/var/run/php5-fpm.pid
if [ ! -f $PIDhhvm ]; then
        echo "$(date) Starting hhvm..."
        echo "$(date) Starting hhvm..." >> ~/server.log
        service hhvm start
fi

if [ ! -f $PIDnginx ]; then
        echo "$(date) Starting nginx..."
        echo "$(date) Starting nginx..." >> ~/server.log
        service nginx start
fi

if [ ! -f $PIDfpm ]; then
	echo "$(date) Starting php5-fpm..."
        echo "$(date) Starting php5-fpm..." >> ~/server.log
        service php5-fpm start
fi
'
mod_pagespeed='
pagespeed on;
pagespeed RewriteLevel PassThrough;
pagespeed FetchHttps enable;
pagespeed EnableFilters add_head;
pagespeed EnableFilters combine_css;
pagespeed EnableFilters rewrite_css;
pagespeed EnableFilters fallback_rewrite_css_urls;
pagespeed EnableFilters rewrite_style_attributes;
pagespeed EnableFilters rewrite_style_attributes_with_url;
pagespeed EnableFilters flatten_css_imports;
pagespeed EnableFilters inline_css;
pagespeed EnableFilters inline_google_font_css;
pagespeed EnableFilters prioritize_critical_css;

pagespeed CssInlineMaxBytes 25600;
pagespeed JsInlineMaxBytes 8192;
pagespeed ImageRecompressionQuality 75;
pagespeed JpegRecompressionQualityForSmallScreens 65;

pagespeed EnableFilters rewrite_javascript;
pagespeed EnableFilters rewrite_javascript_external;
pagespeed EnableFilters rewrite_javascript_inline;
pagespeed EnableFilters combine_javascript;
pagespeed EnableFilters canonicalize_javascript_libraries;
pagespeed EnableFilters inline_javascript;
pagespeed EnableFilters defer_javascript;
pagespeed EnableFilters dedup_inlined_images;
pagespeed EnableFilters lazyload_images;

pagespeed EnableFilters local_storage_cache;
pagespeed EnableFilters rewrite_images;
pagespeed EnableFilters convert_jpeg_to_progressive;
pagespeed EnableFilters convert_png_to_jpeg;
pagespeed EnableFilters convert_jpeg_to_webp;
pagespeed EnableFilters convert_to_webp_lossless;
pagespeed EnableFilters insert_image_dimensions;
pagespeed EnableFilters inline_images;
pagespeed EnableFilters recompress_images;
pagespeed EnableFilters recompress_jpeg;
pagespeed EnableFilters recompress_png;
pagespeed EnableFilters recompress_webp;
pagespeed EnableFilters convert_gif_to_png;
pagespeed EnableFilters strip_image_color_profile;
pagespeed EnableFilters strip_image_meta_data;
pagespeed EnableFilters resize_images;
pagespeed EnableFilters resize_rendered_image_dimensions;
pagespeed EnableFilters resize_mobile_images;

pagespeed EnableFilters remove_comments;
pagespeed EnableFilters collapse_whitespace;
pagespeed EnableFilters elide_attributes;
pagespeed EnableFilters extend_cache;
pagespeed EnableFilters extend_cache_css;
pagespeed EnableFilters extend_cache_images;
pagespeed EnableFilters extend_cache_scripts;

pagespeed EnableFilters sprite_images;
pagespeed EnableFilters convert_meta_tags;

pagespeed EnableFilters in_place_optimize_for_browser;
pagespeed EnableFilters insert_dns_prefetch;

pagespeed FileCachePath /var/ngx_pagespeed_cache;

location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" {
  add_header "" "";
}
location ~ "^/pagespeed_static/" { }
location ~ "^/ngx_pagespeed_beacon$" { }
pagespeed EnableCachePurge on;
'
cache='
location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
expires 365d;
}
'
gzip='
gzip on;
gzip_disable "msie6";
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types text/plain text/css text/xml application/xml application/javascript application/x-javascript text/javascript;
'

##################################################################
##################################################################
##################################################################
##################################################################
##################################################################
##################################################################
##################################################################
##################################################################

sudo apt-get update

# Dependencies etc
sudo apt-get install -y build-essential python dpkg-dev zlib1g-dev libpcre3 libpcre3-dev unzip software-properties-common

# Do PPA stuff
sudo add-apt-repository ppa:nginx/stable -y && sudo apt-get update

# Nginx source
mkdir -p ~/new/nginx_source/
cd ~/new/nginx_source/
apt-get source nginx
sudo apt-get build-dep -y nginx

# Pagespeed download
cd ~
mkdir -p ~/new/ngx_pagespeed/
cd ~/new/ngx_pagespeed/
NPS_VERSION=1.9.32.10
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
unzip release-${NPS_VERSION}-beta.zip

cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
tar -xzf ${NPS_VERSION}.tar.gz

########## Add rules here
cd ~/new/nginx_source/nginx-*/
./configure --add-module=$HOME/new/ngx_pagespeed/ngx_pagespeed-release-${NPS_VERSION}-beta
make
make install
# init script
sudo wget https://raw.githubusercontent.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx


sudo update-rc.d -f nginx defaults

echo "$global_nginx_conf" > /usr/local/nginx/conf/nginx.conf;
mkdir /usr/local/nginx/conf/conf.d/
touch /usr/local/nginx/conf/conf.d/default;
echo "$nginx_conf" > /usr/local/nginx/conf/conf.d/default;
echo "$hhvmwithfallback" > /usr/local/nginx/conf/hhvmwithfallback.conf;
echo "$mod_pagespeed" > /usr/local/nginx/conf/mod_pagespeed.conf;
echo "$cache" > /usr/local/nginx/conf/cache.conf;
echo "$gzip" > /usr/local/nginx/conf/gzip.conf;

# Mariadb
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository -y 'deb http://mirror.i3d.net/pub/mariadb/repo/10.1/ubuntu vivid main' && sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mariadb-server
sudo service mysql start

# PHP
sudo apt-get install -y php5-fpm php5-mysql php5-curl

# HHVM
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
echo deb http://dl.hhvm.com/ubuntu vivid main | sudo tee /etc/apt/sources.list.d/hhvm.list
sudo apt-get update
sudo apt-get install -y hhvm
sudo /usr/share/hhvm/install_fastcgi.sh
sudo service hhvm restart

echo $servercheck > ~/servercheck.sh

# Create server check cron
touch /etc/cron.d/servercheck
echo "*/10 * * * * root bash ~/servercheck.sh" >> /etc/cron.d/servercheck

service nginx restart