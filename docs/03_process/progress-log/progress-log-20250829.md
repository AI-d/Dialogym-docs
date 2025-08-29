# Progress Log - 2025-08-29

**작성자**: [왕택준](https://github.com/TJK98)

---

## Repository 라벨 및 이슈/PR 템플릿 리팩토링

### 공통 작업

* 각 레포지토리(`Dialogym-docs`, `trAIn-frontend`, `trAIn-backend`)별 **라벨 체계 정비**
  * `status`, `priority`, `type` 라벨 기본값 추가

* 각 레포지토리별 **이슈 템플릿 수정/보완**
  * `bug_report.md`, `feature_request.md`, `enhancement_request.md`, `refactor.md`, `docs.md` → 라벨 자동 할당 보강
  * 신규 템플릿 추가: `security.md`, `release.md`, `chore.md`

* **PR 템플릿 리팩토링**
  * PR 유형별 자동 라벨링 가이드 추가
  * 관련 이슈 키워드(`Closes`, `Fixes`, `Resolves`, `Relates to`) 확장
  * CI/CD 체크리스트 추가
  * 스크린샷 섹션을 선택(Optional) 처리

* 기존 이슈 템플릿 및 `config.yml` 보완
  * 일반 문의 URL 최신화 → `https://github.com/orgs/AI-d/discussions`
  * 보안 이슈 비공개 신고 메일 추가 → `mailto:wtj1998@naver.com`

---

## 문서 레포지토리 (Dialogym-docs Repository)

* 신규 문서 **`LABEL_GUIDE.md`** 추가
  * 라벨 사용 규칙, 조합 가이드, 적용 예시 체계화
---

## 프론트엔드 레포지토리 (trAIn-frontend Repository)

* 프로젝트 의존성 추가
  * `react-router-dom` 설치 → 페이지 라우팅 기능 지원
  * `sass` 설치 → SCSS 기반 스타일링 체계 확립

---

## 정리

* 모든 레포지토리에 **라벨/이슈/PR 템플릿 리팩토링** 적용 완료
* **Dialogym-docs**: `LABEL_GUIDE.md` 문서 신규 작성, 라벨 규칙 공식화
* **trAIn-frontend**: `react-router-dom`/`sass` 설치로 라우팅 및 스타일링 기반 환경 구축
* **trAIn-backend**: 라벨/템플릿 개선 반영 완료 (코드 변경 없음)
* 전반적으로 **협업 가이드라인 및 자동화 수준 향상**
