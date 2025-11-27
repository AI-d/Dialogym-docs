# AId 팀원별 기능 및 기술 담당

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.06

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 팀원**: 각자의 기술 책임 범위와 협업 지점을 명확히 이해해야 하는 개발자
* **Product Owner**: 팀원별 전문성을 고려한 작업 분배를 관리하는 책임자
* **신규 합류자**: 프로젝트의 기술 스택과 팀원별 역할을 빠르게 파악해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 AId 팀의 trAIn 프로젝트에서 3명 팀원이 담당하는 기능과 기술을 명확히 정의합니다.
왕택준은 인증/인가 및 AI 기능, 진도희는 WebRTC 및 실시간 분석, 김경민은 GPT-4o 연동 및 인프라를 담당합니다.
각 팀원의 전문 영역을 명확히 구분하여 작업 충돌을 방지하고, 협업 지점을 명시하여 통합 효율성을 높입니다.

---

## 목차 (Table of Contents)

1. [왕택준 담당 영역](#왕택준-담당-영역)
2. [김경민 담당 영역](#김경민-담당-영역)
3. [진도희 담당 영역](#진도희-담당-영역)
4. [팀원 간 협업 지점](#팀원-간-협업-지점)
5. [기술 스택 매트릭스](#기술-스택-매트릭스)

---

## 왕택준 담당 영역

### 역할
**Product Owner / Tech Lead / PM / Documentation Manager / Fullstack Developer**

### 백엔드 기능

**1. 인증/인가 시스템 (`global/security/`)**
- JWT 토큰 생성 및 검증 (JwtTokenProvider)
- JWT 인증 필터 (JwtAuthenticationFilter)
- OAuth2 로그인 성공 핸들러 (OAuth2AuthenticationSuccessHandler)
- 인증 실패 핸들러 (JwtAuthenticationEntryPoint, JwtAccessDeniedHandler)
- Rate Limiting 필터 (RefreshRateLimitFilter)
- Spring Security 전체 설정 (SecurityConfig)
- 사용자 인증 정보 관리 (CustomUserDetails, CustomUserDetailsService)

**2. 사용자 관리 (`domain/user/`)**
- 회원가입 (로컬, 소셜)
- 로그인 (로컬, 소셜)
- 토큰 갱신 (Refresh Token Rotation)
- 로그아웃
- 프로필 조회/수정
- 비밀번호 변경

**3. 이메일 인증 (`domain/verification/`)**
- 이메일 인증 코드 발송
- 인증 코드 검증
- 인증 코드 재발송
- 소셜 회원가입 완료 처리

**4. 약관 관리 (`domain/terms/`)**
- 약관 조회 및 동의 처리
- 약관 버전 관리
- 사용자별 동의 이력 관리

**5. AI 피드백 시스템 (`domain/feedback/`)**
- AI 기반 대화 분석 (FeedbackService, FeedbackPromptService)
- Spring AI + GPT-4 연동
- 종합 점수 산출 (발화 속도, 추임새, 공손도, 명료성)
- 문장별 분석 및 개선안 생성
- 피드백 히스토리 및 통계

**6. 공통 기능 (`global/`)**
- 예외 처리 (TrainException, GlobalExceptionHandler)
- 공통 응답 포맷 (ApiResponse)
- 유틸리티 (CookieUtil, LogMaskingUtil, ErrorResponseWriter)
- 설정 관리 (JwtProperties, CorsProperties, CookieProperties)
- 스케줄러 (DataCleanupScheduler)

### 프론트엔드

**Pages (페이지):**
- **Auth**: CallbackPage, EmailVerificationPage, EmailVerificationCompletePage, LoginPage, SignupPage, SocialSignupPage, SocialSignupCompletePage
- **Welcome**: WelcomePage
- **Feedback**: FeedbackGenerationPage
- **User**: MyProfilePage, PasswordChangePage

**Components (컴포넌트):**
- **Auth**: 로그인 폼, 회원가입 폼, 소셜 버튼, 이메일 인증, 약관 동의 등 모든 인증 관련 컴포넌트
- **Welcome**: WelcomeHeader, WelcomeHero, WelcomeFooter
- **Feedback**: FeedbackScoreCard, FeedbackAlternatives, FeedbackDetailModal 등 모든 피드백 컴포넌트
- **User**: ProfileForm, PasswordChangeForm, FeedbackHistory, ConsentSettings
- **Common**: Modal, inputs (TextInput, PasswordInput, DateInput, Select), ErrorMessage, LoadingOverlay

**Services (서비스):**
- authService.js (로그인, 회원가입, 토큰 교환)
- feedbackService.js (피드백 생성, 조회, 선택)
- termsService.js (약관 조회, 동의 관리)
- userService.js (프로필 조회/수정, 비밀번호 변경)
- apiClient.js (Axios 인스턴스, Interceptor)
- tokenManager.js (토큰 관리)

**Stores (상태 관리):**
- authStore.js (인증 상태, 사용자 정보, 토큰 관리)

**Hooks:**
- useAuthBootstrap.js (앱 시작 시 인증 상태 초기화)
- usePageTitle.js (페이지 제목 관리)

**Routes:**
- ProtectedRoute.jsx (인증 필요 라우트 보호)
- route.config.jsx (라우트 설정)

### 문서화

**1. 프로젝트 문서 관리**
- 40개 이상 기술 문서 작성 (@author 왕택준 표시)
- 7개 카테고리 (기획, 기술, 협업, 개발, 도구, 회의, 표준화)
- 문서 작성 표준 및 템플릿 정의

**2. 협업 도구 관리**
- Discord/Jira/GitHub 워크플로우 관리
- Git 브랜치 전략 수립
- PR 템플릿 및 코드 리뷰 가이드 작성

### 데이터베이스

**담당 테이블**
- User
- SocialAccount
- RefreshToken
- EmailVerification
- PendingSocialUser
- OneTimeCode
- Terms
- UserConsent
- Feedback

### 기술 스택

**백엔드**
- Spring Boot 3.5.5
- Java 17
- Spring Security (JWT, OAuth2)
- JPA/Hibernate
- QueryDSL 5.0.0
- MariaDB
- Caffeine Cache 3.1.8
- Bucket4j 8.10.1 (Rate Limiting)

**AI**
- Spring AI 1.0.0-M4
- OpenAI GPT-4 API
- 프롬프트 엔지니어링

**프론트엔드**
- React 19.1.1
- Vite 7.1.11
- Zustand 5.0.8
- Axios 1.12.2
- JavaScript ES6+

---

## 김경민 담당 영역

### 역할
**공동 Scrum Master / Fullstack Developer / 세션 관리·인프라 담당**

### 백엔드 기능

**1. WebSocket 실시간 통신**
- WebSocket 설정 및 핸들러 구현
- 실시간 메시지 전송/수신

**2. 세션 관리 (`domain/session/`)**
- DialogueSession 생성 및 관리
- 세션 상태 업데이트 (ONGOING, COMPLETED, FAILED)
- 세션 조회 API
- 동시성 제어

**3. Ephemeral Key 발급**
- OpenAI Ephemeral Key 발급 API
- 시나리오 프롬프트 포함
- GPT-4o Realtime API 세션 생성

**4. STT 데이터 DB 저장 및 대화 히스토리 관리**
- Transcript 엔티티 저장
- 대화 내용 DB 저장

### 프론트엔드

**Pages (페이지):**
- **Scenario**: ScenarioListPage (시나리오 선택 화면), CreateScenarioPage (커스텀 시나리오 생성 화면)

**Components (컴포넌트):**
- **Header**: AppHeader (공동 작업)

**Stores (상태 관리):**
- scenarioStore.js (시나리오 목록 및 선택 상태)
- authStore.js (공동 작업)

**Layouts:**
- AppLayout (공동 작업)

**기타:**
- AiTest.jsx (공동 작업)
- main.jsx (공동 작업)

**참고:** 시나리오 관련 프론트엔드 페이지 담당, 인프라 및 백엔드 세션 관리에 주력

### 인프라

**1. AWS 배포 아키텍처 설계 및 구축**
- AWS EC2 인스턴스 생성 및 관리
- 도메인 연결 (dialogym.shop, api.dialogym.shop)
- Route 53 DNS 설정
- RDS MariaDB 생성 및 연결
- 보안 그룹 관리

**2. Docker 컨테이너화**
- Docker Compose 작성
  - Spring Boot 컨테이너
  - MariaDB 컨테이너
- Dockerfile 최적화

**3. Nginx 리버스 프록시**
- Nginx 설정 (Reverse Proxy, HTTPS, SSL 종료)
- Let's Encrypt 인증서 발급 및 자동 갱신

**4. HTTPS 인증서 발급 및 보안 그룹 관리**
- SSL/TLS 인증서 관리
- 보안 그룹 설정

**5. CI/CD 구축 (GitHub Actions)**
- 백엔드 파이프라인: Gradle 빌드 → EC2 배포 → Docker Compose 재시작
- 프론트엔드 파이프라인: Vite 빌드 → S3 업로드 → CloudFront 캐시 무효화
- dev 브랜치 자동 배포

**6. S3 + CloudFront 프론트엔드 배포**
- AWS S3 정적 웹사이트 호스팅
- CloudFront CDN 설정
- AWS Certificate Manager (SSL 인증서)
- 캐시 무효화 자동화

### 데이터베이스

**담당 테이블**
- DialogueSession
- Transcript

### 기술 스택

**백엔드**
- Spring Boot 3.5.5
- Java 17
- WebSocket

**AI**
- OpenAI GPT-4o Realtime API

**인프라**
- AWS (EC2, S3, CloudFront, RDS, Route 53)
- Docker & Docker Compose
- Nginx
- GitHub Actions
- Let's Encrypt

**프론트엔드**
- React 19.1.1
- Vite 7.1.11
- JavaScript ES6+

---

## 진도희 담당 영역

### 역할
**공동 Scrum Master / Fullstack Developer / WebRTC·실시간 분석 담당**

### 백엔드 기능

**1. 시나리오 관리 (`domain/scenario/`)**
- 시나리오 목록 API (`GET /api/v1/scenarios`)
- 시나리오 상세 API (`GET /api/v1/scenarios/{id}`)
- 기본 시나리오 조회 (`GET /api/v1/scenarios/default`)
- 사용자 시나리오 생성/삭제
- Scenario 엔티티 및 Repository
- 시나리오 초기화 (6개 기본 시나리오)

**2. Ephemeral Key 발급 컨트롤러**
- GPT-4o Realtime API Ephemeral Key 발급
- 시나리오 프롬프트 포함

**3. WebSocket 핸들러**
- WebSocket 메시지 핸들러
- 실시간 Transcript 수신
- 음성 분석 처리

**4. 실시간 음성 분석**
- 발화 속도 계산 (WPM)
  - Transcript 기반 단어 수 카운트
  - 분당 속도 계산
- 추임새 감지
  - "음", "어", "그", "저기" 패턴 매칭
  - 빈도 수 카운트
- 실시간 피드백 WebSocket 전송

### 프론트엔드

**Pages (페이지):**
- **Dialogue**: DialoguePage (AI 대화 화면)
- **Scenario**: ScenarioListPage (시나리오 선택 화면), CreateScenarioPage (커스텀 시나리오 생성 화면)

**Hooks:**
- useRealtimeSession.js (GPT Realtime API WebRTC 연결)
  - WebRTC P2P 클라이언트 구현
  - getUserMedia() (마이크 권한)
  - GPT-4o Realtime API WebSocket 연결
  - Ephemeral Key 기반 인증
  - 음성 데이터 전송 관리
  - 음량 시각화 (VAD)
  - 실시간 STT 데이터 WebSocket 전송

**Stores (상태 관리):**
- scenarioStore.js (시나리오 목록 및 선택 상태)
- sessionStore.js (대화 세션 관리)

**Services:**
- api.js (API 호출 유틸리티)

**Components (컴포넌트):**
- Header: AppHeader (공동 작업)

**Layouts:**
- AppLayout (공동 작업)

**기타:**
- audio-processor.js (음성 처리)
- AiTest.jsx (GPT Realtime API 테스트)
- main.jsx (공동 작업)

### 문서화

**회의록 작성**
- 정기 회의록 작성 및 관리

### 데이터베이스

**담당 테이블**
- Scenario
- Transcript

### 기술 스택

**백엔드**
- Spring Boot 3.5.5
- Java 17
- WebSocket (STOMP)

**프론트엔드**
- React 19.1.1
- Vite 7.1.11
- JavaScript ES6+
- WebRTC API
- Web Audio API
- VAD (Voice Activity Detection)
- SCSS Modules

---

## 팀원 간 협업 지점

### 1. 왕택준 → 진도희

**데이터 흐름**
```
왕택준: POST /api/dialogues/start
  → sessionId, scenarioPrompt, voice 반환
진도희: WebSocket /ws/signaling/{sessionId}
  → sessionId로 Room 생성
```

**협업 내용**
- sessionId 생성 규칙 협의
- Scenario 데이터 구조 협의
- WebSocket 메시지 포맷 정의

---

### 2. 왕택준 → 김경민

**데이터 흐름**
```
왕택준: 시나리오 프롬프트 작성
  → GPT-4o에 전달할 시스템 메시지
김경민: GPT-4o API 호출
  → 프롬프트 기반 대화 생성
```

**협업 내용**
- 프롬프트 포맷 협의
- Voice 파라미터 협의
- GPT-4 점수 계산 API 스펙 정의

---

### 3. 진도희 → 김경민

**데이터 흐름**
```
진도희: WebRTC로 Opus 오디오 수신
  → Janus를 통해 오디오 스트림 전달
김경민: Opus → PCM 변환
  → GPT-4o에 전송
```

**협업 내용**
- 오디오 포맷 규격 협의 (코덱, 샘플레이트)
- 청킹 단위 협의 (100ms)
- WebSocket 메시지 구조 협의

---

### 4. 진도희 + 김경민 → 왕택준

**데이터 흐름**
```
김경민: 세션 데이터 관리
  → DialogueSession 엔티티 저장
진도희: transcript 생성
  → 대화 내용 텍스트 (Transcript 엔티티)
→ 왕택준: POST /api/v1/feedbacks/sessions/{sessionId}
  → 세션 데이터 조회하여 피드백 생성
```

**협업 내용**
- API 요청/응답 구조 협의
- 필수 필드 정의 (sessionId, transcript, wpm, fillerCount)
- 피드백 생성 트리거 시점 협의

---

## 기술 스택 매트릭스

| 기술 영역 | 왕택준 | 진도희 | 김경민 |
|---------|-------|-------|-------|
| **백엔드 프레임워크** | Spring Boot | Spring Boot | Spring Boot |
| **인증/인가** | JWT, Spring Security | - | - |
| **WebSocket** | - | ☑️ 메시지 핸들러 | ☑️ Ephemeral Key |
| **WebRTC** | - | P2P 클라이언트 | - |
| **AI API** | GPT-4 (점수) | - | GPT-4o Realtime |
| **음성 분석** | - | WPM, 추임새 | - |
| **데이터베이스** | JPA, MariaDB | JPA, MariaDB | RDS 관리 |
| **프론트엔드** | React (인증, 피드백) | React (WebRTC) | React (히스토리) |
| **인프라** | - | - | AWS, Docker, CI/CD |
| **모니터링** | - | - | CloudWatch |
| **성능 테스트** | - | E2E 테스트 | 부하 테스트 |

---

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.06 | 왕택준 | 최초 작성 및 승인 |
