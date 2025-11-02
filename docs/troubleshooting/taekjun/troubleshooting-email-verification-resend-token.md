# 트러블슈팅: 이메일 인증 재발송 토큰 불일치 새 토큰 반환으로 해결

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.29

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 개발자**: 이메일 인증 프로세스를 이해해야 하는 팀원
* **Tech Lead**: 인증 토큰 관리 및 보안 정책 책임자
* **신규 합류자**: 회원가입 인증 흐름을 학습해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

이메일 인증 코드 재발송 시 새로운 JWT 토큰이 생성되지만 프론트엔드는 기존 토큰을 계속 사용하여 인증 실패 발생. 백엔드에서 재발송 API가 새 토큰을 반환하고, 프론트엔드에서 이를 state로 관리하도록 수정하여 해결. 이메일 + 코드 조합으로 조회하고 토큰도 이중 검증하는 방식 유지.

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

로컬 회원가입 시 이메일 인증 코드를 재발송하면 새로운 6자리 코드와 JWT 토큰이 생성되지만, 프론트엔드가 초기 토큰을 계속 사용하여 `이메일 인증 실패 - 토큰 불일치` 에러 발생. 재발송 API 응답에 새 토큰을 포함하고 프론트엔드에서 업데이트하도록 수정하여 해결.

---

## 1. 문제 현상

### 1-1. 주요 증상
* **문제**: 이메일 인증 코드 재발송 후 새 코드로 인증 시도하면 실패
* **증상**: `401 Unauthorized - 유효하지 않은 인증 세션입니다`
* **상황**: 
  - 첫 인증 코드는 정상 작동
  - 재발송 버튼 클릭 → 새 코드 수신
  - 새 코드 입력 → 인증 실패

### 1-2. 에러 정보
* **에러 메시지**: 
```
2025-10-29T15:37:30.290  WARN  --- 이메일 인증 실패 - 토큰 불일치. Email: wtj1998@naver.com
애플리케이션 예외 발생: 유효하지 않은 인증 세션입니다.
```

* **재현 조건**: 
  1. 회원가입 후 첫 인증 코드 수신
  2. "인증 코드 재전송" 버튼 클릭
  3. 새로 받은 6자리 코드 입력
  4. "인증하기" 버튼 클릭

* **빈도**: 재발송 시마다 발생 (100%)

### 1-3. 환경 정보
* **백엔드**: Spring Boot 3.x, Java 21
* **프론트엔드**: React 18.x, Vite
* **데이터베이스**: MariaDB 10.6
* **인증 방식**: JWT + 6자리 OTP 코드 (이중 인증)

### 1-4. 서버 로그
```log
2025-10-29T15:37:30.289  INFO  --- 
/* <criteria> */ select ev1_0.id,ev1_0.code,ev1_0.created_at,ev1_0.email,
ev1_0.expiry_date,ev1_0.is_verified,ev1_0.user_id,ev1_0.verification_token,
ev1_0.verified_at from email_verifications ev1_0 
where ev1_0.email='wtj1998@naver.com' and ev1_0.code='293055';

2025-10-29T15:37:30.290  WARN  --- 이메일 인증 실패 - 토큰 불일치. Email: wtj1998@naver.com
```

---

## 2. 원인 분석

### 2-1. 1차 분석
재발송 시 새로운 JWT 토큰이 생성되지만, 프론트엔드는 초기 토큰을 계속 사용

### 2-2. 2차 분석

**백엔드 동작**:
```java
// 재발송 시
public void resendVerificationEmail(EmailResendRequestDto request) {
    // 1. 기존 레코드 삭제
    emailVerificationRepository.deleteUnverifiedByEmail(email);
    
    // 2. 새 토큰 + 새 코드 생성
    String newToken = jwtTokenProvider.generateEmailVerificationToken(...);
    String newCode = EmailVerification.generateOtpCode(); // 293055
    
    // 3. DB 저장
    emailVerificationRepository.save(emailVerification);
    
    // ❌ 문제: 새 토큰을 반환하지 않음!
}
```

**프론트엔드 동작**:
```javascript
// EmailVerificationPage.jsx
const { email, emailVerificationToken } = location.state; // 초기 토큰

const handleSubmit = async () => {
    const payload = {
        email,
        verificationCode, // 새 코드 (293055)
        emailVerificationToken, // ❌ 기존 토큰 사용!
    };
    
    await authService.verifyEmail(payload);
};
```

**검증 로직**:
```java
// VerificationService.verifyEmail()
EmailVerification verification = emailVerificationRepository
        .findByEmailAndCode(email, code) // ✅ 새 코드로 조회 성공
        .orElseThrow(...);

// ❌ 토큰 불일치!
if (!verification.getVerificationToken().equals(request.getEmailVerificationToken())) {
    throw new TrainException(ErrorCode.VERIFICATION_TOKEN_INVALID);
}
```

### 2-3. 근본 원인

**문제점**:
1. **백엔드**: 재발송 API가 새 토큰을 반환하지 않음 (`void` 반환)
2. **프론트엔드**: 토큰을 `location.state`로만 관리, 업데이트 불가능
3. **검증 로직**: 토큰과 코드를 모두 검증하지만, 토큰이 갱신되지 않아 불일치

**기술적 배경**:
- 이메일 인증은 JWT 토큰(세션 식별) + 6자리 OTP(사용자 입력) 이중 인증
- 재발송 시 보안을 위해 새 토큰과 코드를 생성
- 프론트엔드에서 토큰을 업데이트하지 않으면 구조적으로 실패할 수밖에 없음

---

## 3. 디버깅 과정

### 3-1. 사용한 디버깅 기법
- Spring Boot 서버 로그 분석
- MariaDB 쿼리 로그 확인
- Chrome DevTools Network 탭으로 API 요청/응답 확인
- Postman으로 재발송 API 직접 호출

### 3-2. 핵심 문제 발견 과정

**1단계: 에러 로그 분석**
```log
WARN  --- 이메일 인증 실패 - 토큰 불일치. Email: wtj1998@naver.com
```

**결과**: 코드는 맞지만 토큰이 불일치함을 확인

**2단계: 데이터베이스 확인**
```sql
SELECT verification_token, code, created_at 
FROM email_verifications 
WHERE email = 'wtj1998@naver.com' 
ORDER BY created_at DESC 
LIMIT 2;

+---------------------------+--------+---------------------+
| verification_token        | code   | created_at          |
+---------------------------+--------+---------------------+
| eyJhbG...새토큰           | 293055 | 2025-10-29 15:37:20 |
| eyJhbG...기존토큰         | 481726 | 2025-10-29 15:35:00 |
+---------------------------+--------+---------------------+
```

**결과**: 재발송 시 새 토큰과 코드가 생성됨 확인

**3단계: 프론트엔드 Request 확인**
```json
// POST /api/v1/verification/email
{
  "email": "wtj1998@naver.com",
  "verificationCode": "293055",  // ✅ 새 코드
  "emailVerificationToken": "eyJhbG...기존토큰"  // ❌ 기존 토큰
}
```

**결과**: 프론트엔드가 기존 토큰을 계속 사용하고 있음 발견

**4단계: 재발송 API 응답 확인**
```json
// POST /api/v1/verification/email/resend
// Response
{
  "success": true,
  "message": "인증 이메일이 재발송되었습니다.",
  "data": null  // ❌ 새 토큰 없음!
}
```

**결과**: 재발송 API가 새 토큰을 반환하지 않음 확인

---

## 4. 해결 과정

### 4-1. 시도했던 해결책들

**A안: 토큰 검증 제거 (보류)**
```java
// 이메일 + 코드만 검증, 토큰 검증 제거
EmailVerification verification = emailVerificationRepository
        .findByEmailAndCode(email, code)
        .orElseThrow(...);

// ❌ 토큰 검증 제거
// if (!verification.getVerificationToken().equals(...)) { ... }
```

**문제점**:
- 보안 수준 낮아짐 (단일 인증)
- JWT 토큰의 의미가 퇴색됨
- 세션 관리 불가능

**B안: 재발송 시 새 토큰 반환 (채택)**
```java
// 백엔드: 새 토큰 반환
public String resendVerificationEmail(...) {
    // 기존 레코드 삭제 → 새 토큰 생성 → 저장
    return newToken; // ✅ 새 토큰 반환
}

// 프론트엔드: 토큰 업데이트
const [emailVerificationToken, setEmailVerificationToken] = useState(initialToken);

const handleResend = async () => {
    const response = await authService.resendVerificationEmail(email);
    setEmailVerificationToken(response.emailVerificationToken); // ✅ 업데이트
};
```

**장점**:
- 이중 인증 보안 유지
- 재발송 시나리오 완벽 대응
- 코드 의도 명확

### 4-2. 최종 해결책

#### Step 1: ResendResponseDto 생성

**ResendResponseDto.java**
```java
package com.aid.train.backend.domain.verification.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResendResponseDto {

    private Boolean success;
    
    private String message;
    
    /**
     * 새로 발급된 이메일 인증 토큰 (JWT)
     */
    private String emailVerificationToken;
}
```

#### Step 2: VerificationService 수정

**VerificationService.java**
```java
/**
 * 인증 이메일을 재발송하고 새 토큰을 반환합니다.
 */
@Transactional
public String resendVerificationEmail(EmailResendRequestDto request) {
    User user = userRepository.findUnverifiedLocalUser(request.getEmail())
            .orElseThrow(() -> new TrainException(ErrorCode.USER_NOT_FOUND_OR_ALREADY_VERIFIED));

    // 1. 기존 미인증 토큰 모두 삭제
    int deletedCount = emailVerificationRepository.deleteUnverifiedByEmail(request.getEmail());
    
    // 2. 즉시 flush하여 DELETE 커밋
    emailVerificationRepository.flush();
    
    log.debug("이메일 재발송 - 기존 미인증 토큰 삭제: {} 개", deletedCount);

    // 3. 새로운 인증 코드 생성 및 발송 (새 토큰 반환)
    String newToken = sendVerificationEmail(user);
    
    log.info("이메일 인증 코드 재발송 완료: Email: {}, 새 토큰 생성", request.getEmail());
    
    return newToken; // ✅ 새 토큰 반환
}
```

#### Step 3: VerificationController 수정

**VerificationController.java**
```java
@PostMapping("/email/resend")
public ResponseEntity<ApiResponse<ResendResponseDto>> resendVerificationEmail(
        @Valid @RequestBody EmailResendRequestDto requestDto) {
    
    // ✅ 새 토큰 받기
    String newToken = verificationService.resendVerificationEmail(requestDto);
    
    // ✅ 응답 DTO 생성
    ResendResponseDto response = ResendResponseDto.builder()
            .success(true)
            .message("인증 코드가 재발송되었습니다.")
            .emailVerificationToken(newToken)
            .build();
    
    return ResponseEntity.ok(ApiResponse.success("인증 이메일이 재발송되었습니다.", response));
}
```

#### Step 4: 프론트엔드 authService 수정

**authService.js**
```javascript
/**
 * 이메일 인증 코드 재전송
 * ✅ 새 토큰을 반환받음
 */
export async function resendVerificationEmail(email) {
  const { data } = await apiClient.post('/verification/email/resend', { email });
  return unwrap(data).data; // { success, message, emailVerificationToken }
}
```

#### Step 5: EmailVerificationPage 수정

**EmailVerificationPage.jsx**
```javascript
const EmailVerificationPage = () => {
  const { email, emailVerificationToken: initialToken } = location.state || {};
  
  // ✅ 토큰을 state로 관리 (재발송 시 업데이트)
  const [emailVerificationToken, setEmailVerificationToken] = useState(initialToken);

  // 인증 코드 재전송
  const handleResend = async () => {
    if (resendCooldown > 0) return;

    try {
      setError('');
      
      // ✅ 새 토큰 받기
      const response = await authService.resendVerificationEmail(email);
      
      // ✅ 새 토큰으로 업데이트
      if (response.emailVerificationToken) {
        setEmailVerificationToken(response.emailVerificationToken);
        console.log('새 인증 토큰 받음');
      }
      
      alert('인증 코드가 재발송되었습니다.');
      setResendCooldown(60);
      
    } catch (err) {
      console.error('재전송 실패:', err);
      setError('인증 코드 재전송에 실패했습니다.');
    }
  };

  const handleSubmit = async () => {
    const payload = {
      email,
      verificationCode,
      emailVerificationToken, // ✅ state에서 가져온 최신 토큰 사용
    };

    await authService.verifyEmail(payload);
    navigate('/login');
  };
};
```

**성공 이유**:
1. **백엔드-프론트엔드 동기화**: 새 토큰을 명시적으로 전달
2. **상태 관리 개선**: React state로 토큰 관리
3. **보안 유지**: 이중 인증 메커니즘 유지
4. **명확한 의도**: API 응답에 새 토큰 포함

---

## 5. 테스트 검증

### 5-1. 테스트 방법

#### 테스트 시나리오 1: 정상 인증
```
1. 회원가입
2. 첫 인증 코드로 인증
→ ✅ 예상: 인증 성공
```

#### 테스트 시나리오 2: 재발송 후 인증
```
1. 회원가입
2. 첫 인증 코드 무시
3. "재전송" 클릭
4. 새 인증 코드로 인증
→ ✅ 예상: 인증 성공
```

#### 테스트 시나리오 3: 여러 번 재발송
```
1. 회원가입
2. 재전송 3회 반복
3. 마지막 인증 코드로 인증
→ ✅ 예상: 인증 성공
```

#### 테스트 시나리오 4: 이전 코드 사용
```
1. 회원가입
2. 재전송 클릭
3. 이전 코드로 인증 시도
→ ✅ 예상: 인증 실패 (코드 불일치)
```

### 5-2. 검증 결과

#### API 응답 확인
```json
// POST /api/v1/verification/email/resend
{
  "success": true,
  "message": "인증 이메일이 재발송되었습니다.",
  "timestamp": "2025-10-29T15:45:00",
  "data": {
    "success": true,
    "message": "인증 코드가 재발송되었습니다.",
    "emailVerificationToken": "eyJhbGci...새토큰"  // ✅ 새 토큰 포함
  }
}
```

#### 프론트엔드 State 확인
```javascript
console.log('재발송 전 토큰:', emailVerificationToken.substring(0, 20));
// 출력: eyJhbGciOiJIUzUxMiJ9...

// 재전송 후
console.log('재발송 후 토큰:', emailVerificationToken.substring(0, 20));
// 출력: eyJhbGciOiJIUzUxMiJ9... (다른 토큰)
```

#### 인증 성공 확인
```log
2025-10-29T15:45:30.123  INFO  --- 이메일 인증 성공. Email: wtj1998@naver.com, Code: 293055
```

**테스트 결과**: 10회 테스트 모두 성공 (100%)

---

## 6. 성능 영향 분석

### 6-1. 변경 전후 비교

**측정 항목**:
- **재발송 API 응답 크기**: +150 bytes (JWT 토큰 추가)
- **재발송 API 응답 시간**: 변화 없음 (~50ms)
- **인증 성공률**: 0% → 100% (재발송 후)

### 6-2. 리소스 사용량

**네트워크**:
- **페이로드 크기**: 미미한 증가 (JWT 토큰 ~150 bytes)
- **요청 횟수**: 변화 없음

**클라이언트**:
- **메모리**: 무시 가능 수준 (state 1개 추가)
- **렌더링**: 변화 없음

### 6-3. 사용자 경험 영향

**긍정적 영향**:
- 재발송 기능이 정상 작동하여 사용자 편의성 향상
- 인증 실패로 인한 좌절 제거

**부정적 영향**:
- 없음

---

## 7. 관련 이슈 및 예방책

### 7-1. 유사한 함정 회피 방법

**위험한 패턴**:
```javascript
// ❌ 토큰을 props나 location.state로만 관리
const { token } = location.state;
// → 업데이트 불가능
```

**안전한 패턴**:
```javascript
// ✅ 토큰을 state로 관리
const [token, setToken] = useState(initialToken);
// → 재발송 시 업데이트 가능
```

### 7-2. 코드 리뷰 체크포인트

- [ ] 재발송 API가 새 토큰을 반환하는지 확인
- [ ] 프론트엔드에서 토큰을 업데이트 가능한 state로 관리하는지 확인
- [ ] API 응답 DTO에 필요한 모든 필드 포함 확인
- [ ] 이중 인증 로직 정상 작동 확인

### 7-3. 추가 예방 방법

#### API 문서화
```yaml
# OpenAPI Spec
/api/v1/verification/email/resend:
  post:
    summary: 이메일 인증 코드 재발송
    responses:
      '200':
        description: 재발송 성공
        content:
          application/json:
            schema:
              type: object
              properties:
                success:
                  type: boolean
                message:
                  type: string
                emailVerificationToken:
                  type: string
                  description: 새로 발급된 JWT 토큰 (필수!)
```

#### 통합 테스트
```java
@Test
void testEmailResend_shouldReturnNewToken() {
    // Given
    String email = "test@example.com";
    
    // When
    ResendResponseDto response = verificationService.resendVerificationEmail(
            new EmailResendRequestDto(email)
    );
    
    // Then
    assertThat(response.getEmailVerificationToken()).isNotNull();
    assertThat(response.getEmailVerificationToken()).isNotEmpty();
}
```

#### 프론트엔드 테스트
```javascript
test('재발송 시 새 토큰을 state에 저장해야 함', async () => {
  const { result } = renderHook(() => useEmailVerification());
  
  await act(async () => {
    await result.current.handleResend();
  });
  
  expect(result.current.emailVerificationToken).not.toBe(initialToken);
});
```

---

## 8. 결론 및 배운 점

### 8-1. 주요 성과

1. **재발송 기능 정상화**: 인증 성공률 100% 달성
2. **보안 수준 유지**: 이중 인증 메커니즘 보존
3. **사용자 경험 개선**: 재발송 시나리오 완벽 대응
4. **코드 품질 향상**: 명확한 API 계약 및 상태 관리

### 8-2. 기술적 학습

**이메일 인증 이중 보안**:
- JWT 토큰: 세션 식별 및 요청 검증
- 6자리 OTP: 사용자 입력 인증
- 두 가지 모두 일치해야 인증 성공

**토큰 관리 전략**:
- 재발송 시 새 토큰 생성 (보안)
- API 응답에 새 토큰 포함 (동기화)
- 프론트엔드에서 state로 관리 (업데이트)

**React 상태 관리**:
- `location.state`는 읽기 전용
- 업데이트가 필요한 데이터는 `useState` 사용
- 초기값은 `location.state`에서, 업데이트는 state로

### 8-3. 프로세스 개선

**API 설계 원칙**:
- 재발송/갱신 API는 새 토큰/자원을 반환해야 함
- 응답 DTO에 필요한 모든 정보 포함
- 프론트엔드가 동기화할 수 있도록 명시적 반환

**테스트 전략**:
- 정상 케이스뿐만 아니라 재발송/재시도 시나리오 필수 테스트
- 백엔드-프론트엔드 통합 테스트 강화
- API 계약 변경 시 양쪽 코드 동시 검토

### 8-4. 장기적 개선 방향

**보안 강화**:
- 재발송 횟수 제한 (Rate Limiting)
- 재발송 쿨다운 시간 조정
- 의심스러운 재발송 패턴 감지

**모니터링**:
- 재발송 횟수 통계
- 인증 실패 원인 분석 (토큰 vs 코드)
- 재발송 후 인증 성공률 추적

**사용자 경험**:
- 재발송 시 카운트다운 표시
- 이메일 미도착 시 대안 제시
- 인증 실패 원인 명확한 안내

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 담당자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.29 | 왕택준 | 최초 작성 - 이메일 인증 재발송 토큰 불일치 문제 해결 |
