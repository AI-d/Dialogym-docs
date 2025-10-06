# API 테스트 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: API를 개발하고 문서화하는 담당자
* **QA 엔지니어**: API 기능 검증과 테스트를 수행하는 담당자
* **프론트엔드 개발자**: API 스펙을 확인하고 통합하는 담당자
* **DevOps 엔지니어**: API 테스트를 CI/CD에 통합하는 담당자

---

## 핵심 요약 (Executive Summary)

본 문서는 dialogym 프로젝트의 API 테스트와 문서화 방법을 정의합니다.
Springdoc OpenAPI를 사용하여 API 스펙을 자동으로 문서화하고 Swagger UI를 생성합니다.
Postman으로 API 엔드포인트를 수동 테스트하고, 컬렉션을 팀과 공유합니다.
Newman을 통해 Postman 테스트를 CI 파이프라인에 통합하여 자동 검증합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Swagger 문서화](#swagger-문서화)
3. [Postman 테스트](#postman-테스트)
4. [Newman CI 통합](#newman-ci-통합)
5. [API 버전 관리](#api-버전-관리)

---

## 문서 개요 (Overview)

본 문서는 API 테스트와 문서화 프로세스를 명확히 하기 위해 작성되었습니다.

API 문서가 없으면 프론트엔드 개발자가 스펙을 파악하기 어렵고, 수동 테스트는 반복 작업이 많아 비효율적입니다. Swagger와 Postman을 활용하여 문서화와 테스트를 자동화합니다.

---

## Swagger 문서화

### Springdoc OpenAPI 설정

**build.gradle 의존성 추가:**

```gradle
dependencies {
    implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.2.0'
}
```

**설정 클래스:**

```java
package com.dialogym.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("dialogym API")
                .version("1.0.0")
                .description("dialogym 백엔드 API 문서")
                .contact(new Contact()
                    .name("dialogym Team")
                    .email("contact@dialogym.com")))
            .servers(List.of(
                new Server().url("http://localhost:8080").description("Local"),
                new Server().url("https://api-staging.dialogym.com").description("Staging"),
                new Server().url("https://api.dialogym.com").description("Production")
            ))
            .components(new Components()
                .addSecuritySchemes("bearerAuth", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT")))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"));
    }
}
```

### Controller 문서화

```java
package com.dialogym.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@Tag(name = "Users", description = "사용자 관리 API")
public class UserController {

    @GetMapping
    @Operation(
        summary = "사용자 목록 조회",
        description = "전체 사용자 목록을 조회합니다"
    )
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses(value = {
        @ApiResponse(
            responseCode = "200",
            description = "조회 성공",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = UserResponse.class)
            )
        ),
        @ApiResponse(responseCode = "401", description = "인증 실패")
    })
    public List<UserResponse> getUsers() {
        return userService.findAll();
    }

    @PostMapping
    @Operation(
        summary = "사용자 생성",
        description = "새로운 사용자를 생성합니다"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "생성 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청")
    })
    public UserResponse createUser(@RequestBody UserCreateRequest request) {
        return userService.create(request);
    }
}
```

### DTO 문서화

```java
package com.dialogym.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "사용자 생성 요청")
public record UserCreateRequest(

    @Schema(description = "이메일", example = "user@example.com")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    @NotBlank(message = "이메일은 필수입니다")
    String email,

    @Schema(description = "비밀번호", example = "password123")
    @NotBlank(message = "비밀번호는 필수입니다")
    @Size(min = 8, message = "비밀번호는 최소 8자 이상이어야 합니다")
    String password,

    @Schema(description = "이름", example = "홍길동")
    @NotBlank(message = "이름은 필수입니다")
    String name
) {}
```

### Swagger UI 접근

```bash
# 로컬 개발
http://localhost:8080/swagger-ui.html

# Staging
https://api-staging.dialogym.com/swagger-ui.html

# Production (선택적)
https://api.dialogym.com/swagger-ui.html
```

---

## Postman 테스트

### Postman 워크스페이스 설정

1. **워크스페이스 생성**
   ```
   Postman → Workspaces → Create Workspace
   Name: dialogym-api
   Type: Team
   ```

2. **컬렉션 생성**
   ```
   Workspaces → dialogym-api → Create Collection
   Name: dialogym Backend API
   ```

3. **환경 변수 설정**
   ```
   Environments → Create Environment

   Local:
   - base_url: http://localhost:8080
   - api_token: (로컬 토큰)

   Staging:
   - base_url: https://api-staging.dialogym.com
   - api_token: (Staging 토큰)

   Production:
   - base_url: https://api.dialogym.com
   - api_token: (Production 토큰)
   ```

### 컬렉션 구조

```
dialogym Backend API/
├── Auth/
│   ├── POST Login
│   ├── POST Signup
│   ├── POST Refresh Token
│   └── POST Logout
├── Users/
│   ├── GET List Users
│   ├── POST Create User
│   ├── GET Get User by ID
│   ├── PATCH Update User
│   └── DELETE Delete User
└── Health/
    └── GET Health Check
```

### 요청 예시

**POST Login:**
```
Method: POST
URL: {{base_url}}/api/auth/login
Headers:
  Content-Type: application/json
Body (raw JSON):
{
  "email": "user@example.com",
  "password": "password123"
}
```

**GET List Users (인증 필요):**
```
Method: GET
URL: {{base_url}}/api/users
Headers:
  Authorization: Bearer {{api_token}}
```

### 테스트 스크립트

**로그인 후 토큰 저장:**
```javascript
// Tests 탭
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has token", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('token');

    // 토큰을 환경 변수에 저장
    pm.environment.set("api_token", jsonData.token);
});

pm.test("Response time is less than 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});
```

**사용자 생성 검증:**
```javascript
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("User created with correct data", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData.email).to.eql("newuser@example.com");
    pm.expect(jsonData).to.have.property('id');
    pm.expect(jsonData).to.have.property('createdAt');
});
```

### 컬렉션 내보내기

```bash
# Postman에서 컬렉션 내보내기
Collections → ... → Export
Format: Collection v2.1

# Git에 저장
git add postman/dialogym-api.postman_collection.json
git add postman/dialogym-env-local.postman_environment.json
git commit -m "TRAIN-XX docs: Postman 컬렉션 업데이트"
```

---

## Newman CI 통합

### Newman 설치

```bash
npm install --save-dev newman newman-reporter-htmlextra
```

### 로컬 실행

```bash
# 기본 실행
npx newman run postman/dialogym-api.postman_collection.json \
  -e postman/dialogym-env-local.postman_environment.json

# HTML 리포트 생성
npx newman run postman/dialogym-api.postman_collection.json \
  -e postman/dialogym-env-staging.postman_environment.json \
  -r htmlextra \
  --reporter-htmlextra-export ./newman-report.html
```

### GitHub Actions 통합

`.github/workflows/api-test.yml`:

```yaml
name: API Test

on:
  push:
    branches: [dev, main]
  schedule:
    - cron: '0 0 * * *'

jobs:
  api-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Newman
        run: npm install -g newman newman-reporter-htmlextra

      - name: Run API Tests (Staging)
        if: github.ref == 'refs/heads/dev'
        run: |
          newman run postman/dialogym-api.postman_collection.json \
            -e postman/dialogym-env-staging.postman_environment.json \
            --env-var "api_token=${{ secrets.STAGING_API_TOKEN }}" \
            -r cli,htmlextra \
            --reporter-htmlextra-export ./newman-report.html

      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: newman-report
          path: newman-report.html

      - name: Notify Slack on failure
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "❌ API 테스트 실패: ${{ github.ref_name }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
          SLACK_WEBHOOK_TYPE: INCOMING_WEBHOOK
```

### package.json 스크립트

```json
{
  "scripts": {
    "test:api": "newman run postman/dialogym-api.postman_collection.json -e postman/dialogym-env-local.postman_environment.json",
    "test:api:staging": "newman run postman/dialogym-api.postman_collection.json -e postman/dialogym-env-staging.postman_environment.json",
    "test:api:report": "newman run postman/dialogym-api.postman_collection.json -e postman/dialogym-env-local.postman_environment.json -r htmlextra --reporter-htmlextra-export ./newman-report.html"
  }
}
```

---

## API 버전 관리

### URL 기반 버전 관리

```java
@RestController
@RequestMapping("/api/v1/users")
public class UserV1Controller {
    // v1 로직
}

@RestController
@RequestMapping("/api/v2/users")
public class UserV2Controller {
    // v2 로직 (Breaking Changes 포함)
}
```

### 헤더 기반 버전 관리

```java
@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public List<UserResponse> getUsers(
        @RequestHeader(value = "API-Version", defaultValue = "1") String version
    ) {
        if ("2".equals(version)) {
            return userService.findAllV2();
        }
        return userService.findAll();
    }
}
```

---

## 관련 문서

* [테스트 전략](testing-strategy.md)
* [성능 테스트](performance-testing.md)
* [백엔드 배포](../deployment/deployment-backend.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
