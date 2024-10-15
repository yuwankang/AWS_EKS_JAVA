
# 🚀 AWS EKS에서 Spring Boot 애플리케이션 배포

Docker, Kubernetes, 그리고 AWS ECR을 사용하여 Spring Boot 애플리케이션을 Amazon EKS(Elastic Kubernetes Service)에 배포

---

## 📋 목차
- **1.개요**
- **2. 사전 준비**
- **3. 기술 스택**
- **4 .AWS CLI 설정**
- **5. AWS EKS 설정**
- **6. Spring Boot 애플리케이션 Dockerize**
- **7. Amazon ECR 설정**
- **8. Kubernetes 배포**
- **9. 배포 성공 및 실행**
- **10. 결론**

---

## 📝 개요

> Docker, Kubernetes, 그리고 AWS ECR을 사용하여 Spring Boot 애플리케이션을 Amazon EKS(Elastic Kubernetes Service)에 배포

---

## 🔧 사전 준비

- AWS CLI 설치 및 구성
- Docker 설치
- `kubectl` 설치
- `eksctl` 설치

---

## 🛠️ 기술 스택

- 프로그래밍 언어: Java 17 <img src="https://upload.wikimedia.org/wikipedia/en/3/30/Java_programming_language_logo.svg" alt="Java Logo" width="20"/>
- 프레임워크: Spring Boot <img src="https://img.icons8.com/color/48/000000/spring-logo.png" alt="Spring Boot Logo" width="20"/>
- 컨테이너화 도구: Docker <img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" alt="Docker Logo" width="20"/>
- 클러스터 관리: Kubernetes <img src="https://upload.wikimedia.org/wikipedia/commons/3/39/Kubernetes_logo_without_workmark.svg" alt="Kubernetes Logo" width="20"/>
- 클라우드 플랫폼: AWS EKS <img src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" alt="AWS EKS Logo" width="20"/>
- 이미지 레지스트리: AWS ECR <img src="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg" alt="AWS ECR Logo" width="20"/>

---

## ⚙️ AWS CLI 설정

1. [AWS CLI 설치 가이드](https://aws.amazon.com/ko/cli/)를 참고하여 설치 후 버전을 확인합니다.
```bash
aws configure
```
2. EC2 인스턴스의 정보를 확인합니다.
```bash
aws ec2 describe-instances
```

---

## ☁️ AWS EKS 설정

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

## 🐳 Spring Boot 애플리케이션 Dockerize

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

## 🗂️ Amazon ECR 설정
![](https://velog.velcdn.com/images/yuwankang/post/5d8bfabd-047c-493e-8aa3-3d04c9f01f6e/image.png)
![](https://velog.velcdn.com/images/yuwankang/post/c0045e5b-4dc3-4743-b9eb-22f249f97e2e/image.png)
![](https://velog.velcdn.com/images/yuwankang/post/964f4fc0-7c0c-4329-93ae-14d90eb27954/image.png)

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

## 🛠️ Kubernetes 배포

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

## ✅ 배포 성공 및 실행

AWS EKS 클러스터에서 애플리케이션이 성공적으로 배포된 것을 확인할 수 있습니다. 다음 명령어로 서비스와 배포 상태를 확인하세요.
```bash
kubectl get svc
kubectl get deployment
kubectl get pods
```
![](https://velog.velcdn.com/images/yuwankang/post/f10efbda-c173-4b09-bf50-af9752293fdd/image.png)
![](https://velog.velcdn.com/images/yuwankang/post/5366e37f-1c60-4405-8cb0-97adad252921/image.png)
---

## 🗑️ 클러스터 삭제

```bash
eksctl delete cluster --name ce01-myeks --region ${AWS_REGION}
```


---

## 💡 결론

>AWS EKS 환경에서 Spring Boot 애플리케이션을 성공적으로 배포하고 관리할 수 있습니다. Kubernetes와 ECR을 통해 애플리케이션의 확장성과 유지보수성을 높일 수 있습니다.
