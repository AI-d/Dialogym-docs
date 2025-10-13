# Sprint 2 회고 (2025.10.07 ~ 2025.10.12)

**담당자 (Author)**: [김경민](https://github.com/minee0505)

**검토자 (Reviewer / PO·SM)**: [김경민](https://github.com/minee0505)

**작성일 (Created)**: 2025.10.13

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## Scrum 정보

**Scrum Master**: [김경민](https://github.com/minee0505)
**Sprint 기간**: 2025.10.07 ~ 2025.10.12

---

## 대상 독자 (Intended Audience)

* **전체 팀원**: Sprint 2에서 수행된 작업과 다음 스프린트 방향을 이해해야 하는 구성원
* **Product Owner**: 스프린트 성과를 평가하고 다음 우선순위를 결정하는 책임자
* **Scrum Master**: 팀 프로세스 개선점을 도출하고 적용하는 담당자
* **신규 합류자**: 팀의 협업 방식과 개선 이력을 빠르게 파악해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

Sprint 2는 ERD 설계와 백엔드 인프라 구축에 집중한 스프린트였습니다. 총 33개의 백로그를 완료했습니다.
ERD 통합 설계, JPA 엔티티 구현, Repository 계층 완성, WebSocket 설정, HTTPS 배포, OAuth2 설정, 인증/인가 도메인 설계 등 핵심 인프라를 구축했습니다.

---

## 목차 (Table of Contents)

1. [Sprint 목표](#sprint-목표)
2. [주요 성과](#주요-성과)
3. [잘된 점 (What Went Well)](#잘된-점-what-went-well)
4. [아쉬운 점 (What Didn't Go Well)](#아쉬운-점-what-didnt-go-well)
5. [개선 방안 (What to Improve)](#개선-방안-what-to-improve)
6. [팀원별 기여](#팀원별-기여)
7. [팀 피드백](#팀-피드백)
8. [Sprint 지표](#sprint-지표)
9. [다음 Sprint 목표](#다음-sprint-목표)
10. [변경 이력](#변경-이력)

---

## Sprint 목표

### 계획된 목표
1. ERD 문서화 완료 및 팀 전체 검토 승인
2. 전체 엔티티 클래스 작성 완료
3. 전체 Repository 인터페이스 작성 완료
4. https://dialogym.com 접속 시 페이지 확인 가능
5. Postman에서 회원가입/로그인 API 200 응답 확인
6. GET /api/scenarios API 정상 작동

### 달성 여부
- ERD 문서화 완료 및 팀 전체 검토 승인 (50% - 향후 webrtc 관련한 엔터티 추가 예정, 추가 후 ERD 문서 완료 예정)
- 전체 엔티티 클래스 작성 완료 (100%)
- 전체 Repository 인터페이스 작성 완료 (100%)
- https://dialogym.com 접속 시 페이지 확인 가능 (100% - 배포 담당이 김경민으로 고정됨에 따라 도메인이 https://dialogym.shop 변경됨 접속 확인함)
- Postman에서 회원가입/로그인 API 200 응답 확인 (75% - 로컬 로그인은 안됨, 소셜 로그인은 완료됨)
- ☑GET /api/scenarios API 정상 작동 (100%)

**종합 달성률**: 87%

---

## 주요 성과

### 1. 데이터베이스 설계 및 구현
- ERD 통합 설계 (User, Scenario, DialogueSession, Feedback, History, Transcript)
- JPA 엔티티 16개 구현 (핵심 도메인 6개 + 인증/인가 도메인 6개 + Enum 6개)
- JPA Auditing 활성화 (createdAt, updatedAt 자동 관리)
- Repository 인터페이스 12개 구현
- Repository 단위 테스트 구현

### 2. 백엔드 인프라 구축
- Spring Boot 프로젝트 기본 설정 완료
- application.yml 환경별 설정 구조 설계 (local, prod)
- build.gradle 의존성 관리 체계화
- WebSocket 설정 및 SignalingHandler 구현
- GlobalExceptionHandler 구현
- API 공통 응답 구조 설계

### 3. 배포 환경 구축
- AWS EC2 인스턴스 생성 및 설정
- 도메인 연결 (dialogym.shop)
- Nginx Reverse Proxy 설정
- HTTPS 인증서 발급 (Let's Encrypt)
- Docker Compose 최종 검증
- Hello World 페이지 배포 및 접속 테스트 성공

### 4. OAuth2 및 인증/인가 시스템 설계
- OAuth2 설정 (카카오, 구글, 네이버)
- Gmail SMTP 계정 생성
- 인증/인가 도메인 엔티티 9개 설계 (User, UserProfile, SocialAccount, RefreshToken, EmailVerification, PasswordReset, LoginHistory, UserTerms, Terms)
- Enum 확장성 개선 (Provider, UserStatus, TermsType)
- 데이터 정리 스케줄러 구현
- 약관 초기화 로직 구현

### 5. 문서화 체계 정립
- Jira 템플릿 작성 및 워크플로우 표준화
- GitHub Discussions 템플릿 작성
- 백엔드 JavaDoc 및 Swagger 주석 규칙 정리
- 프론트엔드 JSDoc 및 Storybook 문서화 표준화
- 디렉토리 구조 표준화 (프론트엔드, 백엔드)
- Backend PR Template 동기화
- Docs, Backend, Frontend Repository별 Wiki 운영 방식 정의

### 6. 코드 리팩토링
- 백엔드 디렉토리 구조 도메인 중심으로 리팩토링
- DialogueSessionRepository JPQL 쿼리를 네이티브 쿼리로 리팩토링
- Repository 테스트 환경 설정 개선
- 환경 변수, YML, Gradle 의존성 통합 리팩토링
- Scenario API 개선

---

## 잘된 점 (What Went Well)

### 1. 계획 대비 높은 생산성
33개 백로그를 완료하며 계획된 6개 목표를 초과 달성했습니다. 팀원 모두가 적극적으로 참여하고 서로 협력하며 효율적으로 작업을 진행했습니다.

### 2. 체계적인 ERD 설계 프로세스
각자 도메인별로 ERD를 설계한 후 통합 회의를 통해 최종 ERD를 확정하는 방식이 효과적이었습니다. 개별 작업과 협업의 균형이 잘 맞았습니다.

### 3. 인프라 구축 성공
HTTPS 배포, Docker Compose, OAuth2 설정 등 복잡한 인프라 작업을 예정보다 빠르게 완료했습니다.

### 4. 문서화 문화 정착
Jira 템플릿, PR 템플릿, Wiki 운영 방식, 주석 규칙 등을 표준화하여 장기적인 프로젝트 유지보수 기반을 마련했습니다.

### 5. 확장 가능한 인증 시스템 설계
OAuth2 소셜 로그인, 이메일 인증, 비밀번호 재설정, 약관 동의 등 실제 서비스에 필요한 인증 기능을 종합적으로 설계했습니다. 엔티티 구조가 확장 가능하고 유연하게 설계되었습니다.

---

## 아쉬운 점 (What Didn't Go Well)

### 1. 중간 점검 미실시
10.08(수) 저녁, 10.10(금) 저녁에 예정된 중간 점검이 이루어지지 않았습니다. 진행 상황을 실시간으로 공유하고 조율할 기회를 놓쳤습니다.

### 2. 회원가입/로그인 로컬 미완성
계획된 인증 API 구현이 Sprint 2에서 완료되지 못했습니다. 엔티티 설계에 시간이 더 소요되었고, Sprint 3로 이월되었습니다.

### 3. Janus WebRTC 환경 구축 지연
Janus Media Server 조사와 로컬 설치가 계획대로 진행되지 못했습니다. WebRTC 기반 실시간 대화 기능 구현을 위한 준비가 부족했습니다.

---

## 개선 방안 (What to Improve)

### 1. 중간 점검 정례화
**문제**: 계획된 중간 점검 미실시로 실시간 조율 부족
**개선안**:
- Sprint 중간 점검을 필수 일정으로 설정
- 점검 내용: 작업 진행률, 블로커, 도움 필요 여부
- Discord 음성 채널에서 30분 이내로 진행

### 2. WebRTC 기술 학습 시간 확보
**문제**: Janus 및 WebRTC 환경 구축 지연
**개선안**:
- Sprint 3에서 WebRTC 학습 및 Janus 설치를 우선순위로 설정
- Janus 로컬 테스트 환경 구축 완료를 DoD에 포함

### 3. 협업 도구 적극 활용
**문제**: Discord, Jira, GitHub 등 협업 도구 활용 미흡
**개선안**:
- Jira에서 작업 상태를 실시간으로 업데이트 (In Progress, Done)
- Discord에 작업 시작/완료 시 간단히 공유
- GitHub PR에 리뷰 요청 시 Discord에 멘션
- 질문이나 블로커 발생 시 즉시 Discord에 공유

---

## 팀원별 기여

### 왕택준 (PO/Tech Lead, Fullstack Developer)
**담당 작업**:
- 인증/인가 설계 및 구현
- OAuth2 설정 및 Gmail SMTP 계정 생성
- 백엔드 디렉토리 구조 리팩토링
- 데이터 정리 스케줄러 및 약관 초기화 구현
- 환경 변수, YML, Gradle 의존성 통합 리팩토링

**성과**:
- 확장 가능한 인증 시스템 아키텍처 설계
- 프로젝트 전반의 문서화 수준 향상
- 백엔드 코드베이스 구조 개선

**개선점**:
- API 구현보다 설계에 시간을 많이 투자했으므로 실행 속도 개선 필요

### 김경민 (SM, Fullstack Developer)
**담당 작업**:
- WebSocket 설정 및 SignalingHandler 구현
- AWS EC2 인스턴스 생성 및 설정
- 도메인 연결 (dialogym.shop)
- Nginx Reverse Proxy 설정
- HTTPS 인증서 발급 (Let's Encrypt)
- Docker Compose 최종 검증
- Hello World 페이지 배포

**성과**:
- 배포 환경 구축 완료 (HTTPS 포함)
- WebSocket 기반 실시간 통신 인프라 구축
- 프로젝트의 DevOps 기반 마련

**개선점**:
- Scrum Master로서 중간 점검을 주도하지 못함
- Sprint 진행 상황 모니터링 강화 필요

### 진도희 (Fullstack Developer)
**담당 작업**:
- Scenario 엔티티 설계 및 구현
- Scenario Repository 구현 및 테스트
- Scenario API 구현 (GET /api/scenarios, GET /api/scenarios/{id})
- Scenario API 테스트 및 개선
- OpenAI API 키 발급 및 테스트 준비

**성과**:
- Scenario API 완성 및 정상 작동 확인
- 시나리오 관리 기능 기반 마련
- OpenAI 연동 준비 완료

**개선점**:
- 기업에서의 서류 제공이 지연됨에 따라 Janus WebRTC 환경 구축이 지연되었으므로 Sprint 3에서 우선 처리 필요

---

## 팀 피드백

### 팀워크
- **긍정**: 팀원 모두가 적극적으로 참여하고 서로 협력하는 분위기가 형성되었습니다. 기술적 어려움이 있을 때 서로 도움을 요청하고 공유하는 문화가 자리 잡았습니다.
- **개선**: 중간 점검 미실시로 팀 전체의 진행 상황을 실시간으로 파악하기 어려웠습니다. 정례 회의를 통해 팀워크를 더욱 강화할 필요가 있습니다.

### 커뮤니케이션
- **긍정**: Discord를 통한 비동기 커뮤니케이션이 활발했습니다. 질문과 답변이 신속하게 이루어졌습니다.
- **개선**: 중요한 의사결정이나 기술 선택 시 음성/화상 회의를 통한 동기 커뮤니케이션이 부족했습니다. 복잡한 주제는 텍스트보다 음성으로 논의하는 것이 효율적입니다.

### 일정 관리
- **긍정**: Sprint 목표 대비 87% 달성률을 기록하며 전반적으로 일정을 잘 지켰습니다. 배포 환경 구축 등 예상보다 빠르게 완료된 작업들이 많았습니다.
- **개선**: 인증 API 구현이 지연되었고, 중간 점검 일정을 지키지 못했습니다. Sprint 중간에 일정을 재점검하고 조율하는 프로세스가 필요합니다.

### 프로세스
- **긍정**: Jira를 통한 백로그 관리, GitHub PR 프로세스, 문서화 체계 등 개발 프로세스가 체계화되었습니다.
- **개선**: Daily Scrum, 중간 점검 등 Scrum 프로세스를 더 엄격하게 준수할 필요가 있습니다. 계획한 프로세스를 실제로 실행하는 것이 중요합니다.

---

## Sprint 지표

### 완료율
- **계획된 작업**: 6개 목표
- **완료된 작업**: 5.2개 (87%)
- **미완료 작업**: 0.8개 (인증 API 부분, ERD 부분)

### 생산성
- **작성된 코드**: 약 15,000 LOC (Lines of Code) 추정
- **완료된 기능**: 33개 백로그
- **해결된 버그**: 5건 (JPQL 쿼리 이슈, Repository 테스트 설정, Enum 확장성 등)

### 품질
- **코드 리뷰 건수**: 33건 (모든 PR)
- **발견된 버그**: 5건
- **테스트 커버리지**: Repository 계층 80% 이상

### 팀 만족도 (자체 평가)
- **왕택준**: 8/10
- **김경민**: 8/10
- **진도희**: 8/10

---

## 다음 Sprint 목표 (Sprint 3)

### 주요 목표
1. **세션 관리 API 완성** (왕택준)
    - POST /api/dialogues/start 구현
    - DialogueSession 엔티티 저장 로직
    - Janus room 자동 생성 연동

2. **WebRTC Signaling 서버 구축** (김경민)
    - WebSocket /ws/signaling/{sessionId} 구현
    - SDP Offer/Answer 처리 및 ICE Candidates 중계
    - Janus REST API 연동 (Room 생성, 참가자 조인)
    - WebRTC 클라이언트 구현 (React)

3. **GPT-4o Realtime API 연동** (진도희)
    - OpenAI Realtime API 세션 생성 및 WebSocket 연결
    - 음성 송수신 파이프라인 구현
    - 오디오 변환 (Opus → PCM 16kHz)
    - 실시간 오디오 청킹 및 Base64 인코딩

4. **실시간 분석 기능** (김경민)
    - 발화 속도 계산 (WPM)
    - 추임새 감지 알고리즘
    - WebSocket /ws/feedback/{sessionId} 실시간 전송

5. **피드백 생성 API** (왕택준)
    - POST /api/feedback/save 구현
    - GPT-4 기반 점수화 (공손도, 명료성)
    - 개선안 생성 (3가지 버전)

6. **AI 프롬프트 작성** (김경민 4개 + 진도희 2개)
    - 상사 보고, 면접 연습, 연인 갈등, 부모님 연락 (김경민)
    - 동료 협업, 교사-학부모 (진도희)

### 완료 기준 (DoD)

**백엔드 필수**
- [ ] POST /api/dialogues/start 구현 완료 및 테스트
- [ ] WebSocket /ws/signaling/{sessionId} 구현 완료
- [ ] WebSocket /ws/feedback/{sessionId} 구현 완료
- [ ] Janus REST API 연동 완료
- [ ] GPT-4o Realtime API 연동 완료
- [ ] 오디오 변환 파이프라인 완성 (Opus → PCM)
- [ ] POST /api/feedback/save 구현 완료
- [ ] 6개 시나리오 프롬프트 작성 완료

**프론트엔드 필수**
- [ ] 로그인/회원가입 페이지 생성 (기본 구조, API 연동)
- [ ] 시나리오 선택 페이지 생성 (리스트 UI, GET API 연동)
- [ ] 대화 화면 페이지 생성 (WebRTC 연동, 마이크/타이머/종료 버튼)
- [ ] React 라우팅 전체 흐름 구현
- [ ] 프로덕션 배포 완료 (https://dialogym.com)

**테스트 필수**
- [ ] E2E 테스트 성공 (로그인 → 시나리오 선택 → Signaling 연결)
- [ ] Postman에서 모든 백엔드 API 200 응답
- [ ] GPT-4o와 실시간 음성 송수신 1회 이상 성공
- [ ] 오디오 레이턴시 <200ms 달성

**문서화 필수**
- [ ] API 명세서 (Swagger) 업데이트
- [ ] Signaling 메시지 프로토콜 문서 작성
- [ ] 프롬프트 엔지니어링 문서 작성

**프로세스 필수**
- [ ] Daily Scrum 출석률 80% 이상
- [ ] 중간 점검 매일 실시 (총 6회)

### 개선 사항 적용
- Daily Scrum 정례화 (매일 오전 10시, 15분)
- 작업 분배 균형 개선 (스토리 포인트 사전 산정, 중간 재분배)
- 중간 점검 정례화 (매일 저녁 6시, 30분 이내)
- WebRTC 및 GPT-4o Realtime 기술 학습 시간 확보
- API 개발 우선순위 조정 (핵심 기능 먼저)
- 협업 도구 적극 활용 (Jira 실시간 업데이트, Discord 즉시 공유)

---

## 변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.13 | 김경민 | 최초 작성 |