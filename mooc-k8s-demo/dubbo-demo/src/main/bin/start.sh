#!/bin/bash

cd `dirname $0`
BIN_DIR=`pwd`
cd ..

DEPLOY_DIR=`pwd`
CONF_DIR=${DEPLOY_DIR}/conf

SERVER_NAME=`sed '/dubbo.application.name/!d;s/.*=//' conf/dubbo.properties | tr -d '\r'`
SERVER_PORT=`sed '/dubbo.protocol.port/!d;s/.*=//' conf/dubbo.properties | tr -d '\r'`

if [ -z "${SERVER_NAME}" ]; then
    echo "ERROR: can not found 'dubbo.application.name' config in 'dubbo.properties' !"
	exit 1
fi

PIDS=`ps  --no-heading -C java -f --width 1000 | grep "${CONF_DIR}" |awk '{print $2}'`
if [ -n "${PIDS}" ]; then
    echo "ERROR: The ${SERVER_NAME} already started!"
    echo "PID: ${PIDS}"
    exit 1
fi

if [ -n "${SERVER_PORT}" ]; then
	SERVER_PORT_COUNT=`netstat -ntl | grep ${SERVER_PORT} | wc -l`
	if [ ${SERVER_PORT_COUNT} -gt 0 ]; then
		echo "ERROR: The ${SERVER_NAME} port ${SERVER_PORT} already used!"
		exit 1
	fi
fi

LOGS_DIR=""
if [ -n "${LOGS_FILE}" ]; then
	LOGS_DIR=`dirname ${LOGS_FILE}`
else
	LOGS_DIR=${DEPLOY_DIR}/logs
fi
if [ ! -d ${LOGS_DIR} ]; then
	mkdir ${LOGS_DIR}
fi
STDOUT_FILE=${LOGS_DIR}/stdout.log

LIB_DIR=${DEPLOY_DIR}/lib
LIB_JARS=`ls ${LIB_DIR} | grep .jar | awk '{print "'${LIB_DIR}'/"$0}'|tr "\n" ":"`

JAVA_OPTS=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true "
JAVA_DEBUG_OPTS=""
if [ "$1" = "debug" ]; then
    JAVA_DEBUG_OPTS=" -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n "
fi

echo -e "Starting the ${SERVER_NAME} ...\c"

nohup ${JAVA_HOME}/bin/java -Dapp.name=${SERVER_NAME} ${JAVA_OPTS} ${JAVA_DEBUG_OPTS} ${JAVA_JMX_OPTS} -classpath ${CONF_DIR}:${LIB_JARS} com.alibaba.dubbo.container.Main >> ${STDOUT_FILE} 2>&1 &

PIDS=`ps  --no-heading -C java -f --width 1000 | grep "${DEPLOY_DIR}" | awk '{print $2}'`
echo "PID: ${PIDS}"
echo "STDOUT: ${STDOUT_FILE}"