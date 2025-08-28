# Progress Log - 2025-08-28

**작성자**: [왕택준](https://github.com/TJK98)

## 프로젝트 아이디어 및 개요 문서화

### 팀명: **AId (에이드)**

* **Mission**: **AI가 사람들의 대화 성장을 돕는다.**
* **핵심 가치**:

  * **AID (지원)**: AI를 단순한 기술이 아닌, 인간의 잠재력을 확장시키는 따뜻한 조력자로 정의합니다.
  * **AI-Driven**: 대화의 본질을 이해하고, 개인화된 데이터를 기반으로 최적의 솔루션을 제공하는 기술적 역량을 강조합니다.

---

### 프로젝트명: **trAIn (트레인)**

* **Vision**: **누구나 자신 있게 말할 수 있는 세상.**
* **스토리텔링**:

  * **AI와 함께하는 여정**: \*기차(Train)\*라는 은유를 통해, 사용자가 대화 능력 향상이라는 목적지로 나아가는 여정에 AI가 동행한다는 메시지를 담습니다.
  * **단계적 성장**: 기차가 여러 정거장을 거쳐 목적지에 도착하듯, 사용자가 초급부터 고급까지 차근차근 성장할 수 있는 체계적인 학습 경험을 제공합니다.

---

### 플랫폼명: **Dialogym (다이얼로짐)**

* **Core Experience**: **대화 근육을 단련하는 훈련 공간.**
* **경험 설계**:

  * **훈련과 반복**: 대화 능력을 *근육*처럼 인식하게 하여, 꾸준한 훈련과 반복의 중요성을 강조합니다.
  * **맞춤형 도구**: 플랫폼의 기능은 헬스장의 운동 기구처럼 설계되어, 사용자가 필요한 대화 능력을 맞춤형으로 훈련할 수 있도록 돕습니다.

---

## GitHub Organization 및 Repository 구성

* 조직: **AI-d** 생성
* 주요 레포지토리:

  * `trAIn-frontend`: React + Vite 기반 프론트엔드
  * `trAIn-backend`: Spring Boot + MariaDB 기반 백엔드
  * `Dialogym-docs`: 기획/설계/문서 전용

---

## Repository 초기 세팅 & 브랜치 전략

* `main`, `dev` 브랜치 운영

| 브랜치    | 용도                            |
|--------|-------------------------------|
| `main` | 최종 결과물 (배포용 전용 브랜치, 직접 작업 금지) |
| `dev`  | 통합 개발 브랜치 (모든 기능 브랜치의 병합 대상)  |

* Git Flow 브랜치 전략 도입
* 브랜치 보호 규칙 설정 (PR 필수, force push 차단 등)

---

## 프론트앤드 레포지토리 (trAIn-frontend Repository)

* Vite + React 기반 초기 프로젝트 생성
* 초기 커밋 내역:

  * `Initial commit`
  * `Add initial React frontend project setup with Vite`
  * `Add initial GitHub issue and PR templates`

---

## 벡앤드 레포지토리 (trAIn-backend Repository)

* Spring Boot 프로젝트 초기 세팅 완료
* MariaDB 연동 설정 (application.yml + .env)
* 초기 커밋 내역:

  * `Initial commit`
  * `Add initial Spring Boot project configuration`
  * `Add initial GitHub issue and PR templates`

---

## 문서 레포지토리 (Dialogym-docs Repository)

* 초기 디렉토리 구조 정의:

```
docs/
 ├─ 00_project-info/      # 프로젝트 개요, 규칙
 ├─ 01_architecture/      # 시스템 아키텍처, DB, 다이어그램
 │   ├─ database/
 │   └─ diagrams/
 ├─ 02_api/               # API 명세서
 ├─ 03_process/           # 진행 로그, 트러블슈팅
 │   ├─ progress-log/
 │   └─ troubleshooting/
 ├─ 04_policies/          # 정책 및 약관
 ├─ 05_user/              # 사용자 시나리오
 │   └─ scenarios/
 └─ setup/                # 설치 및 환경설정 가이드
```

* `CONTRIBUTING.md` 추가
* `.gitignore` 초기 설정 추가
* 초기 커밋 내역:

  * `Initial commit`
  * `Add initial GitHub issue and PR templates`
  * `Add initial .gitignore setup`

---

## workflow 설정

* `.github/ISSUE_TEMPLATE/` 이슈 템플릿 추가
* `PULL_REQUEST_TEMPLATE.md` 추가 → PR 시 자동 적용
*  이슈 라벨 전략 수립
