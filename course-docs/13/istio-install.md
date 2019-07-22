# 部署面向生产的Istio
本文说明如何在kubernetes集群中部署面向生产的Istio，
- Istio版本：1.1.6
- Kubernetes版本：1.14.0
## 1. Istio 对 Pod 和服务的要求
要成为服务网格的一部分，Kubernetes 集群中的 Pod 和服务必须满足以下几个要求：

- 需要给端口正确命名
> 服务端口必须进行命名。端口名称只允许是<协议>[-<后缀>-]模式，其中<协议>部分可选择范围包括 grpc、http、http2、https、mongo、redis、tcp、tls 以及 udp，Istio 可以通过对这些协议的支持来提供路由能力。例如 name: http2-foo 和 name: http 都是有效的端口名，但 name: http2foo 就是无效的。如果没有给端口进行命名，或者命名没有使用指定前缀，那么这一端口的流量就会被视为普通 TCP 流量（除非显式的用 Protocol: UDP 声明该端口是 UDP 端口）。

- Pod 端口
> Pod 必须包含每个容器将监听的明确端口列表。在每个端口的容器规范中使用 containerPort。任何未列出的端口都将绕过 Istio Proxy。

- 关联服务
> Pod 不论是否公开端口，都必须关联到至少一个 Kubernetes 服务上，如果一个 Pod 属于多个服务，这些服务不能在同一端口上使用不同协议，例如 HTTP 和 TCP。

- Deployment 应带有 app 以及 version 标签
> 在使用 Kubernetes Deployment 进行 Pod 部署的时候，建议显式的为 Deployment 加上 app 以及 version 标签。每个 Deployment 都应该有一个有意义的 app 标签和一个用于标识 Deployment 版本的 version 标签。app 标签在分布式追踪的过程中会被用来加入上下文信息。Istio 还会用 app 和 version 标签来给遥测指标数据加入上下文信息。

- Application UID
> 不要使用 ID（UID）值为 1337 的用户来运行应用。

- NET_ADMIN 功能
> 如果您的集群中实施了 Pod 安全策略，除非您使用 Istio CNI 插件，您的 pod 必须具有NET_ADMIN功能。

## 2. 使用 Helm 进行安装
按照此流程安装和配置 Istio 网格，用于深入评估或生产环境使用。 这种安装方式使用 Helm chart 自定义 Istio 控制平面和 Istio 数据平面的 sidecar 。 你只需使用 helm template 生成配置并使用 kubectl apply 安装它，或者你可以选择使用 helm install 让 Tiller 来完全管理安装。

通过这些说明，你可以选择 Istio 内置的任何一个配置文件并根据你特定的需求进行进一步的自定义配置

#### 2.1 下载 Istio 发布包
下载地址：https://github.com/istio/istio/releases
```bash
# 进入 Istio 包目录。例如，假设这个包是 istio-1.1.7
$ cd istio-1.1.7

# 把 istioctl 客户端加入 PATH 环境变量，如果是 macOS 或者 Linux，可以这样实现：
$ export PATH=$PWD/bin:$PATH
```
> **安装目录中包含：**
在 install/ 目录中包含了 Kubernetes 安装所需的 .yaml 文件  
samples/ 目录中是示例应用  
istioctl 客户端文件保存在 bin/ 目录之中。istioctl 的功能是手工进行 Envoy Sidecar 的注入。  
istio.VERSION 配置文件  

#### 2.2 使用 helm template 进行安装
- 创建命名空间
```bash
# 为 Istio 组件创建命名空间 istio-system：
$ kubectl create namespace istio-system
```
- 安装istio-init
```bash
# 根据模板生成kubernetes配置
$ helm template install/kubernetes/helm/istio-init --name imooc-istio-init --namespace istio-system > istio-init.yaml
# 使用 kubectl apply 安装所有的 Istio CRD
$ kubectl apply -f istio-init.yaml

# 使用如下命令以确保全部 53 个 Istio CRD 被提交到 Kubernetes api-server
$ kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
53
```

- 安装istio
```bash
# 根据模板生成kubernetes配置
$ helm template install/kubernetes/helm/istio --name imooc-istio --namespace istio-system > istio.yaml

# 使用 kubectl apply 安装所有的 Istio CRD
$ kubectl apply -f istio.yaml

```

## 3. 确认安装情况
查询配置文件中的组件表, 验证 Helm 是否已经部署了与所选配置文件相对应的 Kubernetes services 服务：
```bash
$ kubectl get svc -n istio-system
```

确保部署了相应的 Kubernetes pod 并且 STATUS 是 Running的:
```bash
$ kubectl get pods -n istio-system
```

## 4. 卸载
```bash
# 删除istio
$ kubectl delete -f istio.yaml

# 删除istio-init
$ kubectl delete -f istio-init.yaml
```
