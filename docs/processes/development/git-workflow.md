# Git 워크플로우

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Git 브랜치 전략과 Jira 연동 워크플로우를 실무에 적용하는 담당자
* **프론트엔드 개발자**: 기능 개발 시 브랜치 생성부터 PR 병합까지 전체 흐름을 따르는 담당자
* **풀스택 개발자**: 백엔드/프론트엔드 모두에서 Git 워크플로우를 일관되게 적용하는 담당자
* **팀 리더 / PM**: 브랜치 전략과 코드 리뷰 프로세스를 관리하고 팀원을 가이드하는 책임자
* **신규 합류자**: Git 협업 규칙을 빠르게 이해하고 팀 워크플로우에 적응해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀의 Git 브랜치 전략과 협업 워크플로우를 정의합니다.
주요 브랜치는 main(프로덕션), dev(개발 통합), feature/*(기능 개발), fix/*(버그 수정), hotfix/*(긴급 수정)로 구성됩니다.
모든 작업은 Jira 이슈와 연동되며, 브랜치명과 커밋 메시지에 TRAIN-XX 형식의 이슈 번호를 포함합니다.
PR은 Squash & Merge 방식을 사용하며, 최소 1명의 승인 후 병합됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [브랜치 전략 개요](#브랜치-전략-개요)
3. [기본 개발 흐름](#기본-개발-흐름)
4. [Jira 연동 워크플로우](#jira-연동-워크플로우)
5. [빠른 참조](#빠른-참조)

---

## 문서 개요 (Overview)

본 문서는 팀 내 Git 협업 규칙을 명확히 하기 위해 작성되었습니다.

프로젝트가 성장하면서 여러 개발자가 동시에 작업할 때 충돌을 최소화하고, 코드 품질을 유지하며, 작업 이력을 명확히 추적하기 위해서는 일관된 Git 워크플로우가 필요합니다.

본 문서는 브랜치 생성부터 PR 병합까지 전체 프로세스를 정의하며, Jira 이슈 관리 시스템과의 연동 방법도 포함합니다.

---

## 브랜치 전략 개요

### 주요 브랜치

| 브랜치         | 용도         | 수명    | 보호 규칙            |
|-------------|------------|-------|------------------|
| `main`      | 프로덕션 배포 전용 | 영구    | 직접 푸시 금지, PR만 허용 |
| `dev`       | 통합 개발 브랜치  | 영구    | 직접 푸시 금지, PR만 허용 |
| `feature/*` | 새 기능 개발    | 2주 이내 | 자유롭게 작업 가능       |
| `fix/*`     | 버그 수정      | 1주 이내 | 자유롭게 작업 가능       |
| `hotfix/*`  | 긴급 수정      | 1일 이내 | 즉시 처리            |

### 브랜치 흐름

```
main (프로덕션)
 ↑
dev (개발 통합)
 ↑
feature/TRAIN-XX (기능 개발)
```

---

## 기본 개발 흐름

### 1단계: Jira 이슈 확인

```
1. Jira에서 Task 확인
2. 자신을 Assignee로 지정
3. 상태를 "IN PROGRESS"로 변경
```

### 2단계: 브랜치 생성

```bash
# dev 최신화
git switch dev
git pull origin dev

# 기능 브랜치 생성 (Jira 이슈 키 포함)
git switch -c feature/TRAIN-12-user-authentication

# 첫 푸시
git push -u origin feature/TRAIN-12-user-authentication
```

### 3단계: 개발 및 커밋

```bash
# 작업 후 커밋 (Jira 이슈 키 필수)
git add .
git commit -m "TRAIN-12 feat: 로그인 폼 UI 구현"

# 푸시
git push origin feature/TRAIN-12-user-authentication
```

### 4단계: PR 생성

```bash
# GitHub에서 PR 생성
# 제목: TRAIN-12 feat: 사용자 인증 시스템 구현
# 본문: Jira 이슈 링크 포함
```

### 5단계: 코드 리뷰 및 병합

```bash
# 리뷰 승인 후 Squash & Merge
# Jira 이슈 자동 업데이트
```

### 6단계: 브랜치 정리

```bash
# 병합 후 로컬/원격 브랜치 삭제
git switch dev
git pull origin dev
git branch -d feature/TRAIN-12-user-authentication
git push origin --delete feature/TRAIN-12-user-authentication
```

---

## Jira 연동 워크플로우

### Smart Commit 사용

```bash
# 기본 커밋
git commit -m "TRAIN-12 feat: JWT 인증 구현"

# 코멘트 추가
git commit -m "TRAIN-12 #comment Redis 캐싱 추가"

# 작업 시간 기록
git commit -m "TRAIN-12 #time 2h 30m"

# 이슈 완료 처리
git commit -m "TRAIN-12 fix: 로그인 버그 수정 #done"

# 여러 명령 조합
git commit -m "TRAIN-12 feat: 결제 API #comment Toss 연동 #time 3h"
```

### 브랜치명 규칙

```bash
# 형식: 타입/TRAIN-이슈번호-설명
feature/TRAIN-12-user-authentication
fix/TRAIN-45-login-error
hotfix/TRAIN-99-security-patch
```

### PR 제목 규칙

```
# 형식: TRAIN-이슈번호 타입: 설명
TRAIN-12 feat: 사용자 인증 시스템 구현
TRAIN-45 fix: 로그인 에러 해결
```

### Jira 자동 연동

커밋 메시지에 TRAIN-XX 포함 시 다음이 자동으로 수행됩니다.

- Jira 이슈에 커밋 자동 연결
- Development 탭에 커밋 표시
- PR 생성 시 자동 링크

PR 머지 시 다음이 자동으로 수행됩니다.

- Jira 이슈 상태 자동 변경 (선택)
- Done 컬럼으로 이동

---

## 빠른 참조

### 새 작업 시작

```bash
git switch dev && git pull origin dev
git switch -c feature/TRAIN-XX-description
```

### 커밋 및 푸시

```bash
git add .
git commit -m "TRAIN-XX type: description"
git push origin feature/TRAIN-XX-description
```

### dev 최신화 (PR 전)

```bash
git switch dev && git pull origin dev
git switch feature/TRAIN-XX-description
git merge dev
```

### 브랜치 정리

```bash
git switch dev && git pull origin dev
git branch -d feature/TRAIN-XX-description
git push origin --delete feature/TRAIN-XX-description
```

---

## 관련 문서

* [브랜치 전략 상세](branching-strategy.md)
* [커밋 컨벤션](commit-convention.md)
* [PR 가이드](pull-request-guide.md)
* [코드 리뷰 가이드](code-review-guide.md)
* [충돌 해결](conflict-resolution.md)
* [다중 환경 작업](multi-env-workflow.md)
* [고급 Git 기법](advanced-git-techniques.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
