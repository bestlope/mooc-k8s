#!/bin/bash

if [ "${BUILD_DIR}" == "" ];then
    echo "env 'BUILD_DIR' is not set"
    exit 1
fi

DOCKER_DIR=${BUILD_DIR}/${JOB_NAME}

if [ ! -d ${DOCKER_DIR} ];then
    mkdir -p ${DOCKER_DIR}
fi

echo "docker workspace: ${DOCKER_DIR}"

JENKINS_DIR=${WORKSPACE}/${MODULE}

echo "jenkins workspace: ${JENKINS_DIR}"

if [ ! -f ${JENKINS_DIR}/target/*.war ];then
    echo "target war file not found ${JENKINS_DIR}/target/*.war"
    exit 1
fi

cd ${DOCKER_DIR}
rm -fr *
unzip -oq ${JENKINS_DIR}/target/*.war -d ./ROOT

mv ${JENKINS_DIR}/Dockerfile .
if [ -d ${JENKINS_DIR}/dockerfiles ];then
    mv ${JENKINS_DIR}/dockerfiles .
fi

VERSION=$(date +%Y%m%d%H%M%S)
IMAGE_NAME=hub.mooc.com/kubernetes/${JOB_NAME}:${VERSION}

echo "${IMAGE_NAME}" > ${WORKSPACE}/IMAGE

echo "building image: ${IMAGE_NAME}"
docker build -t ${IMAGE_NAME} .

docker push ${IMAGE_NAME}

