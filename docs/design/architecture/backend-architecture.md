# Dialogym Backend 아키텍처

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.02

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 시스템 아키텍처를 이해하고 코드를 작성하는 담당자
* **인프라 엔지니어**: 배포 환경을 구성하고 시스템을 운영하는 담당자
* **프론트엔드 개발자**: 백엔드 시스템 구조를 이해하고 API를 통합하는 담당자
* **신규 합류자**: Dialogym Backend 시스템의 전체 구조와 기술 스택을 빠르게 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym Backend 시스템의 전체 아키텍처를 정의합니다.
Spring Boot 3.5.5 기반의 계층형 아키텍처를 채택하였으며, JWT 인증, OpenAI 연동, WebSocket 실시간 통신을 지원합니다.
MariaDB를 데이터베이스로 사용하고, Caffeine 캐시로 성능을 최적화하며, AWS 환경에 Docker 컨테이너로 배포됩니다.
도메인 주도 설계 원칙을 따라 User, Scenario, Session, Feedback 등 5개 주요 도메인으로 구성되며, 각 도메인은 독립적인 계층 구조를 갖습니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [시스템 개요](#시스템-개요)
3. [기술 스택](#기술-스택)
4. [전체 시스템 아키텍처](#전체-시스템-아키텍처)
5. [레이어 아키텍처](#레이어-아키텍처)
6. [도메인 구조](#도메인-구조)
7. [보안 아키텍처](#보안-아키텍처)
8. [데이터베이스 아키텍처](#데이터베이스-아키텍처)
9. [외부 시스템 연동](#외부-시스템-연동)
10. [실시간 통신 아키텍처](#실시간-통신-아키텍처)
11. [배포 아키텍처](#배포-아키텍처)
12. [캐싱 전략](#캐싱-전략)
13. [스케줄러](#스케줄러)
14. [에러 처리 전략](#에러-처리-전략)
15. [성능 최적화](#성능-최적화)
16. [보안 체크리스트](#보안-체크리스트)
17. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 Dialogym Backend 시스템의 전체 아키텍처를 기술적 관점에서 정의하기 위해 작성되었습니다.

소프트웨어 시스템의 아키텍처는 개발, 운영, 확장성의 모든 측면에 영향을 미치는 핵심 설계 결정입니다.
명확한 아키텍처 문서화를 통해 개발자 간 공통된 이해를 확보하고, 시스템 유지보수성과 확장성을 높이며, 신규 합류자의 학습 곡선을 단축합니다.

본 문서는 Dialogym Backend 시스템의 모든 개발, 배포, 운영 활동에 적용되며, 아키텍처 변경 시 반드시 업데이트해야 합니다.

---

## 시스템 개요

### 프로젝트 정보

```
프로젝트명: Dialogym (대화 훈련 AI 플랫폼)
버전: v1.0
설명: AI 기반 대화 훈련 플랫폼 백엔드 시스템
목적: 사용자가 AI와 실시간 음성 대화를 통해 커뮤니케이션 스킬을 향상시킬 수 있는 서비스 제공
```

### 핵심 기능

**사용자 인증**:
로컬 회원가입 및 로그인, 소셜 로그인(Google, Kakao, Naver)을 지원합니다.
JWT 기반 Stateless 인증으로 확장성을 확보하고, Refresh Token Rotation으로 보안을 강화합니다.

**시나리오 관리**:
기본 시나리오를 제공하고, 사용자가 커스텀 시나리오를 생성할 수 있습니다.
난이도와 카테고리별로 분류하여 다양한 학습 상황을 지원합니다.

**실시간 대화**:
OpenAI Realtime API를 통해 음성 기반 AI 대화를 제공합니다.
WebRTC P2P 연결로 낮은 지연시간을 보장하고, Whisper STT로 정확한 음성 인식을 구현합니다.

**AI 피드백**:
ChatGPT 4.0이 대화를 분석하여 발화속도, 추임새, 공손도, 명료성 4가지 항목을 평가합니다.
3가지 스타일의 개선안을 제시하고, 사용자는 선택하거나 직접 수정할 수 있습니다.

**학습 이력 관리**:
사용자별 대화 세션과 피드백 히스토리를 추적하고, 통계 분석을 제공하여 학습 성과를 시각화합니다.

---

## 기술 스택

### Core Framework

```
Java: 17 (LTS)
Spring Boot: 3.5.5
Build Tool: Gradle 8.x
```

### Spring Ecosystem

| 기술 | 버전 | 용도 |
|------|------|------|
| Spring Web | 3.5.5 | RESTful API 구현 |
| Spring Data JPA | 3.5.5 | ORM 및 데이터 접근 계층 |
| Spring Security | 3.5.5 | 인증 및 인가 처리 |
| Spring OAuth2 Client | 3.5.5 | 소셜 로그인 연동 |
| Spring WebSocket | 3.5.5 | 실시간 양방향 통신 |
| Spring Mail | 3.5.5 | 이메일 발송 |
| Spring Cache | 3.5.5 | 캐싱 처리 |
| Spring Actuator | 3.5.5 | 모니터링 및 헬스체크 |
| Spring Validation | 3.5.5 | 입력값 검증 |
| Spring AOP | 3.5.5 | 횡단 관심사 처리 |

### Database & Persistence

```
RDBMS: MariaDB 10.x
ORM: Hibernate (JPA 구현체)
Connection Pool: HikariCP
Query DSL: QueryDSL 5.0.0
Query Logging: P6Spy 1.9.1
```

### Security & Authentication

```
JWT: JJWT 0.12.3
Password Encoding: BCrypt
Rate Limiting: Bucket4j 8.10.1
OAuth2: Spring Security OAuth2 Client
```

### AI & External APIs

```
Spring AI: 1.0.0-M4
OpenAI Integration:
  - ChatGPT 4.0 (피드백 생성)
  - Realtime API (음성 대화)
  - Whisper (STT)
```

### Caching & Performance

```
Cache Provider: Caffeine 3.1.8
Cache Strategy: In-Memory Caching
```

### Documentation & Monitoring

```
API Documentation: SpringDoc OpenAPI 2.8.13 (Swagger UI)
Logging: SLF4J + Logback
Monitoring: Spring Actuator
```

### Development Tools

```
Lombok: 코드 간소화
Dotenv: 환경 변수 관리
DevTools: 개발 생산성 향상
```

---

## 전체 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Web App    │  │  Mobile App  │  │  Admin Panel │          │
│  │  (React/Vue) │  │ (iOS/Android)│  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS / WebSocket
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway / Load Balancer                 │
│                         (Nginx / AWS ALB)                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Dialogym Backend Application                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Spring Boot Application (Port 9090)          │  │
│  │                                                            │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │
│  │  │ REST API     │  │  WebSocket   │  │   Scheduler  │   │  │
│  │  │ Controllers  │  │   Handler    │  │   (Cleanup)  │   │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘   │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────┐    │  │
│  │  │           Security Filter Chain                   │    │  │
│  │  │  - JWT Authentication Filter                      │    │  │
│  │  │  - Rate Limit Filter                              │    │  │
│  │  │  - CORS Filter                                    │    │  │
│  │  └──────────────────────────────────────────────────┘    │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────┐    │  │
│  │  │              Business Logic Layer                 │    │  │
│  │  │  - User Service                                   │    │  │
│  │  │  - Session Service                                │    │  │
│  │  │  - Feedback Service                               │    │  │
│  │  │  - Scenario Service                               │    │  │
│  │  └──────────────────────────────────────────────────┘    │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────┐    │  │
│  │  │           Data Access Layer (JPA)                 │    │  │
│  │  │  - Repositories                                   │    │  │
│  │  │  - QueryDSL                                       │    │  │
│  │  └──────────────────────────────────────────────────┘    │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   MariaDB    │    │  OpenAI API  │    │ OAuth2       │
│   Database   │    │  - ChatGPT   │    │ Providers    │
│              │    │  - Realtime  │    │ - Google     │
│              │    │  - Whisper   │    │ - Kakao      │
│              │    │              │    │ - Naver      │
└──────────────┘    └──────────────┘    └──────────────┘
```

---

## 레이어 아키텍처

Dialogym Backend는 계층형 아키텍처(Layered Architecture)를 채택하여 관심사의 분리와 유지보수성을 확보합니다.

### 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │ Controller │  │    DTO     │  │  Exception │        │
│  │            │  │  Request/  │  │  Handler   │        │
│  │            │  │  Response  │  │            │        │
│  └────────────┘  └────────────┘  └────────────┘        │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   Business Logic Layer                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │  Service   │  │  Validator │  │   Mapper   │        │
│  │            │  │            │  │            │        │
│  └────────────┘  └────────────┘  └────────────┘        │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   Data Access Layer                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │ Repository │  │   Entity   │  │  QueryDSL  │        │
│  │    (JPA)   │  │            │  │            │        │
│  └────────────┘  └────────────┘  └────────────┘        │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                      Database Layer                      │
│                      MariaDB 10.x                        │
└─────────────────────────────────────────────────────────┘
```

### 계층별 책임

#### Presentation Layer (표현 계층)

**위치**: `com.aid.train.backend.domain.*.controller`

**책임**:
- HTTP 요청 및 응답 처리
- 입력값 검증 (Bean Validation)
- DTO 변환
- 예외 처리 및 에러 응답 생성

**주요 컴포넌트**:
- `@RestController`: RESTful API 엔드포인트
- `@RequestBody`, `@PathVariable`, `@RequestParam`: 요청 데이터 바인딩
- `@Valid`: 입력값 검증
- `ApiResponse<T>`: 통일된 응답 포맷

#### Business Logic Layer (비즈니스 로직 계층)

**위치**: `com.aid.train.backend.domain.*.service`

**책임**:
- 핵심 비즈니스 로직 구현
- 트랜잭션 관리 (`@Transactional`)
- 도메인 규칙 검증
- 외부 API 호출 (OpenAI, OAuth2)
- 이메일 발송, 캐싱 등

**주요 컴포넌트**:
- `@Service`: 비즈니스 로직 처리
- `@Transactional`: 트랜잭션 경계 설정
- `@Async`: 비동기 처리 (이메일 발송)
- `@Cacheable`: 캐싱 처리

#### Data Access Layer (데이터 접근 계층)

**위치**: `com.aid.train.backend.domain.*.repository`

**책임**:
- 데이터베이스 CRUD 작업
- 복잡한 쿼리 작성 (QueryDSL)
- 엔티티 매핑 및 관계 관리

**주요 컴포넌트**:
- `JpaRepository`: 기본 CRUD 메서드 제공
- `@Query`: JPQL 쿼리 작성
- QueryDSL: 타입 안전한 동적 쿼리

#### Domain Layer (도메인 계층)

**위치**: `com.aid.train.backend.domain.*.entity`

**책임**:
- 도메인 모델 정의
- 엔티티 간 관계 설정
- 도메인 로직 캡슐화

**주요 컴포넌트**:
- `@Entity`: JPA 엔티티
- `@Table`: 테이블 매핑
- `@ManyToOne`, `@OneToMany`: 관계 매핑
- `@Embedded`: 값 객체

---

## 도메인 구조

Dialogym Backend는 도메인 주도 설계(DDD) 원칙을 따라 도메인별로 패키지를 구성합니다.

### 패키지 구조

```
com.aid.train.backend
├── domain/                    # 도메인 계층
│   ├── user/                  # 사용자 도메인
│   │   ├── controller/        # 사용자 API
│   │   ├── service/           # 사용자 비즈니스 로직
│   │   ├── repository/        # 사용자 데이터 접근
│   │   ├── entity/            # 사용자 엔티티
│   │   └── dto/               # 사용자 DTO
│   ├── scenario/              # 시나리오 도메인
│   ├── session/               # 대화 세션 도메인
│   ├── feedback/              # 피드백 도메인
│   └── verification/          # 인증 도메인
├── global/                    # 전역 설정
│   ├── config/                # 설정 클래스
│   ├── security/              # 보안 설정
│   ├── exception/             # 예외 처리
│   └── util/                  # 유틸리티
└── BackendApplication.java   # 메인 클래스
```

### 주요 도메인

#### User (사용자)

사용자 인증, 프로필 관리, 소셜 계정 연동을 담당합니다.

**엔티티**:
- User: 사용자 기본 정보
- RefreshToken: 토큰 갱신용
- SocialAccount: 소셜 계정 연동 정보

**핵심 기능**:
- 로컬 회원가입 및 로그인
- 소셜 로그인 (Google, Kakao, Naver)
- JWT 토큰 발급 및 갱신
- 프로필 조회 및 수정

#### Scenario (시나리오)

대화 훈련 시나리오 관리를 담당합니다.

**엔티티**:
- Scenario: 시나리오 정보

**핵심 기능**:
- 기본 시나리오 조회
- 사용자 커스텀 시나리오 생성
- 난이도별, 카테고리별 필터링

#### Session (대화 세션)

사용자와 AI 간의 대화 세션을 관리합니다.

**엔티티**:
- DialogueSession: 대화 세션 정보
- Transcript: 발화 내역

**핵심 기능**:
- 세션 생성 및 상태 관리
- 발화 내역 저장 및 조회
- WebRTC 연결 정보 관리

#### Feedback (피드백)

AI가 생성한 피드백을 관리합니다.

**엔티티**:
- Feedback: 피드백 정보

**핵심 기능**:
- AI 자동 피드백 생성
- 항목별 점수 계산
- 개선안 제시 및 선택
- 피드백 히스토리 조회

#### Verification (인증)

이메일 인증과 소셜 로그인 인증을 담당합니다.

**엔티티**:
- EmailVerification: 이메일 인증 정보
- OneTimeCode: 일회용 코드
- PendingSocialUser: 소셜 회원가입 대기 정보

**핵심 기능**:
- 이메일 인증 코드 발송 및 확인
- 소셜 회원가입 완료 처리
- 일회용 코드 생성 및 교환

---

## 보안 아키텍처

### Security Filter Chain

Spring Security의 필터 체인을 통해 요청을 검증하고 인증합니다.

```
HTTP Request
    │
    ▼
┌─────────────────────────────────────┐
│      CORS Filter                     │ → CORS 정책 검증
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│   JWT Authentication Filter          │ → JWT 토큰 검증
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│      Rate Limit Filter               │ → 요청 횟수 제한
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│      Authorization Check             │ → 권한 확인
└─────────────────────────────────────┘
    │
    ▼
Controller
```

### JWT 토큰 구조

**Access Token**:
```json
{
  "sub": "user@example.com",
  "userId": 1,
  "iat": 1730556000,
  "exp": 1730559600
}
```

**Refresh Token**:
- UUID v4 형식
- 데이터베이스에 해시 저장
- HttpOnly Cookie로 전송

### Rate Limiting

Bucket4j를 사용하여 API 요청 횟수를 제한합니다.

```
엔드포인트: POST /api/v1/users/refresh
제한: 사용자당 1분에 5회
구현: Token Bucket 알고리즘
```

---

## 데이터베이스 아키텍처

### ERD 요약

```
users ─────┬───── refresh_tokens
           ├───── social_accounts
           ├───── user_consents
           └───── dialogue_sessions ───┬───── transcripts
                                       └───── feedbacks

scenarios ─────── dialogue_sessions

terms ─────── user_consents
```

### 주요 테이블

| 테이블 | 용도 | 주요 컬럼 |
|--------|------|-----------|
| users | 사용자 정보 | id, email, password, name |
| scenarios | 시나리오 정보 | id, title, difficulty, category |
| dialogue_sessions | 대화 세션 | session_id, user_id, status |
| transcripts | 발화 내역 | id, session_id, speaker, content |
| feedbacks | 피드백 | id, session_id, total_score |

### 인덱스 전략

**기본 키 인덱스**:
- 모든 테이블의 id (CLUSTERED INDEX)

**외래 키 인덱스**:
- user_id, session_id, scenario_id 등

**검색 인덱스**:
- users.email
- users.status
- feedbacks.created_at

**복합 인덱스**:
- (email, primary_provider)
- (provider, provider_id)

---

## 외부 시스템 연동

### OpenAI API

**ChatGPT 4.0 (피드백 생성)**:
```
엔드포인트: https://api.openai.com/v1/chat/completions
모델: gpt-4
용도: 대화 분석 및 피드백 생성
인증: Bearer {API_KEY}
```

**Realtime API (음성 대화)**:
```
엔드포인트: wss://api.openai.com/v1/realtime
모델: gpt-4o-realtime-preview
용도: 실시간 음성 대화
인증: Ephemeral Key
```

**Whisper (STT)**:
```
엔드포인트: https://api.openai.com/v1/audio/transcriptions
모델: whisper-1
용도: 음성을 텍스트로 변환
인증: Bearer {API_KEY}
```

### OAuth2 Providers

**Google OAuth2**:
```
Authorization: https://accounts.google.com/o/oauth2/v2/auth
Token: https://oauth2.googleapis.com/token
UserInfo: https://www.googleapis.com/oauth2/v3/userinfo
Scope: openid, profile, email
```

**Kakao OAuth2**:
```
Authorization: https://kauth.kakao.com/oauth/authorize
Token: https://kauth.kakao.com/oauth/token
UserInfo: https://kapi.kakao.com/v2/user/me
Scope: profile_nickname, account_email
```

**Naver OAuth2**:
```
Authorization: https://nid.naver.com/oauth2.0/authorize
Token: https://nid.naver.com/oauth2.0/token
UserInfo: https://openapi.naver.com/v1/nid/me
```

---

## 실시간 통신 아키텍처

### WebRTC P2P 연결

```
Client                          Backend                OpenAI
  │                               │                      │
  │ 1. 세션 생성 요청             │                      │
  ├──────────────────────────────>│                      │
  │                               │                      │
  │ 2. Ephemeral Key 요청         │                      │
  ├──────────────────────────────>│                      │
  │                               │ 3. Session 생성 요청 │
  │                               ├─────────────────────>│
  │                               │                      │
  │                               │ 4. Ephemeral Key 응답│
  │                               │<─────────────────────│
  │ 5. Ephemeral Key 반환         │                      │
  │<──────────────────────────────│                      │
  │                               │                      │
  │ 6. WebRTC P2P 연결            │                      │
  ├──────────────────────────────────────────────────────>│
  │                               │                      │
  │ 7. 실시간 음성 대화            │                      │
  │<──────────────────────────────────────────────────────│
```

### Ephemeral Key

```
형식: ek_abc123...
만료: 60초
용도: 일회용 WebRTC 연결 인증
보안: HTTPS 전송, 데이터베이스 미저장
```

---

## 배포 아키텍처

### 배포 환경

```
로컬 (Local): 개발자 로컬 환경
개발 (Dev): 테스트 및 QA 환경
프로덕션 (Prod): 실제 서비스 환경
```

### Docker 컨테이너화

**Dockerfile**:
```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY build/libs/*.jar app.jar
EXPOSE 9090
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Docker Compose**:
```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "9090:9090"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
    depends_on:
      - mariadb

  mariadb:
    image: mariadb:10
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: dialogym_db
```

### AWS 배포 구성

```
Route 53 (DNS)
    │
    ▼
CloudFront (CDN)
    │
    ▼
Application Load Balancer
    │
    ├─> EC2 Instance 1 (Backend)
    ├─> EC2 Instance 2 (Backend)
    └─> EC2 Instance 3 (Backend)

RDS (MariaDB)
    │
    └─> Read Replica (향후)

S3 (정적 파일, 백업)
```

### CI/CD 파이프라인

```
GitHub Push
    │
    ▼
GitHub Actions
    │
    ├─> Build (Gradle)
    ├─> Test (JUnit)
    ├─> Docker Build
    ├─> Docker Push (ECR)
    └─> Deploy (ECS/EC2)
```

### 환경 변수 관리

```
로컬: .env 파일
개발/프로덕션: AWS Systems Manager Parameter Store
```

### 모니터링 및 로깅

**로깅**:
```
형식: JSON
레벨: INFO (프로덕션), DEBUG (개발)
저장: CloudWatch Logs
보관 기간: 30일
```

**모니터링**:
```
도구: Spring Actuator + CloudWatch
지표: CPU, 메모리, 응답 시간, 에러율
알림: CPU > 80%, 에러율 > 5%
```

**헬스체크**:
```
엔드포인트: GET /actuator/health
주기: 30초
응답:
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "diskSpace": {"status": "UP"}
  }
}
```

### 스케일링 전략

**수평 스케일링 (Horizontal Scaling)**:
- Auto Scaling Group: CPU 사용률 70% 이상 시 인스턴스 추가
- Load Balancer: 트래픽 분산
- Stateless 설계: JWT 기반 인증으로 세션 공유 불필요

**수직 스케일링 (Vertical Scaling)**:
- 인스턴스 타입 업그레이드: t3.medium → t3.large
- 데이터베이스 스케일업: RDS 인스턴스 타입 변경

**데이터베이스 최적화**:
- Read Replica: 읽기 부하 분산
- Connection Pool: HikariCP 최적화
- Query 최적화: N+1 문제 해결 (Batch Fetch)
- 인덱싱: 자주 조회되는 컬럼에 인덱스 추가

---

## 캐싱 전략

### 캐시 구성

Caffeine 인메모리 캐시를 사용하여 자주 조회되는 데이터를 캐싱합니다.

```yaml
cache:
  type: caffeine
  caffeine:
    spec: maximumSize=1000,expireAfterWrite=3600s
```

### 캐싱 대상

| 데이터 | 캐시 키 | TTL | 이유 |
|--------|---------|-----|------|
| 활성 약관 목록 | `terms:active` | 1시간 | 자주 조회, 변경 드묾 |
| 기본 시나리오 | `scenarios:default` | 1시간 | 자주 조회, 변경 드묾 |
| 사용자 프로필 | `user:{userId}` | 30분 | 자주 조회, 변경 가능 |

### 캐시 무효화

**Time-based**:
TTL 만료 시 자동 삭제

**Event-based**:
데이터 변경 시 수동 삭제 (`@CacheEvict`)

```java
@Cacheable(value = "terms", key = "'active'")
public List<TermsResponseDto> getActiveTerms() {
    // 캐시 적용
}

@CacheEvict(value = "terms", key = "'active'")
public void updateTerms(Terms terms) {
    // 캐시 무효화
}
```

---

## 스케줄러

### 정리 스케줄러

만료된 임시 데이터를 정기적으로 정리합니다.

**실행 주기**: 매일 새벽 3시

**정리 대상**:
1. 만료된 이메일 인증 데이터 (1시간 경과)
2. 만료된 Refresh Token (14일 경과)
3. 만료된 소셜 회원가입 대기 데이터 (1시간 경과)

**구현**:
```java
@Scheduled(cron = "0 0 3 * * *")  // 매일 새벽 3시
public void cleanupExpiredData() {
    cleanupExpiredEmailVerifications();
    cleanupExpiredRefreshTokens();
    cleanupExpiredSocialSignupPending();
}
```

---

## 에러 처리 전략

### 예외 계층 구조

```
Throwable
    │
    └─ Exception
        │
        ├─ RuntimeException
        │   │
        │   └─ TrainException (커스텀 예외)
        │       ├─ ErrorCode (에러 코드 Enum)
        │       └─ message (에러 메시지)
        │
        └─ MethodArgumentNotValidException (Bean Validation)
```

### 전역 예외 핸들러

Spring의 `@RestControllerAdvice`를 사용하여 모든 예외를 중앙에서 처리합니다.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(TrainException.class)
    public ResponseEntity<ApiResponse<Void>> handleTrainException(TrainException e) {
        return ResponseEntity
            .status(e.getErrorCode().getHttpStatus())
            .body(ApiResponse.error(e.getErrorCode()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
        MethodArgumentNotValidException e) {
        // Bean Validation 에러 처리
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception e) {
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(ApiResponse.error(ErrorCode.INTERNAL_SERVER_ERROR));
    }
}
```

### 에러 코드 체계

```java
public enum ErrorCode {
    // 인증 관련 (401)
    UNAUTHORIZED("AUTH001", "인증되지 않은 사용자입니다.", HttpStatus.UNAUTHORIZED),
    INVALID_CREDENTIALS("AUTH002", "이메일 또는 비밀번호가 일치하지 않습니다.", HttpStatus.UNAUTHORIZED),

    // 권한 관련 (403)
    EMAIL_NOT_VERIFIED("AUTH003", "이메일 인증이 필요합니다.", HttpStatus.FORBIDDEN),

    // 리소스 관련 (404)
    USER_NOT_FOUND("USER001", "사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND),
    SESSION_NOT_FOUND("SESSION001", "세션을 찾을 수 없습니다.", HttpStatus.NOT_FOUND),

    // 중복 관련 (409)
    EMAIL_ALREADY_EXISTS("USER002", "이미 사용 중인 이메일입니다.", HttpStatus.CONFLICT),

    // 서버 오류 (500)
    INTERNAL_SERVER_ERROR("SERVER001", "서버 내부 오류가 발생했습니다.", HttpStatus.INTERNAL_SERVER_ERROR);
}
```

---

## 성능 최적화

### 데이터베이스 최적화

**N+1 문제 해결**:
```java
// Batch Fetch Size 설정
spring.jpa.properties.hibernate.default_batch_fetch_size=100

// Fetch Join 사용
@Query("SELECT s FROM DialogueSession s " +
       "JOIN FETCH s.user " +
       "JOIN FETCH s.scenario " +
       "WHERE s.sessionId = :sessionId")
DialogueSession findByIdWithUserAndScenario(@Param("sessionId") String sessionId);
```

**읽기 전용 트랜잭션**:
```java
@Transactional(readOnly = true)
public UserProfileResponseDto getProfile(Long userId) {
    // 읽기 전용 최적화
}
```

**OSIV 비활성화**:
```yaml
spring.jpa.open-in-view: false
```

### API 최적화

**페이징**:
```java
@GetMapping("/users/{userId}/history")
public Page<FeedbackHistoryResponse> getFeedbackHistory(
    @PathVariable Long userId,
    @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC)
    Pageable pageable) {
    // 페이징 처리
}
```

**DTO Projection**:
```java
// 필요한 필드만 조회
@Query("SELECT new com.aid.train.backend.domain.feedback.dto.FeedbackHistoryResponse(" +
       "f.id, f.sessionId, s.title, f.totalScore, f.createdAt) " +
       "FROM Feedback f JOIN f.session.scenario s WHERE f.session.user.id = :userId")
List<FeedbackHistoryResponse> findHistoryByUserId(@Param("userId") Long userId);
```

### 비동기 처리

```java
@Async
public CompletableFuture<Void> sendVerificationEmail(String email, String code) {
    // 이메일 발송 (비동기)
    return CompletableFuture.completedFuture(null);
}
```

---

## 보안 체크리스트

### 인증 및 인가

- JWT 기반 Stateless 인증
- Refresh Token Rotation (RTR)
- HttpOnly Cookie (XSS 방지)
- Secure Cookie (HTTPS 전용)
- Rate Limiting (토큰 갱신)
- 비밀번호 암호화 (BCrypt)

### 입력 검증

- Bean Validation (`@Valid`)
- SQL Injection 방지 (JPA Parameterized Query)
- XSS 방지 (입력값 이스케이프)

### 통신 보안

- HTTPS 강제 (프로덕션)
- CORS 설정
- CSRF 비활성화 (Stateless API)

### 데이터 보안

- 민감 정보 암호화 (비밀번호)
- 환경 변수로 시크릿 관리
- 로그에 민감 정보 제외

---

## 참고 자료 (References)

- [API 명세서](./api-specification.md)
- [보안 정책](./backend-security-policy.md)
- [개념 ERD](./erd-conceptual.md)
- [논리 ERD](./erd-logical.md)
- [물리 ERD](./erd-physical.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|-----|----------|
| v1.0 | 2025.11.02 | 왕택준 | 최초 작성    |
