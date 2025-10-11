# GitHub Discussions 운영 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.09.30

**문서 버전 (Version)**: v0.2

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
6. [템플릿 가이드](#템플릿-가이드)
7. [Discussions Issue 전환 기준](#discussions-issue-전환-기준)
8. [요약 표](#요약-표)

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
- **각 카테고리는 제공된 템플릿을 사용하여 작성합니다.**

---

## 카테고리 구성

### Org Discussions (= Docs Repo Discussions)

다음 카테고리를 운영합니다.

#### 📣 Announcements (공지)

**Description**: 팀 전체 공지, 스프린트 일정, 마일스톤 공유

**Format**: Announcement

**Template**: [discussions-announcement-template.md](./discussions-announcement-template.md)

#### 🌐 General (일반)

**Description**: 팀 운영 논의, 협업 방식 제안, 규칙 개선 논의

**Format**: Open-ended discussion

**Template**: [discussion-general-template.md](./discussion-general-template.md)

#### 🕊️ Sprint Retrospective (스프린트 회고)

**Description**: 스프린트 종료 후 회고, 개선 사항 논의, 액션 아이템 정리

**Format**: Open-ended discussion

**Template**: [sprint-retrospective-template.md](./sprint-retrospective-template.md)

---

### BE Repo Discussions (백엔드)

다음 카테고리를 운영합니다.

#### 📣 Announcements

**Description**: BE 전용 공지, API 스펙 변경

**Format**: Announcement

**Template**: [discussions-announcement-template.md](./discussions-announcement-template.md)

#### 🏛️ Architecture (아키텍처)

**Description**: 인증 방식, DB 스키마, 캐싱 전략 논의

**Format**: Open-ended discussion

**Template**: [discussion-architecture-template.md](./discussion-architecture-template.md)

#### ❔ Q&A (질문/답변)

**Description**: Spring Boot, JPA, QueryDSL, MariaDB 관련 질문

**Format**: Question / Answer

**Template**: [discussion-question-template.md](./discussion-question-template.md)

#### 🔬 Troubleshooting (문제 해결)

**Description**: DB 연결, 성능 최적화, 빌드 실패 문제 공유

**Format**: Open-ended discussion

**Template**: [troubleshooting-template.md](./troubleshooting-template.md)

---

### FE Repo Discussions (프론트엔드)

다음 카테고리를 운영합니다.

#### 📣 Announcements

**Description**: FE 전용 공지, 디자인 시스템 업데이트

**Format**: Announcement

**Template**: [discussions-announcement-template.md](./discussions-announcement-template.md)

#### 🏛️ Architecture (아키텍처)

**Description**: 상태관리, 폴더 구조, 라우팅 전략 논의

**Format**: Open-ended discussion

**Template**: [discussion-architecture-template.md](./discussion-architecture-template.md)

#### ❔ Q&A (질문/답변)

**Description**: React, Next.js, Tailwind 관련 질문

**Format**: Question / Answer

**Template**: [discussion-question-template.md](./discussion-question-template.md)

#### 🔬 Troubleshooting (문제 해결)

**Description**: 빌드 에러, 렌더링 성능, CORS 문제 공유

**Format**: Open-ended discussion

**Template**: [troubleshooting-template.md](./troubleshooting-template.md)

---

## Format 규칙

### Format 종류

다음 Format을 카테고리에 맞게 사용합니다.

- **Announcement**: Announcements 카테고리 전용
- **Question / Answer**: Q&A 카테고리 전용
- **Open-ended discussion**: General, Architecture, Troubleshooting, Retrospective 카테고리

### Format 선택 기준

| 카테고리                 | Format                | Template                             |
|----------------------|-----------------------|--------------------------------------|
| Announcements        | Announcement          | discussions-announcement-template.md |
| Q&A                  | Question / Answer     | discussion-question-template.md      |
| General              | Open-ended discussion | discussion-general-template.md       |
| Architecture         | Open-ended discussion | discussion-architecture-template.md  |
| Troubleshooting      | Open-ended discussion | troubleshooting-template.md          |
| Sprint Retrospective | Open-ended discussion | sprint-retrospective-template.md     |

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

## 템플릿 가이드

각 카테고리별로 제공되는 템플릿을 반드시 사용하여 작성합니다.

### 1. Announcements (공지)

**사용 템플릿**: [discussions-announcement-template.md](./discussions-announcement-template.md)

#### Org Discussions - 팀 전체 공지

**작성 위치**: Docs Repo Discussions

**작성 시기**:

- 스프린트 시작/종료 안내
- 팀 프로세스 변경
- 중요 마일스톤 공지
- 팀 전체 일정 공유

**제목 예시**:

- `[팀][공지] Sprint 3 시작 — 10월 21일 킥오프 미팅`
- `[팀][공지] 코드 리뷰 정책 변경 — 최소 2명 승인 필수`
- `[팀][공지] 중간 발표 일정 — 11월 5일 오후 2시`

#### BE Repo Discussions - 백엔드 공지

**작성 위치**: Backend Repo Discussions

**작성 시기**:

- API 스펙 변경
- DB 스키마 수정
- 백엔드 라이브러리 업데이트
- 백엔드 배포 일정

**제목 예시**:

- `[BE][공지] User API v2.0 배포 — 10월 25일 적용`
- `[BE][공지] MariaDB 10.11 업그레이드 — 테스트 환경 먼저 적용`
- `[BE][공지] Spring Boot 3.2 마이그레이션 — 다음 스프린트 진행`

#### FE Repo Discussions - 프론트엔드 공지

**작성 위치**: Frontend Repo Discussions

**작성 시기**:

- 디자인 시스템 업데이트
- 컴포넌트 라이브러리 변경
- 빌드 설정 변경
- 프론트엔드 배포 일정

**제목 예시**:

- `[FE][공지] Tailwind v4 적용 — 10월 23일부터 신규 프로젝트 적용`
- `[FE][공지] 공통 컴포넌트 Button 개선 — 기존 코드 마이그레이션 필요`
- `[FE][공지] Vercel 배포 자동화 완료 — main 브랜치 푸시 시 자동 배포`

---

### 2. General (일반 논의)

**사용 템플릿**: [discussion-general-template.md](./discussion-general-template.md)

**작성 위치**: Docs Repo Discussions

**작성 시기**:

- 팀 협업 방식 개선 제안
- 회의 시간/방식 변경 논의
- Git 브랜치 전략 변경
- 코드 리뷰 프로세스 개선

**제목 예시**:

- `[팀][프로세스] 데일리 스크럼 시간 조정 — 오전 10시 vs 오후 2시`
- `[팀][협업] PR 리뷰 시간 단축 방안 — 페어 리뷰 도입 검토`
- `[팀][규칙] Commit 메시지 컨벤션 강화 — Conventional Commits 적용`

---

### 3. Architecture (아키텍처)

**사용 템플릿**: [discussion-architecture-template.md](./discussion-architecture-template.md)

**작성 위치**: Backend 또는 Frontend Repo Discussions

**작성 시기**:

- 새로운 아키텍처 패턴 도입
- 기존 구조 개선 제안
- 기술 스택 선택
- 성능 최적화 방안

**제목 예시 (Backend)**:

- `[BE][Architecture] JWT vs Session — 인증 방식 선택`
- `[BE][Architecture] Repository 패턴 개선 — QueryDSL 도입 검토`
- `[BE][Architecture] 캐싱 전략 — Redis vs EhCache`

**제목 예시 (Frontend)**:

- `[FE][Architecture] 상태관리 라이브러리 선택 — Zustand vs Jotai`
- `[FE][Architecture] 폴더 구조 개선 — Feature-based vs Layer-based`
- `[FE][Architecture] SSR vs CSR — Next.js 렌더링 전략`

---

### 4. Q&A (질문/답변)

**사용 템플릿**: [discussion-question-template.md](./discussion-question-template.md)

**작성 위치**: Backend 또는 Frontend Repo Discussions

**작성 시기**:

- 기술적인 질문이 있을 때
- 에러 해결 방법을 모를 때
- 베스트 프랙티스를 알고 싶을 때
- 라이브러리 사용법이 궁금할 때

**제목 예시 (Backend)**:

- `[BE][Q&A] JPA N+1 문제 해결 — Fetch Join vs Entity Graph`
- `[BE][Q&A] Spring Security 설정 — CORS 에러 해결 방법`
- `[BE][Q&A] MariaDB 인덱스 — Composite Index 순서 질문`

**제목 예시 (Frontend)**:

- `[FE][Q&A] React Query 캐시 무효화 — invalidateQueries 사용법`
- `[FE][Q&A] Next.js 이미지 최적화 — Image 컴포넌트 설정`
- `[FE][Q&A] Tailwind 커스텀 — 반응형 breakpoint 추가 방법`

---

### 5. Troubleshooting (문제 해결)

**사용 템플릿**: [troubleshooting-template.md](./troubleshooting-template.md)

**작성 위치**: Backend 또는 Frontend Repo Discussions

**작성 시기**:

- 프로덕션/개발 환경에서 문제 발생
- 성능 이슈 발견 및 해결
- 빌드/배포 실패
- 예상치 못한 버그 발견

**제목 예시 (Backend)**:

- `[BE][Troubleshooting] DB 커넥션 풀 고갈 — HikariCP 설정 조정으로 해결`
- `[BE][Troubleshooting] 메모리 누수 — JPA 영속성 컨텍스트 clear 누락`
- `[BE][Troubleshooting] API 응답 속도 저하 — N+1 쿼리 Batch Fetch로 해결`

**제목 예시 (Frontend)**:

- `[FE][Troubleshooting] 빌드 실패 — Node 버전 불일치 해결`
- `[FE][Troubleshooting] 무한 렌더링 — useEffect 의존성 배열 수정`
- `[FE][Troubleshooting] CORS 에러 — Proxy 설정으로 해결`

---

### 6. Sprint Retrospective (스프린트 회고)

**사용 템플릿**: [sprint-retrospective-template.md](./sprint-retrospective-template.md)

**작성 위치**: Docs Repo Discussions

**작성 시기**:

- 스프린트 종료 직후
- 주간/격주 단위 회고

**제목 예시**:

- `[팀][회고] Sprint 2 회고 (2025.10.07 ~ 10.20) — API 개발 완료`
- `[팀][회고] Sprint 3 회고 (2025.10.21 ~ 11.03) — 프론트 통합 완료`

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

| 범위               | 카테고리                      | Description         | Format                | Template                             |
|------------------|---------------------------|---------------------|-----------------------|--------------------------------------|
| **Org (= Docs)** | Announcements (공지)        | 팀 전체 공지, 일정/마일스톤 공유 | Announcement          | discussions-announcement-template.md |
|                  | General (일반)              | 팀 운영 관련 일반 논의       | Open-ended discussion | discussion-general-template.md       |
|                  | Sprint Retrospective (회고) | 스프린트 회고 및 개선점 논의    | Open-ended discussion | sprint-retrospective-template.md     |
| **BE Repo**      | Announcements (공지)        | 백엔드 전용 공지           | Announcement          | discussions-announcement-template.md |
|                  | Architecture (아키텍처)       | 백엔드 구조 논의           | Open-ended discussion | discussion-architecture-template.md  |
|                  | Q&A (질문/답변)               | 백엔드 기술 Q&A          | Question / Answer     | discussion-question-template.md      |
|                  | Troubleshooting (문제 해결)   | 백엔드 문제 해결 공유        | Open-ended discussion | troubleshooting-template.md          |
| **FE Repo**      | Announcements (공지)        | 프론트엔드 전용 공지         | Announcement          | discussions-announcement-template.md |
|                  | Architecture (아키텍처)       | 프론트엔드 구조 논의         | Open-ended discussion | discussion-architecture-template.md  |
|                  | Q&A (질문/답변)               | 프론트엔드 기술 Q&A        | Question / Answer     | discussion-question-template.md      |
|                  | Troubleshooting (문제 해결)   | 프론트엔드 문제 해결 공유      | Open-ended discussion | troubleshooting-template.md          |

---

## 관련 문서

* [협업 도구 가이드](./collaboration-guide.md)
* [Jira 가이드](./jira-guide.md)
* [Wiki 가이드](./wiki-guide.md)
* [Discussions 템플릿 모음](./templates/)
    * [공지 템플릿](./discussions-announcement-template.md)
    * [일반 논의 템플릿](./discussion-general-template.md)
    * [아키텍처 템플릿](./discussion-architecture-template.md)
    * [Q&A 템플릿](./discussion-question-template.md)
    * [트러블슈팅 템플릿](./troubleshooting-template.md)
    * [회고 템플릿](./sprint-retrospective-template.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용                   |
|------|------------|-----|----------------------------|
| v0.1 | 2025.09.30 | 왕택준 | 최초 작성                      |
| v0.2 | 2025.10.11 | 왕택준 | 템플릿 가이드 추가, 카테고리별 작성 예시 추가 |
