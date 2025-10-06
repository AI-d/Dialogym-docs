# 브랜치 전략

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 브랜치 생성 규칙과 병합 전략을 이해하고 적용하는 담당자
* **프론트엔드 개발자**: 기능 브랜치를 올바르게 관리하고 dev로 병합하는 담당자
* **풀스택 개발자**: 여러 브랜치에서 작업하며 브랜치 간 관계를 이해해야 하는 담당자
* **팀 리더 / PM**: 브랜치 전략을 수립하고 팀원들의 브랜치 관리를 감독하는 책임자
* **신규 합류자**: 브랜치 네이밍과 수명 관리 규칙을 빠르게 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀의 Git 브랜치 전략과 관리 규칙을 정의합니다.
브랜치는 영구 브랜치 main(프로덕션), dev(개발 통합)
임시 브랜치 feature/*(기능), fix/*(버그), hotfix/*(긴급), refactor/*(리팩토링), docs/*(문서), release/*(릴리스), test/*(테스트), infra/*(인프라),
chore/*(설정) 유형으로 관리됩니다.
모든 브랜치명은 타입/TRAIN-이슈번호-설명 형식을 따르며, 영문 소문자와 하이픈을 사용합니다.
병합은 임시 브랜치 → dev는 Squash & Merge, dev → main은 Merge Commit 방식을 사용합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [브랜치 구조](#브랜치-구조)
3. [브랜치 네이밍 규칙](#브랜치-네이밍-규칙)
4. [병합 전략](#병합-전략)
5. [브랜치 보호 규칙](#브랜치-보호-규칙)
6. [브랜치 정리 체크리스트](#브랜치-정리-체크리스트)

---

## 문서 개요 (Overview)

본 문서는 팀 내 브랜치 관리 규칙을 명확히 하기 위해 작성되었습니다.

여러 개발자가 동시에 작업할 때 브랜치 관리가 체계적이지 않으면 충돌이 빈번하고, 히스토리 추적이 어려우며, 배포 시 혼란이 발생합니다. 이를 방지하기 위해 브랜치 유형, 네이밍 규칙, 수명 관리, 병합 전략을
명확히 정의합니다.

본 전략은 Git Flow를 기반으로 하되, 팀 규모와 프로젝트 특성에 맞게 단순화했습니다.

---

## 브랜치 구조

### 영구 브랜치

#### main

**용도**: 프로덕션 배포 전용
**특징**: 항상 배포 가능한 상태 유지
**보호**: 직접 푸시 금지, PR만 허용
**병합**: dev → main (Merge Commit)

#### dev

**용도**: 개발 통합 브랜치
**특징**: 모든 기능 브랜치의 병합 대상
**보호**: 직접 푸시 금지, PR만 허용
**병합**: feature/* → dev (Squash & Merge)

---

### 주요 브랜치

#### feature/*

**용도**: 새로운 기능 개발
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `feature/TRAIN-이슈번호-설명`
**예시**: `feature/TRAIN-12-user-authentication`

---

#### fix/*

**용도**: 버그 수정
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `fix/TRAIN-이슈번호-설명`
**예시**: `fix/TRAIN-45-login-error`

---

#### hotfix/*

**용도**: 긴급 프로덕션 버그 수정
**생성 기준**: main 브랜치에서 분기
**네이밍**: `hotfix/TRAIN-이슈번호-설명`
**예시**: `hotfix/TRAIN-99-security-patch`
**병합**: main과 dev 모두에 병합

---

### 임시 브랜치

#### refactor/*

**용도**: 코드 리팩토링 (기능 변화 없음)
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `refactor/TRAIN-이슈번호-설명`
**예시**: `refactor/TRAIN-78-user-service`

---

#### docs/*

**용도**: 문서 작성 및 수정
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `docs/TRAIN-이슈번호-설명`
**예시**: `docs/TRAIN-90-api-documentation`

---

#### release/*

**용도**: 릴리스 후보 버전 (QA, 안정화, 태깅 준비)
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `release/TRAIN-이슈번호-버전명`
**예시**: `release/TRAIN-120-v1.2.0`
**병합**: QA 완료 후 main 병합 이후 dev에도 병합 (동기화), hotfix 발생 시 cherry-pick 반영
**특징**: 일정 기간 QA 및 버전 태깅용으로 유지

---

#### test/*

**용도**: 테스트 환경 전용 (QA, 통합 테스트, 부하 테스트 등)
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `test/TRAIN-이슈번호-설명`
**예시**: `test/TRAIN-133-api-load-test`
**특징**: 실험성 QA 및 테스트 검증용, 병합 대상 아님

---

#### infra/*

**용도**: 인프라, 배포, CI/CD 설정 관련 변경
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `infra/TRAIN-이슈번호-설명`
**예시**: `infra/TRAIN-140-terraform-eks-setup`
**특징**: IaC, 배포 파이프라인, 환경 변수 구성 등 인프라 작업 전용

---

#### chore/*

**용도**: 환경 설정, 의존성, 빌드 스크립트, 설정 파일 등 비기능적 변경
**생성 기준**: dev 브랜치에서 분기
**네이밍**: `chore/TRAIN-이슈번호-설명`
**예시**: `chore/TRAIN-150-eslint-config-update`
**특징**: 코드/문서 기능과 무관한 단순 관리 작업용, 병합은 dev로만 수행

---

## 브랜치 네이밍 규칙

### 기본 형식

```
타입/TRAIN-이슈번호-설명
```

### 규칙

1. 영문 소문자 사용
2. 단어 구분은 하이픈(-)
3. Jira 이슈 번호 필수 포함
4. 설명은 간결하고 명확하게
5. 릴리스 버전은 semver 사용 (`v{MAJOR}.{MINOR}.{PATCH}`)

    * 프리릴리스는 `-rc.{n}` (예: `v1.2.0-rc.1`)

### 타입별 예시

```bash
# 기능 개발
feature/TRAIN-12-user-authentication
feature/TRAIN-23-payment-integration
feature/TRAIN-34-admin-dashboard

# 버그 수정
fix/TRAIN-45-login-validation
fix/TRAIN-56-memory-leak
fix/TRAIN-67-api-timeout

# 긴급 수정
hotfix/TRAIN-99-critical-security
hotfix/TRAIN-100-server-crash

# 리팩토링
refactor/TRAIN-78-user-service
refactor/TRAIN-89-database-layer

# 문서
docs/TRAIN-90-api-documentation
docs/TRAIN-101-setup-guide

# 인프라
infra/TRAIN-140-terraform-eks-setup
infra/TRAIN-142-ci-pipeline-update

# 테스트
test/TRAIN-133-api-load-test
test/TRAIN-145-performance-check

# 릴리스
release/TRAIN-120-v1.2.0
release/TRAIN-121-v1.3.0

# 환경 설정
chore/TRAIN-150-eslint-config-update
chore/TRAIN-151-gradle-version-upgrade
```

### 잘못된 예시

```bash
# Jira 이슈 번호 없음
feature/user-authentication

# 대문자 사용
feature/TRAIN-12-User-Authentication

# 언더스코어 사용
feature/TRAIN-12_user_authentication

# 공백 사용
feature/TRAIN-12 user authentication

# 너무 긴 설명
feature/TRAIN-12-implement-user-authentication-with-jwt-and-oauth
```

---

## 병합 전략

### 병합 방식

| From → To            | 병합 방식          | 이유             |
|----------------------|----------------|----------------|
| `feature/*` → `dev`  | Squash & Merge | 커밋 히스토리 정리     |
| `fix/*` → `dev`      | Squash & Merge | 버그 수정 단일화      |
| `refactor/*` → `dev` | Squash & Merge | 리팩토링 내역 단일화    |
| `docs/*` → `dev`     | Squash & Merge | 문서 변경 간소화      |
| `infra/*` → `dev`    | Squash & Merge | 설정 변경 단일화      |
| `chore/*` → `dev`    | Squash & Merge | 비기능 변경 통합      |
| `dev` → `release/*`  | Merge Commit   | QA 준비용 릴리스 분기  |
| `release/*` → `main` | Merge Commit   | 최종 릴리스         |
| `release/*` → `dev`  | Merge Commit   | 릴리스 수정사항 동기화   |
| `test/*` → `dev`     | 선택적 병합         | 테스트 코드 필요 시 반영 |
| `hotfix/*` → `main`  | Merge Commit   | 긴급 배포 추적       |
| `hotfix/*` → `dev`   | Cherry-pick    | 개발 브랜치 동기화     |

---

### Squash & Merge 예시

```bash
TRAIN-12 feat: 사용자 인증 시스템 구현

- JWT 토큰 기반 인증
- 소셜 로그인 지원 (Google, GitHub)
- 리프레시 토큰 구현
```

---

### Merge Commit 예시

```bash
git switch main
git pull origin main
git merge --no-ff dev
git tag v1.2.0
git push origin main --tags
```

---

## 브랜치 보호 규칙

### main 브랜치

* 직접 푸시 금지
* PR 필수
* 최소 2명 Approve 필요
* 모든 CI 통과 필수
* 강제 푸시 금지
* 삭제 금지

---

### dev 브랜치

* 직접 푸시 금지
* PR 필수
* 최소 1명 Approve 필요
* CI 통과 필수
* 강제 푸시 금지

---

### release 브랜치

* 직접 푸시 금지
* PR 필수
* 최소 1명 Approve 필요
* CI 통과 필수
* 강제 푸시 금지

---

### feature / fix / refactor / docs / infra / chore 브랜치

* 자유롭게 작업 가능
* 강제 푸시 허용 (사전 공지 필요)
* 본인만 삭제 가능
* 병합은 dev로만 수행

---

### test 브랜치

* 병합 대상 아님 (테스트 코드 유지용)
* QA/부하 테스트 완료 후 수동 삭제
* CI 환경에 영향 주지 않도록 분리

---

## 브랜치 정리 체크리스트

### PR 머지 후

* 로컬 브랜치 삭제: `git branch -d feature/TRAIN-XX`
* 원격 브랜치 삭제: `git push origin --delete feature/TRAIN-XX`
* Jira 이슈 상태 자동 업데이트 확인
* dev 최신화: `git switch dev && git pull origin dev`

### 주간 점검 (매주 월요일)

* 2주 이상 Stale 브랜치 확인
* 병합 완료 브랜치 정리
* release 브랜치 QA 상태 확인

### 릴리스 종료 후

* main 병합 및 태그 확인
* release/* → dev 병합(수정사항 동기화)
* release/* 브랜치 삭제

---

## 관련 문서

* [Git 워크플로우](git-workflow.md)
* [커밋 컨벤션](commit-convention.md)
* [PR 가이드](pull-request-guide.md)
* [충돌 해결](conflict-resolution.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
