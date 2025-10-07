# 협업 도구 워크플로우 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.09.30

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 팀원**: 협업 도구의 역할과 사용 시점을 이해하고 올바른 도구를 선택해야 하는 모든 팀원
* **신규 합류자**: 팀의 협업 구조를 빠르게 파악하고 각 도구의 목적을 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트 팀에서 사용하는 협업 도구의 역할과 문서 작성 흐름을 정의합니다.
Discord는 실시간 소통, Discussions는 구조화된 토론, Wiki는 Draft 작업장, Docs Repo는 최종 문서 저장소로 역할이 구분됩니다.
문서는 긴급도와 중요도에 따라 3가지 흐름으로 관리됩니다: 긴급 문서(즉시 반영), 일반 문서(Wiki Draft → Docs Repo), 기술 문서(Discussions → Wiki Draft → Docs Repo).
Wiki에서 작성된 Draft 버전(v0.x)은 최종 승인 후 docs/archive/wiki-snapshots/로 보존되어 작업 과정 히스토리를 기록합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [도구별 역할 요약](#도구별-역할-요약)
3. [문서 작성 3가지 흐름](#문서-작성-3가지-흐름)
4. [Wiki의 이중 역할](#wiki의-이중-역할)
5. [버전 관리 체계](#버전-관리-체계)
6. [도구 간 전환 기준](#도구-간-전환-기준)
7. [전체 워크플로우 예시](#전체-워크플로우-예시)
8. [상황별 도구 선택 가이드](#상황별-도구-선택-가이드)
9. [빠른 참조](#빠른-참조)
10. [관련 문서](#관련-문서)

---

## 문서 개요 (Overview)

본 문서는 팀 내 협업 도구의 역할과 사용 시점을 명확히 하기 위해 작성되었습니다.

프로젝트에서 여러 협업 도구를 사용하면 "이 내용을 어디에 작성해야 하나?"라는 질문이 반복됩니다. 잘못된 도구 선택은 정보 분산과 중복 작업을 초래합니다.

본 문서는 Discord, Discussions, Wiki, Docs Repo의 역할과 전환 기준을 정의하여, 팀원 누구나 올바른 도구를 선택할 수 있도록 합니다. 각 도구의 세부 사용법은 별도 가이드를 참조하세요.

---

## 도구별 역할 요약

| 도구 | 역할 | 버전 관리 | 보존 여부 | 사용 예시 |
|------|------|----------|-----------|----------|
| **Discord** | 실시간 소통 | - | 일시적 | 긴급 이슈, 간단한 질문, 음성 회의 |
| **Discussions** | 구조화된 토론 | - | 영구 보존 | 기술 선택 논의, 아키텍처 설계 토론 |
| **Wiki** | Draft 작업장 | v0.1, v0.2... | 임시 (확정 후 Archive) | 문서 초안 작성 및 팀 피드백 반영 |
| **Docs Repo** | 최종 문서 저장소 | v1.0 이상 | 영구 보존 | 공식 문서, 요구사항 명세서, 회의록 |
| **wiki-snapshots** | Draft 히스토리 | v0.x 아카이브 | 영구 보존 | Wiki Draft 버전 보존 |
| **Jira** | 작업 관리 | - | 영구 보존 | Task 생성/할당, 진행 상황, 스프린트 |

---

## 문서 작성 3가지 흐름

### 1. 긴급 문서 (즉시 반영)

```
Discord (실시간 논의)
   → 협업을 위한 빠른 문서화
      ↓
Docs Repository (즉시 v1.0 반영)
```

**대상 문서:**
- 협업 도구 사용법 가이드
- 긴급 공지
- 즉시 공유 필요한 설정 방법

**특징:**
- Wiki/Discussions 건너뛰고 바로 반영
- 검토 과정 최소화
- 빠른 정보 공유 우선

**예시:**
- Discord: "Jira 계정 설정 방법 공유합니다"
- 즉시 Docs Repo: `processes/collaboration/jira-guide.md` (v1.0)

---

### 2. 일반 문서 (검토 후 반영)

```
Discord (실시간 논의)
   → "문서 올라왔으니 확인 부탁드립니다"
      ↓
Wiki (v0.1, v0.2, v0.3... 계속 업데이트)
   → 팀원 피드백 반영하며 수정
      ↓
Docs Repository (v1.0 Approved 최종본)
   → 공식 문서로 확정
      ↓
docs/archive/wiki-snapshots/ (v0.x Draft 버전들 보존)
```

**대상 문서:**
- **Sprint 회고록**
- 회의록
- 일반 프로세스 문서
- 가이드 문서

**특징:**
- Wiki에서 Draft 작업 (v0.1 → v0.2 → v0.3)
- 팀원 피드백을 실시간으로 반영
- 확정 후 Docs Repo에 v1.0 반영
- Draft 버전들은 Archive에 히스토리 보존

**예시:**
```
1. Wiki: sprint-1-retrospective.md (v0.1)
   - SM이 회고 회의 후 초안 작성

2. Discord: "회고록 올렸습니다, 확인 부탁드립니다"

3. Wiki: sprint-1-retrospective.md (v0.2)
   - 김경민 피드백 반영

4. Wiki: sprint-1-retrospective.md (v0.3)
   - 진도희 피드백 반영

5. Docs Repo: docs/meetings/sprint-retrospective/team/sprint-1-retrospective.md (v1.0 Approved)
   - PO 최종 승인 및 반영

6. Archive: docs/archive/wiki-snapshots/
   - sprint-1-retrospective-v0.1.md
   - sprint-1-retrospective-v0.2.md
   - sprint-1-retrospective-v0.3.md
```

---

### 3. 기술 문서 (회의 + 토론 필요)

```
Discord (실시간 논의)
   → 음성/채팅/오프라인 간단한 회의
      ↓
GitHub Discussions (구조화된 토론)
   → 팀원들과 기록 남기며 회의
      ↓
Wiki (v0.1, v0.2, v0.3... 계속 업데이트)
   → Discussions 내용 기반 문서화
      ↓
Docs Repository (v1.0 Approved 최종본)
   → 공식 문서로 확정
      ↓
docs/archive/wiki-snapshots/ (v0.x Draft 버전들 보존)
```

**대상 문서:**
- 아키텍처 설계 문서
- API 설계 문서
- 기술 스택 결정 문서
- DB 스키마 설계
- ADR (Architecture Decision Record)

**특징:**
- Discussions에서 먼저 구조화된 토론
- 합의 후 Wiki에서 문서화
- 전체 프로세스를 다 거침 (가장 신중)
- 의사결정 과정이 Discussions에 영구 보존

**예시:**
```
1. Discord: "인증 방식 어떻게 할까요? JWT? Session?"

2. Discussions: [BE][Architecture] 인증 방식 선택 - JWT vs Session
   - 3일간 팀 토론
   - 옵션 비교 (장단점)
   - 최종 합의: JWT 선택

3. Wiki: adr-001-jwt-authentication.md (v0.1)
   - Discussions 내용 기반 ADR 초안 작성

4. Wiki: adr-001-jwt-authentication.md (v0.2)
   - 팀 피드백 반영

5. Docs Repo: docs/decisions/001-jwt-authentication.md (v1.0 Approved)
   - 공식 ADR 문서

6. Archive: docs/archive/wiki-snapshots/
   - adr-001-jwt-authentication-v0.1.md
   - adr-001-jwt-authentication-v0.2.md
```

---

## Wiki의 이중 역할

### 역할 1: Draft 작업장 (임시)

**문서 작성 중일 때 Wiki가 Draft 저장소 역할을 합니다.**

```
Wiki (v0.1) → Wiki (v0.2) → Wiki (v0.3) → Docs Repo (v1.0)
                                             ↓
                                    wiki-snapshots (v0.x 보존)
```

**워크플로우:**
1. Wiki에 v0.1 초안 작성
2. Discord에 공지 및 팀원 검토 요청
3. 팀원 피드백으로 v0.2, v0.3... 반복 수정
4. PO 승인 후 Docs Repo에 v1.0 반영
5. Wiki의 Draft 버전들을 wiki-snapshots로 이동

**대상 문서:**
- Sprint 회고록
- ADR (Architecture Decision Record)
- 회의록
- 설계 문서
- 정책 문서

**예시:**
- Wiki: `sprint-1-retrospective.md` (v0.1 → v0.2 → v0.3)
- 확정 후 Docs Repo: `docs/meetings/sprint-retrospective/team/sprint-1-retrospective.md` (v1.0)
- Archive: `docs/archive/wiki-snapshots/sprint-1-retrospective-v0.x.md`

---

### 역할 2: 개발 참조 문서 (영구)

**확정 후에도 자주 변경되는 문서는 Wiki에 영구 보관합니다.**

```
Docs Repo (최종 ERD v1.0, 확정) ←→ Wiki (현재 DB 스키마, 계속 업데이트)
```

**대상 문서:**
- API 엔드포인트 목록
- 현재 DB 스키마
- 환경 변수 설정
- 트러블슈팅 FAQ
- 로컬 개발 환경 가이드
- 코딩 컨벤션

**예시:**
- Docs Repo: `design/database/final-erd.md` (v1.0 확정, 변경 없음)
- Wiki: `Current-DB-Schema` (개발 중 계속 업데이트)

**특징:**
- Docs Repo로 이동하지 않음
- 개발 진행에 따라 실시간 업데이트
- 개발자가 가장 자주 참조하는 문서

---

## 버전 관리 체계

### 버전 번호 규칙

| 버전 | 위치 | 상태 | 설명 |
|------|------|------|------|
| **v0.1** | Wiki | Draft | 최초 초안 |
| **v0.2, v0.3...** | Wiki | Draft | 피드백 반영 수정본 |
| **v1.0** | Docs Repo | Approved | 최종 승인본 |
| **v1.1, v1.2...** | Docs Repo | Approved | 승인 후 수정본 |

### 문서 상태 (Status)

| 상태 | 의미 | 위치 |
|------|------|------|
| **Draft** | 작성 중 | Wiki |
| **Approved** | 승인 완료 | Docs Repo |
| **Deprecated** | 폐기됨 | docs/archive/deprecated/ |

### 문서 생명주기 및 보관 위치

#### 1. Draft 문서 (Wiki)
```markdown
**문서 버전 (Version)**: v0.1, v0.2, v0.3...
**문서 상태 (Status)**: Draft
```
**위치**: GitHub Wiki
**특징**: 팀원 피드백을 받으며 계속 수정

#### 2. Approved 문서 (Docs Repo)
```markdown
**문서 버전 (Version)**: v1.0
**문서 상태 (Status)**: Approved
```
**위치**: Docs Repository (해당 카테고리 폴더)
**특징**: PO 승인 완료, 공식 문서

#### 3. Draft 아카이브 (wiki-snapshots)
```markdown
**문서 버전 (Version)**: v0.1, v0.2, v0.3...
**문서 상태 (Status)**: Archived
```
**위치**: `docs/archive/wiki-snapshots/`
**특징**: Wiki에서 작업했던 Draft 버전 보존
**이동 시점**: Docs Repo에 v1.0 반영 후

**예시:**
```
docs/archive/wiki-snapshots/
├── sprint-1-retrospective-v0.1.md
├── sprint-1-retrospective-v0.2.md
├── sprint-1-retrospective-v0.3.md
├── adr-001-jwt-v0.1.md
└── adr-001-jwt-v0.2.md
```

#### 4. 폐기 문서 (deprecated)
```markdown
**문서 버전 (Version)**: v1.0, v1.1... (상관 없음)
**문서 상태 (Status)**: Deprecated
```
**위치**: `docs/archive/deprecated/`
**특징**: 더 이상 유효하지 않은 문서
**이동 시점**:
- 새로운 문서로 대체됨
- 정책 변경으로 무효화됨
- 프로젝트 방향 변경으로 사용 안 함

**예시:**
```
docs/archive/deprecated/
├── old-branching-strategy-v1.0.md  (새 전략으로 대체)
├── session-authentication-v1.0.md   (JWT로 전환)
└── docker-compose-old-v1.2.md       (인프라 변경)
```

**폐기 문서 헤더 예시:**
```markdown
# ⚠️ 폐기된 문서 - 구 브랜치 전략

**문서 버전 (Version)**: v1.0
**문서 상태 (Status)**: Deprecated
**폐기 일자**: 2025.10.15
**폐기 사유**: 새로운 브랜치 전략으로 대체됨
**대체 문서**: [branching-strategy.md](../../processes/development/git/branching-strategy.md)
```

---

### 문서 흐름 요약

```
Wiki (Draft v0.x)
   ↓ 확정
Docs Repo (Approved v1.0)
   ↓ 분기
   ├─→ wiki-snapshots (Draft 버전 보존)
   └─→ deprecated (폐기 시 이동)
```

---

## 도구 간 전환 기준

### Discord → Discussions

**전환 기준: 5분 룰**

Discord에서 5분 내 답변 불가능하면 Discussions로 이동합니다.

**이동 조건:**
- 기술적 논의가 필요한 경우
- 여러 옵션을 비교해야 하는 경우
- 의사결정 과정을 기록해야 하는 경우
- 팀 전체의 의견이 필요한 경우

**예시:**
- Discord: "Redis랑 Memcached 중 뭐가 나아?"
- 5분 내 답변 불가 → Discussions: "[BE][Architecture] 캐싱 전략: Redis vs Memcached"

---

### Discord → Wiki (일반 문서)

**전환 기준: 즉시 작성 룰**

논의 없이 바로 문서 작성이 가능한 경우 Wiki로 이동합니다.

**이동 조건:**
- 회의록, 회고록 등 기록 문서
- 단순 정리가 필요한 가이드 문서
- 팀원 검토만 필요한 문서

**예시:**
- Discord: "Sprint 1 회고 회의 완료했습니다"
- Wiki에 회고록 v0.1 작성 → Discord 공지

---

### Discussions → Wiki

**전환 기준: 합의 완료 룰**

Discussions에서 팀 합의가 완료되면 Wiki로 이동하여 문서화합니다.

**이동 조건:**
- 기술 토론 결과를 문서화할 때
- 의사결정이 확정되어 ADR 작성할 때
- 트러블슈팅 해결 과정을 정리할 때

**예시:**
- Discussions: "JWT vs Session 논의 (3일간, 합의 완료)"
- Wiki에 ADR v0.1 작성 → 팀 검토 → v1.0 Docs Repo

---

### Wiki → Docs Repo

**전환 기준: 승인 완료 룰**

Wiki에서 팀 검토가 완료되고 PO 승인이 떨어지면 Docs Repo로 이동합니다.

**이동 조건:**
- 팀원 피드백이 모두 반영됨
- PO(왕택준)의 최종 승인 완료
- 더 이상 수정할 내용이 없음

**워크플로우:**
1. Wiki Draft 완료 (v0.x)
2. PO 최종 검토
3. Docs Repo에 PR 생성 (v1.0)
4. PR 승인 및 병합
5. Wiki Draft 버전들을 wiki-snapshots로 이동

---

### Wiki → wiki-snapshots

**전환 기준: 확정 완료 룰**

Docs Repo에 v1.0이 반영되면 Wiki의 Draft 버전들을 Archive로 이동합니다.

**이동 대상:**
- Wiki에서 작성된 모든 Draft 버전 (v0.1, v0.2, v0.3...)
- 작업 과정 히스토리 보존용

**파일명 규칙:**
```
원본: sprint-1-retrospective.md
아카이브:
- sprint-1-retrospective-v0.1.md
- sprint-1-retrospective-v0.2.md
- sprint-1-retrospective-v0.3.md
```

---

## 전체 워크플로우 예시

### 시나리오 1: Sprint 회고록 작성

```
1. Sprint 1 종료
   ↓
2. Discord (#일반)
   SM(왕택준): "Sprint 1 회고 회의를 2025.10.07 14시에 진행합니다"
   ↓
3. 회고 회의 진행 (1시간)
   - What Went Well
   - What Didn't Go Well
   - What to Improve
   ↓
4. Wiki (dialogym-docs Repo)
   SM이 회고록 v0.1 작성
   - 제목: sprint-1-retrospective.md
   - 버전: v0.1
   - 상태: Draft
   ↓
5. Discord (#일반)
   SM: "Sprint 1 회고록 v0.1 올렸습니다, 확인 부탁드립니다"
   - Wiki 링크 공유
   ↓
6. Wiki (v0.2)
   김경민 피드백: "문서 작성 시간 과다 섹션 추가"
   SM이 반영하여 v0.2 업데이트
   ↓
7. Wiki (v0.3)
   진도희 피드백: "작업 불균형 개선 방안 구체화"
   SM이 반영하여 v0.3 업데이트
   ↓
8. PO 검토 (왕택준)
   최종 검토 및 승인 완료
   ↓
9. Docs Repo (PR 생성)
   파일: docs/meetings/sprint-retrospective/team/sprint-1-retrospective.md
   버전: v1.0
   상태: Approved
   ↓
10. PR 승인 및 병합
   ↓
11. wiki-snapshots 이동
   docs/archive/wiki-snapshots/
   - sprint-1-retrospective-v0.1.md
   - sprint-1-retrospective-v0.2.md
   - sprint-1-retrospective-v0.3.md
```

---

### 시나리오 2: 기술 의사결정 (JWT 인증)

```
1. Discord (#개발-질문)
   개발자: "인증 방식 어떻게 할까요? JWT? Session?"
   ↓
2. Discord (5분 내 답변 불가)
   → Discussions로 이동 결정
   ↓
3. Discussions (BE Repo - Architecture)
   제목: [BE][Architecture] 인증 방식 선택 - JWT vs Session
   - 3일간 논의
   - JWT 장단점
   - Session 장단점
   - 팀원 의견 수렴
   - 최종 합의: JWT 선택
   ↓
4. Wiki (dialogym-docs Repo)
   파일: adr-001-jwt-authentication.md
   버전: v0.1
   상태: Draft
   - Discussions 내용 기반 ADR 작성
   ↓
5. Discord (#일반)
   "ADR 001 JWT 인증 초안 올렸습니다, 확인 부탁드립니다"
   ↓
6. Wiki (v0.2)
   팀원 피드백 반영
   ↓
7. Docs Repo (PR 생성)
   파일: docs/decisions/001-jwt-authentication.md
   버전: v1.0
   상태: Approved
   ↓
8. PR 승인 및 병합
   ↓
9. wiki-snapshots 이동
   docs/archive/wiki-snapshots/
   - adr-001-jwt-authentication-v0.1.md
   - adr-001-jwt-authentication-v0.2.md
   ↓
10. Jira
   Task 생성: TRAIN-45 "JWT 인증 구현"
   ↓
11. 개발 진행
   브랜치: feature/TRAIN-45
   커밋: "TRAIN-45 feat: JWT 미들웨어 추가"
   ↓
12. Wiki (BE Repo)
   페이지: API-Auth (영구 보관)
   - JWT 사용법
   - 토큰 갱신 방법
   - 에러 처리
```

---

### 시나리오 3: 긴급 버그 발생

```
1. Discord (#긴급-이슈)
   @everyone "프로덕션 DB 연결 실패!"
   ↓
2. Discord (실시간 해결)
   - 즉시 대응
   - 원인 파악
   - 임시 조치
   ↓
3. Discussions (BE Repo - Troubleshooting)
   제목: [BE][Troubleshooting] 프로덕션 DB 연결 실패 해결 과정
   - 증상
   - 원인 분석
   - 해결 방법
   - 재발 방지책
   ↓
4. Wiki (BE Repo) [영구 보관]
   페이지: Troubleshooting-DB
   - 자주 발생하는 DB 에러
   - 해결 방법 (명령어 포함)
   ↓
5. Docs Repo (회의록)
   Post-Mortem 기록
```

---

## 상황별 도구 선택 가이드

### 질문이 생겼을 때

| 질문 유형 | 도구 | 이유 |
|----------|------|------|
| 특정 에러 경험 여부 확인 | Discord | 즉시 답변 가능 |
| 설정 방법 문의 | Wiki 먼저 확인 | 이미 문서화되어 있을 가능성 |
| 기술 선택 비교 | Discussions | 논의 필요 |
| 최종 설계 문서 위치 | Docs Repo | 공식 문서 |

---

### 정보를 공유할 때

| 공유 내용 | 도구 | 이유 |
|----------|------|------|
| 배포 완료 알림 | Discord | 실시간 알림 |
| 문제 해결 과정 | Discussions | 과정 공유 |
| 새 API 추가 안내 | Wiki (영구) | 참조 문서 업데이트 |
| 회의 결과 공유 | Wiki → Docs Repo | Draft 작업 후 확정 |

---

### 문서를 찾을 때

```
1. README 확인 (5분 내 로컬 실행)
   ↓
2. Wiki 확인 (개발 가이드, API 문서)
   ↓
3. Docs Repo 확인 (공식 문서, 설계 문서)
   ↓
4. Discussions 검색 (논의 과정)
   ↓
5. Discord에서 질문
```

---

## 빠른 참조

### 도구 선택 체크리스트

**Discord를 사용해야 할 때:**
- [ ] 5분 내 답변이 필요한가?
- [ ] 실시간 소통이 필요한가?
- [ ] 긴급한 알림인가?

**Discussions를 사용해야 할 때:**
- [ ] 여러 옵션을 비교해야 하는가?
- [ ] 팀 전체의 의견이 필요한가?
- [ ] 논의 과정을 기록해야 하는가?

**Wiki를 사용해야 할 때:**
- [ ] Draft 문서를 작성하는가?
- [ ] 팀원 피드백을 받아야 하는가?
- [ ] 개발 중 자주 참조하는 문서인가?

**Docs Repo를 사용해야 할 때:**
- [ ] 확정된 공식 문서인가?
- [ ] 버전 관리가 필요한가?
- [ ] 외부 제출용 문서인가?

---

### 헷갈리는 사례

| 내용 | 올바른 위치 | 이유 |
|------|------------|------|
| Sprint 회고록 초안 | Wiki (v0.x) | Draft 작업장 |
| Sprint 회고록 최종본 | Docs Repo (v1.0) | 공식 회의록 |
| API 엔드포인트 목록 | Wiki (영구) | 개발 중 계속 변경 |
| "왜 JWT를 선택했나?" | Docs Repo (ADR) | 의사결정 기록 |
| JWT 구현 논의 과정 | Discussions | 논의 과정 보존 |
| JWT 사용법 | Wiki (영구) | 개발자 참조 문서 |
| 최종 ERD | Docs Repo | 확정된 설계 |
| 현재 DB 스키마 | Wiki (영구) | 개발 중 변경 사항 |
| CORS 에러 해결 과정 | Discussions | 트러블슈팅 기록 |
| CORS 에러 해결법 | Wiki (영구) | FAQ |

---

### 디렉토리 구조

```
docs/
├── archive/
│   ├── deprecated/              # 폐기된 문서 (Deprecated)
│   │   ├── old-branching-strategy-v1.0.md
│   │   ├── session-authentication-v1.0.md
│   │   └── docker-compose-old-v1.2.md
│   └── wiki-snapshots/          # Wiki Draft 버전 보존 (Archived)
│       ├── sprint-1-retrospective-v0.1.md
│       ├── sprint-1-retrospective-v0.2.md
│       ├── sprint-1-retrospective-v0.3.md
│       ├── adr-001-jwt-v0.1.md
│       └── adr-001-jwt-v0.2.md
├── meetings/
│   └── sprint-retrospective/
│       └── team/
│           └── sprint-1-retrospective.md  # v1.0 Approved
└── decisions/
    └── 001-jwt-authentication.md  # v1.0 Approved
```

---

## 관련 문서

* [Discord 가이드](./discord-guide.md) - 채널 구조 및 사용 규칙
* [Discussions 가이드](./discussions-guide.md) - 카테고리 및 작성 규칙
* [Wiki 가이드](./wiki-guide.md) - Repository별 구조 및 네이밍 규칙
* [Jira 가이드](./jira-guide.md) - 워크플로우 및 이슈 타입

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.09.30 | 왕택준 | 최초 작성 |
| v0.2 | 2025.10.07 | 왕택준 | Wiki Draft 작업장 역할 명확화, 3가지 문서 흐름 추가, wiki-snapshots 아카이브 체계 반영 |
