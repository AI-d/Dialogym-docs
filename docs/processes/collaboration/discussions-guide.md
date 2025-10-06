# GitHub Discussions 운영 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.09.30

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: BE Repo Discussions에서 아키텍처/트러블슈팅 논의를 주도하고, Q&A 카테고리에 기술 질문/답변을 남기는 담당자
* **프론트엔드 개발자**: FE Repo Discussions에서 상태관리, 컴포넌트 구조, UI/UX 관련 논의를 남기고 공유하는 담당자
* **Docs 담당자**: Org(=Docs Repo) Discussions에서 회고, 팀 운영 논의, 공지 작성을 책임지는 문서 담당자
* **팀 리더 / PM**: Announcements, Retrospectives를 관리하고 팀 차원의 프로세스 논의를 이끄는 책임자
* **DevOps / 인프라 엔지니어**: BE/FE 공통으로 발생하는 트러블슈팅, 배포 환경 이슈를 Discussions에 기록하는 담당자
* **QA / 테스트 엔지니어**: 문제 상황 발생 시 Troubleshooting에 버그/에러 보고 및 해결 과정을 기록하는 담당자
* **신규 합류자**: Discussions 카테고리별 목적을 빠르게 이해하고, 어떤 주제를 어디에 남겨야 할지 학습해야 하는 팀 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 GitHub Discussions 운영 방식을 정의합니다.
Discussions는 Organization 단위(Docs Repo 대표)와 Repository 단위(BE/FE)로 구분되며, 각각 고유한 카테고리를 운영합니다.
Org Discussions는 팀 차원의 공지, 일반 운영 논의, 스프린트 회고를 다루며, Repo Discussions는 기술 세부 논의를 담당합니다.
모든 공지는 Announcement Format으로 작성하며, Q&A는 Question/Answer Format, 일반 논의는 Open-ended discussion Format을 사용합니다.
확정된 결정사항은 Docs Repo(ADR, 회의록) 또는 Wiki로 이동하여 공식 문서화합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [운영 원칙](#운영-원칙)
3. [카테고리 구성](#카테고리-구성)
4. [Format 규칙](#format-규칙)
5. [작성 원칙](#작성-원칙)
6. [Discussions Issue 전환 기준](#discussions-issue-전환-기준)
7. [요약 표](#요약-표)

---

## 문서 개요 (Overview)

본 문서는 팀 내 GitHub Discussions 사용 규칙을 명확히 하기 위해 작성되었습니다.

프로젝트가 성장하면서 기술 논의, 의사결정, 트러블슈팅 기록이 늘어나면 정보가 분산되어 검색과 추적이 어려워집니다. 이를 방지하기 위해 Organization과 Repository별 Discussions 구조를
정의하고, 카테고리별 목적과 작성 규칙을 명확히 합니다.

본 문서는 Org Discussions(팀 운영), BE Repo Discussions(백엔드 기술), FE Repo Discussions(프론트엔드 기술)의 역할과 Format 규칙을 포함합니다.

---

## 운영 원칙

다음 운영 원칙을 준수합니다.

- Org Discussions는 **Docs Repo Discussions**를 대표로 사용합니다.
- Org Discussions는 팀 차원의 운영, Repo Discussions는 기술 세부 논의로 역할을 구분합니다.
- Discussions는 **Draft 공간**이며, 확정된 결정사항은 Docs Repo(ADR, 회의록) 또는 Wiki에 반영합니다.
- 공지(Announcements)는 반드시 **Announcement Format**으로 작성합니다.
- Q&A 카테고리는 BE/FE Repo에만 두고, Org에서는 General에서 처리합니다.
- Troubleshooting은 반드시 문제 상황 + 원인 분석 + 해결 방안 구조로 기록합니다.

---

## 카테고리 구성

### Org Discussions (= Docs Repo Discussions)

다음 카테고리를 운영합니다.

#### 📣 Announcements (공지)

**Description**: 팀 전체 공지, 스프린트 일정, 마일스톤 공유

**Format**: Announcement

#### 🌐 General (일반)

**Description**: 팀 운영 논의, 협업 방식 제안, 규칙 개선 논의

**Format**: Open-ended discussion

#### 🕊️ Sprint Retrospective (스프린트 회고)

**Description**: 스프린트 종료 후 회고, 개선 사항 논의, 액션 아이템 정리

**Format**: Open-ended discussion

---

### BE Repo Discussions (백엔드)

다음 카테고리를 운영합니다.

#### 📣 Announcements

**Description**: BE 전용 공지, API 스펙 변경

**Format**: Announcement

#### 🏛️ Architecture (아키텍처)

**Description**: 인증 방식, DB 스키마, 캐싱 전략 논의

**Format**: Open-ended discussion

#### ❔ Q&A (질문/답변)

**Description**: Spring Boot, JPA, QueryDSL, MariaDB 관련 질문

**Format**: Question / Answer

#### 🔬 Troubleshooting (문제 해결)

**Description**: DB 연결, 성능 최적화, 빌드 실패 문제 공유

**Format**: Open-ended discussion

---

### FE Repo Discussions (프론트엔드)

다음 카테고리를 운영합니다.

#### 📣 Announcements

**Description**: FE 전용 공지, 디자인 시스템 업데이트

**Format**: Announcement

#### 🏛️ Architecture (아키텍처)

**Description**: 상태관리, 폴더 구조, 라우팅 전략 논의

**Format**: Open-ended discussion

#### ❔ Q&A (질문/답변)

**Description**: React, Next.js, Tailwind 관련 질문

**Format**: Question / Answer

#### 🔬 Troubleshooting (문제 해결)

**Description**: 빌드 에러, 렌더링 성능, CORS 문제 공유

**Format**: Open-ended discussion

---

## Format 규칙

### Format 종류

다음 Format을 카테고리에 맞게 사용합니다.

- **Announcement**: Announcements 카테고리 전용
- **Question / Answer**: Q&A 카테고리 전용
- **Open-ended discussion**: General, Architecture, Troubleshooting, Retrospective 카테고리

### Format 선택 기준

| 카테고리                 | Format                |
|----------------------|-----------------------|
| Announcements        | Announcement          |
| Q&A                  | Question / Answer     |
| General              | Open-ended discussion |
| Architecture         | Open-ended discussion |
| Troubleshooting      | Open-ended discussion |
| Sprint Retrospective | Open-ended discussion |

---

## 작성 원칙

### 제목 형식

다음 형식을 준수합니다.

```
[영역][분류] 주제 — 요약
```

**예시**:

- `[BE][Architecture] JWT vs Session — 인증 방식 선택`
- `[FE][Q&A] React Query 사용법 — 캐시 무효화 질문`
- `[팀][회고] Sprint 2 회고 — 개선점 논의`

### 본문 구조

다음 구조로 본문을 작성합니다.

```markdown
## 배경

(왜 이 논의가 필요한가?)

## 옵션/근거

(고려한 옵션들과 각각의 장단점)

## 결론/요청

(최종 결정 또는 팀원들에게 요청하는 사항)

## To-Do/담당자

(실행 항목과 담당자)
```

### 승격 규칙

확정된 결정사항은 다음으로 승격합니다.

- **기술 결정** → Docs Repo ADR 문서 작성
- **회의 내용** → Docs Repo 회의록 작성
- **반복 참조** → Wiki에 가이드 추가

---

## Discussions Issue 전환 기준

| 전환 시점 | 조건              | 담당자            |
|-------|-----------------|----------------|
| 기능 제안 | 기능 개발 필요성이 명확해짐 | PO / 담당 개발자    |
| 버그 보고 | 재현 단계까지 확인된 문제  | 작성자 또는 QA      |
| 기술 결정 | 팀 합의로 구현 방안 확정  | PO / Tech Lead |

> Issue로 전환 시 제목은 `[Discussions→Issue] 원본 제목` 형태로 유지하고, 원글 링크를 반드시 첨부합니다.

---

## 요약 표

| 범위               | 카테고리                      | Description         | Format                |
|------------------|---------------------------|---------------------|-----------------------|
| **Org (= Docs)** | Announcements (공지)        | 팀 전체 공지, 일정/마일스톤 공유 | Announcement          |
|                  | General (일반)              | 팀 운영 관련 일반 논의       | Open-ended discussion |
|                  | Sprint Retrospective (회고) | 스프린트 회고 및 개선점 논의    | Open-ended discussion |
| **BE Repo**      | Announcements (공지)        | 백엔드 전용 공지           | Announcement          |
|                  | Architecture (아키텍처)       | 백엔드 구조 논의           | Open-ended discussion |
|                  | Q&A (질문/답변)               | 백엔드 기술 Q&A          | Question / Answer     |
|                  | Troubleshooting (문제 해결)   | 백엔드 문제 해결 공유        | Open-ended discussion |
| **FE Repo**      | Announcements (공지)        | 프론트엔드 전용 공지         | Announcement          |
|                  | Architecture (아키텍처)       | 프론트엔드 구조 논의         | Open-ended discussion |
|                  | Q&A (질문/답변)               | 프론트엔드 기술 Q&A        | Question / Answer     |
|                  | Troubleshooting (문제 해결)   | 프론트엔드 문제 해결 공유      | Open-ended discussion |

---

## 관련 문서

* [협업 도구 가이드](./collaboration-guide.md)
* [Jira 가이드](./jira-guide.md)
* [Wiki 가이드](./wiki-guide.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.09.30 | 왕택준 | 최초 작성    |
