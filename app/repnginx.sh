yum update
mkdir ~/bcck
cp -r /etc/nginx/* ~/bcck/



systemctl stop nginx.service
systemctl disable nginx.service

yum remove nginx
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -rf /var/cache/nginx/
rm -rf /usr/lib/systemd/system/nginx.service


yum -y groupinstall 'Development Tools'
yum -y install epel-release
yum install -y  wget git unzip perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel pcre-devel GeoIP GeoIP-devel
yum remove pcre pcre-devel openssl openssl-devel zlib zlib-devel
yum install unzip

cd /usr/local/src

wget http://nginx.org/download/nginx-1.15.0.tar.gz
wget https://github.com/arut/nginx-rtmp-module/archive/master.zip
tar -xvf nginx-1.15.0.tar.gz
unzip master.zip

wget https://ftp.pcre.org/pub/pcre/pcre-8.42.zip
unzip pcre-8.42.zip

wget https://www.zlib.net/zlib-1.2.11.tar.gz
tar -xzvf zlib-1.2.11.tar.gz

wget https://www.openssl.org/source/openssl-1.1.0h.tar.gz
tar -xzvf openssl-1.1.0h.tar.gz

rm -f *.tar.gz *.zip



cd nginx-1.15.0

./configure --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --modules-path=/usr/lib64/nginx/modules \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --user=nginx \
            --group=nginx \
            --build=CentOS \
            --builddir=nginx-1.15.0 \
            --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_stub_status_module \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-mail=dynamic \
            --with-mail_ssl_module \
            --with-stream=dynamic \
            --with-stream_ssl_module \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
            --with-stream_ssl_preread_module \
            --with-compat \
            --with-pcre=../pcre-8.42 \
            --with-pcre-jit \
            --with-zlib=../zlib-1.2.11 \
            --with-openssl=../openssl-1.1.0h \
            --with-openssl-opt=no-nextprotoneg \
            --add-module=../nginx-rtmp-module-master \
            --with-debug
            
make
make install
sudo useradd -r -d /var/cache/nginx/ -s /sbin/nologin -U nginx
mkdir -p /var/cache/nginx/
chown -R nginx:nginx /var/cache/nginx/

nginx -t
nginx -V

cd /lib/systemd/system/
nano nginx.service

[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target


systemctl daemon-reload
systemctl start nginx
systemctl enable nginx

rm -rf /etc/nginx/*
cp -r ~/bcck/* /etc/nginx/
