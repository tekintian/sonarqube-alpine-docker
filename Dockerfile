ARG JRE_TAG=17.0.9_3.17_jar
FROM tekintian/alpine-jre:${JRE_TAG}

LABEL org.opencontainers.image.url=https://github.com/tekintian/sonarqube-alpine-docker

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

ARG SONARQUBE_VERSION=9.9.3.79811 SONAR_SCANNER_VERSION=5.0.1.3006
ARG RELEASE_URL="${RELEASE_URL:-https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip}" \
    SONAR_SCANNER_URL="${SONAR_SCANNER_URL:-https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip}"

ARG user=sonarqube \
    group=sonarqube \
    uid=1000 \
    gid=1000

ENV SONARQUBE_HOME=/opt/sonarqube \
    SONAR_SCANNER_HOME=/opt/sonar-scanner \
    USER_CACHE_DIR=/opt/sonarqube/.sonar/cache \
    SCANNERWORK_DIR=/opt/sonarqube/.scannerwork \
    SONARQUBE_VERSION="${SONARQUBE_VERSION}" \
    SQ_DATA_DIR="/opt/sonarqube/data" \
    SQ_EXTENSIONS_DIR="/opt/sonarqube/extensions" \
    SQ_LOGS_DIR="/opt/sonarqube/logs" \
    SQ_TEMP_DIR="/opt/sonarqube/temp"

# COPY ./sonarqube /opt/sonarqube
COPY ./entrypoint.sh /entrypoint.sh

RUN set -eux \
  && apk add --no-cache bash  \
  # 安装下载和解压依赖
  && apk add --no-cache --virtual .build-deps \
    curl \
    unzip \
  \
  && cd /tmp \
  # -k 不验证SSL证书
  &&  curl -k --fail --location --output sonarqube.zip --silent --show-error "${RELEASE_URL}" \
  &&  curl -k --fail --location --output sonar-scanner.zip --silent --show-error "${SONAR_SCANNER_URL}" \
  && unzip -q sonarqube.zip \
  &&  mv "sonarqube-${SONARQUBE_VERSION}" ${SONARQUBE_HOME} \
  &&  rm sonarqube.zip* \
  &&  rm -rf ${SONARQUBE_HOME}/bin/* \
  && ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar" \
  && ln -s "${SONARQUBE_HOME}/lib/sonar-shutdowner-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/shutdowner.jar" \
  \
  # sonar scnner
  && unzip sonar-scanner.zip \
  &&  mv "sonar-scanner-${SONAR_SCANNER_VERSION}" ${SONAR_SCANNER_HOME} \
  &&  rm sonar-scanner.zip* \
  && find ${SONAR_SCANNER_HOME} -name "*.bat" -depth -exec rm {} \; \
  # ......
  && cd ${SONARQUBE_HOME} \
  # 清理在docker容器中用不上的文件和目录
  && rm -rf bin COPYING dependency-license.json \
  # 删除所有的.DS_Store文件
  && find ${SONARQUBE_HOME} -name ".DS_Store" -depth -exec rm {} \; \
  \
  # java 安全选项
  && echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security" \
  && sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security" \
  \
  && mkdir -p ${USER_CACHE_DIR} ${SCANNERWORK_DIR} ${SONAR_SCANNER_HOME} \
  # 添加用户和给目录授权
  && addgroup --gid ${gid} ${group} \
  && adduser --uid ${uid} -G ${group} ${user} -h ${SONARQUBE_HOME} -s /sbin/nologin -D \
  \
  && chown -R ${uid}:${gid} ${SONARQUBE_HOME}  ${SONAR_SCANNER_HOME}\
  \
  && chmod -R 0555 ${SONARQUBE_HOME} ${SONAR_SCANNER_HOME} \
  && chmod -R 0777 "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}" "${USER_CACHE_DIR}" "${SCANNERWORK_DIR}" \
  \
  # /entrypoint.sh 入口文件创建
  && chmod +x /entrypoint.sh \
  && rm -rf /var/cache/apk/* \
  && apk del --no-network .build-deps \
  && rm -rf /tmp/*

# config the sonar scanner path env
ENV PATH=${SONAR_SCANNER_HOME}/bin:${PATH}

WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000

USER sonarqube
STOPSIGNAL SIGINT

# start sonar
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
