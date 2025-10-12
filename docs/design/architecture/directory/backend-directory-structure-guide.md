# 백엔드 디렉토리 구조 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.11

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Spring Boot 프로젝트 구조를 이해하고 코드를 올바른 위치에 작성하는 담당자
* **풀스택 개발자**: 백엔드 코드베이스 구조를 파악하고 API를 개발하는 담당자
* **신규 합류자**: 프로젝트 디렉토리 구조와 파일 위치 규칙을 처음 학습하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Spring Boot 기반 백엔드 프로젝트의 디렉토리 구조를 정의합니다.
프로젝트는 도메인 중심 구조를 채택하며, 비즈니스 로직은 domain/ 디렉토리에 도메인별로 격리됩니다.
각 도메인은 entity, repository, service, controller, dto로 구성되며, 전역 설정은 global/ 디렉토리에서 관리합니다.
파일 네이밍은 역할별 접미사를 사용하며, 패키지 구조는 도메인 우선 원칙을 따릅니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [도메인 중심 구조](#도메인-중심-구조)
3. [전체 디렉토리 구조](#전체-디렉토리-구조)
4. [디렉토리별 상세 설명](#디렉토리별-상세-설명)
5. [파일 네이밍 규칙](#파일-네이밍-규칙)
6. [계층별 책임](#계층별-책임)
7. [운영 원칙](#운영-원칙)

---

## 문서 개요 (Overview)

본 문서는 프로젝트의 백엔드 디렉토리 구조를 표준화하기 위해 작성되었습니다.

프로젝트 규모가 커지면서 클래스를 어디에 위치시켜야 할지, 어떤 기준으로 패키지를 나눠야 할지에 대한 혼란이 발생했습니다.
일관된 디렉토리 구조는 코드 검색성을 높이고, 신규 개발자의 온보딩 시간을 단축하며, 유지보수성을 향상시킵니다.

본 가이드는 Spring Boot 프레임워크를 기반으로 하며, 도메인 중심 아키텍처를 채택합니다.

---

## 도메인 중심 구조

### 도메인 중심 구조란?

비즈니스 도메인별로 코드를 그룹화하는 아키텍처 패턴입니다.
각 도메인은 독립적인 단위로 관리되며, 높은 응집도와 낮은 결합도를 유지합니다.

---

### 계층형 vs 도메인 중심

**계층형 구조:**
```
src/
├── controller/     # 모든 컨트롤러
├── service/        # 모든 서비스
├── repository/     # 모든 레포지토리
└── entity/         # 모든 엔티티
```

**문제점:**
- 관련 코드가 흩어져 있음
- 도메인 추가 시 여러 디렉토리 수정 필요
- 패키지 간 의존성 파악 어려움

---

**도메인 중심 구조:**
```
src/
├── domain/
│   ├── user/
│   │   ├── entity/
│   │   ├── repository/
│   │   ├── service/
│   │   └── controller/
│   └── scenario/
│       ├── entity/
│       ├── repository/
│       ├── service/
│       └── controller/
└── global/         # 전역 설정
```

**장점:**
- 관련 코드가 한곳에 모임
- 도메인 단위 개발/테스트 용이
- 명확한 경계와 책임

---

## 전체 디렉토리 구조

```
backend/
└── src/main/java/com/dialogym/
    ├── domain/
    │   ├── user/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   ├── controller/
    │   │   └── dto/
    │   │       ├── request/
    │   │       └── response/
    │   │
    │   ├── terms/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   ├── controller/
    │   │   └── dto/
    │   │       ├── request/
    │   │       └── response/
    │   │
    │   ├── verification/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   └── dto/
    │   │       └── request/
    │   │
    │   ├── scenario/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   ├── controller/
    │   │   └── dto/
    │   │       ├── request/
    │   │       └── response/
    │   │
    │   ├── session/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   ├── controller/
    │   │   └── dto/
    │   │       ├── request/
    │   │       └── response/
    │   │
    │   ├── history/
    │   │   ├── entity/
    │   │   ├── repository/
    │   │   ├── service/
    │   │   ├── controller/
    │   │   └── dto/
    │   │       └── response/
    │   │
    │   └── feedback/
    │       ├── entity/
    │       ├── repository/
    │       ├── service/
    │       ├── controller/
    │       └── dto/
    │           └── response/
    │
    └── global/
        ├── config/
        ├── exception/
        │   └── custom/
        ├── response/
        ├── security/
        │   └── oauth/
        └── util/
```

---

## 디렉토리별 상세 설명

### domain/ - 도메인 모듈

비즈니스 도메인별로 구조화된 모듈입니다.

**구조 원칙:**
- 각 도메인은 독립적인 단위
- 다른 도메인에 직접 의존하지 않음
- global/을 통해서만 공통 기능 사용

---

### domain/{domain}/entity/ - 엔티티

**역할:**
- JPA 엔티티 클래스 정의
- 데이터베이스 테이블 매핑
- 비즈니스 로직 메서드 포함

**위치:**
- 엔티티 클래스: `entity/`
- Enum 타입: `entity/enums/`

**작성 규칙:**
- @Entity 어노테이션 사용
- @Table로 테이블명 지정
- Lombok @Getter, @NoArgsConstructor 사용
- Builder 패턴 사용
- 상태 변경 메서드는 엔티티 내부에 작성

---

### domain/{domain}/repository/ - 레포지토리

**역할:**
- JPA Repository 인터페이스 정의
- 데이터베이스 접근 추상화
- 커스텀 쿼리 메서드 정의

**작성 규칙:**
- JpaRepository 상속
- 메서드명 규칙 준수 (findBy, existsBy, deleteBy 등)
- 복잡한 쿼리는 @Query 사용
- N+1 문제 방지를 위해 Fetch Join 활용

---

### domain/{domain}/service/ - 서비스

**역할:**
- 비즈니스 로직 처리
- 트랜잭션 관리
- 도메인 로직 조합

**파일 구분:**
- `Service`: 쓰기 작업 (등록, 수정, 삭제)
- `QueryService`: 읽기 작업 (조회)

**작성 규칙:**
- @Service 어노테이션 사용
- @Transactional 적절히 사용
- 쓰기 작업과 읽기 작업 분리 (CQRS 패턴)
- 비즈니스 로직 검증 포함
- 예외 처리는 커스텀 예외 사용

---

### domain/{domain}/controller/ - 컨트롤러

**역할:**
- HTTP 요청/응답 처리
- 입력 값 검증
- Service 호출

**작성 규칙:**
- @RestController 사용
- @RequestMapping으로 기본 경로 설정
- @Valid로 입력 값 검증
- Swagger 어노테이션 필수 (@Operation, @Tag)
- 응답은 ApiResponse로 래핑

---

### domain/{domain}/dto/ - DTO

**역할:**
- 요청/응답 데이터 전송
- 계층 간 데이터 전달
- Entity 노출 방지

**파일 구분:**
- `request/`: 요청 DTO
- `response/`: 응답 DTO

**작성 규칙:**
- Request: Validation 어노테이션 필수 (@NotBlank, @Email 등)
- Response: Entity에서 DTO로 변환하는 정적 메서드 제공 (from, of)
- Swagger 어노테이션 필수 (@Schema)
- Lombok @Getter, @Builder 사용

---

### global/ - 전역 설정

프로젝트 전역에서 사용되는 공통 설정과 유틸리티입니다.

---

### global/config/ - 설정 클래스

**역할:**
- Spring 전역 설정
- 외부 라이브러리 설정
- Bean 등록

**작성 규칙:**
- @Configuration 어노테이션 사용
- @Bean으로 Bean 등록
- 설정별로 파일 분리

---

### global/exception/ - 예외 처리

**역할:**
- 전역 예외 처리
- 커스텀 예외 정의
- 에러 응답 통일

**파일 구분:**
- `GlobalExceptionHandler`: @RestControllerAdvice로 전역 예외 처리
- `ErrorCode`: Enum으로 에러 코드 관리
- `ErrorResponse`: 에러 응답 DTO
- `custom/`: 커스텀 예외 클래스

**작성 규칙:**
- 예외는 ErrorCode 기반으로 생성
- 커스텀 예외는 RuntimeException 상속
- HTTP 상태 코드, 에러 코드, 메시지 포함

---

### global/response/ - 공통 응답

**역할:**
- API 응답 형식 통일
- 성공/실패 응답 래핑

**작성 규칙:**
- 제네릭 타입 사용
- success, data, message 필드 포함
- 정적 팩토리 메서드 제공

---

### global/security/ - 보안

**역할:**
- JWT 인증/인가
- OAuth2 소셜 로그인
- Spring Security 설정

**작성 규칙:**
- JWT는 JwtTokenProvider에서 생성/검증
- Filter는 OncePerRequestFilter 상속
- OAuth2는 oauth/ 하위에 분리

---

### global/util/ - 유틸리티

**역할:**
- 공통 헬퍼 함수
- 날짜, 문자열, 암호화 등 처리

**작성 규칙:**
- 순수 함수 (static 메서드)
- 상태를 갖지 않음
- 특정 도메인에 종속되지 않음

---

## 파일 네이밍 규칙

### 엔티티
- **형식**: {도메인명}.java
- **예시**: User.java, Scenario.java, PracticeSession.java

### Enum
- **형식**: {상태명}.java
- **예시**: Provider.java, UserStatus.java, Difficulty.java

### 레포지토리
- **형식**: {엔티티명}Repository.java
- **예시**: UserRepository.java, ScenarioRepository.java

### 서비스
- **형식**: {도메인명}Service.java, {도메인명}QueryService.java
- **예시**: UserService.java, UserQueryService.java

### 컨트롤러
- **형식**: {도메인명}Controller.java
- **예시**: UserController.java, ScenarioController.java

### Request DTO
- **형식**: {도메인명}{동작}Request.java
- **예시**: UserCreateRequest.java, UserUpdateRequest.java

### Response DTO
- **형식**: {도메인명}Response.java, {도메인명}DetailResponse.java
- **예시**: UserResponse.java, UserDetailResponse.java

---

## 계층별 책임

### Controller 계층
- HTTP 요청/응답 처리만 담당
- 비즈니스 로직 포함 금지
- 입력 값 검증 (@Valid)
- Service 호출
- 응답 DTO 반환

### Service 계층
- 비즈니스 로직 처리
- 트랜잭션 관리
- Repository 호출
- Entity → DTO 변환
- 예외 처리

### Repository 계층
- 데이터베이스 접근
- CRUD 작업
- 쿼리 메서드 정의

### Entity 계층
- 데이터베이스 테이블 매핑
- 비즈니스 규칙 포함
- 상태 변경 메서드 제공

---

## 운영 원칙

### 1. 도메인 격리

각 도메인은 독립적으로 동작해야 합니다.

**올바른 예:**
- `user` 도메인이 `scenario` 도메인의 Service를 직접 호출하지 않음
- 필요시 `global/`의 공통 모듈 사용

**잘못된 예:**
- `user.service.UserService`에서 `scenario.service.ScenarioService` 직접 의존

---

### 2. 계층 간 의존 방향

계층 간 의존은 단방향이어야 합니다.

**의존 방향:**
```
Controller → Service → Repository → Entity
```

**올바른 예:**
- Controller가 Service를 의존
- Service가 Repository를 의존

**잘못된 예:**
- Repository가 Service를 의존
- Entity가 Controller를 의존

---

### 3. 쓰기/읽기 분리

Service는 쓰기와 읽기를 분리합니다.

**쓰기 Service:**
- 등록, 수정, 삭제
- @Transactional

**읽기 Service:**
- 조회
- @Transactional(readOnly = true)

---

### 4. DTO 변환 위치

Entity → DTO 변환은 Service 또는 Response DTO에서 처리합니다.

**올바른 예:**
- Response DTO에 `from(Entity)` 정적 메서드 제공
- Service에서 변환 후 반환

**잘못된 예:**
- Controller에서 직접 변환
- Entity를 Controller까지 전달

---

### 5. 예외 처리

비즈니스 로직 예외는 커스텀 예외를 사용합니다.

**올바른 예:**
- Service에서 `throw new BusinessException(ErrorCode.USER_NOT_FOUND)`
- GlobalExceptionHandler에서 처리

**잘못된 예:**
- Service에서 `throw new RuntimeException("사용자 없음")`
- Controller에서 try-catch

---

### 6. Enum 위치

도메인별 Enum은 entity/enums/에 위치시킵니다.

**올바른 예:**
```
user/entity/enums/
├── Provider.java
└── UserStatus.java
```

**잘못된 예:**
```
global/enums/
├── Provider.java
└── UserStatus.java
```

---

### 7. 네이밍 일관성

파일명과 클래스명은 역할을 명확히 드러내야 합니다.

**올바른 예:**
- UserCreateRequest
- UserResponse
- UserService

**잘못된 예:**
- CreateUserDto
- GetUserDto
- UserBusiness

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.11 | 왕택준 | 최초 작성 |
