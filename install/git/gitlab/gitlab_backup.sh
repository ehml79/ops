#!/bin/bash



# 创建备份
/usr/bin/gitlab-rake gitlab:backup:create

# 备份文件目录
# /var/opt/gitlab/backups

 
/etc/gitlab/gitlab.rb 
/etc/gitlab/gitlab-secrets.json


# 重新设置
gitlab-ctl reconfigure

# 恢复备份
gitlab-rake gitlab:backup:restore BACKUP=${BACKUP_VERSION_ID}

# 启动
gitlab-ctl start

