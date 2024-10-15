
# AWS EKS에서 Spring Boot 애플리케이션 배포

이 가이드는 Docker, Kubernetes, 그리고 AWS ECR을 사용하여 Spring Boot 애플리케이션을 Amazon EKS(Elastic Kubernetes Service)에 배포하는 방법을 설명합니다.

## 목차
1. [개요](#개요)
2. [사전 준비](#사전-준비)
3. [AWS CLI 설정](#aws-cli-설정)
4. [AWS EKS 설정](#aws-eks-설정)
5. [Spring Boot 애플리케이션 Dockerize](#spring-boot-애플리케이션-dockerize)
6. [Amazon ECR 설정](#amazon-ecr-설정)
7. [Kubernetes 배포](#kubernetes-배포)
8. [배포 성공 및 실행](#배포-성공-및-실행)
9. [결론](#결론)

---

## 개요

이 문서는 AWS의 EKS를 활용하여 Spring Boot 애플리케이션을 배포하고, Kubernetes와 Docker를 통해 애플리케이션을 컨테이너화하는 방법을 설명합니다. 또한, ECR을 사용하여 도커 이미지를 관리하고, 배포 파이프라인을 설정하는 방법도 포함되어 있습니다.

---

## 사전 준비

- AWS CLI 설치 및 구성
- Docker 설치
- `kubectl` 설치
- `eksctl` 설치

---

## AWS CLI 설정

1. [AWS CLI 설치 가이드](https://aws.amazon.com/ko/cli/)를 참고하여 설치 후 버전을 확인합니다.
```bash
aws configure
```
2. EC2 인스턴스의 정보를 확인합니다.
```bash
aws ec2 describe-instances
```

---

## AWS EKS 설정

1. `kubectl` 설치
```bash
sudo curl -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.4/2023-05-11/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
kubectl version --client=true --short=true
```

2. `eksctl` 설치
```bash
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/eksctl /usr/local/bin
eksctl version
```

3. EKS 클러스터 생성
```bash
export AWS_REGION=ap-northeast-2
eksctl create cluster --name ce01-myeks --region ap-northeast-2
```

---

## Spring Boot 애플리케이션 Dockerize

1. `Dockerfile` 작성
```Dockerfile
FROM openjdk:17
ADD SpringApp-0.0.1-SNAPSHOT.jar spring-eks.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "spring-eks.jar"]
```

2. Docker 이미지 빌드
```bash
docker build -t springboot-eks .
```

---

## Amazon ECR 설정

1. AWS CLI를 통해 ECR 로그인
```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

2. Docker 이미지 ECR로 푸시
```bash
docker tag ce01-spring-eks:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/ce01-spring-eks:latest
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/ce01-spring-eks:latest
```

3. EKS 클러스터 설정 업데이트
```bash
aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
```

---

## Kubernetes 배포

1. `k8s.yaml` 작성 및 적용
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: newapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: newapp
  template:
    metadata:
      labels:
        app: newapp
    spec:
      containers:
        - name: newapp
          image: <ECR:URL>/ce01-spring-eks:latest
          ports:
            - containerPort: 8899
---
apiVersion: v1
kind: Service
metadata:
  name: newapp-service
spec:
  selector:
    app: newapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8899
  type: LoadBalancer
```

2. Kubernetes 명령어 실행
```bash
kubectl apply -f k8s.yaml
kubectl get svc
kubectl get deployment
kubectl get pods
```

---

## 배포 성공 및 실행

AWS EKS 클러스터에서 애플리케이션이 성공적으로 배포된 것을 확인할 수 있습니다. 다음 명령어로 서비스와 배포 상태를 확인하세요.
```bash
kubectl get svc
kubectl get deployment
kubectl get pods
```

---

## 결론

이 가이드를 통해 AWS EKS 환경에서 Spring Boot 애플리케이션을 성공적으로 배포하고 관리할 수 있습니다. Kubernetes와 ECR을 통해 애플리케이션의 확장성과 유지보수성을 높일 수 있습니다. 클러스터 삭제는 아래 명령어를 사용하세요:
```bash
eksctl delete cluster --name ce01-myeks --region ${AWS_REGION}
```
