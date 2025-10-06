# CI/CD 통합 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **DevOps 엔지니어**: GitHub Actions 워크플로우를 작성하고 관리하는 담당자
* **백엔드 개발자**: CI 파이프라인 결과를 확인하고 수정하는 담당자
* **프론트엔드 개발자**: 빌드 자동화와 테스트 실행을 이해하는 담당자

---

## 핵심 요약 (Executive Summary)

본 문서는 dialogym 프로젝트의 CI/CD 파이프라인 구성을 정의합니다.
GitHub Actions를 사용하여 코드 푸시와 PR 시 자동으로 린트, 테스트, 빌드를 실행합니다.
백엔드는 Gradle로 빌드하고 JUnit 테스트를 실행하며, 프론트엔드는 Vite로 빌드하고 Jest 테스트를 실행합니다.
배포는 별도 문서에서 다루며, 본 문서는 공통 CI 파이프라인에 집중합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [CI 워크플로우 구조](#ci-워크플로우-구조)
3. [백엔드 CI 파이프라인](#백엔드-ci-파이프라인)
4. [프론트엔드 CI 파이프라인](#프론트엔드-ci-파이프라인)
5. [환경 변수 관리](#환경-변수-관리)
6. [실패 시 디버깅](#실패-시-디버깅)

---

## 문서 개요 (Overview)

본 문서는 CI/CD 파이프라인의 전체 구조와 공통 CI 설정을 명확히 하기 위해 작성되었습니다.

수동 검증은 시간이 오래 걸리고, 휴먼 에러가 발생하며, 코드 품질 표준을 유지하기 어렵습니다. 이를 방지하기 위해 GitHub Actions를 활용한 자동화된 CI 파이프라인을 구축합니다.

---

## CI 워크플로우 구조

### 전체 흐름

```
코드 푸시
   ↓
린트 검사 (Checkstyle, ESLint)
   ↓
테스트 실행 (JUnit, Jest)
   ↓
빌드 검증 (dev/main만)
   ↓
아티팩트 업로드 (선택)
```

### 트리거 조건

| 브랜치                  | 이벤트      | 실행 내용               |
|----------------------|----------|---------------------|
| `feature/*`, `fix/*` | push, PR | Lint + Test         |
| `dev`                | push     | Lint + Test + Build |
| `main`               | push     | Lint + Test + Build |

---

## 백엔드 CI 파이프라인

`.github/workflows/ci-backend.yml`:

```yaml
name: Backend CI

on:
  push:
    branches: [ main, dev, 'feature/**', 'fix/**' ]
    paths:
      - 'backend/**'
      - '.github/workflows/ci-backend.yml'
  pull_request:
    branches: [ main, dev ]
    paths:
      - 'backend/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend

    steps:
      - uses: actions/checkout@v4

      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'gradle'

      - name: Grant execute permission for gradlew
        run: chmod +x ./gradlew

      - name: Run Checkstyle
        run: ./gradlew checkstyleMain checkstyleTest

      - name: Run SpotBugs
        run: ./gradlew spotbugsMain

  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: dialogym_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'gradle'

      - name: Grant execute permission for gradlew
        run: chmod +x ./gradlew

      - name: Run tests
        run: ./gradlew test
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/dialogym_test
          SPRING_DATASOURCE_USERNAME: test
          SPRING_DATASOURCE_PASSWORD: test

      - name: Publish test results
        if: always()
        uses: EnricoMi/publish-unit-test-result-action@v2
        with:
          files: backend/build/test-results/**/*.xml

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: ./backend/build/reports/jacoco/test/jacocoTestReport.xml
          flags: backend

  build:
    needs: [ lint, test ]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/dev' || github.ref == 'refs/heads/main'
    defaults:
      run:
        working-directory: ./backend

    steps:
      - uses: actions/checkout@v4

      - name: Setup JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'gradle'

      - name: Grant execute permission for gradlew
        run: chmod +x ./gradlew

      - name: Build JAR
        run: ./gradlew bootJar -x test

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: backend-jar
          path: backend/build/libs/*.jar
          retention-days: 7
```

---

## 프론트엔드 CI 파이프라인

`.github/workflows/ci-frontend.yml`:

```yaml
name: Frontend CI

on:
  push:
    branches: [ main, dev, 'feature/**', 'fix/**' ]
    paths:
      - 'frontend/**'
      - '.github/workflows/ci-frontend.yml'
  pull_request:
    branches: [ main, dev ]
    paths:
      - 'frontend/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: './frontend/package-lock.json'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Run Prettier
        run: npm run format:check

  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: './frontend/package-lock.json'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: ./frontend/coverage/lcov.info
          flags: frontend

  build:
    needs: [ lint, test ]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/dev' || github.ref == 'refs/heads/main'
    defaults:
      run:
        working-directory: ./frontend

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: './frontend/package-lock.json'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NODE_ENV: production

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: frontend-dist
          path: frontend/dist/
          retention-days: 7
```

---

## 환경 변수 관리

### GitHub Secrets 설정

```
Repository Settings → Secrets and variables → Actions

추가할 Secrets:
- AWS_ACCESS_KEY_ID (AWS 인증)
- AWS_SECRET_ACCESS_KEY (AWS 인증)
- CLOUDFRONT_PRODUCTION_ID (프론트엔드 배포)
- CLOUDFRONT_STAGING_ID (프론트엔드 배포)
- SLACK_WEBHOOK (알림)
- CODECOV_TOKEN (커버리지 업로드)
```

### 환경별 변수

**백엔드:**

```yaml
# 테스트 환경 (CI)
SPRING_PROFILES_ACTIVE: test
SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/dialogym_test
SPRING_DATASOURCE_USERNAME: test
SPRING_DATASOURCE_PASSWORD: test

# 개발 환경 (Staging)
SPRING_PROFILES_ACTIVE: staging
SPRING_DATASOURCE_URL: ${{ secrets.STAGING_DATASOURCE_URL }}

# 운영 환경 (Production)
SPRING_PROFILES_ACTIVE: production
SPRING_DATASOURCE_URL: ${{ secrets.PRODUCTION_DATASOURCE_URL }}
```

**프론트엔드:**

```yaml
# 개발 환경 (Staging)
VITE_API_URL: https://api-staging.dialogym.com

# 운영 환경 (Production)
VITE_API_URL: https://api.dialogym.com
```

---

## 실패 시 디버깅

### 로컬 재현

**백엔드:**

```bash
cd backend

# 권한 부여
chmod +x ./gradlew

# 린트
./gradlew checkstyleMain checkstyleTest

# 테스트
./gradlew test

# 빌드
./gradlew bootJar -x test
```

**프론트엔드:**

```bash
cd frontend

# 의존성 설치
npm ci

# 린트
npm run lint
npm run format:check

# 테스트
npm test

# 빌드
npm run build
```

### GitHub Actions 로그 확인

```
1. 실패한 워크플로우 클릭
2. 실패한 Job 선택
3. 실패한 Step 확인
4. 에러 메시지 복사
5. 로컬에서 재현
```

---

## 관련 문서

* [브랜치 전략](../development/git/branching-strategy.md)
* [커밋 컨벤션](../development/git/commit-convention.md)
* [백엔드 배포](deployment-backend.md)
* [프론트엔드 배포](deployment-frontend.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
