# 고급 Git 기법

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **숙련 개발자**: 고급 Git 기능이 필요한 복잡한 상황을 처리하는 담당자
* **팀 리더 / PM**: 브랜치 정리, 히스토리 관리, 응급 상황을 처리하는 책임자
* **DevOps 엔지니어**: 배포 관련 Git 작업과 복구를 수행하는 담당자
* **시니어 개발자**: 팀원들의 Git 문제를 해결하고 가이드하는 담당자

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 심화 Git 작업 방법과 응급 상황 대응을 정의합니다.
Rebase는 feature 브랜치의 커밋 정리와 dev 최신화에 사용하며, 공유 브랜치에서는 금지됩니다.
Cherry-pick은 hotfix를 dev에 적용하거나 특정 커밋만 이동할 때 사용합니다.
Reset은 로컬 전용, Revert는 공유 브랜치 안전 용도로 구분하여 사용합니다.
Stash는 작업 전환 시 변경사항을 임시 저장하며, Reflog는 삭제된 커밋 복구에 활용됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Rebase 규칙](#rebase-규칙)
3. [Cherry-pick](#cherry-pick)
4. [Reset과 Revert](#reset과-revert)
5. [Stash 활용](#stash-활용)
6. [응급 복구](#응급-복구)
7. [Git 설정 최적화](#git-설정-최적화)
8. [체크리스트](#체크리스트)

---

## 문서 개요 (Overview)

본 문서는 고급 Git 작업 방법과 응급 상황 대응을 명확히 하기 위해 작성되었습니다.

기본 Git 작업만으로는 복잡한 상황(커밋 정리, 히스토리 수정, 긴급 복구)을 처리하기 어렵습니다. 이를 위해 Rebase, Cherry-pick, Reset, Revert, Stash, Reflog 같은 고급
기능의 사용법과 주의사항을 정의합니다.

본 문서는 각 기능의 사용 시점, 명령어, 예시, 주의사항을 포함하여 안전하고 효율적인 Git 작업을 지원합니다.

---

## Rebase 규칙

### 언제 사용하는가

**사용 가능**:

- feature 브랜치의 WIP 커밋 정리
- PR 전 히스토리 정리
- dev 기준으로 feature 최신화

**사용 금지**:

- dev, main 등 공유 브랜치
- 다른 사람이 기반으로 작업 중인 브랜치
- 배포 대기 중인 브랜치

### Interactive Rebase

```bash
# 최근 5개 커밋 정리
git rebase -i HEAD~5

# 에디터에서 명령어 선택
pick abc123 TRAIN-12 feat: 로그인 추가
squash def456 TRAIN-12 WIP: 로그인 수정
squash ghi789 TRAIN-12 WIP: 버그 수정
pick jkl012 TRAIN-12 feat: 회원가입 추가

# 저장 후 커밋 메시지 작성
```

### Rebase 명령어

| 명령어      | 설명                  |
|----------|---------------------|
| `pick`   | 커밋 그대로 유지           |
| `squash` | 이전 커밋과 합치기 (메시지 합침) |
| `fixup`  | 이전 커밋과 합치기 (메시지 버림) |
| `reword` | 커밋 메시지만 수정          |
| `drop`   | 커밋 삭제               |

### dev 기준 Rebase

```bash
# dev 최신화
git switch dev
git pull origin dev

# feature 브랜치로 전환
git switch feature/TRAIN-12

# Rebase 실행
git rebase dev

# 충돌 발생 시 해결 후
git add .
git rebase --continue

# 강제 푸시 (사전 공지 필요)
git push --force-with-lease origin feature/TRAIN-12
```

### 팀 공지 필수

다음과 같이 사전 공지합니다.

```markdown
[사전 공지] feature/TRAIN-12 rebase 예정

목적: WIP 커밋 8개 → 3개로 정리
시간: 14:00-14:10
영향: 로컬 재동기화 필요
담당: @taekjun
```

---

## Cherry-pick

### 언제 사용하는가

다음 상황에서 사용합니다.

- hotfix를 dev에도 적용
- 특정 커밋만 다른 브랜치로 이동
- 릴리스 브랜치에 선택적 기능 추가

### 단일 커밋 Cherry-pick

```bash
# 1. 복사할 커밋 SHA 확인
git log --oneline

# 2. 대상 브랜치로 전환
git switch dev

# 3. Cherry-pick 실행
git cherry-pick abc123

# 4. 충돌 해결 (필요 시)
git add .
git cherry-pick --continue

# 5. 푸시
git push origin dev
```

### 여러 커밋 Cherry-pick

```bash
# 연속된 커밋
git cherry-pick abc123^..def456

# 개별 커밋
git cherry-pick abc123 def456 ghi789
```

### Hotfix 워크플로우

```bash
# 1. main에서 hotfix 브랜치 생성
git switch main
git switch -c hotfix/TRAIN-99-security

# 2. 수정 및 커밋
git commit -m "TRAIN-99 hotfix: 보안 취약점 수정"

# 3. main에 병합
git switch main
git merge hotfix/TRAIN-99-security
git push origin main

# 4. dev에도 적용 (cherry-pick)
git switch dev
git cherry-pick <hotfix-commit-sha>
git push origin dev
```

---

## Reset과 Revert

### Reset (로컬 전용)

```bash
# Soft: 커밋만 취소, 변경사항 유지
git reset --soft HEAD~1

# Mixed: 커밋과 스테이징 취소
git reset --mixed HEAD~1

# Hard: 모든 변경사항 삭제
git reset --hard HEAD~1
```

### Revert (공유 브랜치 안전)

```bash
# 단일 커밋 되돌리기
git revert abc123

# Merge 커밋 되돌리기
git revert -m 1 merge-commit-sha

# 여러 커밋 되돌리기
git revert abc123 def456
```

### 사용 구분

| 상황                 | Reset | Revert |
|--------------------|-------|--------|
| 로컬 전용 브랜치          | ✅     | ✅      |
| 공유 브랜치 (dev, main) | ❌     | ✅      |
| 푸시 전               | ✅     | ✅      |
| 푸시 후               | ❌     | ✅      |

---

## Stash 활용

### 기본 사용

```bash
# 변경사항 임시 저장
git stash push -m "로그인 UI 작업 중"

# 목록 확인
git stash list

# 복구
git stash pop

# 특정 stash 복구
git stash apply stash@{2}

# 삭제
git stash drop stash@{0}
```

### 선택적 Stash

```bash
# 특정 파일만 stash
git stash push -m "config만 임시 저장" -- config/settings.js

# Untracked 파일 포함
git stash push -u -m "새 파일 포함"

# 모든 변경사항 (ignored 포함)
git stash push -a -m "모든 파일 포함"
```

### 활용 시나리오

```bash
# 시나리오 1: 긴급 작업 전환
git stash push -m "feature 작업 중단"
git switch hotfix/TRAIN-99
# hotfix 작업 완료 후
git switch feature/TRAIN-12
git stash pop

# 시나리오 2: 실험적 변경
git stash push -m "실험 전 백업"
# 실험 진행
# 실패하면
git reset --hard
git stash pop
```

---

## 응급 복구

### Reflog 활용

```bash
# Reflog 확인
git reflog

# 특정 시점으로 복구
git reset --hard HEAD@{5}

# 삭제된 브랜치 복구
git reflog --all | grep "브랜치명"
git switch -c recovered-branch <commit-sha>
```

### 삭제된 커밋 복구

```bash
# 1. Reflog에서 커밋 찾기
git reflog | grep "커밋 메시지"

# 2. 커밋 복구
git cherry-pick <lost-commit-sha>

# 또는 브랜치로 복구
git switch -c recovery-branch <lost-commit-sha>
```

### 잘못된 Merge 되돌리기

```bash
# Merge 직후
git reset --hard HEAD~1

# 이미 푸시한 경우
git revert -m 1 <merge-commit-sha>
git push origin dev
```

### 강제 푸시로 인한 손실

```bash
# 1. 다른 팀원의 로컬에서 복구
# (팀원 PC에 히스토리가 남아있는 경우)
git push origin feature/branch:feature/branch-recovered

# 2. Reflog로 로컬 복구
git reflog
git reset --hard HEAD@{n}

# 3. GitHub에서 복구
# Settings → Branches → Restore
```

---

## Git 설정 최적화

### 유용한 설정

```bash
# Rerere (충돌 해결 기억)
git config --global rerere.enabled true

# 3-way diff
git config --global merge.conflictstyle diff3

# 기본 에디터
git config --global core.editor "code --wait"

# 줄바꿈 처리
git config --global core.autocrlf input  # Mac/Linux
git config --global core.autocrlf true   # Windows
```

### Alias 설정

```bash
# 자주 사용하는 명령어
git config --global alias.sw switch
git config --global alias.st status
git config --global alias.ci commit
git config --global alias.br branch

# 고급 로그
git config --global alias.lg "log --oneline --graph --all"

# 안전한 강제 푸시
git config --global alias.pushf "push --force-with-lease"
```

---

## 체크리스트

### Rebase 전

다음 사항을 체크합니다.

- 백업 브랜치 생성
- 팀 공지 (공유 브랜치인 경우)
- 로컬 테스트 통과 확인
- CI 상태 확인

### Reset/Revert 전

다음 사항을 체크합니다.

- 영향 범위 확인
- 백업 생성 (필요 시)
- 팀 공지 (공유 브랜치인 경우)
- 복구 계획 수립

### 강제 푸시 전

다음 사항을 체크합니다.

- --force-with-lease 사용
- 팀원 동의 확보
- 백업 브랜치 생성
- 동기화 가이드 준비

---

## 관련 문서

* [Git 워크플로우](git-workflow.md)
* [브랜치 전략](branching-strategy.md)
* [충돌 해결](conflict-resolution.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
