# 테스트 전략

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.05

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: API 테스트와 단위 테스트를 작성하는 담당자
* **프론트엔드 개발자**: 컴포넌트 테스트와 E2E 테스트를 작성하는 담당자
* **풀스택 개발자**: 통합 테스트와 전체 시나리오를 검증하는 담당자
* **QA 엔지니어**: 테스트 시나리오를 작성하고 품질을 검증하는 담당자
* **팀 리더 / PM**: 테스트 커버리지를 관리하고 품질 기준을 수립하는 책임자

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트의 테스트 작성 규칙과 품질 기준을 정의합니다.
테스트는 단위 테스트, 통합 테스트, E2E 테스트 세 가지 레벨로 구분하며, 각 레벨별로 도구와 작성 시점을 명확히 합니다.
전체 커버리지 80%, 핵심 로직 90%, 유틸리티 100%를 목표로 하며, AAA 패턴과 테스트 독립성 원칙을 따릅니다.
Jira 이슈와 연동하여 TDD 방식으로 테스트를 먼저 작성하고, CI 파이프라인에 통합하여 자동 검증합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [테스트 레벨](#테스트-레벨)
3. [작성 규칙](#작성-규칙)
4. [커버리지 기준](#커버리지-기준)
5. [Jira 연동](#jira-연동)
6. [CI 통합](#ci-통합)
7. [테스트 작성 가이드](#테스트-작성-가이드)
8. [테스트 디버깅](#테스트-디버깅)
9. [베스트 프랙티스](#베스트-프랙티스)

---

## 문서 개요 (Overview)

본 문서는 프로젝트 팀에서 사용하는 테스트 작성 규칙과 품질 기준을 정의하기 위해 작성되었습니다.

코드 품질을 유지하고 버그를 조기에 발견하기 위해서는 체계적인 테스트 전략이 필요합니다.
본 문서는 단위 테스트, 통합 테스트, E2E 테스트 각 레벨별 작성 방법과 커버리지 기준을 제시하여
팀 전체가 일관된 방식으로 테스트를 작성할 수 있도록 합니다.

TDD(Test-Driven Development) 방식을 권장하며, CI 파이프라인에 테스트를 통합하여 자동 검증합니다.

---

## 테스트 레벨

### 단위 테스트 (Unit Test)

**대상**: 함수, 클래스, 메서드

**도구**:
- Backend: Jest, Vitest
- Frontend: Jest, Vitest, React Testing Library

**작성 시점**: 기능 개발과 동시

**예시**:
```javascript
// user.service.test.js
describe('UserService', () => {
  describe('validateEmail', () => {
    test('올바른 이메일 형식은 true 반환', () => {
      expect(validateEmail('user@example.com')).toBe(true);
    });

    test('잘못된 이메일 형식은 false 반환', () => {
      expect(validateEmail('invalid-email')).toBe(false);
    });
  });
});
```

---

### 통합 테스트 (Integration Test)

**대상**: 여러 모듈 간 상호작용

**도구**:
- Backend: Supertest (API), Testcontainers (DB)
- Frontend: React Testing Library

**작성 시점**: 주요 기능 완료 후

**예시**:
```javascript
// auth.integration.test.js
describe('POST /api/auth/login', () => {
  test('올바른 인증정보로 로그인 성공', async () => {
    const response = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'user@example.com',
        password: 'password123'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('token');
  });
});
```

---

### E2E 테스트 (End-to-End Test)

**대상**: 전체 사용자 시나리오

**도구**: Playwright, Cypress

**작성 시점**: 주요 기능 완성 후

**예시**:
```javascript
// login.e2e.test.js
test('사용자 로그인 플로우', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'user@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('/dashboard');
});
```

---

## 작성 규칙

### 테스트 네이밍

```javascript
// ✅ 좋은 예
describe('UserService', () => {
  describe('login', () => {
    test('올바른 인증정보로 로그인 성공', () => {});
    test('잘못된 비밀번호로 로그인 실패', () => {});
    test('존재하지 않는 이메일로 로그인 실패', () => {});
  });
});

// ❌ 나쁜 예
describe('test', () => {
  test('test1', () => {});
  test('test2', () => {});
});
```

---

### AAA 패턴 (Arrange-Act-Assert)

```javascript
test('사용자 생성 성공', () => {
  // Arrange: 준비
  const userData = {
    email: 'user@example.com',
    password: 'password123'
  };

  // Act: 실행
  const user = createUser(userData);

  // Assert: 검증
  expect(user.email).toBe('user@example.com');
  expect(user.password).not.toBe('password123'); // 암호화 확인
});
```

---

### 테스트 독립성

```javascript
// ✅ 좋은 예: 각 테스트마다 초기화
beforeEach(() => {
  // 데이터베이스 초기화
  // Mock 초기화
});

test('테스트 1', () => {
  // 독립적으로 실행
});

test('테스트 2', () => {
  // 테스트 1의 영향 받지 않음
});
```

---

## 커버리지 기준

### 최소 커버리지

| 영역 | 목표 | 필수 |
|------|------|------|
| 전체 | 80% | ✅ |
| 핵심 로직 | 90% | ✅ |
| 유틸리티 | 100% | ✅ |
| UI 컴포넌트 | 70% | ✅ |

---

### 필수 테스트 대상

#### 백엔드

```markdown
- [ ] 인증/인가 로직
- [ ] 데이터 검증
- [ ] 비즈니스 로직
- [ ] API 엔드포인트
- [ ] 에러 처리
```

---

#### 프론트엔드

```markdown
- [ ] 폼 검증
- [ ] 상태 관리
- [ ] API 통신
- [ ] 라우팅
- [ ] 주요 컴포넌트
```

---

### 커버리지 확인

```bash
# 커버리지 리포트 생성
npm run test:coverage

# 결과 확인
open coverage/lcov-report/index.html
```

---

## Jira 연동

### 테스트 작성 워크플로우

```bash
# 1. Jira 이슈 확인
TRAIN-12: 사용자 로그인 기능 구현

# 2. 테스트 먼저 작성 (TDD)
# user.service.test.js

# 3. 구현
# user.service.js

# 4. 커밋
git commit -m "TRAIN-12 test: 로그인 테스트 추가"
git commit -m "TRAIN-12 feat: 로그인 기능 구현"
```

---

### PR 체크리스트

```markdown
- [ ] 새로운 기능에 대한 단위 테스트 추가
- [ ] 통합 테스트 추가 (필요 시)
- [ ] 모든 테스트 통과
- [ ] 커버리지 기준 충족 (80% 이상)
- [ ] 테스트 네이밍 규칙 준수
```

---

## CI 통합

### GitHub Actions 워크플로우

```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration

      - name: Check coverage
        run: npm run test:coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

---

### 테스트 실패 시 대응

```markdown
1. 로컬에서 재현
   npm run test:unit -- --watch

2. 실패 원인 파악
   - 테스트 로직 오류
   - 환경 차이
   - 의존성 문제

3. 수정 후 재실행
   git commit -m "TRAIN-12 fix: 테스트 오류 수정"
   git push

4. CI 재실행 확인
```

---

## 테스트 작성 가이드

### Mock 사용

```javascript
// API 호출 Mock
import { vi } from 'vitest';

const mockFetch = vi.fn();
global.fetch = mockFetch;

test('사용자 정보 가져오기', async () => {
  mockFetch.mockResolvedValue({
    ok: true,
    json: async () => ({ id: 1, email: 'user@example.com' })
  });

  const user = await fetchUser(1);

  expect(user.email).toBe('user@example.com');
  expect(mockFetch).toHaveBeenCalledWith('/api/users/1');
});
```

---

### 비동기 테스트

```javascript
// async/await 사용
test('비동기 데이터 로딩', async () => {
  const data = await loadData();
  expect(data).toBeDefined();
});

// Promise 사용
test('비동기 데이터 로딩', () => {
  return loadData().then(data => {
    expect(data).toBeDefined();
  });
});
```

---

### 에러 테스트

```javascript
test('잘못된 입력값으로 에러 발생', () => {
  expect(() => {
    validateEmail('invalid-email');
  }).toThrow('Invalid email format');
});

// 비동기 에러
test('API 호출 실패 시 에러 발생', async () => {
  await expect(fetchUser(-1)).rejects.toThrow('User not found');
});
```

---

## 테스트 디버깅

### 로컬 실행

```bash
# 전체 테스트
npm test

# 특정 파일
npm test user.service.test.js

# Watch 모드
npm test -- --watch

# 커버리지 포함
npm run test:coverage

# 특정 테스트만
npm test -- -t "로그인 성공"
```

---

### 디버깅 팁

```javascript
// console.log 사용
test('디버깅', () => {
  const result = someFunction();
  console.log('Result:', result);
  expect(result).toBe(expected);
});

// 테스트 일시 중지
test.skip('나중에 수정', () => {
  // 일시적으로 건너뛰기
});

// 특정 테스트만 실행
test.only('이것만 실행', () => {
  // 이 테스트만 실행됨
});
```

---

## 베스트 프랙티스

### DO

```markdown
✅ 테스트 이름을 명확하게
✅ 한 테스트에 한 가지만 검증
✅ 독립적인 테스트 작성
✅ AAA 패턴 사용
✅ Mock은 필요한 경우만
✅ 실패 메시지를 명확하게
```

---

### DON'T

```markdown
❌ 테스트 간 의존성
❌ 너무 많은 것을 한 번에 테스트
❌ 구현 세부사항 테스트
❌ 하드코딩된 타이밍
❌ 실제 외부 서비스 호출
❌ 테스트를 주석 처리
```

---

## 자주 묻는 질문

### Q1: 레거시 코드는 어떻게 테스트하나요?

```
A: 다음 순서로 진행합니다:
1. 수정하는 부분만 테스트 추가
2. 점진적으로 커버리지 확대
3. 리팩토링 시 테스트 먼저 작성
```

---

### Q2: 테스트 작성 시간이 부족합니다

```
A: 우선순위를 설정합니다:
1. 핵심 비즈니스 로직 (필수)
2. 자주 변경되는 부분
3. 버그가 자주 발생하는 부분
4. 나머지는 점진적으로
```

---

### Q3: 테스트가 너무 느립니다

```
A: 최적화 방법:
1. 단위 테스트만 자주 실행
2. 통합/E2E는 CI에서만
3. 병렬 실행 설정
4. 불필요한 Mock 제거
```

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.05 | 왕택준 | 최초 작성 |
