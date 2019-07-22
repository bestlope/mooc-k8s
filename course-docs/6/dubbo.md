# Dubbo快速入门
## 简介
Dubbo是一款高性能、轻量级的开源Java RPC框架，它提供了三大核心能力：面向接口的远程方法调用，智能容错和负载均衡，以及服务自动注册和发现。

Dubbo源自阿里巴巴，2018年初贡献给了apache基金会。已经经历一年多的孵化。
据悉，2.7.x会作为Dubbo在Apache社区的毕业版本，Dubbo将有机会成为继RocketMQ后，来自阿里巴巴的又一个Apache顶级项目(TLP)。

## 架构
dubbo主要有三种角色：
 - **服务的提供者**  
启动后会把服务的信息写入注册中心（服务的ip地址，端口，有哪些接口等）
 - **服务消费者**  
访问注册中心找到服务提供者的信息，并跟服务提供者建立连接。
 - **注册中心**  
主要作用是存储服务的信息，并对服务的变化做通知。

![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/dubbo-arch.png)

## Quick Start
最常见的使用dubbo的方式是基于spring框架。下面的内容也是基于spring框架的配置去演示如何开发一个基于dubbo的应用。

首先我们创建一个根目录叫：dubbo-demo：
```bash
$ mkdir dubbo-demo
$ cd dubbo-demo
```

然后在根目录下创建三个子目录：
- dubbo-demo-api: 服务的api定义
- dubbo-demo-provider: 服务提供者
- dubbo-demo-consumer: 服务消费者

### 1. 注册中心 - zookeeper
dubbo常用的注册中心是zookeeper，首先用docker启动一个zookeeper服务，暴露出2181端口。
```bash
$ docker run -idt -p 2181:2181 zookeeper:3.5
```

### 2. dubbo-demo-api - 服务接口定义
定义服务接口（DemoService.java）
```java
package org.apache.dubbo.demo;

public interface DemoService {
    String sayHello(String name);
}
```

此时工程的结构应该类似这样：
```bash
├── dubbo-demo-api
│   ├── pom.xml
│   └── src
│       └── main
│           └── java
│               └── org
│                   └── apache
│                       └── dubbo
│                           └── demo
│                               └── DemoService.java
```

### 3. dubbo-demo-provider - 服务提供者
##### 服务实现类（DemoServiceImpl.java）
```java
package org.apache.dubbo.demo.provider;
import org.apache.dubbo.demo.DemoService;

public class DemoServiceImpl implements DemoService {
    public String sayHello(String name) {
        return "Hello " + name;
    }
}
```

##### 服务启动类（Provider.java）
```java
package org.apache.dubbo.demo.provider;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class Provider {

    public static void main(String[] args) throws Exception {
        System.setProperty("java.net.preferIPv4Stack", "true");
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[]{"META-INF/spring/dubbo-demo-provider.xml"});
        context.start();
        System.out.println("Provider started.");
        System.in.read(); // press any key to exit
    }
}
```
##### 通过spring配置暴露服务（provider.xml）
```xml
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
       http://dubbo.apache.org/schema/dubbo http://dubbo.apache.org/schema/dubbo/dubbo.xsd">

    <!-- 服务提供者的应用名 -->
    <dubbo:application name="demo-provider"/>
    <!-- 把服务注册到zookeeper -->
    <dubbo:registry address="zookeeper://${zookeeper_ip_addr}:2181"/>
    <!-- 使用dubbo协议暴露服务端口20880 -->
    <dubbo:protocol name="dubbo" port="20880"/>
    <!-- 服务的实现类 -->
    <bean id="demoService" class="org.apache.dubbo.demo.provider.DemoServiceImpl"/>
    <!-- 声明要暴露的服务接口 -->
    <dubbo:service interface="org.apache.dubbo.demo.DemoService" ref="demoService"/>
</beans>
```

##### 配置日志（log4j.xml）
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
	<appender name="stdout" class="org.apache.log4j.ConsoleAppender">
		<param name="encoding" value="UTF-8"/>
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="[%d{yyyy-MM-dd HH:mm:ss.SSS}] {%p} %c %L - %m%n" />
		</layout>
	</appender>
	<root>
		<level value="warn" />
		<appender-ref ref="stdout" />
	</root>
</log4j:configuration>
```

##### 最终项目结构如下
```bash
├── dubbo-demo-provider
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── apache
│           │           └── dubbo
│           │               └── demo
│           │                   └── provider
│           │                       ├── DemoServiceImpl.java
│           │                       └── Provider.java
│           └── resources
│               ├── META-INF
│               │   └── spring
│               │       └── dubbo-demo-provider.xml
│               └── log4j.xml
```

### 4. dubbo-demo-consumer - 服务消费者

##### 用下面的spring配置引用一个远程的dubbo服务（consumer.xml）
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
       http://dubbo.apache.org/schema/dubbo http://dubbo.apache.org/schema/dubbo/dubbo.xsd">

    <!-- 消费者应用名 -->
    <dubbo:application name="demo-consumer"/>
    <!-- 用zookeeper发现服务 -->
    <dubbo:registry address="zookeeper://${zookeeper_ip_addr}:2181"/>
    <!-- 生成远程服务的代理, 之后demoService就可以像使用本地接口一样使用了 -->
    <dubbo:reference id="demoService" check="false" interface="org.apache.dubbo.demo.DemoService"/>
</beans>
```

##### 消费者启动类（Consumer.java）
```java
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.apache.dubbo.demo.DemoService;
 
public class Consumer {
    public static void main(String[] args) throws Exception {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[] {"META-INF/spring/dubbo-demo-consumer.xml"});
        context.start();
        // Obtaining a remote service proxy
        DemoService demoService = (DemoService)context.getBean("demoService");
        // Executing remote methods
        String hello = demoService.sayHello("world");
        // Display the call result
        System.out.println(hello);
    }
}
```

##### 配置好日志后（同provider），项目结构如下：
```bash
├── dubbo-demo-consumer
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── apache
│           │           └── dubbo
│           │               └── demo
│           │                   └── consumer
│           │                       └── Consumer.java
│           └── resources
│               ├── META-INF
│               │   └── spring
│               │       └── dubbo-demo-consumer.xml
│               └── log4j.xml
```

### 5. 完整示例
- **provider**
```bash
$ git clone https://github.com/apache/incubator-dubbo.git
$ cd incubator-dubbo
```
> 在模块dubbo-demo-provider下运行org.apache.dubbo.demo.provider.Provider
> 如果用的IDE是Intellij Idea，需要添加参数：-Djava.net.preferIPv4Stack=true

- **consumer**
```bash
$ git clone https://github.com/apache/incubator-dubbo.git
$ cd incubator-dubbo
```
> 如果用的IDE是Intellij Idea，需要添加参数：-Djava.net.preferIPv4Stack=true
