# Wiki 운영 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.02

**문서 버전 (Version)**: v0.2

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: API 문서, DB 스키마, 환경 설정을 Wiki에서 참조하고 업데이트하는 담당자
* **프론트엔드 개발자**: 컴포넌트 가이드, 상태관리, 스타일 규칙을 Wiki에서 참조하는 담당자
* **DevOps / 인프라 엔지니어**: 배포 스크립트, 환경 변수, 인프라 설정을 Wiki에 문서화하는 담당자
* **신규 합류자**: Wiki를 통해 빠르게 개발 환경을 세팅하고 프로젝트 구조를 파악해야 하는 팀 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 GitHub Wiki 운영 방식을 정의합니다.
Wiki는 개발자가 개발 중 즉시 참조하는 살아있는 레퍼런스로, PR 없이 직접 편집 가능하며 항상 최신 상태를 유지합니다.
Repository별로 Wiki 구조를 정의하며, 네이밍은 영문 kebab-case를 사용하고 약어는 대문자를 유지합니다.
Docs Wiki는 Draft 작업장으로, BE/FE Wiki는 개발 참조 문서로 역할이 구분됩니다.
프로젝트 종료 시 Wiki 내용을 Docs Repo로 아카이브하여 포트폴리오용으로 보관합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Wiki의 역할](#wiki의-역할)
3. [다른 도구와의 관계](#다른-도구와의-관계)
4. [Wiki 사용 원칙](#wiki-사용-원칙)
5. [Repository별 Wiki 구조](#repository별-wiki-구조)
6. [Wiki 네이밍 규칙](#wiki-네이밍-규칙)
7. [Wiki 작성 규칙](#wiki-작성-규칙)
8. [Edit Message 규칙](#edit-message-규칙)
9. [Wiki 업데이트 원칙](#wiki-업데이트-원칙)
10. [Wiki 유지보수](#wiki-유지보수)
11. [프로젝트 종료 시 아카이브](#프로젝트-종료-시-아카이브)
12. [빠른 참조](#빠른-참조)

---

## 문서 개요 (Overview)

본 문서는 프로젝트 팀에서 사용하는 GitHub Wiki 운영 방식을 정의하기 위해 작성되었습니다.

개발 프로젝트에서는 API 문서, 환경 설정, 컴포넌트 가이드 등 자주 변경되는 참조 문서가 필요합니다.
이러한 문서들은 공식 문서로 관리하기에는 변경이 너무 잦고, Discussions로 관리하기에는 구조화가 부족합니다.

Wiki는 이러한 살아있는 참조 문서를 관리하기 위한 도구로, 개발자가 즉시 참조하고 수정할 수 있는 특징을 가집니다.
본 문서는 Wiki의 역할, 다른 도구와의 구분, Repository별 구조, 작성 규칙을 정의하여
팀 전체가 효과적으로 Wiki를 활용할 수 있도록 합니다.

---

## Wiki의 역할

### Wiki의 이중 역할

Wiki는 Repository에 따라 2가지 역할로 구분됩니다:

#### 1. Draft 작업장 (Docs Repo Wiki)

- 모든 문서는 여기서 작성
- 팀 피드백 받으며 수정 (v0.1 → v0.2 → v0.3)
- 확정 후 Docs Repo로 이동
- Draft 버전은 wiki-snapshots에 보관

#### 2. 개발 참조 문서 (BE/FE Repo Wiki)

- 개발 중 즉시 참조하는 살아있는 레퍼런스
- PR 없이 브라우저에서 직접 편집
- 항상 최신 상태 유지
- Docs Repo로 이동하지 않음 (영구 보관)

### 핵심 특징

- **즉시성**: PR 없이 브라우저에서 직접 편집
- **최신성**: 항상 현재 상태를 반영
- **접근성**: 5분 내 로컬 실행 가능하도록 작성
- **실용성**: 코드 예시와 명령어 위주

---

## 다른 도구와의 관계

### Discussions vs Wiki vs Docs Repo

| 구분    | Discussions | Wiki (Draft)   | Wiki (개발 참조) | Docs Repo     |
|-------|-------------|----------------|--------------|---------------|
| 주요 목적 | 논의 과정 기록    | Draft 작업장      | 개발 참조 문서     | 공식 문서화        |
| 문서 성격 | 대화 중심, 과정   | 작성 중, 임시       | 살아있는 문서, 현재  | 확정된 문서, 특정 시점 |
| 작성 방식 | 토론 형식       | 브라우저 즉시 수정     | 브라우저 즉시 수정   | PR 기반, 리뷰 거침  |
| 변경 빈도 | 3일간 논의 후 종료 | v0.1→v0.2→v0.3 | 매주 (개발 중 계속) | 분기별 (확정 후 고정) |
| 버전 관리 | 불필요         | v0.x (Draft)   | 불필요 (최신만)    | 필수 (Git 히스토리) |

### 도구 간 정보 흐름

```
Discussions (논의)
    ↓
    ├─→ Docs Wiki (Draft 작성 v0.1 → v0.2 → v0.3)
    │      ↓
    │   Docs Repo (v1.0 확정)
    │      ↓
    │   wiki-snapshots (Draft 보관)
    │
    └─→ BE/FE Wiki (개발 참조 문서, 영구 보관)
```

### 역할 구분 예시

| 내용             | 올바른 위치          | 이유         |
|----------------|-----------------|------------|
| API 엔드포인트 목록   | BE Wiki         | 개발 중 계속 변경 |
| "왜 JWT를 선택했나?" | Docs Repo (ADR) | 의사결정 기록    |
| JWT 구현 논의 과정   | Discussions     | 논의 과정 보존   |
| JWT 사용법        | BE Wiki         | 개발자 참조 문서  |
| 최종 확정 ERD      | Docs Repo       | 버전 관리 필요   |
| 현재 DB 스키마      | BE Wiki         | 개발 중 변경 사항 |
| CORS 에러 해결 과정  | Discussions     | 트러블슈팅 기록   |
| CORS 에러 해결법    | BE Wiki         | 트러블슈팅 FAQ  |
| Sprint 회고 초안   | Docs Wiki       | Draft 작업   |
| Sprint 회고 확정   | Docs Repo       | 공식 회의록     |

### Wiki vs README

| 내용         | 위치        |
|------------|-----------|
| 5분 내 실행 방법 | README.md |
| 상세 환경 설정   | Wiki      |
| 기술 스택 목록   | README.md |
| API 전체 문서  | Wiki      |
| 프로젝트 개요    | README.md |
| 트러블슈팅 FAQ  | Wiki      |

**원칙**: README는 개요, Wiki는 상세

---

## Wiki 사용 원칙

### 1. 즉시성 (Immediacy)

PR 없이 직접 편집 가능합니다.
개발 중 발견한 사항을 즉시 반영합니다.

### 2. 접근성 (Accessibility)

신규 팀원이 가장 먼저 참조하는 문서입니다.
5분 내 로컬 환경 실행 가능하도록 작성합니다.

### 3. 최신성 (Currency)

항상 최신 상태를 유지합니다.
오래된 정보는 즉시 삭제 또는 수정합니다.

### 4. 실용성 (Practicality)

이론보다 실무 중심으로 작성합니다.
코드 예시와 명령어 위주로 구성합니다.

---

## Repository별 Wiki 구조

### Docs Repo Wiki

**역할**: Draft 작업장 (임시 공간)

```
Home
├── Sprint 회고
├── 회의록
├── 협업 문서
├── 기술 문서
├── 설계 문서
└── 기타 문서
```

**특징**:

- Draft 문서 작성 (v0.1, v0.2, v0.3...)
- 팀 피드백 받으며 수정
- 확정 후 Docs Repo로 이동
- Draft 버전은 wiki-snapshots에 보관

**페이지 네이밍**: `Draft-[문서명]` (ex. Draft-Sprint-1-Retrospective)

**템플릿 참고**: Docs Repo의 템플릿 파일들을 참고하여 작성

**목적**: 문서 작성 및 검토 공간

**업데이트**: 문서 작성 시

---

### Backend Repo Wiki

**역할**: 백엔드 개발 참조 문서 (영구 보관)

```
Home
├── 빠른 시작
├── API 문서
├── 데이터베이스
├── 인증/인가
├── 개발 가이드
└── 트러블슈팅
```

**특징**:

- 개발 중 계속 업데이트
- Docs Repo로 이동하지 않음
- 항상 최신 상태 유지

**페이지 네이밍**: `BE-[카테고리]-[이름]` (ex. BE-API-Auth)

**템플릿 참고**: 자유 형식 또는 기존 페이지 구조 참고

**목적**: 백엔드 개발자 빠른 참조

**업데이트**: 개발 중 수시로

---

### Frontend Repo Wiki

**역할**: 프론트엔드 개발 참조 문서 (영구 보관)

```
Home
├── 빠른 시작
├── 컴포넌트
├── 상태 관리
├── 라우팅
├── 스타일링
├── 개발 가이드
└── 트러블슈팅
```

**특징**:

- 개발 중 계속 업데이트
- Docs Repo로 이동하지 않음
- 항상 최신 상태 유지

**페이지 네이밍**: `FE-[카테고리]-[이름]` (ex. FE-Component-Button)

**템플릿 참고**: 자유 형식 또는 기존 페이지 구조 참고

**목적**: 프론트엔드 개발자 빠른 참조

**업데이트**: 컴포넌트 추가/변경 시

---

## Wiki 네이밍 규칙

### 기본 원칙

- 영문 사용 (한글 금지)
- 공백은 하이픈(-) 사용
- 약어는 대문자 유지: API, DB, URL, JWT (소문자 api, db 금지)

### 형식

**Docs Wiki:**

```
Draft-[문서명]
```

**BE/FE Wiki:**

```
[Prefix]-[Category]-[Topic]
```

또는

```
[Prefix]-[Topic]
```

### 예시

| Repo     | 좋은 예                         | 나쁜 예                   | 이유           |
|----------|------------------------------|------------------------|--------------|
| Docs     | Draft-Sprint-1-Retrospective | sprint-1-retrospective | Draft 접두사 필수 |
| Backend  | BE-API-Auth                  | api-auth               | 접두사 필수       |
| Backend  | BE-DB-Schema                 | BE-Database-Schema     | 약어 사용        |
| Frontend | FE-Component-Button          | FE-component-button    | 대소문자 규칙      |
| 공통       | API-Auth                     | api-auth               | 약어는 대문자      |

### 주요 카테고리 접두사

**Docs Wiki:**

- **Draft-**: Draft 문서 (모든 작성 중 문서)

**Backend Wiki:**

- **BE-API-**: API 문서
- **BE-DB-**: 데이터베이스
- **BE-Setup-**: 환경 설정
- **BE-Troubleshooting-**: 문제 해결

**Frontend Wiki:**

- **FE-Component-**: 컴포넌트
- **FE-Setup-**: 환경 설정
- **FE-Troubleshooting-**: 문제 해결

---

## Wiki 작성 규칙

### 페이지 구조

```markdown
# 페이지 제목

## 개요

목적과 범위

## 사전 요구사항

필요한 도구/지식

## 본문

단계별 설명 및 코드 예시

## 참고 링크

관련 문서 링크

```

---

## Edit Message 규칙

GitHub Wiki는 Git 기반이므로 모든 변경사항에 Edit message를 작성해야 합니다.

### 작성 규칙

- **최초 생성**: `Initial [페이지명]`
- **내용 추가**: `Add [추가한 내용]`
- **내용 수정**: `Update [수정한 부분]`
- **내용 삭제**: `Remove [삭제한 부분]`

### 예시

| 상황                | Edit Message                             |
|-------------------|------------------------------------------|
| Home 페이지 최초 생성    | `Initial Home page`                      |
| API 문서 추가         | `Add BE-API-Auth page`                   |
| 트러블슈팅 섹션 업데이트     | `Update troubleshooting section`         |
| 오래된 Setup 가이드 삭제  | `Remove deprecated setup guide`          |
| Draft 회고록 v0.2 수정 | `Update Sprint 1 retrospective feedback` |

### 작성 원칙

- 간결하게 작성 (한 줄)
- 영문 사용
- 무엇을 변경했는지 명확하게

---

## Wiki 업데이트 원칙

### Docs Wiki (Draft 작업장)

**업데이트 시점:**

| 상황                | Wiki 업데이트 내용               |
|-------------------|----------------------------|
| 회고 회의 종료          | Draft 회고록 작성 (v0.1)        |
| 팀원 피드백            | Draft 버전 업데이트 (v0.2, v0.3) |
| PO 승인 완료          | Docs Repo로 이동 후 Wiki 삭제    |
| Discussions 토론 완료 | ADR Draft 작성               |

**워크플로우:**

```
1. Draft 작성 (v0.1)
   ↓
2. Discord 검토 요청
   ↓
3. 피드백 반영 (v0.2, v0.3)
   ↓
4. Docs Repo 이동 (v1.0)
   ↓
5. Wiki 삭제 → wiki-snapshots 보관
```

---

### BE/FE Wiki (개발 참조 문서)

**업데이트 시점:**

| 상황        | Wiki 업데이트 내용           |
|-----------|------------------------|
| 새 API 추가  | API 문서 페이지 추가          |
| 환경 변수 변경  | Setup 페이지 수정           |
| 새 컴포넌트 추가 | Component 가이드 추가       |
| 트러블슈팅 해결  | Troubleshooting 페이지 기록 |
| 코딩 컨벤션 변경 | Conventions 페이지 수정     |

**워크플로우:**

```
1. 개발 완료
   ↓
2. Wiki 업데이트 필요성 확인
   ↓
3. Wiki 페이지 편집 (브라우저에서 직접)
   ↓
4. 개발 코드 PR 머지
```

**주의**: Wiki 업데이트는 PR과 별개로 진행됩니다.

---

### 업데이트 책임자

- **개발자**: 본인 작업 내용은 본인이 업데이트
- **리뷰어**: PR 리뷰 시 Wiki 업데이트 여부 확인
- **신규 팀원**: 불명확한 부분 발견 시 보완

---

## Wiki 유지보수

### 정기 검토

- **주기**: 스프린트 종료 시 (1주마다)
- **담당**: 순번제

### 체크리스트

[] 오래된 정보 제거
[] 깨진 링크 수정
[] 중복 내용 통합
[] 누락된 API 문서 확인
[] 환경 변수 최신화

### 버전 관리

Wiki는 Git 저장소이므로 변경 이력 추적이 가능합니다.

잘못된 수정 시 히스토리에서 복구할 수 있습니다.

```bash
# Wiki 저장소 클론
git clone https://github.com/org/repo.wiki.git

# 히스토리 확인
git log

# 특정 버전으로 복구
git revert <commit-hash>
```

---

## 프로젝트 종료 시 아카이브

### 시점

- 프로젝트 종료 1-2일 전
- 최종 배포 직후

### 아카이브 프로세스

#### 1단계: Wiki 정리

- [ ] 오래된 내용 삭제
- [ ] 최신 상태 확인
- [ ] 임시 메모 제거
- [ ] 링크 유효성 확인

#### 2단계: Docs Repo로 이관

**디렉토리 구조:**

```
docs/archive/final-reference/
├── backend/
│   ├── api-docs.md
│   ├── db-schema.md
│   ├── setup.md
│   └── troubleshooting.md
└── frontend/
    ├── components.md
    ├── state-management.md
    ├── setup.md
    └── troubleshooting.md
```

**실행 방법:**

```bash
# Wiki 저장소 클론
git clone https://github.com/org/be.wiki.git wiki-be
git clone https://github.com/org/fe.wiki.git wiki-fe

# Docs Repo에 복사
cd docs
mkdir -p archive/final-reference/backend
mkdir -p archive/final-reference/frontend

# Wiki 내용 복사
cp ../wiki-be/*.md archive/final-reference/backend/
cp ../wiki-fe/*.md archive/final-reference/frontend/

# 커밋 및 푸시
git add archive/
git commit -m "docs: Wiki 아카이브 (프로젝트 종료)"
git push origin main
```

#### 3단계: README 업데이트

**Organization README에 아카이브 링크 추가:**

```markdown
## 아카이브 문서

프로젝트 종료 시점의 최종 참조 문서:

- [백엔드 참조 문서](./docs/archive/final-reference/backend/)
- [프론트엔드 참조 문서](./docs/archive/final-reference/frontend/)
```

### 아카이브 목적

- Wiki는 저장소 삭제 시 사라짐
- Docs Repo에 백업하여 포트폴리오용으로 보관
- 인수인계 문서로 활용
- 프로젝트 회고 및 학습 자료로 활용

---

## 빠른 참조

### Wiki 사용 여부 결정

| 질문            | Wiki 사용 | 올바른 위치      |
|---------------|---------|-------------|
| API 엔드포인트 확인? | ☑️      | BE Wiki     |
| 로컬 환경 세팅?     | ☑️      | BE/FE Wiki  |
| 회고록 작성?       | ☑️      | Docs Wiki   |
| 왜 이 기술 선택?    | ❌       | Discussions |
| Task 진행 상황?   | ❌       | Jira        |
| 최종 ERD?       | ❌       | Docs Repo   |
| 급한 질문?        | ❌       | Discord     |

### Wiki 페이지 생성 체크리스트

새 페이지 생성 시:

[] 네이밍 규칙 준수 (Draft- 또는 BE-/FE- 접두사)
[] 페이지 구조 포함 (개요, 사전요구사항, 본문, 참고링크)
[] 코드 블록에 언어 지정
[] 실행 가능한 명령어 포함
[] 관련 페이지 링크 추가
[] Edit message 작성

### Repo별 Wiki 요약

| Repo     | 역할        | 네이밍            | 보관 기간        | 템플릿 참고        |
|----------|-----------|----------------|--------------|---------------|
| Docs     | Draft 작업장 | Draft-[문서명]    | 임시 (확정 후 삭제) | Docs Repo 템플릿 |
| Backend  | 개발 참조 문서  | BE-[카테고리]-[이름] | 영구           | 자유 형식         |
| Frontend | 개발 참조 문서  | FE-[카테고리]-[이름] | 영구           | 자유 형식         |

---

## 관련 문서

* [협업 도구 가이드](./collaboration-guide.md)
* [Discussions 가이드](./discussions-guide.md)
* [Discord 가이드](./discord-guide.md)
* [Jira 가이드](./jira-guide.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용                                     |
|------|------------|-----|----------------------------------------------|
| v0.1 | 2025.10.02 | 왕택준 | 최초 작성                                        |
| v0.2 | 2025.10.11 | 왕택준 | 실제 Wiki 구조 반영, Edit Message 규칙 추가, 템플릿 참고 명시 |
