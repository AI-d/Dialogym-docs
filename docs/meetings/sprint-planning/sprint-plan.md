# Sprint 1~5 전체 계획

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.06

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 팀원**: 5주간의 스프린트별 목표와 개인 작업 범위를 명확히 이해해야 하는 개발자
* **Product Owner (왕택준)**: 스프린트별 우선순위와 완료 기준을 관리하는 책임자
* **Scrum Master (김경민, 진도희)**: 각 스프린트를 주도하고 일정을 조율하는 담당자
* **신규 합류자**: 프로젝트의 전체 일정과 마일스톤을 빠르게 파악해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 trAIn 프로젝트의 5주 개발 일정을 정의합니다.
Sprint 1에서 프로젝트 기반을 구축하고, Sprint 2에서 DB 설계 및 배포 검증을 완료합니다.
Sprint 3에서 백엔드 핵심 기능(인증, AI, WebRTC)을 완성하고, Sprint 4에서 React UI/UX와 인프라를 통합합니다.
Sprint 5에서는 최적화, 발표 준비, 문서화를 진행하여 프로젝트를 마무리합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [전체 일정 개요](#전체-일정-개요)
3. [Sprint 1 (09.29~10.06) - 프로젝트 기반 구축](#sprint-1-09291006---프로젝트-기반-구축)
4. [Sprint 2 (10.06~10.13) - DB 설계 + 배포 검증](#sprint-2-10061013---db-설계--배포-검증)
5. [Sprint 3 (10.13~10.20) - 백엔드 완료 + React 시작](#sprint-3-10131020---백엔드-완료--react-시작)
6. [Sprint 4 (10.20~10.27) - UI/UX 완성 + Infra](#sprint-4-10201027---uiux-완성--infra)
7. [Sprint 5 (10.27~11.03) - 최적화 + 발표 준비](#sprint-5-10271103---최적화--발표-준비)
8. [팀원별 주요 책임](#팀원별-주요-책임)
9. [완료 기준 (DoD)](#완료-기준-dod)

---

## 문서 개요 (Overview)

본 문서는 trAIn 프로젝트의 5주 개발 일정을 스프린트 단위로 구체화합니다.
각 스프린트는 1주 단위로 운영되며, 명확한 목표와 완료 기준(DoD)을 가집니다.
팀원별 역할과 책임을 명시하여 작업 분배의 공정성과 효율성을 확보합니다.
Agile Scrum 방법론을 따르며, 매 스프린트마다 작동하는 결과물을 산출하는 것을 원칙으로 합니다.

---

## 전체 일정 개요

| Sprint | 기간 | SM | 핵심 목표 |
|--------|------|-----|-----------|
| Sprint 1 | 09.29~10.06 | 왕택준 | 프로젝트 기반 구축 |
| Sprint 2 | 10.06~10.13 | 김경민 | DB 설계 + 배포 검증 |
| Sprint 3 | 10.13~10.20 | 진도희 | 백엔드 완료 + React 시작 |
| Sprint 4 | 10.20~10.27 | 김경민 | UI/UX 완성 + Infra |
| Sprint 5 | 10.27~11.03 | 진도희 | 최적화 + 발표 준비 |

---

## Sprint 1 (09.29~10.06) - 프로젝트 기반 구축

**SM: 왕택준**
**목표: 협업 환경 설정 및 프로젝트 방향 수립**

### 완료 항목

**프로젝트 기획**
- [x] 프로젝트 주제 선정 (Dialogym - 대화 훈련 플랫폼)
- [x] 팀 이름, 프로젝트 이름, 플랫폼 이름 확정
- [x] 프로젝트 개요 문서 작성
- [x] 사례 분석 및 차별성 정리 문서
- [x] 현대 사회 언어문화 변화와 문제점 보고서

**협업 도구 설정**
- [x] GitHub Organization 생성
- [x] Repository 생성 (dialogym-be, dialogym-fe, dialogym-docs)
- [x] GitHub Wiki 구성
- [x] Jira 프로젝트 생성
- [x] Discord 채널 구성

**협업 규칙 문서화**
- [x] Git 브랜치 전략 문서
- [x] 커밋 컨벤션 가이드
- [x] Pull Request 규칙
- [x] 코드 리뷰 가이드
- [x] 팀 역할 정의 문서 (team-roles.md)

**기술 문서**
- [x] 최종 아키텍처 문서 (dialogym-final-architecture.md)
- [x] A+B 팀 MVP 분배 계획 (ab-mvp-final-plan.md)
- [x] C 팀원 가이드 (c-team-guide.md)

---

## Sprint 2 (10.06~10.13) - DB 설계 + 배포 검증

**SM: 김경민**
**목표: 데이터베이스 구조 확정 및 배포 파이프라인 검증**

### 왕택준 (PO/Tech Lead, Fullstack Developer)

**DB 설계**
- [ ] ERD 설계 완료
  - User (id, email, password, name, createdAt)
  - Scenario (id, title, prompt, voice, difficulty)
  - DialogueSession (id, userId, scenarioId, sessionId, status, startedAt)
  - Feedback (id, sessionId, audioUrl, transcript, scores, improvements)
  - History (id, userId, sessionId, completedAt, score)

**인증/인가 구현**
- [ ] JWT 기반 회원가입 API (POST /api/auth/signup)
- [ ] 로그인 API (POST /api/auth/login)
- [ ] JWT 검증 미들웨어
- [ ] User 엔티티 및 Repository

**배포 준비**
- [ ] AWS EC2 인스턴스 생성
- [ ] 도메인 연결 (dialogym.com → EC2 IP)
- [ ] Nginx 기본 설정 (Reverse Proxy)

**기능 역할**: 인증/인가 시스템 설계 및 구현, 배포 인프라 초기 구축

---

### 김경민 (SM, Fullstack Developer)

**배포 검증**
- [ ] Docker Compose 작성 (Spring Boot + MariaDB)
- [ ] Nginx 설정 완료 (80 → 8080 Reverse Proxy)
- [ ] Hello World 페이지 배포 확인
- [ ] HTTPS 인증서 발급 (Let's Encrypt)

**WebSocket 기초**
- [ ] WebSocket 설정 클래스 작성
- [ ] Signaling 메시지 구조 설계
- [ ] 기본 WebSocket 연결 테스트

**GPT-4o 연결 준비**
- [ ] OpenAI API 키 발급 및 테스트
- [ ] GPT-4o Realtime API 문서 숙지
- [ ] WebSocket 클라이언트 기본 구조

**기능 역할**: 배포 파이프라인 검증, WebSocket 인프라 구축

---

### 진도희 (Fullstack Developer)

**백엔드 기본 구조**
- [ ] Spring Boot 프로젝트 기본 설정
- [ ] MariaDB 연결 설정 (application.yml)
- [ ] JPA 설정 및 테스트
- [ ] Scenario 엔티티 및 Repository

**시나리오 API**
- [ ] GET /api/scenarios (전체 목록)
- [ ] GET /api/scenarios/{id} (상세 조회)
- [ ] 시나리오 데이터 1개 입력 ("상사 보고")

**Janus 환경 구축**
- [ ] Janus Media Server Docker 설치
- [ ] Janus 기본 설정 파일 작성
- [ ] 로컬 연결 테스트

**기능 역할**: 시나리오 관리 API, Janus 미디어 서버 환경 구축

---

### Sprint 2 완료 기준 (DoD)

- [ ] ERD 문서화 완료 및 팀 검토 승인
- [ ] `https://dialogym.com` 접속 시 "Hello Dialogym" 출력
- [ ] Postman에서 회원가입/로그인 API 200 응답
- [ ] Docker Compose로 로컬에서 전체 서비스 실행 가능
- [ ] Janus 로컬 설치 및 연결 확인

---

## Sprint 3 (10.13~10.20) - 백엔드 완료 + React 시작

**SM: 진도희**
**목표: 백엔드 3대 기능(인증, AI, WebRTC) 완성 및 프론트엔드 착수**

### 왕택준 (PO/Tech Lead, Fullstack Developer)

**세션 관리 API**
- [ ] POST /api/dialogues/start 구현
  - sessionId 생성 (UUID)
  - DialogueSession 저장
  - 시나리오/프로필 정보 조회
- [ ] DialogueSession 엔티티

**AI 프롬프트 작성**
- [ ] "상사 보고" 시나리오 프롬프트 정교화
- [ ] "면접 연습" 시나리오 프롬프트 작성
- [ ] GPT-4o voice 파라미터 선택 (echo, alloy)

**피드백 API 구조**
- [ ] POST /api/feedback/save 엔드포인트 스켈레톤
- [ ] Feedback 엔티티 설계

**기능 역할**: 세션 생명주기 관리, AI 시나리오 프롬프트 설계

---

### 진도희 (SM, Fullstack Developer)

**WebRTC Signaling 서버**
- [ ] WebSocket /ws/signaling/{sessionId} 구현
- [ ] SDP Offer/Answer 처리 로직
- [ ] ICE Candidates 중계 로직
- [ ] Janus REST API 연동 (Room 생성)

**React 프로젝트 설정**
- [ ] TailwindCSS / module.scss 설정
- [ ] 로그인 화면 UI
- [ ] 회원가입 화면 UI

**기능 역할**: WebRTC Signaling 서버 구현, React 프로젝트 기반 구축

---

### 김경민 (Fullstack Developer)

**GPT-4o Realtime 연동**
- [ ] GPT-4o WebSocket 클라이언트 구현
- [ ] 세션 생성 및 프롬프트 전송
- [ ] 오디오 청크 Base64 인코딩/디코딩
- [ ] 실시간 오디오 송수신 테스트

**오디오 변환**
- [ ] Opus → PCM 16kHz 변환 라이브러리 선택
- [ ] 리샘플링 로직 구현
- [ ] 100ms 단위 청킹 처리

**React 시나리오 선택 화면**
- [ ] 시나리오 카드 그리드 UI
- [ ] API 연동 (GET /api/scenarios)
- [ ] 시나리오 선택 상태 관리

**기능 역할**: GPT-4o 실시간 음성 연동, 오디오 처리 파이프라인

---

### Sprint 3 완료 기준 (DoD)

- [ ] Postman에서 모든 백엔드 API 200 응답
  - POST /api/auth/signup, /login
  - POST /api/dialogues/start
  - WebSocket /ws/signaling 연결
- [ ] GPT-4o와 음성 송수신 1회 이상 성공
- [ ] React 로그인 화면 + 시나리오 선택 화면 렌더링
- [ ] 프론트엔드에서 백엔드 API 호출 성공

---

## Sprint 4 (10.20~10.27) - UI/UX 완성 + Infra

**SM: 김경민**
**목표: 전체 기능 통합 및 프로덕션 배포 준비**

### 왕택준 (PO/Tech Lead, Fullstack Developer)

**피드백 생성**
- [ ] POST /api/feedback/save 완성
- [ ] GPT-4 API 호출 (점수 계산)
  - 공손도 (politeness: 1~10)
  - 명료성 (clarity: 1~10)
- [ ] 개선안 3가지 생성 (짧게/공손/따뜻)
- [ ] Feedback 저장 로직

**히스토리 API**
- [ ] GET /api/history (목록, 필터, 정렬)
- [ ] GET /api/history/stats (성장 통계)
- [ ] History 엔티티

**시나리오 추가**
- [ ] "연인 갈등" 프롬프트 작성
- [ ] "부모님 연락" 프롬프트 작성
- [ ] "동료 협업" 프롬프트 작성
- [ ] "교사-학부모" 프롬프트 작성

**기능 역할**: 피드백 생성 시스템, 히스토리 관리 API

---

### 김경민 (SM, Fullstack Developer)

**녹음 저장**
- [ ] Janus 녹화 플러그인 연동
- [ ] 녹음 파일 생성 (MP3 128kbps)
- [ ] AWS S3 버킷 생성 및 업로드 로직
- [ ] audioUrl 생성 및 반환

**CI/CD 구축**
- [ ] GitHub Actions 워크플로우 작성
  - 백엔드 빌드 (Gradle)
  - 프론트엔드 빌드 (Vite)
  - Docker 이미지 빌드 및 푸시
- [ ] 자동 배포 스크립트 (EC2)

**인프라 고도화**
- [ ] RDS (MariaDB) 생성 및 연결
- [ ] STUN/TURN 서버 설정 (Coturn)
- [ ] CloudWatch 로그 설정

**React 히스토리 화면**
- [ ] 히스토리 목록 UI
- [ ] 성장 그래프 (Recharts)
- [ ] 필터 및 정렬 기능

**기능 역할**: 녹음 파일 관리, CI/CD 파이프라인, 인프라 구축

---

### 진도희 (Fullstack Developer)

**실시간 분석**
- [ ] 발화 속도 계산 (WPM)
- [ ] 추임새 감지 알고리즘 ("음", "어", "그" 등)
- [ ] WebSocket /ws/feedback/{sessionId} 구현
- [ ] 실시간 피드백 전송 로직

**React 대화 화면**
- [ ] WebRTC 클라이언트 구현
  - getUserMedia()
  - RTCPeerConnection
  - Signaling 연동
- [ ] 대화 화면 UI (마이크 버튼, 타이머, 자막)
- [ ] 실시간 피드백 표시 (추임새 알림, 속도 게이지)

**피드백 화면**
- [ ] 점수 대시보드 UI
- [ ] 개선안 카드 UI
- [ ] 녹음 파일 재생 컴포넌트

**기능 역할**: 실시간 음성 분석, WebRTC 클라이언트, 피드백 UI

---

### Sprint 4 완료 기준 (DoD)

- [ ] 전체 기능 E2E 작동 확인
  - 로그인 → 시나리오 선택 → 대화 → 피드백 → 히스토리
- [ ] AWS 프로덕션 환경 배포 완료
- [ ] CI/CD로 자동 배포 1회 이상 성공
- [ ] 성능 테스트 (동시 접속 5명)
- [ ] 버그 리스트 작성 및 우선순위 지정

---

## Sprint 5 (10.27~11.03) - 최적화 + 발표 준비

**SM: 진도희**
**목표: 품질 향상 및 프로젝트 마무리**

### 왕택준 (PO/Tech Lead, Fullstack Developer)

**발표 준비**
- [ ] 발표 자료 작성 (PPT 30장)
  - 프로젝트 소개 (5장)
  - 기술 스택 및 아키텍처 (10장)
  - 주요 기능 시연 (10장)
  - 성과 및 개선점 (5장)
- [ ] 데모 시나리오 3개 촬영
  - 상사 보고
  - 면접 연습
  - 연인 갈등
- [ ] 발표 리허설 (2회)

**문서화**
- [ ] README 최종 작성
- [ ] API 문서 최종 검토 (Swagger)
- [ ] 사용자 가이드 작성
- [ ] 기술 문서 아카이빙

**기능 역할**: 발표 자료 총괄, 프로젝트 문서화

---

### 진도희 (SM, Fullstack Developer)

**QA 및 버그 수정**
- [ ] E2E 통합 테스트 (전체 시나리오)
- [ ] 버그 수정 (Sprint 4에서 발견된 이슈)
- [ ] Cross-browser 테스트 (Chrome, Safari, Firefox)
- [ ] 모바일 반응형 확인

**최적화**
- [ ] WebRTC 연결 안정성 개선
- [ ] 실시간 분석 성능 튜닝
- [ ] 프론트엔드 번들 사이즈 최적화

**회고 및 정리**
- [ ] Sprint Retrospective 주도
- [ ] 회고록 작성
- [ ] 팀 피드백 수집 및 정리

**기능 역할**: QA 총괄, 성능 최적화, 회고 진행

---

### 김경민 (Fullstack Developer)

**성능 테스트**
- [ ] 부하 테스트 (JMeter) - 동시 접속 10명
- [ ] API 응답 시간 측정
- [ ] GPT-4o 응답 지연 최소화 (<200ms 목표)
- [ ] 녹음 파일 업로드 속도 개선

**모니터링 구축**
- [ ] CloudWatch 대시보드 구성
- [ ] 에러 로그 모니터링 설정
- [ ] 알림 규칙 설정 (CPU 80% 이상, 에러율 5% 이상)

**배포 안정화**
- [ ] 무중단 배포 스크립트 작성
- [ ] 롤백 프로세스 문서화
- [ ] 백업 자동화 (DB, S3)

**발표 지원**
- [ ] 데모 환경 안정화
- [ ] 발표 당일 기술 지원

**기능 역할**: 성능 테스트 및 최적화, 모니터링 시스템 구축

---

### Sprint 5 완료 기준 (DoD)

- [ ] 발표 자료 완성 및 리허설 2회 완료
- [ ] 모든 버그 수정 또는 Known Issue로 문서화
- [ ] 성능 테스트 통과 (동시 접속 10명, 응답 시간 <300ms)
- [ ] 모니터링 시스템 정상 작동
- [ ] 최종 배포 완료 및 서비스 안정 운영
- [ ] 프로젝트 문서 아카이빙 완료

---

## 팀원별 주요 책임

### 왕택준 (Product Owner / Tech Lead, Fullstack Developer)
- **핵심 역할**: 제품 비전, 기술 의사결정, 인증/AI 기능
- **주요 기능**: JWT 인증, 세션 관리, GPT-4o 프롬프트, 피드백 생성
- **스프린트별 집중**:
  - Sprint 2: DB 설계, 인증 API
  - Sprint 3: 세션 API, 프롬프트 작성
  - Sprint 4: 피드백 생성, 히스토리 API
  - Sprint 5: 발표 자료, 문서화

### 진도희 (공동 Scrum Master, Fullstack Developer)
- **핵심 역할**: WebRTC 연동, 실시간 분석, QA
- **주요 기능**: Signaling 서버, 발화 속도/추임새 분석, React UI
- **스프린트별 집중**:
  - Sprint 2: Janus 설치, 시나리오 API
  - Sprint 3: Signaling 서버, React 초기화
  - Sprint 4: 실시간 분석, 대화 화면 UI
  - Sprint 5: QA, 최적화, 회고

### 김경민 (공동 Scrum Master, Fullstack Developer)
- **핵심 역할**: GPT-4o 연동, 배포/인프라, 성능 최적화
- **주요 기능**: 음성 송수신, 오디오 변환, CI/CD, 모니터링
- **스프린트별 집중**:
  - Sprint 2: 배포 검증, Docker
  - Sprint 3: GPT-4o 연동, 오디오 처리
  - Sprint 4: 녹음 저장, CI/CD
  - Sprint 5: 성능 테스트, 모니터링

---

## 완료 기준 (DoD)

### Sprint별 공통 DoD
- [ ] 계획된 기능의 90% 이상 구현 완료
- [ ] 코드 리뷰 완료 및 PR 병합
- [ ] Sprint Review 진행 및 데모
- [ ] Sprint Retrospective 완료 및 개선점 도출
- [ ] 다음 스프린트 백로그 정리

### 프로젝트 최종 DoD
- [ ] 6개 시나리오 모두 작동
- [ ] 프로덕션 배포 완료 (HTTPS)
- [ ] CI/CD 파이프라인 정상 작동
- [ ] 모니터링 시스템 구축
- [ ] 성능 테스트 통과
- [ ] 발표 완료 (30분)
- [ ] 기술 문서 아카이빙
- [ ] README 최종 업데이트

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.06 | 왕택준 | 최초 작성 |
