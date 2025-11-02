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

Dialogym은 GPT-4o Realtime API, WebRTC, Janus Media Server를 핵심 기술로 활용하여 실시간 음성 대화 훈련 플랫폼을 구현합니다.
6가지 시나리오 기반 역할극, 실시간 음성 분석, 점수화 피드백, 히스토리 관리 기능을 제공하며, React와 Spring Boot 기반으로 개발됩니다.
5주 개발 일정 내 MVP 완성을 목표로 하며, MoSCoW 방법론으로 기능 우선순위를 관리합니다.

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
| **빌드 도구** | Vite | 7.1.2 | 빠른 개발 서버 및 빌드 |
| **스타일링** | module.scss | - | 컴포넌트별 스타일 격리 |
| **통신** | WebRTC | - | 실시간 음성 통신 |

---

### 백엔드

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **언어** | Java | 17 | 백엔드 개발 언어 |
| **프레임워크** | Spring Boot | 3.5.5 | 웹 애플리케이션 프레임워크 |
| **ORM** | JPA/Hibernate | - | 데이터베이스 ORM |
| **데이터베이스** | MariaDB | - | 관계형 데이터베이스 |
| **캐시** | Redis | - | 세션 캐시 |
| **인증** | JWT | - | 토큰 기반 인증 |

---

### AI 및 음성 처리

| 구분 | 기술 | 용도 |
|------|------|------|
| **음성 대화** | GPT-4o Realtime API | 실시간 음성 대화 (사용자 ↔ AI) |
| **텍스트 분석** | GPT-4 API | 대화 분석 및 점수 계산 |
| **프롬프트** | Custom Prompts | 시나리오별 역할 설정 (6개) |
| **오디오 처리** | FFmpeg | Opus ↔ PCM 변환, 리샘플링 |

---

### 인프라 및 미디어

| 구분 | 기술 | 용도 |
|------|------|------|
| **미디어 서버** | Janus Media Server | WebRTC 미디어 처리 |
| **컨테이너** | Docker | 개발 환경 통일 |
| **CI/CD** | GitHub Actions | 자동 빌드 및 배포 |
| **웹 서버** | Nginx | 리버스 프록시, HTTPS |
| **클라우드** | AWS (EC2, S3, RDS) | 서버 호스팅, 파일 저장 |
| **STUN/TURN** | Coturn | NAT 통과 지원 |

---

## 핵심 기능

### 1. 회원 관리

**기능:**
- 회원가입 (이메일, 비밀번호)
- 로그인 (JWT 토큰 발급)
- 로그아웃
- 프로필 조회

**API:**
- `POST /api/auth/signup`
- `POST /api/auth/login`
- `GET /api/users/me`

**담당:**
- 백엔드: 왕택준
- 프론트엔드: 왕택준

---

### 2. 시나리오 관리

**기능:**
- 시나리오 목록 조회
- 시나리오 상세 조회
- 6가지 시나리오 제공
  1. 상사 보고
  2. 면접 연습
  3. 연인 갈등
  4. 부모님 연락
  5. 동료 협업
  6. 교사-학부모

**API:**
- `GET /api/scenarios`
- `GET /api/scenarios/{id}`

**담당:**
- 백엔드: 진도희
- 프론트엔드: 김경민

---

### 3. 대화 세션 관리

**기능:**
- 대화 세션 시작 (sessionId 생성)
- 시나리오 프롬프트 전달
- 세션 상태 관리 (ACTIVE, COMPLETED)

**API:**
- `POST /api/dialogues/start`

**담당:**
- 백엔드: 왕택준

---

### 4. WebRTC 실시간 음성 대화

**기능:**
- WebRTC Signaling (SDP Offer/Answer, ICE Candidates)
- 실시간 음성 송수신
- Janus Media Server 연동
- 마이크 On/Off 제어

**구현:**
- 프론트엔드: WebRTC 클라이언트
- 백엔드: WebSocket Signaling 서버

**담당:**
- 프론트엔드: 진도희
- 백엔드: 진도희

---

### 5. GPT-4o Realtime 연동

**기능:**
- GPT-4o Realtime API WebSocket 연결
- 세션 생성 및 프롬프트 전송
- 실시간 오디오 청크 송수신
- Base64 인코딩/디코딩

**담당:**
- 백엔드: 김경민

---

### 6. 오디오 변환

**기능:**
- Opus → PCM 16kHz 변환
- PCM → Opus 변환
- 리샘플링
- 100ms 단위 청킹

**담당:**
- 백엔드: 김경민

---

### 7. 실시간 음성 분석

**기능:**
- 발화 속도 계산 (WPM - Words Per Minute)
- 추임새 감지 ("음", "어", "그", "저기" 등)
- 실시간 피드백 전송 (WebSocket)

**담당:**
- 백엔드: 진도희

---

### 8. 녹음 저장

**기능:**
- Janus 녹화 플러그인 활용
- 녹음 파일 생성 (MP3 128kbps)
- AWS S3 업로드
- audioUrl 생성

**API:**
- 자동 처리 (대화 종료 시)

**담당:**
- 백엔드: 김경민

---

### 9. 피드백 생성

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
- `POST /api/feedback/save`

**담당:**
- 백엔드: 왕택준

---

### 10. 히스토리 관리

**기능:**
- 히스토리 목록 조회 (필터, 정렬)
- 히스토리 상세 조회
- 성장 통계 (점수 변화 추이)

**API:**
- `GET /api/history`
- `GET /api/history/{id}`
- `GET /api/history/stats`

**담당:**
- 백엔드: 왕택준
- 프론트엔드: 김경민

---

## MoSCoW 분류

### Must Have (필수 - MVP 포함)

1. **회원 관리**
   - 회원가입, 로그인 (JWT)

2. **시나리오 선택**
   - 6가지 시나리오 목록 및 상세

3. **실시간 음성 대화**
   - WebRTC + Janus
   - GPT-4o Realtime API

4. **음성 분석**
   - 발화 속도 (WPM)
   - 추임새 감지

5. **피드백 생성**
   - 점수화 (0~100)
   - 개선안 3가지

6. **녹음 저장**
   - S3 업로드

7. **히스토리 저장**
   - 과거 대화 기록

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
   ↓ (브라우저)
[React Frontend]
   ↓ (WebRTC)
[Janus Media Server]
   ↓ (오디오)
[Spring Boot Backend]
   ├─ [GPT-4o Realtime API] (실시간 대화)
   ├─ [GPT-4 API] (피드백 생성)
   ├─ [MariaDB] (데이터 저장)
   ├─ [Redis] (세션 캐시)
   └─ [AWS S3] (녹음 파일)
```

---

### 데이터 흐름

#### 1. 대화 시작

```
사용자: 시나리오 선택
   ↓
Frontend: POST /api/dialogues/start
   ↓
Backend: sessionId 생성, 시나리오 프롬프트 전달
   ↓
Frontend: WebRTC 연결 시작
   ↓
Janus: Room 생성
   ↓
Backend: GPT-4o 세션 시작
```

#### 2. 실시간 대화

```
사용자 음성 (마이크)
   ↓ WebRTC
Frontend
   ↓
Janus Media Server
   ↓ Opus
Backend (오디오 변환)
   ↓ PCM 16kHz
GPT-4o Realtime API
   ↓ PCM 16kHz
Backend (오디오 변환)
   ↓ Opus
Janus Media Server
   ↓ WebRTC
Frontend
   ↓
사용자 (스피커)
```

#### 3. 실시간 분석

```
대화 중 (백엔드)
   ↓
STT (Speech-to-Text)
   ↓
발화 속도 계산 (WPM)
추임새 감지 (패턴 매칭)
   ↓ WebSocket
Frontend (실시간 피드백 표시)
```

#### 4. 대화 종료 및 피드백

```
사용자: 대화 종료 버튼 클릭
   ↓
Backend: 녹음 파일 S3 업로드
   ↓
Backend: POST /api/feedback/save
   - transcript
   - audioUrl
   - wpm, fillerCount
   ↓
Backend: GPT-4 API 호출 (점수 계산)
   ↓
Backend: 개선안 3가지 생성
   ↓
Backend: Feedback 저장
   ↓
Frontend: 피드백 화면 표시
```

---

## 팀원별 담당 영역

### 왕택준 (PO/Tech Lead, Fullstack Developer)

**백엔드:**
- 인증/인가 (JWT)
- 세션 관리 (POST /api/dialogues/start)
- 피드백 생성 (POST /api/feedback/save)
- 히스토리 관리 (GET /api/history)

**AI/프롬프트:**
- 시나리오 프롬프트 6개 작성
- GPT-4 점수화 프롬프트
- Voice 파라미터 선택

**프론트엔드:**
- 로그인/회원가입 화면
- 피드백 화면
- 히스토리 화면

---

### 김경민 (공동 SM, Fullstack Developer)

**백엔드:**
- GPT-4o Realtime API 연동
- 오디오 변환 (Opus ↔ PCM)
- 녹음 파일 저장 (S3)

**인프라:**
- AWS (EC2, S3, RDS)
- Docker Compose
- Nginx 설정
- CI/CD (GitHub Actions)

**프론트엔드:**
- 시나리오 선택 화면 (공동)
- 히스토리 화면 (공동)

---

### 진도희 (공동 SM, Fullstack Developer)

**백엔드:**
- 시나리오 API (GET /api/scenarios)
- WebRTC Signaling 서버
- Janus 연동
- 실시간 음성 분석 (WPM, 추임새)

**프론트엔드:**
- 시나리오 선택 화면
- 대화 화면 (WebRTC 클라이언트)
- 실시간 피드백 UI

---

## 개발 일정

### Sprint 1 (09.29~10.06) - 프로젝트 기반 구축

**완료 항목:**
- 협업 도구 설정 (GitHub, Jira, Discord)
- 문서 체계 구축 (33개 문서)
- 기술 스택 확정
- 아키텍처 설계

---

### Sprint 2 (10.06~10.13) - DB 설계 + 배포 검증

**왕택준:**
- ERD 설계
- JWT 인증 API
- User 엔티티

**김경민:**
- Docker Compose
- Nginx 설정
- HTTPS 인증서
- 배포 환경 검증

**진도희:**
- Spring Boot 기본 설정
- Scenario 엔티티
- 시나리오 API
- Janus 설치

---

### Sprint 3 (10.13~10.20) - 백엔드 완료 + React 시작

**왕택준:**
- 세션 관리 API
- DialogueSession 엔티티
- 시나리오 프롬프트 4개 작성

**김경민:**
- GPT-4o Realtime API 연동
- 오디오 변환 기초
- React 시나리오 선택 화면

**진도희:**
- WebRTC Signaling 서버
- Janus REST API 연동
- React 프로젝트 설정

---

### Sprint 4 (10.20~10.27) - UI/UX 완성 + Infra

**왕택준:**
- 피드백 생성 API
- GPT-4 점수 계산
- 개선안 3가지 생성
- 히스토리 API
- 시나리오 프롬프트 2개 추가

**김경민:**
- 녹음 파일 S3 업로드
- CI/CD 구축
- RDS 설정
- React 히스토리 화면

**진도희:**
- 실시간 음성 분석 (WPM, 추임새)
- React 대화 화면 (WebRTC)
- React 피드백 화면
- 실시간 피드백 UI

---

### Sprint 5 (10.27~11.03) - 최적화 + 발표 준비

**왕택준:**
- 발표 자료 작성 (PPT 30장)
- 데모 영상 촬영 (3개 시나리오)
- README 최종 작성
- API 문서 정리

**김경민:**
- 성능 테스트 (동시 접속 10명)
- GPT-4o 응답 지연 최소화
- CloudWatch 모니터링
- 배포 안정화

**진도희:**
- E2E 통합 테스트
- 버그 수정
- Cross-browser 테스트
- 모바일 반응형 확인
- Sprint Retrospective

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
