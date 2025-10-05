# 협업 도구 워크플로우 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.09.30

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Jira, BE Repo Discussions, Wiki를 통해 백엔드 기술 논의와 트러블슈팅을 담당하는 개발자
* **프론트엔드 개발자**: Jira, FE Repo Discussions, Wiki를 통해 프론트엔드 구조 논의와 컴포넌트 설계를 담당하는 개발자
* **Docs 담당자**: Docs Repo, Org Discussions를 통해 회의록/ADR/보고서 문서를 관리하는 담당자
* **팀 리더 / PM**: 전반적인 워크플로우를 관리하고 Announcements, Sprint Retrospective를 운영하는 책임자
* **DevOps / 인프라 엔지니어**: 배포 및 운영 환경 문제를 Troubleshooting으로 공유하고 Wiki/Docs에 반영하는 담당자
* **QA / 테스트 엔지니어**: 버그와 시나리오 테스트 결과를 Discussions과 Jira에 기록하는 담당자
* **신규 합류자**: 협업 도구별 목적과 사용 위치를 빠르게 이해해야 하는 팀 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 협업 도구의 운영 방식을 정의합니다.
Discord는 실시간 소통, Discussions는 기술 논의 및 기록, Jira는 작업 관리, Wiki는 참조 문서, Docs repo는 공식 문서로 역할이 구분됩니다.
아이디어는 Discord에서 제안하고, Discussions에서 논의하며, Docs repo에 ADR로 문서화하고, Jira에서 작업을 생성합니다.
개발 중에는 Wiki를 업데이트하며, Sprint 종료 시 Discussions에서 회고를 진행합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [도구별 역할](#도구별-역할)
3. [전체 워크플로우](#전체-워크플로우)
4. [상황별 사용 가이드](#상황별-사용-가이드)
5. [Smart Commit 문법](#smart-commit-문법)
6. [문서 작성 위치 결정](#문서-작성-위치-결정)
7. [Discord 채널 구성](#discord-채널-구성)
8. [Discussions 카테고리](#discussions-카테고리)
9. [Jira 보드 구성](#jira-보드-구성)
10. [Repository별 Wiki 구조](#repository별-wiki-구조)
11. [Docs Repo 구조](#docs-repo-구조)
12. [Repository별 README](#repository별-readme)
13. [Organization Profile README](#organization-profile-readme)
14. [문서 작성 타이밍](#문서-작성-타이밍)
15. [빠른 참조](#빠른-참조)

---

## 문서 개요 (Overview)

본 문서는 팀 내 협업 도구의 역할을 명확히 하기 위해 작성되었습니다.

프로젝트가 성장하면서 여러 협업 도구를 사용하게 되면, 각 도구의 목적이 모호해지고 정보가 분산되어 효율이 떨어집니다. 이를 방지하기 위해 Discord, GitHub Discussions, Jira, Wiki, Docs Repo의 역할과 사용 시점을 명확히 정의합니다.

본 문서는 아이디어 제안부터 최종 문서화까지 전체 워크플로우를 다루며, 각 도구의 구조와 작성 규칙도 포함합니다.

---

## 도구별 역할

| 도구 | 역할 | 사용 예시 |
|------|------|----------|
| Discord | 실시간 소통 | 긴급 이슈, 간단한 질문, 음성 회의, 일반 대화 |
| Discussions | 기술 논의 및 기록 | 기술 선택 논의, 트러블슈팅 기록, 회고 |
| Jira | 작업 관리 | Task 생성/할당, 진행 상황 추적, 스프린트 |
| Wiki | 참조 문서 | API 문서, 개발 환경 세팅, 컨벤션 |
| Docs repo | 공식 문서 | 요구사항 명세서, ERD, ADR, 회의록 |

---

## 전체 워크플로우

다음은 아이디어 제안부터 최종 문서화까지의 전체 흐름입니다.

```
1. 아이디어 제안 (Discord)
   ↓
2. 기술 논의 (Discussions)
   - 옵션 비교
   - 팀원 의견 수렴 (2-3일)
   - 최종 결정 기록
   ↓
3. 공식 문서화 (Docs repo)
   - ADR 작성 및 커밋
   - 설계 문서 저장
   ↓
4. 작업 생성 (Jira)
   - Epic/Story/Task 생성
   - 담당자 할당
   - Story Points 설정
   ↓
5. 개발 (GitHub + Jira)
   - 브랜치 생성 (feature/NFP-XX)
   - Smart Commit 사용
   - PR 생성 (Jira 링크 포함)
   ↓
6. 참조 문서 업데이트 (Wiki)
   - API 문서 갱신
   - 가이드 추가
   ↓
7. 회고 (Discussions)
   - 스프린트 회고
   - 개선점 논의
```

---

## 상황별 사용 가이드

### 기술 의사결정이 필요할 때

```
1. Discord: 초기 제안 및 간단한 의견 교환
2. Discussions: 본격적인 논의 시작 (3일간 의견 수렴)
3. Docs repo: ADR 문서 작성 및 커밋
4. Jira: 구현 Task 생성
5. Wiki: 관련 가이드 추가
```

### 긴급 버그 발생 시

```
1. Discord: 즉시 알림 및 빠른 해결
2. Discussions: 문제 해결 과정 상세 기록
3. Wiki: 트러블슈팅 FAQ 업데이트
```

### 새 기능 개발 시

```
1. Discussions: 구현 방법 논의
2. Docs repo: 설계 문서 작성
3. Jira: Epic/Story/Task 생성
4. GitHub: 브랜치 생성 및 개발
5. PR: Jira 링크 포함하여 생성
6. Wiki: API 문서 업데이트
```

---

## Smart Commit 문법

### 기본 명령어

```bash
# 기본
git commit -m "NFP-12 feat: JWT 미들웨어 추가"

# 코멘트 추가
git commit -m "NFP-12 #comment Redis 연동 완료"

# 작업 시간 기록
git commit -m "NFP-12 #time 2h 30m"

# 완료 처리
git commit -m "NFP-12 fix: 버그 수정 #done"

# 여러 명령어 조합
git commit -m "NFP-12 feat: 결제 API #comment Toss 연동 #time 3h"
```

### 명령어 설명

| 명령어 | 설명 |
|--------|------|
| 기본 | Jira 이슈에 커밋 연결 |
| `#comment` | 이슈에 코멘트 추가 |
| `#time` | 작업 시간 기록 |
| `#done` | 이슈 완료 처리 |

### 주의사항

다음 사항을 주의합니다.

- NFP-12는 실제 Jira 프로젝트 키와 이슈 번호로 변경
- Conventional Commits 규칙 준수 (feat, fix, docs, refactor 등)

---

## 문서 작성 위치 결정

### 결정 트리

```
자주 바뀌는 내용인가? → Yes → Wiki
논의 과정을 기록해야 하는가? → Yes → Discussions
최종 확정된 공식 문서인가? → Yes → Docs repo
실시간으로 공유해야 하는가? → Yes → Discord
작업 추적이 필요한가? → Yes → Jira
```

### 구체적 예시

| 내용 | 도구 | 이유 |
|------|------|------|
| API 엔드포인트 스펙 | Wiki | 개발 중 자주 변경 |
| JWT vs Session 논의 | Discussions | 의사결정 과정 기록 |
| 최종 확정 ERD | Docs repo | 버전 관리 필요 |
| PR 리뷰 요청 | Discord | 실시간 알림 |
| 스프린트 백로그 | Jira | 작업 추적 |

---

## Discord 채널 구성

### 권장 채널

#### 채팅 채널

다음 채널을 운영합니다.

**공지사항**
- 중요 공지
- 스프린트 시작/종료

**긴급-이슈**
- 서버 다운
- 프로덕션 버그
- @everyone 멘션 사용

**데일리-스탠드업**
- 오늘 할 일
- 어제 한 일
- 블로킹 이슈

**개발-질문**
- 빠른 기술 질문
- 5분 내 답변 불가능하면 Discussions 이동

**일반**
- 자유로운 대화

#### 음성 채널

다음 음성 채널을 운영합니다.

**회의실**
- 스프린트 플래닝

**일반**
- 자유로운 음성 대화

---

## Discussions 카테고리

### Org Discussions (= Docs Repo Discussions)

다음 카테고리를 운영합니다.

- 📣 **Announcements (공지)**: 팀 전체 공지, 스프린트 일정, 마일스톤 공유
- 🌐 **General (일반)**: 팀 운영 논의, 협업 방식 제안, 규칙 개선 논의
- 🕊️ **Sprint Retrospective (스프린트 회고)**: 스프린트 종료 후 회고, 개선 사항 논의, 액션 아이템 정리

### BE Repo Discussions (백엔드)

다음 카테고리를 운영합니다.

- 📣 **Announcements**: BE 전용 공지, API 스펙 변경
- 🏛️ **Architecture**: 인증 방식, DB 스키마, 캐싱 전략 논의
- ❔ **Q&A**: Spring Boot, JPA, QueryDSL, MariaDB 관련 질문
- 🔬 **Troubleshooting**: DB 연결, 성능 최적화, 빌드 실패 문제 공유

### FE Repo Discussions (프론트엔드)

다음 카테고리를 운영합니다.

- 📣 **Announcements**: FE 전용 공지, 디자인 시스템 업데이트
- 🏛️ **Architecture**: 상태관리, 폴더 구조, 라우팅 전략 논의
- ❔ **Q&A**: React, Next.js, Tailwind 관련 질문
- 🔬 **Troubleshooting**: 빌드 에러, 렌더링 성능, CORS 문제 공유

### Format 규칙

다음 Format 규칙을 준수합니다.

- Announcements → Announcement
- Q&A → Question / Answer
- General / Architecture / Troubleshooting / Retrospective → Open-ended discussion

### 작성 원칙

다음 작성 원칙을 따릅니다.

- 제목: `[영역][분류] 주제 — 요약`
- 본문: 배경 → 옵션/근거 → 결론/요청 → To-Do/담당자
- 확정된 결정사항은 **Docs Repo(ADR, 회의록)** 또는 **Wiki**로 승격

---

## Jira 보드 구성

### 컬럼 구조

다음 컬럼 구조를 사용합니다.

```
Backlog → To Do → In Progress → Code Review → Done
```

| 컬럼 | 설명 |
|------|------|
| Backlog | 우선순위 미정, 다음 스프린트 후보 |
| To Do | 이번 스프린트 작업, 담당자 지정됨 |
| In Progress | 개발 중, 브랜치 생성됨 |
| Code Review | PR 생성, 리뷰 대기 중 |
| Done | PR 머지 완료, 배포됨 |

### WIP 제한

다음 WIP 제한을 적용합니다.

- In Progress: 최대 3개 (팀원당 1개)
- Code Review: 제한 없음

### 이슈 계층 구조

다음 계층 구조를 사용합니다.

```
Epic (대기능)
└── Story (사용자 스토리)
    └── Task (개발 작업)
        └── Subtask (세부 작업)
```

### Task 필수 항목

다음 항목을 필수로 입력합니다.

- Summary: 작업 제목
- Issue Type: Task/Bug/Story
- Priority: High/Medium/Low
- Story Points: 1, 2, 3, 5, 8, 13
- Assignee: 담당자
- Labels: 태그
- Description: 목표, 참고, 요구사항, 완료 조건

---

## Repository별 Wiki 구조

### be repo Wiki

다음 구조로 Wiki를 구성합니다.

```
Home
├── 빠른 시작
├── 개발 환경 세팅
│   ├── 사전 요구사항
│   ├── 설치 방법
│   └── 환경 변수 설정
├── API 문서
│   ├── 인증 API
│   ├── 상품 API
│   ├── 주문 API
│   └── 결제 API
├── 데이터베이스
│   ├── 스키마 구조
│   ├── 마이그레이션 가이드
│   └── 시드 데이터
├── 코딩 컨벤션
│   ├── 네이밍 규칙
│   ├── 폴더 구조
│   └── 에러 처리
└── 트러블슈팅
```

**목적**: 백엔드 개발자 빠른 참조 문서

**특징**: 자주 변경되는 내용 (API 스펙, 가이드)

**업데이트**: 개발 중 수시로

### fe repo Wiki

다음 구조로 Wiki를 구성합니다.

```
Home
├── 빠른 시작
├── 개발 환경 세팅
├── 컴포넌트 가이드
├── 상태관리
├── 라우팅
├── 스타일 가이드
└── 트러블슈팅
```

**목적**: 프론트엔드 개발자 빠른 참조 문서

**특징**: 컴포넌트 사용법, 스타일 규칙

**업데이트**: 컴포넌트 추가/변경 시

### docs repo Wiki (선택)

다음 구조로 Wiki를 구성합니다.

```
Home
├── 문서 작성 가이드
├── 마크다운 컨벤션
└── 문서 리뷰 프로세스
```

**목적**: 문서 작성 규칙 (필요 시에만)

**사용 빈도**: 낮음

---

## Docs Repo 구조

### 디렉토리 구조

다음 디렉토리 구조를 사용합니다.

```
docs/
├── requirements/              # 요구사항
├── design/                    # 설계 문서
├── decisions/                 # ADR
├── meeting-notes/             # 회의록
├── guides/                    # 팀 가이드
└── reports/                   # 보고서
```

### requirements/

**내용**: 프로젝트 요구사항 정의

**파일**:
- 기능명세서.md
- 비기능요구사항.md
- 사용자스토리.md

**작성 시점**: 프로젝트 시작 초기

**작성자**: 전체 팀원

**업데이트**: 요구사항 변경 시

### design/

**내용**: 설계 문서 및 다이어그램

**파일**:
- ERD.png
- 시스템아키텍처.png
- API설계.md
- 화면설계/ (와이어프레임, Figma 링크)

**작성 시점**: 개발 시작 전

**작성자**: 설계 담당자

**업데이트**: 설계 변경 시

### decisions/

**내용**: ADR (Architecture Decision Record)

**파일 명명**: `번호-제목.md` (001, 002, 003...)

**작성 시점**: Discussions 논의 완료 후

**작성자**: 논의 주도자

**업데이트**: 결정 변경 시 새 ADR 작성

**ADR 필수 항목**:
- 날짜, 상태
- 배경
- 고려한 옵션 (장단점)
- 최종 결정
- 근거
- 영향
- 참고 링크

### meeting-notes/

**내용**: 팀 회의 기록

**파일 명명**: `YYYY-MM-DD-회의명.md`

**작성 시점**: 회의 직후

**작성자**: 회의 서기 (순번제)

**업데이트**: 액션 아이템 완료 시

**필수 항목**:
- 날짜, 참석자, 시간
- 안건
- 논의 내용
- 액션 아이템 (체크리스트)
- 다음 회의 일정

### guides/

**내용**: 팀 프로세스 및 컨벤션

**파일**:
- Git-브랜치-전략.md
- 코드리뷰-가이드.md
- 커밋-컨벤션.md
- 배포-프로세스.md

**작성 시점**: 프로젝트 초기 또는 필요 시

**작성자**: 전체 팀원 협의

**업데이트**: 프로세스 변경 시

### reports/

**내용**: 외부 제출용 보고서

**파일**:
- 주간보고.md
- 최종보고서.md

**작성 시점**: 보고 주기, 프로젝트 종료 시

**작성자**: 팀 대표 또는 순번제

---

## Repository별 README

### be repo README.md

**목적**: 5분 안에 로컬 실행 가능하도록

**필수 섹션**:
- 빠른 시작 (설치 및 실행 명령어)
- 사전 요구사항
- 실행 확인 (URL)
- 기술 스택
- 주요 스크립트
- 프로젝트 구조
- 환경 변수
- 문서 링크 (Wiki)
- 관련 저장소

**작성 원칙**:
- 코드 블록 위주
- 명령어는 복사 가능하게
- 상세 설명은 Wiki로 링크

### fe repo README.md

**목적**: 5분 안에 로컬 실행 가능하도록

**필수 섹션**:
- 빠른 시작 (설치 및 실행 명령어)
- 사전 요구사항
- 실행 확인 (URL)
- 기술 스택
- 주요 스크립트
- 프로젝트 구조
- 환경 변수
- 스타일 가이드 요약
- 문서 링크 (Wiki)
- 관련 저장소

**작성 원칙**:
- 코드 블록 위주
- 명령어는 복사 가능하게
- 상세 설명은 Wiki로 링크

### docs repo README.md

**목적**: 문서 찾기 쉽게

**필수 섹션**:
- 개요
- 디렉토리 구조 (전체 트리)
- 각 디렉토리 설명 (표 형식)
  - 내용
  - 작성 시점
  - 담당자
  - 파일 예시
- 문서 작성 규칙
- 관련 저장소

**작성 원칙**:
- 디렉토리 구조를 트리로 명확히
- 각 디렉토리의 목적과 파일 종류 설명
- 언제, 누가 작성하는지 명시

---

## Organization Profile README

**위치**: `org/.github/profile/README.md`

**목적**: 프로젝트 전체 소개 (포트폴리오용)

**필수 섹션**:
1. 프로젝트명 및 한 줄 설명
2. 기술 스택 뱃지
3. 프로젝트 개요 (기간, 팀 구성, 목적)
4. 주요 기능
5. 기술 스택 (상세)
6. 저장소 링크 (표)
7. 시스템 아키텍처 다이어그램
8. ERD 이미지
9. 빠른 시작 (Backend/Frontend)
10. 문서 링크 (표)
11. 개발 프로세스 (브랜치 전략, 커밋 규칙, CI/CD)
12. 팀원 정보 (표)
13. 프로젝트 진행 상황
14. 학습 내용
15. 라이센스
16. 문의

**작성 원칙**:
- 시각적 요소 활용 (뱃지, 다이어그램, 이미지)
- 포트폴리오 관점에서 작성
- 기술적 의사결정과 성과 강조
- 외부인이 봐도 이해 가능하게

---

## 문서 작성 타이밍

| 단계 | 작성 문서 | 도구 | 담당자 |
|------|----------|------|--------|
| 프로젝트 시작 | 요구사항 명세서, 사용자 스토리 | Docs repo | 전체 팀원 |
| 기술 논의 중 | 기술 선택 Discussion | Discussions | 논의 참여자 |
| 기술 결정 후 | ADR 문서 | Docs repo | 논의 주도자 |
| 설계 단계 | ERD, 시스템 아키텍처, API 설계 | Docs repo | 설계 담당자 |
| Sprint Planning | 회의록, Jira Task | Docs repo + Jira | 전체 팀원 |
| 개발 중 | API 문서, 컴포넌트 가이드 | Wiki | 개발자 |
| 개발 완료 후 | README 업데이트 | Repository | 담당 개발자 |
| Sprint 종료 | 회고 Discussion, 회의록 | Discussions + Docs | 전체 팀원 |
| 주간 단위 | 주간 보고서 | Docs repo | 순번제 |
| 프로젝트 종료 | 최종 보고서, Organization README | Docs repo | 팀 대표 |

---

## 빠른 참조

### 상황별 도구 선택

| 상황 | 도구 |
|------|------|
| 급한 질문 | Discord |
| 기술 선택 논의 | Discussions |
| 작업 할당 | Jira |
| API 스펙 확인 | Wiki (be) |
| 컴포넌트 사용법 | Wiki (fe) |
| ERD 확인 | Docs repo |
| 로컬 실행 방법 | README (be/fe) |
| 프로젝트 소개 | README (org) |
| 회의 기록 | Docs repo |
| 트러블슈팅 기록 | Discussions → Wiki |

### 문서 업데이트 주기

| 문서 | 업데이트 주기 | 담당 |
|------|--------------|------|
| API 문서 (Wiki) | 기능 추가 시마다 | 개발자 |
| README | 주요 변경 시 | 개발자 |
| ADR | 기술 결정 시 | 논의 주도자 |
| 회의록 | 회의 직후 | 회의 서기 |
| 주간 보고서 | 매주 금요일 | 순번제 |
| Organization README | Sprint 종료 시 | 팀 대표 |

---

## 관련 문서

* [Discussions 가이드](./discussions-guide.md)
* [Jira 가이드](./jira-guide.md)
* [Wiki 가이드](./wiki-guide.md)
* [Discord 가이드](./discord-guide.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.09.30 | 왕택준 | 최초 작성 |
