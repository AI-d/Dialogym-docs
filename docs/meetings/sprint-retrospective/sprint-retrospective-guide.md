# Sprint 회고록 작성 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **Scrum Master**: Sprint 회고록을 작성하고 팀 회고를 주도하는 담당자
* **전체 팀원**: 회고록 작성 규칙과 형식을 이해해야 하는 구성원
* **Product Owner**: 회고록을 검토하고 다음 스프린트 계획에 반영하는 책임자
* **신규 합류자**: 팀의 회고 문화와 문서 작성 방법을 학습해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Sprint 회고록 작성 방법과 규칙을 정의합니다.
회고록은 Agile 표준 형식(What Went Well / What Didn't Go Well / What to Improve)을 따르며, 모든 Sprint 종료 후 Scrum Master가 작성합니다.
회고록은 Wiki에서 Draft 버전(v0.x)으로 작성 및 수정되며, 팀 검토와 PO 승인 후 Docs Repository에 v1.0 Approved로 반영됩니다.
Wiki의 Draft 버전들은 docs/archive/wiki-snapshots/에 보존되어 작업 과정 히스토리를 기록합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [회고록의 목적](#회고록의-목적)
3. [작성 시점 및 담당자](#작성-시점-및-담당자)
4. [작성 원칙](#작성-원칙)
5. [섹션별 작성 가이드](#섹션별-작성-가이드)
6. [회고 회의 진행 방법](#회고-회의-진행-방법)
7. [좋은 회고록 vs 나쁜 회고록](#좋은-회고록-vs-나쁜-회고록)
8. [저장 위치 및 파일명 규칙](#저장-위치-및-파일명-규칙)
9. [작성 및 승인 절차](#작성-및-승인-절차)
10. [참고 자료](#참고-자료)
11. [변경 이력](#변경-이력)

---

## 문서 개요 (Overview)

Sprint 회고록은 팀의 협업 방식과 프로세스를 지속적으로 개선하기 위한 핵심 문서입니다.
매 Sprint 종료 후 팀 전체가 참여하는 회고 회의를 통해 잘된 점, 아쉬운 점, 개선 방안을 도출하고 문서화합니다.
회고록은 단순한 기록이 아니라, 다음 Sprint에서 실제로 적용할 구체적인 액션 아이템을 포함해야 합니다.

---

## 회고록의 목적

### 1. 팀 성장 촉진
- 팀의 강점을 인식하고 강화
- 약점을 파악하고 개선 방안 도출

### 2. 프로세스 개선
- 협업 방식의 비효율성 제거
- 도구 및 자동화 개선

### 3. 투명한 커뮤니케이션
- 팀원 간 솔직한 피드백 공유
- 문제를 조기에 발견하고 해결

### 4. 지식 축적
- 프로젝트 진행 과정의 학습 기록
- 신규 합류자를 위한 히스토리 제공

---

## 작성 시점 및 담당자

### 작성 시점
- **Sprint Retrospective 회의 직후**
- Sprint 종료일로부터 1영업일 이내 Wiki에 v0.1 작성 완료

### 담당자
- **주 담당**: 해당 Sprint의 Scrum Master
- **참여**: 전체 팀원 (회고 회의에서 의견 제공, Wiki 검토)
- **검토**: Product Owner (PO)

### 작성 시간
- 약 1~2시간 (회의 1시간 + Wiki 문서 정리 1시간)

---

## 작성 원칙

### 1. 구체성 (Specificity)
❌ 나쁜 예: "커뮤니케이션이 부족했다"
☑️ 좋은 예: "Daily Scrum을 주 2회만 진행하여 작업 진행 상황 공유가 지연됨"

### 2. 객관성 (Objectivity)
- 개인 공격이 아닌 프로세스 개선에 집중
- 감정적 표현 지양, 사실 기반 서술

### 3. 실행 가능성 (Actionability)
- 모든 개선 방안은 구체적인 액션 아이템 포함
- 담당자, 기한, 방법을 명확히 정의

### 4. 균형 (Balance)
- 긍정적 피드백과 개선 사항을 균형있게 작성
- 문제점만 나열하지 않고, 잘된 점도 충분히 인정

### 5. 간결성 (Conciseness)
- 불필요한 장문 지양
- 핵심 위주로 명확하게 작성

---

## 섹션별 작성 가이드

### 1. 메타 정보

**Wiki (Draft 버전):**
```markdown
**담당자 (Author)**: [Scrum Master 이름](GitHub 주소)
**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)
**작성일 (Created)**: 2025.10.07
**문서 버전 (Version)**: v0.1
**문서 상태 (Status)**: Draft
```

**Docs Repo (Approved 버전):**
```markdown
**담당자 (Author)**: [Scrum Master 이름](GitHub 주소)
**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)
**작성일 (Created)**: 2025.10.07
**문서 버전 (Version)**: v1.0
**문서 상태 (Status)**: Approved
```

- 담당자는 해당 Sprint의 SM
- 검토자는 PO (왕택준)
- 작성일은 회고 회의 당일 또는 익일
- Wiki는 Draft (v0.1, v0.2...), Docs Repo는 Approved (v1.0)

### 2. 추가 정보
```markdown
**Scrum Master**: 김경민
**Sprint 기간**: 2025.10.06 ~ 2025.10.13
```

### 3. Sprint 목표
- sprint-plan.md에 정의된 목표를 그대로 가져오기
- 각 목표의 달성 여부를 정량적으로 표시
- 종합 달성률 계산 (완료 목표 수 / 전체 목표 수)

**작성 팁**:
- ☑️: 100% 완료
- ⚠️: 부분 완료 (50~99%)
- ❌: 미완료 (0~49%)

### 4. 주요 성과
- Sprint에서 완료한 구체적인 결과물 나열
- 카테고리별로 그룹핑 (예: 백엔드 API, 프론트엔드 UI, 인프라)
- 정량적 지표 포함 (API 5개, 문서 10개 등)

### 5. 잘된 점 (What Went Well)
- 팀이 잘한 것, 유지해야 할 관행
- 최소 3개 이상 작성
- 구체적인 예시와 이유 포함

**예시**:
```markdown
### 1. 명확한 프로젝트 방향 수립
프로젝트 아이디어(Dialogym)가 팀 전원의 동의를 얻어 빠르게 확정됨.
초기에 기술 스택과 아키텍처를 명확히 정의하여 개발 방향 설정이 수월했음.
```

### 6. 아쉬운 점 (What Didn't Go Well)
- 개선이 필요한 문제점
- 최소 3개 이상 작성
- 문제의 원인 분석 포함

**작성 시 주의**:
- 개인 비난 금지
- "~가 안 했다" ❌ → "~가 부족했다" ☑️

### 7. 개선 방안 (What to Improve)
- 아쉬운 점을 해결하기 위한 구체적 방안
- 각 개선 방안은 "문제" + "개선안" 형식
- 개선안은 실행 가능한 액션 아이템으로 작성

**필수 요소**:
- 무엇을 (What)
- 누가 (Who) - 가능하면 담당자 명시
- 언제 (When) - 다음 Sprint에서 적용
- 어떻게 (How) - 구체적 방법

**예시**:
```markdown
### 1. Daily Scrum 정례화
**문제**: Daily Scrum 미실시로 진행 상황 공유 부족
**개선안**:
- Sprint 2부터 매일 오전 10시 Daily Scrum 실시 (15분)
- Discord 음성 채널 활용
- Scrum Master(김경민)가 주도
```

### 8. 팀원별 기여
- 각 팀원의 담당 작업, 성과, 개선점 작성
- 객관적이고 건설적인 피드백 제공
- 개인 공격이 아닌 역량 개발 관점으로 작성

### 9. 팀 피드백
- 팀워크, 커뮤니케이션, 일정 관리, 프로세스 4가지 항목
- 각 항목마다 긍정/개선 피드백 작성

### 10. Sprint 지표
- 정량적 데이터로 Sprint 성과 측정
- 완료율, 생산성, 품질, 팀 만족도

**측정 항목**:
- 완료율: 계획 대비 실제 완료 비율
- 생산성: 코드 라인 수, 완료 기능, 해결 버그, 작성 문서
- 품질: 코드 리뷰, 발견 버그, 테스트 커버리지
- 팀 만족도: 각 팀원의 10점 만점 자체 평가

### 11. 다음 Sprint 목표
- sprint-plan.md의 다음 Sprint 계획을 요약
- 이번 회고에서 도출된 개선 사항 명시
- DoD (Definition of Done) 체크리스트 포함

---

## 회고 회의 진행 방법

### 1. 회의 준비 (SM 담당)
- 회의 일정 공지 (Sprint 종료 당일 또는 익일)
- 회고 템플릿 공유
- 팀원들에게 사전 의견 수집 요청 (선택)

### 2. 회의 진행 (60분)
**0~5분**: 오프닝
- 회고의 목적과 규칙 설명
- 안전한 환경 강조 (비난 금지, 솔직한 의견 환영)

**5~20분**: What Went Well
- 각 팀원이 잘된 점 공유
- SM이 화이트보드/노션에 정리

**20~35분**: What Didn't Go Well
- 각 팀원이 아쉬운 점 공유
- 비슷한 의견은 그룹핑

**35~55분**: What to Improve
- 아쉬운 점에 대한 개선 방안 브레인스토밍
- 우선순위 투표 (각 팀원 3표)
- 상위 3~5개 개선 방안 선정

**55~60분**: 클로징
- 다음 Sprint에서 적용할 액션 아이템 확인
- 회고록 작성 일정 공유

### 3. 회의 후 작업 (SM 담당)
- 회의 내용을 바탕으로 Wiki에 회고록 v0.1 작성
- Discord에 공지 및 팀원 검토 요청
- 팀원 피드백 반영하여 v0.2, v0.3... 수정
- PO 승인 후 Docs Repo에 v1.0 반영

---

## 좋은 회고록 vs 나쁜 회고록

### 좋은 회고록의 특징
☑️ 구체적인 예시와 데이터 포함
☑️ 실행 가능한 개선 방안 제시
☑️ 긍정과 개선 사항의 균형
☑️ 팀 전체의 의견이 반영됨
☑️ 다음 Sprint에서 바로 적용 가능

### 나쁜 회고록의 특징
❌ 추상적이고 모호한 표현
❌ 개인 비난이나 감정적 표현
❌ 실행 불가능한 개선 방안
❌ 문제점만 나열하고 해결책 없음
❌ SM 혼자 작성하고 팀 의견 미반영

---

## 저장 위치 및 파일명 규칙

### Wiki (Draft 버전)
```
GitHub Wiki (dialogym-docs Repository)
- 파일명: sprint-[N]-retrospective.md
```

### Docs Repo (Approved 버전)
```
docs/meetings/sprint-retrospective/team/sprint-[N]-retrospective.md
```

### Archive (Draft 히스토리)
```
docs/archive/wiki-snapshots/
- sprint-[N]-retrospective-v0.1.md
- sprint-[N]-retrospective-v0.2.md
- sprint-[N]-retrospective-v0.3.md
```

**파일명 예시**:
- Wiki: `sprint-1-retrospective.md` (v0.1, v0.2, v0.3...)
- Docs Repo: `sprint-1-retrospective.md` (v1.0)
- Archive: `sprint-1-retrospective-v0.1.md`, `sprint-1-retrospective-v0.2.md`

---

## 작성 및 승인 절차

### 전체 흐름

```
Sprint 회고 회의
   ↓
Wiki (v0.1 Draft 작성)
   ↓
Discord (팀원 검토 요청)
   ↓
Wiki (v0.2, v0.3... 피드백 반영)
   ↓
PO 승인
   ↓
Docs Repo (v1.0 Approved)
   ↓
wiki-snapshots (Draft 버전 보존)
```

---

### 1단계: Wiki Draft 작성

**담당자**: Scrum Master
**시점**: 회고 회의 직후 (1영업일 이내)

**작업 내용**:
1. GitHub Wiki(dialogym-docs Repo)에 접속
2. 회고 템플릿 복사
3. 회의 내용 기반으로 v0.1 초안 작성
4. 메타 정보 작성:
   ```markdown
   **문서 버전 (Version)**: v0.1
   **문서 상태 (Status)**: Draft
   ```

**예시**:
```
Wiki: sprint-1-retrospective.md (v0.1)
- Sprint 목표
- 주요 성과
- What Went Well
- What Didn't Go Well
- What to Improve
```

---

### 2단계: Discord 공지 및 팀원 검토

**담당자**: Scrum Master
**시점**: Wiki v0.1 작성 직후

**작업 내용**:
1. Discord #일반 채널에 공지
   ```
   @팀원 Sprint 1 회고록 v0.1 올렸습니다.
   확인 부탁드립니다.
   [Wiki 링크]
   ```
2. 팀원들에게 검토 기한 안내 (1일)

---

### 3단계: Wiki 피드백 반영

**담당자**: Scrum Master + 팀원
**시점**: 공지 후 1~2일

**작업 내용**:
1. 팀원들이 Wiki에서 직접 수정하거나 Discord에 피드백 제공
2. SM이 피드백을 반영하여 v0.2, v0.3... 업데이트
3. 각 버전마다 메타 정보 업데이트:
   ```markdown
   **문서 버전 (Version)**: v0.2
   **문서 상태 (Status)**: Draft
   ```

**예시**:
```
Wiki: sprint-1-retrospective.md (v0.2)
- 김경민 피드백: "문서 작성 시간 과다" 섹션 추가

Wiki: sprint-1-retrospective.md (v0.3)
- 진도희 피드백: "작업 불균형" 개선 방안 구체화
```

---

### 4단계: PO 최종 검토 및 승인

**담당자**: Product Owner (왕택준)
**시점**: 팀 검토 완료 후

**작업 내용**:
1. Wiki 최종 버전 검토
2. 필요 시 수정 요청
3. 승인 완료 시 SM에게 알림

---

### 5단계: Docs Repo 반영

**담당자**: Scrum Master
**시점**: PO 승인 직후

**작업 내용**:
1. Wiki 내용을 복사
2. Docs Repository에 PR 생성
   - 위치: `docs/meetings/sprint-retrospective/team/`
   - 파일명: `sprint-1-retrospective.md`
3. 메타 정보 업데이트:
   ```markdown
   **문서 버전 (Version)**: v1.0
   **문서 상태 (Status)**: Approved
   ```
4. PO가 PR 승인
5. `main` 브랜치에 병합

---

### 6단계: wiki-snapshots 보존

**담당자**: Scrum Master
**시점**: Docs Repo 병합 직후

**작업 내용**:
1. Wiki의 각 Draft 버전을 파일로 저장
2. Docs Repo에 PR 생성
   - 위치: `docs/archive/wiki-snapshots/`
   - 파일명:
     - `sprint-1-retrospective-v0.1.md`
     - `sprint-1-retrospective-v0.2.md`
     - `sprint-1-retrospective-v0.3.md`
3. PR 병합

**wiki-snapshots 헤더 예시**:
```markdown
# Sprint 1 회고 (v0.1 Draft)

**문서 버전 (Version)**: v0.1
**문서 상태 (Status)**: Archived
**아카이브 일자**: 2025.10.08
**최종본 위치**: [sprint-1-retrospective.md](../../meetings/sprint-retrospective/team/sprint-1-retrospective.md)
```

---

### 절차 요약표

| 단계 | 담당자 | 위치 | 버전 | 상태 | 소요 시간 |
|------|--------|------|------|------|-----------|
| 1. Draft 작성 | SM | Wiki | v0.1 | Draft | 1시간 |
| 2. Discord 공지 | SM | Discord | - | - | 5분 |
| 3. 팀원 검토 | 팀원 | Wiki | v0.2, v0.3... | Draft | 1일 |
| 4. PO 승인 | PO | Wiki | v0.x | Draft | 30분 |
| 5. Docs Repo 반영 | SM | Docs Repo | v1.0 | Approved | 30분 |
| 6. wiki-snapshots | SM | Docs Repo | v0.x | Archived | 30분 |

---

## 참고 자료

### 관련 문서
- [collaboration-guide.md](../../processes/collaboration/collaboration-guide.md) - 문서 작성 흐름
- [document-template-guide.md](../../processes/document-template-guide.md) - 문서 표준
- [sprint-retrospective-template.md](./sprint-retrospective-template.md) - 회고록 템플릿
- [sprint-plan.md](../sprint-planning/sprint-plan.md) - Sprint 계획
- [team-roles.md](../../team/team-roles.md) - 팀 역할

### 외부 자료
- [Atlassian - Sprint Retrospective](https://www.atlassian.com/agile/scrum/retrospectives)
- [Scrum Guide - Sprint Retrospective](https://scrumguides.org/)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
