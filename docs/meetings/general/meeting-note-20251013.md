# 팀 AId 회의록 (10/13)

**담당자:** [진도희](https://github.com/dohee-jin)  
**일시:** 2025.10.13  
**장소:** 학원  
**참석자:** 왕택준(팀장), 김경민, 진도희

> 목적: Sprint 3 통합 킥오프

---

## 1. 오늘 다룬 의제
1. Sprint 2 완료 상황 최종 검토
2. Sprint 3 목표 및 일정 확인
3. 역할 분담 및 일정 확인

---

## 2. 주요 논의

### 2-1. Sprint 2 완료 상황 최종 검토

**완료**

* **왕택준(팀장)**  
  * 논리 ERD 설계: User, Feedback, History
  * 엔티티 클래스 작성
  * Spring Boot 프로젝트 생성 및 기본 설정
  * application.yml 설정 (DB 연결, JPA 설정)
  * User 엔티티 및 Repository 작성
  * POST /api/auth/signup 구현
  * POST /api/auth/login 구현
  * JWT 토큰 생성 로직
  * 세션 관리 로직 설계
  * API 문서 정리 (Swagger)
  * 통합 테스트

* **김경민**  
  * 논리 ERD 설계: DialogueSession, Transcript
  * 엔티티 클래스 작성
  * DialogueSession, Transcript 엔티티 및 Repository 작성
  * WebSocketConfig 클래스 작성
  * Signaling 메시지 구조 설계
  * 기본 WebSocket 연결 테스트
  * AWS EC2 인스턴스 생성
  * 도메인 연결 (dialogym.com → EC2 IP)
  * Nginx 설치 및 기본 Reverse Proxy 설정
  * Docker Compose 작성 (Spring Boot + MariaDB)
  * Hello World 페이지 배포
  * Nginx 80 → 8080 Reverse Proxy 최종 확인
  * HTTPS 인증서 발급 (Let's Encrypt)
  * Docker Compose 최종 검증

* **진도희**  
  * 논리 ERD 설계: Scenario
  * 엔티티 클래스 작성
  * Scenario 엔티티 및 Repository 작성
  * GET /api/scenarios 구현 (전체 목록)
  * GET /api/scenarios/{id} 구현 (상세 조회)
  * 시나리오 테스트 데이터 1개 입력 ("상사 보고")
  * OpenAI API 키 발급 및 테스트
  * 시나리오 API 최종 테스트

* **공통**
  * ERD 문서화 완료 및 팀 전체 검토 승인
  * 전체 엔티티 클래스 작성 완료 (User, Scenario, DialogueSession, Feedback, History, Transcript)
  * 전체 Repository 인터페이스 작성 완료
  * https://dialogym.com 접속 시 페이지 확인 가능 (Hello World 또는 기본 페이지)
  * Postman에서 회원가입/로그인 API 200 응답 확인
  * GET /api/scenarios API 정상 작동
  * Docker Compose로 로컬에서 전체 서비스 실행 가능
  * HTTPS 인증서 발급
  * Sprint Review (완성된 기능 데모)
  * Sprint Retrospective (좋았던 점 / 개선할 점 / 액션 아이템)

**미완료**

* **공통**
  * Janus 로컬 설치 및 연결 확인 

**결론**: Sprint 2 필수 사항 모두 완료. WebRTC/Janus 관련은 Sprint 3에서 본격 진행.

### 2-3. Sprint 3 목표 및 일정 확인

* **백엔드 3대 기능 완성**
  * 세션 관리 API: POST /api/dialogues/start (왕택준)
  * WebRTC Signaling 서버: WebSocket /ws/signaling/{sessionId} (김경민)
  * 피드백 생성 API: POST /api/feedback/save (왕택준)
  
* **WebRTC & AI 통합**
  * Janus REST API 연동 (김경민) - 아직 서류 미수령
  * GPT-4o Realtime API 연동 (진도희) - 아직 서류 미수령
  * 오디오 변환 파이프라인: Opus → PCM 16kHz (진도희)
  
* **분석 & 피드백**
  * 실시간 분석: 발화 속도(WPM), 추임새 감지 (김경민)
  * 피드백 생성: GPT-4 점수화, 개선안 생성 (왕택준)
  
* **AI 프롬프트 작성 (6개 총 완료)**
  * 상사 보고, 면접 연습, 연인 갈등, 부모님 연락 (김경민 4개)
  * 동료 협업, 교사-학부모 (진도희 2개)
  
* **프론트엔드 React 초기 구축**
  * 로그인/회원가입 페이지
  * 시나리오 선택 페이지
  * 대화 화면 (마이크 버튼, 타이머, 종료)
  * 기본 라우팅 및 상태 관리
  
* **배포 & 문서**
  * 프로덕션 배포 (https://dialogym.com)
  * API 설계서 (Swagger)
  * Signaling 메시지 프로토콜 문서
  * 프롬프트 엔지니어링 가이드

* **Sprint 3 기간**: 2025.10.13 (월) ~ 2025.10.20 (월) - 7일
  * SM: 진도희
  * 목표: 백엔드 핵심 기능 + 프론트엔드 초기 구축

* **⚠️ 주의사항**
  * WebRTC/Janus: 아직 기술 전달받지 못함 → MVP로 축소 예정
  * GPT-4o Realtime: 기술 결정 후 진행 (음성 vs 텍스트)
  * 실시간 피드백 WebSocket 제거 (녹음 종료 후 한 번에 분석)
  * UI 디자인 최소화 (기능 구현만, 스타일링은 Sprint 4)


### 2-4. 기술 스택 및 협업 도구 확정

**application.yml 관리 전략 (변경사항)**
* ❌ 기존: dev, local, 일반, 운영 4가지
* ✅ **변경**: 일반(기본), local(개발), 운영(프로덕션) 3가지로 통합
  * `application.yml` (기본 설정)
  * `application-local.yml` (로컬 개발 환경)
  * `application-prod.yml` (운영 환경)

**협업 도구 적극 도입 (이번 주차부터)**
1. **JIRA**: Epic 단위로 관리 (Sprint 3 에픽 생성)
2. **GitHub Wiki**: 문서 집약 (기술 스택, 아키텍처, API 명세 등)
3. **GitHub Discussion**: 기술 논의 및 의사결정 기록

### 2-5. 위키 사용

* **논의 기록/의사결정/문서 링크 집약**을 위해 팀 위키 사용 합의
* 문서 현황과 히스토리 일원화
* GitHub Wiki를 중심으로 관리

---

## 3. 결정 사항

1. **yml 관리**: **3가지로 통합** (일반, local, prod)
   * `application.yml` (기본 설정)
   * `application-local.yml` (로컬 개발 환경)
   * `application-prod.yml` (운영 환경)

2. **협업 도구**: **JIRA, GitHub Wiki, GitHub Discussion 적극 도입** (이번 주차부터)
   * JIRA: Epic 단위로 관리
   * GitHub Wiki: 문서 집약
   * GitHub Discussion: 기술 논의 및 의사결정 기록

3. **WebRTC/Janus**: **아직 전달받지 못함 → Sprint 3 초반 기술 결정 필요**

---

## 4. 역할 및 문서 담당

### **C팀: 왕택준(팀장)** (11일)

**백엔드 (5일)**
* **세션 관리 API** (2일)
  * POST /api/dialogues/start 구현
  * DialogueSession 엔티티 저장
  * UUID 기반 sessionId 생성

* **피드백 생성 API** (2.5일)
  * POST /api/feedback/save 구현
  * 간단한 수식으로 점수 계산
  * Feedback 엔티티 저장
  * GPT-4 점수화는 MVP 제외 (간단한 수식만 사용)

* **기타** (0.5일)
  * API 문서 (Swagger) 업데이트
  * 에러 핸들링

**프론트엔드 (6일)**
* **React 프로젝트 기초** (1일)
  * Vite + React 초기화
  * TailwindCSS 또는 module.scss 설정
  * 라우팅 (react-router-dom)
  * 디렉토리 구조 설계

* **기본 페이지 스켈레톤** (2.5일)
  * 로그인/회원가입 페이지 (폼 검증 기본만)
  * 시나리오 선택 페이지 (리스트 UI)
  * 대화 화면 (마이크 버튼, 타이머, 종료 버튼)

* **상태 관리 & API 연동** (2.5일)
  * JWT 토큰 관리
  * Context API 기본 구조
  * API 연동 (login, signup, scenarios)

### **A팀: 김경민 (11일)**
* **WebRTC Signaling 서버** (3.5일)
  * WebSocket /ws/signaling/{sessionId} 구현
  * Janus REST API 연동 (서류 미수령, 추후 결정)
  * SDP/ICE 메시지 중계
  * 메모리 저장 방식

* **WebRTC 클라이언트** (2일)
  * React 대화 화면에서 WebRTC 구현
  * getUserMedia(), RTCPeerConnection 생성
  * Signaling 서버 연결

* **실시간 분석** (2.5일)
  * 발화 속도 계산 (WPM)
  * 추임새 감지 (한국어 패턴: "음", "어", "그" 등)
  * 실시간 업데이트

* **AI 프롬프트 작성** (2일)
  * 상사 보고
  * 면접 연습
  * 연인 갈등
  * 부모님 연락

### **B팀: 진도희** (11일 + SM 역할)
* **GPT-4o Realtime API 연동** (3.5일)
  * OpenAI Realtime API 세션 생성 (서류 미수령, 추후 결정)
  * WebSocket 연결 및 메시지 처리
  * 음성 송수신 (기술 결정 후)
  * 세션 관리

* **오디오 변환 파이프라인** (2.5일)
  * Opus → PCM 16kHz 변환 (서류 미수령, 추후 결정)
  * 100ms 청킹
  * Base64 인코딩/디코딩
  * 오디오 렌더링 (Web Audio API)

* **AI 프롬프트 작성** (2일)
  * 동료 협업
  * 교사-학부모

* **SM 역할** (전주간)
  * 일일 스탠드업 (오전 10시)
  * 중간 점검 (저녁 6시)
  * 이슈/블로커 즉시 해결
  * 리스크 관리

---

## 5. 액션 아이템

### 공통 (오늘 중)

* [ ] 위키에 문서 목차/템플릿 게시 및 담당자 태깅
* [ ] JIRA에 Sprint 3 Epic 생성
* [ ] GitHub Discussion에서 기술 논의 시작

### C팀: 왕택준(팀장)

* [ ] React/Vite 프로젝트 초기화 및 GitHub 저장소 생성
* [ ] 프로젝트 디렉토리 구조 설계
* [ ] 라우팅 구조 설계 (/login, /signup, /scenarios, /dialogue/{id})
* [ ] POST /api/dialogues/start 구현 시작
* [ ] JIRA 이슈 등록 (세션 API, 피드백 API, 로그인, 회원가입, 시나리오 페이지)

### A팀: 김경민

* [ ] WebRTC 기본 개념 숙지 (SDP, ICE, TURN)
* [ ] Signaling 메시지 프로토콜 설계 완료
* [ ] 프롬프트 4개 초안 작성 및 GitHub Wiki 업로드
* [ ] WebSocket /ws/signaling/{sessionId} 구현 시작
* [ ] JIRA 이슈 등록 (Signaling, WebRTC, 분석, 프롬프트 x4)

### B팀: 진도희 (SM)

* [ ] SM 일일 스탠드업 및 중간 점검 일정 확정
* [ ] 협업 도구 세팅 (Discord, GitHub Discussion)
* [ ] 기술 결정 대기 사항 정리 (WebRTC/Janus, GPT-4o, 오디오)
* [ ] OpenAI API 계정 준비 (기술 결정 후)
* [ ] GPT-4o Realtime API 문서 상세 숙지
* [ ] 오디오 라이브러리 선택 및 테스트 계획 수립
* [ ] JIRA Epic 생성 및 기본 이슈 틀 작성


---

## 6. 리스크 & 대응
- **WebRTC/Janus 서류 미수령**: 기술 구현 지연 가능 → MVP 전략으로 축소, 추후 기술 전달 시 본격 진행

- **오디오 처리 복잡도**: 레이턴시 최적화 필수 (<200ms) → 라이브러리 선택 및 CPU 모니터링

- **프롬프트 품질 미달**: 한국식 경어와 상황 반영 필수 → 반복 테스트 및 팀 피드백 수집

- **일정 압박 (7일 안에 완료)**: MVP 전략으로 핵심만 구현 → 기능/비기능 명확히 분리, 우선순위 엄격 운영

- **팀 간 의존성**: A팀 Signaling → C팀 WebRTC 클라이언트, B팀 GPT-4o → A팀 프롬프트 → SM의 적극적 조율 필수

**대응 방안**
* 일일 스탠드업으로 의존성 즉시 공유
* 기술 결정은 최대한 조기에 (10/13~10/14)
* MVP 우선순위 엄격히 운영
* SM(진도희)의 적극적 중재 및 일정 관리

---

## 7. 다음 회의
- **일시**: 2025.10.14 (화) 또는 2025.10.15 (수)
- **주제**: 기술 결정 및 중간 점검
- **아젠다**: 
  * WebRTC/Janus 기술 전달 및 기술 결정
  * 오디오 처리 라이브러리 선택 확정
  * 프롬프트 초안 검토
  * 의존성 명시 및 API 명세 최종 확정
