# sonarqube alpine docker

Alpine 版本 3.17
JDK版本 17.0.9_3.17
Sonarqube版本 9.9.3.79811


~~~sh
# 
# 构建镜像 RELEASE_URL 这个是sonarqube的发行包,
# 由于太大,所以建议下载到本地后指定URL方式更快一些,不指定这个URL则 使用官方URL下载
# 
./build.sh

# 运行镜像
# conf/sonar.properties 这个配置文件中的所有配置项目,可以通过在环境变量中使用 CONF_配置KEY大写 的形式进行动态加载
# 如: 配置项 sonar.jdbc.username=sonarqube 可以通过设置 CONF_SONAR_JDBC_USERNAME="sonarqube" 环境变量来修改

docker run -itd --name sonarqube9 \
	-p 9000:9000 \
	-e CONF_SONAR_JDBC_USERNAME="sonarqube" \
	-e CONF_SONAR_JDBC_PASSWORD="sonarqube888" \
	-e CONF_SONAR_JDBC_URL="jdbc:postgresql://192.168.2.8/sonarqube?currentSchema=public" \
	tekintian/sonarqube:9.9.3.79811

# 默认登录地址:  http://localhost:9000/ 账户: admin/admin
~~~

## sonar-scanner

执行扫描命令
~~~sh
# sonarqube9 是你自己创建的容器名称 sonar-scanner 是容器中的扫描命令 后面是扫描参数
docker exec -it sonarqube9 sonar-scanner \
	-Dsonar.projectKey=tpos \
	-Dsonar.sources=. \
	-Dsonar.host.url=http://192.168.2.8:9000 \
	-Dsonar.login=sqp_5b9d629200000000000005b9d62925b9d6292

#  tpos 是项目名称
#  . 这里表示当前目录, 这里是要扫描的项目的路径, 可以是. 也可以是绝对路径
#  sqp_5b9d629200000000000005b9d62925b9d6292 这个是你要扫描的项目的token
#  http://192.168.2.8:9000 是sonarqube的服务地址和端口
~~~


### scanner的配置文件
$SONAR_SCANNER_HOME/conf/sonar-scanner.properties
-e SCANNER_SONAR_HOST_URL="http://192.168.2.8:9000"
-e SCANNER_SONAR_SOURCEENCODING="UTF-8"
~~~sh
#----- Default SonarQube server
sonar.host.url=http://localhost:9000

#----- Default source code encoding
sonar.sourceEncoding=UTF-8
~~~




## 保存加载docker镜像

- save保存镜像文件
docker save tekintian/sonarqube:9.9.3.79811 > sonarqube_9.9.3.79811.tar

- load加载镜像
docker load < sonarqube_9.9.3.79811.tar

