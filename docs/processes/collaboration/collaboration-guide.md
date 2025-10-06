# 협업 도구 워크플로우 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.09.30

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 팀원**: 협업 도구의 역할과 사용 시점을 이해하고 올바른 도구를 선택해야 하는 모든 팀원
* **신규 합류자**: 팀의 협업 구조를 빠르게 파악하고 각 도구의 목적을 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 협업 도구의 역할과 전환 기준을 정의합니다.
Discord는 실시간 소통, Discussions는 논의 기록, Wiki는 참조 문서, Docs Repo는 공식 문서로 역할이 구분됩니다.
정보는 Discord → Discussions → Wiki/Docs Repo 순서로 흐르며, 각 단계마다 명확한 전환 기준이 있습니다.
5분 룰: Discord에서 5분 내 답변 불가능하면 Discussions로 이동합니다.
확정 룰: Discussions에서 확정된 내용은 Docs Repo(ADR) 또는 Wiki로 승격합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [도구별 역할 요약](#도구별-역할-요약)
3. [정보 흐름의 원칙](#정보-흐름의-원칙)
4. [도구 간 전환 기준](#도구-간-전환-기준)
5. [문서 작성 위치 결정](#문서-작성-위치-결정)
6. [전체 워크플로우](#전체-워크플로우)
7. [상황별 도구 선택 가이드](#상황별-도구-선택-가이드)
8. [빠른 참조](#빠른-참조)
9. [관련 문서](#관련-문서)

---

## 문서 개요 (Overview)

본 문서는 팀 내 협업 도구의 역할과 사용 시점을 명확히 하기 위해 작성되었습니다.

프로젝트에서 여러 협업 도구를 사용하면 "이 내용을 어디에 작성해야 하나?"라는 질문이 반복됩니다. 잘못된 도구 선택은 정보 분산과 중복 작업을 초래합니다.

본 문서는 Discord, Discussions, Wiki, Docs Repo의 역할과 전환 기준을 정의하여, 팀원 누구나 올바른 도구를 선택할 수 있도록 합니다. 각 도구의 세부 사용법은 별도 가이드를 참조하세요.

---

## 도구별 역할 요약

| 도구              | 역할     | 핵심 특징        | 사용 예시                   |
|-----------------|--------|--------------|-------------------------|
| **Discord**     | 실시간 소통 | 즉시성, 일시성     | 긴급 이슈, 간단한 질문, 음성 회의    |
| **Discussions** | 논의 기록  | 과정 보존, 검색 가능 | 기술 선택 논의, 트러블슈팅 공유      |
| **Wiki**        | 참조 문서  | 최신성, 빠른 수정   | API 문서, 개발 환경 세팅, 컨벤션   |
| **Docs Repo**   | 공식 문서  | 버전 관리, 확정성   | 요구사항 명세서, ERD, ADR, 회의록 |
| **Jira**        | 작업 관리  | 추적성, 상태 관리   | Task 생성/할당, 진행 상황, 스프린트 |

---

## 정보 흐름의 원칙

### 기본 흐름

```
Discord (제안/질문)
    ↓
Discussions (논의/기록)
    ↓
    ├─→ Wiki (개발 참조)
    └─→ Docs Repo (공식 문서)
```

### 흐름 설명

1. **Discord**: 아이디어 제안, 간단한 질문
2. **Discussions**: 깊은 논의, 의견 수렴 (2-3일)
3. **Wiki**: 자주 참조하는 개발 문서
4. **Docs Repo**: 확정된 공식 문서

### 역방향 참조

```
개발자가 Wiki 참조
    ↓
Wiki에 없는 내용 발견
    ↓
Discussions에서 배경 확인
    ↓
Docs Repo에서 공식 결정 확인
```

---

## 도구 간 전환 기준

### Discord → Discussions

**전환 기준: 5분 룰**

Discord에서 5분 내 답변 불가능하면 Discussions로 이동합니다.

**이동 조건:**

- 기술적 논의가 필요한 경우
- 여러 옵션을 비교해야 하는 경우
- 의사결정 과정을 기록해야 하는 경우
- 팀 전체의 의견이 필요한 경우

**예시:**

- Discord: "Redis랑 Memcached 중 뭐가 나아?"
- 5분 내 답변 불가 → Discussions: "[BE][Architecture] 캐싱 전략: Redis vs Memcached"

### Discussions → Docs Repo

**전환 기준: 확정 룰**

Discussions에서 팀 합의로 확정된 내용은 Docs Repo로 승격합니다.

**이동 대상:**

- 기술 의사결정 → ADR 문서
- 회의 내용 → 회의록
- 설계 결정 → 설계 문서
- 정책/규칙 → 가이드 문서

**예시:**

- Discussions: "JWT vs Session 논의 (3일간)"
- 팀 합의 완료 → Docs Repo: `decisions/001-jwt-authentication.md` (ADR)

### Discussions → Wiki

**전환 기준: 반복 참조 룰**

개발 중 자주 참조하는 내용은 Wiki로 이동합니다.

**이동 대상:**

- 트러블슈팅 해결법
- 개발 가이드
- 자주 묻는 질문 (FAQ)
- 환경 설정 방법

**예시:**

- Discussions: "CORS 에러 해결 과정"
- 해결 완료 → Wiki: `Troubleshooting-CORS` 페이지 생성

### Wiki ↔ Docs Repo 관계

**Wiki → Docs Repo (프로젝트 종료 시)**

프로젝트 종료 시 Wiki 내용을 Docs Repo로 아카이브합니다.

**이유:**

- Wiki는 저장소 삭제 시 사라짐
- 포트폴리오 및 인수인계용 보관 필요

**Docs Repo → Wiki (개발 시작 시)**

공식 문서의 참조 버전을 Wiki에 작성합니다.

**예시:**

- Docs Repo: 최종 ERD (확정본, 변경 없음)
- Wiki: 현재 DB 스키마 (개발 중 변경 반영)

---

## 문서 작성 위치 결정

### 결정 플로우차트

```
"이 내용을 어디에 작성해야 하나?"
    ↓
1. 실시간 공유가 필요한가?
   YES → Discord
   NO → 다음 단계
    ↓
2. 논의 과정을 기록해야 하나?
   YES → Discussions
   NO → 다음 단계
    ↓
3. 확정된 공식 문서인가?
   YES → Docs Repo
   NO → 다음 단계
    ↓
4. 개발 중 자주 참조하나?
   YES → Wiki
   NO → Docs Repo (보관용)
```

### 도구별 적합 콘텐츠

#### Discord에 적합한 내용

- 긴급 알림 (서버 다운, 배포 실패)
- 간단한 질문 (5분 내 답변 가능)
- 작업 공유 (오늘 할 일, 어제 한 일)
- PR 리뷰 요청
- 음성 회의 참여 요청

#### Discussions에 적합한 내용

- 기술 선택 논의 (JWT vs Session)
- 아키텍처 설계 논의
- 트러블슈팅 과정 공유
- 팀 운영 개선 제안
- 스프린트 회고

#### Wiki에 적합한 내용

- API 엔드포인트 목록
- 환경 변수 설정 방법
- 로컬 실행 가이드
- 코딩 컨벤션
- 트러블슈팅 FAQ
- 현재 DB 스키마 (개발 중)

#### Docs Repo에 적합한 내용

- 요구사항 명세서
- 최종 ERD (확정본)
- 시스템 아키텍처
- ADR (기술 의사결정 기록)
- 회의록
- API 설계 문서 (초기 버전)

---

## 전체 워크플로우

### 시나리오 1: 기술 의사결정

```
1. Discord (#개발-질문)
   개발자: "인증 방식 어떻게 할까요? JWT? Session?"
   ↓
2. Discord (5분 내 답변 불가)
   → Discussions로 이동 결정
   ↓
3. Discussions (BE Repo - Architecture)
   제목: [BE][Architecture] 인증 방식 선택 — JWT vs Session
   - 3일간 논의
   - 옵션 비교 (장단점)
   - 팀원 의견 수렴
   ↓
4. Docs Repo (decisions/)
   파일: 001-jwt-authentication.md
   - ADR 작성
   - 최종 결정 사항 기록
   ↓
5. Jira
   Task 생성: TRAIN-45 "JWT 인증 구현"
   ↓
6. 개발 진행
   브랜치: feature/TRAIN-45
   커밋: "TRAIN-45 feat: JWT 미들웨어 추가"
   ↓
7. Wiki (BE Repo)
   페이지: API-Auth
   - JWT 사용법
   - 토큰 갱신 방법
   - 에러 처리
```

### 시나리오 2: 긴급 버그 발생

```
1. Discord (#긴급-이슈)
   @everyone "프로덕션 DB 연결 실패!"
   ↓
2. Discord (실시간 해결)
   - 즉시 대응
   - 원인 파악
   - 임시 조치
   ↓
3. Discussions (BE Repo - Troubleshooting)
   제목: [BE][Troubleshooting] 프로덕션 DB 연결 실패 해결 과정
   - 증상
   - 원인 분석
   - 해결 방법
   - 재발 방지책
   ↓
4. Wiki (BE Repo)
   페이지: Troubleshooting-DB
   - 자주 발생하는 DB 에러
   - 해결 방법 (명령어 포함)
   ↓
5. Docs Repo (meeting-notes/)
   회의록에 Post-Mortem 기록
```

### 시나리오 3: 새 API 개발

```
1. Jira
   Task: TRAIN-67 "상품 목록 API 개발"
   ↓
2. Discussions (BE Repo - Architecture) [선택사항]
   복잡한 설계라면 논의
   ↓
3. 개발 진행
   브랜치: feature/TRAIN-67
   ↓
4. Wiki (BE Repo - API 문서)
   실시간 업데이트:
   - GET /api/products
   - 요청/응답 예시
   - 에러 코드
   ↓
5. PR 생성 → 리뷰 → 머지
   ↓
6. Docs Repo (설계 문서) [선택사항]
   중요한 API라면 공식 문서에 기록
```

---

## 상황별 도구 선택 가이드

### 질문이 생겼을 때

| 질문 유형                   | 도구          | 이유              |
|-------------------------|-------------|-----------------|
| "이 에러 본 사람?"            | Discord     | 즉시 답변 가능        |
| "Redis 설정 어떻게 해?"       | Wiki 먼저 확인  | 이미 문서화되어 있을 가능성 |
| "JWT vs Session 뭐가 나아?" | Discussions | 논의 필요           |
| "최종 ERD 어디 있어?"         | Docs Repo   | 공식 문서           |

### 정보를 공유할 때

| 공유 내용               | 도구          | 이유         |
|---------------------|-------------|------------|
| "방금 배포했어요"          | Discord     | 실시간 알림     |
| "CORS 에러 이렇게 해결했어요" | Discussions | 과정 공유      |
| "새 API 추가했어요"       | Wiki        | 참조 문서 업데이트 |
| "회의 결과입니다"          | Docs Repo   | 공식 기록      |

### 문서를 찾을 때

```
1. README 확인 (5분 내 로컬 실행)
   ↓
2. Wiki 확인 (개발 가이드)
   ↓
3. Docs Repo 확인 (공식 문서)
   ↓
4. Discussions 검색 (논의 과정)
   ↓
5. Discord에서 질문
```

---

## 빠른 참조

### 도구 선택 체크리스트

**Discord를 사용해야 할 때:**

- [ ] 5분 내 답변이 필요한가?
- [ ] 실시간 소통이 필요한가?
- [ ] 긴급한 알림인가?

**Discussions를 사용해야 할 때:**

- [ ] 여러 옵션을 비교해야 하는가?
- [ ] 팀 전체의 의견이 필요한가?
- [ ] 논의 과정을 기록해야 하는가?

**Wiki를 사용해야 할 때:**

- [ ] 개발 중 자주 참조하는가?
- [ ] 자주 변경되는 내용인가?
- [ ] 신규 팀원이 참조해야 하는가?

**Docs Repo를 사용해야 할 때:**

- [ ] 확정된 공식 문서인가?
- [ ] 버전 관리가 필요한가?
- [ ] 외부 제출용 문서인가?

### 헷갈리는 사례

| 내용             | 올바른 위치          | 이유         |
|----------------|-----------------|------------|
| API 엔드포인트 목록   | Wiki            | 개발 중 계속 변경 |
| "왜 JWT를 선택했나?" | Docs Repo (ADR) | 의사결정 기록    |
| JWT 구현 논의 과정   | Discussions     | 논의 과정 보존   |
| JWT 사용법        | Wiki            | 개발자 참조 문서  |
| 최종 ERD         | Docs Repo       | 확정된 설계     |
| 현재 DB 스키마      | Wiki            | 개발 중 변경 사항 |
| CORS 에러 해결 과정  | Discussions     | 트러블슈팅 기록   |
| CORS 에러 해결법    | Wiki            | FAQ        |

---

## 관련 문서

* [Discord 가이드](./discord-guide.md) - 채널 구조 및 사용 규칙
* [Discussions 가이드](./discussions-guide.md) - 카테고리 및 작성 규칙
* [Wiki 가이드](./wiki-guide.md) - Repository별 구조 및 네이밍 규칙
* [Jira 가이드](./jira-guide.md) - 워크플로우 및 이슈 타입

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.09.30 | 왕택준 | 최초 작성    |
