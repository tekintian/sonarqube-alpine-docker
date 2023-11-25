#!/bin/sh
# 
#  官方下载地址, 建议下载到本地后再进行,否则速度很慢
#  
#  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-6.7.7.zip
#  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-5.6.7.zip
#  最新版发布页面
#  https://www.sonarsource.com/products/sonarqube/downloads/
#  历史版本
#  https://www.sonarsource.com/products/sonarqube/downloads/historical-downloads/
#  https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006.zip
#  
#  sonar-scanner版本下载
#  https://docs.sonarsource.com/sonarqube/9.9/analyzing-source-code/scanners/sonarscanner/
#  SonarScanner 4.3  2019-03-09  sonarqube 6.6
#  
WORK_DIR=$(cd $(dirname $0); pwd)

# 获取用户输入 -j JRE_TAG  -v SONAR_VERSION  -s SONAR_SCANNER_VERSION
while getopts ":j:v:s:" opt
do
    case $opt in
    	j)
          JRE_TAG=$OPTARG;;
        v)
          SONARQUBE_VERSION=$OPTARG;;
        s)
          SONAR_SCANNER_VERSION=$OPTARG;;
        ?)
        echo "Unknown parameter"
        exit 1;;
    esac
done

# 获取好初始化环境变量
# tekintian/alpine-jre:1.8.0_392_3.17_jar
# 5.6.7 2017-09-22
# 6.7.7 2019-04-14
JRE_TAG=${JRE_TAG:-"8u265-1-tse"}
SONARQUBE_VERSION=${SONARQUBE_VERSION:-"6.7.7"}

# 构建容器
# --build-arg RELEASE_URL="https://docker.lan.yunnan.ws/downloads/sonar/sonarqube-${SONARQUBE_VERSION}.zip" 
docker build -f Dockerfile \
	-t tekintian/sonarqube:${SONARQUBE_VERSION}  \
	--build-arg JRE_TAG=${JRE_TAG} \
	--build-arg SONARQUBE_VERSION=${SONARQUBE_VERSION} \
	\
	${WORK_DIR}


