#!/bin/sh
# 
#  官方下载地址, 建议下载到本地后再进行,否则速度很慢
#  
#  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.3.79811.zip
#  
#  最新版发布页面
#  https://www.sonarsource.com/products/sonarqube/downloads/
#  历史版本
#  https://www.sonarsource.com/products/sonarqube/downloads/historical-downloads/
#  https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006.zip
#  

SONARQUBE_VERSION="9.9.3.79811"
SONAR_SCANNER_VERSION="5.0.1.3006"

docker build -f Dockerfile \
	-t tekintian/sonarqube:${SONARQUBE_VERSION}  \
	--build-arg SONARQUBE_VERSION=${SONARQUBE_VERSION} \
	--build-arg SONAR_SCANNER_VERSION=${SONAR_SCANNER_VERSION} \
	--build-arg RELEASE_URL="https://docker.lan.yunnan.ws/downloads/sonar/sonarqube-${SONARQUBE_VERSION}.zip" \
	.