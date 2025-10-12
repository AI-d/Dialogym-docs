# Jira 이용 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.01

**문서 버전 (Version)**: v0.2

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Task/Feature 이슈를 생성하고, Bug Report를 작성하며, Technical Spike를 통해 기술 검토를 수행하는 담당자
* **프론트엔드 개발자**: UI/UX 관련 Task와 Feature 이슈를 생성하고, 프론트엔드 버그를 리포트하는 담당자
* **풀스택 개발자**: 백엔드와 프론트엔드 작업을 모두 수행하며, 통합 작업 이슈를 관리하는 담당자
* **팀 리더 / Scrum Master**: Sprint Planning, Sprint Review, Sprint Retrospective를 주도하고 전체 스프린트를 관리하는 책임자
* **DevOps / 인프라 엔지니어**: 배포, CI/CD 관련 Task를 생성하고 인프라 이슈를 추적하는 담당자
* **신규 합류자**: Jira 워크플로우, 이슈 타입, 양식 작성법을 빠르게 학습해야 하는 팀 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Jira를 활용한 작업 관리 방식을 정의합니다.
Jira는 팀 내부 작업 관리 도구로 사용하며, GitHub Issues는 외부 공개용으로 별도 운영합니다.
모든 이슈는 Sprint에 할당되어야 하며, CODE REVIEW 단계를 필수로 거쳐야 합니다.
워크플로우는 BACKLOG → TO DO → IN PROGRESS → CODE REVIEW → DONE 순서로 진행됩니다.
GitHub 커밋 메시지에 Jira 이슈 키를 포함하여 양방향 연동을 지원하며, Sprint는 1주 단위로 진행됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [운영 원칙](#운영-원칙)
3. [이슈 계층 구조](#이슈-계층-구조)
4. [워크플로우](#워크플로우)
5. [이슈 타입 및 양식](#이슈-타입-및-양식)
6. [라벨 체계](#라벨-체계)
7. [이슈 생성 가이드](#이슈-생성-가이드)
8. [스프린트 관리](#스프린트-관리)
9. [GitHub 연동](#github-연동)
10. [코드 리뷰 규칙](#코드-리뷰-규칙)

---

## 문서 개요 (Overview)

본 문서는 프로젝트 팀에서 사용하는 Jira 작업 관리 방식을 정의하기 위해 작성되었습니다.

프로젝트가 성장하면서 작업 추적, 우선순위 관리, 팀 간 협업이 복잡해집니다.
Jira는 이러한 문제를 해결하기 위한 작업 관리 도구로, Sprint 기반 애자일 개발을 지원합니다.

본 문서는 Jira 프로젝트 구성, 워크플로우, 이슈 타입별 양식, GitHub 연동 규칙을 다루어
팀 전체가 일관된 방식으로 Jira를 활용할 수 있도록 합니다.

---

## 운영 원칙

본 프로젝트의 Jira 운영 원칙은 다음과 같습니다.

### 기본 원칙

Jira는 팀 내부 작업 관리 도구로 사용하며, GitHub Issues는 외부 공개용으로 별도 운영합니다.
모든 이슈는 반드시 Sprint에 할당되어야 합니다.
CODE REVIEW 단계는 필수이며, IN PROGRESS에서 DONE으로 직접 이동할 수 없습니다.
이슈 생성 시 필수 필드를 반드시 입력해야 합니다.

### 연동 규칙

GitHub 커밋 메시지에는 반드시 Jira 이슈 키(TRAIN-XX)를 포함해야 합니다.
Sprint는 1주 단위로 진행하며, Sprint 종료 시 Sprint Retrospective(회고록)를 작성합니다.
Jira와 GitHub는 양방향 연동되어 있습니다(GitHub for Atlassian 앱 사용).

---

## 이슈 계층 구조

Jira 이슈는 계층적 구조로 관리됩니다. 큰 단위에서 작은 단위로 분해하여 작업을 추적합니다.

### 계층 구조 개요

```
Epic (에픽)
  ├── Task (일반 작업)
  │     └── Sub-task (하위 작업)
  ├── Feature (기능 구현)
  │     └── Sub-task (하위 작업)
  ├── Bug Report (버그 리포트)
  │     └── Sub-task (하위 작업)
  └── Technical Spike (기술 검토)
        └── Sub-task (하위 작업)
```

---

### 1단계: Epic (에픽)

Epic은 여러 스프린트에 걸쳐 진행되는 대규모 기능이나 프로젝트를 관리합니다.

**사용 시기:**

- 한 분기 이상 진행되는 큰 프로젝트
- 여러 팀이 협업하는 대규모 기능
- 비즈니스 목표와 직접 연결되는 작업

**예시:**

- "사용자 인증 시스템 구축"
- "AI 기반 추천 엔진 개발"
- "WebRTC 화상 회의 기능 구현"

**특징:**

- Epic에는 여러 개의 Task, Feature, Bug, Spike가 연결됩니다
- Epic 단위로 진행 상황을 추적하고 보고합니다
- Epic은 직접 구현하지 않고, 하위 이슈들을 통해 완료됩니다

**템플릿:** `jira-epic-template.md` 참조

---

### 2단계: 실행 이슈 (Task / Feature / Bug Report / Technical Spike)

Epic 아래에 생성되는 실제 작업 단위입니다. 각 이슈 타입은 용도에 따라 구분됩니다.

#### Task (일반 작업)

개발·운영 과정에서 발생하는 일반적인 업무를 추적합니다.

**사용 시기:**

- 설정 파일 작성
- 문서 작성
- 리팩토링
- 의존성 업데이트

**템플릿:** `jira-task-template.md` 참조

---

#### Feature (기능 구현)

신규 기능이나 개선 기능을 정의하고 구현을 추적합니다.

**사용 시기:**

- 새로운 기능 개발
- 기존 기능 개선
- 사용자 스토리 구현

**템플릿:** `jira-feature-template.md` 참조

---

#### Bug Report (버그 리포트)

시스템에서 발생한 오류를 추적하고 해결합니다.

**사용 시기:**

- 프로덕션 버그 발생
- QA 테스트 중 발견된 버그
- 사용자 제보 버그

**템플릿:** `jira-bug-report-template.md` 참조

---

#### Technical Spike (기술 검토)

새로운 기술이나 아키텍처 도입 전에 조사 및 실험을 진행합니다.

**사용 시기:**

- 새로운 라이브러리/프레임워크 검토
- 아키텍처 의사결정이 필요한 경우
- POC(Proof of Concept) 개발

**템플릿:** `jira-technical-spike-template.md` 참조

---

### 3단계: Sub-task (하위 작업)

부모 이슈를 실행 가능한 작은 단위로 분해하여 추적합니다.

**사용 시기:**

- Task/Feature/Bug/Spike를 여러 개발자가 분담할 때
- 작업을 더 세밀하게 추적해야 할 때
- 특정 작업 단계를 명확히 구분해야 할 때

**예시:**
부모 이슈: "TRAIN-10: JWT 인증 구현 (Feature)"

- Sub-task 1: "JWT 토큰 생성 로직 구현"
- Sub-task 2: "JWT 검증 미들웨어 구현"
- Sub-task 3: "리프레시 토큰 로직 구현"
- Sub-task 4: "인증 관련 단위 테스트 작성"

**특징:**

- Sub-task는 반드시 부모 이슈에 종속됩니다
- Sub-task 없이 독립적으로 존재할 수 없습니다
- 부모 이슈의 상태는 하위 작업 완료 여부에 따라 관리됩니다

**템플릿:** `jira-sub-task-template.md` 참조

---

### 계층 구조 활용 예시

**시나리오: 사용자 인증 시스템 구축**

```
Epic: TRAIN-1 "사용자 인증 시스템 구축"
│
├── Technical Spike: TRAIN-2 "JWT vs Session 방식 비교 검토"
│   ├── Sub-task: TRAIN-3 "JWT 방식 조사 및 POC"
│   └── Sub-task: TRAIN-4 "Session 방식 조사 및 POC"
│
├── Feature: TRAIN-5 "JWT 기반 로그인 구현"
│   ├── Sub-task: TRAIN-6 "JWT 토큰 생성 API 개발"
│   ├── Sub-task: TRAIN-7 "JWT 검증 미들웨어 개발"
│   └── Sub-task: TRAIN-8 "로그인 프론트엔드 연동"
│
├── Feature: TRAIN-9 "소셜 로그인 구현"
│   ├── Sub-task: TRAIN-10 "Google OAuth 연동"
│   └── Sub-task: TRAIN-11 "Kakao OAuth 연동"
│
├── Task: TRAIN-12 "인증 관련 API 문서 작성"
│
└── Bug Report: TRAIN-13 "토큰 만료 시 무한 리다이렉트 버그"
    └── Sub-task: TRAIN-14 "토큰 갱신 로직 수정"
```

---

### 계층 구조 작성 가이드

**Epic 생성 시:**

1. 프로젝트의 큰 목표와 범위를 명확히 정의합니다
2. 성공 지표를 구체적으로 작성합니다
3. 예상 기간과 담당 팀을 지정합니다

**실행 이슈 생성 시:**

1. 반드시 상위 Epic을 연결합니다
2. 이슈 타입을 정확히 선택합니다 (Task/Feature/Bug/Spike)
3. 해당 템플릿의 필수 필드를 모두 작성합니다

**Sub-task 생성 시:**

1. 부모 이슈를 먼저 생성한 후 Sub-task를 추가합니다
2. Sub-task는 1~4시간 내에 완료 가능한 크기로 작성합니다
3. 각 Sub-task는 명확한 완료 조건을 가져야 합니다

**주의사항:**

- Epic 없이 바로 Task를 생성하지 않습니다
- Sub-task가 너무 많으면 (5개 이상) 부모 이슈를 분리하는 것을 고려합니다
- 계층이 3단계(Epic > Task > Sub-task)를 초과하지 않도록 합니다

---

## 워크플로우

### 상태 흐름

```
Create
 ↓
BACKLOG
 ↓
TO DO
 ↓
IN PROGRESS
 ↓
CODE REVIEW
 ↓
DONE
```

---

### 보드 컬럼 구성

| 컬럼          | 설명         | WIP 제한         |
|-------------|------------|----------------|
| BACKLOG     | 우선순위 미정    | 제한 없음          |
| TO DO       | 이번 스프린트 작업 | 제한 없음          |
| IN PROGRESS | 개발 중       | 최대 3개 (팀원당 1개) |
| CODE REVIEW | PR 리뷰 중    | 제한 없음          |
| DONE        | 완료         | 제한 없음          |

---

### 규칙

IN PROGRESS에서 DONE으로 직접 이동할 수 없습니다.
CODE REVIEW 단계는 필수입니다.
Approve 1명 이상 + CI 통과가 필수입니다.

---

## 이슈 타입 및 양식

각 이슈 타입의 상세한 작성 양식은 별도 템플릿 문서를 참조하세요.

### Epic (에픽)

**템플릿:** `jira-epic-template.md`

**필수 필드:**

- 상태, 요약, 에픽 이름, 설명
- 목표, 범위, 성공 지표
- 우선 순위, Sprint, Team, 담당자, 보고자

---

### Task (일반 작업)

**템플릿:** `jira-task-template.md`

**필수 필드:**

- 상태, 요약, 설명
- 우선 순위, 레이블, Sprint, Team, 담당자, 보고자

---

### Feature (기능 구현)

**템플릿:** `jira-feature-template.md`

**필수 필드:**

- 상태, 요약, 설명
- 배경/목적, 제안 내용, 기능 구현 방안
- 우선 순위, 레이블, Sprint, Team, 담당자, 보고자

---

### Bug Report (버그 리포트)

**템플릿:** `jira-bug-report-template.md`

**필수 필드:**

- 상태, 요약, 설명
- 재현 방법, 예상 동작, 실제 동작
- 우선 순위, 레이블, Sprint, Team, 담당자, 보고자

---

### Technical Spike (기술 검토)

**템플릿:** `jira-technical-spike-template.md`

**필수 필드:**

- 상태, 요약, 설명
- 검토 목적, 결론/권장사항
- 우선 순위, 레이블, Sprint, Team, 담당자, 보고자

---

### Sub-task (하위 작업)

**템플릿:** `jira-sub-task-template.md`

**필수 필드:**

- 상태, 요약, 설명
- 작업 내용, 우선 순위, 레이블, Sprint, Team, 담당자, 보고자

---

## 라벨 체계

### Area (영역)

| 라벨명      | 설명                       |
|----------|--------------------------|
| frontend | 프론트엔드(UI/React 등) 관련 작업  |
| backend  | 백엔드(Spring, API 등) 관련 작업 |
| database | 데이터베이스 설계·쿼리 등 DB 관련 작업  |
| devops   | 서버·배포·CI/CD 등 인프라 관련 작업  |
| ai       | AI/ML 모델 및 프롬프트 관련 작업    |
| webrtc   | WebRTC 실시간 통신 관련 작업      |

---

### Type (유형)

| 라벨명         | 설명                          |
|-------------|-----------------------------|
| feature     | 새로운 기능을 추가하는 작업             |
| bug         | 기존 기능의 오류를 수정하는 작업          |
| enhancement | 기존 기능을 개선하거나 확장하는 작업        |
| refactor    | 코드 구조를 개선하지만 동작은 바꾸지 않는 작업  |
| docs        | 프로젝트 문서를 작성하거나 수정하는 작업      |
| design      | UI/UX 화면 디자인 및 레이아웃 작업      |
| test        | 테스트를 작성하거나 수정하는 작업          |
| security    | 보안 이슈를 해결하거나 보안 기능 강화 작업    |
| performance | 성능을 개선하거나 최적화하는 작업          |
| ci-cd       | 배포 및 CI/CD 자동화를 다루는 작업      |
| chore       | 유지보수, 사소한 잡일(의존성 업데이트 등) 작업 |

---

## 이슈 생성 가이드

### 이슈 생성 절차

1. "만들기" 클릭 (단축키 C)
2. 양식 선택 → 필드 입력
3. 레이블, 담당자, 스프린트 지정
4. 저장

---

### 이슈 키 규칙

```
TRAIN-1, TRAIN-2, ...
```

---

## 스프린트 관리

### Sprint Planning

1주 단위로 Sprint를 진행합니다.
Sprint Goal을 작성합니다.

---

### Board 진행

```
TO DO → IN PROGRESS → CODE REVIEW → DONE
```

---

### Daily Standup

Discord에서 비동기로 진행합니다.

---

### Sprint 종료

Review + Retrospective를 진행합니다.

---

## GitHub 연동

### Smart Commit 문법

#### 기본

```bash
git commit -m "TRAIN-12 feat: JWT 미들웨어 추가"
```

---

#### 코멘트

```bash
git commit -m "TRAIN-12 #comment 내용"
```

---

#### 시간 기록

```bash
git commit -m "TRAIN-12 #time 2h"
```

---

#### 완료 처리

```bash
git commit -m "TRAIN-12 fix: 버그 수정 #done"
```

---

### 브랜치 규칙

```
feature/TRAIN-12
fix/TRAIN-45
hotfix/TRAIN-99
```

---

## 코드 리뷰 규칙

### PR 생성 시

1. IN PROGRESS → CODE REVIEW 이동 시 PR 생성
2. PR 제목에 Jira 이슈 키 포함
3. 최소 1명 Approve + CI 통과
4. PR 머지 후 자동으로 DONE 이동

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용                   |
|------|------------|-----|----------------------------|
| v0.1 | 2025.10.01 | 왕택준 | 최초 작성                      |
| v0.2 | 2025.10.10 | 왕택준 | 이슈 계층 구조 섹션 추가 및 템플릿 참조 추가 |
