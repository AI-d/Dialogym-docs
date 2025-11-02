# 트러블슈팅: 백엔드 디렉토리 구조 리팩토링 자동화 스크립트로 해결

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.12

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Spring Boot 프로젝트 구조 리팩토링을 수행해야 하는 개발자
* **Tech Lead**: 대규모 코드베이스 구조 변경 시 참고해야 하는 기술 리더
* **신규 합류자**: 프로젝트의 아키텍처 변경 이력을 이해해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

계층형과 도메인형이 혼재된 백엔드 디렉토리 구조를 도메인 중심 아키텍처로 일관되게 전환하는 작업에서, 수동 리팩토링의 번거로움과 실수 가능성을 자동화 스크립트로 해결했습니다. Bash 스크립트를 통해 파일 이동, 패키지 선언부 수정, Import 경로 업데이트를 자동화하여 30분 만에 안전하게 리팩토링을 완료했습니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [문제 현상](#1-문제-현상)
3. [원인 분석](#2-원인-분석)
4. [디버깅 과정](#3-디버깅-과정)
5. [해결 과정](#4-해결-과정)
6. [테스트 검증](#5-테스트-검증)
7. [성능 영향 분석](#6-성능-영향-분석)
8. [관련 이슈 및 예방책](#7-관련-이슈-및-예방책)
9. [결론 및 배운 점](#8-결론-및-배운-점)

---

## 문서 개요 (Overview)

Spring Boot 프로젝트의 디렉토리 구조가 계층형(controller/, service/, repository/)과 도메인형(domain/)이 혼재되어 있어 코드 응집도가 낮고 유지보수가 어려운 상황이었습니다. 표준 디렉토리 가이드 문서에 따라 도메인 중심 구조로 일관되게 변경해야 했으나, 수작업으로 진행할 경우 실수 가능성과 작업 시간이 우려되었습니다.

**관련 이슈**: TRAIN-31

---

## 1. 문제 현상

### 1-1. 주요 증상
* **문제**: 계층형과 도메인형 디렉토리 구조가 혼재됨
* **증상**: controller, service, repository가 최상위에 존재하면서 동시에 domain 내부에도 entity만 존재
* **상황**: 신규 기능 추가 시 어디에 파일을 위치시켜야 할지 혼란 발생

### 1-2. 구조 문제
**기존 구조**:
```
backend/
├── controller/scenario/     # 계층형
├── service/                 # 계층형
├── repository/              # 계층형
└── domain/
    ├── user/entity/         # 도메인형 (불완전)
    └── scenario/entity/     # 도메인형 (불완전)
```

**문제점**:
- Scenario 관련 파일이 3곳에 분산 (controller/, service/, repository/)
- 도메인별 응집도가 낮아 관련 코드 찾기 어려움
- 표준 가이드 문서와 불일치

### 1-3. 환경 정보
* **프로젝트**: Spring Boot 3.x
* **빌드 도구**: Gradle 8.x
* **패키지 구조**: com.aid.train.backend
* **운영체제**: macOS (개발), Ubuntu (EC2)

---

## 2. 원인 분석

### 2-1. 1차 분석
프로젝트 초기에 계층형 구조로 시작했으나, 중간에 도메인형 구조로 전환하는 과정에서 일관성 없이 마이그레이션이 진행됨

### 2-2. 2차 분석
수동 리팩토링의 위험 요소:
- 30개 이상의 Java 파일 이동 필요
- 각 파일의 package 선언부 수정 필요
- 모든 파일의 import 경로 업데이트 필요
- 휴먼 에러 발생 가능성 높음
- 작업 시간 예상: 2-3시간

### 2-3. 근본 원인
**문제점**:
- 명확한 디렉토리 구조 가이드 부재 (당시)
- 리팩토링 시 일관된 작업 프로세스 부재
- 수동 작업의 반복성과 실수 가능성

**해결 방향**:
- 자동화 스크립트로 안전하고 빠르게 마이그레이션
- 백업과 롤백 메커니즘 확보
- 단계별 검증 프로세스 수립

---

## 3. 디버깅 과정

### 3-1. 사용한 분석 기법
- 현재 프로젝트 구조 분석: `tree` 명령어
- Git 상태 확인: `git status`
- 표준 가이드 문서와 비교 분석
- 파일 의존성 분석 (IntelliJ 활용)

### 3-2. 핵심 문제 발견 과정

**1단계: 현재 구조 파악**
```bash
tree src/main/java/com/aid/train/backend -L 3
```

**결과**: controller, service, repository가 최상위에 있고, domain 내부는 entity만 존재

**2단계: 이동 대상 파일 식별**
```bash
find src -name "*.java" -type f | grep -E "(controller|service|repository)"
```

**결과**: 
- ScenarioController.java
- ScenarioService.java
- Scenario*.java (repository 3개)
- UserRepository.java
- DialogueSessionRepository.java
- TranscriptRepository.java

**3단계: 의존성 분석**
IntelliJ에서 import 문 분석:
```java
import com.aid.train.backend.repository.scenario.ScenarioRepository;
import com.aid.train.backend.global.common.response.ApiResponse;
```

**결과**: 다른 파일들이 옛날 경로를 참조하고 있어 import 문도 업데이트 필요

**4단계: 수동 작업 시간 추정**
- 파일 이동: 10개 × 2분 = 20분
- Package 선언 수정: 10개 × 2분 = 20분
- Import 경로 수정: 전체 프로젝트 검색 및 수정 = 60분
- 컴파일 에러 수정: 30분
- **총 예상 시간: 2시간 30분**

**결론**: 자동화가 필수적

---

## 4. 해결 과정

### 4-1. 시도했던 해결책들

**A안: IntelliJ Refactor 기능 사용 (실패)**
```
IntelliJ → Refactor → Move
```

**문제점**:
- 한 파일씩만 이동 가능
- Package 구조 변경 시 수동 작업 여전히 필요
- Import 최적화가 잘못된 경로를 자동으로 고쳐주지 못함

**B안: 수동 작업 (기각)**
- 시간 소요: 2-3시간
- 실수 가능성 높음
- 반복 가능성 없음

**C안: 자동화 스크립트 작성 (채택)**
- Bash 스크립트로 파일 이동, 패키지 선언 수정, Import 업데이트 자동화
- 백업 자동 생성
- 단계별 확인 가능 (인터랙티브 모드)

### 4-2. 최종 해결책

#### 해결책 1: 인터랙티브 마이그레이션 스크립트

**migrate-interactive.sh**:
```bash
#!/bin/bash

set -e

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="src/main/java/com/aid/train/backend"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 사용자 확인
confirm() {
    echo -e "${YELLOW}$1 (y/n):${NC} "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

# 백업 생성
create_backup() {
    if confirm "백업을 생성하시겠습니까?"; then
        BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
        cp -r "$PROJECT_ROOT" "$BACKUP_DIR"
        log_info "백업 완료: $BACKUP_DIR"
    fi
}

# Scenario 도메인 마이그레이션
step1_scenario() {
    if ! confirm "Scenario 도메인을 마이그레이션하시겠습니까?"; then
        return
    fi
    
    # 디렉토리 생성
    mkdir -p "$PROJECT_ROOT/domain/scenario/controller"
    mkdir -p "$PROJECT_ROOT/domain/scenario/service"
    mkdir -p "$PROJECT_ROOT/domain/scenario/repository"
    
    # Controller 이동 및 패키지 수정
    if [ -f "$PROJECT_ROOT/controller/scenario/ScenarioController.java" ]; then
        mv "$PROJECT_ROOT/controller/scenario/ScenarioController.java" \
           "$PROJECT_ROOT/domain/scenario/controller/"
        sed -i.bak 's/package com.aid.train.backend.controller.scenario;/package com.aid.train.backend.domain.scenario.controller;/' \
            "$PROJECT_ROOT/domain/scenario/controller/ScenarioController.java"
        rm "$PROJECT_ROOT/domain/scenario/controller/ScenarioController.java.bak"
        log_info "Controller 이동 완료"
    fi
    
    # Service 이동 및 패키지 수정
    if [ -f "$PROJECT_ROOT/service/ScenarioService.java" ]; then
        mv "$PROJECT_ROOT/service/ScenarioService.java" \
           "$PROJECT_ROOT/domain/scenario/service/"
        sed -i.bak 's/package com.aid.train.backend.service;/package com.aid.train.backend.domain.scenario.service;/' \
            "$PROJECT_ROOT/domain/scenario/service/ScenarioService.java"
        rm "$PROJECT_ROOT/domain/scenario/service/ScenarioService.java.bak"
        log_info "Service 이동 완료"
    fi
    
    # Repository 이동 및 패키지 수정
    if [ -d "$PROJECT_ROOT/repository/scenario" ]; then
        for file in "$PROJECT_ROOT/repository/scenario/"*.java; do
            [ -f "$file" ] || continue
            filename=$(basename "$file")
            mv "$file" "$PROJECT_ROOT/domain/scenario/repository/"
            sed -i.bak 's/package com.aid.train.backend.repository.scenario;/package com.aid.train.backend.domain.scenario.repository;/' \
                "$PROJECT_ROOT/domain/scenario/repository/$filename"
            rm "$PROJECT_ROOT/domain/scenario/repository/$filename.bak"
        done
        log_info "Repository 이동 완료"
    fi
}

# 메인 함수
main() {
    create_backup
    step1_scenario
    # ... 기타 도메인들
}

main
```

**핵심 로직**:
1. **백업 생성**: 작업 전 자동 백업
2. **단계별 확인**: 각 단계마다 사용자 확인 요청
3. **파일 이동**: `mv` 명령어로 안전하게 이동
4. **패키지 수정**: `sed` 명령어로 package 선언부 자동 변경
5. **임시 파일 정리**: `.bak` 파일 자동 삭제

#### 해결책 2: Import 경로 일괄 수정 스크립트

**fix-imports.sh**:
```bash
#!/bin/bash

echo "🔧 Import 경로 일괄 수정 시작..."

# global.common.response → global.response
find src -name "*.java" -type f -exec sed -i '' \
  's/com\.aid\.train\.backend\.global\.common\.response/com.aid.train.backend.global.response/g' {} +

# repository.scenario → domain.scenario.repository
find src -name "*.java" -type f -exec sed -i '' \
  's/com\.aid\.train\.backend\.repository\.scenario/com.aid.train.backend.domain.scenario.repository/g' {} +

# repository.user → domain.user.repository
find src -name "*.java" -type f -exec sed -i '' \
  's/com\.aid\.train\.backend\.repository\.user/com.aid.train.backend.domain.user.repository/g' {} +

# repository.session → domain.session.repository
find src -name "*.java" -type f -exec sed -i '' \
  's/com\.aid\.train\.backend\.repository\.session/com.aid.train.backend.domain.session.repository/g' {} +

# global.jwt → global.security.jwt
find src -name "*.java" -type f -exec sed -i '' \
  's/com\.aid\.train\.backend\.global\.jwt/com.aid.train.backend.global.security.jwt/g' {} +

echo "✅ Import 경로 수정 완료!"
./gradlew clean build
```

**핵심 로직**:
- `find`로 모든 .java 파일 검색
- `sed`로 정규식 패턴 매칭 및 일괄 치환
- macOS 호환성을 위해 `-i ''` 옵션 사용

### 4-3. 실행 프로세스

```bash
# 1. Git 브랜치 생성
git checkout -b refactor/TRAIN-31-backend-domain-structure

# 2. 마이그레이션 스크립트 실행
chmod +x migrate-interactive.sh
./migrate-interactive.sh

# 3. Import 경로 수정
chmod +x fix-imports.sh
./fix-imports.sh

# 4. 빌드 검증
./gradlew clean build -x test

# 5. Git 커밋
git add -A
git commit -m "refactor/TRAIN-31: 백엔드 디렉토리 구조 도메인 중심으로 리팩토링"
```

**성공 이유**:
- 자동화로 휴먼 에러 방지
- 백업으로 안전성 확보
- 단계별 검증으로 문제 조기 발견
- 재사용 가능한 스크립트로 향후 유사 작업에 활용

---

## 5. 테스트 검증

### 5-1. 테스트 방법

**1. 파일 이동 검증**
```bash
git status
```

**결과**:
```
deleted:    src/main/java/com/aid/train/backend/controller/scenario/ScenarioController.java
new file:   src/main/java/com/aid/train/backend/domain/scenario/controller/ScenarioController.java
```

Git이 삭제와 생성을 정상적으로 감지 → 파일 이동 성공

**2. 패키지 선언 검증**
```bash
grep -r "package com.aid.train.backend.domain.scenario.controller" src/
```

**결과**: ScenarioController.java의 패키지 선언이 올바르게 변경됨

**3. Import 경로 검증**
```bash
grep -r "import com.aid.train.backend.repository.scenario" src/
```

**결과**: 검색 결과 없음 → 모든 import가 새 경로로 변경됨

**4. 컴파일 검증**
```bash
./gradlew clean build -x test
```

**결과**: BUILD SUCCESSFUL in 5s

### 5-2. 검증 결과
* **변경 전**: 
  - 컴파일 에러: 6개 (import 경로 불일치)
  - 구조: 계층형 + 도메인형 혼재
  - 빌드 상태: 실패

* **변경 후**: 
  - 컴파일 에러: 0개
  - 구조: 도메인 중심 구조로 일관됨
  - 빌드 상태: 성공

### 5-3. 파일 무결성 확인

```bash
# 백업 폴더의 Java 파일 수
find backup_* -name "*.java" | wc -l
# 결과: 45

# 현재 src의 Java 파일 수
find src -name "*.java" | wc -l
# 결과: 45
```

**결론**: 파일 손실 없음

---

## 6. 성능 영향 분석

### 6-1. 변경 전후 비교

**측정 항목**:
- **작업 시간**:
  - 예상 (수동): 2시간 30분
  - 실제 (자동화): 30분 (-80%)
- **실수 횟수**:
  - 예상 (수동): 3-5회
  - 실제 (자동화): 0회
- **빌드 시간**: 
  - 변경 전: 6초
  - 변경 후: 5초 (거의 동일)

### 6-2. 리소스 사용량
- **메모리**: 변화 없음
- **CPU**: 빌드 시간 동일
- **디스크**: 백업 폴더 추가 (~50MB)

### 6-3. 사용자 경험 영향
- **개발자 경험**: 
  - 코드 검색성 향상 (도메인별 응집도 증가)
  - 신규 기능 추가 시 파일 위치 명확
- **런타임 성능**: 영향 없음 (구조 변경만)

---

## 7. 관련 이슈 및 예방책

### 7-1. 유사한 함정 회피 방법

**위험한 패턴**:
- 대규모 리팩토링을 수동으로 진행
- 백업 없이 작업 시작
- 한 번에 모든 변경사항 커밋

**안전한 패턴**:
- 자동화 스크립트 작성 후 테스트
- 백업 자동 생성 메커니즘
- 단계별 커밋으로 롤백 포인트 확보

### 7-2. 코드 리뷰 체크포인트

**리팩토링 전**:
- [ ] 표준 구조 가이드 문서 확인
- [ ] 영향 범위 분석 (의존성 그래프)
- [ ] 자동화 가능 여부 검토

**리팩토링 중**:
- [ ] 백업 생성 확인
- [ ] 단계별 빌드 검증
- [ ] Git 상태 확인 (파일 손실 방지)

**리팩토링 후**:
- [ ] 전체 빌드 성공 확인
- [ ] 테스트 실행 (가능한 경우)
- [ ] 팀원에게 변경 사항 공유

### 7-3. 추가 예방 방법

**프로세스 개선**:
- 디렉토리 구조 가이드 문서 필수 작성
- 신규 프로젝트 시작 시 구조 먼저 정의
- 주기적인 구조 리뷰 (분기별)

**자동화 강화**:
- CI/CD에 구조 검증 스크립트 추가
- Pre-commit hook으로 잘못된 위치 파일 방지
- Lint 규칙에 패키지 구조 체크 추가

**지식 공유**:
- 리팩토링 스크립트 템플릿화
- 트러블슈팅 문서 작성 (본 문서)
- 기술 세션에서 공유

---

## 8. 결론 및 배운 점

### 8-1. 주요 성과

1. **작업 시간 80% 단축**
   - 수동 2.5시간 → 자동화 30분

2. **무결성 100% 달성**
   - 파일 손실: 0건
   - 컴파일 에러: 0건

3. **재사용 가능한 자산 확보**
   - 마이그레이션 스크립트
   - Import 수정 스크립트
   - 트러블슈팅 문서

4. **표준 구조 확립**
   - 도메인 중심 아키텍처 일관 적용
   - 가이드 문서 준수

### 8-2. 기술적 학습

**Bash 스크립팅**:
- `find` + `sed` 조합으로 대규모 텍스트 치환 가능
- macOS와 Linux의 `sed` 차이점 이해 (`-i` vs `-i ''`)
- 인터랙티브 스크립트로 사용자 확인 단계 추가

**Git 활용**:
- 파일 이동 시 Git이 자동으로 rename 감지
- `git add -A`로 삭제+생성을 함께 스테이징
- 브랜치 전략으로 안전한 실험 가능

**Spring Boot 구조**:
- 패키지 구조 변경이 런타임에 영향 없음 (컴파일 타임만)
- Import 경로만 정확하면 리팩토링 안전
- 테스트는 별도 이슈로 분리 가능

### 8-3. 프로세스 개선

**리팩토링 체크리스트 작성**:
```markdown
## 대규모 리팩토링 체크리스트

### 사전 준비
- [ ] 백업 계획 수립
- [ ] 영향 범위 분석
- [ ] 자동화 스크립트 작성 가능성 검토
- [ ] 롤백 시나리오 수립

### 실행
- [ ] Git 브랜치 생성
- [ ] 백업 생성
- [ ] 단계별 스크립트 실행
- [ ] 각 단계마다 빌드 검증

### 검증
- [ ] 파일 무결성 확인
- [ ] 컴파일 성공 확인
- [ ] 테스트 실행 (가능 시)
- [ ] Git 상태 확인

### 완료
- [ ] 변경 사항 커밋
- [ ] PR 생성 및 리뷰 요청
- [ ] 트러블슈팅 문서 작성
- [ ] 팀 공유
```

**자동화 우선 원칙**:
- 반복적인 작업은 무조건 자동화 검토
- 스크립트 작성 시간 < 수동 작업 시간이면 자동화
- 재사용 가능성 고려

### 8-4. 장기적 개선 방향

**아키텍처 거버넌스**:
- ArchUnit으로 패키지 구조 규칙 자동 검증
- CI/CD에 구조 검증 단계 추가
- 위반 시 빌드 실패 처리

**스크립트 템플릿화**:
```bash
# 범용 리팩토링 스크립트 작성
refactor-package-structure.sh \
  --from "controller" \
  --to "domain/{domain}/controller" \
  --package-prefix "com.aid.train.backend"
```

**지식 베이스 구축**:
- 트러블슈팅 문서 카테고리화
- Wiki에 검색 가능하도록 정리
- 주요 문서는 README에 링크

**팀 역량 강화**:
- 스크립팅 기술 세션 진행
- 자동화 우수 사례 공유
- 신규 멤버 온보딩에 활용

---

## 참고 자료

- [백엔드 디렉토리 구조 가이드](../backend-directory-structure-guide.md)
- [트러블슈팅 작성 가이드](../troubleshooting-guide.md)
- [Spring Boot Best Practices](https://spring.io/guides)
- [Effective Shell Scripting](https://google.github.io/styleguide/shellguide.html)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 담당자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.12 | 왕택준 | 최초 작성 |
