# 다중 환경 Git 작업 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 회사와 집에서 같은 브랜치로 작업을 이어가는 담당자
* **프론트엔드 개발자**: 여러 PC에서 동일한 기능을 개발하는 담당자
* **풀스택 개발자**: 다중 환경에서 동기화 문제를 관리하는 담당자
* **팀 리더 / PM**: 원격 작업 가이드를 제공하고 환경 통일을 관리하는 책임자
* **신규 합류자**: 환경 전환 시 코드 동기화 방법을 빠르게 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 여러 환경(회사 PC, 집 PC, 노트북 등)에서 Git 작업을 연속적으로 수행하는 방법을 정의합니다.
원격 저장소를 진실의 단일 출처(Single Source of Truth)로 삼아, 환경 전환 전 반드시 푸시하고 새 환경에서 pull로 시작하는 원칙을 따릅니다.
런타임 버전 고정, 에디터 설정 통일, 줄바꿈 통일, 민감정보 제외 등 환경 표준 세팅 방법을 다룹니다.
WIP 커밋 관리, 환경별 설정 분리, 자동화 스크립트 활용 방법을 제공하여 다중 환경에서의 효율적인 작업을 지원합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [핵심 원칙](#핵심-원칙)
3. [환경 표준 세팅](#환경-표준-세팅)
4. [환경 간 작업 이어가기](#환경-간-작업-이어가기)
5. [환경 이동 체크리스트](#환경-이동-체크리스트)
6. [문제 상황별 해결책](#문제-상황별-해결책)
7. [WIP 커밋 관리](#wip-커밋-관리)
8. [환경별 설정 관리](#환경별-설정-관리)
9. [npm ci vs npm install](#npm-ci-vs-npm-install)
10. [자동화 스크립트](#자동화-스크립트)
11. [보안 고려사항](#보안-고려사항)
12. [빠른 참조](#빠른-참조)

---

## 문서 개요 (Overview)

본 문서는 프로젝트 팀에서 여러 환경에서 Git 작업을 연속적으로 수행하는 방법을 정의하기 위해 작성되었습니다.

개발자들은 회사 PC, 집 PC, 노트북 등 여러 환경에서 작업하는 경우가 많습니다.
이 때 환경 간 코드 동기화 문제, 의존성 버전 불일치, 설정 차이 등으로 인한 문제가 발생할 수 있습니다.

본 문서는 원격 저장소를 중심으로 한 동기화 원칙, 환경 표준 세팅 방법, 문제 해결 방법을 제공하여
다중 환경에서도 안정적이고 효율적인 개발이 가능하도록 합니다.

---

## 핵심 원칙

### 원격 우선 (Remote-First)

원격 저장소가 진실의 단일 출처(Single Source of Truth)입니다.
환경 전환 전 반드시 푸시합니다.
새 환경에서 항상 pull로 시작합니다.

### 3단계 규칙

1. 떠나기 전: git commit → git push
2. 도착한 후: git pull → npm ci
3. 의심스러우면: 항상 원격 확인

---

## 환경 표준 세팅

### 런타임 버전 고정

```bash
# .nvmrc 파일 생성
echo "20.16.0" > .nvmrc

# 사용
nvm use
```

---

### 에디터 설정 통일

```ini
# .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true
```

---

### 줄바꿈 통일

```bash
# .gitattributes
* text=auto eol=lf
*.sh text eol=lf
*.bat text eol=crlf
*.png binary
*.jpg binary
```

---

### 민감정보 제외

```bash
# .gitignore
node_modules/
dist/
build/
.env
.env.*
!.env.example
.DS_Store
```

---

## 환경 간 작업 이어가기

### 환경 A에서 작업 마무리 (예: 회사)

```bash
# 1. 현재 상태 확인
git status

# 2-A. 완료된 작업: 정식 커밋
git add .
git commit -m "TRAIN-12 feat: 사용자 인증 로직 완료"

# 2-B. 미완성 작업: WIP 커밋
git add .
git commit -m "TRAIN-12 WIP: 사용자 인증 UI 작업 중"

# 3. 원격 푸시
git push origin feature/TRAIN-12-user-auth
```

---

### 환경 B에서 작업 이어받기 (예: 집)

#### 처음 프로젝트를 받는 경우

```bash
# 1. 클론
git clone <repository-url>
cd <project-name>

# 2. 브랜치 전환
git switch feature/TRAIN-12-user-auth

# 3. 의존성 설치
npm ci

# 4. 환경 변수 설정
cp .env.example .env.local
# .env.local 수정

# 5. 작업 시작
npm run dev
```

---

#### 이미 프로젝트가 있는 경우

```bash
# 1. 브랜치 전환
git switch feature/TRAIN-12-user-auth

# 2. 최신 코드 가져오기
git pull origin feature/TRAIN-12-user-auth

# 3. 의존성 재설치
npm ci

# 4. 작업 시작
npm run dev
```

---

## 환경 이동 체크리스트

### 떠나기 전

```markdown
- [ ] 변경사항 커밋 (WIP 포함)
- [ ] 원격 푸시 (git push)
- [ ] .env 파일 커밋 안 했는지 확인
- [ ] 로컬 서버 종료
```

---

### 도착한 후

```markdown
- [ ] 최신 코드 가져오기 (git pull)
- [ ] 의존성 재설치 (npm ci)
- [ ] 환경 변수 설정 (.env.local)
- [ ] 로컬 서버 실행 확인
```

---

## 문제 상황별 해결책

### Q1: 브랜치를 찾을 수 없습니다

```bash
# 원격 브랜치 확인
git fetch origin
git branch -r | grep TRAIN-12

# 브랜치 전환
git switch feature/TRAIN-12-user-auth

# 없으면 이전 환경에서 푸시 안 했을 가능성
```

---

### Q2: pull 받았는데 최신 코드가 반영되지 않습니다

```bash
# 1. Stash로 로컬 변경사항 백업
git stash push -m "임시 백업"

# 2. 강제로 원격과 동기화
git fetch origin
git reset --hard origin/feature/TRAIN-12-user-auth

# 3. Stash 복구 (필요 시)
git stash pop
```

---

### Q3: 환경마다 의존성 버전이 다릅니다

```bash
# 1. 한 환경에서 lock 파일 업데이트
npm install
git add package-lock.json
git commit -m "TRAIN-12 chore: 의존성 버전 고정"
git push

# 2. 다른 환경에서는 lock 기준으로 설치
git pull
npm ci
```

---

### Q4: OS 줄바꿈 문제 (CRLF/LF)

```bash
# .gitattributes 설정
echo "* text=auto eol=lf" > .gitattributes
git add .gitattributes
git commit -m "TRAIN-12 chore: LF로 줄바꿈 통일"
```

---

## WIP 커밋 관리

### WIP 커밋 사용

```bash
# 작업 중단 시
git add .
git commit -m "TRAIN-12 WIP: 로그인 UI 작업 중 - 환경 이동"
git push origin feature/TRAIN-12-user-auth
```

---

### WIP 커밋 정리 (PR 전)

```bash
# Interactive Rebase로 WIP 커밋 정리
git rebase -i HEAD~5

# 에디터에서 WIP 커밋들을 squash
# pick → squash 또는 fixup으로 변경

# 최종 커밋 메시지 작성
# TRAIN-12 feat: 사용자 로그인 기능 완료

# 강제 푸시 (사전 공지)
git push --force-with-lease origin feature/TRAIN-12-user-auth
```

---

## 환경별 설정 관리

### 환경 변수 분리

```bash
# 프로젝트에 포함
.env.example         # 키 목록만 (커밋)

# 로컬에만 존재
.env.local           # 실제 값 (커밋 금지)
```

---

### .env.example

```bash
# Database
DB_HOST=
DB_PORT=
DB_NAME=

# API Keys (로컬 개발용)
API_KEY=
```

---

### .env.local (각 환경마다 설정)

```bash
# 회사 PC
DB_HOST=localhost
DB_PORT=3306
DB_NAME=dev_db
API_KEY=dev_key_123

# 집 PC
DB_HOST=localhost
DB_PORT=3306
DB_NAME=dev_db
API_KEY=dev_key_123
```

---

## npm ci vs npm install

### npm install

```bash
# package.json 기준으로 설치
# lock 파일을 업데이트할 수 있음
# 의존성 버전이 변경될 가능성

npm install
```

---

### npm ci (권장)

```bash
# package-lock.json 기준으로 설치
# lock 파일을 수정하지 않음
# 모든 환경에서 동일한 버전 보장

npm ci
```

다중 환경에서는 npm ci 사용을 권장합니다.

---

## 자동화 스크립트

### 환경 전환 준비

```bash
#!/bin/bash
# scripts/leave-env.sh

BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "환경 전환 준비: $BRANCH"

# 변경사항 확인
if [[ -n $(git status --porcelain) ]]; then
  git add -A
  git commit -m "TRAIN-XX WIP: 환경 이동 전 자동 저장 ($(date '+%Y-%m-%d %H:%M'))"
fi

# 푸시
git push -u origin "$BRANCH"
echo "준비 완료!"
```

---

### 새 환경 동기화

```bash
#!/bin/bash
# scripts/sync-env.sh

BRANCH=$1
echo "$BRANCH 브랜치 동기화..."

# 원격에서 가져오기
git fetch origin
git switch "$BRANCH"
git pull origin "$BRANCH"

# 의존성 재설치
if [[ -f "package-lock.json" ]]; then
  npm ci
fi

# 환경 변수 확인
if [[ ! -f ".env.local" ]]; then
  echo "⚠️  .env.local 파일이 없습니다. .env.example을 복사하세요."
fi

echo "동기화 완료!"
```

---

## 보안 고려사항

### 회사 정책 확인

```markdown
확인 사항:

- [ ] 회사 코드를 개인 PC에 저장 가능한가?
- [ ] VPN 연결이 필요한가?
- [ ] 민감한 데이터가 포함되어 있는가?
```

---

### 민감정보 관리

```bash
# .gitignore에 추가
.env
.env.*
!.env.example
*.key
*.pem
credentials.json
```

---

## 빠른 참조

### 환경 전환 명령어

```bash
# 떠나기 전
git add . && git commit -m "TRAIN-XX WIP" && git push

# 도착 후
git pull && npm ci && npm run dev
```

---

### 긴급 상황

```bash
# 로컬을 원격과 완전히 동기화
git fetch origin
git reset --hard origin/$(git branch --show-current)

# 의존성 재설치
npm ci
```

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
