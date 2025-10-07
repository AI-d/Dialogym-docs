# 팀 AId 회의록

**담당자:** [진도희](https://github.com/dohee-jin)

**일시**: 2025.10.01

**장소**: 학원

**참석자**: 왕택준(팀장), 김경민, 진도희

---
## 2. 오늘 다룬 의제

* 최종 아키텍처 및 역할 분담 확정
* 음성 AI 리서치 결과 공유 및 기술 스택 논의
* 5주 개발 일정 상세 검토
* 1주차 환경 설정 작업 분담

---

## 3. 주요 논의

### 3-1. 최종 아키텍처 및 역할 분담 확정
* **팀 구성 재편**: 기존 사람 A/B/C → **A+B 팀(2명)**, **C 팀(1명)**으로 통합
  - A+B 팀(김경민, 진도희): 시나리오 선택 + 실시간 음성 대화 + WebRTC + GPT-4o Realtime API 연동
  - C 팀(왕택준): 인증 + 피드백 + 히스토리 + 프로필 관리 + 시나리오 프롬프트 작성

* **기술 아키텍처 확정**:
  ```
  사용자 브라우저 ←WebRTC→ 백엔드 서버 ←WebSocket→ GPT-4o Realtime API
  ```
  - GPT-4o Realtime API는 STT+LLM+TTS 통합 처리 (3단계 파이프라인 불필요)
  - GPT-4o Realtime API 도입 실패 시 3단계 파이프라인 적용
  - WebRTC 미디어 서버로 Kurento 또는 Janus 사용 결정
  - 오디오 포맷: Opus → PCM 16kHz 변환 후 GPT-4o 전송

### 3-2. 음성 AI 리서치 결과 공유
* **잔도희**: 음성 AI 리서치 문서 공유
  - `gpt-4o` 또는 `gpt-4o-mini` 사용 필요
  - STT → LLM → TTS 3단계 파이프라인 문제 → **GPT-4o Realtime API 사용으로 해결**
  - WebRTC 구현 필요성 확인: MediaRecorder + REST 업로드는 실시간성 부족

* **김경민**: WebRTC 기술 스택 조사 결과
  - Kurento vs Janus 비교: 둘 다 STUN/TURN 지원, Kurento가 문서화 우수
  - Signaling 프로토콜은 WebSocket 사용, SDP Offer/Answer 교환 필요

* **공통**: GPT-4 프롬프트 엔지니어링 리서치

### 3-3. 5주 개발 일정 상세 검토
* **1주차 환경 설정**: Docker, Git, DB, API 명세서, ERD, 코딩 컨벤션
* **2주차 기본 구조**: WebRTC 기본 연결, 인증 API, 시나리오 UI
* **3주차 핵심 기능**: GPT-4o 연동, 피드백 API, 히스토리 UI
* **4주차 고급 기능**: 실시간 분석, 점수 계산, TTS 생성, 프로필 분석
* **5주차 통합 테스트**: E2E 테스트, 데모 촬영, 배포 준비

* **작업량 분석**: 
  - A+B 팀: 난이도 ⭐⭐⭐⭐⭐ (WebRTC + GPT-4o 연동 복잡도 높음)
  - C 팀: 난이도 ⭐⭐⭐⭐ (화면 5개, API 5개 그룹이지만 초반 시간 여유)
  - **결론**: C 팀이 2~3주차에 여유 생기면 A+B 팀 지원 가능

### 3-4. 팀 간 연결 지점 명확화
* **대화 시작 시**: C 팀 → sessionId 생성 → A+B 팀 전달 → WebRTC Room 생성
* **대화 진행 중**: A+B 팀 → GPT-4o 실시간 처리 → 피드백 WebSocket 전송
* **대화 종료 시**: A+B 팀 → 녹음 파일 + transcript 생성 → C 팀 API 호출

---

## 4. 결정 사항

* **팀 구성**: A+B 팀(2명), C 팀(1명)으로 최종 확정
* **기술 스택**: 
  - 프론트: React 18 + Vite + JavaScript + TailwindCSS + WebRTC
  - 백엔드: Spring Boot 3 + Java 17 + JPA
  - DB: MariaDB 
  - AI: GPT-4o Realtime API, GPT-4
  - 미디어: Kurento Media Server (1순위), Janus (2순위)
  - 인프라: Docker, Nginx, GitHub Actions, AWS S3

* **GPT-4o Realtime API 사용**: STT+LLM+TTS 통합 처리로 3단계 파이프라인 불필요
* **WebRTC 아키텍처**: 사용자 브라우저 ←SRTP→ Kurento ←WebSocket→ GPT-4o

---

## 5. 공통 작업

### 회의 중 공동 합의·진행 사항
* 5주 일정 전체 리뷰 및 각 주차별 마일스톤 확인

### 회의 후 공통 TODO
* API 명세서 초안 구조 합의 (Swagger 사용)
* 데이터베이스 ERD 주요 테이블 구조 논의
* Git 저장소 브랜치 전략 문서 작성 (main, develop, feature/*)
* 코딩 컨벤션 문서 작성 (변수명, 함수명, 들여쓰기 규칙)
* Commit 메시지 규칙 정립
* 환경 변수 관리 방식 결정 (.env.example 작성)

---

## 6. 개별 담당 (순서: 팀장, 팀원 (가나다 순))

* **왕택준 (팀장, C 팀, 풀스택 담당)**
  * Jira 초기 설정, 디스코드, Github(이슈 라벨, 템플릿) 리펙토링
  * 로그인/회원가입 화면 와이어프레임 (Figma)
  * 피드백/히스토리/프로필 관리 화면 와이어프레임 (총 5개 화면)
  * 시나리오 프롬프트 6개 초안 작성 (직장: 상사 보고/동료 협업, 면접: 자기소개/압박 면접, 가족, 연애)
  * GPT-4 API 키 발급 및 프롬프트 테스트
  * 점수화 기준 문서 작성 (발화 속도, 추임새, 공손도, 명료성 세부 기준)

* **김경민, 진도희 (A+B 팀, 풀스택 담당)**
  * WebRTC 아키텍처 상세 다이어그램 작성
  * Kurento/Janus 설치 가이드 문서 작성
  * Signaling 프로토콜 정의 문서 (SDP, ICE 포맷)
  * GPT-4o API 키 발급 및 테스트 환경 구축
  * STUN/TURN 서버 조사 및 설정 방안 작성
  * 시나리오 선택 화면 와이어프레임 (Figma)
  * 대화 화면 UI 목업 (음량 인디케이터, 자막, 타이머)
  * getUserMedia() 마이크 권한 테스트 코드 작성
  * RTCPeerConnection 기본 연결 샘플 구현

---

## 7. 리스크 및 이슈

* **WebRTC 구현 복잡도**: A+B 팀 작업량이 많고 난이도가 높아 일정 지연 가능성
  - **대응**: 2주차에 기본 연결 테스트 완료 목표, 막히면 C 팀 지원 요청
  
* **GPT-4o Realtime API 응답 지연**: 200ms 이하 목표이나 네트워크 상황에 따라 변동 가능
  - **대응**: 로딩 UI 및 재시도 로직 구현, 타임아웃 설정

* **GPT-4o Realtime API 도입 가능 여부**: GPT-4o RealTime API 도입 가능 여부 불투명
  - **대응**: 도입 불가능 할 시 GPT-4o 모델 도입, 3단계 파이프라인 도입

* **C 팀 초반 대기 시간**: A+B 팀의 API가 완성되기 전 프론트 개발 제약
  - **대응**: 목 데이터(Mock Data) 사용해 선행 개발, API 명세서 기반 작업

* **시나리오 프롬프트 일관성**: GPT-4 응답이 매번 달라질 수 있음
  - **대응**: 프롬프트 여러 번 테스트 후 안정적인 버전 선정, temperature 파라미터 조정

---

## 7. 차기 회의 계획

* **일정**: 2025.10.02 (목)
* **예상 의제**:
  * 1주차 개별 작업 진행 상황 공유
  * API 명세서 초안 논의
  * 데이터베이스 ERD 논의
  * 코딩 컨벤션 및 Commit 메시지 규칙 검토

---

## 부록: 참고 문서

* 팀원별 역할 요약본: [dialogym-roles-summary.md](https://github.com/AI-d)
* 최종 아키텍처 문서: [dialogym-final-architecture.md](https://github.com/AI-d)
* 음성 AI 리서치: [음성ai_리서치.md](https://github.com/AI-d)
