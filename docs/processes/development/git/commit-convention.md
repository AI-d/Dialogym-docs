# 커밋 컨벤션

**담당자**: [왕택준](https://github.com/TJK98)  
**작성일**: 2025.10.05  
**문서 버전**: v0.2  
**문서 상태**: Draft

---

## 핵심 요약

모든 커밋 메시지는 `TRAIN-이슈번호 타입: 변경요약` 형식을 따릅니다.  
한 줄은 **50자 이내**로 작성하며, **90% 이상의 커밋은 한 줄로 충분**합니다.  
복잡한 변경이나 Breaking Changes가 있을 때만 본문/꼬리말을 추가합니다.

---

## 기본 형식

### 한 줄 커밋 (기본 - 90% 이상)

```
TRAIN-이슈번호 타입: 변경요약
```

### 본문 추가 (선택사항)

```
TRAIN-이슈번호 타입: 변경요약

본문 내용 (필요시)
```

### 꼬리말 추가 (Breaking Changes만)

```
TRAIN-이슈번호 타입!: 변경요약

본문 내용

BREAKING CHANGE: 상세 설명
```

> **참고**: Conventional Commits 표준에 따라 본문과 꼬리말은 **선택사항**입니다.  
> 대부분의 경우 한 줄 커밋만으로 충분합니다.

---

## 타입 정의

| 타입         | 설명                   | 예시                                |
|------------|-----------------------|-----------------------------------|
| `feat`     | 새로운 기능 추가            | `TRAIN-12 feat: 소셜 로그인 추가`        |
| `fix`      | 버그 수정                | `TRAIN-23 fix: 메모리 누수 해결`         |
| `refactor` | 리팩토링 (기능 변화 없음)      | `TRAIN-34 refactor: 유저 서비스 구조 개선` |
| `perf`     | 성능 개선                | `TRAIN-45 perf: DB 쿼리 최적화`        |
| `style`    | 코드 스타일 변경 (포맷팅, 세미콜론) | `TRAIN-56 style: 린트 규칙 적용`        |
| `docs`     | 문서 수정                | `TRAIN-67 docs: API 문서 업데이트`      |
| `test`     | 테스트 추가/수정            | `TRAIN-78 test: 로그인 테스트 추가`       |
| `chore`    | 빌드/설정 변경             | `TRAIN-89 chore: 의존성 업데이트`        |
| `ci`       | CI/CD 설정 변경          | `TRAIN-90 ci: 배포 스크립트 개선`         |
| `infra`    | 인프라, 배포, 환경 설정 변경    | `TRAIN-140 infra: Docker 설정 개선`   |
| `release`  | 릴리스 버전 태깅            | `TRAIN-120 release: v1.2.0 배포`    |

---

## 브랜치별 커밋 타입

| 브랜치          | 커밋 타입      | 예시                                 |
|--------------|------------|------------------------------------|
| `feature/*`  | `feat`     | `TRAIN-12 feat: 사용자 인증 기능 추가`      |
| `fix/*`      | `fix`      | `TRAIN-23 fix: 로그인 검증 로직 수정`       |
| `hotfix/*`   | `fix`      | `TRAIN-99 fix: 결제 오류 긴급 수정`        |
| `refactor/*` | `refactor` | `TRAIN-78 refactor: 서비스 구조 개선`     |
| `docs/*`     | `docs`     | `TRAIN-90 docs: API 문서 업데이트`       |
| `release/*`  | `release`  | `TRAIN-120 release: v1.2.0 릴리스`    |
| `test/*`     | `test`     | `TRAIN-133 test: 부하 테스트 추가`        |
| `infra/*`    | `infra`    | `TRAIN-140 infra: Docker 빌드 최적화`   |
| `chore/*`    | `chore`    | `TRAIN-150 chore: ESLint 설정 수정`    |

---

## Jira Smart Commit

### 기본 명령어

```bash
# 1. 기본 커밋
git commit -m "TRAIN-12 feat: JWT 인증 구현"

# 2. 코멘트 추가
git commit -m "TRAIN-12 feat: JWT 인증 구현 #comment Redis 캐싱 추가"

# 3. 작업 시간 기록
git commit -m "TRAIN-12 feat: JWT 인증 구현 #time 2h 30m"

# 4. 이슈 완료 처리
git commit -m "TRAIN-12 fix: 로그인 버그 수정 #done"

# 5. 여러 명령 조합
git commit -m "TRAIN-12 feat: 결제 API 구현 #comment Toss 연동 완료 #time 3h #done"
```

### Smart Commit 명령어

| 명령어        | 설명          | 예시                |
|------------|-------------|-------------------|
| `#comment` | 이슈에 코멘트 추가  | `#comment 작업 완료`  |
| `#time`    | 작업 시간 기록    | `#time 2h 30m`    |
| `#done`    | 이슈 완료 처리    | `#done`           |

---

## 작성 규칙

### 필수 규칙

1. ☑️ **Jira 이슈 번호 필수**: 모든 커밋은 `TRAIN-XX`로 시작
2. ☑️ **타입 명시**: feat, fix, refactor 등 타입 필수
3. ☑️ **첫 줄 50자 이내**: 간결하게 요약
4. ☑️ **현재형 동사 사용**: "추가함" ❌ → "추가" ☑️

### 권장 사항

1. 한글/영문 혼용 가능 (팀 내 편한 언어 사용)
2. 한 커밋에는 한 가지 작업만
3. 본문/꼬리말은 정말 필요할 때만

### 금지 사항

1. ❌ **의미 없는 메시지**: "수정", "fix", "wip"
2. ❌ **이슈 번호 누락**: Jira 연동 불가
3. ❌ **여러 기능 혼합**: 한 커밋에 한 가지만

---

## 예시

### 기본 예시 (90% 이상)

```bash
TRAIN-12 feat: 사용자 로그인 기능 추가
TRAIN-23 fix: 로그인 validation 오류 수정
TRAIN-34 refactor: 인증 로직 분리
TRAIN-45 docs: README 설치 방법 업데이트
TRAIN-56 perf: 사용자 조회 쿼리 최적화
```

### 본문 포함 (복잡한 변경시)

```bash
TRAIN-12 feat: OAuth 2.0 소셜 로그인 구현

Google, Facebook, GitHub 로그인 지원
JWT 토큰 기반 세션 관리
기존 이메일 로그인과 통합
```

### Breaking Changes (API 변경시)

```bash
TRAIN-100 feat!: 인증 API v2로 전환

기존 /auth/login 엔드포인트 제거
새로운 /api/v2/auth/login 사용

BREAKING CHANGE: 기존 v1 인증 API는 더 이상 지원되지 않음
```

### Smart Commit 조합

```bash
TRAIN-89 feat: 결제 모듈 구현 #time 4h
TRAIN-90 fix: 메모리 누수 해결 #comment 캐시 정리 로직 추가
TRAIN-101 feat: 관리자 대시보드 #done
```

### 잘못된 예시

```bash
# ❌ Jira 이슈 번호 없음
feat: 로그인 기능 추가

# ❌ 타입 없음
TRAIN-12 로그인 기능 추가

# ❌ 의미 없는 메시지
TRAIN-12 fix: 수정

# ❌ 여러 작업 혼합
TRAIN-12 feat: 로그인 추가, 버그 수정, 리팩토링

# ❌ 과거형 사용
TRAIN-12 feat: 로그인 기능을 추가했음
```

---

## 언제 본문/꼬리말을 쓸까?

### 한 줄로 충분한 경우 (90%)
```bash
TRAIN-12 feat: 소셜 로그인 추가
TRAIN-23 fix: 메모리 누수 해결
TRAIN-34 refactor: 서비스 구조 개선
```

### 본문이 필요한 경우 (9%)
- 변경 사항이 복잡해서 맥락 설명 필요
- 여러 파일에 걸친 변경의 이유 설명

```bash
TRAIN-45 perf: 사용자 조회 성능 개선

인덱스 추가로 조회 속도 50% 향상
N+1 쿼리 문제 해결
캐시 레이어 추가
```

### 꼬리말이 필요한 경우 (1%)
- **Breaking Changes**: API가 변경되어 하위 호환성이 깨짐
- **Major 버전 업데이트**: 기존 사용자에게 영향

```bash
TRAIN-100 feat!: 인증 시스템 v2 전환

BREAKING CHANGE: 기존 JWT 토큰 형식 변경으로 
모든 클라이언트는 재로그인 필요
```

> **원칙**: 제목만으로 이해 안 되면 본문 추가, API 변경이면 꼬리말 추가

---

## 커밋 메시지 검증

### Git Hooks 설정

`.git/hooks/commit-msg` 파일 생성:

```bash
#!/bin/sh

commit_msg=$(cat $1)
commit_regex='^TRAIN-[0-9]+ (feat|fix|refactor|perf|style|docs|test|chore|ci|infra|release)(!)?:'

if ! echo "$commit_msg" | head -1 | grep -qE "$commit_regex"; then
    echo "❌ 잘못된 커밋 메시지 형식"
    echo ""
    echo "올바른 형식: TRAIN-이슈번호 타입: 요약"
    echo "예시: TRAIN-12 feat: 사용자 로그인 기능 추가"
    exit 1
fi
```

실행 권한 부여:
```bash
chmod +x .git/hooks/commit-msg
```

---

## 빠른 참조

```bash
# 일반 커밋 (90%)
TRAIN-XX feat: 기능 추가
TRAIN-XX fix: 버그 해결
TRAIN-XX refactor: 코드 개선

# Smart Commit
TRAIN-XX feat: 기능 추가 #done
TRAIN-XX feat: 기능 추가 #time 3h

# Breaking Changes (1%)
TRAIN-XX feat!: API 변경

BREAKING CHANGE: 기존 API 제거
```

---

## Conventional Commits 호환성

본 컨벤션은 [Conventional Commits v1.0.0](https://www.conventionalcommits.org/ko/v1.0.0/) 표준을 따릅니다:

- ☑️ `<타입>: <설명>` 기본 형식 준수 (Jira 이슈 번호 접두어 추가)
- ☑️ `feat`, `fix` 필수 타입 사용
- ☑️ 선택적 본문/꼬리말
- ☑️ `BREAKING CHANGE` 꼬리말 지원
- ☑️ `!` 표기로 Breaking Changes 표시 가능

---

## 변경 이력

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용                           |
|------|------------|-----|-----------------------------------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성                             |
| v0.2 | 2025.10.07 | 왕택준 | 상세 커밋 형식 간소화, Conventional Commits 표준 명시 |
