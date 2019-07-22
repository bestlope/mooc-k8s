# Kubernetes零基础入门 - 看这一篇就够了!
## Kubernetes - 初识
#### 起源
Kubernetes 源自于 google 内部的服务编排系统 - borg，诞生于2014年。它汲取了google 十五年生产环境的经验积累，并融合了社区优秀的idea和实践经验。
#### 名字
Kubernetes 这个名字，起源于古希腊，是舵手的意思，所以它的 logo 即像一张渔网又像一个罗盘，谷歌选择这个名字还有一个深意：既然docker把自己比作一只鲸鱼，驮着集装箱，在大海上遨游，google 就要用Kubernetes去掌握大航海时代的话语权，去捕获和指引着这条鲸鱼按照主人设定的路线去巡游。
#### 核心
得益于 docker 的特性，服务的创建和销毁变得非常快速、简单。Kubernetes 正是以此为基础，实现了集群规模的管理、编排方案，使应用的发布、重启、扩缩容能够自动化。

## Kubernetes - 认知
#### 集群设计
Kubernetes 可以管理大规模的集群，使集群中的每一个节点彼此连接，能够像控制一台单一的计算机一样控制整个集群。

集群有两种角色，一种是 **master** ，一种是 **Node**（也叫worker）。
- **master** 是集群的"大脑"，负责管理整个集群：像应用的调度、更新、扩缩容等。
- **Node** 就是具体"干活"的，一个Node一般是一个虚拟机或物理机，它上面事先运行着 docker 服务和 kubelet 服务（ Kubernetes 的一个组件），当接收到 master 下发的"任务"后，Node 就要去完成任务（用 docker 运行一个指定的应用）

![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/01_cluster.png)

#### Deployment - 应用管理者
当我们拥有一个 Kubernetes 集群后，就可以在上面跑我们的应用了，前提是我们的应用必须支持在 docker 中运行，也就是我们要事先准备好docker镜像。

有了镜像之后，一般我们会通过Kubernetes的 **Deployment** 的配置文件去描述应用，比如应用叫什么名字、使用的镜像名字、要运行几个实例、需要多少的内存资源、cpu 资源等等。

有了配置文件就可以通过Kubernetes提供的命令行客户端 - **kubectl** 去管理这个应用了。kubectl 会跟 Kubernetes 的 master 通过RestAPI通信，最终完成应用的管理。
比如我们刚才配置好的 Deployment 配置文件叫 app.yaml，我们就可以通过
"kubectl create -f app.yaml" 来创建这个应用啦，之后就由 Kubernetes 来保证我们的应用处于运行状态，当某个实例运行失败了或者运行着应用的 Node 突然宕机了，Kubernetes 会自动发现并在新的 Node 上调度一个新的实例，保证我们的应用始终达到我们预期的结果。

![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/02_first_app.png)

#### Pod - Kubernetes最小调度单位
其实在上一步创建完 Deployment 之后，Kubernetes 的 Node 做的事情并不是简单的docker run 一个容器。出于像易用性、灵活性、稳定性等的考虑，Kubernetes 提出了一个叫做 Pod 的东西，作为 Kubernetes 的最小调度单位。所以我们的应用在每个 Node 上运行的其实是一个 Pod。Pod 也只能运行在 Node 上。如下图：
![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/03_nodes.png)

那么什么是 Pod 呢？Pod 是一组容器（当然也可以只有一个）。容器本身就是一个小盒子了，Pod 相当于在容器上又包了一层小盒子。这个盒子里面的容器有什么特点呢？
- 可以直接通过 volume 共享存储。
- 有相同的网络空间，通俗点说就是有一样的ip地址，有一样的网卡和网络设置。
- 多个容器之间可以“了解”对方，比如知道其他人的镜像，知道别人定义的端口等。

至于这样设计的好处呢，还是要大家深入学习后慢慢体会啦~
![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/03_pods.png)

#### Service - 服务发现 - 找到每个Pod
上面的 Deployment 创建了，Pod 也运行起来了。如何才能访问到我们的应用呢？

最直接想到的方法就是直接通过 Pod-ip+port 去访问，但如果实例数很多呢？好，拿到所有的 Pod-ip 列表，配置到负载均衡器中，轮询访问。但上面我们说过，Pod 可能会死掉，甚至 Pod 所在的 Node 也可能宕机，Kubernetes 会自动帮我们重新创建新的Pod。再者每次更新服务的时候也会重建 Pod。而每个 Pod 都有自己的 ip。所以 Pod 的ip 是不稳定的，会经常变化的。

面对这种变化我们就要借助另一个概念：Service。它就是来专门解决这个问题的。不管Deployment的Pod有多少个，不管它是更新、销毁还是重建，Service总是能发现并维护好它的ip列表。Service对外也提供了多种入口：
1. ClusterIP：Service 在集群内的唯一 ip 地址，我们可以通过这个 ip，均衡的访问到后端的 Pod，而无须关心具体的 Pod。
2. NodePort：Service 会在集群的每个 Node 上都启动一个端口，我们可以通过任意Node 的这个端口来访问到 Pod。
3. LoadBalancer：在 NodePort 的基础上，借助公有云环境创建一个外部的负载均衡器，并将请求转发到 NodeIP:NodePort。
4. ExternalName：将服务通过 DNS CNAME 记录方式转发到指定的域名（通过 spec.externlName 设定）。
![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/04_services.png)

好，看似服务访问的问题解决了。但大家有没有想过，Service是如何知道它负责哪些 Pod 呢？是如何跟踪这些 Pod 变化的？

最容易想到的方法是使用 Deployment 的名字。一个 Service 对应一个 Deployment 。当然这样确实可以实现。但k ubernetes 使用了一个更加灵活、通用的设计 - Label 标签，通过给 Pod 打标签，Service 可以只负责一个 Deployment 的 Pod 也可以负责多个 Deployment 的 Pod 了。Deployment 和 Service 就可以通过 Label 解耦了。
![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/04_labels.png)

#### RollingUpdate - 滚动升级
滚动升级是Kubernetes中最典型的服务升级方案，主要思路是一边增加新版本应用的实例数，一边减少旧版本应用的实例数，直到新版本的实例数达到预期，旧版本的实例数减少为0，滚动升级结束。在整个升级过程中，服务一直处于可用状态。并且可以在任意时刻回滚到旧版本。

![conv_ops](https://git.imooc.com/coding-335/course-docs/raw/master/images/05_rollingupdate.gif)

## Kubernetes - 入门实践
#### Deployment 实践
##### 首先配置好 Deployment 的配置文件（这里用的是 tomcat 镜像）  

**[ app.yaml ]**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: web
  replicas: 2
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: registry.cn-hangzhou.aliyuncs.com/liuyi01/tomcat:8.0.51-alpine
        ports:
        - containerPort: 8080
```

##### 通过 kubectl 命令创建服务

```bash
# 创建应用
$ kubectl create -f app.yaml
Deployment.apps/web created

# 等待一会后，查看 Pod 调度、运行情况。
# 我看可以看到 Pod 的名字、运行状态、Pod 的 ip、还有所在Node的名字等信息
$ kubectl get Pods -o wide
NAME                       READY     STATUS    RESTARTS   AGE   IP       NODE
web-c486dd5c4-86fxm        1/1       Running   0          1m        172.24.3.13     node-01
web-c486dd5c4-zxdbb        1/1       Running   0          1m        172.24.0.149    node-02
```

#### Service 实践
通过上面创建的 Deployment 我们还没法合理的访问到应用，下面我们就创建一个 service 作为我们访问应用的入口。  
##### 首先创建service配置  

**[ service.yaml ]**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  ports:
  - port: 80 # 服务端口
    protocol: TCP
    targetPort: 8080 # 容器端口
  selector:
    app: web # 标签选择器，这里的app=web正是我们刚才建立app
```

##### 创建服务

```bash
# 创建
$ kubectl create -f service.yaml
service/web created

# 查看
$ kubectl get service
NAME     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
web      ClusterIP   10.95.189.143   <none>        80/TCP    9s
```

##### 访问服务
接下来就可以在任意节点通过ClusterIP负载均衡的访问后端应用了

```bash
# 在任意 Node 上访问tomcat服务
$ curl -I 10.95.189.143
HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
Content-Type: text/html;charset=UTF-8
Transfer-Encoding: chunked
```

## One More Thing
好啦~ 以上就是Kubernetes入门的全部内容，看懂这篇文章，你就整体上大概了解了Kubernetes。  
想要更多、更深入的学习Kubernetes，去看我的实战课吧！
#### [《Kubernetes生产级实践指南 从部署到核心应用》][1]

[1]:https://coding.imooc.com/class/335.html
