# Swagger 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.10

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Spring Boot API에 Swagger 주석을 작성하고 API 문서를 자동 생성하는 담당자
* **프론트엔드 개발자**: Swagger UI를 통해 API 명세를 확인하고 테스트하는 담당자
* **신규 합류자**: Swagger 설정과 어노테이션 사용법을 처음 학습하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Spring Boot 프로젝트에서 Swagger를 활용한 API 문서화 방법을 정의합니다.
Swagger는 RESTful API를 시각적으로 문서화하고 테스트할 수 있는 도구입니다.
모든 Controller 메서드에는 Swagger 어노테이션이 필수이며, JavaDoc과 결합하여 완전한 API 명세서를 자동 생성합니다.
Swagger UI는 `/swagger-ui.html` 경로에서 접근할 수 있습니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Swagger 소개](#swagger-소개)
3. [프로젝트 설정](#프로젝트-설정)
4. [주요 어노테이션](#주요-어노테이션)
5. [Controller 문서화](#controller-문서화)
6. [요청/응답 문서화](#요청응답-문서화)
7. [인증 설정](#인증-설정)
8. [Swagger UI 사용](#swagger-ui-사용)
9. [작성 원칙](#작성-원칙)

---

## 문서 개요 (Overview)

본 문서는 프로젝트에서 Swagger를 활용한 API 문서화 방법을 표준화하기 위해 작성되었습니다.

API 개발 시 프론트엔드 개발자와 백엔드 개발자 간 API 명세에 대한 소통 비용이 발생하고, 수동으로 작성한 문서는 코드와 동기화되지 않아 신뢰성이 떨어지는 문제가 있었습니다.

Swagger는 코드 기반으로 API 문서를 자동 생성하여 항상 최신 상태를 유지하며, 실시간 API 테스트 기능을 제공합니다.

---

## Swagger 소개

### Swagger란?

Swagger는 RESTful API를 설계, 빌드, 문서화하고 사용하기 위한 오픈소스 도구입니다.

**주요 기능:**

- API 엔드포인트 자동 문서화
- 대화형 API 테스트 인터페이스 (Swagger UI)
- 요청/응답 모델 정의
- 인증 방식 설정
- API 그룹화 및 태그 지정

---

### Swagger vs OpenAPI

- **OpenAPI**: API 명세 표준 (현재 OpenAPI 3.0)
- **Swagger**: OpenAPI 명세를 구현한 도구 세트
- **SpringDoc**: Spring Boot 3.x에서 OpenAPI 3.0을 지원하는 라이브러리

---

### Swagger 활용 시나리오

**백엔드 개발자:**

- API 엔드포인트 문서화
- API 변경 사항 자동 반영
- API 테스트 및 디버깅

**프론트엔드 개발자:**

- API 명세 확인
- 요청/응답 형식 파악
- 실제 API 호출 테스트

**팀 전체:**

- API 명세서로 활용
- 커뮤니케이션 비용 절감
- 외부 개발자에게 API 제공

---

## 프로젝트 설정

### 의존성 추가

**build.gradle (Spring Boot 3.x)**

```gradle
dependencies {
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.0'
}
```

**pom.xml (Maven)**

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
```

---

### 기본 설정

**application.yml**

```yaml
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    tags-sorter: alpha
    operations-sorter: alpha
  default-consumes-media-type: application/json
  default-produces-media-type: application/json
```

---

### OpenAPI 설정 클래스

```java
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger/OpenAPI 설정 클래스입니다.
 *
 * @author 왕택준
 */
@Configuration
public class SwaggerConfig {

    /**
     * OpenAPI 설정을 정의합니다.
     *
     * @return OpenAPI 객체
     */
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("프로젝트 API")
                .version("1.0.0")
                .description("프로젝트 RESTful API 명세서")
                .contact(new Contact()
                    .name("왕택준")
                    .email("tjk98@example.com")
                    .url("https://github.com/TJK98")));
    }
}
```

---

## 주요 어노테이션

### @Tag

Controller 클래스를 그룹화합니다.

```java
@Tag(name = "사용자 관리", description = "사용자 CRUD API")
@RestController
@RequestMapping("/api/users")
public class UserController {
    // ...
}
```

---

### @Operation

개별 API 엔드포인트를 설명합니다.

```java
@Operation(
    summary = "사용자 생성",
    description = "새로운 사용자를 생성합니다. 이메일 중복 검사를 수행합니다."
)
@PostMapping
public ResponseEntity<User> createUser(@RequestBody UserDto userDto) {
    // ...
}
```

---

### @Parameter

메서드 파라미터를 설명합니다.

```java
@Operation(summary = "사용자 조회")
@GetMapping("/{id}")
public ResponseEntity<User> getUser(
    @Parameter(description = "사용자 ID", required = true, example = "1")
    @PathVariable Long id
) {
    // ...
}
```

---

### @ApiResponse / @ApiResponses

API 응답을 정의합니다.

```java
@Operation(summary = "사용자 생성")
@ApiResponses(value = {
    @ApiResponse(
        responseCode = "201",
        description = "사용자 생성 성공",
        content = @Content(schema = @Schema(implementation = User.class))
    ),
    @ApiResponse(
        responseCode = "400",
        description = "잘못된 요청 (유효성 검증 실패)"
    ),
    @ApiResponse(
        responseCode = "409",
        description = "이메일 중복"
    )
})
@PostMapping
public ResponseEntity<User> createUser(@RequestBody UserDto userDto) {
    // ...
}
```

---

### @Schema

모델(DTO, Entity)을 설명합니다.

```java
@Schema(description = "사용자 정보")
public class UserDto {

    @Schema(description = "사용자 이름", example = "홍길동", required = true)
    private String name;

    @Schema(description = "이메일 주소", example = "hong@example.com", required = true)
    private String email;

    @Schema(description = "나이", example = "25", minimum = "1", maximum = "150")
    private Integer age;

    // getter, setter...
}
```

---

### @Hidden

특정 API를 문서에서 숨깁니다.

```java
@Hidden
@GetMapping("/internal")
public ResponseEntity<String> internalApi() {
    // 내부 API로 문서화하지 않음
}
```

---

## Controller 문서화

### 기본 Controller 문서화

```java
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 사용자 관리 API 컨트롤러입니다.
 *
 * @author 왕택준
 */
@Tag(name = "사용자 관리", description = "사용자 CRUD API")
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 사용자 목록을 조회합니다.
     *
     * @param page 페이지 번호
     * @param size 페이지 크기
     * @return 사용자 목록
     */
    @Operation(
        summary = "사용자 목록 조회",
        description = "페이징을 지원하는 사용자 목록을 조회합니다."
    )
    @GetMapping
    public ResponseEntity<Page<UserDto>> getUsers(
        @Parameter(description = "페이지 번호 (0부터 시작)", example = "0")
        @RequestParam(defaultValue = "0") int page,

        @Parameter(description = "페이지 크기", example = "10")
        @RequestParam(defaultValue = "10") int size
    ) {
        Page<UserDto> users = userService.getUsers(page, size);
        return ResponseEntity.ok(users);
    }

    /**
     * ID로 사용자를 조회합니다.
     *
     * @param id 사용자 ID
     * @return 사용자 정보
     */
    @Operation(summary = "사용자 조회", description = "ID로 특정 사용자를 조회합니다.")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "조회 성공",
            content = @Content(schema = @Schema(implementation = UserDto.class))
        ),
        @ApiResponse(
            responseCode = "404",
            description = "사용자를 찾을 수 없음"
        )
    })
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(
        @Parameter(description = "사용자 ID", required = true, example = "1")
        @PathVariable Long id
    ) {
        UserDto user = userService.getUser(id);
        return ResponseEntity.ok(user);
    }

    /**
     * 새로운 사용자를 생성합니다.
     *
     * @param userDto 생성할 사용자 정보
     * @return 생성된 사용자
     */
    @Operation(
        summary = "사용자 생성",
        description = "새로운 사용자를 생성합니다. 이메일 중복 검사를 수행합니다."
    )
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "201",
            description = "생성 성공",
            content = @Content(schema = @Schema(implementation = UserDto.class))
        ),
        @ApiResponse(
            responseCode = "400",
            description = "잘못된 요청"
        ),
        @ApiResponse(
            responseCode = "409",
            description = "이메일 중복"
        )
    })
    @PostMapping
    public ResponseEntity<UserDto> createUser(
        @io.swagger.v3.oas.annotations.parameters.RequestBody(
            description = "생성할 사용자 정보",
            required = true,
            content = @Content(schema = @Schema(implementation = UserDto.class))
        )
        @RequestBody @Valid UserDto userDto
    ) {
        UserDto createdUser = userService.createUser(userDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }

    /**
     * 사용자 정보를 수정합니다.
     *
     * @param id 수정할 사용자 ID
     * @param userDto 수정할 정보
     * @return 수정된 사용자
     */
    @Operation(summary = "사용자 수정", description = "기존 사용자 정보를 수정합니다.")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "수정 성공"
        ),
        @ApiResponse(
            responseCode = "404",
            description = "사용자를 찾을 수 없음"
        )
    })
    @PutMapping("/{id}")
    public ResponseEntity<UserDto> updateUser(
        @Parameter(description = "사용자 ID", required = true)
        @PathVariable Long id,

        @RequestBody @Valid UserDto userDto
    ) {
        UserDto updatedUser = userService.updateUser(id, userDto);
        return ResponseEntity.ok(updatedUser);
    }

    /**
     * 사용자를 삭제합니다.
     *
     * @param id 삭제할 사용자 ID
     * @return 삭제 결과
     */
    @Operation(summary = "사용자 삭제", description = "사용자를 삭제합니다.")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "204",
            description = "삭제 성공"
        ),
        @ApiResponse(
            responseCode = "404",
            description = "사용자를 찾을 수 없음"
        )
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(
        @Parameter(description = "사용자 ID", required = true)
        @PathVariable Long id
    ) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

---

## 요청/응답 문서화

### DTO 문서화

```java
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 사용자 생성/수정 요청 DTO입니다.
 *
 * @author 왕택준
 */
@Schema(description = "사용자 정보")
public class UserDto {

    @Schema(description = "사용자 ID (조회 시에만 포함)", accessMode = Schema.AccessMode.READ_ONLY, example = "1")
    private Long id;

    @Schema(description = "사용자 이름", example = "홍길동", required = true, minLength = 2, maxLength = 50)
    @NotBlank(message = "이름은 필수입니다")
    @Size(min = 2, max = 50, message = "이름은 2-50자 사이여야 합니다")
    private String name;

    @Schema(description = "이메일 주소", example = "hong@example.com", required = true)
    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    private String email;

    @Schema(description = "나이", example = "25", minimum = "1", maximum = "150")
    private Integer age;

    @Schema(description = "전화번호", example = "010-1234-5678")
    private String phone;

    @Schema(description = "계정 생성 일시", accessMode = Schema.AccessMode.READ_ONLY)
    private LocalDateTime createdAt;

    // getter, setter...
}
```

---

### Enum 문서화

```java
@Schema(description = "사용자 역할")
public enum UserRole {

    @Schema(description = "관리자")
    ADMIN,

    @Schema(description = "일반 사용자")
    USER,

    @Schema(description = "게스트")
    GUEST
}
```

---

### 에러 응답 문서화

```java
@Schema(description = "에러 응답")
public class ErrorResponse {

    @Schema(description = "에러 코드", example = "USER_NOT_FOUND")
    private String code;

    @Schema(description = "에러 메시지", example = "사용자를 찾을 수 없습니다")
    private String message;

    @Schema(description = "발생 시각")
    private LocalDateTime timestamp;

    // getter, setter...
}
```

---

## 인증 설정

### JWT 인증 설정

```java
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("프로젝트 API")
                .version("1.0.0"))
            .components(new Components()
                .addSecuritySchemes("bearer-jwt",
                    new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")
                        .in(SecurityScheme.In.HEADER)
                        .name("Authorization")))
            .addSecurityItem(new SecurityRequirement().addList("bearer-jwt"));
    }
}
```

---

### Controller에 인증 명시

```java
import io.swagger.v3.oas.annotations.security.SecurityRequirement;

@Tag(name = "사용자 관리")
@RestController
@RequestMapping("/api/users")
@SecurityRequirement(name = "bearer-jwt")
public class UserController {
    // 모든 메서드에 JWT 인증 필요
}
```

또는 개별 메서드에만:

```java
@Operation(summary = "사용자 생성")
@SecurityRequirement(name = "bearer-jwt")
@PostMapping
public ResponseEntity<UserDto> createUser(@RequestBody UserDto userDto) {
    // ...
}
```

---

## Swagger UI 사용

### 접속 방법

애플리케이션 실행 후 다음 URL로 접속합니다.

```
http://localhost:9090/swagger-ui.html
```

---

### Swagger UI 기능

**1. API 목록 확인**
- 좌측에서 태그별로 그룹화된 API 확인
- 각 API의 HTTP 메서드와 경로 확인

**2. API 상세 정보**
- API 클릭 시 요청/응답 스키마 확인
- 파라미터 정보 확인

**3. API 테스트**
- "Try it out" 버튼 클릭
- 파라미터 입력
- "Execute" 버튼으로 실제 API 호출
- 응답 결과 확인

**4. 인증 설정**
- 우측 상단 "Authorize" 버튼 클릭
- JWT 토큰 입력
- 인증이 필요한 API 테스트

---

### OpenAPI JSON 확인

```
http://localhost:9090/api-docs
```

OpenAPI 명세를 JSON 형식으로 확인할 수 있습니다.

---

## 작성 원칙

### 필수 작성 대상

다음 항목에는 반드시 Swagger 어노테이션을 작성합니다.

- 모든 Controller 클래스 (@Tag)
- 모든 API 엔드포인트 (@Operation)
- 모든 요청 DTO (@Schema)
- 모든 응답 DTO (@Schema)
- 복잡한 파라미터 (@Parameter)

---

### 작성 규칙

**명확성:**
- summary는 간단하게, description은 상세하게 작성
- 예시(example) 값을 반드시 포함
- 응답 코드별로 설명 작성

**일관성:**
- 태그 이름은 한글로 통일
- summary는 "~조회", "~생성", "~수정", "~삭제" 형식으로 통일
- 에러 응답 코드는 프로젝트 전체에서 일관되게 사용

**완전성:**
- 모든 가능한 응답 코드 정의
- 인증이 필요한 API는 명시
- 페이징, 정렬 파라미터 상세히 설명

---

### 나쁜 예시

```java
@PostMapping
public User create(@RequestBody User user) {
    return userService.create(user);
}
```

**문제점:**
- Swagger 어노테이션 없음
- API 설명 없음
- 응답 코드 정의 없음
- 에러 처리 누락

---

### 좋은 예시

```java
@Operation(
    summary = "사용자 생성",
    description = "새로운 사용자를 생성합니다. 이메일 중복 검사를 수행하며, 중복 시 409 에러를 반환합니다."
)
@ApiResponses(value = {
    @ApiResponse(
        responseCode = "201",
        description = "생성 성공",
        content = @Content(schema = @Schema(implementation = UserDto.class))
    ),
    @ApiResponse(
        responseCode = "400",
        description = "잘못된 요청 (유효성 검증 실패)",
        content = @Content(schema = @Schema(implementation = ErrorResponse.class))
    ),
    @ApiResponse(
        responseCode = "409",
        description = "이메일 중복",
        content = @Content(schema = @Schema(implementation = ErrorResponse.class))
    )
})
@PostMapping
public ResponseEntity<UserDto> createUser(
    @io.swagger.v3.oas.annotations.parameters.RequestBody(
        description = "생성할 사용자 정보",
        required = true,
        content = @Content(schema = @Schema(implementation = UserDto.class))
    )
    @RequestBody @Valid UserDto userDto
) {
    UserDto createdUser = userService.createUser(userDto);
    return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
}
```

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.10 | 왕택준 | 최초 작성 |
