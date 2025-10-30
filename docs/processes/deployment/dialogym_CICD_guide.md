# dialogym CI/CD 가이드 (GitHub Actions)

**담당자 (Author)**: [김경민](https://github.com/minee0505)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.30

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

> **대상**: 수동 배포를 완료하고 자동 배포를 설정하려는 초보자  
> **방식**: GitHub Actions 워크플로우 + AWS 연동  
> **목표**: 코드 push만으로 자동 빌드 & 배포

---

## 목차

1. [CI/CD란?](#cicd란)
2. [자동화 흐름](#자동화-흐름)
3. [배포 순서](#배포-순서)
4. [1단계: GitHub Actions 이해하기](#1단계-github-actions-이해하기)
5. [2단계: AWS IAM 사용자 생성](#2단계-aws-iam-사용자-생성-배포용)
6. [3단계: GitHub Secrets 설정](#3단계-github-secrets-설정)
7. [4단계: 환경 변수 파일 관리](#4단계-환경-변수-파일-관리)
8. [5단계: 프론트엔드 워크플로우 작성](#5단계-프론트엔드-워크플로우-작성)
9. [6단계: 백엔드 워크플로우 작성](#6단계-백엔드-워크플로우-작성)
10. [7단계: 첫 자동 배포 테스트](#7단계-첫-자동-배포-테스트)
11. [8단계: 배포 모니터링 및 관리](#8단계-배포-모니터링-및-관리)
12. [로컬 개발 독립성](#로컬-개발-독립성)
13. [트러블슈팅](#트러블슈팅)

---

## CI/CD란?

### CI (Continuous Integration - 지속적 통합)
- 코드를 push하면 자동으로 빌드하고 테스트
- 문제가 있으면 즉시 알림

### CD (Continuous Deployment - 지속적 배포)
- 테스트 통과하면 자동으로 배포
- 수동으로 파일 옮길 필요 없음

---

## 자동화 흐름

### 현재 (수동 배포):
```
1. 로컬에서 코드 수정
2. 로컬에서 빌드 (npm run build / gradlew bootJar)
3. WinSCP로 파일 전송
4. SSH로 서버 접속해서 재시작
5. 문제 있으면 다시 1번부터...
```

**소요 시간: 20~30분**

---

### 앞으로 (자동 배포):
```
1. 로컬에서 코드 수정
2. git push origin main
3. 커피 마시면서 대기
4. 자동으로 배포 완료
```

**소요 시간: 5분 (자동)**

---

## 배포 순서

```
1단계: GitHub Actions 이해하기
2단계: AWS IAM 사용자 생성 (배포용)
3단계: GitHub Secrets 설정
4단계: 환경 변수 파일 관리
5단계: 프론트엔드 워크플로우 작성
6단계: 백엔드 워크플로우 작성
7단계: 첫 자동 배포 테스트
8단계: 배포 모니터링 및 관리
```

---

## 1단계: GitHub Actions 이해하기

### 1.1 GitHub Actions란?

- GitHub에서 제공하는 무료 CI/CD 도구
- 코드 저장소(Repository)에 `.github/workflows/` 폴더에 설정 파일 작성
- YAML 파일로 작성 (들여쓰기 중요)

---

### 1.2 워크플로우(Workflow) 구조

```yaml
name: 워크플로우 이름

on:
  push:
    branches: [main]  # main 브랜치에 push하면 실행

jobs:
  deploy:  # 작업 이름
    runs-on: ubuntu-latest  # GitHub가 제공하는 가상 서버
    
    steps:  # 실행할 단계들
      - name: 코드 다운로드
        uses: actions/checkout@v4
      
      - name: 빌드
        run: npm run build
      
      - name: 배포
        run: aws s3 sync dist/ s3://버킷이름
```

**핵심 개념:**
- `on`: 언제 실행할지 (push, pull request 등)
- `jobs`: 실행할 작업들
- `steps`: 작업 안의 세부 단계들
- `uses`: 다른 사람이 만든 액션 사용
- `run`: 직접 명령어 실행
- `runs-on: ubuntu-latest`: GitHub가 제공하는 Ubuntu 가상 서버에서 실행

---

### 1.3 GitHub가 제공하는 Ubuntu 서버란?

**정확한 의미:**

GitHub Actions가 워크플로우 실행 시마다:
- 클라우드에 Ubuntu 가상 서버를 자동으로 생성
- 빌드 및 배포 작업 수행
- 작업 완료 후 자동으로 삭제

**스펙:**
```
OS: Ubuntu 22.04 (최신)
CPU: 2 cores
RAM: 7GB
Disk: 14GB SSD
네트워크: 초고속
```

**비용:** Public 레포지토리는 무제한 무료

---

### 1.4 GitHub Actions 무료 한도

| 계정 유형 | 무료 한도 |
|-----------|-----------|
| Public 레포지토리 | 무제한 |
| Private 레포지토리 | 월 2,000분 |

---

## 2단계: AWS IAM 사용자 생성 (배포용)

### 2.1 왜 필요한가?

- GitHub Actions가 AWS에 접근하려면 권한이 필요
- 루트 계정 사용은 위험하므로 IAM 사용자 생성
- 최소 권한 원칙: S3, EC2만 접근 가능하도록 제한

---

### 2.2 IAM 콘솔 접속

1. AWS 콘솔 로그인: https://console.aws.amazon.com/
2. 상단 검색창에 "IAM" 입력 → Enter
3. 왼쪽 메뉴 → "사용자" 클릭

---

### 2.3 새 사용자 생성

#### 1) 사용자 생성 시작

오른쪽 상단 "사용자 생성" 버튼 클릭

---

#### 2) 사용자 세부 정보 지정

**1단계: 사용자 세부 정보 지정**

```
사용자 이름: dialogym-github-actions
```

**AWS Management Console에 대한 사용자 액세스 권한 제공:**
```
[체크 해제] 이 사용자에 대한 액세스 권한 제공 안 함
```

→ 이 사용자는 AWS 콘솔에 로그인하지 않고, API로만 접근

우측 하단 "다음" 버튼 클릭

---

#### 3) 권한 설정

**2단계: 권한 설정**

**권한 옵션:**
```
[선택] 직접 정책 연결
```

**권한 정책 (검색창에서 검색 후 체크):**

```
검색: S3
[체크] AmazonS3FullAccess
```

```
검색: CloudFront
[체크] CloudFrontFullAccess
```

```
검색: EC2
[체크] AmazonEC2FullAccess
```

**주의:** 실무에서는 최소 권한 원칙에 따라 커스텀 정책을 만들어야 하지만, 학습 단계에서는 FullAccess 사용

우측 하단 "다음" 버튼 클릭

---

#### 4) 검토 및 생성

**3단계: 검토 및 생성**

**사용자 세부 정보:**
```
사용자 이름: dialogym-github-actions
권한 정책: AmazonS3FullAccess, CloudFrontFullAccess, AmazonEC2FullAccess
```

우측 하단 "사용자 생성" 버튼 클릭

---

### 2.4 액세스 키 생성

#### 1) 생성된 사용자 선택

사용자 목록에서 `dialogym-github-actions` 클릭

---

#### 2) 보안 자격 증명 탭

**상단 탭:**
```
[선택] 보안 자격 증명
```

아래로 스크롤 → "액세스 키" 섹션 찾기

---

#### 3) 액세스 키 만들기

"액세스 키 만들기" 버튼 클릭

---

#### 4) 사용 사례 선택

**1단계: 액세스 키 모범 사례 및 대안**

```
[선택] Command Line Interface (CLI)
```

**확인 체크박스:**
```
[체크] 위의 권장 사항을 이해했으며 액세스 키 생성을 계속하려고 합니다.
```

"다음" 버튼 클릭

---

#### 5) 설명 태그 설정 (선택사항)

**2단계: 설명 태그 설정 - 선택 사항**

```
설명 태그 값: GitHub Actions deployment key
```

"액세스 키 만들기" 버튼 클릭

---

#### 6) 액세스 키 저장 (중요)

**3단계: 액세스 키 검색**

**매우 중요: 이 화면은 단 한 번만 표시됩니다**

**표시된 정보:**
```
액세스 키: AK...
비밀 액세스 키: wJal...
```

**저장 방법 2가지:**

**방법 1: 메모장에 복사**
```
Windows 메모장 실행
→ 액세스 키 복사해서 붙여넣기
→ 비밀 액세스 키 복사해서 붙여넣기
→ "dialogym-aws-keys.txt"로 저장
```

**방법 2: .csv 파일 다운로드**
```
".csv 파일 다운로드" 버튼 클릭
→ 안전한 곳에 저장
```

"완료" 버튼 클릭

---

**IAM 사용자 생성 완료**

**저장해야 할 정보:**
```
액세스 키 ID: AKI...
비밀 액세스 키: wJal...
```

**주의:** 이 정보는 GitHub Secrets에 저장할 때 사용하니 잘 보관하세요.

---

## 3단계: GitHub Secrets 설정

### 3.1 GitHub Secrets란?

- 민감한 정보(비밀번호, API 키)를 안전하게 저장
- 워크플로우에서 `${{ secrets.변수명 }}`으로 사용
- GitHub 저장소 설정에서 관리

---

### 3.2 프론트엔드 레포지토리 Secrets 설정

#### 1) GitHub 레포지토리 접속

브라우저에서:
```
https://github.com/본인계정/dialogym-frontend
```

예시:
```
https://github.com/AI-d/trAIn-frontend
```

---

#### 2) Settings 메뉴

상단 메뉴바에서:

"Settings" 클릭

---

#### 3) Secrets and variables 메뉴

왼쪽 사이드바에서:
```
Security
  Secrets and variables
    Actions
```

"Secrets and variables" 클릭 → "Actions" 클릭

---

#### 4) New repository secret

우측 상단 "New repository secret" 버튼 클릭 (녹색 버튼)

---

#### 5) AWS 액세스 키 추가

**Secret 1: AWS_ACCESS_KEY_ID**

```
Name: AWS_ACCESS_KEY_ID
Secret: AKI... (2단계에서 저장한 액세스 키 ID)
```

"Add secret" 버튼 클릭

---

다시 "New repository secret" 버튼 클릭

**Secret 2: AWS_SECRET_ACCESS_KEY**

```
Name: AWS_SECRET_ACCESS_KEY
Secret: wJa... (2단계에서 저장한 비밀 액세스 키)
```

"Add secret" 버튼 클릭

---

#### 6) S3 버킷 이름 추가

다시 "New repository secret" 버튼 클릭

**Secret 3: S3_BUCKET_NAME**

```
Name: S3_BUCKET_NAME
Secret: dialogym-frontend (본인의 S3 버킷 이름)
```

"Add secret" 버튼 클릭

---

#### 7) CloudFront Distribution ID 추가

**먼저 CloudFront Distribution ID 확인:**

1. AWS 콘솔 → CloudFront
2. 배포 목록에서 `dialogym-frontend` 찾기
3. ID 컬럼 값 복사 (예: `E1234567890ABC`)

---

다시 GitHub으로 돌아와서:

"New repository secret" 버튼 클릭

**Secret 4: CLOUDFRONT_DISTRIBUTION_ID**

```
Name: CLOUDFRONT_DISTRIBUTION_ID
Secret: E123... (복사한 Distribution ID)
```

"Add secret" 버튼 클릭

---

#### 8) OpenAI API Key 추가

다시 "New repository secret" 버튼 클릭

**Secret 5: VITE_OPENAI_API_KEY**

```
Name: VITE_OPENAI_API_KEY
Secret: sk-proj-Qpb...
```

**주의:** 실제 프로젝트의 OpenAI API Key 입력

"Add secret" 버튼 클릭

---

**프론트엔드 Secrets 설정 완료**

**확인:**
```
Repository secrets (5)
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET_NAME
- CLOUDFRONT_DISTRIBUTION_ID
- VITE_OPENAI_API_KEY
```

---

### 3.3 백엔드 레포지토리 Secrets 설정

#### 1) 백엔드 레포지토리 접속

브라우저에서:
```
https://github.com/본인계정/dialogym-backend
```

예시:
```
https://github.com/AI-d/trAIn-backend
```

---

#### 2) Settings → Secrets and variables → Actions

프론트엔드와 동일한 경로:
```
Settings → Secrets and variables → Actions
```

---

#### 3) AWS 자격 증명 추가 (동일)

**"New repository secret"** 버튼 클릭

**Secret 1: AWS_ACCESS_KEY_ID**
```
Name: AWS_ACCESS_KEY_ID
Secret: AKI...
```

"Add secret" 클릭

---

**"New repository secret"** 버튼 클릭

**Secret 2: AWS_SECRET_ACCESS_KEY**
```
Name: AWS_SECRET_ACCESS_KEY
Secret: wJal...
```

"Add secret" 클릭

---

#### 4) EC2 접속 정보 추가

**EC2_HOST 추가:**

**"New repository secret"** 버튼 클릭

```
Name: EC2_HOST
Secret: 13.xxx.xxx.xx (본인의 탄력적 IP)
```

"Add secret" 클릭

---

**EC2_USER 추가:**

**"New repository secret"** 버튼 클릭

```
Name: EC2_USER
Secret: ec2-user
```

"Add secret" 클릭

---

**EC2_SSH_KEY 추가 (중요)**

**먼저 SSH 키를 OpenSSH 포맷으로 변환:**

1. Windows 시작 메뉴 → "PuTTYgen" 실행
2. 상단 메뉴 → "Load" 버튼
3. `dialogym-key.ppk` 파일 선택
4. 상단 메뉴 → "Conversions" → "Export OpenSSH key"
5. "dialogym-key-openssh.pem"으로 저장
6. 저장된 `.pem` 파일을 메모장으로 열기
7. 전체 내용 복사

**올바른 형식 (OpenSSH):**
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAvRcfQjt560hStACHx1PV7uPW8LrzMPFYfPVT3PIbXCJsCMcr
... (여러 줄)
-----END RSA PRIVATE KEY-----
```

---

GitHub으로 돌아와서:

**"New repository secret"** 버튼 클릭

```
Name: EC2_SSH_KEY
Secret: (복사한 .pem 파일 전체 내용 붙여넣기)
```

"Add secret" 클릭

---

**백엔드 Secrets 설정 완료**

**확인:**
```
Repository secrets (5)
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- EC2_HOST
- EC2_USER
- EC2_SSH_KEY
```

---

## 4단계: 환경 변수 파일 관리

### 4.1 문제 상황

현재 .env 파일이 배포 환경으로 설정되어 있어 로컬 개발 시 문제 발생:

```env
# 현재 설정 (배포용)
VITE_API_BASE_URL=https://dialogym.shop
VITE_WS_URL=wss://dialogym.shop/ws
```

**문제점:**
- 로컬에서 개발할 때 실제 서버로 요청이 감
- 백엔드 개발자가 localhost:9090으로 API 띄워도 프론트엔드가 못 찾음
- 팀원마다 매번 .env 수정해야 함

---

### 4.2 해결 방법: 파일 분리

```
frontend/
  .env                  (기본값 - 로컬 개발용)
  .env.production       (배포용 - GitHub Actions에서 사용)
  .env.example          (예시 파일 - Git에 커밋)
```

---

### 4.3 파일별 내용

#### 1) .env (로컬 개발용)

**파일명:** `frontend/.env`

```env
# API 서버 설정 (로컬 개발)
VITE_API_BASE_URL=http://localhost:9090

# AI
VITE_OPENAI_API_KEY=sk-proj-xxx

# WebSocket URL (대화 기능용)
VITE_WS_URL=ws://localhost:9090/ws

VITE_USE_DYNAMIC_HOST=true
```

**용도:**
- 로컬에서 npm run dev 실행 시 자동으로 읽힘
- 백엔드 localhost:9090에 연결
- Git에 올리지 않음 (.gitignore에 포함)

---

#### 2) .env.production (배포용)

**파일명:** `frontend/.env.production`

```env
# API 서버 설정 (배포 환경)
VITE_API_BASE_URL=https://dialogym.shop

# AI (GitHub Secrets에서 주입됨)
# VITE_OPENAI_API_KEY는 빌드 시 환경 변수로 주입

# WebSocket URL (대화 기능용)
VITE_WS_URL=wss://dialogym.shop/ws

VITE_USE_DYNAMIC_HOST=false
```

**용도:**
- npm run build 실행 시 자동으로 읽힘
- GitHub Actions에서 사용
- Git에 올려도 됨 (민감한 정보 없음)

---

#### 3) .env.example (예시 파일)

**파일명:** `frontend/.env.example`

```env
# API 서버 설정
VITE_API_BASE_URL=http://localhost:9090

# AI (OpenAI API 키 발급 필요)
VITE_OPENAI_API_KEY=sk-proj-your-api-key-here

# WebSocket URL
VITE_WS_URL=ws://localhost:9090/ws

VITE_USE_DYNAMIC_HOST=true
```

**용도:**
- 신규 팀원 온보딩용
- Git에 올림
- 실제 값은 비워두고 형식만 보여줌

---

### 4.4 .gitignore 설정

**파일명:** `frontend/.gitignore`

```gitignore
# 환경 변수 (로컬 개발용)
.env
.env.local
.env.*.local

# 배포용은 올려도 됨 (민감한 정보 없으므로)
# .env.production
```

**결과:**
- `.env` (로컬용): Git에 안 올라감 (API Key 보호)
- `.env.production` (배포용): Git에 올라감 (민감한 정보 없음)
- `.env.example`: Git에 올라감 (예시용)


---

## 5단계: 프론트엔드 워크플로우 작성

### 5.1 워크플로우 파일 생성

#### 1) GitHub 레포지토리에서 파일 생성

**방법: GitHub 웹에서 직접 생성 (추천)**

1. `dialogym-frontend` 레포지토리 메인 페이지
2. 상단 "Add file" 버튼 클릭
3. "Create new file" 선택

---

#### 2) 파일 경로 입력

**파일 이름 입력란:**
```
.github/workflows/deploy-frontend.yml
```

**주의:**
- `.github` 앞에 점(`.`)이 있어야 함
- `/`를 입력하면 자동으로 폴더가 생성됨
- 파일 이름은 정확히 `deploy-frontend.yml`

---

### 5.2 워크플로우 코드 작성

**아래 코드를 복사해서 붙여넣기:**

```yaml
name: Deploy Frontend to S3

# 트리거 조건: main 브랜치에 push하면 실행
on:
  push:
    branches:
      - main
    paths:
      - 'frontend/**'  # frontend 폴더 변경 시에만 실행
      - '.github/workflows/deploy-frontend.yml'

# 환경 변수
env:
  AWS_REGION: ap-northeast-2

jobs:
  deploy:
    runs-on: ubuntu-latest  # GitHub가 제공하는 Ubuntu 서버

    steps:
      # 1단계: 코드 다운로드
      - name: Checkout code
        uses: actions/checkout@v4

      # 2단계: Node.js 설치
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
          cache-dependency-path: './frontend/package-lock.json'

      # 3단계: 의존성 설치
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci

      # 4단계: 프로덕션 빌드
      - name: Build project
        working-directory: ./frontend
        run: npm run build
        env:
          VITE_OPENAI_API_KEY: ${{ secrets.VITE_OPENAI_API_KEY }}

      # 5단계: AWS 자격 증명 설정
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      # 6단계: S3에 파일 업로드
      - name: Deploy to S3
        working-directory: ./frontend
        run: |
          aws s3 sync dist/ s3://${{ secrets.S3_BUCKET_NAME }} \
            --delete \
            --cache-control "public, max-age=31536000, immutable"
          echo "Files uploaded to S3"

      # 7단계: CloudFront 캐시 무효화
      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
          echo "CloudFront cache invalidated"

      # 8단계: 배포 완료 알림
      - name: Deployment completed
        run: |
          echo "================================"
          echo "Frontend deployed successfully!"
          echo "URL: https://www.dialogym.shop"
          echo "================================"
```

---

### 5.3 코드 설명

**주요 부분 설명:**

#### 트리거 조건
```yaml
on:
  push:
    branches:
      - main  # main 브랜치에 push할 때만
    paths:
      - 'frontend/**'  # frontend 폴더 변경 시에만
```

→ `frontend/` 폴더의 파일을 수정하고 main 브랜치에 push하면 자동 실행

---

#### Node.js 버전
```yaml
node-version: '22'
```

→ 팀원들이 사용하는 Node.js 22.20.0 버전 사용

---

#### 환경 변수 주입
```yaml
env:
  VITE_OPENAI_API_KEY: ${{ secrets.VITE_OPENAI_API_KEY }}
```

→ GitHub Secrets에서 OpenAI API Key를 가져와서 빌드 시 주입

**작동 방식:**
1. npm run build 실행
2. .env.production 파일 읽기 (도메인, WebSocket URL)
3. GitHub Secrets에서 VITE_OPENAI_API_KEY 가져오기
4. 환경 변수로 덮어씀
5. 빌드 완료

---

#### S3 업로드
```yaml
aws s3 sync dist/ s3://${{ secrets.S3_BUCKET_NAME }} --delete
```

- `dist/`: 빌드된 파일들
- `--delete`: S3에 있는 이전 파일 삭제
- `--cache-control`: 브라우저 캐싱 설정

---

#### CloudFront 캐시 무효화
```yaml
aws cloudfront create-invalidation --paths "/*"
```

→ CloudFront 캐시를 지워서 최신 파일 반영

---

### 5.4 파일 커밋

**페이지 하단:**

```
Commit new file

Commit message:
Add: GitHub Actions workflow for frontend deployment

Extended description (optional):
- Auto deploy on push to main
- Build React app with Vite
- Upload to S3
- Invalidate CloudFront cache
```

**Commit directly to the main branch** (선택)

"Commit new file" 버튼 클릭 (녹색)

---

**프론트엔드 워크플로우 생성 완료**

---

## 6단계: 백엔드 워크플로우 작성

### 6.1 워크플로우 파일 생성

#### 1) GitHub 백엔드 레포지토리 접속

```
https://github.com/본인계정/dialogym-backend
```

---

#### 2) 파일 생성

"Add file" → "Create new file"

**파일 이름:**
```workflows/deploy-backend.yml
.github/
```

---

### 6.2 워크플로우 코드 작성

**아래 코드를 복사해서 붙여넣기:**

```yaml
name: Deploy Backend to EC2

# 트리거 조건
on:
  push:
    branches:
      - main
    paths:
      - 'backend/**'
      - '.github/workflows/deploy-backend.yml'

# 환경 변수
env:
  AWS_REGION: ap-northeast-2
  JAVA_VERSION: '17'

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      # 1단계: 코드 다운로드
      - name: Checkout code
        uses: actions/checkout@v4

      # 2단계: Java 17 설치
      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'
          cache: 'gradle'

      # 3단계: Gradle 실행 권한 부여
      - name: Grant execute permission for gradlew
        working-directory: ./backend
        run: chmod +x gradlew

      # 4단계: 테스트 실행
      - name: Run tests
        working-directory: ./backend
        run: ./gradlew test

      # 5단계: JAR 파일 빌드
      - name: Build with Gradle
        working-directory: ./backend
        run: ./gradlew clean bootJar -x test

      # 6단계: SSH 키 설정
      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.EC2_SSH_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H ${{ secrets.EC2_HOST }} >> ~/.ssh/known_hosts

      # 7단계: JAR 파일 EC2로 전송
      - name: Copy JAR to EC2
        working-directory: ./backend
        run: |
          scp -i ~/.ssh/id_rsa build/libs/*.jar \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}:/home/ec2-user/dialogym/backend.jar

      # 8단계: Docker Compose 파일 전송
      - name: Copy docker-compose.yml
        working-directory: ./backend
        run: |
          scp -i ~/.ssh/id_rsa docker-compose.yml \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}:/home/ec2-user/dialogym/
          scp -i ~/.ssh/id_rsa Dockerfile \
            ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}:/home/ec2-user/dialogym/

      # 9단계: EC2에서 Docker Compose 재배포
      - name: Deploy on EC2
        run: |
          ssh -i ~/.ssh/id_rsa ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << 'EOF'
            cd /home/ec2-user/dialogym
            
            # Docker Compose 재시작
            docker-compose down
            docker-compose up -d --build
            
            # 컨테이너 시작 확인
            sleep 10
            
            # 헬스체크
            if docker ps | grep dialogym-backend; then
              echo "Backend container started successfully"
            else
              echo "Failed to start backend container"
              docker-compose logs backend
              exit 1
            fi
          EOF

      # 10단계: 배포 완료 알림
      - name: Deployment completed
        run: |
          echo "================================"
          echo "Backend deployed successfully!"
          echo "API URL: https://api.dialogym.shop"
          echo "================================"
```

---

### 6.3 코드 설명

**주요 부분 설명:**

#### Gradle 빌드
```yaml
./gradlew clean bootJar -x test
```

- `clean`: 이전 빌드 삭제
- `bootJar`: Spring Boot 실행 가능한 JAR 생성
- `-x test`: 테스트 스킵 (이미 4단계에서 실행했으므로)

---

#### SSH 키 설정
```yaml
echo "${{ secrets.EC2_SSH_KEY }}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```

→ GitHub Secrets에 저장한 SSH 키를 파일로 생성하고 권한 설정

---

#### SCP 파일 전송
```yaml
scp -i ~/.ssh/id_rsa build/libs/*.jar \
  ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }}:/home/ec2-user/dialogym/backend.jar
```

- `scp`: Secure Copy (SSH 파일 전송)
- `-i ~/.ssh/id_rsa`: SSH 키 사용
- `build/libs/*.jar`: 빌드된 JAR 파일
- `/home/ec2-user/dialogym/`: EC2 대상 경로

---

#### Docker Compose 재시작
```yaml
docker-compose down
docker-compose up -d --build
```

- `down`: 기존 컨테이너 중지 및 삭제
- `up -d`: 백그라운드로 재시작
- `--build`: Docker 이미지 재빌드

---

### 6.4 파일 커밋

**페이지 하단:**

```
Commit new file

Commit message:
Add: GitHub Actions workflow for backend deployment

Extended description:
- Auto deploy on push to main
- Build Spring Boot JAR with Gradle
- Transfer JAR to EC2 via SCP
- Restart Docker Compose
```

"Commit new file" 버튼 클릭

---

**백엔드 워크플로우 생성 완료**

---

## 7단계: 첫 자동 배포 테스트

### 7.1 프론트엔드 배포 테스트

#### 1) 로컬에서 코드 수정

**Windows 명령 프롬프트 또는 Git Bash:**

```bash
# 레포지토리 클론 (아직 안 했다면)
git clone https://github.com/본인계정/dialogym-frontend.git
cd dialogym-frontend

# 또는 기존 레포지토리로 이동
cd C:\path\to\dialogym-frontend
```

---

#### 2) 간단한 변경사항 만들기

**예시: README.md 수정**

```bash
# 메모장으로 열기
notepad README.md
```

**추가할 내용:**
```
# Dialogym Frontend

CI/CD Test - 자동 배포 테스트 중
```

저장 후 닫기

---

#### 3) Git 커밋 & 푸시

```bash
# 변경사항 확인
git status

# 변경사항 스테이징
git add .

# 커밋
git commit -m "Test: CI/CD 자동 배포 테스트"

# 푸시
git push origin main
```

---

#### 4) GitHub Actions 실행 확인

**브라우저에서:**

```
https://github.com/본인계정/dialogym-frontend/actions
```

**확인 사항:**

1. Workflows 목록:
   ```
   Deploy Frontend to S3
   ```

2. 최근 실행:
   ```
   Test: CI/CD 자동 배포 테스트
   [실행 중...] (주황색)
   ```

3. 클릭해서 상세 보기

---

#### 5) 실행 로그 확인

**왼쪽:**
```
deploy (작업 이름)
```

**오른쪽:**
```
Checkout code                    [완료]
Setup Node.js                    [완료]
Install dependencies             [완료]
Build project                    [진행 중...]
Configure AWS credentials        [대기 중]
Deploy to S3                     [대기 중]
Invalidate CloudFront cache     [대기 중]
Deployment completed             [대기 중]
```

**각 단계를 클릭하면 상세 로그 확인 가능**

---

#### 6) 배포 성공 확인

**모든 단계 완료:**
```
[완료] Checkout code
[완료] Setup Node.js
[완료] Install dependencies
[완료] Build project
[완료] Configure AWS credentials
[완료] Deploy to S3
[완료] Invalidate CloudFront cache
[완료] Deployment completed
```

**최종 메시지:**
```
================================
Frontend deployed successfully!
URL: https://www.dialogym.shop
================================
```

---

#### 7) 웹사이트 확인

**브라우저에서:**
```
https://www.dialogym.shop
```

**개발자 도구 (F12):**
- Console 탭 → 에러 없는지 확인
- Network 탭 → XHR 요청 확인

**성공**

---

### 7.2 백엔드 배포 테스트

#### 1) 로컬에서 코드 수정

```bash
cd C:\path\to\dialogym-backend
```

**간단한 변경사항:**

```bash
# README.md 수정
notepad README.md
```

**추가:**
```
# Dialogym Backend

CI/CD Test - 자동 배포 테스트 중
```

---

#### 2) Git 커밋 & 푸시

```bash
git add .
git commit -m "Test: CI/CD 자동 배포 테스트"
git push origin main
```

---

#### 3) GitHub Actions 실행 확인

```
https://github.com/본인계정/dialogym-backend/actions
```

**Workflow:**
```
Deploy Backend to EC2
```

**실행 로그:**
```
Checkout code                    [완료]
Setup JDK 17                     [완료]
Grant execute permission         [완료]
Run tests                        [완료]
Build with Gradle                [진행 중...]
Setup SSH key                    [대기 중]
Copy JAR to EC2                  [대기 중]
Copy docker-compose.yml          [대기 중]
Deploy on EC2                    [대기 중]
Deployment completed             [대기 중]
```

---

#### 4) 배포 성공 확인

**모든 단계 완료:**
```
[완료] Backend container started successfully
================================
Backend deployed successfully!
API URL: https://api.dialogym.shop
================================
```

---

#### 5) API 테스트

**브라우저에서:**
```
https://api.dialogym.shop/actuator/health
```

**예상 결과:**
```json
{
  "status": "UP"
}
```

**성공**

---

## 8단계: 배포 모니터링 및 관리

### 8.1 GitHub Actions 대시보드

#### 메인 대시보드

```
https://github.com/본인계정/dialogym-frontend/actions
```

**확인 가능:**
- 성공/실패 상태
- 실행 시간
- 성공률
- 실행 히스토리

---

#### 워크플로우 필터링

**왼쪽 사이드바:**
```
Workflows
  [모든 워크플로우]
  Deploy Frontend to S3
```

"Deploy Frontend to S3" 클릭 → 해당 워크플로우만 보기

---

#### 실행 로그 다운로드

1. 워크플로우 실행 선택
2. 우측 상단 "..." (더보기) 메뉴
3. "Download log archive" 클릭
4. `.zip` 파일 다운로드

---

### 8.2 배포 실패 시 대처

#### 1) 실패 알림 확인

**GitHub에서 이메일 알림:**
```
제목: [본인계정/dialogym-frontend] Run failed: Deploy Frontend to S3 - main (1234567)
```

→ 이메일 확인 후 즉시 대응

---

#### 2) 실패 로그 확인

**Actions 탭:**
```
[실패] Test: CI/CD 자동 배포 테스트
```

**클릭 → 실패한 단계 찾기:**
```
[완료] Checkout code
[완료] Setup Node.js
[완료] Install dependencies
[실패] Build project (실패)
```

**"Build project" 클릭 → 에러 메시지 확인**

---

#### 3) 일반적인 에러 및 해결

**에러 1: npm install 실패**
```
Error: Cannot find module 'react'
```

**해결:**
```bash
# 로컬에서 package-lock.json 재생성
npm install
git add package-lock.json
git commit -m "Fix: Update package-lock.json"
git push origin main
```

---

**에러 2: 빌드 실패**
```
Error: Build failed with errors
```

**해결:**
```bash
# 로컬에서 빌드 테스트
npm run build

# 에러 확인 및 수정
# 수정 후 푸시
```

---

**에러 3: AWS 권한 오류**
```
Error: AccessDenied
```

**해결:**
1. GitHub Secrets 확인 (오타 없는지)
2. IAM 사용자 권한 확인
3. S3 버킷 정책 확인

---

**에러 4: SSH 연결 실패 (백엔드)**
```
Error: Permission denied (publickey)
```

**해결:**
1. GitHub Secrets의 `EC2_SSH_KEY` 확인
2. EC2 보안 그룹 22번 포트 열려있는지 확인
3. EC2 인스턴스 실행 중인지 확인

---

#### 4) 재실행

**실패한 워크플로우 재실행:**

1. 실패한 워크플로우 선택
2. 우측 상단 "Re-run jobs" 버튼
3. "Re-run all jobs" 선택

---

### 8.3 배포 히스토리 관리

#### 배포 기록 확인

**Actions 탭에서:**
```
2024-10-28 14:30  [완료] Add: New feature
2024-10-28 12:15  [완료] Fix: Bug fix
2024-10-28 10:00  [실패] Test: Failed test
2024-10-27 18:45  [완료] Refactor: Code cleanup
```

**각 배포의 커밋 해시, 시간, 결과 확인 가능**

---

#### 특정 버전으로 롤백

**방법 1: Git Revert (권장)**

```bash
# 특정 커밋 되돌리기
git revert abc1234

# 푸시
git push origin main
```

→ GitHub Actions가 자동으로 이전 버전 배포

---

**방법 2: Git Reset (주의)**

```bash
# 특정 커밋으로 되돌리기
git reset --hard abc1234

# 강제 푸시
git push origin main --force
```

**주의:** 커밋 히스토리가 삭제됨

---

### 8.4 배포 알림 설정

#### 이메일 알림 (기본 제공)

**GitHub 계정 설정:**

1. GitHub 프로필 → Settings
2. Notifications
3. Actions 섹션:
   ```
   [체크] Send notifications for failed workflows only
   ```

---

### 8.5 워크플로우 최적화

#### 캐싱으로 빌드 시간 단축

**Node.js 캐싱 (이미 적용됨):**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    cache: 'npm'
```

**Gradle 캐싱 (이미 적용됨):**
```yaml
- name: Setup JDK 17
  uses: actions/setup-java@v4
  with:
    cache: 'gradle'
```

**효과:**
- 첫 실행: 5~7분
- 이후 실행: 3~4분 (40% 단축)

---

#### 조건부 실행

**특정 파일 변경 시에만 실행:**

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'frontend/src/**'  # src 폴더만
      - 'frontend/package.json'
```

---

## 로컬 개발 독립성

### 핵심 개념

**CI/CD 설정은 배포만 자동화하는 것**이고, **팀원들 로컬 개발은 영향 없습니다.**

---

### 트리거 조건이 분리되어 있음

```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'frontend/**'
```

**의미:**
- main 브랜치에 push하고
- frontend 폴더 내용이 변경되었을 때만
- GitHub Actions 실행

**팀원들 상황:**
```
개발자 A: feature/login 브랜치에서 작업 중
개발자 B: feature/chat 브랜치에서 작업 중
개발자 C: 로컬에서 npm run dev 실행 중
```

→ main에 push 안 했으므로 **GitHub Actions 실행 안 됨**

---

### 로컬 개발과 배포는 완전 독립적

```
로컬 개발 (팀원들):
  npm run dev
    ↓
  .env 파일 읽기
    ↓
  localhost:9090으로 연결
    ↓
  백엔드 개발자의 로컬 서버와 통신
    ↓
  아무 문제 없음
```

```
자동 배포 (GitHub Actions):
  git push origin main
    ↓
  GitHub Actions 실행
    ↓
  .env.production 읽기
    ↓
  https://dialogym.shop 빌드
    ↓
  S3에 업로드
    ↓
  실제 서버 업데이트
```

**완전히 다른 경로입니다.**

---

### 실제 시나리오

#### 상황 1: 팀원 A가 로그인 기능 개발 중

```bash
# 팀원 A (로컬)
git checkout -b feature/login
# 코드 작성...
npm run dev  # localhost:3000 실행

# .env 파일 사용
VITE_API_BASE_URL=http://localhost:9090
```

**결과:**
- GitHub Actions 실행 안 됨 (feature 브랜치니까)
- 로컬 백엔드와 통신
- 개발 정상 진행

---

#### 상황 2: CI/CD 설정 중

```bash
# CI/CD 설정
git checkout main
# .github/workflows/deploy-frontend.yml 작성
git add .
git commit -m "Add: CI/CD workflow"
git push origin main
```

**결과:**
- GitHub Actions 실행됨
- 하지만 워크플로우 파일만 변경됨
- frontend 폴더는 안 변경됨
- 배포는 실행 안 되거나, 기존 코드 그대로 배포
- 팀원들 로컬 개발은 전혀 영향 없음

---

#### 상황 3: 로그인 기능 완성 후 main에 머지

```bash
# 팀원 A
git checkout feature/login
git add .
git commit -m "Add: Login feature"
git push origin feature/login

# GitHub에서 Pull Request 생성
# 코드 리뷰 후 main에 머지
```

**결과:**
- GitHub Actions 실행됨 (main에 frontend 코드 변경됨)
- 자동으로 빌드 & 배포
- 로그인 기능이 실제 서버에 반영됨
- **팀원들 로컬은 여전히 문제 없음**

---

### 구조 정리

#### 로컬 개발 환경

```
팀원 PC
  ↓
npm run dev
  ↓
.env 파일 (localhost:9090)
  ↓
로컬 백엔드 서버
```

**독립적으로 작동**

---

#### 배포 환경

```
git push origin main
  ↓
GitHub Actions (GitHub 서버)
  ↓
.env.production (https://dialogym.shop)
  ↓
S3 업로드
  ↓
실제 사용자가 접속하는 서버
```

**로컬과 완전 분리**

---

### 트리거 조건 상세

#### 실행되는 경우

```yaml
on:
  push:
    branches:
      - main  # main 브랜치
    paths:
      - 'frontend/**'  # frontend 폴더 변경
```

**조건:**
1. main 브랜치에 push
2. frontend 폴더 내용 변경

**둘 다 만족해야 실행**

---

#### 실행 안 되는 경우

```
feature/login 브랜치에 push → 실행 안 됨 (main 아님)
main 브랜치에 push했지만 backend 폴더만 변경 → 실행 안 됨
로컬에서 npm run dev → 실행 안 됨 (push 아님)
.github/workflows 파일만 변경 → 실행 안 됨 (frontend 폴더 변경 없음)
```

---

### 팀원들이 신경 쓸 부분

#### 신경 쓸 필요 없는 것

- GitHub Actions 설정
- .env.production 파일
- S3, CloudFront
- 배포 과정

---

#### 신경 써야 하는 것

```
1. .env 파일 생성 (처음 1회만)
   cp .env.example .env

2. OpenAI API Key 입력 (처음 1회만)

3. 평소처럼 개발
   npm run dev

4. 기능 완성되면 PR 생성
   git push origin feature/내기능
```

---

### 개발 흐름

#### 권장하는 방식

```
1. 팀원들: feature 브랜치에서 개발
   git checkout -b feature/기능명
   npm run dev로 로컬 테스트

2. 기능 완성: PR 생성
   git push origin feature/기능명

3. 코드 리뷰 후 main에 머지

4. GitHub Actions 자동 배포

5. 배포 확인
   https://dialogym.shop
```

---

#### CI/CD 설정 중에도 개발 가능

```
CI/CD 설정자: CI/CD 설정 (main 브랜치)
팀원 A: 로그인 개발 (feature/login 브랜치)
팀원 B: 채팅 개발 (feature/chat 브랜치)
```

**서로 영향 없음. 각자 브랜치에서 작업.**

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

### GitHub Actions 빌드 실패

**에러: npm install 실패**
```
Error: Cannot find module
```

**해결:**
```bash
rm -rf node_modules package-lock.json
npm install
git add package-lock.json
git commit -m "Fix: Update dependencies"
git push
```

---

**에러: Gradle 빌드 실패**
```
Error: Could not resolve dependencies
```

**해결:**
```bash
./gradlew clean build --refresh-dependencies
git add .
git commit -m "Fix: Refresh Gradle dependencies"
git push
```

---

### SSH 키 관련 에러

**에러: Permission denied (publickey)**

**원인:**
- EC2_SSH_KEY가 잘못 설정됨
- OpenSSH 포맷이 아님

**해결:**
1. PuTTYgen으로 .ppk → .pem 변환 확인
2. .pem 파일 전체 내용 복사 (BEGIN~END 포함)
3. GitHub Secrets에 다시 등록

---

## 학습 정리

### 배운 내용

1. **GitHub Actions 기본 개념**
    - Workflow, Job, Step
    - Triggers (on push, on pull_request 등)
    - Secrets 관리
    - GitHub가 제공하는 Ubuntu 서버

2. **AWS IAM 사용자 관리**
    - 최소 권한 원칙
    - 액세스 키 발급
    - 정책 연결

3. **환경 변수 파일 관리**
    - .env (로컬 개발용)
    - .env.production (배포용)
    - .env.example (예시)
    - GitHub Secrets 연동

4. **CI/CD 파이프라인 구축**
    - 프론트엔드: React 빌드 → S3 업로드 → CloudFront 캐시 무효화
    - 백엔드: Spring Boot 빌드 → EC2 전송 → Docker 재시작

5. **모니터링 및 트러블슈팅**
    - 배포 로그 확인
    - 실패 시 대처
    - 롤백 방법

6. **로컬 개발 독립성**
    - 로컬 개발과 배포 환경 분리
    - 트리거 조건의 중요성
    - 팀원 간 협업 방식

---

### 2. 보안 강화

- IAM 권한 최소화 (커스텀 정책)
- Secrets 주기적 갱신
- 보안 취약점 스캔

---

### 3. 성능 최적화

- 빌드 캐싱 확대
- 병렬 빌드
- Docker 이미지 최적화

---

### 4. 모니터링 추가

- CloudWatch 대시보드
- 배포 메트릭 수집
- 알림 규칙 설정

---

## 체크리스트

### 프론트엔드 CI/CD

- GitHub Secrets 설정 완료
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - S3_BUCKET_NAME
    - CLOUDFRONT_DISTRIBUTION_ID
    - VITE_OPENAI_API_KEY

- 환경 변수 파일 관리
    - .env (로컬 개발용)
    - .env.production (배포용)
    - .env.example (예시)

- 워크플로우 파일 생성
    - `.github/workflows/deploy-frontend.yml`

- 첫 배포 성공
    - 코드 수정 → git push
    - Actions 탭에서 성공 확인
    - 웹사이트에서 변경사항 확인

---

### 백엔드 CI/CD

- GitHub Secrets 설정 완료
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - EC2_HOST
    - EC2_USER
    - EC2_SSH_KEY

- 워크플로우 파일 생성
    - `.github/workflows/deploy-backend.yml`

- 첫 배포 성공
    - 코드 수정 → git push
    - Actions 탭에서 성공 확인
    - API에서 변경사항 확인

---

## 참고 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [AWS IAM 사용 설명서](https://docs.aws.amazon.com/IAM/latest/UserGuide/)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

---
변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.30 | 김경민 | 최초 작성    |