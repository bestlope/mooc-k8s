# SpringBoot快速入门
## 简介
SpringBoot使你可以非常容易的创建一个独立的、生产级的、基于spring的应用。  
它大量简化了使用spring带来的繁琐的配置，大部分基于SpringBoot的应用只需要一点点的配置。

## 特征
- 独立的spring应用（内置tomcat、jetty，无需部署war包）
- 提供了丰富的"starter"依赖，简化应用构建配置
- 自动配置spring和第三方依赖库
- 没有代码生成，没有xml配置
- 提供准生产功能，如指标，健康检查和外部配置

## Quick Start
### 生成项目
访问官网：https://start.spring.io/  
选择构建工具，如：Maven Project、Java、Spring Boot 版本 2.1.4 以及一些基本信息，如下图：

![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/springboot-starter.png)

最终会下载到一个demo.zip，解压后主要目录结构如下
```bash
├── demo
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── example
│           │           └── demo
│           │               └── DemoApplication.java
│           └── resources
│               └── application.properties
```

### 在demo基础上做一个web服务
##### 改造后的pom
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.4.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <!-- 唯一改动的地方，从spring-boot-starter改成spring-boot-starter-web -->
        <!-- 引入此依赖会自动给应用加入web服务常用的jar包，包括默认的web容器 -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
             <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <!-- 此插件用于构建出一个fatjar，将所有应用的依赖，包括class文件、配置文件、jar包都打包到一个jar包里，可以使用java -jar的方式去运行 -->
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>

```

##### 服务配置 - application.properties
```bash
# 服务名
server.name=springboot-web-demo
# web服务监听端口
server.port=8080
```

##### 增加controller代码
com.example.demo.DemoController.java
```java
package com.example.demo;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DemoController {

    @RequestMapping("/hello")
    public String sayHello() {
        return "Hello SpringBoot";
    }

}
```

##### 运行&测试
经过以上步骤，一个基于springboot的web服务就搭建好了。

运行方式如下：
- 在IDE中：  
直接以DemoApplication做为启动类。
- 在命令行下：  

```bash
# 构建fatjar（构建结果在target目录下）
$ cd demo
$ mvn clean package

# 运行jar包
$ java -jar target/demo-0.0.1-SNAPSHOT.jar
```

测试：  
打开浏览器访问： http://localhost:8080/hello 看看效果吧




