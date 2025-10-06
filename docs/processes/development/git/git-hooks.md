# Git Hooks 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Git Hooks를 설정하고 커밋/푸시 전 자동 검증을 적용하는 담당자
* **프론트엔드 개발자**: 코드 품질 검사를 자동화하고 규칙 위반을 방지하는 담당자
* **풀스택 개발자**: 여러 저장소에서 일관된 Hooks를 유지하는 담당자
* **팀 리더 / PM**: 팀 전체의 Hooks 표준을 수립하고 관리하는 책임자
* **신규 합류자**: Git Hooks 설정 방법을 빠르게 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 Git Hooks 설정과 자동 검증 규칙을 정의합니다.
Git Hooks는 커밋, 푸시 같은 Git 이벤트 발생 시 자동으로 실행되는 스크립트입니다.
Pre-commit은 린트, 테스트, 브랜치명 검증을, Commit-msg는 커밋 메시지 형식 검증을, Pre-push는 보호 브랜치 푸시 방지를 수행합니다.
Husky를 사용하여 팀 전체가 동일한 Hooks를 자동으로 설치하고 사용할 수 있습니다.
긴급 상황 시 --no-verify 옵션으로 우회할 수 있지만, 남용은 금지됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Git Hooks 개요](#git-hooks-개요)
3. [Pre-commit Hook](#pre-commit-hook)
4. [Commit-msg Hook](#commit-msg-hook)
5. [Pre-push Hook](#pre-push-hook)
6. [설치 및 관리](#설치-및-관리)
7. [Hooks 우회 방법](#hooks-우회-방법)
8. [팀 공유 방법](#팀-공유-방법)
9. [트러블슈팅](#트러블슈팅)
10. [체크리스트](#체크리스트)

---

## 문서 개요 (Overview)

본 문서는 Git Hooks 설정과 자동 검증 규칙을 명확히 하기 위해 작성되었습니다.

수동으로 코드 품질을 검사하면 실수가 발생하고, 일관성이 떨어지며, 리뷰 시간이 늘어납니다. 이를 방지하기 위해 Git Hooks를 활용하여 커밋/푸시 전에 자동으로 검증합니다.

본 문서는 Pre-commit, Commit-msg, Pre-push Hook의 설정 방법, 검증 규칙, 설치 방법, 우회 방법을 포함하여 자동화된 품질 관리를 지원합니다.

---

## Git Hooks 개요

### Git Hooks란?

Git 이벤트 발생 시 자동으로 실행되는 스크립트입니다.

- 커밋, 푸시 전에 자동 검증
- 규칙 위반 방지
- 코드 품질 자동 관리

### 주요 Hooks

| Hook         | 실행 시점       | 용도             |
|--------------|-------------|----------------|
| `pre-commit` | 커밋 직전       | 린트, 테스트, 포맷 검사 |
| `commit-msg` | 커밋 메시지 작성 후 | Jira 이슈 번호 검증  |
| `pre-push`   | 푸시 직전       | 보호 브랜치 푸시 방지   |

### Hooks 위치

```bash
.git/hooks/
├── pre-commit
├── commit-msg
└── pre-push
```

---

## Pre-commit Hook

### 목적

커밋 전에 코드 품질을 검사합니다.

- 린트 검사
- 테스트 실행
- 브랜치명 검증
- 보안 스캔

### 스크립트

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Pre-commit 검사 실행 중..."

# 1. 린트 검사
echo "코드 스타일 검사 중..."
npm run lint
if [ $? -ne 0 ]; then
    echo "❌ 린트 검사 실패"
    echo "수정: npm run lint:fix"
    exit 1
fi

# 2. 포맷 검사
echo "코드 포맷 검사 중..."
npm run format:check
if [ $? -ne 0 ]; then
    echo "❌ 포맷 검사 실패"
    echo "수정: npm run format"
    exit 1
fi

# 3. 변경된 파일 테스트
echo "테스트 실행 중..."
npm run test:staged
if [ $? -ne 0 ]; then
    echo "❌ 테스트 실패"
    exit 1
fi

# 4. 브랜치명 검증
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ ! $BRANCH =~ ^(feature|fix|hotfix|refactor|docs)/TRAIN-[0-9]+ ]]; then
    echo "❌ 잘못된 브랜치명: $BRANCH"
    echo "올바른 형식: feature/TRAIN-XX-description"
    exit 1
fi

# 5. 보안 검사 (선택)
echo "보안 검사 중..."
npm audit --audit-level high
if [ $? -ne 0 ]; then
    echo "⚠️  보안 취약점 발견"
    echo "확인: npm audit"
    # 경고만 출력, 커밋은 허용
fi

echo "☑️ Pre-commit 검사 통과"
```

### 실행 흐름

```
git commit 실행
    ↓
Pre-commit Hook 자동 실행
    ↓
린트 검사 → 실패 시 커밋 중단
    ↓
포맷 검사 → 실패 시 커밋 중단
    ↓
테스트 실행 → 실패 시 커밋 중단
    ↓
브랜치명 검증 → 잘못되면 커밋 중단
    ↓
모두 통과 → 커밋 완료
```

---

## Commit-msg Hook

### 목적

커밋 메시지 형식을 검증합니다.

- Jira 이슈 번호 확인
- 커밋 타입 검증
- 메시지 길이 제한

### 스크립트

```bash
#!/bin/sh
# .git/hooks/commit-msg

commit_file=$1
commit_msg=$(cat $commit_file)

echo "커밋 메시지 검증 중..."

# 1. Jira 이슈 번호 + 타입 검증
commit_regex='^TRAIN-[0-9]+ (feat|fix|refactor|perf|style|docs|test|chore|ci|revert|infra|release|hotfix)(\(.+\))?: .{1,50}'

if ! echo "$commit_msg" | head -1 | grep -qE "$commit_regex"; then
    echo "❌ 잘못된 커밋 메시지 형식"
    echo ""
    echo "올바른 형식:"
    echo "  TRAIN-이슈번호 타입: 요약"
    echo ""
    echo "예시:"
    echo "  TRAIN-12 feat: 사용자 로그인 기능 추가"
    echo "  TRAIN-23 fix: 로그인 버그 수정"
    echo "  TRAIN-34 refactor: 인증 로직 개선"
    echo ""
    echo "현재 메시지:"
    echo "  $commit_msg"
    exit 1
fi

# 2. 제목 길이 검증 (50자 제한)
title=$(echo "$commit_msg" | head -1)
if [ ${#title} -gt 72 ]; then
    echo "⚠️  커밋 메시지 제목이 너무 깁니다 (${#title}자)"
    echo "권장: 50자 이내"
fi

# 3. WIP 커밋 경고
if echo "$commit_msg" | grep -qi "WIP"; then
    echo "⚠️  WIP 커밋입니다. PR 전에 정리하세요."
fi

echo "☑️ 커밋 메시지 형식 올바름"
```

### 검증 규칙

필수 형식은 다음과 같습니다.

```
TRAIN-이슈번호 타입: 요약
```

검증 항목은 다음과 같습니다.

1. Jira 이슈 번호 (TRAIN-XX)
2. 타입 (feat, fix, refactor 등)
3. 콜론(:) 포함
4. 요약 존재
5. 제목 50자 이내 (권장)

---

## Pre-push Hook

### 목적

푸시 전 최종 검증을 수행합니다.

- 보호 브랜치 직접 푸시 방지
- 민감정보 푸시 방지
- 대용량 파일 방지

### 스크립트

```bash
#!/bin/sh
# .git/hooks/pre-push

echo "Pre-push 검사 실행 중..."

# 1. 보호 브랜치 직접 푸시 금지
protected_branches="main dev"
current_branch=$(git rev-parse --abbrev-ref HEAD)

for protected in $protected_branches; do
    if [ "$current_branch" = "$protected" ]; then
        echo "❌ $protected 브랜치에 직접 푸시할 수 없습니다"
        echo "Pull Request를 사용하세요"
        exit 1
    fi
done

# 2. 민감정보 검사
echo "민감정보 검사 중..."
if git log --name-only --pretty=format: HEAD~10..HEAD | grep -E '\.(env|key|pem|p12)$'; then
    echo "❌ 민감한 파일이 포함되어 있습니다"
    echo "해당 파일을 제거하고 .gitignore에 추가하세요"
    exit 1
fi

# 3. 대용량 파일 검사 (50MB 초과)
echo "대용량 파일 검사 중..."
large_files=$(git diff --cached --name-only | xargs ls -la 2>/dev/null | awk '$5 > 52428800 {print $9}')
if [ ! -z "$large_files" ]; then
    echo "❌ 대용량 파일 발견 (50MB 초과):"
    echo "$large_files"
    echo "Git LFS 사용을 고려하세요"
    exit 1
fi

# 4. Jira 이슈 번호 확인
if [[ ! $current_branch =~ TRAIN-[0-9]+ ]]; then
    echo "⚠️  브랜치에 Jira 이슈 번호가 없습니다"
    echo "브랜치명: $current_branch"
    # 경고만 출력, 푸시는 허용
fi

echo "☑️ Pre-push 검사 통과"
```

### 검증 항목

다음 항목을 검증합니다.

1. 보호 브랜치 (main, dev) 직접 푸시 금지
2. 민감정보 파일 (.env, .key 등) 푸시 방지
3. 대용량 파일 (50MB 초과) 경고
4. Jira 이슈 번호 확인

---

## 설치 및 관리

### 수동 설치

```bash
# 1. Hooks 디렉토리로 이동
cd .git/hooks

# 2. Hook 파일 생성
touch pre-commit
touch commit-msg
touch pre-push

# 3. 실행 권한 부여
chmod +x pre-commit
chmod +x commit-msg
chmod +x pre-push

# 4. 스크립트 작성
# (위 스크립트 복사)
```

### 자동 설치 (Husky)

```bash
# 1. Husky 설치
npm install --save-dev husky

# 2. Husky 초기화
npx husky init

# 3. Hooks 추가
npx husky add .husky/pre-commit "npm run lint && npm run test:staged"
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit ${1}'
npx husky add .husky/pre-push "npm run test"
```

### package.json 설정

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "test": "jest",
    "test:staged": "jest --findRelatedTests",
    "prepare": "husky install"
  },
  "devDependencies": {
    "husky": "^8.0.0",
    "@commitlint/cli": "^17.0.0",
    "@commitlint/config-conventional": "^17.0.0"
  }
}
```

### Commitlint 설정

```js
// .commitlintrc.js
module.exports = {
    extends: ['@commitlint/config-conventional'],
    rules: {
        'header-max-length': [2, 'always', 72],
        'subject-case': [0],
        'type-enum': [
            2,
            'always',
            ['feat', 'fix', 'refactor', 'perf', 'style', 'docs', 'test', 'chore', 'ci', 'revert']
        ],
        'subject-empty': [2, 'never'],
        // Jira 이슈 번호 검증
        'header-pattern': [
            2,
            'always',
            /^TRAIN-[0-9]+ (feat|fix|refactor|perf|style|docs|test|chore|ci|revert)(\(.+\))?: .+$/
        ]
    }
};
```

---

## Hooks 우회 방법

### 긴급 상황 시

```bash
# Hooks 무시하고 커밋 (비추천)
git commit --no-verify -m "TRAIN-12 hotfix: 긴급 수정"

# Hooks 무시하고 푸시 (비추천)
git push --no-verify
```

### 우회 사용 시나리오

**허용**:

- 긴급 hotfix
- CI 실패로 인한 임시 우회
- Hooks 자체 수정 테스트

**금지**:

- 린트 검사 회피
- 테스트 실패 숨기기
- 규칙 무시

---

## 팀 공유 방법

### 저장소에 포함

```bash
# 1. scripts/ 디렉토리에 저장
mkdir -p scripts/git-hooks
cp .git/hooks/pre-commit scripts/git-hooks/
cp .git/hooks/commit-msg scripts/git-hooks/
cp .git/hooks/pre-push scripts/git-hooks/

# 2. 설치 스크립트 작성
# scripts/install-hooks.sh
#!/bin/bash
cp scripts/git-hooks/* .git/hooks/
chmod +x .git/hooks/*
echo "☑️ Git Hooks 설치 완료"

# 3. README에 안내
echo "## 개발 환경 설정
git clone ...
npm install
./scripts/install-hooks.sh  # Git Hooks 설치
" >> README.md
```

### Husky 사용 (권장)

```bash
# 1. Husky 설치 (팀 전체)
npm install

# 2. 자동으로 Hooks 설치됨
# (prepare 스크립트에서 husky install 실행)

# 3. 팀원들은 별도 작업 불필요
```

---

## 트러블슈팅

### Hook이 실행되지 않습니다

```bash
# 1. 실행 권한 확인
ls -la .git/hooks/pre-commit

# 2. 실행 권한 부여
chmod +x .git/hooks/pre-commit

# 3. shebang 확인
head -1 .git/hooks/pre-commit
# #!/bin/sh 또는 #!/bin/bash
```

### Hook이 너무 느립니다

다음 방법으로 최적화합니다.

```bash
# 1. 변경된 파일만 검사
npm run lint:staged  # 전체 대신
npm run test:staged  # 변경된 파일만

# 2. 병렬 실행
npm run lint & npm run test &
wait

# 3. 캐시 활용
# ESLint, Jest 캐시 설정
```

### Windows에서 Hook 오류

Git Bash 사용을 권장하거나 shebang을 수정합니다.

```bash
#!/usr/bin/env bash
```

---

## 체크리스트

### 신규 프로젝트 설정

다음 사항을 체크합니다.

- Husky 설치
- Commitlint 설정
- Pre-commit 설정
- Commit-msg 설정
- Pre-push 설정
- package.json 스크립트 추가
- README 설치 가이드 추가

### 기존 프로젝트 적용

다음 사항을 체크합니다.

- 팀 공지
- Hooks 스크립트 준비
- 설치 스크립트 작성
- 테스트 (더미 커밋)
- README 업데이트
- 팀원 설치 확인

---

## 관련 문서

* [Git 워크플로우](git-workflow.md)
* [커밋 컨벤션](commit-convention.md)
* [브랜치 전략](branching-strategy.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
