# 테스트 전략

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: JUnit 테스트와 Spring Boot Test를 작성하는 담당자
* **프론트엔드 개발자**: Jest 테스트와 React Testing Library를 작성하는 담당자
* **QA 엔지니어**: 테스트 시나리오를 작성하고 품질을 검증하는 담당자
* **팀 리더 / PM**: 테스트 커버리지를 관리하고 품질 기준을 수립하는 책임자

---

## 핵심 요약 (Executive Summary)

본 문서는 dialogym 프로젝트의 테스트 작성 규칙과 품질 기준을 정의합니다.
백엔드는 JUnit 5와 Mockito를 사용하고, 프론트엔드는 Jest와 React Testing Library를 사용합니다.
테스트는 단위 테스트, 통합 테스트, E2E 테스트로 구분하며, 각 레벨별로 도구와 작성 시점을 명확히 합니다.
TDD 방식을 권장하지만 강제하지 않으며, 핵심 로직에 대한 테스트 작성을 우선합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [도구 선택](#도구-선택)
3. [테스트 레벨](#테스트-레벨)
4. [백엔드 테스트](#백엔드-테스트)
5. [프론트엔드 테스트](#프론트엔드-테스트)
6. [커버리지 기준](#커버리지-기준)
7. [테스트 작성 시점](#테스트-작성-시점)
8. [베스트 프랙티스](#베스트-프랙티스)

---

## 문서 개요 (Overview)

본 문서는 프로젝트 팀에서 사용하는 테스트 작성 규칙과 품질 기준을 정의하기 위해 작성되었습니다.

코드 품질을 유지하고 버그를 조기에 발견하기 위해서는 체계적인 테스트 전략이 필요합니다. 본 문서는 백엔드(Java/Spring Boot)와 프론트엔드(React) 각각의 테스트 방법을 정의합니다.

---

## 도구 선택

### 백엔드

| 용도        | 도구               | 이유                   |
|-----------|------------------|----------------------|
| 단위 테스트    | JUnit 5          | Spring Boot 표준       |
| Mocking   | Mockito          | Spring Boot 기본 지원    |
| Assertion | AssertJ          | 가독성 높은 체이닝           |
| 통합 테스트    | Spring Boot Test | `@SpringBootTest` 지원 |
| API 테스트   | MockMvc          | Controller 테스트       |
| DB 테스트    | Testcontainers   | 실제 PostgreSQL 사용     |

### 프론트엔드

| 용도       | 도구                    | 이유         |
|----------|-----------------------|------------|
| 단위 테스트   | Jest                  | React 표준   |
| 컴포넌트 테스트 | React Testing Library | 사용자 관점 테스트 |
| E2E 테스트  | Playwright            | 빠르고 안정적    |
| Mocking  | MSW                   | API 모킹     |

---

## 테스트 레벨

### 단위 테스트 (Unit Test)

**대상**: 개별 함수, 메서드, 클래스

**특징**:

- 빠른 실행 속도
- 외부 의존성 없음 (Mock 사용)
- 격리된 환경

### 통합 테스트 (Integration Test)

**대상**: 여러 컴포넌트 간 상호작용

**특징**:

- 실제 DB 사용
- Spring Context 로딩
- API 레이어 전체 테스트

### E2E 테스트 (End-to-End Test)

**대상**: 전체 사용자 시나리오

**특징**:

- 브라우저 자동화
- 실제 환경과 유사
- 가장 느린 실행 속도

---

## 백엔드 테스트

### JUnit 5 단위 테스트

**build.gradle 설정:**

```gradle
dependencies {
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.mockito:mockito-core'
    testImplementation 'org.assertj:assertj-core'
}

test {
    useJUnitPlatform()
}
```

**기본 테스트 구조:**

```java
package com.dialogym.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.BeforeEach;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("이메일로 사용자 조회 성공")
    void findByEmail_Success() {
        // Given
        String email = "test@example.com";
        User user = User.builder()
                .email(email)
                .name("테스트")
                .build();

        when(userRepository.findByEmail(email))
                .thenReturn(Optional.of(user));

        // When
        User result = userService.findByEmail(email);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getEmail()).isEqualTo(email);
        verify(userRepository, times(1)).findByEmail(email);
    }

    @Test
    @DisplayName("존재하지 않는 이메일 조회 시 예외 발생")
    void findByEmail_NotFound_ThrowsException() {
        // Given
        String email = "nonexistent@example.com";
        when(userRepository.findByEmail(email))
                .thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> userService.findByEmail(email))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessage("User not found: " + email);
    }
}
```

### Spring Boot 통합 테스트

```java
package com.dialogym.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void createUser_Success() throws Exception {
        String requestBody = """
                {
                    "email": "test@example.com",
                    "password": "password123",
                    "name": "테스트"
                }
                """;

        mockMvc.perform(post("/api/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.name").value("테스트"));
    }

    @Test
    void getUserList_Success() throws Exception {
        mockMvc.perform(get("/api/users")
                        .header("Authorization", "Bearer " + getValidToken()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    private String getValidToken() {
        // JWT 토큰 생성 로직
        return "valid-jwt-token";
    }
}
```

### Repository 테스트 (Testcontainers)

```java
package com.dialogym.repository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.*;

@DataJpaTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @Autowired
    private UserRepository userRepository;

    @Test
    void findByEmail_Success() {
        // Given
        User user = User.builder()
                .email("test@example.com")
                .name("테스트")
                .build();
        userRepository.save(user);

        // When
        Optional<User> result = userRepository.findByEmail("test@example.com");

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getEmail()).isEqualTo("test@example.com");
    }
}
```

---

## 프론트엔드 테스트

### Jest 단위 테스트

**package.json 설정:**

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "devDependencies": {
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "@testing-library/user-event": "^14.0.0",
    "jest": "^29.0.0"
  }
}
```

**유틸리티 함수 테스트:**

```javascript
// utils/validation.test.js
import {validateEmail, validatePassword} from './validation';

describe('validateEmail', () => {
    test('올바른 이메일 형식은 true 반환', () => {
        expect(validateEmail('user@example.com')).toBe(true);
        expect(validateEmail('test.user@domain.co.kr')).toBe(true);
    });

    test('잘못된 이메일 형식은 false 반환', () => {
        expect(validateEmail('invalid-email')).toBe(false);
        expect(validateEmail('user@')).toBe(false);
        expect(validateEmail('@example.com')).toBe(false);
    });
});

describe('validatePassword', () => {
    test('8자 이상 비밀번호는 true 반환', () => {
        expect(validatePassword('password123')).toBe(true);
    });

    test('8자 미만 비밀번호는 false 반환', () => {
        expect(validatePassword('pass')).toBe(false);
    });
});
```

### React 컴포넌트 테스트

```javascript
// components/LoginForm.test.jsx
import {render, screen, fireEvent, waitFor} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LoginForm from './LoginForm';

describe('LoginForm', () => {
    test('폼이 올바르게 렌더링됨', () => {
        render(<LoginForm/>);

        expect(screen.getByLabelText(/이메일/i)).toBeInTheDocument();
        expect(screen.getByLabelText(/비밀번호/i)).toBeInTheDocument();
        expect(screen.getByRole('button', {name: /로그인/i})).toBeInTheDocument();
    });

    test('올바른 입력값으로 로그인 성공', async () => {
        const onSubmit = jest.fn();
        const user = userEvent.setup();

        render(<LoginForm onSubmit={onSubmit}/>);

        await user.type(screen.getByLabelText(/이메일/i), 'test@example.com');
        await user.type(screen.getByLabelText(/비밀번호/i), 'password123');
        await user.click(screen.getByRole('button', {name: /로그인/i}));

        await waitFor(() => {
            expect(onSubmit).toHaveBeenCalledWith({
                email: 'test@example.com',
                password: 'password123'
            });
        });
    });

    test('잘못된 이메일 형식 시 에러 메시지 표시', async () => {
        const user = userEvent.setup();

        render(<LoginForm/>);

        await user.type(screen.getByLabelText(/이메일/i), 'invalid-email');
        await user.click(screen.getByRole('button', {name: /로그인/i}));

        expect(await screen.findByText(/올바른 이메일 형식이 아닙니다/i)).toBeInTheDocument();
    });
});
```

### E2E 테스트 (Playwright)

```javascript
// e2e/login.spec.js
import {test, expect} from '@playwright/test';

test.describe('로그인 플로우', () => {
    test('사용자 로그인 및 대시보드 이동', async ({page}) => {
        // 로그인 페이지 이동
        await page.goto('https://staging.dialogym.com/login');

        // 로그인 폼 입력
        await page.fill('[name="email"]', 'test@example.com');
        await page.fill('[name="password"]', 'password123');

        // 로그인 버튼 클릭
        await page.click('button[type="submit"]');

        // 대시보드로 리다이렉트 확인
        await expect(page).toHaveURL(/.*dashboard/);

        // 사용자 이름 표시 확인
        await expect(page.locator('text=테스트님')).toBeVisible();
    });

    test('잘못된 비밀번호로 로그인 실패', async ({page}) => {
        await page.goto('https://staging.dialogym.com/login');

        await page.fill('[name="email"]', 'test@example.com');
        await page.fill('[name="password"]', 'wrongpassword');
        await page.click('button[type="submit"]');

        // 에러 메시지 확인
        await expect(page.locator('text=이메일 또는 비밀번호가 일치하지 않습니다')).toBeVisible();
    });
});
```

---

## 커버리지 기준

### 목표 커버리지

| 영역                   | 목표   | 허용  | 비고         |
|----------------------|------|-----|------------|
| 전체                   | 70%  | 60% | 점진적 향상     |
| 핵심 로직 (인증, 결제)       | 90%  | 80% | 필수         |
| 유틸리티                 | 100% | 95% | 필수         |
| Controller/Component | 60%  | 50% | 통합 테스트로 보완 |

### 필수 테스트 대상

**백엔드:**

- 인증/인가 로직 (JWT, Security)
- 데이터 검증 (Validation)
- 비즈니스 로직 (Service)
- Repository 쿼리
- 에러 핸들링

**프론트엔드:**

- 폼 검증
- API 호출 로직
- 상태 관리 (Redux/Zustand)
- 라우팅
- 주요 컴포넌트

### 커버리지 확인

**백엔드:**

```bash
./gradlew test jacocoTestReport

# 리포트 확인
open build/reports/jacoco/test/html/index.html
```

**프론트엔드:**

```bash
npm run test:coverage

# 리포트 확인
open coverage/lcov-report/index.html
```

---

## 테스트 작성 시점

### 방식 1: TDD (권장)

```
1. 실패하는 테스트 작성
2. 테스트를 통과하는 최소 코드 작성
3. 리팩토링
```

**장점:**

- 명확한 요구사항 정의
- 높은 커버리지
- 리팩토링 안정성

**단점:**

- 초기 시간 소요
- 러닝 커브

### 방식 2: 일반 개발 (허용)

```
1. 기능 구현
2. 테스트 작성
```

**사용 시점:**

- 프로토타입 검증
- 요구사항이 불명확할 때
- 빠른 실험 필요 시

### 팀 규칙

**필수:**

- PR 전에 테스트 코드 존재
- 커버리지 기준 충족
- CI 통과

**선택:**

- TDD 방식 사용 여부
- 테스트 작성 순서

---

## 베스트 프랙티스

### DO

- 테스트 이름을 명확하게 (`@DisplayName` 활용)
- 한 테스트에 한 가지만 검증
- Given-When-Then 패턴 사용
- 독립적인 테스트 작성
- Mock은 필요한 경우만 사용
- 실패 메시지를 명확하게

### DON'T

- 테스트 간 의존성 생성
- 너무 많은 것을 한 번에 테스트
- 구현 세부사항 테스트 (내부 메서드)
- 하드코딩된 시간 사용
- 실제 외부 서비스 호출
- 테스트를 주석 처리

---

## 관련 문서

* [API 테스트](api-testing.md)
* [성능 테스트](performance-testing.md)
* [CI/CD 통합](../deployment/ci-cd-integration.md)

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|-----|----------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성    |
