# 部署 Bookinfo 示例应用

## 1. 简介
部署一个样例应用，它由四个单独的微服务构成，用来演示多种 Istio 特性。这个应用模仿在线书店的一个分类，显示一本书的信息。页面上会显示一本书的描述，书籍的细节（ISBN、页数等），以及关于这本书的一些评论。

Bookinfo 应用分为四个单独的微服务：

Bookinfo 应用分为四个单独的微服务：

- productpage ：productpage 微服务会调用 details 和 reviews 两个微服务，用来生成页面。
- details ：这个微服务包含了书籍的信息。
- reviews ：这个微服务包含了书籍相关的评论。它还会调用 ratings 微服务。
- ratings ：ratings 微服务中包含了由书籍评价组成的评级信息。
- reviews 微服务有 3 个版本：

> v1 版本不会调用 ratings 服务。
> v2 版本会调用 ratings 服务，并使用 1 到 5 个黑色星形图标来显示评分信息。
> v3 版本会调用 ratings 服务，并使用 1 到 5 个红色星形图标来显示评分信息。

下图展示了这个应用的端到端架构。
![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/13_bookinfo_1.png)
Bookinfo 是一个异构应用，几个微服务是由不同的语言编写的。这些服务对 Istio 并无依赖，但是构成了一个有代表性的服务网格的例子：它由多个服务、多个语言构成，并且 reviews 服务具有多个版本。

## 2. 部署应用
要在 Istio 中运行这一应用，无需对应用自身做出任何改变。我们只要简单的在 Istio 环境中对服务进行配置和运行，具体一点说就是把 Envoy sidecar 注入到每个服务之中。这个过程所需的具体命令和配置方法由运行时环境决定，而部署结果较为一致，如下图所示：
![avatar](https://git.imooc.com/coding-335/course-docs/raw/master/images/13_bookinfo_2.png)

所有的微服务都和 Envoy sidecar 集成在一起，被集成服务所有的出入流量都被 sidecar 所劫持，这样就为外部控制准备了所需的 Hook，然后就可以利用 Istio 控制平面为应用提供服务路由、遥测数据收集以及策略实施等功能。

接下来可以根据 Istio 的运行环境，按照下面的讲解完成应用的部署。

#### 2.1 部署
```bash
# 进入 Istio 安装目录。
# Istio 默认启用自动 Sidecar 注入，为 default 命名空间打上标签 istio-injection=enabled。
$ kubectl label namespace default istio-injection=enabled

# 下载配置
# 地址：https://git.imooc.com/coding-335/deep-in-kubernetes/raw/master/13-istio/demo/bookinfo.yaml
# 使用 kubectl 部署简单的服务
$ kubectl apply -f bookinfo.yaml
```

#### 2.2 部署结果检查

确认所有的服务和 Pod 都已经正确的定义和启动
```bash
# service列表
$ kubectl get services
NAME                       CLUSTER-IP   EXTERNAL-IP   PORT(S)              AGE
details                    10.0.0.31    <none>        9080/TCP             6m
kubernetes                 10.0.0.1     <none>        443/TCP              7d
productpage                10.0.0.120   <none>        9080/TCP             6m
ratings                    10.0.0.15    <none>        9080/TCP             6m
reviews                    10.0.0.170   <none>        9080/TCP             6m

# pod列表
$ kubectl get pods
NAME                                        READY     STATUS    RESTARTS   AGE
details-v1-1520924117-48z17                 2/2       Running   0          6m
productpage-v1-560495357-jk1lz              2/2       Running   0          6m
ratings-v1-734492171-rnr5l                  2/2       Running   0          6m
reviews-v1-874083890-f0qf0                  2/2       Running   0          6m
reviews-v2-1343845940-b34q5                 2/2       Running   0          6m
reviews-v3-1813607990-8ch52                 2/2       Running   0          6m
```

要确认 Bookinfo 应用程序正在运行，请通过某个 pod 中的 curl 命令向其发送请求，例如来自 ratings：
```bash
$ kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
<title>Simple Bookstore App</title>
```

#### 2.3 部署BookIno-Gateway
```bash
# 先下载配置文件
# 地址：https://git.imooc.com/coding-335/deep-in-kubernetes/raw/master/13-istio/demo/bookinfo-gateway.yaml
# 为应用程序定义入口网关
$ kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
# 确认网关创建完成
$ kubectl get gateway
NAME               AGE
bookinfo-gateway   32s

# 访问测试服务
$ curl <INGRESS-IP>:<INGRESS-PORT>/productpage
```
