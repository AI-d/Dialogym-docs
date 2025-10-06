# 백엔드 배포 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **DevOps 엔지니어**: 백엔드 배포 파이프라인을 구축하고 관리하는 담당자
* **백엔드 개발자**: 배포 프로세스를 이해하고 문제 발생 시 대응하는 담당자
* **인프라 관리자**: EC2, RDS, K8s 클러스터를 관리하는 책임자

---

## 핵심 요약 (Executive Summary)

본 문서는 dialogym 백엔드 애플리케이션의 배포 절차를 정의합니다.
백엔드는 Java/Spring Boot 애플리케이션을 Gradle로 빌드하여 JAR 파일을 생성합니다.
Docker 이미지로 패키징하여 AWS ECR에 푸시하고, Kubernetes에서 배포합니다.
dev 브랜치는 Staging 환경, main 브랜치는 Production 환경으로 자동 배포됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [배포 환경](#배포-환경)
3. [Gradle 빌드](#gradle-빌드)
4. [Docker 이미지 빌드](#docker-이미지-빌드)
5. [ECR 푸시](#ecr-푸시)
6. [Kubernetes 배포](#kubernetes-배포)
7. [RDS 연결](#rds-연결)
8. [GitHub Actions 워크플로우](#github-actions-워크플로우)
9. [배포 확인](#배포-확인)

---

## 문서 개요 (Overview)

본 문서는 백엔드 배포 프로세스를 명확히 하기 위해 작성되었습니다.

수동 배포는 시간이 오래 걸리고, 설정 실수가 발생하며, 환경 간 불일치가 생길 수 있습니다. 이를 방지하기 위해 Docker와 Kubernetes를 활용한 자동화된 배포 파이프라인을 구축합니다.

---

## 배포 환경

### Staging 환경

```yaml
브랜치: dev
클러스터: dialogym-k8s-staging
네임스페이스: staging
도메인: api-staging.dialogym.com
RDS: dialogym-staging-db
인스턴스: 1개 (최소)
```

### Production 환경

```yaml
브랜치: main
클러스터: dialogym-k8s-production
네임스페이스: production
도메인: api.dialogym.com
RDS: dialogym-production-db
인스턴스: 2개 (최소, Auto-scaling)
```

---

## Gradle 빌드

### build.gradle

```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.0'
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'com.dialogym'
version = '0.0.1-SNAPSHOT'

java {
    sourceCompatibility = '17'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    runtimeOnly 'org.postgresql:postgresql'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
}

tasks.named('test') {
    useJUnitPlatform()
}

bootJar {
    archiveFileName = 'app.jar'
}
```

### 로컬 빌드

```bash
cd backend

# 의존성 다운로드
./gradlew dependencies

# 테스트 실행
./gradlew test

# JAR 빌드 (테스트 제외)
./gradlew bootJar -x test

# 빌드 결과 확인
ls -lh build/libs/app.jar
```

### 로컬 실행

```bash
# JAR 실행
java -jar build/libs/app.jar

# 프로파일 지정
java -jar -Dspring.profiles.active=local build/libs/app.jar

# 환경 변수 설정
DATABASE_URL=postgresql://localhost:5432/dialogym \
JWT_SECRET=local-secret \
java -jar build/libs/app.jar
```

---

## Docker 이미지 빌드

### Dockerfile

`backend/Dockerfile`:

```dockerfile
# Build stage
FROM gradle:8-jdk17 AS builder

WORKDIR /app

# Gradle 설정 파일 복사
COPY build.gradle settings.gradle ./
COPY gradle ./gradle

# 의존성 캐싱 (소스 변경 시 재다운로드 방지)
RUN gradle dependencies --no-daemon

# 소스 코드 복사
COPY src ./src

# JAR 빌드
RUN gradle bootJar -x test --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 보안: non-root 유저 생성
RUN addgroup -g 1001 spring && \
    adduser -D -u 1001 -G spring spring

# JAR 파일 복사
COPY --from=builder --chown=spring:spring /app/build/libs/app.jar app.jar

# 유저 전환
USER spring

# 포트 노출
EXPOSE 8080

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# 실행
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

### .dockerignore

```
.gradle
build
bin
.git
.env
.env.*
*.log
.DS_Store
```

### 로컬 빌드 테스트

```bash
cd backend

# 이미지 빌드
docker build -t dialogym-backend:local .

# 로컬 실행
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:postgresql://host.docker.internal:5432/dialogym" \
  -e SPRING_DATASOURCE_USERNAME="dbuser" \
  -e SPRING_DATASOURCE_PASSWORD="dbpass" \
  -e JWT_SECRET="local-secret" \
  dialogym-backend:local

# 헬스체크
curl http://localhost:8080/actuator/health
```

---

## ECR 푸시

### ECR 리포지토리 생성

```bash
aws ecr create-repository \
  --repository-name dialogym-backend \
  --region ap-northeast-2 \
  --image-scanning-configuration scanOnPush=true
```

### 수동 푸시 (테스트용)

```bash
# AWS 로그인
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com

# 이미지 태깅
docker tag dialogym-backend:local \
  <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/dialogym-backend:latest

# 푸시
docker push <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/dialogym-backend:latest
```

---

## Kubernetes 배포

### application.yml 설정

`backend/src/main/resources/application.yml`:

```yaml
spring:
  application:
    name: dialogym-backend

  datasource:
    url: ${SPRING_DATASOURCE_URL}
    username: ${SPRING_DATASOURCE_USERNAME}
    password: ${SPRING_DATASOURCE_PASSWORD}
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: true

jwt:
  secret: ${JWT_SECRET}
  expiration: 3600000

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized
```

### Namespace 생성

```bash
kubectl create namespace staging
kubectl create namespace production
```

### Deployment 매니페스트

`k8s/backend-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: production
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/dialogym-backend:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        - name: SPRING_DATASOURCE_URL
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: datasource-url
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: datasource-username
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: datasource-password
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: jwt-secret
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: production
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

### Secret 생성

```bash
# Staging
kubectl create secret generic backend-secrets \
  --from-literal=datasource-url="jdbc:postgresql://dialogym-staging-db.xxxxx.ap-northeast-2.rds.amazonaws.com:5432/dialogym" \
  --from-literal=datasource-username="dbadmin" \
  --from-literal=datasource-password="staging-password" \
  --from-literal=jwt-secret="staging-jwt-secret" \
  --namespace=staging

# Production
kubectl create secret generic backend-secrets \
  --from-literal=datasource-url="jdbc:postgresql://dialogym-production-db.xxxxx.ap-northeast-2.rds.amazonaws.com:5432/dialogym" \
  --from-literal=datasource-username="dbadmin" \
  --from-literal=datasource-password="production-password" \
  --from-literal=jwt-secret="production-jwt-secret" \
  --namespace=production
```

### Ingress 설정

`k8s/backend-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
spec:
  tls:
  - hosts:
    - api.dialogym.com
    secretName: backend-tls
  rules:
  - host: api.dialogym.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
```

### 배포 명령

```bash
# Staging
kubectl apply -f k8s/backend-deployment.yaml --namespace=staging
kubectl apply -f k8s/backend-ingress.yaml --namespace=staging

# Production
kubectl apply -f k8s/backend-deployment.yaml --namespace=production
kubectl apply -f k8s/backend-ingress.yaml --namespace=production
```

---

## RDS 연결

### RDS 엔드포인트

```yaml
Staging:
  Host: dialogym-staging-db.xxxxx.ap-northeast-2.rds.amazonaws.com
  Port: 5432
  Database: dialogym_staging
  User: dbadmin

Production:
  Host: dialogym-production-db.xxxxx.ap-northeast-2.rds.amazonaws.com
  Port: 5432
  Database: dialogym_production
  User: dbadmin
```

### 보안 그룹 설정

```bash
# RDS 보안 그룹에 K8s Worker Node SG 추가
aws ec2 authorize-security-group-ingress \
  --group-id <RDS-SG-ID> \
  --protocol tcp \
  --port 5432 \
  --source-group <K8s-Worker-SG-ID>
```

### 연결 테스트

```bash
# Pod에서 직접 테스트
kubectl run -it --rm psql-client \
  --image=postgres:15 \
  --restart=Never \
  --namespace=production \
  -- psql -h dialogym-production-db.xxxxx.ap-northeast-2.rds.amazonaws.com \
        -U dbadmin -d dialogym_production
```

---

## GitHub Actions 워크플로우

`.github/workflows/deploy-backend.yml`:

```yaml
name: Deploy Backend

on:
  push:
    branches: [dev, main]
    paths:
      - 'backend/**'
      - 'k8s/backend-*.yaml'
      - '.github/workflows/deploy-backend.yml'

env:
  AWS_REGION: ap-northeast-2
  ECR_REPOSITORY: dialogym-backend

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Grant execute permission for gradlew
        run: chmod +x ./gradlew
        working-directory: ./backend

      - name: Run tests
        run: ./gradlew test
        working-directory: ./backend

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        working-directory: ./backend
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'

      - name: Configure kubectl
        run: |
          aws eks update-kubeconfig \
            --region ${{ env.AWS_REGION }} \
            --name dialogym-k8s-cluster

      - name: Deploy to Staging
        if: github.ref == 'refs/heads/dev'
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          kubectl set image deployment/backend-deployment \
            backend=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG \
            --namespace=staging \
            --record
          kubectl rollout status deployment/backend-deployment --namespace=staging

      - name: Deploy to Production
        if: github.ref == 'refs/heads/main'
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          kubectl set image deployment/backend-deployment \
            backend=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG \
            --namespace=production \
            --record
          kubectl rollout status deployment/backend-deployment --namespace=production

      - name: Verify deployment
        run: |
          NAMESPACE=${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
          kubectl get pods --namespace=$NAMESPACE
          kubectl get services --namespace=$NAMESPACE

      - name: Notify Slack
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "${{ job.status == 'success' && '✅' || '❌' }} Backend 배포 ${{ job.status }}: ${{ github.ref_name }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Backend 배포*\n브랜치: `${{ github.ref_name }}`\n상태: ${{ job.status }}\n커밋: ${{ github.sha }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

---

## 배포 확인

### Pod 상태 확인

```bash
# Staging
kubectl get pods --namespace=staging
kubectl logs -f <pod-name> --namespace=staging

# Production
kubectl get pods --namespace=production
kubectl logs -f <pod-name> --namespace=production
```

### 서비스 엔드포인트 확인

```bash
# Staging
curl https://api-staging.dialogym.com/actuator/health

# Production
curl https://api.dialogym.com/actuator/health
```

### 배포 히스토리 확인

```bash
kubectl rollout history deployment/backend-deployment --namespace=production
```

---

## 관련 문서

* [CI/CD 통합](ci-cd-integration.md)
* [프론트엔드 배포](deployment-frontend.md)
* [롤백 가이드](rollback-guide.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
