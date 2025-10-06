# 충돌 해결 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Merge/Rebase 중 발생하는 충돌을 해결하는 담당자
* **프론트엔드 개발자**: 협업 시 발생하는 파일 충돌을 처리하는 담당자
* **풀스택 개발자**: 여러 브랜치에서 충돌을 예방하고 해결하는 담당자
* **팀 리더 / PM**: 충돌 방지 전략을 수립하고 팀원을 가이드하는 책임자
* **신규 합류자**: 충돌 해결 프로세스를 빠르게 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 Git 충돌 해결 방법과 예방 전략을 정의합니다.
충돌은 Merge, Rebase, Cherry-pick 작업 중 발생하며, 충돌 마커(<<<<<<<, =======, >>>>>>>)를 통해 확인합니다.
해결 방법은 수동 수정, 특정 버전 선택(--ours/--theirs), Merge Tool 사용 등이 있습니다.
package-lock.json은 재생성, JSON 파일은 구조 유지, DB 마이그레이션은 타임스탬프 변경으로 해결합니다.
예방 전략으로 자주 동기화, 작은 PR, 파일별 작업 분할, 브랜치 수명 단축을 권장합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [충돌 유형](#충돌-유형)
3. [기본 해결 방법](#기본-해결-방법)
4. [파일별 해결법](#파일별-해결법)
5. [충돌 방지 전략](#충돌-방지-전략)
6. [충돌 해결 도구](#충돌-해결-도구)
7. [복구 방법](#복구-방법)
8. [고급 충돌 해결](#고급-충돌-해결)
9. [체크리스트](#체크리스트)

---

## 문서 개요 (Overview)

본 문서는 Git 충돌 해결 방법과 예방 전략을 명확히 하기 위해 작성되었습니다.

여러 개발자가 동시에 작업하면 같은 파일을 수정하여 충돌이 발생합니다. 충돌은 프로젝트 진행을 지연시키고, 잘못 해결하면 코드 손실이나 버그를 유발할 수 있습니다.

본 문서는 충돌 유형, 해결 방법, 파일별 특수 케이스, 예방 전략, 복구 방법을 포함하여 안전하고 효율적인 충돌 해결을 지원합니다.

---

## 충돌 유형

### 1. Merge 충돌

```bash
# 상황: feature 브랜치를 dev에 병합할 때
git switch feature/TRAIN-12
git merge dev

Auto-merging src/user.service.js
CONFLICT (content): Merge conflict in src/user.service.js
```

### 2. Rebase 충돌

```bash
# 상황: feature 브랜치를 dev 기준으로 rebase할 때
git switch feature/TRAIN-12
git rebase dev

CONFLICT (content): Merge conflict in src/api.controller.js
```

### 3. Cherry-pick 충돌

```bash
# 상황: 특정 커밋만 가져올 때
git cherry-pick abc123

CONFLICT (modify/delete): src/config.js deleted in HEAD
```

---

## 기본 해결 방법

### Merge 충돌 해결

```bash
# 1. 충돌 파일 확인
git status

# 2. 충돌 파일 수정
# 에디터에서 충돌 마커 확인 및 해결

# 3. 해결된 파일 스테이징
git add src/user.service.js

# 4. 병합 완료
git commit -m "TRAIN-12 fix: dev 병합 충돌 해결"

# 5. 푸시
git push origin feature/TRAIN-12
```

### Rebase 충돌 해결

```bash
# 1. 충돌 파일 확인
git status

# 2. 충돌 파일 수정
# 에디터에서 충돌 해결

# 3. 해결된 파일 스테이징
git add src/api.controller.js

# 4. Rebase 계속
git rebase --continue

# 5. 강제 푸시 (사전 공지 필요)
git push --force-with-lease origin feature/TRAIN-12
```

### 충돌 마커 이해

```js
<
<
<
<
<
<
< HEAD (현재
브랜치
)

function login(email, password) {
    return authenticateUser(email, password);
}

======
=
    function login(username, password) {
        return auth.validate(username, password);
    }
    >>> >>> > feature / TRAIN - 12(들어오는
브랜치
)
```

**해결 방법**:

1. 두 버전 비교
2. 올바른 버전 선택 또는 통합
3. 충돌 마커 제거

---

## 파일별 해결법

### JavaScript/TypeScript 파일

```bash
# 충돌 확인
git status

# 수동 해결
code src/user.service.js

# 해결 예시
function login(email, password) {
  // 두 버전 통합
  const user = authenticateUser(email, password);
  return auth.validate(user);
}

# 스테이징
git add src/user.service.js
```

### package-lock.json 충돌

```bash
# 방법 1: lock 파일 재생성
rm package-lock.json
npm install
git add package-lock.json

# 방법 2: npm ci 후 재생성
npm ci
npm install
git add package-lock.json
```

### JSON 파일 충돌

```bash
# 수동 해결 (JSON 구조 유지)
code config/settings.json

# JSON 유효성 검증
npx jsonlint config/settings.json

# 스테이징
git add config/settings.json
```

### 데이터베이스 마이그레이션 충돌

```bash
# 1. 마이그레이션 파일 목록 확인
ls migrations/ | sort

# 2. 중복 번호 해결 (타임스탬프 변경)
mv migrations/20251005120000_add_column.sql \
   migrations/20251005120001_add_column.sql

# 3. 스테이징
git add migrations/
```

---

## 충돌 방지 전략

### 1. 자주 동기화

```bash
# 매일 아침 dev 최신화
git switch dev
git pull origin dev
git switch feature/TRAIN-12
git merge dev
```

### 2. 작은 PR

작은 PR로 빠른 리뷰 및 병합으로 충돌을 최소화합니다.

```bash
# 300줄 이하로 유지
```

### 3. 파일별 작업 분할

동일 파일 수정을 최소화합니다.

```bash
# 동일 파일 수정 최소화
팀원 A: user.controller.js
팀원 B: user.service.js
공통 파일: 사전 논의 후 순차 작업
```

### 4. 브랜치 수명 단축

2주 이내 병합을 원칙으로 합니다. 오래된 브랜치는 충돌 가능성이 증가합니다.

---

## 충돌 해결 도구

### VS Code 활용

```bash
# VS Code에서 충돌 해결
1. 충돌 파일 열기
2. "Accept Current Change" / "Accept Incoming Change" 버튼 클릭
3. 또는 "Accept Both Changes" 후 수동 통합
4. 저장 후 스테이징
```

### Git 설정

```bash
# 3-way diff 활성화 (더 명확한 충돌 정보)
git config --global merge.conflictstyle diff3

# Rerere 활성화 (충돌 해결 기억)
git config --global rerere.enabled true
```

### Merge Tool

```bash
# Merge Tool 설정
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Merge Tool 실행
git mergetool
```

---

## 복구 방법

### 병합 중단

```bash
# Merge 중단
git merge --abort

# Rebase 중단
git rebase --abort

# Cherry-pick 중단
git cherry-pick --abort
```

### 잘못된 해결 복구

```bash
# 1. Reflog 확인
git reflog

# 2. 이전 상태로 복구
git reset --hard HEAD@{n}

# 3. 재시도
git merge dev
```

### 백업 활용

```bash
# 충돌 해결 전 백업 생성
git branch backup-before-merge

# 잘못되면 백업에서 복구
git reset --hard backup-before-merge
```

---

## 고급 충돌 해결

### 대량 충돌 처리

```bash
# 우리 버전 선택
git checkout --ours path/to/file

# 상대방 버전 선택
git checkout --theirs path/to/file

# 스테이징
git add path/to/file
```

### 바이너리 파일 충돌

```bash
# 이미지, 문서 등
# 1. 양쪽 버전 확인
git show HEAD:path/to/image.png > image_ours.png
git show MERGE_HEAD:path/to/image.png > image_theirs.png

# 2. 올바른 버전 선택
cp image_theirs.png path/to/image.png

# 3. 스테이징
git add path/to/image.png
```

---

## 체크리스트

### 충돌 발생 시

다음 사항을 체크합니다.

- 충돌 파일 목록 확인 (git status)
- 충돌 원인 파악
- 백업 생성 (선택)
- 충돌 마커 찾기
- 올바른 버전 선택/통합
- 충돌 마커 제거
- 파일 저장
- 스테이징 (git add)
- 빌드/테스트 확인
- 커밋 또는 계속 진행

### 충돌 해결 후

다음 사항을 체크합니다.

- 로컬 빌드 성공
- 테스트 통과
- 코드 스타일 일관성
- 기능 정상 작동
- 푸시 전 최종 확인

---

## 관련 문서

* [Git 워크플로우](git-workflow.md)
* [브랜치 전략](branching-strategy.md)
* [고급 Git 기법](advanced-git-techniques.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
