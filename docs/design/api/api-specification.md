# Dialogym API 명세서

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.02

**문서 버전 (Version)**: v1.0.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: API 엔드포인트를 구현하고 유지보수하는 담당자
* **프론트엔드 개발자**: API를 호출하여 클라이언트를 개발하는 담당자
* **QA 엔지니어**: API 테스트 케이스를 작성하고 검증하는 담당자
* **DevOps 엔지니어**: API 배포 및 모니터링 환경을 구축하는 담당자

---

## 핵심 요약 (Executive Summary)

본 문서는 TrAIn(Training AI for Communication) 프로젝트의 RESTful API 명세를 정의합니다.
API는 사용자 인증(JWT + HttpOnly Cookie), 시나리오 관리, 실시간 대화 세션, AI 피드백 생성 등의 기능을 제공합니다.
Base URL은 로컬 개발 환경 `http://localhost:9090`, 프로덕션 환경 `https://api.dialogym.shop`이며, 모든 API는 `/api/v1` prefix를 사용합니다.
인증은 Access Token(Bearer)과 Refresh Token(HttpOnly Cookie) 조합으로 구현되며, Refresh Token Rotation 방식을 적용합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [기본 정보](#기본-정보-basic-information)
3. [공통 응답 형식](#공통-응답-형식-common-response-format)
4. [User & Auth API](#user--auth-api)
5. [Verification API](#verification-api)
6. [Terms API](#terms-api)
7. [Scenario API](#scenario-api)
8. [Session API](#session-api)
9. [Transcript API](#transcript-api)
10. [Feedback API](#feedback-api)
11. [Realtime Session API](#realtime-session-api-webrtc)
12. [공통 에러 코드](#공통-에러-코드-common-error-codes)
13. [인증 흐름](#인증-흐름-authentication-flows)
14. [WebSocket 연결](#websocket-연결-realtime-conversation)
15. [데이터 모델](#데이터-모델-data-models)

---

## 문서 개요 (Overview)

본 문서는 Dialogym(TrAIn) 프로젝트의 백엔드 API 명세를 표준화하여 정의합니다.

프로젝트가 진행되면서 API 엔드포인트가 증가하고 팀원 간 협업이 활발해짐에 따라, API 구조와 규칙을 명확히 문서화할 필요성이 대두되었습니다.
본 명세서는 프론트엔드 개발자가 API를 정확히 호출할 수 있도록 요청/응답 형식, 인증 방식, 에러 처리 방법을 상세히 기술합니다.

API는 Spring Boot 기반으로 구현되며, JWT 인증, RESTful 설계 원칙, OpenAPI 3.0 규격을 준수합니다.

---

## 기본 정보 (Basic Information)

### 프로젝트 정보

| 항목 | 내용 |
|------|------|
| 프로젝트명 | TrAIn (Training AI for Communication) |
| 버전 | 1.0.0 |
| Base URL (로컬) | `http://localhost:9090` |
| Base URL (프로덕션) | `https://api.dialogym.shop` |
| API Prefix | `/api/v1` |

### 인증 방식

| 항목 | 방식 |
|------|------|
| Access Token | HTTP Authorization Header (`Bearer {token}`) |
| Refresh Token | HttpOnly Cookie (`refreshToken`) |
| Token Rotation | Refresh Token Rotation(RTR) 적용 |

---

## 공통 응답 형식 (Common Response Format)

모든 API는 일관된 응답 형식을 따릅니다.

### 성공 응답

```json
{
  "success": true,
  "message": "요청이 성공적으로 처리되었습니다.",
  "timestamp": "2025-11-02T10:30:00",
  "data": { ... },
  "errorCode": null
}
```

### 에러 응답

```json
{
  "success": false,
  "message": "에러 메시지",
  "timestamp": "2025-11-02T10:30:00",
  "data": null,
  "errorCode": "ERROR_CODE"
}
```

---

## User & Auth API

사용자 인증 및 회원 관리 API입니다.

### 회원가입

**Endpoint**: `POST /api/v1/users/signup`

로컬 계정으로 회원가입합니다.

#### Request Body

```json
{
  "name": "홍길동",
  "email": "user@example.com",
  "password": "password123!",
  "passwordConfirm": "password123!",
  "birthDate": "1990-01-01",
  "termsConsents": [
    {
      "termsId": 1,
      "agreed": true
    },
    {
      "termsId": 2,
      "agreed": true
    },
    {
      "termsId": 3,
      "agreed": false
    }
  ]
}
```

#### Response: `201 Created`

```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다. 이메일 인증을 진행해주세요.",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "emailVerificationToken": "abc123..."
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 (비밀번호 불일치, 나이 제한 등) |
| 400 | REQUIRED_TERMS_NOT_AGREED | 필수 약관 미동의 |
| 409 | EMAIL_ALREADY_EXISTS | 이미 사용 중인 이메일 |

---

### 로그인

**Endpoint**: `POST /api/v1/users/login`

이메일과 비밀번호로 로그인합니다.

#### Request Body

```json
{
  "email": "user@example.com",
  "password": "password123!"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "로그인에 성공했습니다.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null,
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동"
  }
}
```

#### Response Headers

```
Set-Cookie: refreshToken={token}; HttpOnly; Secure; SameSite=None
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 |
| 401 | INVALID_CREDENTIALS | 로그인 실패 (자격 증명 불일치) |
| 403 | EMAIL_NOT_VERIFIED | 이메일 미인증 사용자 |

---

### 로그아웃

**Endpoint**: `POST /api/v1/users/logout`

로그아웃하고 Refresh Token을 무효화합니다.

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "성공적으로 로그아웃되었습니다.",
  "data": null
}
```

---

### 토큰 갱신 (Refresh Token Rotation)

**Endpoint**: `POST /api/v1/users/refresh`

Refresh Token을 사용하여 새로운 Access Token과 Refresh Token을 발급받습니다.

#### Request

Cookie에서 `refreshToken` 자동 전송됩니다.

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "토큰이 성공적으로 갱신되었습니다.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

#### Response Headers

```
Set-Cookie: refreshToken={new_token}; HttpOnly; Secure; SameSite=None
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 401 | REFRESH_TOKEN_INVALID | Refresh Token이 없거나 유효하지 않음 (만료, 이미 사용됨 등) |

---

### 일회용 코드-토큰 교환

**Endpoint**: `POST /api/v1/users/token/exchange`

소셜 로그인 후 받은 일회용 코드를 Access Token과 Refresh Token으로 교환합니다.

#### Request Body

```json
{
  "code": "one-time-code-123"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "토큰 교환에 성공했습니다.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null,
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동"
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 |
| 401 | INVALID_CODE | 일회용 코드가 유효하지 않음 (만료, 사용됨 등) |

---

### 내 프로필 조회

**Endpoint**: `GET /api/v1/users/profile`

현재 로그인한 사용자의 프로필 정보를 조회합니다.

#### Request Headers

```
Authorization: Bearer {accessToken}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "프로필 조회에 성공했습니다.",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "birthDate": "1990-01-01",
    "provider": "LOCAL",
    "createdAt": "2025-11-01T10:00:00"
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 401 | UNAUTHORIZED | 인증되지 않은 사용자 (AccessToken 누락/만료/위조) |

---

### 내 프로필 수정

**Endpoint**: `PUT /api/v1/users/profile`

현재 로그인한 사용자의 프로필 정보를 수정합니다.

#### Request Headers

```
Authorization: Bearer {accessToken}
```

#### Request Body

```json
{
  "name": "홍길동",
  "birthDate": "1990-01-01"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "프로필이 성공적으로 수정되었습니다.",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "birthDate": "1990-01-01"
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 |
| 401 | UNAUTHORIZED | 인증되지 않은 사용자 |

---

### 비밀번호 변경

**Endpoint**: `PUT /api/v1/users/password`

현재 로그인한 사용자의 비밀번호를 변경합니다. (로컬 계정 전용)

#### Request Headers

```
Authorization: Bearer {accessToken}
```

#### Request Body

```json
{
  "currentPassword": "oldPassword123!",
  "newPassword": "newPassword456!",
  "newPasswordConfirm": "newPassword456!"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "비밀번호가 성공적으로 변경되었습니다.",
  "data": null
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 또는 현재 비밀번호 불일치 |
| 401 | UNAUTHORIZED | 인증되지 않은 사용자 |
| 403 | SOCIAL_ACCOUNT_PASSWORD_CHANGE | 소셜 로그인 계정 (비밀번호 변경 불가) |

---

## Verification API

이메일 인증 및 소셜 회원가입 완료 API입니다.

### 이메일 인증 확인

**Endpoint**: `POST /api/v1/verification/email`

회원가입 후 이메일로 받은 6자리 코드와 인증 토큰을 검증합니다.

#### Request Body

```json
{
  "emailVerificationToken": "abc123...",
  "verificationCode": "123456"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "이메일 인증이 완료되었습니다.",
  "data": {
    "verified": true,
    "email": "user@example.com"
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 인증 코드 불일치 |
| 410 | VERIFICATION_SESSION_EXPIRED | 인증 세션 만료 |

---

### 이메일 인증 코드 재발송

**Endpoint**: `POST /api/v1/verification/email/resend`

만료된 이메일 인증 코드를 재발송하고 새로운 인증 토큰을 반환합니다.

#### Request Body

```json
{
  "emailVerificationToken": "abc123..."
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "인증 이메일이 재발송되었습니다.",
  "data": {
    "success": true,
    "message": "인증 코드가 재발송되었습니다.",
    "emailVerificationToken": "newToken456..."
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 |
| 410 | VERIFICATION_SESSION_EXPIRED | 인증 세션 만료 |

---

### 소셜 회원가입 완료

**Endpoint**: `POST /api/v1/verification/social/complete`

소셜 로그인 후 신규 사용자가 추가 정보를 입력하여 회원가입을 완료합니다.

#### Request Body

```json
{
  "socialSignupToken": "social-token-123",
  "name": "홍길동",
  "birthDate": "1990-01-01",
  "termsConsents": [
    {
      "termsId": 1,
      "agreed": true
    }
  ]
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "소셜 회원가입 및 로그인이 완료되었습니다.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null,
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동"
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 (나이 제한, 필수 약관 미동의 등) |
| 401 | INVALID_TOKEN | 소셜 회원가입 대기 토큰이 유효하지 않음 (만료, 사용됨 등) |

---

## Terms API

서비스 약관 관리 API입니다.

### 활성 약관 목록 조회

**Endpoint**: `GET /api/v1/terms`

회원가입 등에 필요한 현재 활성화된 약관 목록을 조회합니다.

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "활성 약관 목록 조회에 성공했습니다.",
  "data": [
    {
      "termsId": 1,
      "title": "서비스 이용약관",
      "content": "약관 내용...",
      "version": "1.0",
      "required": true,
      "category": "SERVICE"
    }
  ]
}
```

---

### 내 약관 동의 내역 조회

**Endpoint**: `GET /api/v1/terms/consent`

현재 로그인한 사용자의 약관 동의 내역을 조회합니다.

#### Request Headers

```
Authorization: Bearer {accessToken}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "약관 동의 내역 조회에 성공했습니다.",
  "data": [
    {
      "termsId": 1,
      "title": "서비스 이용약관",
      "agreed": true,
      "agreedAt": "2025-11-01T10:00:00"
    }
  ]
}
```

---

### 약관 동의 변경

**Endpoint**: `PUT /api/v1/terms/consent`

마케팅 수신 동의 등 선택 약관에 대한 동의 상태를 변경합니다.

#### Request Headers

```
Authorization: Bearer {accessToken}
```

#### Request Body

```json
{
  "consents": [
    {
      "termsId": 2,
      "agreed": true
    }
  ]
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "약관 동의 상태가 변경되었습니다.",
  "data": null
}
```

---

## Scenario API

대화 시나리오 관리 API입니다.

### 전체 시나리오 조회

**Endpoint**: `GET /api/v1/scenarios`

모든 시나리오를 조회합니다.

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "전체 시나리오 조회를 성공했습니다.",
  "data": [
    {
      "id": 1,
      "title": "고객 응대 시나리오",
      "description": "고객 불만 처리 연습",
      "difficulty": "MEDIUM",
      "category": "CUSTOMER_SERVICE",
      "isDefault": true,
      "ownerId": null
    }
  ]
}
```

---

### 개별 시나리오 조회

**Endpoint**: `GET /api/v1/scenarios/{id}`

특정 시나리오의 상세 정보를 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | Long | 시나리오 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "1번 시나리오 조회에 성공했습니다.",
  "data": {
    "id": 1,
    "title": "고객 응대 시나리오",
    "description": "고객 불만 처리 연습",
    "difficulty": "MEDIUM",
    "category": "CUSTOMER_SERVICE",
    "isDefault": true
  }
}
```

---

### 기본 시나리오 조회

**Endpoint**: `GET /api/v1/scenarios/default`

시스템에서 제공하는 기본 시나리오 목록을 조회합니다.

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "기본 시나리오 조회에 성공했습니다.",
  "data": [
    {
      "id": 1,
      "title": "고객 응대 시나리오",
      "description": "고객 불만 처리 연습",
      "isDefault": true
    }
  ]
}
```

---

### 사용자 시나리오 생성

**Endpoint**: `POST /api/v1/scenarios`

사용자가 커스텀 시나리오를 생성합니다.

#### Request Body

```json
{
  "ownerId": 1,
  "title": "나만의 시나리오",
  "description": "커스텀 시나리오 설명",
  "difficulty": "EASY",
  "category": "CUSTOM",
  "aiPersona": "친절한 상담원",
  "userGoal": "문제 해결하기"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "시나리오 생성을 성공했습니다.",
  "data": {
    "id": 10,
    "title": "나만의 시나리오",
    "ownerId": 1,
    "isDefault": false
  }
}
```

---

### 사용자가 생성한 모든 시나리오 조회

**Endpoint**: `GET /api/v1/scenarios/me/{userId}`

특정 사용자가 생성한 모든 시나리오를 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | Long | 사용자 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "사용자가 생성한 모든 시나리오 조회를 성공했습니다.",
  "data": [
    {
      "id": 10,
      "title": "나만의 시나리오",
      "ownerId": 1,
      "isDefault": false
    }
  ]
}
```

---

### 사용자가 생성한 단일 시나리오 조회

**Endpoint**: `GET /api/v1/scenarios/me/{userId}/{id}`

특정 사용자가 생성한 특정 시나리오를 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | Long | 사용자 ID |
| id | Long | 시나리오 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "10번 시나리오 조회에 성공했습니다.",
  "data": {
    "id": 10,
    "title": "나만의 시나리오",
    "ownerId": 1
  }
}
```

---

### 사용자 시나리오 삭제

**Endpoint**: `DELETE /api/v1/scenarios/me/{userId}/{id}`

사용자가 생성한 시나리오를 삭제합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | Long | 사용자 ID |
| id | Long | 시나리오 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "시나리오 삭제에 성공했습니다",
  "data": ""
}
```

---

## Session API

대화 세션 관리 API입니다.

### 대화 세션 생성

**Endpoint**: `POST /api/v1/sessions`

새로운 대화 세션을 생성합니다.

#### Request Body

```json
{
  "userId": 1,
  "scenarioId": 1
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "대화 세션이 생성되었습니다.",
  "data": {
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "userId": 1,
    "scenarioId": 1,
    "scenarioTitle": "고객 응대 시나리오",
    "status": "ONGOING",
    "startedAt": "2025-11-02T10:30:00",
    "endedAt": null,
    "audioDurationSeconds": null
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 잘못된 요청 (유효하지 않은 userId 또는 scenarioId) |
| 500 | INTERNAL_SERVER_ERROR | 세션 생성 중 오류 발생 |

---

### 세션 상태 조회

**Endpoint**: `GET /api/v1/sessions/{sessionId}`

특정 세션의 상태를 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "세션 조회 성공",
  "data": {
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "userId": 1,
    "scenarioId": 1,
    "scenarioTitle": "고객 응대 시나리오",
    "status": "COMPLETED",
    "startedAt": "2025-11-02T10:30:00",
    "endedAt": "2025-11-02T10:45:00",
    "audioDurationSeconds": 900
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | SESSION_NOT_FOUND | 세션을 찾을 수 없음 |
| 500 | INTERNAL_SERVER_ERROR | 세션 조회 중 오류 발생 |

---

### 세션 정상 종료

**Endpoint**: `PUT /api/v1/sessions/{sessionId}/complete`

세션을 정상 종료 처리합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "세션이 정상 종료되었습니다.",
  "data": null
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 세션을 찾을 수 없거나 이미 종료됨 |
| 500 | INTERNAL_SERVER_ERROR | 세션 종료 중 오류 발생 |

---

### 세션 실패 처리

**Endpoint**: `PUT /api/v1/sessions/{sessionId}/fail`

세션을 실패 처리합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "세션이 실패 처리되었습니다.",
  "data": null
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | SESSION_NOT_FOUND | 세션을 찾을 수 없음 |
| 500 | INTERNAL_SERVER_ERROR | 세션 실패 처리 중 오류 발생 |

---

## Transcript API

대화 내역 조회 API입니다.

### 세션의 모든 발화 내역 조회

**Endpoint**: `GET /api/v1/transcripts/{sessionId}`

특정 세션의 모든 발화 내역을 시간순으로 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": null,
  "data": [
    {
      "id": 1,
      "sessionId": "550e8400-e29b-41d4-a716-446655440000",
      "speaker": "USER",
      "text": "안녕하세요",
      "timestamp": "2025-11-02T10:30:05",
      "sequenceNumber": 1
    },
    {
      "id": 2,
      "sessionId": "550e8400-e29b-41d4-a716-446655440000",
      "speaker": "AI",
      "text": "안녕하세요. 무엇을 도와드릴까요?",
      "timestamp": "2025-11-02T10:30:08",
      "sequenceNumber": 2
    }
  ]
}
```

---

### 사용자 발화만 조회

**Endpoint**: `GET /api/v1/transcripts/{sessionId}/user`

특정 세션의 사용자 발화만 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": null,
  "data": [
    {
      "id": 1,
      "sessionId": "550e8400-e29b-41d4-a716-446655440000",
      "speaker": "USER",
      "text": "안녕하세요",
      "timestamp": "2025-11-02T10:30:05"
    }
  ]
}
```

---

### AI 발화만 조회

**Endpoint**: `GET /api/v1/transcripts/{sessionId}/ai`

특정 세션의 AI 발화만 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": null,
  "data": [
    {
      "id": 2,
      "sessionId": "550e8400-e29b-41d4-a716-446655440000",
      "speaker": "AI",
      "text": "안녕하세요. 무엇을 도와드릴까요?",
      "timestamp": "2025-11-02T10:30:08"
    }
  ]
}
```

---

## Feedback API

AI 피드백 생성 및 조회 API입니다.

### AI 자동 피드백 생성

**Endpoint**: `POST /api/v1/feedbacks/sessions/{sessionId}`

ChatGPT 4.0이 대화를 분석하여 자동으로 피드백을 생성합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "AI 피드백이 생성되었습니다.",
  "data": {
    "id": 1,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "speechRateScore": 85,
    "fillerWordsScore": 75,
    "politenessScore": 90,
    "clarityScore": 80,
    "totalScore": 82.5,
    "alternativeA": "간결한 스타일의 개선안",
    "alternativeB": "공손한 스타일의 개선안",
    "alternativeC": "따뜻한 스타일의 개선안",
    "chosenAlternative": null,
    "customAlternative": null,
    "createdAt": "2025-11-02T10:50:00"
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 세션 미완료, 이미 피드백 존재 등 |
| 404 | SESSION_NOT_FOUND | 세션을 찾을 수 없음 |
| 500 | AI_API_ERROR | AI API 호출 실패 또는 서버 오류 |

---

### 피드백 조회

**Endpoint**: `GET /api/v1/feedbacks/{sessionId}`

특정 세션의 피드백 상세 정보를 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "피드백 조회 성공",
  "data": {
    "id": 1,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "speechRateScore": 85,
    "fillerWordsScore": 75,
    "politenessScore": 90,
    "clarityScore": 80,
    "totalScore": 82.5,
    "alternativeA": "간결한 스타일의 개선안",
    "alternativeB": "공손한 스타일의 개선안",
    "alternativeC": "따뜻한 스타일의 개선안",
    "chosenAlternative": "A",
    "customAlternative": null
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 404 | FEEDBACK_NOT_FOUND | 피드백을 찾을 수 없음 |

---

### 개선안 선택

**Endpoint**: `PUT /api/v1/feedbacks/{sessionId}/choice`

사용자가 AI가 제시한 개선안 중 하나를 선택하거나 직접 수정합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionId | String(UUID) | 세션 ID |

#### Request Body (AI 개선안 선택)

```json
{
  "chosenAlternative": "A",
  "customAlternative": null
}
```

#### Request Body (사용자 정의)

```json
{
  "chosenAlternative": "CUSTOM",
  "customAlternative": "사용자가 직접 작성한 개선안"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "개선안이 선택되었습니다.",
  "data": {
    "id": 1,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "chosenAlternative": "A",
    "customAlternative": null,
    "totalScore": 82.5
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | CUSTOM 선택 시 내용 누락 등 |
| 404 | FEEDBACK_NOT_FOUND | 피드백을 찾을 수 없음 |

---

### 피드백 히스토리 조회 (페이징)

**Endpoint**: `GET /api/v1/feedbacks/users/{userId}/history`

특정 사용자의 피드백 히스토리를 페이징하여 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | Long | 사용자 ID |

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | Integer | 0 | 페이지 번호 |
| size | Integer | 20 | 페이지 크기 |
| sort | String | createdAt,desc | 정렬 기준 |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "피드백 히스토리 조회 성공",
  "data": {
    "content": [
      {
        "feedbackId": 1,
        "sessionId": "550e8400-e29b-41d4-a716-446655440000",
        "scenarioTitle": "고객 응대 시나리오",
        "totalScore": 82.5,
        "createdAt": "2025-11-02T10:50:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 50,
    "totalPages": 3,
    "last": false
  }
}
```

---

### 전체 피드백 히스토리 조회

**Endpoint**: `GET /api/v1/feedbacks/users/{userId}/history/all`

특정 사용자의 모든 피드백 히스토리를 한 번에 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | Long | 사용자 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "전체 피드백 히스토리 조회 성공",
  "data": [
    {
      "feedbackId": 1,
      "sessionId": "550e8400-e29b-41d4-a716-446655440000",
      "scenarioTitle": "고객 응대 시나리오",
      "totalScore": 82.5,
      "createdAt": "2025-11-02T10:50:00"
    }
  ]
}
```

---

### 피드백 통계 조회

**Endpoint**: `GET /api/v1/feedbacks/users/{userId}/stats`

특정 사용자의 피드백 통계를 조회합니다.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| userId | Long | 사용자 ID |

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "피드백 통계 조회 성공",
  "data": {
    "totalCount": 50,
    "averageScore": 82.5,
    "averageSpeechRateScore": 85.0,
    "averageFillerWordsScore": 75.0,
    "averagePolitenessScore": 90.0,
    "averageClarityScore": 80.0,
    "scoreDistribution": {
      "A": 10,
      "B": 25,
      "C": 15
    },
    "recentFeedbacks": [
      {
        "feedbackId": 1,
        "totalScore": 82.5,
        "createdAt": "2025-11-02T10:50:00"
      }
    ],
    "improvementTrend": [
      {
        "date": "2025-11-01",
        "averageScore": 80.0
      },
      {
        "date": "2025-11-02",
        "averageScore": 82.5
      }
    ]
  }
}
```

---

## Realtime Session API (WebRTC)

실시간 음성 대화를 위한 WebRTC 연결 API입니다.

### Ephemeral Key 발급

**Endpoint**: `POST /api/v1/realtime/session`

WebRTC P2P 연결을 위한 OpenAI Ephemeral Key를 발급받습니다.

#### Request Body

```json
{
  "sessionId": "550e8400-e29b-41d4-a716-446655440000",
  "model": "gpt-4o-realtime-preview-2024-12-17",
  "voice": "alloy",
  "sttModel": "whisper-1",
  "language": "ko"
}
```

#### Response: `200 OK`

```json
{
  "success": true,
  "message": "webRtc 연결을 위한 키 발급에 성공했습니다.",
  "data": {
    "id": "sess_abc123",
    "object": "realtime.session",
    "model": "gpt-4o-realtime-preview-2024-12-17",
    "expires_at": 1730556000,
    "client_secret": {
      "value": "ek_abc123...",
      "expires_at": 1730556000
    }
  }
}
```

#### Error Codes

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 세션이 이미 완료됨 |
| 404 | SESSION_NOT_FOUND | 세션을 찾을 수 없음 |
| 500 | AI_API_ERROR | OpenAI API 호출 실패 |

---

## 공통 에러 코드 (Common Error Codes)

모든 API에서 사용되는 공통 에러 코드입니다.

| HTTP Status | Error Code | 설명 |
|-------------|------------|------|
| 400 | INVALID_INPUT | 입력값 유효성 검증 실패 |
| 400 | PASSWORD_MISMATCH | 비밀번호 불일치 |
| 400 | AGE_RESTRICTION | 나이 제한 (만 14세 미만) |
| 400 | REQUIRED_TERMS_NOT_AGREED | 필수 약관 미동의 |
| 401 | UNAUTHORIZED | 인증되지 않은 사용자 |
| 401 | INVALID_CREDENTIALS | 로그인 실패 (자격 증명 불일치) |
| 401 | ACCESS_TOKEN_INVALID | Access Token 만료/위조 |
| 401 | REFRESH_TOKEN_INVALID | Refresh Token 만료/위조/이미 사용됨 |
| 403 | EMAIL_NOT_VERIFIED | 이메일 미인증 사용자 |
| 403 | SOCIAL_ACCOUNT_PASSWORD_CHANGE | 소셜 로그인 계정 비밀번호 변경 불가 |
| 404 | USER_NOT_FOUND | 사용자를 찾을 수 없음 |
| 404 | SESSION_NOT_FOUND | 세션을 찾을 수 없음 |
| 404 | FEEDBACK_NOT_FOUND | 피드백을 찾을 수 없음 |
| 409 | EMAIL_ALREADY_EXISTS | 이미 사용 중인 이메일 |
| 410 | VERIFICATION_SESSION_EXPIRED | 인증 세션 만료 |
| 500 | INTERNAL_SERVER_ERROR | 서버 내부 오류 |
| 500 | AI_API_ERROR | AI API 호출 실패 |

---

## 인증 흐름 (Authentication Flows)

시스템의 인증 체계와 흐름을 설명합니다.

### 로컬 회원가입 및 로그인 흐름

1. **회원가입**: `POST /api/v1/users/signup`
    - 이메일 인증 토큰 발급
2. **이메일 인증**: `POST /api/v1/verification/email`
    - 6자리 코드 검증
3. **로그인**: `POST /api/v1/users/login`
    - Access Token (Body) + Refresh Token (Cookie) 발급
4. **API 호출**: Header에 `Authorization: Bearer {accessToken}` 포함
5. **토큰 갱신**: `POST /api/v1/users/refresh`
    - 새로운 Access Token + Refresh Token 발급 (RTR)

### 소셜 로그인 흐름

1. **OAuth 인증**: 프론트엔드에서 OAuth Provider로 리다이렉트
2. **콜백 처리**: 백엔드가 OAuth 콜백 처리
    - 기존 회원: 일회용 코드 발급
    - 신규 회원: 소셜 회원가입 대기 토큰 발급
3. **토큰 교환** (기존 회원): `POST /api/v1/users/token/exchange`
    - Access Token + Refresh Token 발급
4. **회원가입 완료** (신규 회원): `POST /api/v1/verification/social/complete`
    - 추가 정보 입력 후 Access Token + Refresh Token 발급

---

## WebSocket 연결 (Realtime Conversation)

실시간 음성 대화를 위한 WebRTC 연결 흐름입니다.

### 연결 흐름

1. **세션 생성**: `POST /api/v1/sessions`
    - sessionId 발급
2. **Ephemeral Key 발급**: `POST /api/v1/realtime/session`
    - OpenAI WebRTC 연결용 임시 키 발급
3. **WebRTC 연결**: 프론트엔드에서 OpenAI Realtime API와 P2P 연결
4. **실시간 대화**: 음성 입출력 및 STT/TTS 처리
5. **세션 종료**: `PUT /api/v1/sessions/{sessionId}/complete`
6. **피드백 생성**: `POST /api/v1/feedbacks/sessions/{sessionId}`

---

## 데이터 모델 (Data Models)

시스템의 주요 엔티티 구조입니다.

### User

| 필드 | 타입 | 설명 |
|------|------|------|
| id | Long | 사용자 ID (PK) |
| email | String | 이메일 (Unique) |
| name | String | 이름 |
| password | String | 비밀번호 (nullable, 소셜 로그인 시) |
| birthDate | LocalDate | 생년월일 |
| provider | Enum | 로그인 제공자 (LOCAL, GOOGLE, KAKAO, NAVER) |
| emailVerified | Boolean | 이메일 인증 여부 |
| createdAt | LocalDateTime | 생성일시 |

### Scenario

| 필드 | 타입 | 설명 |
|------|------|------|
| id | Long | 시나리오 ID (PK) |
| title | String | 제목 |
| description | String | 설명 |
| difficulty | Enum | 난이도 (EASY, MEDIUM, HARD) |
| category | String | 카테고리 |
| isDefault | Boolean | 기본 시나리오 여부 |
| ownerId | Long | 소유자 ID (nullable, 기본 시나리오는 null) |

### DialogueSession

| 필드 | 타입 | 설명 |
|------|------|------|
| sessionId | String(UUID) | 세션 ID (PK) |
| userId | Long | 사용자 ID (FK) |
| scenarioId | Long | 시나리오 ID (FK) |
| status | Enum | 상태 (ONGOING, COMPLETED, FAILED) |
| startedAt | LocalDateTime | 시작일시 |
| endedAt | LocalDateTime | 종료일시 (nullable) |
| audioDurationSeconds | Integer | 음성 지속 시간(초) (nullable) |

### Transcript

| 필드 | 타입 | 설명 |
|------|------|------|
| id | Long | 발화 내역 ID (PK) |
| sessionId | String(UUID) | 세션 ID (FK) |
| speaker | Enum | 화자 (USER, AI) |
| text | String | 발화 내용 |
| timestamp | LocalDateTime | 발화 시간 |
| sequenceNumber | Integer | 순서 번호 |

### Feedback

| 필드 | 타입 | 설명 |
|------|------|------|
| id | Long | 피드백 ID (PK) |
| sessionId | String(UUID) | 세션 ID (FK, Unique) |
| speechRateScore | Integer | 발화 속도 점수 (0-100) |
| fillerWordsScore | Integer | 불필요한 표현 점수 (0-100) |
| politenessScore | Integer | 공손함 점수 (0-100) |
| clarityScore | Integer | 명확성 점수 (0-100) |
| totalScore | Double | 종합 점수 |
| alternativeA | String | 개선안 A |
| alternativeB | String | 개선안 B |
| alternativeC | String | 개선안 C |
| chosenAlternative | Enum | 선택된 개선안 (A, B, C, CUSTOM, nullable) |
| customAlternative | String | 사용자 정의 개선안 (nullable) |
| createdAt | LocalDateTime | 생성일시 |

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|---------------|
| v1.0.0 | 2025.11.02 | 왕택준 | 최초 작성 |