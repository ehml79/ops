首先，我们先来安装 Nginx

yum install epel-release -y
yum install nginx -y
安装完成后，配置 nginx 启动和开机自启动

systemctl enable nginx.service 
systemctl start nginx.service
安装 Node 环境
接下来，我们来配置 Node 运行环境

curl --silent --location https://rpm.nodesource.com/setup_8.x |  bash -
yum -y install nodejs
配置 NPM 加速
安装完成后，我们为 NPM 添加国内的镜像，从而实现 node 依赖的加速下载

npm install -g cnpm --registry=https://registry.npm.taobao.org




安装 Express
任务时间：时间未知

安装 Express 生成器
首先，我们来安装 express 的生成器，帮助我们快速生成 Express 站点, 执行如下命令

cnpm install express-generator -g
创建一个 express 站点
接下来，我们来创建一个 express 站点， 执行如下命令，来初始化一个新的以 cloud 为名的应用，

cd /home/
express cloud
初始化完成后，进入到目录中，安装对应的依赖

cd cloud 
cnpm install
这样，我们就完成了安装。

测试 Express
执行如下命令，来启动 Express ，进行测试

DEBUG=cloud:* npm start
此时，我们可以打开浏览器，访问 http://<您的 CVM IP 地址>:3000 就可以访问默认的 Express 界面的内容。

按下 Ctrl + C 来退出进程。

安装 PM 2
执行如下命令来安装 pm2

cnpm install pm2 -g
安装完成后，执行命令，为我们的 pm2 添加开机自启动

pm2 startup systemd 
pm2 save
使用 PM2 启动 Express
执行如下命令，来使用 pm2 来启动我们的 express

pm2 start ./bin/www
接下来，我们来创建 Nginx 配置文件(/etc/nginx/conf.d/cloud.conf)，用于对 Express 进行反向代理，在文件中添加如下代码

示例代码：/etc/nginx/conf.d/cloud.conf
upstream cloud-app{
    server 127.0.0.1:3000;
    keepalive 64;
}
server{
    listen 80;
    server_name <您的 CVM IP 地址>;
    root /home/cloud;

    location / {
        proxy_set_header HOST $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://cloud-app/;
        proxy_redirect off;
        proxy_read_timeout 240s;
    }

}
添加完成后执行 nginx -t 来检测配置文件是否正常。

如果没有报错，就执行 nginx -s reload 来让重新加载配置文件。

此时，你可以访问 http://<您的 CVM IP 地址> 来查看你的 Express 站点了。