# Dialogym 기능 명세서

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **개발팀 전체**: 구현해야 할 기능과 기술 스택을 이해해야 하는 개발자
* **Product Owner**: 기능 우선순위와 범위를 관리하는 책임자
* **QA**: 테스트 계획 수립을 위한 기능 목록 파악이 필요한 담당자
* **신규 합류자**: 프로젝트의 기술 구조와 기능을 빠르게 파악해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

Dialogym은 GPT-4o Realtime API와 WebRTC P2P 연결을 핵심 기술로 활용하여 실시간 음성 대화 훈련 플랫폼을 구현합니다.
6가지 시나리오 기반 역할극, 실시간 음성 분석, 점수화 피드백, 히스토리 관리 기능을 제공하며, React와 Spring Boot 기반으로 개발됩니다.
5주 개발 일정 내 MVP 완성을 목표로 하며, 실제 배포까지 완료했습니다 (https://dialogym.shop).

---

## 목차 (Table of Contents)

1. [기술 스택](#기술-스택)
2. [핵심 기능](#핵심-기능)
3. [MoSCoW 분류](#moscow-분류)
4. [시스템 아키텍처](#시스템-아키텍처)
5. [팀원별 담당 영역](#팀원별-담당-영역)
6. [개발 일정](#개발-일정)
7. [관련 문서](#관련-문서)

---

## 기술 스택

### 프론트엔드

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **언어** | JavaScript | ES6+ | 프론트엔드 개발 언어 |
| **프레임워크** | React | 19.1.1 | UI 라이브러리 |
| **빌드 도구** | Vite | 7.1.11 | 빠른 개발 서버 및 빌드 |
| **라우팅** | React Router DOM | 7.9.4 | 클라이언트 사이드 라우팅 |
| **상태 관리** | Zustand | 5.0.8 | 경량 전역 상태 관리 |
| **상태 영속화** | zustand-persist | 0.4.0 | 상태 영속화 |
| **불변성 관리** | Immer | 10.2.0 | 불변성 관리 |
| **스타일링** | SASS | 1.92.1 | CSS 전처리기 |
| **스타일링** | SCSS Modules | - | 컴포넌트별 스타일 격리 |
| **HTTP 클라이언트** | Axios | 1.12.2 | HTTP 요청 |
| **통신** | WebRTC | - | 실시간 음성 통신 |
| **UI 컴포넌트** | Ant Design | 5.27.4 | UI 컴포넌트 라이브러리 |
| **아이콘** | React Icons | 5.5.0 | 아이콘 라이브러리 |
| **알림** | React Hot Toast | 2.6.0 | 토스트 알림 |
| **마크다운** | React Markdown | 10.1.0 | 마크다운 렌더링 |

---

### 백엔드

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **언어** | Java | 17 | 백엔드 개발 언어 |
| **프레임워크** | Spring Boot | 3.5.5 | 웹 애플리케이션 프레임워크 |
| **ORM** | JPA/Hibernate | - | 데이터베이스 ORM |
| **데이터베이스** | MariaDB | 10.x | 관계형 데이터베이스 |
| **캐시** | Caffeine | 3.1.8 | 고성능 인메모리 캐시 |
| **인증** | JWT | 0.12.3 | 토큰 기반 인증 |
| **보안** | Spring Security | - | 인증/인가 프레임워크 |
| **OAuth2** | Spring OAuth2 Client | - | 소셜 로그인 |
| **쿼리** | QueryDSL | 5.0.0 | 타입 안전 쿼리 |
| **쿼리 로깅** | p6spy | 1.9.1 | SQL 쿼리 로깅 |
| **Rate Limiting** | Bucket4j | 8.10.1 | API 요청 제한 |
| **AOP** | Spring AOP | - | 관점 지향 프로그래밍 |
| **이메일** | Spring Mail | - | 이메일 발송 |
| **템플릿** | Thymeleaf | - | 이메일 템플릿 |
| **환경 변수** | Spring Dotenv | 4.0.0 | .env 파일 관리 |
| **모니터링** | Spring Actuator | - | 애플리케이션 모니터링 |
| **API 문서** | SpringDoc OpenAPI | 2.8.13 | Swagger UI 자동 생성 |
| **개발 도구** | Spring DevTools | - | 개발 편의 기능 |
| **코드 생성** | Lombok | - | 보일러플레이트 코드 제거 |

---

### AI 및 음성 처리

| 구분 | 기술 | 용도 |
|------|------|------|
| **음성 대화** | GPT-4o Realtime API | 실시간 음성 대화 (사용자 ↔ AI), WebRTC P2P 연결 |
| **텍스트 분석** | GPT-4 API | 대화 분석 및 점수 계산 |
| **AI 통합** | Spring AI | 1.0.0-M4 | AI 통합 프레임워크 |
| **프롬프트** | Custom Prompts | 시나리오별 역할 설정 (6개) |
| **음성 활동 감지** | @ricky0123/vad-react | 0.0.34 | React용 음성 활동 감지 |
| **음성 활동 감지** | @ricky0123/vad-web | 0.0.28 | 웹 기반 음성 활동 감지 |

---

### 인프라 및 미디어

| 구분 | 기술 | 용도 |
|------|------|------|
| **컨테이너** | Docker + Docker Compose | 개발 환경 통일 및 배포 |
| **CI/CD** | GitHub Actions | 자동 빌드 및 배포 |
| **웹 서버** | Nginx | 리버스 프록시, HTTPS, SSL 종료 |
| **클라우드** | AWS (EC2, S3, CloudFront, RDS) | 서버 호스팅, 정적 파일, CDN, 데이터베이스 |
| **도메인** | Route 53 | DNS 관리 |
| **SSL/TLS** | Let's Encrypt + AWS Certificate Manager | 무료 인증서 |
| **협업 도구** | Discord + Jira + GitHub | 커뮤니케이션 및 이슈 관리 |

---

### 테스트 및 개발 도구

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **테스트 프레임워크** | JUnit 5 | - | 백엔드 단위 테스트 |
| **Mocking** | Mockito | - | 테스트 Mock 객체 |
| **테스트 DB** | H2 Database | - | 인메모리 테스트 DB |
| **프론트 테스트** | Vitest | 4.0.3 | 프론트엔드 단위 테스트 |
| **E2E 테스트** | Playwright | 1.56.1 | End-to-End 테스트 |
| **컴포넌트 개발** | Storybook | 9.1.15 | 컴포넌트 개발 환경 |
| **린팅** | ESLint | 9.33.0 | 코드 린팅 |

---

## 핵심 기능

### 1. 회원 관리

**기능:**
- 회원가입 (이메일, 비밀번호, 약관 동의)
- 소셜 로그인 (Google, Kakao, Naver)
- 이메일 인증 (6자리 코드)
- 로그인 (JWT 토큰 발급: Access + Refresh)
- 로그아웃
- 토큰 갱신 (Refresh Token Rotation)
- 프로필 조회 및 수정
- 비밀번호 변경

**API:**
- `POST /api/v1/users/signup`
- `POST /api/v1/users/login`
- `POST /api/v1/users/logout`
- `POST /api/v1/users/refresh`
- `POST /api/v1/users/token/exchange` (소셜 로그인)
- `GET /api/v1/users/profile`
- `PUT /api/v1/users/profile`
- `PUT /api/v1/users/password`

**담당:**
- 백엔드: 왕택준
- 프론트엔드: 왕택준

---

### 2. 시나리오 관리

**기능:**
- 시나리오 목록 조회 (전체/기본/사용자 생성)
- 시나리오 상세 조회
- 커스텀 시나리오 생성
- 사용자 시나리오 삭제
- 6가지 기본 시나리오 제공
  1. 상사에게 휴가 요청하기
  2. 부모님께 여행 요청하기
  3. 친구에게 모임 제안하기
  4. 식당 예약 요청하기
  5. 동료에게 프로젝트 협조 요청하기
  6. 연인에게 중요한 대화 요청하기

**API:**
- `GET /api/v1/scenarios` (전체 조회)
- `GET /api/v1/scenarios/default` (기본 시나리오)
- `GET /api/v1/scenarios/{id}` (상세 조회)
- `POST /api/v1/scenarios` (사용자 생성)
- `GET /api/v1/scenarios/me/{userId}` (사용자 시나리오 목록)
- `DELETE /api/v1/scenarios/me/{userId}/{id}` (삭제)

**담당:**
- 백엔드: 진도희
- 프론트엔드: 김경민

---

### 3. 대화 세션 관리

**기능:**
- 대화 세션 생성 (sessionId 생성: UUID)
- 세션 상태 조회
- 세션 종료 (정상/실패)
- 세션 상태 관리 (ONGOING, COMPLETED, FAILED)

**API:**
- `POST /api/v1/sessions` (세션 생성)
- `GET /api/v1/sessions/{sessionId}` (세션 조회)
- `PUT /api/v1/sessions/{sessionId}/complete` (정상 종료)
- `PUT /api/v1/sessions/{sessionId}/fail` (실패 처리)

**담당:**
- 백엔드: 김경민

---

### 4. Ephemeral Key 발급 및 실시간 대화

**기능:**
- OpenAI Ephemeral Key 발급
- 시나리오 프롬프트 포함
- WebRTC P2P 연결 (프론트엔드 ↔ GPT-4o)
- 실시간 음성 스트리밍
- STT (Speech-to-Text) 실시간 변환

**API:**
- `POST /api/v1/realtime/session` (Ephemeral Key 발급)

**담당:**
- 백엔드: 김경민
- 프론트엔드: 진도희

---

### 5. 실시간 음성 분석

**기능:**
- 발화 속도 계산 (WPM - Words Per Minute)
- 추임새 감지 ("음", "어", "그", "저기" 등)
- 실시간 피드백 전송 (WebSocket)

**담당:**
- 백엔드: 진도희

---

### 6. 피드백 생성

**기능:**
- GPT-4 API 호출 (점수 계산)
  - 공손도 (politeness: 1~10)
  - 명료성 (clarity: 1~10)
- 종합 점수 계산 (0~100)
  - 발화 속도 (30점)
  - 추임새 (20점)
  - 공손도 (25점)
  - 명료성 (25점)
- 개선안 3가지 생성
  - 간결하게
  - 정중하게
  - 따뜻하게

**API:**
- `POST /api/v1/feedbacks/sessions/{sessionId}` (AI 피드백 생성)
- `GET /api/v1/feedbacks/{sessionId}` (피드백 조회)
- `PUT /api/v1/feedbacks/{sessionId}/choice` (개선안 선택)

**담당:**
- 백엔드: 왕택준

---

### 7. 히스토리 관리

**기능:**
- 피드백 히스토리 조회 (페이징)
- 전체 히스토리 조회
- 성장 통계 (점수 변화 추이, 평균, 등급 분포)

**API:**
- `GET /api/v1/feedbacks/users/{userId}/history` (페이징)
- `GET /api/v1/feedbacks/users/{userId}/history/all` (전체)
- `GET /api/v1/feedbacks/users/{userId}/stats` (통계)

**담당:**
- 백엔드: 왕택준
- 프론트엔드: 왕택준

---

### 8. 이메일 인증

**기능:**
- 이메일 인증 코드 발송 (6자리)
- 인증 코드 검증
- 인증 코드 재발송
- 소셜 회원가입 완료

**API:**
- `POST /api/v1/verification/email` (인증 확인)
- `POST /api/v1/verification/email/resend` (재발송)
- `POST /api/v1/verification/social/complete` (소셜 회원가입 완료)

**담당:**
- 백엔드: 왕택준

---

### 9. 약관 관리

**기능:**
- 활성 약관 목록 조회
- 사용자 약관 동의 내역 조회
- 약관 동의 상태 변경

**API:**
- `GET /api/v1/terms` (활성 약관)
- `GET /api/v1/terms/consent` (내 동의 내역)
- `PUT /api/v1/terms/consent` (동의 변경)

**담당:**
- 백엔드: 왕택준

---

## MoSCoW 분류

### Must Have (필수 - MVP 포함)

1. **회원 관리**
   - 회원가입, 로그인 (JWT)

2. **시나리오 선택**
   - 6가지 시나리오 목록 및 상세

3. **실시간 음성 대화**
   - WebRTC P2P 연결
   - GPT-4o Realtime API
   - Ephemeral Key 발급

4. **음성 분석**
   - 발화 속도 (WPM)
   - 추임새 감지
   - 실시간 STT

5. **피드백 생성**
   - 점수화 (0~100)
   - 개선안 3가지
   - 개선안 선택 기능

6. **히스토리 저장**
   - 피드백 히스토리
   - 성장 통계

7. **이메일 인증**
   - 6자리 코드 발송/검증

8. **약관 관리**
   - 약관 동의 관리

---

### Should Have (우선 고려 - MVP 이후)

1. **프로필 관리**
   - 사용자 프로필 수정
   - 아바타 이미지

2. **성장 통계**
   - 점수 변화 그래프
   - 주간/월간 리포트

3. **시나리오 확장**
   - 추가 시나리오 (8~10개)

4. **개선안 선택**
   - 사용자가 선택한 개선안 저장
   - 선호 스타일 학습

---

### Could Have (추가 고려 - 여유 시 구현)

1. **상대방 스타일 학습**
   - 대화 상대 프로필 생성
   - 말투, 톤, 습관 반영

2. **7일 대화 챌린지**
   - 연속 훈련 동기 부여
   - 배지 시스템

3. **감정 톤 분석**
   - 대화 중 감정 변화 감지
   - 감정 조절 피드백

4. **메시지 초안 추천**
   - 텍스트 기반 메시지 작성 지원
   - 톤 선택 (공식/친근/따뜻)

---

### Won't Have (제외 - 1차 MVP에서 제외)

1. **다국어 지원**
   - 영어, 중국어, 일본어 등

2. **실시간 통화 중 AI 개입**
   - 실제 전화 중 실시간 코칭

3. **동영상 대화**
   - 화상 통화 연습

4. **모바일 앱**
   - iOS, Android 네이티브 앱

---

## 시스템 아키텍처

### 전체 구조

```
[사용자]
   ↓ (HTTPS)
[CloudFront CDN]
   ↓
[S3 Static Hosting] ← React Frontend (SPA)
   ↓ (HTTPS REST API + WebSocket)
[Route 53 DNS]
   ↓
[EC2 + Nginx]
   ↓
[Docker Container]
   └─ [Spring Boot Backend]
       │
       ├─ [도메인 계층]
       │   ├─ User (사용자 관리)
       │   ├─ Verification (이메일 인증)
       │   ├─ Terms (약관 관리)
       │   ├─ Scenario (시나리오 관리)
       │   ├─ Session (대화 세션 관리)
       │   └─ Feedback (피드백 관리)
       │
       ├─ [외부 API]
       │   ├─ GPT-4o Realtime API (실시간 음성 대화)
       │   └─ GPT-4 API (피드백 생성)
       │
       └─ [데이터 계층]
           ├─ MariaDB (영구 데이터)
           └─ Caffeine Cache (세션 캐시)
```

---

### 데이터 흐름

#### 1. 대화 시작

```
사용자: 시나리오 선택
   ↓
Frontend: POST /api/v1/sessions
   - userId, scenarioId
   ↓
Backend: sessionId 생성 (UUID)
   ↓
Frontend: POST /api/v1/realtime/session
   - sessionId, model, voice, sttModel
   ↓
Backend: 시나리오 프롬프트 생성
   ↓
Backend: OpenAI Ephemeral Key 발급
   ↓
Frontend: WebRTC P2P 연결 시작
```

#### 2. 실시간 대화

```
사용자 음성 (마이크)
   ↓ WebRTC P2P
Frontend
   ↓ WebSocket
GPT-4o Realtime API
   ↓ Audio Response
Frontend
   ↓ WebRTC P2P
사용자 (스피커)

동시에:
GPT-4o Realtime API
   ↓ Transcript (STT)
Backend (WebSocket Handler)
   ↓ 음성 분석 (WPM, 추임새)
Frontend (실시간 피드백 표시)
```

#### 3. 대화 종료 및 피드백

```
사용자: 대화 종료 버튼 클릭
   ↓
Frontend: PUT /api/v1/sessions/{sessionId}/complete
   ↓
Frontend: POST /api/v1/feedbacks/sessions/{sessionId}
   ↓
Backend: 세션 데이터 조회
   - transcript, wpm, fillerCount
   ↓
Backend: GPT-4 API 호출 (점수 계산)
   - 공손도, 명료성
   ↓
Backend: 개선안 3가지 생성
   ↓
Backend: Feedback 저장 (DB)
   ↓
Frontend: 피드백 화면 표시
```

---

## 팀원별 담당 영역

### 왕택준 (PO/Tech Lead/PM/Documentation Manager, Fullstack Developer)
**GitHub**: https://github.com/TJK98

**Backend:**
- JWT 기반 인증 시스템 구축
  - JWT 토큰 생성 및 검증 (JwtTokenProvider)
  - JWT 인증 필터 (JwtAuthenticationFilter)
  - Refresh Token Rotation (RTR)
  - Rate Limiting (RefreshRateLimitFilter)
- OAuth2 소셜 로그인 (Google/Kakao/Naver)
  - OAuth2 로그인 성공 핸들러
  - 일회용 코드 방식 구현
- 이메일 인증 (6자리 코드 발송/검증)
- 약관 관리 API
- AI 피드백 생성
  - 전체 대화 평가
  - 문장별 분석
  - 개선안 3개 생성 (간결/공손/따뜻)
- 피드백 히스토리 및 성장 통계 API
- 공통 기능 (예외 처리, 유틸리티, 스케줄러)

**Frontend:**
- 웰컴, 회원가입, 로그인, 이메일 인증 화면 구현
- 피드백, 마이 페이지 화면 구현
- Zustand 상태 관리 (authStore, 피드백)
- Axios Interceptor (토큰 갱신 자동화)

**Docs/Collaboration:**
- 40개 이상 기술 문서 작성 및 관리
- Discord/Jira/GitHub 워크플로우 관리
- Git 브랜치 전략 수립
- 문서 작성 표준 및 템플릿 정의

---

### 김경민 (공동 SM, Fullstack Developer)
**GitHub**: https://github.com/minee0505

**Backend:**
- WebSocket 실시간 통신 구현
- 세션 관리 및 동시성 제어
- GPT-4o Realtime API Ephemeral Key 발급
- STT 데이터 DB 저장 및 대화 히스토리 관리

**Frontend:**
- 기본 시나리오 선택 화면 구현
- 커스텀 시나리오 생성 화면 구현

**Infra:**
- AWS 배포 아키텍처 설계 및 구축
- Docker 컨테이너화 및 Nginx 리버스 프록시
- HTTPS 인증서 발급 및 보안 그룹 관리
- CI/CD 구축 (GitHub Actions)
- S3 + CloudFront 프론트엔드 배포

---

### 진도희 (공동 SM, Fullstack Developer)
**GitHub**: https://github.com/dohee-jin

**Backend:**
- 시나리오 생성, 조회, 삭제 API 구현
- GPT Realtime API Ephemeral Key 발급 컨트롤러 구현
- WebSocket 핸들러 구현
- 실시간 음성 분석 (WPM, 추임새)

**Frontend:**
- AI 대화 화면 구현
- GPT Realtime API WebRTC 연결 구현
- GPT Realtime API 음성 전송 제어
- 실시간 STT 데이터 WebSocket 전송 구현
- 실시간 피드백 UI

**Docs:**
- 회의록 작성

---

## 개발 일정

### Sprint 1 (09.29 ~ 10.06) - 프로젝트 기반 구축

**완료 항목:**
- 아이디어 확정
- 팀 구성 및 기획
- 팀원 각자 공부 (Spring Boot, React, WebRTC, GPT-4o)
- 문서 계획 수립
- 협업 도구 설정 (GitHub, Jira, Discord)
- 배포 환경 구축 (AWS EC2, RDS)

---

### Sprint 2 (10.06 ~ 10.20) - 백엔드 개발 시작

**왕택준:**
- DB 설계 (ERD)
- JPA 엔티티 구현 (User, Scenario, Session, Feedback)
- 회원가입 구현 (로컬 + 이메일 인증)
- OAuth2 설정 (Google, Kakao, Naver)
- JWT 인증/인가 시스템

**김경민:**
- 보안 통합 파이프라인 구현
- WebSocket 실시간 통신 구현
- 세션 관리 및 동시성 제어

**진도희:**
- 시나리오 생성, 조회, 삭제 API 구현
- 시나리오 초기화 (6개 기본 시나리오)

---

### Sprint 3 (10.20 ~ 10.27) - 실시간 대화 기능 구축

**왕택준:**
- 세션 관리 API 완성
- AI 프롬프트 작성 (6개 시나리오)

**김경민:**
- GPT-4o Realtime API 연동
- Ephemeral Key 발급 컨트롤러 구현
- STT 데이터 DB 저장 및 대화 히스토리 관리

**진도희:**
- GPT Realtime API WebRTC 연결 구현
- WebSocket 핸들러 구현
- 실시간 음성 분석 (WPM, 추임새)

---

### Sprint 4 (10.27 ~ 11.03) - AI 피드백 및 프론트엔드 시작

**왕택준:**
- AI 피드백 생성 구현 완료
  - 전체 대화 평가
  - 문장별 분석
  - 개선안 3개 생성 (간결/공손/따뜻)
- 피드백 히스토리 API
- 성장 통계 API

**김경민:**
- CI/CD 구축 (GitHub Actions)
- Docker 컨테이너화
- Nginx 리버스 프록시 설정
- HTTPS 인증서 발급

**진도희:**
- 실시간 STT 데이터 WebSocket 전송 구현
- 음성 전송 제어 구현

---

### Sprint 5 (11.03 ~ 11.10) - 프론트엔드 개발 및 배포

**왕택준:**
- React 지식 탐색 및 연습
- 웰컴, 회원가입, 로그인, 이메일 화면 구현
- 피드백, 마이 페이지 화면 구현

**김경민:**
- React 화면 설계
- 기본 시나리오 선택 화면 구현
- 커스텀 시나리오 생성 화면 구현
- AWS 배포 아키텍처 설계 및 구축
- S3 + CloudFront 프론트엔드 배포

**진도희:**
- AI 대화 화면 구현
- GPT Realtime API WebRTC 연결 (프론트엔드)
- GPT Realtime API 음성 전송 제어
- 실시간 STT 표시
- 회의록 작성

**전체:**
- 배포 준비 및 최종 배포
- 발표 자료 작성
- 발표 및 데모

---

## 관련 문서

* [프로젝트 개요](project-overview.md) - Dialogym의 출발점과 목표
* [문제 분석 보고서](problem-analysis.md) - 해결하고자 하는 사회 문제
* [컨셉 정의서](concept-definition.md) - 서비스 철학과 핵심 컨셉
* [경쟁사 분석](competitive-analysis.md) - 기존 서비스 대비 차별점
* [팀 역할 정의](../team/team-roles.md) - 팀원별 역할과 책임
* [팀 기술 스택](../team/team-tech-stack.md) - 팀원별 기술 담당 영역
* [Sprint 계획](../meetings/sprint-planning/sprint-plan.md) - 5주 상세 일정

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
