# 브랜치 전략

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

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
브랜치는 main(프로덕션), dev(개발 통합), feature/*(기능), fix/*(버그), hotfix/*(긴급), refactor/*(리팩토링), docs/*(문서) 유형으로 관리됩니다.
모든 브랜치명은 타입/TRAIN-이슈번호-설명 형식을 따르며, 영문 소문자와 하이픈을 사용합니다.
feature와 refactor 브랜치는 최대 2주, fix와 docs 브랜치는 1주, hotfix는 1일 수명을 가지며, 초과 시 연장 신청이 필요합니다.
병합은 feature/fix/refactor/docs → dev는 Squash & Merge, dev → main은 Merge Commit 방식을 사용합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [브랜치 구조](#브랜치-구조)
3. [브랜치 네이밍 규칙](#브랜치-네이밍-규칙)
4. [브랜치 수명 관리](#브랜치-수명-관리)
5. [병합 전략](#병합-전략)
6. [브랜치 보호 규칙](#브랜치-보호-규칙)
7. [브랜치 정리 체크리스트](#브랜치-정리-체크리스트)

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

### 임시 브랜치

#### feature/*

**용도**: 새로운 기능 개발

**생성 기준**: dev 브랜치에서 분기

**최대 수명**: 2주

**네이밍**: `feature/TRAIN-이슈번호-설명`

**예시**: `feature/TRAIN-12-user-authentication`

#### fix/*

**용도**: 버그 수정

**생성 기준**: dev 브랜치에서 분기

**최대 수명**: 1주

**네이밍**: `fix/TRAIN-이슈번호-설명`

**예시**: `fix/TRAIN-45-login-error`

#### hotfix/*

**용도**: 긴급 프로덕션 버그 수정

**생성 기준**: main 브랜치에서 분기

**최대 수명**: 1일

**네이밍**: `hotfix/TRAIN-이슈번호-설명`

**예시**: `hotfix/TRAIN-99-security-patch`

**병합**: main과 dev 모두에 병합

#### refactor/*

**용도**: 코드 리팩토링 (기능 변화 없음)

**생성 기준**: dev 브랜치에서 분기

**최대 수명**: 2주

**네이밍**: `refactor/TRAIN-이슈번호-설명`

**예시**: `refactor/TRAIN-78-user-service`

#### docs/*

**용도**: 문서 작성 및 수정

**생성 기준**: dev 브랜치에서 분기

**최대 수명**: 1주

**네이밍**: `docs/TRAIN-이슈번호-설명`

**예시**: `docs/TRAIN-90-api-documentation`

---

## 브랜치 네이밍 규칙

### 기본 형식

```
타입/TRAIN-이슈번호-설명
```

### 규칙

다음 규칙을 준수합니다.

1. 영문 소문자 사용
2. 단어 구분은 하이픈(-)
3. Jira 이슈 번호 필수 포함
4. 설명은 간결하고 명확하게

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
```

### 잘못된 예시

다음은 규칙을 위반한 예시입니다.

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

## 브랜치 수명 관리

### 수명 정책

| 브랜치 타입       | 최대 수명 | 연장 가능 여부  |
|--------------|-------|-----------|
| `feature/*`  | 2주    | 팀 리더 승인 시 |
| `fix/*`      | 1주    | 자동 연장 가능  |
| `hotfix/*`   | 1일    | 연장 불가     |
| `refactor/*` | 2주    | 팀 리더 승인 시 |
| `docs/*`     | 1주    | 자동 연장 가능  |

### 수명 초과 시 처리

**1주차 경고**

Jira 이슈에 코멘트가 자동 생성됩니다.

```
"이 브랜치가 1주가 지났습니다. 조만간 병합하거나 연장 신청하세요."
```

**2주차 알림**

팀 채널에 알림이 전송됩니다.

```
"feature/TRAIN-12 브랜치가 2주를 초과했습니다. 즉시 조치 필요."
```

**연장 신청 방법**

Jira 이슈에 다음과 같이 코멘트를 남깁니다.

```markdown
브랜치 연장 신청

- 사유: 외부 API 연동 지연
- 예상 완료일: 2025-10-15
- 승인 요청: @team-lead
```

### 자동 정리

GitHub 설정에서 병합된 브랜치를 자동으로 삭제합니다.

```bash
Repository Settings → General → Automatically delete head branches ✅
```

---

## 병합 전략

### 병합 방식

| From → To            | 병합 방식          | 이유         |
|----------------------|----------------|------------|
| `feature/*` → `dev`  | Squash & Merge | 커밋 히스토리 정리 |
| `fix/*` → `dev`      | Squash & Merge | 커밋 히스토리 정리 |
| `refactor/*` → `dev` | Squash & Merge | 커밋 히스토리 정리 |
| `docs/*` → `dev`     | Squash & Merge | 커밋 히스토리 정리 |
| `dev` → `main`       | Merge Commit   | 릴리스 추적성    |
| `hotfix/*` → `main`  | Merge Commit   | 긴급 배포 추적   |
| `hotfix/*` → `dev`   | Cherry-pick    | 개발 브랜치 동기화 |

### Squash & Merge

GitHub UI에서 수행할 것을 권장하며, Squash 시 커밋 메시지 형식은 다음과 같습니다.

```bash
TRAIN-12 feat: 사용자 인증 시스템 구현

- JWT 토큰 기반 인증
- 소셜 로그인 지원 (Google, GitHub)
- 리프레시 토큰 구현
```

### Merge Commit

dev에서 main으로 병합 시 다음 명령을 사용합니다.

```bash
git switch main
git pull origin main
git merge --no-ff dev
git tag v1.2.0
git push origin main --tags
```

### PR 생성 전 dev 최신화

**방법 1: Merge (권장)**

```bash
git switch dev
git pull origin dev
git switch feature/TRAIN-12-description
git merge dev
git push origin feature/TRAIN-12-description
```

**방법 2: Rebase (선택적, 팀 공지 필요)**

```bash
git switch feature/TRAIN-12-description
git rebase dev
git push --force-with-lease origin feature/TRAIN-12-description
```

---

## 브랜치 보호 규칙

### main 브랜치

다음 보호 규칙이 적용됩니다.

- 직접 푸시 금지
- PR 필수
- 최소 2명 Approve 필요
- 모든 CI 통과 필수
- 강제 푸시 금지
- 삭제 금지

### dev 브랜치

다음 보호 규칙이 적용됩니다.

- 직접 푸시 금지
- PR 필수
- 최소 1명 Approve 필요
- CI 통과 필수
- 강제 푸시 금지

### feature/fix/refactor/docs 브랜치

다음 규칙이 적용됩니다.

- 자유롭게 작업 가능
- 강제 푸시 허용 (사전 공지 필요)
- 본인만 삭제 가능

---

## 브랜치 정리 체크리스트

### PR 머지 후

다음 작업을 수행합니다.

- 로컬 브랜치 삭제: `git branch -d feature/TRAIN-XX`
- 원격 브랜치 삭제: `git push origin --delete feature/TRAIN-XX`
- Jira 이슈 상태 확인 (자동 업데이트 확인)
- dev 브랜치 최신화: `git switch dev && git pull origin dev`

### 주간 점검 (매주 월요일)

다음 항목을 점검합니다.

- Stale 브랜치 확인 (2주 이상)
- 병합된 브랜치 정리
- 연장 신청 브랜치 검토

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
