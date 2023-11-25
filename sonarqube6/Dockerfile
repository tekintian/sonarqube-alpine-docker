ARG JRE_TAG=8u265-1-tse
FROM tekintian/alpine-jre:${JRE_TAG}

LABEL org.opencontainers.image.url=https://github.com/tekintian/sonarqube-alpine-docker

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

ARG SONARQUBE_VERSION=6.5
ARG RELEASE_URL="${RELEASE_URL:-https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip}"

ARG user=sonarqube \
    group=sonarqube \
    uid=1000 \
    gid=1000

ENV SONARQUBE_HOME=/opt/sonarqube \
    USER_CACHE_DIR=/opt/sonarqube/.sonar/cache \
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
  \
  && unzip -q sonarqube.zip \
  &&  mv "sonarqube-${SONARQUBE_VERSION}" ${SONARQUBE_HOME} \
  &&  rm sonarqube.zip* \
  &&  rm -rf ${SONARQUBE_HOME}/bin/* \
  && ln -s "${SONARQUBE_HOME}/lib/sonar-application-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/sonarqube.jar" \
  # && ln -s "${SONARQUBE_HOME}/lib/sonar-shutdowner-${SONARQUBE_VERSION}.jar" "${SONARQUBE_HOME}/lib/shutdowner.jar" \
  \
  && cd ${SONARQUBE_HOME} \
  # 清理在docker容器中用不上的文件和目录
  && rm -rf bin COPYING dependency-license.json \
  # 删除所有的.DS_Store文件
  && find ${SONARQUBE_HOME} -name ".DS_Store" -depth -exec rm {} \; \
  \
  && mkdir -p ${USER_CACHE_DIR} \
  # 添加用户和给目录授权
  && addgroup --gid ${gid} ${group} \
  && adduser --uid ${uid} -G ${group} ${user} -h ${SONARQUBE_HOME} -s /sbin/nologin -D \
  \
  && chown -R ${uid}:${gid} ${SONARQUBE_HOME} \
  \
  && chmod -R 0555 ${SONARQUBE_HOME} \
  && chmod -R 0777 "${SQ_DATA_DIR}" "${SQ_EXTENSIONS_DIR}" "${SQ_LOGS_DIR}" "${SQ_TEMP_DIR}" "${USER_CACHE_DIR}"  \
  \
  # /entrypoint.sh 入口文件创建
  && chmod +x /entrypoint.sh \
  && rm -rf /var/cache/apk/* \
  && apk del --no-network .build-deps \
  && rm -rf /tmp/*

WORKDIR ${SONARQUBE_HOME}
EXPOSE 9000

USER sonarqube
STOPSIGNAL SIGINT

# start sonar
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
