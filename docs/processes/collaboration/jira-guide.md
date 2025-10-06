# Jira 이용 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.01

**문서 버전 (Version)**: v0.1

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
3. [워크플로우](#워크플로우)
4. [이슈 타입 및 양식](#이슈-타입-및-양식)
5. [라벨 체계](#라벨-체계)
6. [이슈 생성 가이드](#이슈-생성-가이드)
7. [스프린트 관리](#스프린트-관리)
8. [GitHub 연동](#github-연동)
9. [코드 리뷰 규칙](#코드-리뷰-규칙)

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

### Task (일반 작업)

**용도**: 개발, 설정, 문서, 리팩토링

**타입**: Task

#### 설명 필드

* 상태 (필수)
* 요약 (필수)
* 설명

#### 컨텍스트 필드

* 작업 목록 (To Do List, 필수)
* 우선 순위 (Priority, 필수)
* 레이블 (Labels, 필수)
* Sprint (필수)
* Team (필수)
* 담당자 (Assignee, 필수)
* 보고자 (Reporter)
* Start date
* 기한 (Due date)

---

### Feature (기능 구현)

**용도**: 신규 기능 개발 또는 개선

**타입**: Story

#### 설명 필드

* 상태 (필수)
* 요약 (필수)
* 설명

#### 컨텍스트 필드

* 배경/목적 (Background, 필수)
* 제안 내용 (Proposed Feature, 필수)
* 작업 목록 (Checklist, 필수)
* 기술 구현 방안 (Implementation Details, 필수)
* 우선 순위 (Priority, 필수)
* 레이블 (Labels, 필수)
* Sprint (필수)
* Team (필수)
* 담당자 (Assignee, 필수)
* 보고자 (Reporter)
* Start date
* 기한 (Due date)

---

### Bug Report (버그 리포트)

**용도**: 시스템 오류 추적 및 해결

**타입**: Bug

#### 설명 필드

* 상태 (필수)
* 요약 (필수)
* 설명
* 환경 (Environment)

#### 컨텍스트 필드

* 재현 방법 (Steps to Reproduce, 필수)
* 예상 동작 (Expected Behavior, 필수)
* 실제 동작 (Actual Behavior, 필수)
* 우선 순위 (Priority, 필수)
* 레이블 (Labels, 필수)
* Sprint (필수)
* Team (필수)
* 담당자 (Assignee, 필수)
* 보고자 (Reporter)
* Start date
* 기한 (Due date)

---

### Technical Spike (기술 검토)

**용도**: 새로운 기술/아키텍처 조사 및 검토

**타입**: Task

#### 설명 필드

* 상태 (필수)
* 요약 (필수)
* 설명

#### 컨텍스트 필드

* 검토 목적 (Purpose, 필수)
* 조사 항목 (Research Items, 필수)
* 결론/권장사항 (Conclusion, 필수)
* 우선 순위 (Priority, 필수)
* 레이블 (Labels, 필수)
* Sprint (필수)
* Team (필수)
* 담당자 (Assignee, 필수)
* 보고자 (Reporter)
* Start date
* 기한 (Due date)

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

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.01 | 왕택준 | 최초 작성    |
