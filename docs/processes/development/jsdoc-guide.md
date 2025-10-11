# JSDoc 작성 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.10

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: React 컴포넌트와 JavaScript 함수에 JSDoc 주석을 작성하는 담당자
* **풀스택 개발자**: 프론트엔드 코드에 타입 정보와 설명을 추가하여 문서화하는 담당자
* **신규 합류자**: JSDoc 작성 규칙을 처음 학습하고 팀의 코드 문서화 표준을 따라야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트의 JavaScript 코드에 JSDoc 주석을 작성하는 표준을 정의합니다.
JSDoc은 함수, 컴포넌트, 매개변수, 반환 값에 대한 타입과 설명을 제공하여 코드 가독성과 유지보수성을 향상시킵니다.
모든 공개(export) 함수와 컴포넌트에는 JSDoc 주석이 필수입니다.
주석은 간결하고 명확하게 작성하며, 예시 코드가 필요한 경우 @example 태그를 사용합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [JSDoc 기본 구조](#jsdoc-기본-구조)
3. [주요 태그](#주요-태그)
4. [React 컴포넌트 문서화](#react-컴포넌트-문서화)
5. [함수 문서화](#함수-문서화)
6. [타입 정의](#타입-정의)
7. [작성 원칙](#작성-원칙)

---

## 문서 개요 (Overview)

본 문서는 팀 내 JavaScript 코드의 일관된 문서화를 위해 작성되었습니다.

코드 리뷰 과정에서 함수의 목적, 매개변수의 의미, 반환 값의 타입을 이해하는 데 시간이 소요되는 문제가 발생했습니다.
JSDoc 주석을 표준화하여 코드 자체가 명세서 역할을 할 수 있도록 하고, IDE의 자동완성과 타입 체크 기능을 활용할 수 있도록 합니다.

본 가이드는 Storybook과 연계하여 컴포넌트 명세서를 자동 생성하는 데 활용됩니다.

---

## JSDoc 기본 구조

JSDoc 주석은 `/**`로 시작하고 `*/`로 끝나며, 함수나 컴포넌트 정의 바로 위에 작성합니다.

```javascript
/**
 * 함수나 컴포넌트에 대한 설명을 작성합니다.
 *
 * @param {string} name - 매개변수 설명
 * @returns {boolean} 반환 값 설명
 */
function exampleFunction(name) {
  return true;
}
```

---

## 주요 태그

### @param

함수의 매개변수를 설명합니다.

**형식:**
```javascript
@param {타입} 매개변수명 - 설명
```

**예시:**
```javascript
/**
 * 사용자 정보를 조회합니다.
 *
 * @param {string} userId - 사용자 ID
 * @param {boolean} includeProfile - 프로필 정보 포함 여부
 */
function getUser(userId, includeProfile) {
  // ...
}
```

---

### @returns (또는 @return)

함수의 반환 값을 설명합니다.

**형식:**
```javascript
@returns {타입} 설명
```

**예시:**
```javascript
/**
 * 두 숫자의 합을 계산합니다.
 *
 * @param {number} a - 첫 번째 숫자
 * @param {number} b - 두 번째 숫자
 * @returns {number} 두 숫자의 합
 */
function add(a, b) {
  return a + b;
}
```

---

### @typedef

사용자 정의 타입을 정의합니다.

**예시:**
```javascript
/**
 * @typedef {Object} User
 * @property {string} id - 사용자 ID
 * @property {string} name - 사용자 이름
 * @property {string} email - 이메일 주소
 * @property {number} age - 나이
 */

/**
 * 사용자 정보를 생성합니다.
 *
 * @param {string} name - 사용자 이름
 * @param {string} email - 이메일 주소
 * @returns {User} 생성된 사용자 객체
 */
function createUser(name, email) {
  // ...
}
```

---

### @example

사용 예시를 제공합니다.

**예시:**
```javascript
/**
 * 배열의 중복을 제거합니다.
 *
 * @param {Array} arr - 중복 제거할 배열
 * @returns {Array} 중복이 제거된 배열
 *
 * @example
 * removeDuplicates([1, 2, 2, 3, 4, 4, 5]);
 * // Returns: [1, 2, 3, 4, 5]
 */
function removeDuplicates(arr) {
  return [...new Set(arr)];
}
```

---

### @deprecated

더 이상 사용하지 않는 함수나 컴포넌트를 표시합니다.

**예시:**
```javascript
/**
 * 사용자 정보를 조회합니다.
 *
 * @deprecated getUserV2()를 사용하세요.
 * @param {string} userId - 사용자 ID
 * @returns {Object} 사용자 정보
 */
function getUser(userId) {
  // ...
}
```

---

## React 컴포넌트 문서화

React 컴포넌트는 props에 대한 타입과 설명을 명확히 작성합니다.

### 함수형 컴포넌트

```javascript
/**
 * 사용자 프로필을 표시하는 컴포넌트입니다.
 *
 * @param {Object} props - 컴포넌트 props
 * @param {string} props.name - 사용자 이름
 * @param {string} props.email - 사용자 이메일
 * @param {string} [props.avatar] - 프로필 이미지 URL (선택)
 * @param {Function} props.onEdit - 편집 버튼 클릭 핸들러
 * @returns {JSX.Element}
 *
 * @example
 * <UserProfile
 *   name="홍길동"
 *   email="hong@example.com"
 *   onEdit={() => console.log('Edit clicked')}
 * />
 */
function UserProfile({ name, email, avatar, onEdit }) {
  return (
    <div>
      {avatar && <img src={avatar} alt={name} />}
      <h2>{name}</h2>
      <p>{email}</p>
      <button onClick={onEdit}>편집</button>
    </div>
  );
}
```

---

### Props 타입 정의

복잡한 props는 @typedef로 별도 정의합니다.

```javascript
/**
 * @typedef {Object} ButtonProps
 * @property {string} label - 버튼 텍스트
 * @property {'primary'|'secondary'|'danger'} variant - 버튼 스타일
 * @property {boolean} [disabled=false] - 비활성화 여부
 * @property {Function} onClick - 클릭 이벤트 핸들러
 */

/**
 * 재사용 가능한 버튼 컴포넌트입니다.
 *
 * @param {ButtonProps} props - 버튼 props
 * @returns {JSX.Element}
 *
 * @example
 * <Button
 *   label="저장"
 *   variant="primary"
 *   onClick={() => console.log('Saved')}
 * />
 */
function Button({ label, variant = 'primary', disabled = false, onClick }) {
  return (
    <button
      className={`btn btn-${variant}`}
      disabled={disabled}
      onClick={onClick}
    >
      {label}
    </button>
  );
}
```

---

## 함수 문서화

### 일반 함수

```javascript
/**
 * 날짜를 형식화합니다.
 *
 * @param {Date} date - 형식화할 날짜 객체
 * @param {string} [format='YYYY-MM-DD'] - 날짜 형식
 * @returns {string} 형식화된 날짜 문자열
 *
 * @example
 * formatDate(new Date(), 'YYYY-MM-DD');
 * // Returns: "2025-10-10"
 */
function formatDate(date, format = 'YYYY-MM-DD') {
  // ...
}
```

---

### 비동기 함수

```javascript
/**
 * API에서 사용자 목록을 가져옵니다.
 *
 * @async
 * @param {number} page - 페이지 번호
 * @param {number} limit - 페이지당 항목 수
 * @returns {Promise<Array<User>>} 사용자 목록
 * @throws {Error} API 호출 실패 시
 *
 * @example
 * const users = await fetchUsers(1, 10);
 */
async function fetchUsers(page, limit) {
  const response = await fetch(`/api/users?page=${page}&limit=${limit}`);
  if (!response.ok) {
    throw new Error('Failed to fetch users');
  }
  return response.json();
}
```

---

### 콜백 함수

```javascript
/**
 * @callback FilterCallback
 * @param {*} item - 배열 항목
 * @param {number} index - 항목 인덱스
 * @returns {boolean} 필터링 결과
 */

/**
 * 배열을 필터링하고 결과를 반환합니다.
 *
 * @param {Array} array - 필터링할 배열
 * @param {FilterCallback} callback - 필터링 함수
 * @returns {Array} 필터링된 배열
 */
function filterArray(array, callback) {
  return array.filter(callback);
}
```

---

## 타입 정의

### 기본 타입

| 타입 | 설명 |
|------|------|
| `string` | 문자열 |
| `number` | 숫자 |
| `boolean` | 불리언 |
| `Object` | 객체 |
| `Array` | 배열 |
| `Function` | 함수 |
| `null` | null |
| `undefined` | undefined |
| `*` | 모든 타입 |

---

### 복합 타입

```javascript
/**
 * 유니온 타입 (여러 타입 중 하나)
 * @param {string|number} id - 문자열 또는 숫자
 */

/**
 * 배열 타입
 * @param {Array<string>} names - 문자열 배열
 * @param {string[]} tags - 문자열 배열 (축약형)
 */

/**
 * 객체 타입
 * @param {{name: string, age: number}} user - 사용자 객체
 */

/**
 * 선택적 매개변수
 * @param {string} [name] - 선택적 이름
 * @param {number} [age=18] - 기본값이 있는 선택적 나이
 */
```

---

## 작성 원칙

### 필수 작성 대상

다음 항목에는 반드시 JSDoc 주석을 작성합니다.

- 모든 export된 함수
- 모든 React 컴포넌트
- 공개 API 함수
- 복잡한 비즈니스 로직을 포함한 함수

---

### 작성 규칙

**명확성:**
- 설명은 간결하고 명확하게 작성합니다
- 불필요한 장황한 설명은 피합니다

**일관성:**
- 팀 전체가 동일한 용어와 형식을 사용합니다
- @param, @returns 순서를 일관되게 유지합니다

**완전성:**
- 모든 매개변수와 반환 값에 대한 설명을 포함합니다
- 예외 상황(@throws)이 있다면 명시합니다

**예시 제공:**
- 복잡한 함수는 @example을 포함합니다
- 실제 사용 가능한 코드를 예시로 작성합니다

---

### 나쁜 예시

```javascript
/**
 * 함수
 * @param a
 * @param b
 */
function calculate(a, b) {
  return a + b;
}
```

**문제점:**
- 함수의 목적이 불명확
- 매개변수 타입 누락
- 반환 값 설명 누락

---

### 좋은 예시

```javascript
/**
 * 두 숫자를 더합니다.
 *
 * @param {number} a - 첫 번째 숫자
 * @param {number} b - 두 번째 숫자
 * @returns {number} 두 숫자의 합
 *
 * @example
 * calculate(5, 3);
 * // Returns: 8
 */
function calculate(a, b) {
  return a + b;
}
```

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.10 | 왕택준 | 최초 작성 |
