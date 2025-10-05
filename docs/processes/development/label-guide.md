# 라벨 사용 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드/프론트엔드 개발자**: 이슈/PR 생성 및 관리 시 올바른 라벨을 선택해야 하는 담당자
* **QA/테스터**: 버그 리포트, 테스트 케이스, 품질 관련 이슈를 라벨링하는 담당자
* **운영자/PM**: 프로젝트 진행 상황을 라벨 기반으로 파악하고 관리하는 책임자
* **외부 기여자**: 프로젝트에 참여할 때 라벨 규칙을 준수해야 하는 기여자

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트에서 사용하는 GitHub 라벨의 정의, 적용 규칙, 활용 예시를 정리합니다.
라벨은 Area(영역), Type(유형), Priority(우선순위), Status(상태), Meta(보조) 5개 그룹으로 구성됩니다.
모든 이슈/PR은 Type 1개, Priority 1개, Status 1개를 필수로 포함하며, Area는 권장사항입니다.
feature는 새 기능, enhancement는 기존 개선, refactor는 구조 개선, bug는 오작동 수정으로 명확히 구분합니다.
상태는 todo → in progress → done 순으로 흐르며, 차단 시 blocked 상태를 사용합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [공통 규칙](#공통-규칙)
3. [Area (영역)](#area-영역)
4. [Type (유형)](#type-유형)
5. [Priority (우선순위)](#priority-우선순위)
6. [Status (상태)](#status-상태)
7. [Meta (보조)](#meta-보조)
8. [라벨 적용 예시](#라벨-적용-예시)

---

## 문서 개요 (Overview)

본 문서는 GitHub 라벨 사용 규칙을 명확히 하기 위해 작성되었습니다.

라벨은 이슈와 PR을 분류하고 검색하는 핵심 도구입니다. 일관된 규칙 없이 사용하면 분류가 모호해지고, 프로젝트 상태 파악이 어려워집니다.

본 문서는 5개 라벨 그룹의 정의, 사용 예시, 구분 기준을 포함하여 체계적인 이슈/PR 관리를 지원합니다.

---

## 공통 규칙

다음 규칙을 준수합니다.

- **필수**: Type 1개, Priority 1개, Status 1개
- **권장**: Area 1개(최대 2개), Meta 필요 시 추가
- **상태 흐름**: `status: todo → in progress → done` (차단 시 `blocked`)
- **배포**: 배포 관련 태스크는 `release`(Meta)로 별도 관리

### 구분 기준

다음 기준으로 라벨을 구분합니다.

- **feature vs enhancement**: 새로 생기는가(기능/화면/플로우)면 feature, 기존의 개선·확장이면 enhancement
- **bug vs refactor vs performance**: 잘못 동작을 고치면 bug, 동작 동일하게 구조만 고치면 refactor, 성능 수치를 개선하면 performance
- **build vs ci-cd**: 로컬/공통 빌드·번들 설정은 build, 파이프라인/배포 자동화는 ci-cd
- **test: unit vs test: e2e**: 모듈/함수 단위면 unit, 사용자 시나리오/엔드투엔드면 e2e

---

## Area (영역)

### area: frontend

**의도**: 클라이언트/UI 레이어에 해당하는 작업

**포함**: React 컴포넌트, 라우팅/상태 관리, 스타일링, 접근성

**제외**: 서버·DB·배포 관련 이슈(→ backend/devops/database)

**권장 조합**: `feature | bug | enhancement | design` + `priority:*` + `status:*`

**예시**:

- 검색 결과 페이지 무한스크롤 추가
- 모바일 뷰 헤더 깨짐 수정
- 다크모드 토글 접근성 개선

### area: backend

**의도**: 서버/도메인/비즈니스 로직에 해당하는 작업

**포함**: API, 서비스/리포지토리, 인증/인가, 스케줄러

**제외**: 브라우저 UI(→ frontend)

**권장 조합**: `feature | bug | enhancement | refactor | security` + `priority:*` + `status:*`

**예시**:

- 회원가입 API 추가
- JWT 리프레시 토큰 재발급 로직 수정
- 주문 집계 배치 스케줄 개선

### area: database

**의도**: 데이터 계층 작업

**포함**: 스키마 변경, 인덱스, SQL, 마이그레이션, 쿼리 튜닝

**제외**: 애플리케이션 로직 변경(→ backend)

**권장 조합**: `performance | enhancement | bug` + `priority:*` + `status:*`

**예시**:

- orders 테이블 인덱스 추가
- N+1 쿼리 발생 구간 튜닝
- DDL 마이그레이션 스크립트 작성

### area: devops

**의도**: 인프라/배포/운영 작업

**포함**: Docker/K8s, 모니터링, 로깅, CI/CD 러너 설정

**제외**: 앱 기능 구현(→ backend/frontend)

**권장 조합**: `ci-cd | build | performance | security | release` + `priority:*` + `status:*`

**예시**:

- Nginx gzip/브로틀리 압축 설정
- 프로덕션 로그 수집 파이프라인 구성
- 배포 실패 알림 슬랙 연동

### area: ai

**의도**: AI/LLM 관련 작업

**포함**: 프롬프트 설계, 모델/파라미터, 벡터DB/검색 품질, 안전장치

**제외**: 일반 CRUD/뷰 로직(→ backend/frontend)

**권장 조합**: `feature | enhancement | performance` + `priority:*` + `status:*`

**예시**:

- 릴레이 소설 요약 프롬프트 개선
- 임베딩 코사인 유사도 임계값 조정
- 컨텍스트 윈도우 초과 대비 요약 파이프라인 추가

---

## Type (유형)

### feature

**의도**: 새로운 기능/화면/플로우를 추가하는 작업

**포함**: 신규 API, 신규 페이지, 신규 도메인 규칙

**제외**: 기존 기능의 소폭 개선(→ enhancement)

**권장 조합**: `area:*` + `priority:*` + `status:*`

**예시**: 비밀번호 찾기 기능 추가, 작품 신고 플로우 도입

### bug

**의도**: 잘못 동작을 수정하는 작업

**포함**: 예외/오류, UI 오작동, 데이터 불일치

**제외**: 구조만 고치는 변경(→ refactor), 성능 개선(→ performance)

**권장 조합**: `area:*` + `priority:P0|P1` + `status:*`

**예시**: 로그인 실패 시 500 에러 수정, 무한스크롤 중복 호출 수정

### enhancement

**의도**: 기존 기능의 사용성·옵션을 개선/확장하는 작업

**포함**: 필터/정렬 추가, UX 마이크로 인터랙션, API 옵션 확장

**제외**: 완전 신규 기능(→ feature)

**권장 조합**: `area:*` + `priority:P1|P2` + `status:*`

**예시**: 검색 결과 정렬 옵션(최신/인기) 추가, 댓글 작성 UX 개선

### refactor

**의도**: 동작은 유지하고 구조·가독성·모듈화를 개선하는 작업

**포함**: 레이어 분리, 네이밍/폴더링 정리, 중복 제거

**제외**: 사용성 변화, 성능 개선 자체 목표(→ enhancement/performance)

**권장 조합**: `area:*` + `priority:P2` + `status:*`

**예시**: 서비스/리포지토리 분리, 컨트롤러 응답 DTO 정리

### docs

**의도**: 문서를 작성/보완하는 작업

**포함**: README, API 스펙, 아키텍처 다이어그램, 운영 가이드

**제외**: 디자인 산출물(UI 시안)(→ design)

**권장 조합**: `priority:P2` + `status:*` (+ 필요한 `area:*`)

**예시**: 빠른 시작 가이드 추가, DB ERD 문서 업데이트

### design

**의도**: UI/UX 설계·레이아웃·시안 작업

**포함**: 와이어프레임, 컴포넌트 가이드, 디자인 토큰

**제외**: 구현된 UI의 버그 수정(→ bug + area: frontend)

**권장 조합**: `area: frontend` + `priority:*` + `status:*`

**예시**: 작품 상세 페이지 레이아웃 리뉴얼, 버튼 컴포넌트 가이드 작성

### test: unit

**의도**: 모듈/함수 단위 자동 테스트 작업

**포함**: JUnit/Mockito, 리포지토리/서비스 단위 테스트

**제외**: 사용자 플로우 테스트(→ test: e2e)

**권장 조합**: `area:*` + `priority:P2|P1` + `status:*`

**예시**: UserService 단위 테스트 보강, 리포지토리 경계 테스트 추가

### test: e2e

**의도**: 엔드투엔드/통합 시나리오 테스트 작업

**포함**: Playwright/Cypress, API+UI 플로우 검증

**제외**: 모듈 단위 테스트(→ test: unit)

**권장 조합**: `area: frontend|backend` + `priority:P1` + `status:*`

**예시**: 회원가입→로그인→글쓰기 E2E 테스트 추가

### security

**의도**: 인증·인가·취약점 대응 등 보안 강화를 위한 작업

**포함**: XSS/CSRF/CSP, 토큰/세션, 의심 트래픽 방어

**제외**: 단순 버그/성능 이슈

**권장 조합**: `area: backend|devops` + `priority:P0|P1` + `status:*`

**예시**: JWT 재발급 보안 강화, CSP 헤더 정책 적용

### performance

**의도**: 성능 지표를 개선하는 작업

**포함**: 응답시간, 메모리, 쿼리/인덱스, 캐싱, 번들 최적화

**제외**: 구조 개선 자체가 목표(→ refactor)

**권장 조합**: `area: database|frontend|backend` + `priority:P1` + `status:*`

**예시**: 작품 목록 API 800ms→200ms 최적화, 이미지 lazy-loading 적용

### build

**의도**: 빌드/패키징/툴체인 설정 작업

**포함**: Gradle/NPM 설정, 번들러 설정, 코드 규칙 툴

**제외**: 파이프라인·배포 자동화(→ ci-cd)

**권장 조합**: `priority:P2|P1` + `status:*`

**예시**: Gradle 버전 업데이트, ESLint/Prettier 설정 통일

### chore

**의도**: 코드 기능 추가·수정이 아닌 프로젝트 관리성 작업

**포함**: .github 디렉토리 수정, 워크플로 업데이트, 린트/포맷팅 설정, CI 환경 변수 관리

**제외**: 기능 구현(→ feature/enhancement), 버그 수정(→ bug)

**권장 조합**: `priority:P2` + `status:*` (+ 필요한 `area:*`)

**예시**: GitHub Actions 워크플로 수정, Prettier 설정 업데이트

### ci-cd

**의도**: 빌드/테스트/배포 파이프라인 자동화 작업

**포함**: GitHub Actions, 환경/비밀 관리, 배포 전략

**제외**: 로컬 빌드 설정 변경(→ build)

**권장 조합**: `area: devops` + `priority:P1` + `status:*`

**예시**: PR 빌드/테스트 워크플로우 추가, CD 롤백 전략 구성

### translation

**의도**: 다국어/번역 지원 작업

**포함**: i18n 리소스 추가/수정, 언어 토글, 카탈로그 정리

**제외**: 일반 카피 문구 변경(→ enhancement/docs)

**권장 조합**: `area: frontend` + `priority:P2` + `status:*`

**예시**: ko→en 번역 리소스 추가, 날짜/통화 로케일 처리

---

## Priority (우선순위)

### priority: P0

**의도**: 즉시 대응이 필요한 긴급 작업

**포함**: 프로덕션 장애, 보안 취약점, 데이터 손실 위험

**제외**: 편의/개선성 작업

**권장 조합**: `bug | security` + `status:*`

**예시**: 서비스 500 오류 다발, 민감정보 노출 취약점 패치

### priority: P1

**의도**: 스프린트 내 처리할 일반 중요도 작업

**포함**: 핵심 기능 개발, 유의미한 개선/성능 작업

**제외**: 즉시성 없음(→ P2), 긴급(→ P0)

**예시**: 검색 필터 확장, E2E 회귀 테스트 추가

### priority: P2

**의도**: 여유 시 처리할 낮은 우선순위 작업

**포함**: 리팩터링, 문서/청소 작업

**제외**: 제품 목표 일정에 영향 주는 항목

**예시**: 패키지 구조 정리, 설치 가이드 보강

---

## Status (상태)

### status: todo

**의도**: 아이템이 정의되었으나 착수 전인 작업

**전환**: 담당자 배정 및 작업 시작 시 `in progress`

**예시**: 신규 API 설계 초안

### status: in progress

**의도**: 담당자가 구현/수정을 진행 중인 작업

**전환**: 리뷰/머지 완료 시 `done`, 차단 시 `blocked`

**예시**: 프론트 검색 UX 개선 작업진행

### status: blocked

**의도**: 의존/승인/리소스 이슈로 일시 중단된 작업

**전환**: 원인 해소 후 `in progress` 복귀

**예시**: API 스펙 확정 대기

### status: done

**의도**: 개발·리뷰·머지까지 완료된 작업(배포 여부 무관)

**주의**: 배포 태스크는 `release` 라벨로 별도 관리

**예시**: PR #123 머지 완료

---

## Meta (보조)

### discussion

**의도**: 구현 착수 전 정책/방향을 논의하는 작업

**포함**: 스펙/정책/이름짓기/데이터 모델 결정

**예시**: 투표 동률 처리 정책 확정

### question

**의도**: 확인/답변이 필요한 질의 작업

**포함**: API 파라미터 의미, 운영 절차 문의, 의존성 해석

**예시**: 정렬 기본값은 최신/인기 중 무엇인가요?

### help wanted

**의도**: 담당자 모집/외부 기여가 필요한 작업

**포함**: 문서 보강, 번역, UI 마크업, 테스트 작성

**예시**: README 영문화 도움 요청

### release

**의도**: 버전 태깅/체인지로그/배포 체크 등 릴리즈 작업

**포함**: 릴리즈 브랜치 관리, 배포 체크리스트, 롤백/핫픽스

**예시**: v1.0.0 릴리즈 준비 및 배포 점검

---

## 라벨 적용 예시

다음은 시나리오별 라벨 적용 예시입니다.

1. **회원가입 API 신규 개발**: `feature`, `area: backend`, `priority: P1`, `status: in progress`
2. **모바일 헤더 깨짐 수정**: `bug`, `area: frontend`, `priority: P1`, `status: todo`
3. **검색 결과 정렬 옵션 추가**: `enhancement`, `area: frontend`, `priority: P1`, `status: in progress`
4. **쿼리 튜닝으로 응답 800ms→200ms**: `performance`, `area: database`, `priority: P1`, `status: in progress`
5. **PR 빌드 자동화 파이프라인 도입**: `ci-cd`, `area: devops`, `priority: P1`, `status: in progress`
6. **JWT 재발급 보안 강화**: `security`, `area: backend`, `priority: P0`, `status: in progress`
7. **설치 가이드 업데이트**: `docs`, `priority: P2`, `status: done`
8. **CI 워크플로 수정 및 코드 포맷터 설정 변경**: `chore`, `priority: P2`, `status: todo`
9. **v1.0.0 릴리즈**: `release`, `area: devops`, `priority: P1`, `status: in progress`

---

## 관련 문서

* [Jira 가이드](../../../../../../문서/jira-guide.md)
* [Git 워크플로우](../development/git-workflow.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
