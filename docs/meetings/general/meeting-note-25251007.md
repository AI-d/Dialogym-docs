# 팀 AId 회의록

**담당자:** [진도희](https://github.com/dohee-jin)

**일시**: 2025.10.07

**장소**: 온라인

**참석자**:  왕택준(팀장), 김경민(SM), 진도희  

> 본 회의는 Sprint 2(10.07~10.12) 계획 수립 및 ERD·엔티티 작업 분담을 목표로 진행함. 근거 문서: *Sprint 2 Planning - ERD 설계 및 엔티티 작업*.

---

## 1. 오늘 다룬 의제

1. Sprint 2 범위, 기간 확정(10.07~10.12)  
2. ERD 설계 원칙 및 작업 분담  
3. 엔티티 클래스 1차 작성 일정 및 통합 회의 일정  
4. 주간 일정(일자별 오너십·산출물) 합의  
5. DoD(완료 기준) 합의

---

## 2. 주요 논의

### 2-1. ERD 설계 및 엔티티 작업 원칙

* **도메인별 분담 설계**로 진행(각자 책임 소유)  
* 엔티티 클래스도 **각자 작성** 후 통합 시 일관성 정리  
* **내일(10.08) 회의 전까지** 논리 ERD + 엔티티 초안 제출  
* **내일(10.08) 09:00** 통합 회의에서 최종 ERD 확정

### 2-2. 역할·담당 엔티티

* **왕택준**: User, Feedback, History  
  * 이슈: JWT 필요 여부, Feedback–History 관계(1:1 vs 1:N), `scores/improvements` JSON vs 정규화

* **김경민**: DialogueSession, Transcript(선택)  
  * 이슈: DialogueSession `status` 값 정의, 실시간 분석 데이터 저장 위치, 녹음 파일 URL 소관

* **진도희**: Scenario  
  * 이슈: `voice`(onyx/echo/nova), `difficulty`(E/M/H), `category` 정의

### 2-3. 네이밍·공통정책 체크리스트(통합 회의에서 확정)

* 테이블/컬럼 네이밍 규칙(Pascal/snake/camel)  
* 공통 필드(`createdAt`, `updatedAt`)와 PK 타입(Long vs UUID)  
* Soft Delete(`deletedAt` vs `isDeleted`)  
* FK 제약(ON DELETE CASCADE/SET NULL)  
* 관계 가설:  
  - User ← DialogueSession (1:N), Scenario ← DialogueSession (1:N), DialogueSession ← Feedback (1:1?/1:N?), User ← History (1:N)

### 2-4. 주간 일정(요약)

* **10.07**: ERD 설계·엔티티 생성(개별)  
* **10.08**: 09:00 통합 회의 → 최종 ERD, Spring Boot 기본설정, Repo 작성  
* **10.09**: API 1차 구현 (Auth/Scenario/WebSocket 기초)  
* **10.10**: API 마감·배포 준비(EC2·Nginx·Docker 착수)  
* **10.11**: 인프라 구축(Swagger, 도메인 연결, Docker Compose)  
* **10.12**: 배포 검증, Sprint Review/Retro

---

## 3. 결정 사항

* Sprint 2 목표는 **DB 설계 + 배포 검증**으로 확정  
* ERD/엔티티 **개별 설계 후 통합** 방식 채택  
* **10.08(수) 09:00** 통합 회의 일정 확정  
* DoD 합의:  
  * ERD 문서화·팀 승인  
  * 엔티티/Repository 전량 작성  
  * 회원가입/로그인 API 200 응답  
  * `/api/scenarios` 정상 동작  
  * `dialogym.com` 기본 페이지 노출(Hello World OK)

---

## 4. 공통 작업

### 회의 중 합의·진행

* ERD 체크리스트 항목 수집  
* 주간 일정/오너십 확정  
* 인프라·배포는 **김경민** 리드, 인증/세션은 **왕택준** 리드, 시나리오·Janus·AI 연동은 **진도희** 리드

### 회의 후 공통 TODO
* 각자 논리 ERD/엔티티 초안 **10.08 오전 회의 전 디스코드에 업로드**  
* 통합 회의 자료: 모델 관계도, FK, 결정 필요 이슈 목록화

---

## 5. 개인별 액션 아이템

* **왕택준**
  * User/Feedback/History 엔티티 설계 및 Repo 작성  
  * JWT 토큰 흐름 초안/미들웨어 설계  
  * 10.09~10.10 회원가입/로그인 API 구현·테스트

* **김경민**
  * DialogueSession/Transcript 엔티티·Repo·테스트  
  * WebSocketConfig 초안 및 기본 연결 테스트  
  * 10.10~10.12 EC2, 도메인 연결, Nginx 리버스 프록시, Docker Compose 착수

* **진도희**
  * Scenario 엔티티·Repo·시드 데이터  
  * `/api/scenarios` 목록/상세 API 구현 및 통합 테스트  
  * Janus Docker 설치 가이드/기본 설정 초안

---

## 6. 리스크 & 확인 필요 사항

* Feedback–History 관계 및 점수/개선안 **JSON vs 정규화** 결정 지연 시 스키마 변경 비용  
* Transcript 저장 전략(실시간 분석 데이터와의 경계)  
* 네이밍/공통 필드/Soft Delete 정책 확정 필요(10.08 회의 안건)

---

## 7. 다음 회의

* **일시**: 2025.10.08 (수) 09:00  
* **아젠다**: 최종 ERD 확정, 네이밍/공통정책 결정, 초기 Repo 병합 전략