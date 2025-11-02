# Dialogym 보안 정책

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.02

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 보안 코딩 가이드라인을 준수하고 보안 기능을 구현하는 담당자
* **보안 책임자**: 시스템 보안 정책을 수립하고 보안 사고에 대응하는 책임자
* **운영팀**: 보안 모니터링과 정기 점검을 수행하는 운영 담당자
* **신규 합류자**: Dialogym Backend 시스템의 보안 정책과 규칙을 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym Backend 시스템의 보안 정책과 구현 지침을 정의합니다.
인증은 JWT 기반으로 구현하며, Access Token(1시간)과 Refresh Token(14일)을 활용한 RTR 방식을 사용합니다.
모든 민감 데이터는 BCrypt 또는 SHA-256으로 암호화하며, HTTPS/TLS 통신을 필수로 합니다.
OWASP Top 10 취약점에 대응하고, 정기적인 보안 점검과 모니터링을 통해 시스템 안전성을 확보합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [보안 원칙](#보안-원칙)
3. [인증 보안](#인증-보안)
4. [데이터 보안](#데이터-보안)
5. [통신 보안](#통신-보안)
6. [API 보안](#api-보안)
7. [세션 보안](#세션-보안)
8. [개인정보 보호](#개인정보-보호)
9. [취약점 대응](#취약점-대응)
10. [보안 모니터링](#보안-모니터링)
11. [사고 대응](#사고-대응)
12. [규정 준수](#규정-준수)
13. [보안 교육 및 점검](#보안-교육-및-점검)
14. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 Dialogym Backend 시스템의 보안 정책과 구현 지침을 정의하기 위해 작성되었습니다.

프로젝트가 성장하면서 보안 요구사항이 복잡해지고, 다양한 보안 위협에 노출될 가능성이 증가합니다.
이를 방지하기 위해 인증/인가, 데이터 암호화, 통신 보안, API 보안 등 전반적인 보안 정책을 명확히 정의하고 팀 전체가 준수할 수 있도록 합니다.

본 문서는 Dialogym Backend API 서버, 데이터베이스(MariaDB), 외부 API 연동(OpenAI, OAuth2 Providers), 사용자 데이터 및 개인정보 처리 전반에 적용됩니다.

---

## 보안 원칙

Dialogym Backend 시스템은 다음 5가지 핵심 보안 원칙을 기반으로 설계되고 운영됩니다.

### 최소 권한 원칙 (Principle of Least Privilege)

사용자와 시스템 구성 요소는 필요한 최소한의 권한만 부여받습니다.
데이터베이스 계정은 DDL 권한 없이 SELECT, INSERT, UPDATE, DELETE 권한만 부여하며, API 엔드포인트는 역할 기반 접근 제어를 통해 권한을 제한합니다.

### 심층 방어 (Defense in Depth)

단일 보안 메커니즘에 의존하지 않고 다층 보안 구조를 적용합니다.
인증은 JWT와 Refresh Token Rotation을 결합하고, 데이터 보안은 암호화와 접근 제어를 동시에 적용하며, 통신 보안은 HTTPS와 CORS 정책을 함께 사용합니다.

### 기본 보안 (Secure by Default)

시스템은 안전한 기본 설정으로 구성됩니다.
Cookie는 HttpOnly와 Secure 속성을 기본으로 설정하고, CSRF는 SameSite 속성으로 방어하며, 에러 응답은 최소한의 정보만 노출합니다.

### 투명성 (Transparency)

보안 정책과 구현 방식은 명확히 문서화되고 팀 전체에 공유됩니다.
보안 사고 발생 시 신속한 대응을 위해 절차를 명시하고, 정기적인 보안 교육을 통해 인식을 제고합니다.

### 지속적 개선 (Continuous Improvement)

보안은 일회성 작업이 아니라 지속적인 프로세스입니다.
정기적인 취약점 스캔과 보안 점검을 수행하고, 최신 보안 위협에 대응하기 위해 정책을 업데이트합니다.

---

## 인증 보안

### 비밀번호 정책

#### 비밀번호 요구사항

Dialogym 시스템은 강력한 비밀번호 정책을 적용하여 무단 접근을 방지합니다.

```
최소 길이: 8자 이상
최대 길이: 100자 이하
복잡도 요구사항:
  - 영문 대문자 또는 소문자 포함
  - 숫자 포함
  - 특수문자 포함 권장
```

**구현 예시**:
```java
@Pattern(
    regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,100}$",
    message = "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다."
)
private String password;
```

#### 비밀번호 암호화

모든 비밀번호는 BCrypt 알고리즘으로 암호화하여 저장합니다.
BCrypt는 단방향 해시 함수로 복호화가 불가능하며, Salt를 자동으로 생성하여 레인보우 테이블 공격을 방지합니다.

```
알고리즘: BCrypt
Salt Rounds: 10 (기본값)
구현: Spring Security BCryptPasswordEncoder
```

#### 비밀번호 변경 정책

비밀번호 변경 시 현재 비밀번호 확인이 필수이며, 새 비밀번호와 확인 비밀번호의 일치 여부를 검증합니다.
소셜 로그인 계정은 비밀번호를 사용하지 않으므로 비밀번호 변경이 불가능합니다.

#### 비밀번호 저장 금지 사항

비밀번호는 어떠한 경우에도 평문으로 저장하거나 로그에 출력하지 않습니다.
에러 메시지에 비밀번호가 포함되지 않도록 주의하며, 디버깅 시에도 비밀번호 값을 마스킹합니다.

### JWT 토큰 보안

#### Access Token

Access Token은 사용자 인증 정보를 담은 짧은 수명의 토큰입니다.

```yaml
만료 시간: 1시간 (3600초)
전송 방식: HTTP Authorization Header
저장 위치: 클라이언트 메모리 (권장)
알고리즘: HS256 (HMAC-SHA256)
```

**보안 요구사항**:
- 최소 256비트 시크릿 키 사용
- 환경 변수로 시크릿 키 관리
- 코드에 하드코딩 금지

**JWT Payload**:
```json
{
  "sub": "user@example.com",
  "userId": 1,
  "iat": 1730556000,
  "exp": 1730559600
}
```

#### Refresh Token

Refresh Token은 Access Token을 갱신하기 위한 장기 수명 토큰입니다.

```yaml
만료 시간: 14일 (1,209,600초)
전송 방식: HttpOnly Cookie
저장 위치: 서버 측 쿠키
알고리즘: UUID v4 (랜덤)
```

**보안 특징**:
- HttpOnly: JavaScript 접근 차단하여 XSS 공격 방지
- Secure: HTTPS 전용 전송 (프로덕션 환경)
- SameSite: CSRF 공격 방지
- 데이터베이스에 해시 저장하여 탈취 방지

#### Refresh Token Rotation (RTR)

토큰 갱신 시마다 새로운 Refresh Token을 발급하여 재사용 공격을 방지합니다.

```
토큰 갱신 프로세스:
1. 기존 Refresh Token 검증
2. 기존 Refresh Token 무효화 (DB에서 삭제)
3. 새로운 Access Token 발급
4. 새로운 Refresh Token 발급
5. 새 Refresh Token을 Cookie로 전송
```

이미 사용된 Refresh Token이 재사용될 경우 즉시 거부하며, 의심스러운 활동 감지 시 해당 사용자의 모든 토큰을 무효화합니다.

#### 토큰 검증 프로세스

모든 API 요청에 대해 다음 단계로 토큰을 검증합니다.

```java
1. Authorization Header 존재 확인
2. "Bearer " 접두사 확인
3. JWT 서명 검증
4. 만료 시간 확인
5. Payload 파싱 및 사용자 정보 추출
6. SecurityContext에 인증 정보 설정
```

### OAuth2 소셜 로그인 보안

#### 지원 Provider

Dialogym은 Google, Kakao, Naver OAuth2를 지원합니다.
각 Provider는 표준 OAuth2 Authorization Code Flow를 사용하며, Client Secret은 환경 변수로 안전하게 관리됩니다.

#### OAuth2 보안 설정

```yaml
redirect-uri: ${OAUTH_REDIRECT_BASE_URL}/login/oauth2/code/{provider}
authorization-grant-type: authorization_code
client-authentication-method: client_secret_post
```

**보안 요구사항**:
- Client Secret 환경 변수로 관리
- Redirect URI 화이트리스트 등록
- State 파라미터로 CSRF 방지
- HTTPS 전용 (프로덕션)

#### 일회용 코드 (One-Time Code)

소셜 로그인 완료 후 프론트엔드에 안전하게 토큰을 전달하기 위해 일회용 코드를 사용합니다.

```
목적: 소셜 로그인 후 프론트엔드에 안전하게 토큰 전달
생성: UUID v4
만료: 60초
저장: 데이터베이스 (일회용)
사용 후: 즉시 삭제
```

### 이메일 인증 보안

#### 인증 코드

이메일 인증 시 6자리 숫자 코드를 발송하며, SecureRandom으로 생성하여 예측 불가능하게 합니다.

```
형식: 6자리 숫자
생성: SecureRandom
만료: 10분
재발송: 최대 5회
저장: 데이터베이스 (해시)
```

#### 인증 토큰

인증 세션을 식별하기 위한 토큰으로 UUID v4 형식을 사용합니다.

```
형식: UUID v4
만료: 1시간
용도: 인증 세션 식별
일회용: 인증 완료 후 삭제
```

### Rate Limiting

#### 토큰 갱신 제한

토큰 갱신 엔드포인트에 Rate Limiting을 적용하여 무차별 대입 공격을 방지합니다.

```yaml
엔드포인트: POST /api/v1/users/refresh
제한: 사용자당 1분에 5회
구현: Bucket4j + Caffeine Cache
```

**초과 시 응답**:
```json
{
  "success": false,
  "message": "요청 횟수 제한을 초과했습니다. 잠시 후 다시 시도해주세요.",
  "errorCode": "RATE_LIMIT_EXCEEDED"
}
```

#### 로그인 시도 제한

향후 로그인 시도 제한을 추가하여 계정 보호를 강화할 예정입니다.

```
제한: IP당 5분에 10회
초과 시: 5분간 차단
구현: 향후 추가 예정
```

---

## 데이터 보안

### 민감 데이터 암호화

#### 암호화 대상

| 데이터 | 암호화 방식 | 저장 위치 |
|--------|-------------|-----------|
| 비밀번호 | BCrypt (단방향) | User.password |
| Refresh Token | SHA-256 (단방향) | RefreshToken.token |
| 이메일 인증 코드 | SHA-256 (단방향) | EmailVerification.code |
| JWT Secret | 환경 변수 | 서버 환경 |
| OAuth2 Client Secret | 환경 변수 | 서버 환경 |
| OpenAI API Key | 환경 변수 | 서버 환경 |

#### 평문 저장 데이터

이메일, 이름, 생년월일은 검색과 표시를 위해 평문으로 저장됩니다.
대신 데이터베이스 접근 제어, 백업 데이터 암호화, 전송 시 HTTPS 사용으로 보안을 확보합니다.

### 데이터베이스 보안

#### 접근 제어

데이터베이스는 애플리케이션 전용 계정으로만 접근하며, 최소 권한 원칙을 적용합니다.

```yaml
사용자: 애플리케이션 전용 계정
권한: SELECT, INSERT, UPDATE, DELETE (최소 권한)
금지: DROP, CREATE, ALTER (DDL 권한)
네트워크: VPC 내부 통신만 허용
```

#### Connection Pool 보안

HikariCP를 사용하여 안전한 커넥션 풀을 구성하며, 연결 누수 감지 기능을 활성화합니다.

```yaml
hikari:
  maximum-pool-size: 10
  minimum-idle: 5
  connection-timeout: 30000
  leak-detection-threshold: 60000  # 연결 누수 감지
```

#### SQL Injection 방지

모든 데이터베이스 쿼리는 JPA Parameterized Query 또는 QueryDSL을 사용하여 SQL Injection을 방지합니다.
Native Query 사용 시에도 반드시 파라미터 바인딩을 사용해야 합니다.

**안전한 예시**:
```java
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);
```

**위험한 예시 (금지)**:
```java
// String concatenation - SQL Injection 취약
String query = "SELECT * FROM users WHERE email = '" + email + "'";
```

### 데이터 백업 및 복구

#### 백업 정책

데이터베이스는 매일 자동 백업되며, AWS S3에 암호화하여 저장합니다.

```
주기: 매일 새벽 2시 (자동)
보관 기간: 30일
저장 위치: AWS S3 (암호화)
복구 테스트: 월 1회
```

#### 백업 데이터 보안

백업 파일은 AES-256으로 암호화하고, IAM 정책으로 접근 권한을 제한하며, 전송 시 TLS를 사용합니다.

### 데이터 삭제 정책

#### Soft Delete

User, DialogueSession, Feedback은 Soft Delete 방식으로 삭제하며, 30일 후 자동으로 완전 삭제됩니다.

```
대상: User, DialogueSession, Feedback
방식: deletedAt 필드 설정
보관 기간: 30일
완전 삭제: 30일 후 자동 삭제
```

#### Hard Delete

임시 데이터는 만료 즉시 물리적으로 삭제합니다.

```
대상: 임시 데이터 (EmailVerification, RefreshToken)
방식: 물리적 삭제
시점: 만료 즉시 또는 스케줄러
```

---

## 통신 보안

### HTTPS/TLS

#### 프로덕션 환경

프로덕션 환경에서는 HTTPS를 필수로 사용하며, HTTP 요청은 HTTPS로 강제 리다이렉트합니다.

```yaml
프로토콜: HTTPS (TLS 1.2 이상)
인증서: Let's Encrypt 또는 AWS Certificate Manager
강제 리다이렉트: HTTP → HTTPS
HSTS: Strict-Transport-Security 헤더 설정
```

**HSTS 헤더**:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

#### 로컬 개발 환경

로컬 개발 환경에서는 개발 편의성을 위해 HTTP를 사용하지만, 프로덕션 배포 전 HTTPS 설정을 반드시 확인해야 합니다.

### CORS 정책

#### CORS 설정

Cross-Origin 요청을 안전하게 처리하기 위해 명시적인 CORS 정책을 설정합니다.

```yaml
cors:
  allowed-origins: ${CORS_ALLOWED_ORIGINS}
  allowed-methods: GET,POST,PUT,PATCH,DELETE,OPTIONS
  allowed-headers: "*"
  allow-credentials: true
  max-age: 3600
```

#### 환경별 설정

```yaml
# 로컬
CORS_ALLOWED_ORIGINS=http://localhost:5050

# 프로덕션
CORS_ALLOWED_ORIGINS=https://dialogym.shop,https://www.dialogym.shop
```

**보안 원칙**:
- 와일드카드(`*`) 사용 금지
- 신뢰할 수 있는 도메인만 허용
- `allow-credentials: true` 시 명시적 도메인 지정 필수

### Cookie 보안

#### Cookie 속성

Refresh Token을 안전하게 전송하기 위해 보안 속성을 설정합니다.

```yaml
cookie:
  http-only: true              # JavaScript 접근 차단
  secure: true                 # HTTPS 전용 (프로덕션)
  same-site: None              # Cross-site 요청 허용 (프로덕션)
  domain: .dialogym.shop       # 서브도메인 포함
  path: /                      # 전체 경로
  max-age: 1209600             # 14일
```

#### 환경별 Cookie 설정

| 환경 | Secure | SameSite | Domain |
|------|--------|----------|--------|
| Local | false | Lax | localhost |
| Dev | true | Lax | localhost |
| Prod | true | None | .dialogym.shop |

### API 요청 보안

#### 요청 헤더 검증

모든 API 요청은 적절한 헤더를 포함해야 합니다.

```
Content-Type: application/json
Authorization: Bearer {token}
Origin: 허용된 도메인
```

#### 응답 헤더 보안

보안 관련 응답 헤더를 설정하여 다양한 공격을 방어합니다.

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

---

## API 보안

### 입력 검증

#### Bean Validation

모든 사용자 입력은 Bean Validation을 통해 검증합니다.

```java
@NotBlank(message = "이메일은 필수입니다.")
@Email(message = "올바른 이메일 형식이 아닙니다.")
private String email;

@NotBlank(message = "비밀번호는 필수입니다.")
@Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,100}$")
private String password;

@NotNull(message = "생년월일은 필수입니다.")
@Past(message = "생년월일은 과거 날짜여야 합니다.")
private LocalDate birthDate;
```

#### 커스텀 검증

비즈니스 로직에 따른 추가 검증을 수행합니다.

```java
// 나이 제한 검증
if (Period.between(birthDate, LocalDate.now()).getYears() < 14) {
    throw new TrainException(ErrorCode.AGE_RESTRICTION);
}

// 비밀번호 일치 검증
if (!password.equals(passwordConfirm)) {
    throw new TrainException(ErrorCode.PASSWORD_MISMATCH);
}
```

#### XSS 방지

HTML 태그를 이스케이프하고, 사용자 입력 출력 시 인코딩하며, Content-Security-Policy 헤더를 설정하여 XSS 공격을 방어합니다.

### 인가 (Authorization)

#### URL 기반 접근 제어

Spring Security를 사용하여 URL 기반 접근 제어를 구현합니다.

```java
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/v1/users/signup", "/api/v1/users/login").permitAll()
    .requestMatchers("/api/v1/users/profile").authenticated()
    .anyRequest().authenticated()
)
```

#### 리소스 소유권 검증

사용자는 본인 소유의 리소스만 접근할 수 있습니다.

```java
// 본인의 프로필만 수정 가능
public void updateProfile(Long userId, ProfileUpdateRequestDto dto) {
    if (!userId.equals(currentUser.getId())) {
        throw new TrainException(ErrorCode.FORBIDDEN);
    }
    // ...
}
```

### CSRF 방어

#### CSRF 비활성화

Stateless API이며 JWT 기반 인증을 사용하므로 CSRF 토큰을 비활성화합니다.

```java
http.csrf(AbstractHttpConfigurer::disable)
```

**이유**:
- Stateless API (JWT 기반)
- Cookie에 토큰 저장하지 않음 (Refresh Token 제외)
- SameSite Cookie 속성으로 CSRF 방어

#### OAuth2 State 파라미터

OAuth2 인증 시 State 파라미터가 자동으로 생성되어 CSRF 공격을 방지합니다.

### 에러 응답 보안

#### 에러 정보 최소화

에러 응답은 최소한의 정보만 포함하여 시스템 내부 정보 노출을 방지합니다.

```json
// 안전한 응답
{
  "success": false,
  "message": "로그인에 실패했습니다.",
  "errorCode": "INVALID_CREDENTIALS"
}

// 위험한 응답 (금지)
{
  "error": "User not found: user@example.com",
  "stackTrace": "..."
}
```

#### 에러 응답 원칙

- 스택 트레이스 노출 금지
- 시스템 내부 정보 노출 금지
- 사용자 존재 여부 추측 방지
- 일관된 에러 메시지 사용

---

## 세션 보안

### 대화 세션 보안

#### 세션 ID

대화 세션은 UUID v4 형식의 고유 ID로 식별됩니다.

```
형식: UUID v4
생성: SecureRandom
저장: 데이터베이스
접근: 세션 소유자만 조회 가능
```

#### 세션 상태 관리

세션 상태는 ONGOING, COMPLETED, FAILED로 관리되며, 완료된 세션은 수정할 수 없습니다.

```java
public enum SessionStatus {
    ONGOING,    // 진행 중
    COMPLETED,  // 정상 종료
    FAILED      // 실패
}
```

**보안 규칙**:
- 완료된 세션은 수정 불가
- 세션 소유자만 종료 가능
- 비정상 종료 시 자동 FAILED 처리

### WebSocket 보안

#### Ephemeral Key

OpenAI Realtime API 인증을 위한 임시 키입니다.

```
목적: OpenAI Realtime API 인증
형식: OpenAI 발급 임시 키
만료: 60초
용도: 일회용 WebRTC 연결
```

#### WebSocket 연결 제한

사용자당 동시 연결 수를 제한하고 타임아웃을 설정하여 리소스 남용을 방지합니다.

```
동시 연결: 사용자당 1개
타임아웃: 60초
재연결: 자동 재시도 (최대 3회)
```

### 발화 내역 보안

#### Transcript 저장

사용자와 AI의 발화 내역은 평문으로 저장되지만, 세션 소유자만 조회할 수 있습니다.

```
저장 대상: USER, AI 발화
암호화: 평문 (검색 필요)
접근 제어: 세션 소유자만 조회
보관 기간: 영구 (사용자 삭제 시 함께 삭제)
```

#### 민감 정보 필터링

향후 개인정보 자동 감지 및 마스킹, 욕설/비속어 필터링 기능을 추가할 예정입니다.

---

## 개인정보 보호

### 수집 정보

#### 필수 정보

회원가입 시 다음 정보를 필수로 수집합니다.

- 이메일 (로그인 ID)
- 이름
- 생년월일 (만 14세 이상 확인)
- 비밀번호 (로컬 계정)

#### 선택 정보

사용자는 마케팅 수신 동의 여부를 선택할 수 있습니다.

#### 자동 수집 정보

서비스 운영을 위해 다음 정보를 자동으로 수집합니다.

- 접속 IP 주소 (로그)
- 접속 시간
- 사용 기록 (세션, 피드백)

### 개인정보 처리 방침

#### 수집 목적

개인정보는 다음 목적으로만 사용됩니다.

- 회원 가입 및 관리
- 서비스 제공 (AI 대화 훈련)
- 학습 이력 관리
- 고객 지원

#### 보유 기간

```
회원 정보: 회원 탈퇴 시까지
학습 이력: 회원 탈퇴 후 30일
로그 데이터: 90일
백업 데이터: 30일
```

#### 제3자 제공

```
OpenAI: 대화 내용 (AI 분석 목적)
  - 전송 데이터: 발화 내역, 시나리오 정보
  - 보관 기간: OpenAI 정책 준수
  - 개인 식별 정보: 제외

OAuth2 Providers: 최소 정보
  - Google: 이메일, 이름
  - Kakao: 이메일, 닉네임
  - Naver: 이메일, 이름
```

### 사용자 권리

#### 열람 권리

사용자는 본인의 정보와 학습 이력을 조회할 수 있습니다.

- 본인 정보 조회: `GET /api/v1/users/profile`
- 학습 이력 조회: `GET /api/v1/feedbacks/users/{userId}/history`

#### 정정 권리

사용자는 본인의 정보를 수정할 수 있습니다.

- 프로필 수정: `PUT /api/v1/users/profile`
- 비밀번호 변경: `PUT /api/v1/users/password`

#### 삭제 권리 (회원 탈퇴)

회원 탈퇴 기능은 향후 추가될 예정입니다.

```
구현: 향후 추가 예정
절차:
  1. 본인 확인 (비밀번호 입력)
  2. 탈퇴 사유 선택 (선택)
  3. 개인정보 삭제 안내
  4. 최종 확인
  5. 계정 비활성화 (Soft Delete)
  6. 30일 후 완전 삭제 (Hard Delete)
```

### 아동 보호

#### 연령 제한

Dialogym 서비스는 만 14세 미만 사용자의 회원가입을 제한합니다.

```
최소 연령: 만 14세
확인 방법: 생년월일 입력
거부 시: 회원가입 불가
```

**구현**:
```java
int age = Period.between(birthDate, LocalDate.now()).getYears();
if (age < 14) {
    throw new TrainException(ErrorCode.AGE_RESTRICTION);
}
```

#### 법정대리인 동의

만 14세 미만은 회원가입이 불가능하며, 만 14세 이상은 본인 동의로 가입할 수 있습니다.

---

## 취약점 대응

### OWASP Top 10 대응

Dialogym Backend는 OWASP Top 10에 명시된 주요 웹 애플리케이션 취약점에 대응합니다.

#### A01: Broken Access Control

**대응**:
- JWT 기반 인증/인가
- URL 기반 접근 제어
- 리소스 소유권 검증

#### A02: Cryptographic Failures

**대응**:
- BCrypt 비밀번호 암호화
- HTTPS/TLS 통신
- 민감 데이터 암호화

#### A03: Injection

**대응**:
- JPA Parameterized Query
- Bean Validation
- 입력값 검증 및 이스케이프

#### A04: Insecure Design

**대응**:
- 보안 설계 문서화
- 위협 모델링
- 보안 코드 리뷰

#### A05: Security Misconfiguration

**대응**:
- 안전한 기본 설정
- 불필요한 기능 비활성화
- 정기적인 보안 설정 검토

#### A06: Vulnerable Components

**대응**:
- 의존성 정기 업데이트
- 취약점 스캔 (Dependabot)
- 보안 패치 신속 적용

#### A07: Authentication Failures

**대응**:
- 강력한 비밀번호 정책
- Rate Limiting
- Refresh Token Rotation

#### A08: Software and Data Integrity Failures

**대응**:
- 코드 서명
- CI/CD 파이프라인 보안
- 무결성 검증

#### A09: Security Logging Failures

**대응**:
- 보안 이벤트 로깅
- 로그 모니터링
- 이상 탐지

#### A10: Server-Side Request Forgery (SSRF)

**대응**:
- 외부 URL 검증
- 화이트리스트 기반 접근
- 네트워크 격리

### 보안 취약점 스캔

#### 정적 분석

```
도구: SonarQube, SpotBugs
주기: 매 커밋
대상: 소스 코드
```

#### 의존성 스캔

```
도구: Dependabot, OWASP Dependency-Check
주기: 매일
대상: 라이브러리 및 프레임워크
```

#### 동적 분석

```
도구: OWASP ZAP, Burp Suite
주기: 월 1회
대상: 실행 중인 애플리케이션
```

### 보안 패치 정책

#### 긴급 패치

Critical 취약점은 24시간 이내에 패치합니다.

```
대상: Critical 취약점
대응 시간: 24시간 이내
절차: 즉시 패치 → 테스트 → 배포
```

#### 일반 패치

High/Medium 취약점은 7일 이내에 패치합니다.

```
대상: High/Medium 취약점
대응 시간: 7일 이내
절차: 패치 계획 → 테스트 → 배포
```

#### 저위험 패치

Low 취약점은 30일 이내에 패치합니다.

```
대상: Low 취약점
대응 시간: 30일 이내
절차: 정기 업데이트에 포함
```

---

## 보안 모니터링

### 로깅 정책

#### 보안 이벤트 로깅

다음 보안 이벤트를 로그로 기록합니다.

```
로그 대상:
  - 로그인 성공/실패
  - 토큰 발급/갱신/무효화
  - 권한 없는 접근 시도
  - 비정상적인 API 호출
  - 시스템 오류
```

**로그 포맷**:
```
[2025-11-02 10:30:00] [SECURITY] [LOGIN_SUCCESS] userId=1, ip=192.168.1.100
[2025-11-02 10:31:00] [SECURITY] [LOGIN_FAILED] email=user@example.com, ip=192.168.1.100
[2025-11-02 10:32:00] [SECURITY] [UNAUTHORIZED_ACCESS] userId=1, endpoint=/api/v1/admin
```

#### 로그 보안

로그는 민감 정보를 마스킹하고, 접근 권한을 제한하며, 무결성을 보장합니다.

- 민감 정보 마스킹 (비밀번호, 토큰)
- 로그 접근 권한 제한
- 로그 무결성 보장
- 로그 보관 기간: 90일

#### 로그 금지 사항

다음 정보는 로그에 기록하지 않습니다.

```
금지:
  - 비밀번호 (평문/암호화 모두)
  - JWT 토큰 전체 (일부만 로깅)
  - 개인정보 (이메일, 이름 등)
  - API Key, Secret
```

### 이상 탐지

#### 탐지 대상

다음과 같은 비정상적인 활동을 탐지합니다.

```
- 짧은 시간 내 다수 로그인 실패
- 비정상적인 API 호출 패턴
- 대량의 데이터 조회
- 권한 없는 리소스 접근 시도
- 토큰 재사용 시도
```

#### 알림 설정

심각도에 따라 알림 방식과 시간을 다르게 설정합니다.

```
Critical: 즉시 알림 (SMS, Email)
High: 5분 이내 알림 (Email)
Medium: 1시간 이내 알림 (Email)
Low: 일일 리포트
```

### 모니터링 지표

#### 보안 메트릭

다음 지표를 모니터링합니다.

```
- 로그인 실패율
- 토큰 갱신 실패율
- 401/403 에러 비율
- Rate Limit 초과 횟수
- 비정상 종료 세션 수
```

#### 대시보드

Grafana를 사용하여 실시간 보안 대시보드를 구성합니다.

```
도구: Grafana
데이터 소스: Prometheus, CloudWatch
업데이트: 실시간
접근: 보안팀, 운영팀
```

---

## 사고 대응

### 보안 사고 분류

#### 심각도 분류

| 레벨 | 설명 | 예시 |
|------|------|------|
| **Critical** | 즉각적인 대응 필요 | 데이터 유출, 시스템 침해 |
| **High** | 긴급 대응 필요 | 인증 우회, 권한 상승 |
| **Medium** | 신속 대응 필요 | XSS, CSRF 취약점 |
| **Low** | 계획된 대응 | 정보 노출, 설정 오류 |

### 사고 대응 절차

#### 탐지 및 분석

```
1. 보안 이벤트 탐지
2. 사고 확인 및 분류
3. 영향 범위 분석
4. 근본 원인 파악
```

#### 격리 및 차단

```
1. 공격 차단 (IP 차단, 계정 정지)
2. 영향받은 시스템 격리
3. 추가 피해 방지
```

#### 복구

```
1. 취약점 패치
2. 시스템 복구
3. 데이터 무결성 확인
4. 서비스 재개
```

#### 사후 조치

```
1. 사고 보고서 작성
2. 재발 방지 대책 수립
3. 보안 정책 업데이트
4. 관련자 교육
```

### 데이터 유출 대응

#### 즉시 조치

```
1. 유출 경로 차단
2. 영향받은 사용자 식별
3. 관련 기관 신고 (필요 시)
4. 사용자 통지 준비
```

#### 사용자 통지

개인정보 유출 시 영향받은 사용자에게 다음 내용을 통지합니다.

```
대상: 개인정보 유출 영향을 받은 사용자
방법: 이메일, 앱 푸시, 공지사항
내용:
  - 유출된 정보 종류
  - 유출 시점 및 경위
  - 회사의 대응 조치
  - 사용자 권장 조치 (비밀번호 변경 등)
```

### 비상 연락망

보안 사고 발생 시 즉시 연락할 수 있도록 비상 연락망을 유지합니다.

```
보안 책임자: [이름] [전화번호] [이메일]
개발팀 리드: [이름] [전화번호] [이메일]
운영팀 리드: [이름] [전화번호] [이메일]
법무팀: [이름] [전화번호] [이메일]
```

---

## 규정 준수

### 개인정보보호법 (한국)

#### 준수 사항

Dialogym은 한국 개인정보보호법을 준수합니다.

- 개인정보 수집 시 동의 획득
- 개인정보 처리방침 공개
- 개인정보 안전성 확보 조치
- 개인정보 유출 시 통지 의무

#### 안전성 확보 조치

```
기술적 조치:
  - 접근 통제
  - 암호화
  - 접속 기록 보관
  - 악성 프로그램 방지

관리적 조치:
  - 개인정보 보호책임자 지정
  - 정기적인 보안 교육
  - 접근 권한 관리
```

### 정보통신망법 (한국)

#### 준수 사항

- 이용자 정보 보호
- 개인정보 유출 통지
- 본인 확인 조치
- 아동 보호

### GDPR (유럽, 해당 시)

#### 준수 사항

유럽 사용자가 있을 경우 GDPR을 준수합니다.

- 데이터 처리의 합법성
- 데이터 최소화
- 정확성 및 최신성
- 저장 제한
- 무결성 및 기밀성
- 책임성

#### 사용자 권리

- 정보 접근권
- 정정권
- 삭제권 (잊힐 권리)
- 처리 제한권
- 데이터 이동권

---

## 보안 교육 및 점검

### 개발자 교육

#### 필수 교육

개발자는 분기별로 보안 교육을 받아야 합니다.

```
주기: 분기별 1회
내용:
  - 보안 코딩 가이드라인
  - OWASP Top 10
  - 보안 취약점 사례
  - 사고 대응 절차
```

#### 보안 코딩 가이드라인

- 입력값 검증
- 출력값 인코딩
- 인증/인가 구현
- 암호화 사용
- 에러 처리
- 로깅

### 보안 인식 제고

#### 전 직원 교육

전 직원은 연 2회 보안 교육을 받아야 합니다.

```
주기: 연 2회
내용:
  - 피싱 메일 대응
  - 비밀번호 관리
  - 소셜 엔지니어링
  - 보안 사고 신고
```

### 정기 점검

#### 일일 점검

```
- 로그 모니터링
- 이상 트래픽 확인
- 시스템 리소스 확인
```

#### 주간 점검

```
- 보안 이벤트 리뷰
- 취약점 스캔 결과 확인
- 패치 현황 확인
```

#### 월간 점검

```
- 접근 권한 검토
- 보안 정책 준수 확인
- 백업 복구 테스트
```

#### 분기별 점검

```
- 보안 감사
- 침투 테스트
- 보안 정책 업데이트
```

### 보안 체크리스트

#### 인증/인가

- JWT 시크릿 키 안전하게 관리
- Refresh Token Rotation 구현
- Rate Limiting 적용
- 비밀번호 정책 준수

#### 데이터 보안

- 민감 데이터 암호화
- SQL Injection 방지
- XSS 방지
- 백업 데이터 암호화

#### 통신 보안

- HTTPS 적용 (프로덕션)
- CORS 정책 설정
- Cookie 보안 속성 설정
- 보안 헤더 설정

#### API 보안

- 입력값 검증
- 에러 정보 최소화
- 리소스 소유권 검증
- API 문서 보안 (프로덕션)

---

## 참고 자료 (References)

- [백엔드 시스템 아키텍처](./backend-architecture.md)
- [API 명세서](./api-specification.md)
- [인증 시스템 명세](./authentication-system-specification.md)
- [개인정보 처리방침](./privacy-policy.md) (향후 작성)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.11.02 | 왕택준 | 최조 작성 |
