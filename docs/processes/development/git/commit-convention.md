# 커밋 컨벤션

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 커밋 메시지 규칙을 준수하고 Jira와 자동 연동하는 담당자
* **프론트엔드 개발자**: Conventional Commits 형식으로 커밋하고 이력을 관리하는 담당자
* **풀스택 개발자**: 백엔드/프론트엔드 모두에서 일관된 커밋 메시지를 작성하는 담당자
* **팀 리더 / PM**: 커밋 히스토리 품질을 관리하고 팀원들을 가이드하는 책임자
* **신규 합류자**: 커밋 메시지 규칙과 Jira Smart Commit을 빠르게 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀의 커밋 메시지 작성 규칙과 Jira 연동 방법을 정의합니다.
모든 커밋 메시지는 TRAIN-이슈번호 타입: 변경요약 형식을 따르며, Conventional Commits 표준을 준수합니다.
타입은 feat, fix, refactor, perf, style, docs, test, chore, ci 중 하나를 사용하며, 한 줄은 50자 이내로 작성합니다.
Jira Smart Commit 기능을 통해 커밋 시 자동으로 이슈에 연동되며, #comment, #time, #done 명령어를 사용할 수 있습니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [기본 형식](#기본-형식)
3. [타입 정의](#타입-정의)
4. [Jira Smart Commit](#jira-smart-commit)
5. [작성 규칙](#작성-규칙)
6. [예시](#예시)
7. [커밋 메시지 검증](#커밋-메시지-검증)
8. [빠른 참조](#빠른-참조)

---

## 문서 개요 (Overview)

본 문서는 팀 내 커밋 메시지 작성 규칙을 통일하기 위해 작성되었습니다.

일관된 커밋 메시지는 코드 히스토리를 명확히 하고, 버그 추적을 용이하게 하며, 자동화된 도구(릴리스 노트, 체인지로그)를 활용할 수 있게 합니다. 또한 Jira 이슈와 자동 연동되어 작업 추적성을 향상시킵니다.

본 컨벤션은 Conventional Commits 표준을 기반으로 하며, Jira Smart Commit 기능을 통합하여 팀의 협업 효율을 극대화합니다.

---

## 기본 형식

### 한 줄 커밋 (기본)

```
TRAIN-이슈번호 타입: 변경 요약
```

### 상세 커밋 (선택)

```
TRAIN-이슈번호 타입(스코프): 변경 요약

상세 설명
- 변경 사항 1
- 변경 사항 2

Breaking Changes: (있는 경우)
```

---

## 타입 정의

| 타입         | 설명                 | 예시                                 |
|------------|--------------------|------------------------------------|
| `feat`     | 새로운 기능 추가          | `TRAIN-12 feat: 소셜 로그인 추가`         |
| `fix`      | 버그 수정              | `TRAIN-23 fix: 메모리 누수 해결`          |
| `refactor` | 리팩토링 (기능 변화 없음)    | `TRAIN-34 refactor: 유저 서비스 구조 개선`  |
| `perf`     | 성능 개선              | `TRAIN-45 perf: DB 쿼리 최적화`         |
| `style`    | 코드 스타일 변경          | `TRAIN-56 style: 린트 규칙 적용`         |
| `docs`     | 문서 수정              | `TRAIN-67 docs: API 문서 업데이트`       |
| `test`     | 테스트 추가/수정          | `TRAIN-78 test: 로그인 테스트 추가`        |
| `chore`    | 빌드/설정 변경           | `TRAIN-89 chore: 의존성 업데이트`         |
| `ci`       | CI/CD 설정 변경        | `TRAIN-90 ci: 배포 스크립트 개선`          |
| `infra`    | 인프라, 배포, 환경 설정 변경  | `TRAIN-140 infra: Docker 빌드 최적화`   |
| `release`  | 릴리스 버전 태깅 및 QA 안정화 | `TRAIN-120 release: v1.2.0 릴리스 준비` |

---

### 브랜치 전략과 커밋 타입 매핑

| 브랜치          | 커밋 타입      | 설명              | 예시                                 |
|--------------|------------|-----------------|------------------------------------|
| `feature/*`  | `feat`     | 새로운 기능 추가       | `TRAIN-12 feat: 사용자 인증 기능 추가`      |
| `fix/*`      | `fix`      | 일반 버그 수정        | `TRAIN-23 fix: 로그인 검증 로직 수정`       |
| `hotfix/*`   | `hotfix`   | 프로덕션 긴급 수정      | `TRAIN-99 hotfix: 결제 오류 임시 복구`     |
| `refactor/*` | `refactor` | 코드 리팩토링         | `TRAIN-78 refactor: 서비스 구조 개선`     |
| `docs/*`     | `docs`     | 문서 수정           | `TRAIN-90 docs: API 문서 업데이트`       |
| `release/*`  | `release`  | QA 안정화 및 버전 태깅  | `TRAIN-120 release: v1.2.0 릴리스 준비` |
| `test/*`     | `test`     | 테스트 코드 작성/수정    | `TRAIN-133 test: 부하 테스트 스크립트 추가`   |
| `infra/*`    | `infra`    | 인프라/배포/CI 설정 변경 | `TRAIN-140 infra: Docker 빌드 최적화`   |
| `chore/*`    | `chore`    | 설정/의존성 관리       | `TRAIN-150 chore: ESLint 설정 수정`    |

---

## Jira Smart Commit

### 기본 명령어

```bash
# 1. 기본 커밋 (Jira 이슈에 연결)
git commit -m "TRAIN-12 feat: JWT 인증 구현"

# 2. 코멘트 추가
git commit -m "TRAIN-12 #comment Redis 캐싱 추가"

# 3. 작업 시간 기록
git commit -m "TRAIN-12 #time 2h 30m"

# 4. 이슈 완료 처리
git commit -m "TRAIN-12 fix: 로그인 버그 수정 #done"

# 5. 여러 명령 조합
git commit -m "TRAIN-12 feat: 결제 API #comment Toss 연동 완료 #time 3h"
```

### Smart Commit 명령어

| 명령어        | 설명             | 예시                     |
|------------|----------------|------------------------|
| 기본         | Jira 이슈에 커밋 연결 | `TRAIN-12 feat: 기능 추가` |
| `#comment` | 이슈에 코멘트 추가     | `#comment 작업 완료`       |
| `#time`    | 작업 시간 기록       | `#time 2h 30m`         |
| `#done`    | 이슈 완료 처리       | `#done`                |

### 자동 연동 결과

커밋 푸시 시 다음이 자동으로 수행됩니다.

- Jira 이슈 "Development" 탭에 커밋 표시
- 커밋 메시지와 GitHub 링크 자동 생성
- #done 사용 시 이슈 상태 "Done"으로 변경

---

## 작성 규칙

### 필수 규칙

다음 규칙을 준수합니다.

1. **Jira 이슈 번호 필수**: 모든 커밋은 `TRAIN-XX`로 시작
2. **타입 명시**: feat, fix, refactor 등 타입 필수
3. **한글/영문 혼용 가능**: 요약은 명확하게
4. **첫 줄 50자 이내**: 간결하게 요약
5. **현재형 사용**: "추가함" 대신 "추가"

### 권장 규칙

다음 규칙을 권장합니다.

1. **스코프 사용**: 변경 범위 명시 (선택)
2. **상세 설명**: 복잡한 변경은 본문 추가
3. **Breaking Changes**: API 변경 시 명시
4. **관련 이슈**: 여러 이슈 참조 가능

### 금지 사항

다음 사항을 금지합니다.

1. **의미 없는 메시지**: "수정", "fix", "wip"
2. **이슈 번호 누락**: Jira 연동 불가
3. **여러 기능 혼합**: 한 커밋에 한 가지만

---

## 예시

### 기본 예시

```bash
# 기능 추가
TRAIN-12 feat: 사용자 로그인 기능 추가

# 버그 수정
TRAIN-23 fix: 로그인 validation 오류 수정

# 리팩토링
TRAIN-34 refactor: 인증 로직 분리

# 문서 수정
TRAIN-45 docs: README 설치 방법 업데이트
```

### 스코프 포함

```bash
# 프론트엔드
TRAIN-56 feat(auth): 로그인 UI 컴포넌트 추가

# 백엔드
TRAIN-67 fix(api): JWT 토큰 갱신 로직 수정

# 데이터베이스
TRAIN-78 perf(db): 사용자 조회 쿼리 최적화
```

### Smart Commit 조합

```bash
# 작업 시간 기록
TRAIN-89 feat: 결제 모듈 구현 #time 4h

# 코멘트 추가
TRAIN-90 fix: 메모리 누수 해결 #comment 캐시 정리 로직 추가

# 완료 처리
TRAIN-101 feat: 관리자 대시보드 #done

# 모두 조합
TRAIN-102 feat: 알림 시스템 #comment WebSocket 구현 #time 5h #done
```

### 상세 설명 포함

```bash
git commit -m "TRAIN-12 feat: OAuth 2.0 소셜 로그인 구현

- Google, Facebook, GitHub 로그인 지원
- JWT 토큰 기반 세션 관리
- 기존 이메일 로그인과 통합

Breaking Changes:
- User 모델에 provider 필드 추가 (migration 필요)"
```

### 잘못된 예시

다음은 규칙을 위반한 예시입니다.

```bash
# Jira 이슈 번호 없음
feat: 로그인 기능 추가

# 타입 없음
TRAIN-12 로그인 기능 추가

# 의미 없는 메시지
TRAIN-12 fix: 수정

# 여러 작업 혼합
TRAIN-12 feat: 로그인 추가, 버그 수정, 리팩토링
```

---

## 커밋 메시지 검증

### Git Hooks 설정

`.git/hooks/commit-msg` 파일을 생성하여 검증을 자동화합니다.

#### 파일 생성 및 실행 권한 부여

```bash
touch .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

#### Git Hooks 스크립트

```bash
#!/bin/sh

commit_msg=$(cat $1)
commit_regex='^TRAIN-[0-9]+ (feat|fix|refactor|perf|style|docs|test|chore|ci|infra|release)(\(.+\))?: .{1,50}'

if ! echo "$commit_msg" | head -1 | grep -qE "$commit_regex"; then
    echo "❌ 잘못된 커밋 메시지 형식"
    echo ""
    echo "올바른 형식:"
    echo "  TRAIN-이슈번호 타입: 요약"
    echo ""
    echo "예시:"
    echo "  TRAIN-12 feat: 사용자 로그인 기능 추가"
    echo "  TRAIN-23 fix: 로그인 버그 수정"
    exit 1
fi
```

#### 검증 동작 확인

```bash
git commit -m "TRAIN-12 feat: 로그인 기능 추가"   # 통과
git commit -m "feat: 로그인 추가"                # 거부됨
```

---

### 커밋 템플릿

`.gitmessage` 파일을 생성하여 템플릿을 제공합니다.

```bash
TRAIN- type:

# 타입: feat, fix, refactor, perf, style, docs, test, chore, ci
# 요약: 50자 이내로 명확하게
#
# 상세 설명 (선택):
# -
#
# Smart Commit (선택):
# #comment
# #time
# #done

# 설정 방법:
# git config commit.template .gitmessage
```

---

## 빠른 참조

### 자주 사용하는 패턴

```bash
# 새 기능
TRAIN-XX feat: 기능 추가

# 버그 수정
TRAIN-XX fix: 버그 해결

# 리팩토링
TRAIN-XX refactor: 코드 개선

# 성능 개선
TRAIN-XX perf: 성능 최적화

# 문서 수정
TRAIN-XX docs: 문서 업데이트

# 의존성 업데이트
TRAIN-XX chore: 패키지 업데이트
```

---

## 관련 문서

* [Git 워크플로우](git-workflow.md)
* [브랜치 전략](branching-strategy.md)
* [PR 가이드](pull-request-guide.md)
* [Jira 가이드](../../collaboration/jira-guide.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
