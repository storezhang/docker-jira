FROM storezhang/ubuntu AS builder


# 版本
ENV VERSION 8.16.1


WORKDIR /opt/atlassian


RUN apt update && apt install -y axel curl

# 安装Bitbucket
RUN axel --num-connections 64 --insecure "https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${VERSION}.tar.gz"
RUN tar -xzf atlassian-jira-software-${VERSION}.tar.gz && mv atlassian-jira-software-${VERSION}-standalone jira
RUN chown -R ${USERNAME} /opt/atlassian/jira
RUN chmod -R u=rwx,go-rwx /opt/atlassian/jira





# 打包真正的镜像
FROM storezhang/atlassian


MAINTAINER storezhang "storezhang@gmail.com"
LABEL architecture="AMD64/x86_64" version="latest" build="2021-04-13"
LABEL Description="Atlassian公司产品Jira，一个非常好的敏捷开发系统。在原来的基础上增加了MySQL/MariaDB驱动以及太了解程序。"



# 设置Jira主目录
ENV JIRA_HOME /config
ENV SET_PERMISSIONS true



# 开放端口
# Jira本身的端口
EXPOSE 8080



# 复制文件
COPY --from=builder /opt/atlassian/jira /opt/atlassian/jira
COPY docker /



RUN set -ex \
    \
    \
    \
    # 安装JIRA并增加执行权限
    && chmod +x /etc/s6/jira/* \
    \
    \
    \
    # 安装MySQL/MariaDB驱动
    && cp -r /opt/oracle/mariadb/lib/ /opt/atlassian/jira/ \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/lib/apt/lists/* \
    && apt autoclean
