# Dialogym-docs

Dialogym 플랫폼의 문서/기획/설계 자료를 관리하는 레포지토리입니다.

## 저장소 클론

```bash
git clone https://github.com/AI-d/dialogym-docs.git
cd dialogym-docs
```

## 빠른 시작 가이드

1. 레포지토리를 클론합니다
2. `docs/` 디렉토리에서 필요한 문서를 확인하거나 작성합니다
3. 새로운 문서는 해당하는 카테고리 디렉토리에 추가합니다
4. 변경사항을 커밋하고 푸시합니다

## 디렉토리 구조

```
dialogym-docs/
├── docs/
│   ├── archive/           # 더 이상 사용하지 않는 문서 보관
│   │   ├── deprecated/    # 폐기된 문서
│   │   └── wiki-snapshots/ # 위키 스냅샷
│   │
│   ├── decisions/         # 기술 및 설계 의사결정 기록
│   │   ├── backend/       # 백엔드 관련 결정사항
│   │   ├── frontend/      # 프론트엔드 관련 결정사항
│   │   └── infrastructure/ # 인프라 관련 결정사항
│   │
│   ├── design/            # 설계 문서
│   │   ├── api/           # API 설계 문서
│   │   ├── architecture/  # 시스템 아키텍처 설계
│   │   ├── database/      # 데이터베이스 설계
│   │   ├── infrastructure/ # 인프라 설계
│   │   └── ui/            # UI/UX 설계
│   │
│   ├── meetings/          # 회의록 및 진행 기록
│   │   ├── general/       # 일반 회의록
│   │   ├── personal-retrospective/ # 개인 회고
│   │   ├── progress-log/  # 진행 상황 로그
│   │   ├── sprint-planning/ # 스프린트 계획
│   │   └── sprint-retrospective/ # 스프린트 회고
│   │
│   ├── processes/         # 프로세스 및 가이드
│   │   ├── collaboration/ # 협업 프로세스
│   │   ├── deployment/    # 배포 프로세스
│   │   ├── development/   # 개발 프로세스
│   │   └── testing/       # 테스트 프로세스
│   │
│   ├── reports/           # 보고서
│   │   └── weekly/        # 주간 보고서
│   │
│   ├── requirements/      # 요구사항 정의
│   │   ├── policies/      # 정책 문서
│   │   ├── competitive-analysis.md # 경쟁사 분석
│   │   ├── concept-definition.md   # 컨셉 정의
│   │   ├── feature-specification.md # 기능 명세
│   │   ├── problem-analysis.md     # 문제 분석
│   │   └── project-overview.md     # 프로젝트 개요
│   │
│   ├── team/              # 팀 관련 문서
│   │   ├── team-roles.md  # 팀 역할 정의
│   │   └── team-tech-stack.md # 기술 스택
│   │
│   └── troubleshooting/   # 트러블슈팅 기록
│       ├── dohee/         # 도희 트러블슈팅
│       ├── kyungmin/      # 경민 트러블슈팅
│       └── taekjun/       # 택준 트러블슈팅
│
├── .github/               # GitHub 설정 파일
├── CONTRIBUTING.md        # 기여 가이드
└── README.md              # 프로젝트 소개
