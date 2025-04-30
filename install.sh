#!/bin/bash

download_url="https://f002.backblazeb2.com/file/aquaman-bucket/base.zip"
read -p "请输入一个域名（可以是顶级域名或者二级域名）: " domain

registries='[
    "43.162.127.172:5000"
]'

regex="^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"
if [[ $domain =~ $regex ]]; then
    echo "域名有效: $domain"
    valid_domain=$domain
else
    echo "无效的域名，请输入正确的域名格式。"
    exit 1
fi

# Rest of your script would continue here...
echo "使用的域名是: $valid_domain"


target_dir="$HOME/aquaman"

# 创建目标目录（如果不存在）
mkdir -p "$target_dir"

# 下载文件到目标目录
wget -O "$target_dir/base.zip" "https://f002.backblazeb2.com/file/aquaman-bucket/base.zip"

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "下载失败，请检查下载链接或网络连接。"
    exit 1
fi


# 解压文件到目标目录
echo "正在解压文件..."
unzip "$target_dir/base.zip" -d "$target_dir"

# 检查解压是否成功
if [ $? -ne 0 ]; then
    exit 1
fi

# 删除压缩包
rm "$target_dir/base.zip"
echo "文件下载并解压成功，存放在 $target_dir 目录下。"
conf_file="$HOME/aquaman/data/conf/conf.d/web.conf"
sed -i "s/{{DOMAIN}}/$valid_domain/g" "$conf_file"
sed -i "s/{{DOMAIN}}/$valid_domain/g" "$target_dir/docker-compose.yml"
echo "********************配置成功********************"
cd $target_dir
echo "********************程序安装********************"
docker compose pull
docker compose up -d

echo "访问 http://$valid_domain 查看。"
echo "默认账密:admin/123456"
echo "请及时在后台修改，防止信息泄露"
echo "********************配置成功********************"
[root@VM-0-14-centos ~]# cat i.sh 
#!/bin/bash

# 定义daemon.json文件路径
DAEMON_JSON="/etc/docker/daemon.json"

# 检查文件是否存在
if [ ! -f "$DAEMON_JSON" ]; then
    # 文件不存在，创建并写入内容
    echo "{
  \"insecure-registries\" : [
    \"43.162.127.172:5000\"
  ]
}" > "$DAEMON_JSON"
    echo "daemon 文件已创建并写入内容。"
else
    echo "daemon 文件已存在，跳过写入。"
fi

# 重新加载systemctl守护进程并重启docker
systemctl daemon-reload
systemctl restart docker

echo "服务已重启。"
