FROM hub.mooc.com/kubernetes/openjdk:8-jre-alpine

COPY target/springboot-web-demo-1.0-SNAPSHOT.jar /springboot-web.jar

ENTRYPOINT ["java", "-jar", "/springboot-web.jar"]

