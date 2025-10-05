# CI/CD 통합 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: CI/CD 파이프라인을 이해하고 배포 프로세스를 따르는 담당자
* **프론트엔드 개발자**: 빌드 자동화와 배포 절차를 이해하는 담당자
* **DevOps 엔지니어**: CI/CD 파이프라인을 구축하고 관리하는 담당자
* **팀 리더 / PM**: 배포 프로세스를 관리하고 품질을 보장하는 책임자

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 GitHub Actions와 Jira 연동 방법을 정의합니다.
CI 파이프라인은 feature 브랜치에서 린트와 테스트, dev 브랜치에서 빌드 추가, main 브랜치에서 배포까지 수행합니다.
GitHub Actions는 push와 PR 이벤트에 자동으로 트리거되며, 린트, 테스트, 빌드, 배포 단계로 구성됩니다.
Jira 연동은 GitHub for Jira 앱을 통해 자동으로 수행되며, 커밋과 PR에 TRAIN-XX를 포함하면 이슈에 자동 연결됩니다.
배포는 dev 브랜치에서 Staging, main 브랜치에서 Production으로 자동 배포되며, 실패 시 즉시 롤백합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [CI/CD 개요](#cicd-개요)
3. [GitHub Actions 워크플로우](#github-actions-워크플로우)
4. [Jira 자동 연동](#jira-자동-연동)
5. [배포 파이프라인](#배포-파이프라인)
6. [실패 시 대응](#실패-시-대응)
7. [환경 변수 관리](#환경-변수-관리)
8. [배포 체크리스트](#배포-체크리스트)
9. [모니터링](#모니터링)

---

## 문서 개요 (Overview)

본 문서는 CI/CD 파이프라인과 Jira 연동을 명확히 하기 위해 작성되었습니다.

수동 배포는 시간이 오래 걸리고, 인적 오류가 발생하며, 품질 검증이 누락될 수 있습니다. 이를 방지하기 위해 GitHub Actions를 활용한 자동화된 CI/CD 파이프라인을 구축합니다.

본 문서는 CI 파이프라인 구성, Jira 자동 연동, 배포 절차, 실패 시 대응 방법을 포함하여 안정적이고 효율적인 배포 프로세스를 지원합니다.

---

## CI/CD 개요

### 워크플로우 구조

```
코드 푸시 → CI 파이프라인 → 자동 테스트 → 빌드 → 배포
   ↓              ↓              ↓           ↓       ↓
Jira 연동    린트/포맷 검사   단위/통합   아티팩트  Staging
```

### 트리거 조건

| 브랜치 | 트리거 | 실행 내용 |
|--------|--------|-----------|
| `feature/*` | Push, PR | 린트 + 테스트 |
| `dev` | Push, PR | 린트 + 테스트 + 빌드 |
| `main` | Push | 전체 + 배포 (Production) |

---

## GitHub Actions 워크플로우

### CI 파이프라인

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run prettier
        run: npm run format:check

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-files
          path: dist/
```

### PR 검증 워크플로우

```yaml
# .github/workflows/pr-validation.yml
name: PR Validation

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Check PR title format
        run: |
          PR_TITLE="${{ github.event.pull_request.title }}"
          if [[ ! $PR_TITLE =~ ^TRAIN-[0-9]+ ]]; then
            echo "❌ PR 제목이 규칙을 따르지 않습니다"
            echo "형식: TRAIN-이슈번호 타입: 설명"
            exit 1
          fi

      - name: Check branch name
        run: |
          BRANCH="${{ github.head_ref }}"
          if [[ ! $BRANCH =~ ^(feature|fix|hotfix|refactor|docs)/ ]]; then
            echo "❌ 브랜치명이 규칙을 따르지 않습니다"
            exit 1
          fi
```

---

## Jira 자동 연동

### GitHub for Jira 앱 설정

다음 절차로 설정합니다.

1. Jira 설치: Atlassian Marketplace → GitHub for Jira 설치
2. GitHub 연동: Jira Settings → Apps → GitHub → Connect repository
3. 자동 연동 확인: 커밋 푸시 → Jira 이슈 "Development" 탭 확인

### 커밋 → Jira 연동

```bash
# 커밋 메시지에 TRAIN-XX 포함
git commit -m "TRAIN-12 feat: 로그인 기능 구현"

# 푸시 시 자동으로:
# → Jira TRAIN-12 이슈에 커밋 링크 표시
# → Development 탭에 커밋 내역 추가
```

### PR → Jira 연동

```bash
# PR 제목에 TRAIN-XX 포함
TRAIN-12 feat: 사용자 인증 시스템 구현

# PR 생성 시 자동으로:
# → Jira 이슈에 PR 링크 표시
# → PR 상태가 Jira에 반영 (Open/Merged)
```

### 자동 상태 업데이트

Jira 설정에서 자동화 규칙을 생성합니다.

```yaml
When: PR merged
Then: Move issue to "Done"

When: PR created
Then: Add comment "PR created: {PR_URL}"
```

---

## 배포 파이프라인

### Staging 배포 (dev 브랜치)

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [dev]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NODE_ENV: staging

      - name: Deploy to staging
        run: |
          # 배포 스크립트 실행
          npm run deploy:staging
        env:
          DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}

      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ Staging 배포 완료: ${{ github.sha }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Production 배포 (main 브랜치)

```yaml
# .github/workflows/deploy-production.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NODE_ENV: production

      - name: Run security scan
        run: npm audit --audit-level high

      - name: Deploy to production
        run: |
          npm run deploy:production
        env:
          DEPLOY_KEY: ${{ secrets.PRODUCTION_DEPLOY_KEY }}

      - name: Create release tag
        run: |
          git tag v$(date +%Y%m%d-%H%M%S)
          git push --tags

      - name: Notify team
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚀 Production 배포 완료: ${{ github.sha }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 실패 시 대응

### CI 실패

다음 절차로 대응합니다.

1. 로컬 재현: `npm run lint`, `npm run test`, `npm run build`
2. 실패 원인 확인: GitHub Actions 로그 확인, 에러 메시지 분석
3. 수정 후 재푸시: `git commit -m "TRAIN-12 fix: CI 오류 수정"`, `git push`
4. CI 재실행 확인

### 배포 실패

다음 절차로 대응합니다.

1. 즉시 롤백: `npm run deploy:rollback`
2. 원인 파악: 배포 로그 확인, 서버 상태 확인, 에러 로그 분석
3. 핫픽스 브랜치: `git switch -c hotfix/TRAIN-XX-deploy-fix`
4. 수정 후 재배포

### 알림 설정

```yaml
# Slack 알림 (실패 시만)
- name: Notify on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "❌ CI 실패: ${{ github.event.head_commit.message }}"
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 환경 변수 관리

### GitHub Secrets 설정

다음 위치에서 Secrets를 추가합니다.

```
Repository Settings → Secrets and variables → Actions

추가할 Secrets:
- STAGING_DEPLOY_KEY
- PRODUCTION_DEPLOY_KEY
- SLACK_WEBHOOK_URL
- DATABASE_URL
- API_KEY
```

### 환경별 변수

```yaml
# Staging
NODE_ENV: staging
API_URL: https://staging-api.example.com

# Production
NODE_ENV: production
API_URL: https://api.example.com
```

---

## 배포 체크리스트

### Staging 배포 전

다음 사항을 체크합니다.

- dev 브랜치 최신화
- 모든 PR 병합 완료
- CI 통과 확인
- 테스트 커버리지 확인

### Production 배포 전

다음 사항을 체크합니다.

- Staging 테스트 완료
- 릴리스 노트 작성
- 팀 공지
- 데이터베이스 백업
- 롤백 계획 수립
- 모니터링 준비

### 배포 후

다음 사항을 체크합니다.

- 배포 확인 (Health Check)
- 주요 기능 테스트
- 에러 로그 확인
- 성능 모니터링
- 팀 공지 (완료)

---

## 모니터링

### 배포 상태 확인

```bash
# Health Check
curl https://api.example.com/health

# 버전 확인
curl https://api.example.com/version

# 로그 확인
npm run logs:production
```

### 메트릭 모니터링

다음 메트릭을 모니터링합니다.

- Response Time
- Error Rate
- Request Count
- CPU/Memory Usage

---

## 관련 문서

* [Git 워크플로우](../development/git-workflow.md)
* [브랜치 전략](../development/branching-strategy.md)
* [테스트 전략](../development/testing-strategy.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성 |
