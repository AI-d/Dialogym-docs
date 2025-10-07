# Sprint 1 회고 (2025.09.29 ~ 2025.10.07)

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.06

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## Scrum 정보

**Scrum Master**: 왕택준
**Sprint 기간**: 2025.09.29 ~ 2025.10.6

---

## 대상 독자 (Intended Audience)

* **전체 팀원**: Sprint 1에서 수립된 협업 기반과 다음 스프린트 방향을 이해해야 하는 구성원
* **Product Owner (왕택준)**: 초기 구조의 효과성을 평가하고 개선점을 도출하는 책임자
* **신규 합류자**: 프로젝트의 초기 설정 과정과 협업 체계를 빠르게 파악해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

Sprint 1에서는 프로젝트 아이디어(Dialogym - 대화 훈련 플랫폼) 확립과 협업 인프라 구축에 집중했습니다.
총 38개의 문서와 가이드를 작성하여 팀 협업의 기반을 마련했으며, GitHub Organization/Repository 3개, Jira, Discord를 통합하여 협업 환경을 완성했습니다.
문서 중심 협업 체계(Discord → Wiki → Docs Repository)를 수립하고, Git 브랜치 전략과 커밋 컨벤션 등 표준화된 개발 프로세스를 정의했습니다.
wiki-snapshots 아카이브 체계를 통해 Draft 버전 히스토리를 보존하는 문서 관리 시스템을 구축했습니다.

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
1. 프로젝트 아이디어 확립 및 주제 선정
2. 협업 도구 설정 (GitHub, Jira, Discord)
3. 문서 체계 구축 및 협업 규칙 정의
4. 개발 프로세스 표준화 (Git, PR, 코드 리뷰)

### 달성 여부
- ✅ 프로젝트 아이디어 확립 (100%)
- ✅ 협업 도구 설정 (100%)
- ✅ 문서 체계 구축 (100%)
- ✅ 개발 프로세스 표준화 (100%)

**종합 달성률**: 100%

---

## 주요 성과

### 1. 프로젝트 기획 완료

**핵심 산출물:**
- 프로젝트 주제: Dialogym (대화 훈련 플랫폼)
- 팀 이름: AId
- 플랫폼 이름: trAIn

**기획 문서 (5개):**
- project-overview.md: 개인 경험에서 시작된 프로젝트 배경
- problem-analysis.md: 현대 사회 커뮤니케이션 문제 분석
- concept-definition.md: "대화도 훈련이 필요하다" 철학 정립
- competitive-analysis.md: 7개 경쟁 서비스 분석 및 차별점
- feature-specification.md: 기술 스택 및 기능 명세

---

### 2. 협업 인프라 구축

**GitHub:**
- Organization 생성: `dialogym-org`
- Repository 3개 생성:
  - `dialogym-be` (백엔드)
  - `dialogym-fe` (프론트엔드)
  - `dialogym-docs` (문서)
- GitHub Wiki 초기 구성
- GitHub Discussions 활성화

**Jira:**
- 프로젝트 생성: `trAIn Development`
- 백로그 초기 설정
- Sprint 보드 구성
- Epic 및 Story 구조 정의

**Discord:**
- 서버 생성 및 채널 구조 설계
  - 일반
  - 개발-질문
  - 긴급-이슈
  - 알림
- 역할 및 권한 설정
- 알림 규칙 수립

---

### 3. 문서 체계 수립 (총 38개 문서)

#### 협업 프로세스 문서 (18개)

**협업 가이드 (5개):**
- collaboration-guide.md: 문서 작성 3가지 흐름 정의
- discord-guide.md
- jira-guide.md
- wiki-guide.md
- discussions-guide.md

**개발 프로세스 (10개):**
- branching-strategy.md
- commit-convention.md
- git-workflow.md
- pull-request-guide.md
- code-review-guide.md
- label-guide.md
- conflict-resolution.md
- git-hooks.md
- multi-env-workflow.md
- advanced-git-techniques.md

**배포 프로세스 (3개):**
- deployment-backend.md
- deployment-frontend.md
- rollback-guide.md

#### 프로젝트 기획 문서 (5개)
- project-overview.md
- problem-analysis.md
- concept-definition.md
- competitive-analysis.md
- feature-specification.md

#### 팀 관리 문서 (2개)
- team-roles.md: PO 1명 + 공동 SM 2명 구조
- team-tech-stack.md: 팀원별 기술 담당 영역

#### 개발 계획 문서 (3개)
- sprint-plan.md: 5주 전체 계획
- ab-mvp-final-plan.md: A+B 팀 MVP 분배
- c-team-guide.md: C 팀원을 위한 핵심 개념 가이드

#### 템플릿 (4개)
- document-template.md
- document-template-guide.md
- sprint-retrospective-template.md
- sprint-retrospective-guide.md

#### 기타 문서 (6개)
- README.md
- CONTRIBUTING.md
- 테스트 가이드 3개
- 트러블슈팅 가이드 1개

---

### 4. 문서 흐름 체계 정립

**3가지 문서 작성 흐름:**

1. **긴급 문서** (즉시 반영)
   ```
   Discord → Docs Repository
   ```

2. **일반 문서** (검토 후 반영)
   ```
   Discord → Wiki (v0.x Draft) → Docs Repository (v1.0 Approved)
       ↓
   docs/archive/wiki-snapshots/ (Draft 버전 보존)
   ```

3. **기술 문서** (회의 + 토론 필요)
   ```
   Discord → Discussions → Wiki (v0.x Draft) → Docs Repository (v1.0)
       ↓
   docs/archive/wiki-snapshots/ (Draft 버전 보존)
   ```

---

### 5. 디렉토리 구조 설계

```
docs/
├── archive/
│   ├── deprecated/           # 폐기된 문서
│   └── wiki-snapshots/       # Wiki Draft 버전 보존
├── decisions/                # 의사결정 기록 (ADR)
├── design/                   # 설계 문서
│   ├── api/
│   ├── architecture/
│   ├── database/
│   ├── infrastructure/
│   └── ui/
├── meetings/                 # 회의록 및 회고
│   ├── general/
│   ├── personal-retrospective/
│   ├── progress-log/
│   ├── sprint-planning/
│   └── sprint-retrospective/
├── processes/                # 프로세스 가이드
│   ├── collaboration/
│   ├── deployment/
│   ├── development/
│   └── testing/
├── reports/                  # 보고서
├── requirements/             # 요구사항
│   └── policies/
├── team/                     # 팀 정보
└── troubleshooting/          # 트러블슈팅
```

---

## 잘된 점 (What Went Well)

### 1. 명확한 프로젝트 방향 수립

프로젝트 아이디어(Dialogym)가 개인적 경험에서 출발하여 팀 전원의 공감을 얻었습니다.
기술 스택과 아키텍처 방향이 초기에 명확히 정립되어 이후 개발 방향 설정이 수월해졌습니다.
팀원 간 공통 인식이 형성되어 프로젝트의 정체성이 확립되었습니다.

**구체적 성과:**
- 5개의 체계적인 기획 문서 완성
- 경쟁사 분석을 통한 차별점 명확화
- 6가지 핵심 시나리오 정의

---

### 2. 체계적인 문서 중심 협업

38개의 문서를 통해 협업 기반을 철저히 마련했습니다.
문서 흐름(Discord → Wiki → Docs Repository)이 명확히 정의되어 혼란이 없습니다.
템플릿 제공으로 문서 작성 장벽이 낮아졌습니다.

**구체적 성과:**
- 3가지 문서 작성 흐름 정의
- wiki-snapshots 아카이브 체계 수립
- 표준 템플릿 4개 제공

---

### 3. 통합된 협업 도구 환경

GitHub, Jira, Discord가 유기적으로 연결되었습니다.
Smart Commit 등 자동화 기반을 마련했습니다.
팀원 전원이 도구 사용법을 습득했습니다.

**구체적 성과:**
- Repository 3개 + Wiki + Discussions 통합
- Jira 프로젝트 구조 완성
- Discord 채널 체계 확립

---

### 4. 표준화된 개발 프로세스

Git 브랜치 전략이 명확히 정의되었습니다.
커밋 컨벤션, PR 규칙, 코드 리뷰 가이드가 수립되었습니다.
일관된 개발 문화 조성이 가능해졌습니다.

**구체적 성과:**
- Git 관련 가이드 10개 작성
- 배포 프로세스 3개 문서화
- 테스트 전략 수립

---

### 5. 역할 기반 책임 분배

PO, SM, Developer 역할이 명확히 구분되었습니다.
Sprint별 SM 순환 배정으로 리더십을 분산했습니다.
팀원별 기술 담당 영역을 명시하여 작업 충돌을 최소화했습니다.

**구체적 성과:**
- team-roles.md: 역할 정의 완료
- team-tech-stack.md: 기술 담당 명시
- 5주 Sprint별 SM 배정 완료

---

## 아쉬운 점 (What Didn't Go Well)

### 1. 문서 작성에 과도한 시간 소요

실제 개발 착수 전 문서 작업 기간이 9일 소요되었습니다.
일부 문서 간 내용 중복이 발생했습니다 (Git 관련 가이드 10개).
문서 검토 및 승인 프로세스가 부재하여 품질 편차가 존재합니다.

**문제 상황:**
- 계획: 1주 (7일)
- 실제: 9일 (약 2일 지연)
- Git 관련 문서가 과도하게 세분화됨

---

### 2. 자동화 미완성

GitHub Actions CI/CD 파이프라인이 미구축되었습니다.
Jira ↔ GitHub Smart Commit 연동 테스트가 미완료되었습니다.
Discord 알림 자동화가 부분적으로만 구현되었습니다.

**문제 상황:**
- CI/CD: 0% (Sprint 2에서 진행)
- Smart Commit: 테스트 안 됨
- Discord Webhook: 50% 구현

---

### 3. 실습 및 검증 부족

작성된 가이드(Git, PR 등)에 대한 팀 실습이 없었습니다.
협업 도구 통합 테스트를 실시하지 못했습니다.
문서 기반 시뮬레이션이 부재했습니다.

**문제 상황:**
- Git 브랜치 전략 실습: 0회
- PR 생성 연습: 0회
- Jira 티켓 생성 연습: 0회

---

### 4. 일정 관리 미흡

Sprint 1이 약 2일 지연되었습니다 (예정: 10.05 → 실제: 10.07).
Daily Scrum이 미실시되어 진행 상황 공유가 부족했습니다.
작업 우선순위 변경에 대한 명확한 기준이 부재했습니다.

**문제 상황:**
- 목표 완료일: 10.05
- 실제 완료일: 10.07
- Daily Scrum: 0회

---

### 5. 팀원 간 작업 불균형

왕택준(PO/SM)이 대부분의 문서를 작성했습니다.
김경민, 진도희의 Sprint 1 기여도가 낮았습니다.
역할 분배가 실질적으로 작동하지 않았습니다.

**문제 상황:**
- 왕택준: 38개 문서 중 35개 작성 (92%)
- 김경민: 문서 작성 0개
- 진도희: 문서 작성 0개

---

## 개선 방안 (What to Improve)

### 1. 문서 통합 및 효율화

**문제**: 문서 중복 및 참조 경로 불일치
**개선안**:
- `docs/README.md`에 전체 문서 인덱스 추가
- 유사 주제 문서 통합 (Git 관련 10개 → 5개로 축소)
- 문서 간 상호 참조 링크 명시
- 문서 검토 체크리스트 도입
- 최소 2명 이상 검토 후 Approved 전환

---

### 2. 자동화 강화

**문제**: 수동 작업 비중 높음
**개선안**:
- Sprint 2에서 GitHub Actions 기본 워크플로우 구축
  - 백엔드 빌드 자동화
  - 프론트엔드 빌드 자동화
  - 자동 배포 스크립트
- Jira Smart Commit 테스트 및 규칙 문서화
  - `TRAIN-123 #comment 작업 완료` 형식 테스트
  - 자동 상태 전환 확인
- Discord Webhook 연동으로 PR/Commit 알림 자동화
  - PR 생성 시 Discord 알림
  - 코드 리뷰 요청 시 알림
  - 병합 완료 시 알림

---

### 3. 협업 프로세스 실습

**문제**: 이론만 있고 실습 없음
**개선안**:
- Sprint 2 시작 전 팀 워크샵 실시 (2시간)
  - Git 브랜치 전략 실습 (30분)
    - feature 브랜치 생성 연습
    - 병합 연습
  - PR 생성 및 코드 리뷰 시뮬레이션 (30분)
    - 실제 코드로 PR 생성
    - 리뷰 코멘트 작성 연습
  - Jira 티켓 생성 및 Smart Commit 테스트 (30분)
    - Epic, Story, Task 생성
    - Smart Commit 동작 확인
  - Discord 채널 활용 연습 (30분)
- 가상 시나리오 기반 협업 연습

---

### 4. Daily Scrum 정례화

**문제**: 일일 진행 상황 공유 부재
**개선안**:
- Sprint 2부터 매일 오전 10시 Daily Scrum 실시 (15분)
- Discord 음성 채널 활용
- 3가지 질문 형식
  1. 어제 한 일
  2. 오늘 할 일
  3. 장애물 (도움 필요한 것)
- 작업 현황 Jira 보드에 실시간 반영
- Scrum Master(김경민)가 주도

---

### 5. 작업 분배 개선

**문제**: 왕택준에게 작업 집중
**개선안**:
- Sprint 2부터 백로그를 3등분하여 명확히 할당
  - 왕택준: 인증/세션/피드백
  - 김경민: GPT-4o/오디오/인프라
  - 진도희: WebRTC/Janus/시나리오
- 팀원별 책임 영역을 Jira Epic으로 관리
- 상호 리뷰 체계 강화 (본인 외 최소 1명 리뷰 필수)
- SM(김경민, 진도희)이 적극적으로 작업 분배 주도
- 문서 작성도 역할 분담
  - 왕택준: 기술 문서
  - 김경민: 인프라 문서
  - 진도희: 테스트 문서

---

### 6. Sprint Planning 강화

**문제**: Sprint 목표가 추상적
**개선안**:
- Sprint 2 Planning 시 SMART 목표 설정
  - **Specific**: 구체적인 완료 기준 명시
    - 예: "API 5개 완성" (어떤 API인지 명시)
  - **Measurable**: 정량적 지표 설정
    - 예: "ERD 10개 테이블", "문서 3개"
  - **Achievable**: 팀 역량 고려한 현실적 계획
  - **Relevant**: 프로젝트 목표와 직결
  - **Time-bound**: 명확한 마감일 지정 (일 단위)
- 각 목표마다 담당자와 마감일 명시
- 버퍼 타임 20% 확보 (예상치 못한 이슈 대비)

---

## 팀원별 기여

### 왕택준 (PO/SM/Tech Lead, Fullstack Developer)

**담당 작업**:
- 프로젝트 아이디어 도출 및 문서화 (5개)
- GitHub Organization 및 Repository 생성 (3개)
- 협업 도구 설정 (Jira, Discord)
- 문서 체계 설계 및 38개 문서 작성
- Git 브랜치 전략 및 커밋 컨벤션 정의
- 팀 역할 및 기술 스택 문서 작성
- Sprint 계획 수립 (5주)
- 문서 흐름 체계 정립 (3가지 흐름)
- wiki-snapshots 아카이브 구조 설계

**성과**:
- 프로젝트 전체 방향 설정 완료
- 협업 인프라 완전 구축
- 표준화된 프로세스 정립
- 38개 문서 작성 (전체의 92%)

**개선점**:
- 문서 작성 시 팀원 참여 유도 필요
- 작업 위임을 통한 부담 분산
- 더 명확한 작업 분배 필요

---

### 김경민 (Fullstack Developer)

**담당 작업**:
- 협업 도구 학습 및 테스트
- 문서 검토 및 피드백 제공 (일부)

**성과**:
- 협업 도구 사용법 숙지
- Sprint 2 SM 역할 준비
- Jira, Discord 활용법 이해

**개선점**:
- Sprint 1 문서 작성 참여 부족 (0개)
- 보다 적극적인 의견 제시 필요
- 자료 조사 및 공유 활동 필요

---

### 진도희 (Fullstack Developer)

**담당 작업**:
- 협업 도구 학습 및 테스트
- 문서 검토 및 피드백 제공 (일부)

**성과**:
- 협업 도구 사용법 숙지
- Sprint 3 SM 역할 준비
- GitHub, Jira 활용법 이해

**개선점**:
- Sprint 1 문서 작성 참여 부족 (0개)
- 보다 적극적인 의견 제시 필요
- 기술 조사 및 자료 공유 활동 필요

---

## 팀 피드백

### 팀워크
- **긍정**: 초기 설정 단계에서 역할이 명확히 정의됨
- **개선**: Sprint 1은 왕택준이 주도했으나, Sprint 2부터는 전원이 균등하게 기여해야 함

### 커뮤니케이션
- **긍정**: Discord와 Jira를 통한 실시간 커뮤니케이션 가능 환경 구축
- **개선**: Daily Scrum 미실시로 일일 진행 상황 공유 부족

### 일정 관리
- **긍정**: 전반적으로 계획대로 진행됨 (달성률 100%)
- **개선**: 약 2일 지연 발생 (10.05 → 10.07), 버퍼 타임 확보 필요

### 프로세스
- **긍정**: 문서 중심 협업 체계가 명확히 수립됨 (3가지 흐름)
- **개선**: 자동화 도구(GitHub Actions, Smart Commit) 미완성

---

## Sprint 지표

### 완료율
- **계획된 작업**: 4개 대분류 목표
- **완료된 작업**: 4개 (100%)
- **미완료 작업**: 0개

### 생산성
- **작성된 문서**: 38개
- **설정된 도구**: 3개 (GitHub, Jira, Discord)
- **정의된 프로세스**: 5개 (Git, PR, 코드 리뷰, 배포, 테스트)
- **설계된 시스템**: 1개 (문서 관리 시스템)

### 품질
- **문서 품질**: 중상 (일부 중복 및 미검증 내용 존재)
- **협업 도구 통합도**: 중 (연동 테스트 미완료)
- **프로세스 완성도**: 상 (명확한 가이드 제공)

### 팀 만족도 (자체 평가)
- **왕택준**: 7/10 (문서 작업 부담 높음, 하지만 방향 명확)
- **김경민**: 6/10 (Sprint 1 기여 부족, Sprint 2 준비됨)
- **진도희**: 6/10 (Sprint 1 기여 부족, Sprint 3 준비됨)

---

## 다음 Sprint 목표 (Sprint 2)

### 주요 목표
1. **데이터베이스 설계 완료**
   - ERD 작성 및 팀 검토
   - 10개 테이블 정의
     - User, Scenario, DialogueSession
     - Feedback, History
     - CounterpartyProfile, Transcript
     - 등

2. **배포 환경 검증**
   - AWS EC2 인스턴스 생성
   - Docker Compose 작성 및 테스트
   - HTTPS 인증서 발급 (Let's Encrypt)
   - `https://dialogym.com` 접속 확인

3. **백엔드 기본 API 구현**
   - 회원가입/로그인 API (왕택준)
     - POST /api/auth/signup
     - POST /api/auth/login
     - JWT 토큰 발급
   - 시나리오 목록/상세 API (진도희)
     - GET /api/scenarios
     - GET /api/scenarios/{id}
   - WebSocket Signaling 준비 (김경민)
     - WebSocket 설정 클래스
     - Signaling 메시지 구조 설계

4. **자동화 파이프라인 구축**
   - GitHub Actions 기본 워크플로우
     - 백엔드 빌드 (Gradle)
     - 프론트엔드 빌드 (Vite)
   - Jira Smart Commit 연동 테스트
     - 커밋 메시지로 Jira 상태 변경
   - Discord 알림 자동화
     - PR 생성/병합 알림
     - 빌드 결과 알림

---

### 완료 기준 (DoD)
- [ ] ERD 문서화 완료 및 팀 검토 승인
- [ ] `https://dialogym.com` 접속 시 "Hello Dialogym" 출력
- [ ] Postman에서 회원가입/로그인 API 200 응답
- [ ] GET /api/scenarios 응답 확인 (최소 1개 시나리오)
- [ ] Docker Compose로 로컬에서 전체 서비스 실행 가능
- [ ] GitHub Actions로 자동 빌드 1회 성공
- [ ] Jira Smart Commit 동작 확인
- [ ] Daily Scrum 5회 이상 진행

---

### 개선 사항 적용
- Daily Scrum 매일 10시 실시
- 작업 분배를 팀원별로 명확히 할당
- 문서 인덱스 페이지 추가 (docs/README.md)
- 협업 프로세스 워크샵 실시 (Sprint 2 시작 전, 10.06 14시)
- Git 관련 문서 통합 (10개 → 5개)
- 팀원별 문서 작성 분담 시작

---

## 변경 이력

| 버전 | 일자 | 작성자 | 주요 변경 내용 |
|------|------|--------|----------------|
| v0.1 | 2025.10.06 | 왕택준 | 최초 작성 |
