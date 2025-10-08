# 팀 AId 회의록

**담당자:** [진도희](https://github.com/dohee-jin)

**일시**: 2025.09.30

**장소**: 학원

**참석자**: 왕택준(팀장), 김경민, 진도희

---
## 2. 오늘 다룬 의제

* 유저플로우 논의, 문서화
* 워크플로우 논의, 문서화

---

## 3. 주요 논의

### 3-1. 유저플로우 논의, 문서화
* 서비스의 핵심 여정을 **사람 A(초안 생성) → 사람 B(피드백·재평가) → 사람 C(저장·히스토리·프로필 변환)**으로 확정.  
  - 사람 A: 시나리오 선택 → 의도 입력 → AI 초안 3개 제안 → 초안 선택  
  - 사람 B: 점수(공손도/명료성/길이) 확인, 개선 포인트, 최대 2회 재평가  
  - 사람 C: 최종안 저장, 히스토리/전후 비교, 프로필 기반 재생성  
  - 세부 화면 흐름과 저장 데이터 정의는 **유저 플로우 상세 문서** 기준으로 진행. fileciteturn0file0

### 3-2. 워크플로우 논의, 문서화
* **협업 도구 역할 구분** 채택: Discord(실시간), Discussions(기술 논의/기록), Jira(작업관리), Wiki(참조문서), Docs repo(공식문서).  

* **아이디어 → 논의 → 공식문서화 → 작업 생성 → 개발/PR → 참조문서 갱신 → 회고**의 엔드투엔드 플로우 적용.  

* **Smart Commit** 사용 원칙(`PROJECT-XX #comment/#time/#done` 등)과 **Docs repo 디렉토리 구조(meeting-notes/, decisions/, design/ …)** 채택.

* **GitHub Discussions 운영 규칙** 정립: Org(=Docs) 단위는 공지/일반/회고, BE/FE 단위는 공지/Architecture/Q&A/Troubleshooting. Discussions는 **Draft 공간**이며, 확정사항은 ADR/회의록/Wiki로 승격.

---

## 4. 결정 사항

* 사용자 여정(사람 A/B/C)과 **재평가 최대 2회** 제약을 그대로 채택.

* 협업 도구 역할 및 **전체 워크플로우/Smart Commit/Docs 디렉토리 구조** 채택.

* Discussions **카테고리 구성과 운영 원칙** 채택, 확정사항은 ADR·회의록·Wiki로 승격.  

---

## 5. 공통 작업

### 회의 중 공동 합의·진행 사항
* 유저플로우 베이스라인 확정 및 화면/데이터 항목 1차 정리. 

* 협업 규칙과 문서 저장 위치·작성 타이밍 합의. 

### 회의 후 공통 TODO
* 비즈니스 로직 구체화 (점수 산식, 재평가 한도, 프로필 변환 파라미터)  

* 기능별 Must/Should/Could/Won’t 정리 (MoSCoW)  
* 와이어프레임 제작 (시나리오 선택/초안선택/피드백/히스토리/프로필 변환)  

* Docs repo 골격 생성: `docs/meeting-notes/`, `docs/decisions/`, `docs/design/` 등 초기 트리 구성 

* Discussions 스레드 개설: 아키텍처/상태관리/DB 스키마/Q&A/Troubleshooting 가이드라인에 맞춰 등록 

* Jira 프로젝트/보드 구성(Backlog→To Do→In Progress→Code Review→Done) 및 이슈 계층(Epic/Story/Task/Subtask) 세팅 

---

## 6. 개별 담당

* **왕택준 (팀장)**  
  * Jira 프로젝트/보드/워크플로우 초기 설정 (컬럼·WIP·이슈 템플릿)  
  * Discord 공지/데일리/긴급-이슈 채널 구성  

* **김경민**  
  * 유저플로우 상세 문서 반영 및 보완(저장 데이터/점수 항목) 

* **진도희**  
  * Docs repo 초기화 및 **회의록/ADR 템플릿** 추가, 오늘 회의록 커밋  

---

## 7. 차기 회의 계획

* **일정**: 2025.10.01  
* **예상 의제**:  
  * 비즈니스 로직 구체화(점수 산식/재평가 규칙/프로필 파라미터)  
  * 기능별 Must/Should/Could/Won’t 정리 공유  
  * 와이어프레임 1차안 리뷰 & 확정  
  * Docs/Discussions/Jira 초기 세팅 검수

---

## 부록: 참고 문서

* 유저 플로우 상세 문서: [dialogym-userflow.md](https://github.com/AI-d)
* 협업 도구 워크플로우 가이드: [collaboration-guide.md](https://github.com/AI-d)
* GitHub Discussions 운영 가이드: [discussions-guide.md](https://github.com/AI-d)
