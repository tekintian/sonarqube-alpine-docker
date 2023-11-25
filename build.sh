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
#  sonar-scanner版本下载
#  https://docs.sonarsource.com/sonarqube/9.9/analyzing-source-code/scanners/sonarscanner/
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
JRE_TAG=${JRE_TAG:-"17.0.9_3.17_jar"}
SONARQUBE_VERSION=${SONARQUBE_VERSION:-"9.9.3.79811"}
SONAR_SCANNER_VERSION=${SONAR_SCANNER_VERSION:-"5.0.1.3006"}
# 获取jdk的前2位版本号,如 1.8 11.0 17.0
JDK_MVER=$(echo $JRE_TAG |cut -d. -f1 -f2)

echo "\n版本信息: JDK_MVER: ${JDK_MVER} JRE_TAG=${JRE_TAG} SONARQUBE_VERSION=${SONARQUBE_VERSION} SONAR_SCANNER_VERSION=${SONAR_SCANNER_VERSION} \n"

# 构建容器
docker build -f Dockerfile \
	-t tekintian/sonarqube:${SONARQUBE_VERSION}_${JDK_MVER}  \
	--build-arg JRE_TAG=${JRE_TAG} \
	--build-arg SONARQUBE_VERSION=${SONARQUBE_VERSION} \
	--build-arg SONAR_SCANNER_VERSION=${SONAR_SCANNER_VERSION} \
	--build-arg RELEASE_URL="https://docker.lan.yunnan.ws/downloads/sonar/sonarqube-${SONARQUBE_VERSION}.zip" \
  --build-arg SONAR_SCANNER_URL="https://docker.lan.yunnan.ws/downloads/sonar/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip" \
	${WORK_DIR}