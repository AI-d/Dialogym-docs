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
**Product Owner / Tech Lead / 인증·AI 담당**

### 백엔드 기능

**1. 인증/인가 시스템**
- JWT 기반 회원가입 API (`POST /api/auth/signup`)
- 로그인 API (`POST /api/auth/login`)
- JWT 토큰 발급 및 검증
- Spring Security 설정
- User 엔티티 및 Repository

**2. 세션 관리**
- 대화 세션 시작 API (`POST /api/dialogues/start`)
- sessionId 생성 (UUID)
- DialogueSession 엔티티 생명주기 관리
- 시나리오/프로필 정보 조회 및 반환

**3. 피드백 생성**
- 피드백 저장 API (`POST /api/feedback/save`)
- GPT-4 API 호출 (점수 계산)
  - 공손도 (politeness: 1~10)
  - 명료성 (clarity: 1~10)
- 개선안 3가지 생성 (짧게/공손/따뜻)
- Feedback 엔티티 저장

**4. 히스토리 관리**
- 히스토리 목록 API (`GET /api/history`)
- 성장 통계 API (`GET /api/history/stats`)
- History 엔티티 관리

### AI/프롬프트

**1. 시나리오 프롬프트 작성 (6개)**
- "상사 보고" 시나리오
- "면접 연습" 시나리오
- "연인 갈등" 시나리오
- "부모님 연락" 시나리오
- "동료 협업" 시나리오
- "교사-학부모" 시나리오

**2. GPT-4o Voice 선택**
- 시나리오별 최적 Voice 파라미터 선택
- 말투, 성격, 대화 규칙 정의

**3. 점수화 로직**
- 발화 속도 점수 계산 (30점)
- 추임새 점수 계산 (20점)
- 공손도 점수 계산 (25점)
- 명료성 점수 계산 (25점)
- 종합 점수 산출 알고리즘 (0~100점)

### 프론트엔드

**1. 로그인/회원가입 화면**
- 로그인 폼 UI
- 회원가입 폼 UI
- JWT 토큰 저장 (localStorage)

**2. 피드백 화면**
- 점수 대시보드 UI
- 개선안 카드 UI (3가지 버전)
- 녹음 파일 재생 컴포넌트

**3. 히스토리 화면**
- 히스토리 목록 UI
- 필터 및 정렬 기능
- 성장 그래프 (Recharts)

### 데이터베이스

**담당 테이블**
- User
- DialogueSession
- Feedback
- History

### 기술 스택

**백엔드**
- Spring Boot 3.5.5
- Java 17
- Spring Security (JWT)
- JPA/Hibernate
- MariaDB

**AI**
- OpenAI GPT-4 API
- 프롬프트 엔지니어링

**프론트엔드**
- React 19.1.1
- Vite 7.1.2
- JavaScript ES6+

---

## 김경민 담당 영역

### 역할
**공동 Scrum Master / Fullstack Developer / GPT-4o·인프라 담당**

### 백엔드 기능

**1. GPT-4o Realtime API 연동**
- GPT-4o WebSocket 클라이언트 구현
- 세션 생성 및 프롬프트 전송
- 실시간 오디오 청크 송수신
- Base64 인코딩/디코딩

**2. 오디오 처리**
- Opus → PCM 16kHz 변환
- 리샘플링 로직
- 100ms 단위 청킹
- 오디오 포맷 변환 라이브러리 관리

**3. 녹음 파일 관리**
- Janus 녹화 플러그인 연동
- 녹음 파일 생성 (MP3 128kbps)
- AWS S3 업로드
- audioUrl 생성 및 반환

### 인프라

**1. 배포 환경 구축**
- AWS EC2 인스턴스 생성 및 관리
- 도메인 연결 (dialogym.com)
- Nginx 설정 (Reverse Proxy, HTTPS)
- Let's Encrypt 인증서 발급

**2. Docker**
- Docker Compose 작성
  - Spring Boot 컨테이너
  - MariaDB 컨테이너
  - Redis 컨테이너
- 멀티 스테이지 빌드

**3. CI/CD**
- GitHub Actions 워크플로우
  - 백엔드 빌드 (Gradle)
  - 프론트엔드 빌드 (Vite)
  - Docker 이미지 빌드 및 푸시
- 자동 배포 스크립트
- 무중단 배포 (Blue-Green)

**4. 데이터베이스**
- RDS (MariaDB) 생성 및 연결
- 백업 자동화
- 성능 튜닝

**5. 모니터링**
- CloudWatch 대시보드 구성
- 로그 수집 및 분석
- 알림 규칙 설정
  - CPU 사용률 80% 이상
  - 에러율 5% 이상
  - 디스크 용량 부족

### 프론트엔드

**1. 시나리오 선택 화면 (공동)**
- 시나리오 카드 UI
- API 연동

**2. 히스토리 화면 (공동)**
- 히스토리 목록 UI
- 그래프 컴포넌트

### 성능 테스트

**1. 부하 테스트**
- JMeter 시나리오 작성
- 동시 접속 10명 테스트
- API 응답 시간 측정

**2. 최적화**
- GPT-4o 응답 지연 최소화 (<200ms)
- 녹음 파일 업로드 속도 개선
- 데이터베이스 쿼리 최적화

### 기술 스택

**백엔드**
- Spring Boot 3.5.5
- Java 17
- WebSocket (OpenAI Realtime API)
- FFmpeg (오디오 처리)

**AI**
- OpenAI GPT-4o Realtime API

**인프라**
- AWS (EC2, S3, RDS, CloudWatch)
- Docker & Docker Compose
- Nginx
- GitHub Actions
- Let's Encrypt

**프론트엔드**
- React 19.1.1
- Vite 7.1.2
- JavaScript ES6+

---

## 진도희 담당 영역

### 역할
**공동 Scrum Master / Fullstack Developer / WebRTC·실시간 분석 담당**

### 백엔드 기능

**1. 시나리오 관리**
- 시나리오 목록 API (`GET /api/scenarios`)
- 시나리오 상세 API (`GET /api/scenarios/{id}`)
- Scenario 엔티티 및 Repository

**2. WebRTC Signaling 서버**
- WebSocket 엔드포인트 (`/ws/signaling/{sessionId}`)
- SDP Offer/Answer 처리
- ICE Candidates 중계
- Janus REST API 연동 (Room 생성)

**3. 실시간 음성 분석**
- 발화 속도 계산 (WPM)
  - 음성 → 텍스트 변환 (STT)
  - 단어 수 카운트
  - 분당 속도 계산
- 추임새 감지
  - "음", "어", "그", "저기" 패턴 매칭
  - 빈도 수 카운트
- 실시간 피드백 WebSocket (`/ws/feedback/{sessionId}`)

**4. Janus Media Server**
- Janus Docker 설치 및 설정
- Janus 플러그인 설정 (VideoRoom)
- STUN/TURN 서버 설정 (Coturn)

### 프론트엔드

**1. 시나리오 선택 화면**
- 시나리오 카드 그리드 UI
- 필터링 기능
- 시나리오 선택 상태 관리

**2. 대화 화면**
- WebRTC 클라이언트 구현
  - getUserMedia() (마이크 권한)
  - RTCPeerConnection 생성
  - createOffer() 및 SDP 교환
  - ICE Candidates 처리
- 마이크 On/Off 버튼
- 대화 타이머
- 실시간 자막 표시
- 실시간 피드백 UI
  - 추임새 알림
  - 발화 속도 게이지
- 음량 시각화 (Web Audio API)

### QA 및 최적화

**1. 통합 테스트**
- E2E 테스트 (전체 시나리오)
- Cross-browser 테스트
- 모바일 반응형 확인

**2. 성능 최적화**
- WebRTC 연결 안정성 개선
- 실시간 분석 성능 튜닝
- 프론트엔드 번들 사이즈 최적화

### 데이터베이스

**담당 테이블**
- Scenario
- Transcript

### 기술 스택

**백엔드**
- Spring Boot 3.5.5
- Java 17
- WebSocket (STOMP)
- Janus Media Server
- Coturn (STUN/TURN)

**프론트엔드**
- React 19.1.1
- Vite 7.1.2
- JavaScript ES6+
- WebRTC API
- Web Audio API
- module.scss

**인프라**
- Docker (Janus)

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
김경민: 녹음 파일 S3 업로드
  → audioUrl 생성
진도희: transcript 생성
  → 대화 내용 텍스트
→ 왕택준: POST /api/feedback/save
  → audioUrl, transcript 받아서 피드백 생성
```

**협업 내용**
- API 요청 본문 구조 협의
- 필수 필드 정의 (sessionId, audioUrl, transcript, wpm, fillerCount)
- 응답 포맷 협의

---

## 기술 스택 매트릭스

| 기술 영역 | 왕택준 | 진도희 | 김경민 |
|---------|-------|-------|-------|
| **백엔드 프레임워크** | Spring Boot | Spring Boot | Spring Boot |
| **인증/인가** | JWT, Spring Security | - | - |
| **WebSocket** | - | ☑️ STOMP (Signaling) | ☑️ OpenAI WebSocket |
| **WebRTC** | - | Janus, STUN/TURN | 오디오 처리 |
| **AI API** | GPT-4 (점수) | - | GPT-4o Realtime |
| **오디오 처리** | - | STT, 분석 | Opus/PCM 변환 |
| **데이터베이스** | JPA, MariaDB | JPA, MariaDB | RDS 관리 |
| **프론트엔드** | React (인증, 피드백) | React (WebRTC) | React (히스토리) |
| **인프라** | - | Janus Docker | AWS, CI/CD |
| **모니터링** | - | - | CloudWatch |
| **성능 테스트** | - | E2E 테스트 | 부하 테스트 |

---

## 기능 복잡도 분석

### 왕택준
- **높은 난이도**: GPT-4 프롬프트 엔지니어링, 점수화 알고리즘
- **중간 난이도**: JWT 인증, CRUD API
- **낮은 난이도**: 기본 React UI

**예상 시간**: 3~4주 (Sprint 2~5 분산)

---

### 진도희
- **높은 난이도**: WebRTC Signaling, Janus 연동, 실시간 분석
- **중간 난이도**: React 대화 화면
- **낮은 난이도**: 시나리오 API

**예상 시간**: 3~4주 (Sprint 2~5 집중)

---

### 김경민
- **높은 난이도**: GPT-4o Realtime 연동, 오디오 변환, CI/CD
- **중간 난이도**: Docker, AWS 배포
- **낮은 난이도**: S3 업로드

**예상 시간**: 3~4주 (Sprint 2~5 집중)

---

## 작업량 균형 검증

| 항목 | 왕택준 | 진도희 | 김경민 |
|------|-------|-------|-------|
| **백엔드 API** | 5개 그룹 | 3개 그룹 | 3개 그룹 |
| **프론트 화면** | 3개 | 2개 | 1개 |
| **AI/프롬프트** | 6개 시나리오 | - | Voice 최적화 |
| **인프라** | - | Janus | AWS 전체 |
| **예상 시간** | 3~4주 | 3~4주 | 3~4주 |

**결론**: 작업량과 난이도가 균형있게 분배되었습니다.

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.06 | 왕택준 | 최초 작성 및 승인 |
