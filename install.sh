#!/bin/bash


download_url="https://f002.backblazeb2.com/file/aquaman-bucket/base.zip"
read -p "请输入一个域名（可以是顶级域名或者二级域名）: " domain

registries='[
    "77.37.64.124:5000",
    "192.168.0.153:15000"
]'

regex="^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$"
if [[ $domain =~ $regex ]]; then
    echo "域名有效: $domain"
    valid_domain=$domain
else
    echo "无效的域名，请输入正确的域名格式。"
    exit 1
fi
echo $valid_domain

## 删除旧的Docker版本
#sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine || exit 1
#
## 安装yum-utils
#sudo yum install -y yum-utils || exit 1
#
## 添加Docker的官方仓库
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || exit 1
## http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
## https://download.docker.com/linux/centos/docker-ce.repo
## 安装Docker
#sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || exit 1
#
## 定义要添加的 registries
#registries='[
#    "77.37.64.124:5000",
#    "192.168.0.153:15000"
#]'
#
## Docker daemon.json 文件路径
#daemon_file="/etc/docker/daemon.json"
#
## 安装 jq（适用于 CentOS/RHEL/Fedora）
#if ! command -v jq &> /dev/null
#then
#    echo "jq 未安装，正在安装..."
#    sudo yum install -y jq
#fi
#
## 如果 daemon.json 不存在，创建一个新的文件
#if [ ! -f "$daemon_file" ]; then
#    echo "{}" > "$daemon_file"
#fi
#
## 使用 jq 更新 daemon.json，添加或修改 insecure-registries
#sudo jq --argjson reg "$registries" '. + { "insecure-registries": $reg }' "$daemon_file" > "/tmp/daemon.json.tmp"
#
## 移动更新后的文件到正确位置
#sudo mv "/tmp/daemon.json.tmp" "$daemon_file"
#
## 重启 Docker 服务
#echo "重启 Docker 服务..."
## 启动Docker并设置为开机启动
#sudo systemctl start docker || exit 1
#sudo systemctl restart docker || exit 1
#sudo systemctl enable docker || exit 1
#echo "********************安装成功********************"
# 设置下载链接和目标目录

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
