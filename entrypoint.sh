#!/bin/bash
set -e

# 确保用户缓存目录存在
if [ ! -d "${USER_CACHE_DIR}" ];then
  mkdir -p ${USER_CACHE_DIR}
  chmod -R 0777 ${USER_CACHE_DIR}
  echo "${USER_CACHE_DIR} created!"
fi

chmod -R 0777 $SONARQUBE_HOME/conf $SONAR_SCANNER_HOME/conf
# General config 
# 循环所有 env 环境变量并将以CONF_开头的变量转换为小写.的默认写入到配置文件中
for VAR in `env`
do
  #如果变量名是以 CONF_ 开头且不以 SONAR_VERSION 开头 
  if [[ $VAR =~ ^CONF_ && ! $VAR =~ ^SONAR_VERSION ]]; then
    CONF_KEY=$(echo "$VAR" | sed -r "s/CONF_(.*)=.*/\1/g" | tr "[:upper:]" "[:lower:]" | tr _ .)
    CONF_VAR=${VAR%%=*}

    if egrep -q "(^|^#)$CONF_KEY" $SONARQUBE_HOME/conf/sonar.properties; then
      sed -r -i "s (^|^#)$CONF_KEY=.*$ $CONF_KEY=${!CONF_VAR} g" $SONARQUBE_HOME/conf/sonar.properties
    else
      echo "$CONF_KEY=${!CONF_VAR}" >> $SONARQUBE_HOME/conf/sonar.properties
    fi
  fi

  # sonar scanner config for conf/sonar-scanner.properties
  if [[ $VAR =~ ^SCANNER_ ]]; then
    CONF_KEY=$(echo "$VAR" | sed -r "s/SCANNER_(.*)=.*/\1/g" | tr "[:upper:]" "[:lower:]" | tr _ .)
    CONF_VAR=${VAR%%=*}

    if egrep -q "(^|^#)$CONF_KEY" $SONAR_SCANNER_HOME/conf/sonar-scanner.properties; then
      sed -r -i "s (^|^#)$CONF_KEY=.*$ $CONF_KEY=${!CONF_VAR} g" $SONAR_SCANNER_HOME/conf/sonar-scanner.properties
    else
      echo "$CONF_KEY=${!CONF_VAR}" >> $SONAR_SCANNER_HOME/conf/sonar-scanner.properties
    fi
  fi

done

chmod -R 0555 $SONARQUBE_HOME/conf $SONAR_SCANNER_HOME/conf

# By default, java from the PATH is used, except if CONF_JAVA_PATH env variable is set
findjava() {
  if [ -z "${SONAR_JAVA_PATH}" ]; then
    if ! command -v java 2>&1; then
      echo "Java not found. Please make sure that the environmental variable SONAR_JAVA_PATH points to a Java executable"
      exit 1
    fi
    JAVA_CMD=java
  else
    if ! [ -x "${SONAR_JAVA_PATH}" ] || ! [ -f "${SONAR_JAVA_PATH}" ]; then
      echo "File '${SONAR_JAVA_PATH}' is not executable. Please make sure that the environmental variable SONAR_JAVA_PATH points to a Java executable"
      exit 1
    fi
    JAVA_CMD="${SONAR_JAVA_PATH}"
  fi
}

findjava

if [ -z "${HAZELCAST_ADDITIONAL}" ]; then
  HAZELCAST_ADDITIONAL="--add-exports=java.base/jdk.internal.ref=ALL-UNNAMED \
  --add-opens=java.base/java.lang=ALL-UNNAMED \
  --add-opens=java.base/java.nio=ALL-UNNAMED \
  --add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
  --add-opens=java.management/sun.management=ALL-UNNAMED \
  --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED"
fi

# Sonar app launching process memory setting
if [ -z "${JAVA_OPT}" ]; then
  JAVA_OPT=" -Xms8m -Xmx32m "
fi

# JAVA_OPT_ADD 增加的JAVA选项不为空
if ! [ -z "${JAVA_OPT_ADD}" ]; then
  JAVA_OPT=" ${JAVA_OPT_ADD} ${JAVA_OPT} "
fi

# sonar app opt
if [ -z "${APP_OPT}" ]; then
  APP_OPT=" -Dsonar.log.console=true "
fi

DEFAULT_CMD=($JAVA_CMD $JAVA_OPT $HAZELCAST_ADDITIONAL '-jar' ${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar ${APP_OPT})

# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- "${DEFAULT_CMD[@]}" "$@"
fi

exec "$@"
