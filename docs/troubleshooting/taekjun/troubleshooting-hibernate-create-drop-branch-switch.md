# 트러블슈팅: Hibernate create-drop 브랜치 전환 시 스키마 충돌 DB 재생성으로 해결

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.27

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 개발자**: 유사한 Hibernate 스키마 충돌 문제 해결 시 참고해야 하는 팀원
* **Tech Lead**: 개발 환경 설정과 브랜치 전환 워크플로우 개선에 활용하는 책임자
* **신규 합류자**: Spring Boot JPA 개발 환경과 브랜치 관리 시 주의사항을 학습해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

브랜치 간 엔티티 구조 차이로 인해 Hibernate `create-drop` 설정에서 스키마 충돌이 발생했습니다. History 엔티티가 삭제된 브랜치와 존재하는 브랜치 간 전환 시 외래키 제약조건으로 인한 불완전한 테이블 삭제가 원인이었으며, 브랜치 최신화 후 데이터베이스 재생성으로 해결했습니다.

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

Spring Boot 개발 환경에서 브랜치 간 엔티티 구조가 다를 때 Hibernate의 `create-drop` 설정으로 인해 발생하는 스키마 충돌 문제를 다룹니다. 특히 외래키 제약조건으로 인한 불완전한 테이블 삭제가 브랜치 전환 시 "Table already exists" 오류를 야기하는 상황을 해결합니다.

---

## 1. 문제 현상

### 1-1. 주요 증상
* **문제**: 로컬에서 Spring Boot 애플리케이션 실행(`BootRun`) 시, 데이터베이스 스키마 관련 오류가 발생하며 부팅에 실패
* **증상**: 
  - 테이블/인덱스가 이미 존재한다는 SQL 오류 발생
  - 외래키 제약조건 위반으로 인한 삭제 실패
* **상황**: 
  1. `feat/A` 브랜치에서 작업 후, `dev` 브랜치로 `git checkout`
  2. `dev` 브랜치에서 `BootRun`을 실행하면 오류 발생
  3. `DROP/CREATE DATABASE`로 DB를 수동 초기화하면 정상 실행
  4. 다시 `feat/A` 브랜치로 복귀하여 `BootRun`을 실행하면 또다시 오류 발생 (무한 반복)

### 1-2. 에러 정보
* **에러 메시지**:
```sql
-- 종료 시도 시 (항상 발생하진 않음)
java.sql.SQLIntegrityConstraintViolationException: (conn=200) Cannot delete or update a parent row: a foreign key constraint fails

-- 재시작 시
java.sql.SQLSyntaxErrorException: (conn=200) Table 'users' already exists
java.sql.SQLSyntaxErrorException: (conn=200) Duplicate key name 'idx_user_email'
java.sql.SQLSyntaxErrorException: (conn=200) Duplicate key name 'idx_user_status'
java.sql.SQLSyntaxErrorException: (conn=200) Duplicate key name 'idx_user_last_login'
java.sql.SQLSyntaxErrorException: (conn=200) Duplicate key name 'uk_email_provider'
```

* **재현 조건**:
  1. `spring.jpa.hibernate.ddl-auto: create-drop` 설정 사용
  2. 서로 다른 엔티티 스키마를 가진 두 브랜치를 준비
  3. 한 브랜치에서 앱 실행/종료 후, 다른 브랜치로 이동하여 앱 재실행
* **빈도**: 브랜치 전환 후 첫 실행 시 100% 발생

### 1-3. 환경 정보
* **운영체제**: macOS/Windows (로컬 개발 환경)
* **서버**: Spring Boot 3.x (JPA, Hibernate)
* **데이터베이스**: MySQL (MariaDB)
* **관련 버전**: Hibernate 6.x
* **관련 설정**: `spring.jpa.hibernate.ddl-auto: create-drop`

---

## 2. 원인 분석

### 2-1. 1차 분석
브랜치 간 엔티티 구조 차이로 인한 스키마 불일치가 발생했습니다.

### 2-2. 2차 분석
Hibernate의 `create-drop` 설정에서 외래키 제약조건으로 인해 앱 종료 시 테이블 삭제가 불완전하게 실행되었습니다.

### 2-3. 근본 원인

**엔티티 구조 차이**:
- TJ님 브랜치: History 엔티티 없음 (삭제됨), Feedback 엔티티 복잡한 구조
- 다른 팀원 브랜치: History 엔티티 존재 (User와 ManyToOne 관계), Feedback 엔티티 단순 구조

**문제 발생 메커니즘**:
1. **브랜치 A**에서 앱 실행 → `users`, `feedbacks` 테이블 생성 (history 없음)
2. 앱 종료 시 → FK 제약조건으로 인해 **DROP이 불완전하게 실행**
3. **브랜치 B**로 전환 → **다른 엔티티 세트 정의** (history 엔티티 추가)
4. 앱 시작 시 → Hibernate가 새로운 스키마 생성 시도
5. **기존 테이블/인덱스가 남아있어서 충돌 발생**

```sql
-- Hibernate가 시도하는 작업 (실패)
DROP TABLE feedbacks;  -- User 테이블을 참조하므로 FK 제약조건으로 실패 가능
DROP TABLE users;      -- 완전히 삭제되지 않음

-- 다음 실행 시
CREATE TABLE users;    -- "Table already exists" 오류 발생
```

---

## 3. 디버깅 과정

### 3-1. 사용한 디버깅 기법
- Spring Boot 로그 분석 (`spring.jpa.show-sql=true`)
- MySQL 테이블 및 제약조건 확인
- Git 브랜치 간 엔티티 파일 비교
- Hibernate DDL 실행 순서 추적

### 3-2. 핵심 문제 발견 과정

**1단계: 엔티티 차이 확인**
- User 엔티티 비교: 동일함을 확인
- 다른 연관 엔티티들 확인 필요

**결과**: User 엔티티는 동일하여 다른 원인 추정

**2단계: 브랜치별 엔티티 구조 비교**
```java
// TJ님 브랜치: History 엔티티 없음
// Feedback 엔티티: DialogueSession과 OneToOne 관계

// 다른 브랜치: History 엔티티 존재
@Entity
@Table(name = "history")
public class History {
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    // ...
}
```

**결과**: 브랜치 간 엔티티 세트 차이 발견

**3단계: Hibernate DDL 실행 순서 확인**
- `create-drop`이 FK 제약조건 때문에 불완전한 삭제 수행
- 남은 테이블 잔재와 새로운 스키마 간 충돌 확인

**결과**: 외래키 제약조건으로 인한 불완전한 정리가 근본 원인

---

## 4. 해결 과정

### 4-1. 시도했던 해결책들

**A안: ddl-auto 설정 변경 (검토)**
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: create  # create-drop → create로 변경
```

**결과**: 임시 해결 가능하지만 근본 해결 아님

**B안: FK 제약조건 비활성화 (복잡함)**
```yaml
spring:
  sql:
    init:
      schema-locations: classpath:disable-fk-checks.sql
```

**결과**: 설정 복잡도 증가

**C안: 브랜치 최신화 + DB 재생성 (선택)**

### 4-2. 최종 해결책

브랜치 최신화 후 데이터베이스 완전 재생성

```bash
# 1. 브랜치 최신화
git checkout dev
git pull origin dev

# 2. DB 재생성
DROP DATABASE dialogym;
CREATE DATABASE dialogym CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# 3. 앱 실행
./gradlew bootRun
```

**성공 이유**:
- 브랜치 간 엔티티 차이 해결 (모든 팀원이 동일한 스키마 사용)
- DB 완전 초기화로 잔여 스키마 제거
- 추가 설정 변경 불필요

---

## 5. 테스트 검증

### 5-1. 테스트 방법
1. 브랜치 최신화 후 DB 재생성
2. Spring Boot 애플리케이션 정상 기동 확인
3. 여러 번 재시작하여 안정성 확인

### 5-2. 검증 결과
* **변경 전**: 브랜치 전환 후 100% 스키마 충돌 오류 발생
* **변경 후**: 정상 기동 및 안정적 재시작 확인

---

## 6. 성능 영향 분석

### 6-1. 변경 전후 비교

**측정 항목**:
- 애플리케이션 기동 시간: 변화 없음
- 메모리 사용량: 변화 없음

### 6-2. 리소스 사용량
- **메모리**: 변화 없음
- **CPU**: 변화 없음
- **디스크**: 기존 데이터 삭제로 약간 감소

### 6-3. 사용자 경험 영향
개발 생산성 크게 향상 (브랜치 전환 시 수동 DB 초기화 불필요)

---

## 7. 관련 이슈 및 예방책

### 7-1. 유사한 함정 회피 방법

**위험한 패턴**:
- 브랜치 간 엔티티 구조 차이 무시
- `create-drop` 설정에서 FK 제약조건 영향 미고려

**안전한 패턴**:
- 브랜치 전환 후 DB 상태 확인
- 엔티티 변경 시 팀 공유

### 7-2. 코드 리뷰 체크포인트
- [ ] 새로운 엔티티 추가/삭제 시 팀 공지
- [ ] FK 관계 변경 시 스키마 영향도 확인
- [ ] 브랜치 병합 전 DB 스키마 호환성 검증

### 7-3. 추가 예방 방법
- **브랜치별 DB 분리 고려**:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/dialogym_${git.branch:main}
```
- **Docker 기반 개발 환경 구축**:
```yaml
# docker-compose.yml로 독립적인 DB 환경 제공
```
- **엔티티 변경 시 Migration 스크립트 작성**

---

## 8. 결론 및 배운 점

### 8-1. 주요 성과
1. **브랜치 전환 시 스키마 충돌 문제 해결**
2. **Hibernate create-drop의 한계점 이해**
3. **팀 개발 환경 안정성 향상**

### 8-2. 기술적 학습

**Hibernate DDL 동작 원리**:
- `create-drop`은 외래키 제약조건으로 인해 완전한 정리가 어려움
- 브랜치 간 엔티티 차이는 스키마 충돌을 야기함
- `create` 설정이 개발 환경에서 더 안전할 수 있음

**브랜치 관리와 데이터베이스**:
- 엔티티 구조 변경은 팀 전체에 영향
- 브랜치별 스키마 차이는 예상치 못한 문제 야기
- DB 상태와 코드 상태의 동기화 중요성

### 8-3. 프로세스 개선

**엔티티 변경 시 팀 공유 프로세스**:
- [ ] 새로운 엔티티 추가/삭제 시 Discord 공지
- [ ] PR에 스키마 변경 내용 명시
- [ ] 브랜치 병합 후 팀원들에게 DB 재생성 안내

**개발 환경 개선 고려사항**:
- [ ] Docker 기반 개발 환경 구축 검토
- [ ] 브랜치별 DB 분리 방안 검토
- [ ] Migration 기반 스키마 관리 도입 검토

### 8-4. 장기적 개선 방향

**개발 환경 표준화**:
- Docker Compose를 이용한 독립적인 개발 환경 구축
- 브랜치별 데이터베이스 자동 분리 시스템

**스키마 관리 개선**:
- Flyway 등 Migration 도구 도입 검토
- 스키마 변경 자동 감지 및 알림 시스템

**팀 협업 프로세스**:
- 엔티티 변경 시 의무적 팀 공유
- 브랜치 병합 시 DB 재생성 자동화 스크립트 제공

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 담당자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.27 | 왕택준 | 최초 작성 |
