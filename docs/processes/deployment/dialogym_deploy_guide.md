# dialogym 배포 가이드 (Windows 환경 - 추천 아키텍처)

**담당자 (Author)**: [김경민](https://github.com/minee0505)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.30

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

> **대상**: Windows 환경에서 AWS 브라우저로 배포하는 초보자  
> **방식**: PuTTY + PPK 키 사용, AWS 콘솔(브라우저)로 진행  
> **아키텍처**: CloudFront/S3(프론트) + EC2/Docker(백엔드) + RDS(DB)

---

## 최종 아키텍처

```
사용자 브라우저
   ↓
www.dialogym.shop (도메인)
   ↓
Route 53 (DNS)
   ↓
┌─────────────────┴──────────────────┐
│                                    │
▼                                    ▼
┌─────────────────┐      ┌─────────────────────┐
│  CloudFront     │      │   탄력적 IP          │
│      +          │      │  (고정 IP 주소)      │
│     S3          │      └─────────────────────┘
│  (프론트엔드)     │                 ↓
└─────────────────┘      ┌─────────────────────┐
                        │   EC2 인스턴스       │
                        │  (t3.small 1대)    │
                        │                     │
                        │  ┌───────────────┐  │
                        │  │ Nginx         │  │
                        │  │ (80, 443)     │  │
                        │  └───────────────┘  │
                        │         ↓           │
                        │  ┌───────────────┐  │
                        │  │Docker Compose │  │
                        │  │               │  │
                        │  │ ┌─────────┐  │  │
                        │  │ │Backend  │  │  │
                        │  │ │(9090)   │  │  │
                        │  │ └─────────┘  │  │
                        │  └───────────────┘  │
                        └─────────────────────┘
                                   ↓
                        ┌─────────────────────┐
                        │   RDS (MariaDB)     │
                        │  (Private Subnet)   │
                        └─────────────────────┘
```

**특징**:
- 프론트엔드: S3 + CloudFront (정적 파일 배포, CDN 가속)
- 백엔드: EC2 + Docker (Spring Boot 컨테이너)
- 데이터베이스: RDS (관리형 MariaDB)
- 탄력적 IP: EC2 고정 IP
- Nginx: 리버스 프록시 + SSL 인증서

**예상 비용**: 월 약 $50~70

---

## 배포 순서

```
1단계: EC2 인스턴스 생성
2단계: 탄력적 IP 할당
3단계: RDS (MariaDB) 생성
4단계: 도메인 연결 (Route 53)
5단계: EC2 환경 설정 (Docker 설치)
6단계: 백엔드 배포 (Docker)
7단계: Nginx 설정
8단계: SSL 인증서 발급
9단계: 프론트엔드 배포 (S3 + CloudFront)
10단계: 최종 테스트
```

---

## 필요한 프로그램 (Windows)

### 1. PuTTY (SSH 접속)
- 다운로드: https://www.putty.org/
- 파일: `putty-64bit-0.XX-installer.msi`
- 설치: 기본 옵션으로 진행

### 2. WinSCP (파일 전송)
- 다운로드: https://winscp.net/
- 설치: 기본 옵션으로 진행

### 3. AWS CLI
- 다운로드: https://aws.amazon.com/cli/
- Windows용 MSI 설치 파일

---

## 1단계: EC2 인스턴스 생성

### 1.1 AWS 콘솔 접속
1. 크롬 브라우저 실행
2. https://console.aws.amazon.com/ 접속
3. 로그인
4. 상단 검색창: **"EC2"** 입력 → 클릭

---

### 1.2 인스턴스 시작
1. 왼쪽 메뉴 → **"인스턴스"**
2. 오른쪽 상단 → **"인스턴스 시작"** 버튼

---

### 1.3 인스턴스 설정

#### 이름 및 태그
```
이름: dialogym-backend-server
```

#### 애플리케이션 및 OS 이미지
```
OS: Amazon Linux 2023
아키텍처: 64비트 (x86)
```

#### 인스턴스 유형
```
유형: t3.medium
vCPU: 2
메모리: 4GB
```

**왜 t3.medium?**
- Docker + Spring Boot + Nginx 동시 실행 가능
- t2.micro는 메모리 부족으로 빌드 실패 위험

---

#### 키 페어 (중요!)
1. **"새 키 페어 생성"** 클릭
2. 설정:
    - 키 페어 이름: `dialogym-key`
    - 키 페어 유형: **RSA**
    - 프라이빗 키 파일 형식: **`.ppk`** ← 윈도우용!
3. **"키 페어 생성"** 클릭
4. **`dialogym-key.ppk`** 파일 자동 다운로드
5. 파일 저장 위치 (예시):
   ```
   C:\Users\내이름\Documents\AWS\dialogym-key.ppk
   ```

**주의**: 이 파일 분실 시 재발급 불가! 안전한 곳에 보관하세요.

---

#### 네트워크 설정

**보안 그룹 규칙:**

| 유형 | 프로토콜 | 포트 | 소스 | 설명 |
|------|----------|------|------|------|
| SSH | TCP | 22 | 내 IP | PuTTY 접속용 |
| HTTP | TCP | 80 | 0.0.0.0/0 | 웹 트래픽 |
| HTTPS | TCP | 443 | 0.0.0.0/0 | SSL 트래픽 |

**설정 방법:**
1. "보안 그룹 규칙 추가" 클릭
2. **HTTP 규칙:**
    - 유형: HTTP
    - 소스: Anywhere (0.0.0.0/0)
3. "보안 그룹 규칙 추가" 클릭
4. **HTTPS 규칙:**
    - 유형: HTTPS
    - 소스: Anywhere (0.0.0.0/0)

SSH는 "내 IP"로 자동 설정됨 (보안상 안전)

---

#### 스토리지 구성
```
크기: 20 GiB
유형: gp3 (SSD)
```

---

### 1.4 인스턴스 시작
1. 오른쪽 하단 **"인스턴스 시작"** 버튼
2. "시작됨" 메시지 확인
3. **"인스턴스 보기"** 클릭

---

### 1.5 인스턴스 실행 확인
1. 인스턴스 목록에서 `dialogym-backend-server` 찾기
2. "인스턴스 상태" → **"실행 중"** 대기 (1~2분)
3. 퍼블릭 IPv4 주소 메모 (예: `3.xx.xxx.45`)

---

## 2단계: 탄력적 IP 할당 및 연결

### 2.1 탄력적 IP란?
- 일반 IP: 재시작하면 바뀜
- **탄력적 IP**: 고정 IP, 재시작해도 유지, **EC2 사용 중일 때 무료!**

---

### 2.2 탄력적 IP 할당

1. EC2 대시보드 왼쪽 메뉴
2. **"네트워크 및 보안"** → **"탄력적 IP"**
3. 오른쪽 상단 → **"탄력적 IP 주소 할당"**
4. 설정:
    - 네트워크 경계 그룹: **ap-northeast-2** (서울)
    - IPv4 주소 풀: **Amazon의 IPv4 주소 풀**
5. **"할당"** 버튼 클릭
6. 할당된 IP 메모 (예: `13.xxx.xxx.56`)

---

### 2.3 EC2에 연결

1. 할당된 탄력적 IP 선택 (체크박스)
2. 상단 **"작업"** → **"탄력적 IP 주소 연결"**
3. 설정:
    - 리소스 유형: **인스턴스**
    - 인스턴스: **dialogym-backend-server** 선택
    - 프라이빗 IP: (자동)
4. **"연결"** 버튼

---

### 2.4 연결 확인

1. 인스턴스 목록으로 이동
2. `dialogym-backend-server` 선택
3. 하단 "세부 정보" 탭:
    - 퍼블릭 IPv4 주소 → 탄력적 IP로 변경 확인
    - 탄력적 IP 항목 표시 확인

---

### 2.5 PuTTY로 SSH 접속 테스트

#### PuTTY 실행 및 설정
1. Windows 시작 메뉴 → **"PuTTY"** 실행
2. 설정 화면:
    - **Session 탭:**
        - Host Name: `ec2-user@13.xxx.xxx.56` (탄력적 IP)
        - Port: `22`
        - Connection type: **SSH**

    - **Connection → SSH → Auth → Credentials:**
        - "Private key file for authentication" → **Browse**
        - `dialogym-key.ppk` 파일 선택

    - **Session 탭으로 돌아가기:**
        - Saved Sessions: `dialogym-server` 입력
        - **"Save"** 버튼 클릭 (다음부터 로드해서 사용)

3. **"Open"** 버튼 클릭

#### 첫 접속 시 보안 경고
```
The server's host key is not cached in the registry...
Accept? (y/n)
```
→ **"예(Yes)"** 클릭

#### 접속 성공 화면
```
Amazon Linux 2023

   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'

Last login: Sat Oct 24 12:34:56 2025
[ec2-user@ip-xxx-xxx-xxx-xxx ~]$
```

**성공!** 이제 EC2 서버에 접속되었습니다.

---

## 3단계: RDS (MariaDB) 생성

### 3.1 RDS란?
- **RDS**: AWS 관리형 데이터베이스
- **장점**: 자동 백업, 자동 업데이트, 고가용성
- **EC2에 직접 설치 vs RDS**: RDS가 관리 편함

---

### 3.2 RDS 콘솔 접속
1. AWS 콘솔 검색창 → **"RDS"** 입력
2. **"데이터베이스 생성"** 버튼 클릭

---

### 3.3 데이터베이스 설정

#### 데이터베이스 생성 방식
```
방식: 표준 생성
```

#### 엔진 옵션
```
엔진 유형: MariaDB
버전: MariaDB 10.11.14
```

#### 템플릿
```
템플릿: 프리 티어 (처음이면 무료!)
```

프리 티어 아니면 **"개발/테스트"** 선택

---

#### 설정
```
DB 인스턴스 식별자: dialogym-db
마스터 사용자 이름: admin
마스터 암호: YourSecurePassword123!
암호 확인: YourSecurePassword123!
```

**암호 메모 필수!** 나중에 백엔드 연결할 때 사용

---

#### DB 인스턴스 크기
```
인스턴스 클래스: db.t4g.micro (ARM 기반, db.t3.micro보다 더 저렴하고 빠름)
```

---

#### 스토리지
```
스토리지 유형: 범용 SSD (gp3)
할당된 스토리지: 20 GiB
스토리지 자동 조정: 활성화 (체크)
```

---

#### 연결

**VPC 및 서브넷:**
```
Virtual Private Cloud (VPC): 기본 VPC 선택
서브넷 그룹: 기본 그룹
퍼블릭 액세스: 아니요 (보안상 중요!)
```

**VPC 보안 그룹:**
- "새 VPC 보안 그룹 생성" 선택
- 이름: `dialogym-db-sg`

---

#### 데이터베이스 인증
```
데이터베이스 인증: 암호 인증
```

---

#### 추가 구성

**초기 데이터베이스 이름:**
```
초기 데이터베이스 이름: dialogym
```

**백업:**
```
자동 백업 활성화: 체크
백업 보존 기간: 7일
```

**유지 관리:**
```
자동 마이너 버전 업그레이드: 활성화
```

---

### 3.4 데이터베이스 생성
1. 하단 **"데이터베이스 생성"** 버튼 클릭
2. 생성 완료까지 **5~10분** 대기
3. 상태가 **"사용 가능"**으로 변경될 때까지 기다리기

---

### 3.5 RDS 엔드포인트 확인

1. RDS 대시보드 → **"데이터베이스"**
2. `dialogym-db` 선택
3. **"연결 및 보안"** 탭에서 확인:
   ```
   엔드포인트: dialogym-db.c1a2b3c4d5e6.ap-northeast-2.rds.amazonaws.com
   포트: 3306
   ```
4. 엔드포인트 주소 복사해서 메모장에 저장

---

### 3.6 보안 그룹 설정 (EC2 → RDS 연결 허용)

#### RDS 보안 그룹 수정
1. RDS 대시보드 → `dialogym-db` 선택
2. "VPC 보안 그룹" 클릭 (예: `dialogym-db-sg`)
3. "인바운드 규칙" 탭 → **"인바운드 규칙 편집"**
4. **"규칙 추가"** 클릭:
    - 유형: **MySQL/Aurora**
    - 프로토콜: TCP
    - 포트: 3306
    - 소스: **사용자 지정** → EC2의 보안 그룹 선택
      (또는 EC2의 프라이빗 IP 입력)
5. **"규칙 저장"** 클릭

이제 EC2에서 RDS로 접근 가능합니다!

---

## 4단계: 도메인 연결 (Route 53)

### 4.1 Route 53이란?
- AWS의 DNS 서비스
- 도메인 이름을 IP 주소로 연결

---

### 4.2 호스팅 영역 생성 (Route 53)

1. AWS 콘솔 → **"Route 53"** 검색
2. 왼쪽 메뉴 → **"호스팅 영역"**
3. **"호스팅 영역 생성"** 버튼 클릭
4. 설정:
    - 도메인 이름: `dialogym.shop`
    - 유형: **퍼블릭 호스팅 영역**
5. **"호스팅 영역 생성"** 버튼

---

### 4.3 네임서버 설정 (도메인 구매 업체)

#### Route 53에서 네임서버 확인
1. `dialogym.shop` 호스팅 영역 클릭
2. **"NS"** 레코드 확인:
   ```
   ns-123.awsdns-12.com
   ns-456.awsdns-34.net
   ns-789.awsdns-56.org
   ns-101.awsdns-78.co.uk
   ```
3. 이 4개 네임서버 복사

#### 도메인 구매 업체에서 설정

**가비아인 경우:**
1. https://www.gabia.com/ 로그인
2. My가비아 → 도메인 관리
3. `dialogym.shop` 선택 → **"관리"**
4. **"네임서버 설정"** 클릭
5. "호스팅 네임서버" → **"1차~4차 네임서버"** 입력
6. Route 53 네임서버 4개 입력
7. **"적용"** 클릭

**호스팅케이알인 경우:**
1. 로그인 → 도메인 관리
2. `dialogym.shop` 선택
3. 네임서버 변경
4. Route 53 네임서버 입력

**전파 시간**: 5분~30분 소요

---

### 4.4 A 레코드 추가 (백엔드용)

Route 53 호스팅 영역에서:

1. **"레코드 생성"** 버튼
2. 설정:
    - 레코드 이름: `api`
    - 레코드 유형: **A**
    - 값: `13.xxx.xxx.56` (탄력적 IP)
    - TTL: `300` (5분)
    - 라우팅 정책: **단순 라우팅**
3. **"레코드 생성"** 버튼

결과: `api.dialogym.shop` → EC2 연결

---

### 4.5 DNS 전파 확인

Windows PowerShell 실행:
```powershell
nslookup api.dialogym.shop
```

**성공 예시:**
```
이름:    api.dialogym.shop
Address:  13.xxx.xxx.56
```

이제 도메인으로 접속 가능합니다.

---

## 5단계: EC2 환경 설정 (Docker 설치)

### 5.1 PuTTY로 EC2 접속
1. PuTTY 실행
2. Saved Sessions → `dialogym-server` 선택
3. **"Load"** → **"Open"**

---

### 5.2 시스템 업데이트
```bash
sudo yum update -y
```
완료까지 1~2분 대기

---

### 5.3 Docker 설치
```bash
# Docker 설치
sudo yum install -y docker

# Docker 서비스 시작
sudo systemctl start docker

# 부팅 시 자동 시작 설정
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker ec2-user
```

---

### 5.4 재접속 (권한 적용)
```bash
exit
```
PuTTY 다시 접속

---

### 5.5 Docker 설치 확인
```bash
docker --version
```
**출력 예시:**
```
Docker version 25.0.3, build 1234abcd
```

---

### 5.6 Docker Compose 설치
```bash
# Docker Compose 다운로드
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

# 실행 권한 부여
sudo chmod +x /usr/local/bin/docker-compose

# 설치 확인
docker-compose --version
```

**출력 예시:**
```
Docker Compose version v2.24.0
```

---

### 5.7 Nginx 설치
```bash
# Nginx 설치
sudo yum install -y nginx

# Nginx 시작 및 자동 실행 설정
sudo systemctl start nginx
sudo systemctl enable nginx

# 상태 확인
sudo systemctl status nginx
```

`q` 키로 종료

---

### 5.8 Git 설치
```bash
sudo yum install -y git
git --version
```

---

## 6단계: 백엔드 배포 (Docker)

### 6.1 프로젝트 디렉토리 생성
```bash
mkdir -p ~/dialogym
cd ~/dialogym
```

---

### 6.2 백엔드 JAR 파일 전송 (Windows → EC2)

#### 로컬(Windows)에서 백엔드 빌드
Windows PowerShell:
```powershell
cd C:\path\to\your\backend
gradlew.bat clean bootJar
```

빌드 완료 후:
```
build/libs/train-backend-0.0.1-SNAPSHOT.jar
```

---

#### WinSCP로 파일 전송

1. **WinSCP 실행**
2. 새 세션:
    - 파일 프로토콜: **SCP**
    - 호스트 이름: `13.125.234.56` (탄력적 IP)
    - 포트 번호: `22`
    - 사용자 이름: `ec2-user`
    - 고급 → SSH → 인증:
        - 프라이빗 키 파일: `dialogym-key.ppk` 선택
3. **"로그인"** 버튼
4. 왼쪽(로컬) → `train-backend-0.0.1-SNAPSHOT.jar` 파일
5. 오른쪽(EC2) → `/home/ec2-user/dialogym/` 폴더로 드래그

---

### 6.3 Dockerfile 생성

PuTTY에서:
```bash
cd ~/dialogym
nano Dockerfile
```

**Dockerfile 내용:**
```dockerfile
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# JAR 파일 복사
COPY *.jar app.jar

# 헬스체크를 위한 curl 설치
RUN apk add --no-cache curl

# 비루트 사용자
RUN addgroup -g 1001 spring && \
    adduser -D -u 1001 -G spring spring && \
    chown -R spring:spring /app

USER spring

EXPOSE 9090

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
  CMD curl -f http://localhost:9090/actuator/health || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
```

저장: `Ctrl + X` → `Y` → `Enter`

---

### 6.4 docker-compose.yml 생성

```bash
nano docker-compose.yml
```

**docker-compose.yml 내용:**
```yaml
version: '3.8'

services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: dialogym-backend
    restart: unless-stopped
    ports:
      - "9090:9090"
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - DB_HOST=dialogym-db.c1a2b3c4d5e6.ap-northeast-2.rds.amazonaws.com
      - DB_PORT=3306
      - DB_NAME=dialogym
      - DB_USER=admin
      - DB_PASS=YourSecurePassword123!
      - JWT_SECRET=${JWT_SECRET}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - CORS_ALLOWED_ORIGINS=https://www.dialogym.shop
      - COOKIE_DOMAIN=.dialogym.shop
      - COOKIE_SECURE=true
      - COOKIE_SAME_SITE=None
      - SERVER_PORT=9090
    networks:
      - dialogym-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9090/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  dialogym-network:
    driver: bridge
```

**중요**: `DB_HOST`를 실제 RDS 엔드포인트로 변경!

저장: `Ctrl + X` → `Y` → `Enter`

---

### 6.5 환경변수 파일 생성

```bash
nano .env
```

**.env 내용:**
```bash
JWT_SECRET=your-super-secret-jwt-key-min-256-bits-long-string
OPENAI_API_KEY=sk-your-openai-api-key-here
```

저장: `Ctrl + X` → `Y` → `Enter`

**파일 권한 설정:**
```bash
chmod 600 .env
```

---

### 6.6 Docker 이미지 빌드 및 실행

```bash
# Docker Compose로 빌드 및 실행
docker-compose up -d --build
```

**출력 예시:**
```
[+] Building 45.3s (10/10) FINISHED
[+] Running 1/1
 ✔ Container dialogym-backend  Started
```

---

### 6.7 컨테이너 상태 확인

```bash
# 컨테이너 목록
docker-compose ps
```

**성공 예시:**
```
NAME               IMAGE           STATUS         PORTS
dialogym-backend   dialogym:latest Up 2 minutes   0.0.0.0:9090->9090/tcp
```

---

### 6.8 로그 확인

```bash
docker-compose logs -f backend
```

**성공 메시지 찾기:**
```
Started TrAInBackendApplication in 12.345 seconds
```

로그 종료: `Ctrl + C`

---

### 6.9 백엔드 테스트

```bash
# 헬스체크
curl http://localhost:9090/actuator/health

# API 테스트
curl http://localhost:9090/api/health
```

**예상 결과:**
```json
{"status":"UP"}
```

성공!

---

## 7단계: Nginx 설정

### 7.1 Nginx 설정 파일 생성

```bash
sudo nano /etc/nginx/conf.d/dialogym.conf
```

**dialogym.conf 내용:**
```nginx
# HTTP → HTTPS 리다이렉트
server {
    listen 80;
    server_name api.dialogym.shop;
    
    return 301 https://$server_name$request_uri;
}

# HTTPS - 백엔드 API
server {
    listen 443 ssl http2;
    server_name api.dialogym.shop;

    # SSL 인증서 (8단계에서 설정)
    # ssl_certificate /etc/letsencrypt/live/api.dialogym.shop/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/api.dialogym.shop/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # 보안 헤더
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # API 프록시
    location / {
        proxy_pass http://localhost:9090;
        proxy_http_version 1.1;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 웹소켓 지원
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # 타임아웃
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 로그
    access_log /var/log/nginx/dialogym-api-access.log;
    error_log /var/log/nginx/dialogym-api-error.log;
}
```

저장: `Ctrl + X` → `Y` → `Enter`

---

### 7.2 Nginx 설정 테스트

```bash
sudo nginx -t
```

**성공 메시지:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

### 7.3 Nginx 재시작

```bash
sudo systemctl reload nginx
```

---

## 8단계: SSL 인증서 발급 (Let's Encrypt)

### 8.1 Certbot 설치

```bash
# Certbot 및 Nginx 플러그인 설치
sudo yum install -y certbot python3-certbot-nginx

# 설치 확인
certbot --version
```

---

### 8.2 SSL 인증서 발급

```bash
sudo certbot --nginx -d api.dialogym.shop \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email
```

**대화형 프롬프트:**
```
Would you like to redirect HTTP traffic to HTTPS?
1: No redirect
2: Redirect - Make all requests redirect to secure HTTPS
Select the appropriate number [1-2]: 2
```
→ **2** 선택 (HTTP → HTTPS 자동 리다이렉트)

---

### 8.3 발급 성공 확인

**성공 메시지:**
```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/api.dialogym.shop/fullchain.pem
Key is saved at: /etc/letsencrypt/live/api.dialogym.shop/privkey.pem
Congratulations!
```

---

### 8.4 Nginx 재시작

```bash
sudo systemctl reload nginx
```

---

### 8.5 HTTPS 테스트

```bash
curl -I https://api.dialogym.shop/actuator/health
```

**예상 결과:**
```
HTTP/2 200
server: nginx
...
```

**브라우저 테스트:**
- https://api.dialogym.shop/actuator/health 접속
- 주소창에 자물쇠 아이콘 확인

성공!

---

## 9단계: 프론트엔드 배포 (S3 + CloudFront)

### 9.1 S3 버킷 생성

1. AWS 콘솔 → **"S3"** 검색
2. **"버킷 만들기"** 버튼
3. 설정:
    - 버킷 이름: `dialogym-frontend` (고유한 이름)
    - AWS 리전: **아시아 태평양(서울) ap-northeast-2**
    - 객체 소유권: **ACL 비활성화됨**
    - 퍼블릭 액세스 차단: **모두 해제** (체크 해제)
    - 버킷 버전 관리: **비활성화**
    - 기본 암호화: **비활성화**
4. **"버킷 만들기"** 버튼

---

### 9.2 정적 웹 사이트 호스팅 설정

1. 생성한 버킷 선택: `dialogym-frontend`
2. **"속성"** 탭
3. 맨 아래 **"정적 웹 사이트 호스팅"** → **"편집"** 클릭
4. 설정:
    - 정적 웹 사이트 호스팅: **활성화**
    - 호스팅 유형: **정적 웹 사이트 호스팅**
    - 인덱스 문서: `index.html`
    - 오류 문서: `index.html` (React Router용)
5. **"변경 사항 저장"**

---

### 9.3 버킷 정책 설정 (퍼블릭 읽기 허용)

1. **"권한"** 탭
2. **"버킷 정책"** → **"편집"** 클릭
3. 다음 JSON 입력:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::dialogym-frontend/*"
    }
  ]
}
```

4. **"변경 사항 저장"**

---

### 9.4 프론트엔드 빌드 (로컬 Windows)

Windows PowerShell:
```powershell
cd C:\path\to\your\frontend

# 프로덕션 환경변수 설정
# .env.production 파일 생성
echo VITE_API_URL=https://api.dialogym.shop > .env.production

# 의존성 설치
npm install

# 프로덕션 빌드
npm run build
```

빌드 완료 후:
```
dist/
├── index.html
├── assets/
│   ├── index-abc123.js
│   └── index-def456.css
└── ...
```

---

### 9.5 S3에 파일 업로드

#### AWS CLI 사용 (추천)

Windows PowerShell:
```powershell
# AWS CLI 설치 확인
aws --version

# AWS 자격 증명 설정 (최초 1회)
aws configure
# Access Key ID: [입력]
# Secret Access Key: [입력]
# Default region: ap-northeast-2
# Default output format: json

# S3에 업로드
cd dist
aws s3 sync . s3://dialogym-frontend --delete
```

#### 또는 웹 콘솔 사용

1. S3 버킷 `dialogym-frontend` 선택
2. **"업로드"** 버튼
3. `dist` 폴더의 모든 파일 선택
4. **"업로드"** 버튼

---

### 9.6 CloudFront 배포 생성

1. AWS 콘솔 → **"CloudFront"** 검색
2. **"배포 생성"** 버튼
3. 설정:

#### 원본
```
원본 도메인: dialogym-frontend.s3.ap-northeast-2.amazonaws.com
이름: S3-dialogym-frontend
S3 버킷 액세스: 퍼블릭
```

#### 기본 캐시 동작
```
뷰어 프로토콜 정책: Redirect HTTP to HTTPS
허용된 HTTP 메서드: GET, HEAD
캐시 키 및 원본 요청: CachingOptimized
```

#### 설정
```
가격 분류: 북미, 유럽 및 아시아 사용
대체 도메인 이름(CNAME): www.dialogym.shop
SSL 인증서: ACM 인증서 선택 (또는 요청)
기본 루트 객체: index.html
```

4. **"배포 생성"** 버튼

생성 완료까지 5~10분 대기

---

### 9.7 SSL 인증서 발급 (ACM)

CloudFront용 SSL 인증서는 **us-east-1 리전**에서 발급해야 함!

1. AWS 콘솔 오른쪽 상단 리전 선택 → **"미국 동부(버지니아 북부) us-east-1"** 선택
2. **"Certificate Manager"** 검색
3. **"인증서 요청"** 버튼
4. 설정:
    - 인증서 유형: **퍼블릭 인증서 요청**
    - 도메인 이름: `www.dialogym.shop`, `dialogym.shop` (두 개 추가)
    - 검증 방법: **DNS 검증**
5. **"요청"** 버튼
6. CNAME 레코드를 Route 53에 추가 (자동 버튼 클릭 가능)
7. 검증 완료까지 5~30분 대기

---

### 9.8 CloudFront 배포에 SSL 연결

1. CloudFront 배포 선택
2. **"편집"** 버튼
3. SSL 인증서: ACM 인증서 선택
4. **"변경 사항 저장"**

---

### 9.9 Route 53 A 레코드 추가 (프론트엔드용)

1. Route 53 → 호스팅 영역 → `dialogym.shop`
2. **"레코드 생성"** 버튼
3. 설정:
    - 레코드 이름: `www`
    - 레코드 유형: **A**
    - 별칭: **예**
    - 트래픽 라우팅 대상: **CloudFront 배포에 대한 별칭**
    - CloudFront 배포: 방금 생성한 배포 선택
4. **"레코드 생성"**

---

### 9.10 프론트엔드 테스트

브라우저:
```
https://www.dialogym.shop
```

성공하면 React 앱이 로드됩니다!

---

## 10단계: 최종 테스트

### 10.1 전체 흐름 테스트

1. **프론트엔드 접속:**
   ```
   https://www.dialogym.shop
   ```

2. **백엔드 API 테스트:**
   ```
   https://api.dialogym.shop/actuator/health
   ```

3. **데이터베이스 연결 확인:**
    - EC2에서 테스트:
   ```bash
   docker logs dialogym-backend | grep -i "mariadb"
   ```

---

### 10.2 SSL 인증서 확인

브라우저:
- https://www.dialogym.shop → 주소창 자물쇠 클릭 → 인증서 확인
- https://api.dialogym.shop → 인증서 확인

---

### 10.3 성능 테스트

```bash
# 응답 시간 확인
curl -o /dev/null -s -w 'Total: %{time_total}s\n' https://api.dialogym.shop/actuator/health
```

---

## 배포 완료!


```
프론트엔드: S3 + CloudFront (https://www.dialogym.shop)
백엔드: EC2 + Docker + Nginx (https://api.dialogym.shop)
데이터베이스: RDS MariaDB
SSL/TLS: Let's Encrypt + ACM
도메인: Route 53
```

---

## 유지보수 가이드

### 백엔드 업데이트

```bash
# 1. 로컬에서 JAR 빌드
gradlew.bat clean bootJar

# 2. WinSCP로 전송 (덮어쓰기)

# 3. EC2에서 재배포
cd ~/dialogym
docker-compose down
docker-compose up -d --build

# 4. 로그 확인
docker-compose logs -f backend
```

---

### 프론트엔드 업데이트

```powershell
# 1. 로컬에서 빌드
npm run build

# 2. S3 업로드
cd dist
aws s3 sync . s3://dialogym-frontend --delete

# 3. CloudFront 캐시 무효화
aws cloudfront create-invalidation \
  --distribution-id E1234567890ABC \
  --paths "/*"
```

---

### 로그 확인

```bash
# 백엔드 로그
docker-compose logs -f backend

# Nginx 로그
sudo tail -f /var/log/nginx/dialogym-api-error.log
```

---

### 비용 절감 팁

1. **프리 티어 활용:**
    - EC2 t3.medium → t3.micro (프리 티어)
    - RDS db.t3.micro (프리 티어)

2. **CloudFront 캐싱 최적화:**
    - TTL 값 늘리기 (비용 절감)

3. **사용하지 않을 때 인스턴스 중지:**
    - 개발/테스트 환경은 중지

---

## 트러블슈팅

### 백엔드가 시작되지 않음
```bash
# 로그 확인
docker logs dialogym-backend

# 일반적인 원인:
# 1. RDS 연결 실패 → 보안 그룹 확인
# 2. 환경변수 오류 → .env 파일 확인
# 3. 포트 충돌 → 9090 포트 사용 확인
```

---

### SSL 인증서 오류
```bash
# Let's Encrypt 갱신
sudo certbot renew --dry-run
```

---

### 프론트엔드가 백엔드 호출 실패
- CORS 설정 확인
- API URL 확인 (`.env.production`)
- 백엔드 헬스체크: https://api.dialogym.shop/actuator/health

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.30 | 김경민 | 최초 작성    |