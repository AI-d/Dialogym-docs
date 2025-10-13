# 팀 AId 회의록

**담당자:** [진도희](https://github.com/dohee-jin)

**일시**: 2025.10.08

**장소**: 온라인

**참석자**:  왕택준(팀장), 김경민(SM), 진도희  

> 본 회의는 Sprint 2(10.07~10.12) 진행상황 점검 및 리포지토리 구현 전 준비 작업 확정을 목표로 진행함.

---

## 1. 오늘 다룬 의제

1. 3인 ERD 통합 결과 확인 및 확정
2. Janus/GPT Realtime 운영키 저장 위치(MVP) 반영
3. 외래키·연관관계·CASCADE 및 인덱스 전략 확정
4. 담당자별 Repository/테스트 작업 계획
5. 첨부 문서 공유 및 기준 문서화

---

## 2. 주요 논의

### 2-1. 3인 ERD 통합

* 인증/인가 엔티티 7개 + 비즈니스 로직 엔티티 2개(Feedback/History), 시나리오 1개, 대화 세션 2개(Transcript 포함)로 **총 12개 엔티티** 통합 완료.
* DialogueSession–Transcript 구조와 상태/타임스탬프, 오디오/리얼타임 메트릭스 필드 확인.

### 2-2. Janus 운영키 반영 (MVP)

* **DialogueSession**에 nullable 운영키 4개 추가: `janus_room_id`, `janus_user_feed_id`, `janus_bot_feed_id`, `ai_realtime_session_id`  
  → Sprint 3에서 **분리 테이블**로 전환 검토. 
* 인덱스: `idx_janus_room_id`로 방 추적 용이성 확보. 

### 2-3. 외래키·관계·인덱스 전략

* 모든 엔티티 간 연관관계 및 **ON DELETE CASCADE/RESTRICT** 정책 확정. 
* 사용자/세션/히스토리/시나리오/약관 등 주요 조회 패턴 기준 인덱스 확정. 

### 2-4. 팀원별 담당 엔티티 확인

* **왕택준**: 인증/인가 7개 + 비즈니스 로직 2개(Feedback, History) 총 9개. 
* **김경민**: DialogueSession, Transcript 2개. 
* **진도희**: Scenario 1개. 

---

## 3. 결정 사항

* 통합 ERD v1.0을 **Sprint 2 최종 확정본**으로 채택. 
* MVP에서는 Janus/GPT Realtime 운영키를 **DialogueSession**에 보관(Nullable), **Sprint 3**에서 분리 검토. 
* DDL 생성은 통합 ERD 문서의 물리 스키마 정의를 기준으로 진행. 

---

## 4. 공통 작업

### 회의 중 합의·진행

* 외래키/관계/인덱스 전략 일괄 확정 및 체크리스트 반영. 
* 엔티티 기준 코드 레퍼런스는 **통합 엔티티 모음** 문서를 단일 소스 오브 트루스로 사용. 

### 회의 후 공통 TODO

* DDL 스크립트 1차 생성 및 로컬 DB 반영(테스트 포함). 
* Repository 인터페이스 생성·단위 테스트 코드 착수(각 담당 영역). 

---

## 5. 개인별 액션 아이템(10.08)

* **왕택준**
  * Spring Boot 프로젝트 생성 및 `application.yml` 기본 설정(DB/JPA)  
  * 담당 엔티티 Repository 작성 및 단위 테스트 수행. 

* **김경민**
  * DialogueSession/Transcript Repository 작성 및 단위 테스트. 

* **진도희**
  * Scenario Repository 작성 및 단위 테스트.

---

## 6. 리스크 & 확인 필요 사항

* Janus/GPT Realtime 운영키 **분리 시점** 및 마이그레이션 전략 수립 필요(Sprint 3 선결 과제). 
* MariaDB JSON 필드(메트릭/스코어) 버전 호환성 및 조회 최적화 검토. 

---

## 7. 다음 회의

* **일시**: 2025.10.09 (목) 시간 미정
* **아젠다**: DDL 반영 결과 점검, Repository 테스트 현황 공유, API 1차 구현 범위 확정

---

## 8. 첨부 문서
* **통합 ERD 최종본** - [(물리 ERD, FK, 인덱스 전략): v1.0  — 기준 문서](https://github.com/AI-d/Dialogym-docs)
* **김경민 담당 - DialogueSession & Transcript ERD/엔티티** - [세션·전사 구조 상세](https://github.com/AI-d/Dialogym-docs)
* **통합 엔티티 클래스 모음** — [12개 엔티티/Enum/패키지 구조/설정 안내](https://github.com/AI-d/Dialogym-docs)