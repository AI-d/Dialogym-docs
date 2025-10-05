# Wiki 운영 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.02

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: API 문서, DB 스키마, 환경 설정을 Wiki에서 참조하고 업데이트하는 담당자
* **프론트엔드 개발자**: 컴포넌트 가이드, 상태관리, 스타일 규칙을 Wiki에서 참조하는 담당자
* **DevOps / 인프라 엔지니어**: 배포 스크립트, 환경 변수, 인프라 설정을 Wiki에 문서화하는 담당자
* **신규 합류자**: Wiki를 통해 빠르게 개발 환경을 세팅하고 프로젝트 구조를 파악해야 하는 팀 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 GitHub Wiki 운영 방식을 정의합니다.
Wiki는 개발자가 개발 중 즉시 참조하는 살아있는 레퍼런스로, PR 없이 직접 편집 가능하며 항상 최신 상태를 유지합니다.
Discussions는 논의 과정 기록, Wiki는 개발 참조 문서, Docs Repo는 공식 문서화로 역할을 구분합니다.
Repository별로 Wiki 구조를 정의하며, 네이밍은 영문 kebab-case를 사용하고 약어는 대문자를 유지합니다.
프로젝트 종료 시 Wiki 내용을 Docs Repo로 아카이브하여 포트폴리오용으로 보관합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Wiki의 역할](#wiki의-역할)
3. [Wiki, Docs Repository, Discussions와의 관계](#wiki-docs-repository-discussions와의-관계)
4. [Wiki 사용 원칙](#wiki-사용-원칙)
5. [Wiki에 적합한 콘텐츠](#wiki에-적합한-콘텐츠)
6. [실제 워크플로우 예시](#실제-워크플로우-예시)
7. [Repository별 Wiki 구조](#repository별-wiki-구조)
8. [Wiki 네이밍 규칙](#wiki-네이밍-규칙)
9. [Wiki 작성 규칙](#wiki-작성-규칙)
10. [Wiki 업데이트 원칙](#wiki-업데이트-원칙)
11. [Wiki 유지보수](#wiki-유지보수)
12. [프로젝트 종료 시 아카이브](#프로젝트-종료-시-아카이브)
13. [빠른 참조](#빠른-참조)

---

## 문서 개요 (Overview)

본 문서는 프로젝트 팀에서 사용하는 GitHub Wiki 운영 방식을 정의하기 위해 작성되었습니다.

개발 프로젝트에서는 API 문서, 환경 설정, 컴포넌트 가이드 등 자주 변경되는 참조 문서가 필요합니다.
이러한 문서들은 공식 문서로 관리하기에는 변경이 너무 잦고, Discussions로 관리하기에는 구조화가 부족합니다.

Wiki는 이러한 살아있는 참조 문서를 관리하기 위한 도구로, 개발자가 즉시 참조하고 수정할 수 있는 특징을 가집니다.
본 문서는 Wiki의 역할, 다른 도구와의 구분, Repository별 구조, 작성 규칙을 정의하여
팀 전체가 효과적으로 Wiki를 활용할 수 있도록 합니다.

---

## Wiki의 역할

Wiki는 개발자가 개발 중 즉시 참조하는 살아있는 레퍼런스입니다.

---

## Wiki, Docs Repository, Discussions와의 관계

### 핵심 차이점

| 구분 | Discussions | Wiki | Docs Repo |
|------|-------------|------|-----------|
| 주요 목적 | 논의 과정 기록 | 개발 참조 문서 | 공식 문서화 |
| 위치 | GitHub Discussions 탭 | GitHub Repo Wiki 탭 | 별도 docs 저장소 |
| 문서 성격 | 대화 중심, 과정 기록 | 살아있는 문서, 현재 상태 | 확정된 문서, 특정 시점 |
| 작성 방식 | 토론, Q&A, 투표 | 브라우저에서 즉시 수정 | PR 기반, 코드 리뷰 거침 |
| 변경 빈도 | 3일간 논의 후 종료 | 매주 (개발 중 계속) | 분기별 (확정 후 고정) |
| 버전 관리 | 불필요 (타임라인만) | 불필요 (최신만 유지) | 필수 (Git 히스토리) |

---

### 적합 사례

#### Discussions

JWT vs Session 논의, 트러블슈팅 과정, 스프린트 회고

#### Wiki

API 엔드포인트 목록, 환경 변수 설정, 컴포넌트 사용법

#### Docs Repo

최종 ERD, ADR, 요구사항 명세서

---

### 장단점

#### Discussions

**장점**: 의사결정 과정 보존, 다양한 의견 수렴

**단점**: 최종 문서화 부적합

#### Wiki

**장점**: 빠른 수정, 높은 접근성, 검색 용이

**단점**: 구조 관리 취약, 공식성 부족

#### Docs Repo

**장점**: 체계적 관리, 버전 추적, 공식 문서

**단점**: 수정이 번거로움, PR 필요

---

### 사용 구분 기준

```
"이 내용을 어디에 작성해야 하나?"
        ↓
    논의 중인가?  →  YES  →  Discussions
        ↓
       NO
        ↓
    확정되었나?
        ↓
   자주 바뀌나?
        ↓
   YES → Wiki
   NO → Docs Repo
```

---

### 실제 워크플로우 예시

시나리오: Redis 캐싱 도입

1. Discussions: "캐싱 전략: Redis vs Memcached" (3일간 논의)
2. Docs Repo: ADR 작성 (docs/decisions/001-redis-caching.md)
3. Wiki 업데이트: Setup-Redis 페이지 생성, API-Caching 페이지 업데이트

---

### 헷갈리는 사례

| 문서 | 어디에? | 이유 |
|------|---------|------|
| API 엔드포인트 목록 | Wiki | 개발 중 계속 변경, 자주 참조 |
| "왜 JWT를 선택했나?" | Docs Repo (ADR) | 의사결정 기록, 한 번 확정 |
| JWT 구현 논의 과정 | Discussions | 논의 과정 보존 |
| JWT 사용법 | Wiki | 개발자 참조 문서 |
| 최종 시스템 아키텍처 | Docs Repo | 버전 관리 필요, 공식 문서 |
| 현재 DB 스키마 | Wiki | 개발 중 테이블 추가/변경 |
| 초기 ERD (확정본) | Docs Repo | 특정 시점 설계 문서 |
| CORS 에러 해결 과정 | Discussions | 트러블슈팅 과정 기록 |
| CORS 에러 해결법 | Wiki | 트러블슈팅 FAQ |

---

## Wiki 사용 원칙

### 즉시성 (Immediacy)

PR 없이 직접 편집 가능합니다.
개발 중 발견한 사항을 즉시 반영합니다.

### 접근성 (Accessibility)

신규 팀원이 가장 먼저 참조하는 문서입니다.
5분 내 로컬 환경 실행 가능하도록 작성합니다.

### 최신성 (Currency)

항상 최신 상태를 유지합니다.
오래된 정보는 즉시 삭제 또는 수정합니다.

### 실용성 (Practicality)

이론보다 실무 중심으로 작성합니다.
코드 예시와 명령어 위주로 구성합니다.

---

## Wiki에 적합한 콘텐츠

### Wiki에 작성해야 할 내용

* 자주 바뀌는 참조 문서: API 엔드포인트, 환경 변수, DB 스키마 (개발 중)
* 개발 가이드: 코딩 컨벤션, 폴더 구조, 에러 처리
* 트러블슈팅 FAQ: DB 연결 실패, CORS 에러, 빌드 실패
* 빠른 시작: 5분 내 로컬 실행, 주요 스크립트

---

### Wiki에 작성하면 안 되는 내용

* 논의 과정 → Discussions ("왜 Redis를 선택했나?")
* 작업 추적 → Jira ("Task 진행 상황")
* 확정된 공식 문서 → Docs Repo ("최종 ERD, ADR")
* 실시간 소통 → Discord ("지금 배포 가능?")

---

## 실제 워크플로우 예시

시나리오: Redis 캐싱 도입

1. Discord: "Redis 도입 어때?"
2. Discussions: "캐싱 전략: Redis vs Memcached" (3일 논의)
3. Docs Repo: ADR 작성 (001-redis-caching-strategy.md)
4. Jira: Task 생성 (TRAIN-45)
5. 개발 진행
6. Wiki 업데이트: 환경 변수, Redis 사용법, 로컬 실행 방법

---

## Repository별 Wiki 구조

### be repo Wiki

```
Home
├── 빠른 시작
├── 개발 환경 세팅
│   ├── 사전 요구사항
│   ├── 설치 방법
│   └── 환경 변수 설정
├── API 문서
│   ├── 인증 API
│   ├── 상품 API
│   ├── 주문 API
│   └── 결제 API
├── 데이터베이스
│   ├── 스키마 구조
│   ├── 마이그레이션 가이드
│   └── 시드 데이터
├── 코딩 컨벤션
│   ├── 네이밍 규칙
│   ├── 폴더 구조
│   └── 에러 처리
└── 트러블슈팅
```

목적: 백엔드 개발자 빠른 참조
업데이트: 개발 중 수시로

---

### fe repo Wiki

```
Home
├── 빠른 시작
├── 개발 환경 세팅
├── 컴포넌트 가이드
├── 상태관리
├── 라우팅
├── 스타일 가이드
└── 트러블슈팅
```

목적: 프론트엔드 개발자 빠른 참조
업데이트: 컴포넌트 추가/변경 시

---

### docs repo Wiki (선택 사항)

```
Home
├── 문서 작성 가이드
├── 마크다운 컨벤션
└── 문서 리뷰 프로세스
```

목적: 문서 작성 규칙 (필요 시에만)
사용 빈도: 낮음

---

## Wiki 네이밍 규칙

### 기본 원칙

영문 사용 (한글 금지)
공백은 하이픈(-) 사용
약어는 대문자 유지: API, DB, URL, JWT (소문자 api, db 금지)

---

### 형식

카테고리-주제 또는 주제

---

### 예시

| 좋은 예 | 나쁜 예 | 이유 |
|---------|---------|------|
| API-Auth | api-auth | 약어는 대문자 |
| Setup-Docker | 01-Setup-Docker | 번호 불필요 |
| DB-Schema | Database-Schema | 약어 사용 |
| Quick-Start | QuickStart | 하이픈 필수 |

---

### 주요 카테고리 접두사

* API-: API 문서
* DB-: 데이터베이스
* Setup-: 환경 설정
* Troubleshooting-: 문제 해결
* Guide-: 가이드 문서

---

## Wiki 작성 규칙

### 페이지 구조

```markdown
# 페이지 제목

## 개요
- 목적과 범위

## 사전 요구사항
- 필요한 도구

## 본문
- 단계별 설명
- 코드 예시

## 참고 링크
```

---

### 코드 블록 작성

좋은 예시:

```bash
# MariaDB 실행
docker run -d --name mariadb -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mariadb:10.11
```

나쁜 예시:

```
Docker를 사용하여 MariaDB를 실행하세요.
```

---

### 환경 변수 문서화

```markdown
| 변수명 | 필수 | 기본값 | 설명 |
|--------|------|--------|------|
| DB_HOST | ✅ | localhost | 데이터베이스 호스트 |
| DB_PORT | ✅ | 3306 | 데이터베이스 포트 |
| REDIS_URL | ❌ | - | Redis 연결 URL |
```

---

### API 문서 작성

```markdown
## POST /api/auth/login

**요청:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**응답:**
```json
{
  "token": "eyJhbGci...",
  "user": { "id": 1, "email": "user@example.com" }
}
```

**에러:**
- 401: 인증 실패
- 500: 서버 에러
```

---

### 트러블슈팅 작성

```markdown
## DB 연결 실패

**증상:**

Error: connect ECONNREFUSED 127.0.0.1:3306


**원인:** MariaDB가 실행되지 않음

**해결:**

docker ps | grep mariadb
docker restart mariadb

```

---

## Wiki 업데이트 원칙

### 업데이트 시점

| 상황 | Wiki 업데이트 내용 |
|------|-------------------|
| 새 API 추가 | API 문서 페이지 추가 |
| 환경 변수 변경 | 개발 환경 세팅 수정 |
| 새 컴포넌트 추가 | 컴포넌트 가이드 추가 |
| 트러블슈팅 해결 | 트러블슈팅 페이지 기록 |

---

### 업데이트 책임자

개발자: 본인 작업 내용은 본인이 업데이트
리뷰어: PR 리뷰 시 Wiki 업데이트 여부 확인
신규 팀원: 불명확한 부분 발견 시 보완

---

### 업데이트 프로세스

1. 개발 완료
2. Wiki 업데이트 필요성 확인
3. Wiki 페이지 편집
4. PR 머지

---

## Wiki 유지보수

### 정기 검토

주기: 스프린트 종료 시 (1주마다)
담당: 순번제

체크리스트:
- 오래된 정보 제거
- 깨진 링크 수정
- 중복 내용 통합

---

### 버전 관리

Wiki는 Git 저장소이므로 변경 이력 추적이 가능합니다.
잘못된 수정 시 히스토리에서 복구할 수 있습니다.

---

## 프로젝트 종료 시 아카이브

### 시점

프로젝트 종료 1-2일 전
최종 배포 직후

---

### 프로세스

#### Wiki 정리

오래된 내용 삭제
최신 상태 확인
임시 메모 제거

---

#### Docs Repo로 이관

```
docs/archive/final-reference/
├── backend/
│   ├── api-docs.md
│   ├── db-schema.md
│   └── troubleshooting.md
└── frontend/
    ├── components.md
    └── state-management.md
```

---

#### README 업데이트

Organization README에 아카이브 링크 추가
포트폴리오용 최종 문서 명시

---

### 목적

Wiki는 저장소 삭제 시 사라집니다.
Docs Repo에 백업 및 포트폴리오용으로 보관합니다.
인수인계 문서로 활용합니다.

---

## 빠른 참조

### 언제 Wiki를 사용하나?

| 질문 | Wiki 사용 여부 |
|------|---------------|
| API 엔드포인트 확인? | ✅ Wiki |
| 로컬 환경 세팅? | ✅ Wiki |
| 왜 이 기술 선택? | ❌ Discussions |
| Task 진행 상황? | ❌ Jira |
| 최종 ERD? | ❌ Docs Repo |
| 급한 질문? | ❌ Discord |

---

### Wiki vs README

| 내용 | 위치 |
|------|------|
| 5분 내 실행 방법 | README.md |
| 상세 환경 설정 | Wiki |
| 기술 스택 목록 | README.md |
| API 전체 문서 | Wiki |
| 프로젝트 개요 | README.md |
| 트러블슈팅 FAQ | Wiki |

원칙: README는 개요, Wiki는 상세

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.02 | 왕택준 | 표준 템플릿 가이드에 맞춰 최초 작성 |
