# Dialogym 벡엔드 인증/보안 시스템 구현 명세서

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.01

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 인증 시스템의 전체 구조와 각 API의 상세 동작 방식을 이해하고 유지보수해야 하는 담당자
* **프론트엔드 개발자**: 클라이언트에서 토큰 관리, API 호출, 에러 처리를 구현해야 하는 담당자
* **보안 담당자**: JWT 토큰 관리, XSS/CSRF 방어 전략, 토큰 탈취 대응 방안을 검토하는 담당자
* **신규 합류자**: 프로젝트의 인증 시스템 전체 구조를 빠르게 파악해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 JWT 기반 Stateless 인증과 Refresh Token Rotation(RTR)을 적용한 하이브리드 인증 시스템의 구현 명세를 정의합니다. AccessToken(15분)은 API Body로 전달되어 클라이언트 메모리에서 관리되며, RefreshToken(14일)은 HttpOnly/Secure/SameSite=Strict 쿠키로 브라우저에 안전하게 저장됩니다. 로컬 회원가입은 이메일 인증(JWT 토큰 + 6자리 OTP 이중 검증)을 거쳐 완료되며, 소셜 로그인은 신규/기존 회원을 분기 처리합니다. 신규 소셜 회원은 SOCIAL_SIGNUP_PENDING_TOKEN(15분)을 받아 추가 정보 입력 후 가입을 완료하고, 기존 소셜 회원은 DB 기반 일회용 코드(1분)를 받아 안전하게 AccessToken으로 교환합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [시스템 아키텍처](#시스템-아키텍처)
   - 2.1 [전체 구조](#전체-구조)
   - 2.2 [토큰 종류 및 특성](#토큰-종류-및-특성)
   - 2.3 [Spring Security 필터 체인](#spring-security-필터-체인)
   - 2.4 [핵심 컴포넌트 구현](#핵심-컴포넌트-구현)
3. [데이터베이스 스키마](#데이터베이스-스키마)
4. [로컬 회원가입 플로우](#로컬-회원가입-플로우)
5. [소셜 로그인 플로우](#소셜-로그인-플로우)
6. [토큰 관리 및 갱신](#토큰-관리-및-갱신)
7. [보안 전략](#보안-전략)
8. [에러 처리](#에러-처리)
9. [API 엔드포인트 명세](#api-엔드포인트-명세)
10. [부록](#부록)
11. [참고 자료](#참고-자료-references)
12. [인증 플로우 다이어그램](#인증-플로우-다이어그램)
13. [향후 개선 로드맵](#향후-개선-로드맵)
14. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 trAIn 프로젝트의 인증/인가 시스템 전체 구현 내역을 상세히 기술합니다. 프로젝트 초기 설계 단계에서 XSS와 CSRF 공격 모두에 대한 방어를 균형 있게 고려한 하이브리드 토큰 관리 방식을 채택했습니다. 실제 코드 구현을 기반으로 각 인증 플로우의 세부 동작, DB 스키마, 보안 전략, 에러 처리 방식을 포함하여 시스템 전체를 이해할 수 있도록 작성되었습니다.

본 명세서는 다음과 같은 목적으로 활용됩니다.

* 신규 개발자의 온보딩 자료
* 인증 시스템 유지보수 및 확장 시 참고 문서
* 보안 감사 및 코드 리뷰 기준 문서
* 프론트엔드-백엔드 간 API 계약 명세

---

## 시스템 아키텍처

### 전체 구조

본 시스템은 JWT 기반 Stateless 인증과 Refresh Token Rotation(RTR)을 결합한 하이브리드 방식을 사용합니다.

**핵심 설계 원칙:**

* Stateless 인증: AccessToken은 서버 상태를 저장하지 않고 JWT 자체로 인증 정보를 검증합니다.
* Stateful 갱신: RefreshToken은 DB에 저장하여 무효화 및 탈취 감지가 가능합니다.
* 토큰 분리 전략: AccessToken과 RefreshToken을 서로 다른 방식으로 전달하여 XSS와 CSRF 공격을 모두 방어합니다.
* 일회용 토큰: 모든 임시 인증 토큰은 사용 즉시 DB에서 삭제되어 재사용을 방지합니다.


### 토큰 종류 및 특성

| 토큰 종류 | 유효기간 | 전달 방식 | 저장 위치 (클라이언트) | 저장 위치 (서버) | 주요 용도 |
|-----------|----------|-----------|------------------------|------------------|-----------|
| AccessToken | 15분 | API Body (JSON) | 메모리 (State) | 없음 (Stateless) | API 접근 권한 증명 |
| RefreshToken | 14일 | HttpOnly 쿠키 | 브라우저 쿠키 저장소 | DB (refresh_tokens) | AccessToken 갱신 |
| EmailVerificationToken | 15분 | API Body (JSON) | 메모리 (State) | DB (email_verifications) | 이메일 인증 |
| SocialSignupPendingToken | 15분 | URL 쿼리 파라미터 | 메모리 (State) | DB (pending_social_users) | 소셜 신규 가입 완료 |
| OneTimeCode | 1분 | URL 쿼리 파라미터 | 즉시 교환 | DB (one_time_codes) | AccessToken 교환 |

### Spring Security 필터 체인

```
Client Request
    ↓
RefreshRateLimitFilter (Rate Limiting)
    ↓
JwtAuthenticationFilter (JWT 검증 및 SecurityContext 설정)
    ↓
Spring Security FilterChain
    ↓
Controller (@AuthenticationPrincipal 사용)
```

**JwtAuthenticationFilter 동작 과정:**

1. `Authorization` 헤더에서 `Bearer` 토큰 추출
2. JWT 서명 및 만료 시간 검증 (`JwtTokenProvider.validateToken`)
3. 토큰에서 userId 추출 (`JwtTokenProvider.getUserIdFromToken`)
4. UserDetailsService로 사용자 정보 조회 (`CustomUserDetailsService.loadUserById`)
5. SecurityContext에 인증 정보 설정 (`SecurityContextHolder.getContext().setAuthentication`)
6. 검증 실패 시 인증 없이 다음 필터로 진행 (Public API는 통과, Protected API는 401 반환)

**SecurityConfig 주요 설정:**

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
ublic SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .formLogin(AbstractHttpConfigurer::disable)
            .httpBasic(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource))
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .exceptionHandling(exception -> exception
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
                .accessDeniedHandler(jwtAccessDeniedHandler))
            .authorizeHttpRequests(auth -> auth
                // Public API
                .requestMatchers(
                    "/api/v1/users/signup",
                    "/api/v1/users/login",
                    "/api/v1/users/logout",
                    "/api/v1/users/refresh",
                    "/api/v1/users/token/exchange",
                    "/api/v1/verification/**",
                    "/api/v1/terms",
                    "/oauth2/**",
                    "/login/oauth2/**",
                    "/swagger-ui/**",
                    "/v3/api-docs/**"
                ).permitAll()
                // Protected API
                .anyRequest().authenticated())
            .oauth2Login(oauth2 -> oauth2
                .authorizationEndpoint(auth -> auth
                    .authorizationRequestRepository(
                        new HttpSessionOAuth2AuthorizationRequestRepository()))
                .successHandler(oAuth2AuthenticationSuccessHandler))
            .addFilterBefore(refreshRateLimitFilter,
                UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(jwtAuthenticationFilter,
                UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

**주요 특징:**
* CSRF 비활성화 (JWT 사용으로 불필요)
* Stateless 세션 관리
* 커스텀 인증/인가 예외 핸들러
* Public/Protected API 구분
* OAuth2 로그인 통합
* 필터 체인 순서: RefreshRateLimitFilter → JwtAuthenticationFilter → Spring Security FilterChain

### 핵심 컴포넌트 구현

#### CustomUserDetails 및 UserDetailsService

**CustomUserDetails:**
* Spring Security의 `UserDetails` 인터페이스 구현
* OAuth2User 인터페이스도 함께 구현하여 소셜 로그인과 일반 로그인 통합
* User 엔티티를 감싸서 인증/인가 정보 제공

**주요 메서드:**
```java
public class CustomUserDetails implements UserDetails, OAuth2User {
    private final User user;
    private Map<String, Object> attributes;

    // 사용자 ID 반환
    public Long getUserId() {
        return user.getId();
    }

    // 권한 목록 반환 (현재는 ROLE_USER로 고정)
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"));
    }

    // 계정 잠금 여부 (SUSPENDED 상태 체크)
    @Override
    public boolean isAccountNonLocked() {
        return !user.getStatus().isTerminated()
            && user.getStatus() != UserStatus.SUSPENDED;
    }

    // 계정 활성화 여부 (로그인 가능 상태 체크)
    @Override
    public boolean isEnabled() {
        return user.getStatus().canLogin();
    }
}
```

**CustomUserDetailsService:**
* JWT 토큰에서 추출한 userId로 사용자 조회
* 이메일 기반 로그인 지원 (로컬 계정만)

```java
@Service
public class CustomUserDetailsService implements UserDetailsService {

    // JWT 인증용: userId로 조회
    public UserDetails loadUserById(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다"));
        return new CustomUserDetails(user);
    }

    // 일반 인증용: 이메일로 조회 (로컬 계정만)
    @Override
    public UserDetails loadUserByUsername(String email) {
        User user = userRepository.findByEmailAndPrimaryProvider(email, Provider.LOCAL)
            .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다"));
        return new CustomUserDetails(user);
    }
}
```

#### @CurrentUserId 커스텀 어노테이션

**목적:**
* 컨트롤러 메서드에서 현재 인증된 사용자 ID를 간편하게 추출
* `@AuthenticationPrincipal`을 래핑하여 코드 간소화

**정의:**
```java
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@AuthenticationPrincipal(expression = "#this == 'anonymousUser' ? null : #this")
public @interface CurrentUserId {
}
```

**사용 예시:**
```java
@GetMapping("/me")
public ResponseEntity<?> getMyProfile(@CurrentUserId Long userId) {
    // userId는 JWT에서 자동 추출됨
    UserProfileResponseDto profile = userService.getProfile(userId);
    return ResponseEntity.ok(profile);
}
```

**기존 방식과 비교:**
```java
// 기존 방식 (장황함)
@GetMapping("/me")
public ResponseEntity<?> getMyProfile(@AuthenticationPrincipal CustomUserDetails userDetails) {
    Long userId = userDetails.getUserId();
    // ...
}

// @CurrentUserId 사용 (간결함)
@GetMapping("/me")
public ResponseEntity<?> getMyProfile(@CurrentUserId Long userId) {
    // ...
}
```

#### JwtAccessDeniedHandler

**역할:**
* 인증은 되었지만 권한이 부족한 경우 403 Forbidden 응답
* Spring Security의 `AccessDeniedHandler` 구현

**동작:**
```java
@Component
public class JwtAccessDeniedHandler implements AccessDeniedHandler {
    @Override
    public void handle(HttpServletRequest request,
                       HttpServletResponse response,
                       AccessDeniedException accessDeniedException) {

        log.warn("권한 부족 접근 거부: URI: {}, Principal: {}",
                request.getRequestURI(),
                request.getUserPrincipal() != null
                    ? request.getUserPrincipal().getName()
                    : "Anonymous");

        ErrorResponseWriter.write(
            request, response, 403,
            "접근 권한이 없습니다.", "AUTH_002"
        );
    }
}
```

**발생 시나리오:**
* 일반 사용자가 관리자 전용 API 접근 시
* 특정 리소스에 대한 소유권이 없는 경우
* `@PreAuthorize` 어노테이션 조건 미충족 시

#### RequestLoggingAspect (AOP 로깅)

**목적:**
* 모든 컨트롤러 요청/응답을 자동으로 로깅
* 민감 정보 자동 마스킹 (LogMaskingUtil 사용)
* 개별 컨트롤러에서 로깅 코드 중복 제거

**구현:**
```java
@Slf4j
@Aspect
@Component
public class RequestLoggingAspect {

    @Around("within(@org.springframework.web.bind.annotation.RestController *)")
    public Object logControllerExecution(ProceedingJoinPoint pjp) throws Throwable {
        String controllerName = pjp.getSignature().getDeclaringTypeName();
        String methodName = pjp.getSignature().getName();
        Object[] args = pjp.getArgs();

        // 요청 로그 (민감 정보 마스킹)
        log.info("[REQ] {}.{} args={}",
            controllerName, methodName,
            LogMaskingUtil.maskSensitiveData(args));

        // 실제 메서드 실행
        Object result = pjp.proceed();

        // 응답 로그 (민감 정보 마스킹)
        log.info("[RES] {}.{} return={}",
            controllerName, methodName,
            LogMaskingUtil.maskSensitiveData(result));

        return result;
    }
}
```

**마스킹 대상:**
* 이메일: `user@example.com` → `u***@example.com`
* 토큰: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` → `eyJhbGci...`
* 비밀번호: 완전 제거
* 기타 민감 필드: `***` 처리

**로그 예시:**
```
[REQ] UserController.login args=[LoginRequestDto(email=u***@example.com, password=***)]
[RES] UserController.login return=ApiResponse(success=true, data=LoginResponseDto(accessToken=eyJhbGci..., refreshToken=null))
```

---

## 데이터베이스 스키마

### users 테이블

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(60),  -- BCrypt 암호화, 소셜 계정은 NULL
    name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    job_type VARCHAR(20) NOT NULL,
    job_detail VARCHAR(20),
    primary_provider VARCHAR(20) NOT NULL,  -- LOCAL, GOOGLE, KAKAO, NAVER
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME,
    created_at DATETIME NOT NULL,
    deleted_at DATETIME,
    UNIQUE KEY uk_email_provider (email, primary_provider),
    INDEX idx_user_email (email),
    INDEX idx_user_status (status)
);
```

**주요 특징:**
* `email + primary_provider` 복합 유니크 제약: 같은 provider 내에서만 이메일 중복 불가
* `password` NULL 허용: 소셜 계정은 비밀번호 없음
* `email_verified`: 로컬 계정은 false로 시작, 소셜 계정은 true
* `deleted_at`: Soft delete 방식으로 탈퇴 처리

### refresh_tokens 테이블

```sql
CREATE TABLE refresh_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    expiry_date DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**주요 특징:**
* 사용자당 여러 토큰 가능 (멀티 디바이스 지원)
* RTR 방식: 갱신 시 기존 토큰 삭제 후 새 토큰 생성
* 로그아웃 시 해당 토큰 즉시 삭제


### email_verifications 테이블

```sql
CREATE TABLE email_verifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    email VARCHAR(100) NOT NULL,
    verification_token VARCHAR(500) NOT NULL UNIQUE,
    code VARCHAR(6) NOT NULL,  -- 6자리 OTP
    expiry_date DATETIME NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    verified_at DATETIME,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_ev_email_code (email, code)
);
```

**주요 특징:**
* JWT 토큰 + 6자리 OTP 이중 검증
* 인증 성공 시 즉시 삭제 (일회용)
* 재발송 시 기존 레코드 삭제 후 새 레코드 생성

### pending_social_users 테이블

```sql
CREATE TABLE pending_social_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pending_token VARCHAR(500) NOT NULL UNIQUE,
    provider VARCHAR(20) NOT NULL,
    provider_id VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    expiry_date DATETIME NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    used_at DATETIME,
    created_at DATETIME NOT NULL,
    INDEX idx_psu_provider (provider, provider_id)
);
```

**주요 특징:**
* 소셜 신규 회원의 추가 정보 입력 대기 상태 저장
* 회원가입 완료 시 즉시 삭제 (일회용)
* 재시도 시 기존 레코드 삭제 후 새 레코드 생성

### one_time_codes 테이블

```sql
CREATE TABLE one_time_codes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL UNIQUE,
    user_id VARCHAR(20) NOT NULL,
    expiry_date DATETIME NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    INDEX idx_otc_user (user_id)
);
```

**주요 특징:**
* 소셜 기존 회원의 AccessToken 교환용 일회용 코드
* 1분 후 자동 만료
* 사용 즉시 DB에서 삭제
* URL에 AccessToken 노출 방지

### social_accounts 테이블

```sql
CREATE TABLE social_accounts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    provider VARCHAR(20) NOT NULL,
    provider_id VARCHAR(100) NOT NULL,
    social_email VARCHAR(100) NOT NULL,
    social_name VARCHAR(100) NOT NULL,
    is_connected BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_provider_provider_id (provider, provider_id)
);
```

**주요 특징:**
* 하나의 User에 여러 소셜 계정 연동 가능
* `provider + provider_id` 복합 유니크 제약
* 소셜 계정 연동/해제 관리

---

## 로컬 회원가입 플로우

### 1. 회원가입 요청 (POST /api/v1/users/signup)

**요청 흐름:**
```
Client → UserController.signup()
      → UserService.signUp()
      → VerificationService.sendVerificationEmail()
      → EmailService.sendVerificationEmail() (비동기)
```

**요청 Body:**
```json
{
  "email": "user@example.com",
  "password": "password123!",
  "passwordConfirm": "password123!",
  "name": "홍길동",
  "birthDate": "1990-01-01",
  "jobType": "EMPLOYEE",
  "jobDetail": null,
  "consents": [
    { "termsId": 1, "agreed": true },
    { "termsId": 2, "agreed": true }
  ]
}
```


**처리 과정:**

1. 입력값 검증
   - 비밀번호 확인 일치 여부
   - 나이 제한 (만 14세 이상)
   - 이메일 중복 체크 (`UserRepository.findLoginableUser(email, Provider.LOCAL)`)
   - 필수 약관 동의 확인 (`TermsService.validateConsents`)
   - 직업 상세 정보 검증 (JobType.OTHER인 경우 jobDetail 필수)

2. User 엔티티 생성 및 저장
   - 비밀번호 BCrypt 암호화
   - `emailVerified=false`, `primaryProvider=LOCAL` 설정
   - 약관 동의 내역 저장 (`user_consents` 테이블)

3. 이메일 인증 토큰 및 코드 생성
   - JWT 토큰 생성 (15분 유효)
   - 6자리 OTP 코드 생성 (`Math.random() * 1000000`)
   - `EmailVerification` 엔티티 DB 저장

4. 이메일 비동기 발송
   - 6자리 코드만 이메일로 전송 (토큰은 전송 안 함)

**응답 Body:**
```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다. 이메일 인증을 진행해주세요.",
  "data": {
    "userId": 123,
    "email": "user@example.com",
    "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**클라이언트 처리:**
* `emailVerificationToken`을 메모리(State)에 저장
* 이메일 인증 페이지로 이동하여 6자리 코드 입력 대기

### 2. 이메일 인증 (POST /api/v1/verification/email)

**요청 Body:**
```json
{
  "email": "user@example.com",
  "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "verificationCode": "123456"
}
```

**처리 과정:**

1. DB 조회 (이중 검증)
   - 1차: 이메일 + 코드로 조회 (`emailVerificationRepository.findByEmailAndCode`)
   - 2차: 토큰 일치 여부 확인
   - 3차: 만료 검증 (`LocalDateTime.now().isAfter(expiryDate)`)

2. 인증 완료 처리
   - `user.verifyEmail()` 호출 (`emailVerified = true`)
   - `EmailVerification` 레코드 즉시 삭제 (일회용 보장)

**응답 Body:**
```json
{
  "success": true,
  "message": "이메일 인증이 완료되었습니다.",
  "data": {
    "success": true,
    "emailVerified": true
  }
}
```

### 3. 이메일 인증 코드 재발송 (POST /api/v1/verification/email/resend)

**요청 Body:**
```json
{
  "email": "user@example.com",
  "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**처리 과정:**

1. 미인증 사용자 조회 (`userRepository.findUnverifiedLocalUser`)
2. 기존 미인증 토큰 전체 삭제 (`emailVerificationRepository.deleteUnverifiedByEmail`)
3. 새 토큰 및 코드 생성
4. 새 코드 이메일 발송
5. 새 토큰 응답

**응답 Body:**
```json
{
  "success": true,
  "message": "인증 이메일이 재발송되었습니다.",
  "data": {
    "success": true,
    "message": "인증 코드가 재발송되었습니다.",
    "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**클라이언트 처리:**
* 응답에서 받은 새 `emailVerificationToken`으로 메모리(State) 업데이트


### 4. 로그인 (POST /api/v1/users/login)

**요청 Body:**
```json
{
  "email": "user@example.com",
  "password": "password123!"
}
```

**처리 과정:**

1. 사용자 조회 및 검증
   - 사용자 존재 여부 확인
   - 비밀번호 검증 (`passwordEncoder.matches`)
   - 이메일 인증 완료 여부 확인 (`user.isEmailVerified()`)

2. 토큰 생성
   - AccessToken (15분) 및 RefreshToken (14일) 생성
   - RefreshToken DB 저장 (`refresh_tokens` 테이블)

3. 사용자 상태 업데이트
   - 마지막 로그인 시간 업데이트 (`user.updateLastLogin()`)
   - 계정 상태 ACTIVE로 변경 (필요 시)

4. 응답 처리
   - RefreshToken을 HttpOnly 쿠키로 설정
   - Body에서는 RefreshToken을 null로 설정

**응답:**
* 헤더: `Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict; Max-Age=1209600; Path=/`
* Body:
```json
{
  "success": true,
  "message": "로그인에 성공했습니다.",
  "data": {
    "userId": 123,
    "email": "user@example.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

---

## 소셜 로그인 플로우

### 1. 소셜 로그인 시작

**프론트엔드 처리:**
```javascript
// 사용자가 "Google로 로그인" 버튼 클릭
window.location.href = "http://backend.com/oauth2/authorization/google";
```

**백엔드 처리:**
* Spring Security OAuth2가 자동으로 Google 인증 페이지로 리다이렉트
* 사용자가 Google에서 로그인 및 권한 동의

### 2. 소셜 콜백 처리 (/login/oauth2/code/{provider})

**Spring Security 자동 처리:**
1. Authorization Code를 Access Token으로 교환
2. 소셜 플랫폼 API로 사용자 정보 조회
3. `OAuth2AuthenticationSuccessHandler.onAuthenticationSuccess()` 호출

**소셜 정보 추출 (AuthService.extractSocialUserInfo):**

```java
// Google
providerId = attributes.get("sub")
email = attributes.get("email")
name = attributes.get("name")

// Kakao
providerId = String.valueOf(attributes.get("id"))
email = kakaoAccount.get("email")
name = profile.get("nickname")

// Naver
providerId = response.get("id")
email = response.get("email")
name = response.get("name")
```

**기존 회원 여부 확인:**
```java
Optional<SocialAccount> socialAccountOpt = socialAccountRepository
    .findByProviderAndProviderId(provider, providerId);
```

### 3-A. 신규 회원 처리

**처리 과정:**

1. 기존 미완료 레코드 삭제 (재시도 대응)
   - `pendingSocialUserRepository.deleteByProviderAndProviderId(provider, providerId)`

2. JWT 토큰 생성 (15분)
   - `jwtTokenProvider.generateSocialSignupPendingToken(provider, providerId, email, name)`

3. PendingSocialUser 엔티티 저장
   - `pending_social_users` 테이블에 저장

4. 프론트엔드 리다이렉트
   - `http://localhost:5050/social-signup?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**프론트엔드 처리:**
* URL에서 `token` 파라미터 추출
* 메모리(State)에 저장
* 추가 정보 입력 폼 표시 (생년월일, 직업, 약관 동의)


### 4. 소셜 회원가입 완료 (POST /api/v1/verification/social/complete)

**요청:**
* 헤더: `Authorization: Bearer [SOCIAL_SIGNUP_PENDING_TOKEN]`
* Body:
```json
{
  "socialSignupPendingToken": "eyJhbGciOiJIUzI1N5cCI6IkpXVCJ9...",
  "birthDate": "1990-01-01",
  "jobType": "EMPLOYEE",
  "jobDetail": null,
  "consents": [
    { "termsId": 1, "agreed": true },
    { "termsId": 2, "agreed": true }
  ]
}
```

**처리 과정:**

1. 토큰 검증 (이중 검증)
   - 1차: JWT 서명 및 만료 검증
   - 2차: DB 조회 (`pendingSocialUserRepository.findByPendingToken`)
   - 3차: 사용 여부 및 만료 확인

2. 입력값 검증
   - 나이 제한, 직업 상세 정보, 약관 동의 확인

3. User 및 SocialAccount 엔티티 생성
   - `emailVerified=true`, `primaryProvider=소셜제공자` 설정
   - 약관 동의 내역 저장

4. PendingSocialUser 삭제 (일회용 보장)

5. 즉시 로그인 처리 (토큰 발급)
   - AccessToken 및 RefreshToken 생성
   - RefreshToken DB 저장

**응답:**
* 헤더: `Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict`
* Body:
```json
{
  "success": true,
  "message": "소셜 회원가입 및 로그인이 완료되었습니다.",
  "data": {
    "userId": 123,
    "email": "user@gmail.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

### 3-B. 기존 회원 처리 (DB 기반 One-Time Code)

**처리 과정:**

1. 사용자 조회 및 상태 업데이트
   - 마지막 로그인 시간 업데이트

2. RefreshToken 생성 및 저장
   - `refresh_tokens` 테이블에 저장

3. 일회용 코드 생성 및 DB 저장
   - 기존 코드 삭제 (중복 방지)
   - 16자리 랜덤 코드 생성 (`UUID.randomUUID().toString().replace("-", "").substring(0, 16)`)
   - 1분 만료 시간 설정
   - `one_time_codes` 테이블에 저장

4. 프론트엔드 리다이렉트
   - `http://localhost:5050/?code=a1b2c3d4e5f6g7h8`

**보안 강화 포인트:**
* URL에 실제 AccessToken이 노출되지 않음
* 일회용 코드는 1분 후 자동 만료
* 사용 즉시 DB에서 삭제
* 브라우저 히스토리에 남아도 재사용 불가

### 5. 일회용 코드-토큰 교환 (POST /api/v1/users/token/exchange)

**프론트엔드 처리:**
```javascript
// 페이지 로드 시 URL 확인
const urlParams = new URLSearchParams(window.location.search);
const code = urlParams.get('code');

if (code) {
    // 즉시 API 호출
    co
nst response = await fetch('/api/v1/users/token/exchange', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code })
});

const data = await response.json();
if (data.success) {
    // AccessToken을 메모리(State)에 저장
    setAccessToken(data.data.accessToken);
    // RefreshToken은 HttpOnly 쿠키로 자동 저장됨

    // URL에서 code 파라미터 제거 (브라우저 히스토리 보안)
    window.history.replaceState({}, document.title, '/');
}
```

**요청 Body:**
```json
{
  "code": "a1b2c3d4e5f6g7h8"
}
```

**처리 과정:**

1. DB에서 일회용 코드 조회
   - `oneTimeCodeRepository.findByCode(code)`
   - 존재하지 않으면 401 에러

2. 코드 유효성 검증
   - 만료 여부 확인 (`LocalDateTime.now().isAfter(expiryDate)`)
   - 사용 여부 확인 (`used == true`)
   - 유효하지 않으면 DB에서 삭제 후 401 에러

3. 코드 즉시 삭제 (일회용 보장)
   - `oneTimeCodeRepository.delete(oneTimeCode)`

4. 사용자 조회 및 토큰 발급
   - userId로 User 엔티티 조회
   - AccessToken 및 RefreshToken 생성
   - RefreshToken DB 저장
   - 마지막 로그인 시간 업데이트

**응답:**
* 헤더: `Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict`
* Body:
```json
{
  "success": true,
  "message": "토큰 교환에 성공했습니다.",
  "data": {
    "userId": 123,
    "email": "user@gmail.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

**보안 강화 효과:**
* URL에 실제 AccessToken이 노출되지 않음
* 브라우저 히스토리에 민감한 토큰이 남지 않음
* 일회용 코드는 1분 후 자동 만료
* 사용 즉시 DB에서 삭제되어 재사용 불가

---

## 토큰 관리 및 갱신

### AccessToken 갱신 (POST /api/v1/users/refresh)

**Refresh Token Rotation (RTR) 방식:**

본 시스템은 Refresh Token Rotation(RTR) 방식을 채택하여 보안을 강화했습니다. 매번 AccessToken을 갱신할 때마다 RefreshToken도 함께 갱신되며, 기존 RefreshToken은 즉시 무효화됩니다.

**RTR의 보안 이점:**
* 토큰 탈취 감지: 탈취된 RefreshToken이 사용되면 정상 사용자의 토큰도 무효화되어 즉시 감지 가능
* 재사용 방지: 한 번 사용된 RefreshToken은 DB에서 삭제되어 재사용 불가
* 공격 표면 축소: RefreshToken의 유효 기간이 실질적으로 단축됨

**요청:**
* 헤더: 없음 (쿠키 자동 전송)
* 쿠키: `refreshToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**처리 과정:**

1. HttpOnly 쿠키에서 RefreshToken 추출
   - `cookieUtil.getRefreshToken(request)`
   - 없으면 401 에러

2. DB에서 RefreshToken 조회
   - `refreshTokenRepository.findByToken(refreshToken)`
   - 없으면 401 에러 (이미 사용되었거나 로그아웃됨)

3. 만료 검증
   - `storedToken.isExpired()` 확인
   - 만료되었으면 DB에서 삭제 후 401 에러

4. 기존 RefreshToken 삭제 (RTR 핵심)
   - `refreshTokenRepository.delete(storedToken)`
   - `refreshTokenRepository.flush()` (즉시 DB 반영)

5. 새로운 토큰 쌍 생성
   - AccessToken (15분) 및 RefreshToken (14일) 생성
   - 새 RefreshToken을 DB에 저장

6. 응답 처리
   - 새 RefreshToken을 HttpOnly 쿠키로 설정
   - Body에는 AccessToken만 포함 (RefreshToken은 null)

**응답:**
* 헤더: `Set-Cookie: refreshToken=[새로운 토큰]; HttpOnly; Secure; SameSite=Strict`
* Body:
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

**Rate Limiting:**

토큰 갱신 엔드포인트는 `RefreshRateLimitFilter`를 통해 Rate Limiting이 적용됩니다.

**정책:**
* 윈도우: 10초
* 최대 요청 수: 2회
* 초과 시: 429 Too Many Requests 응답
* Retry-After 헤더 제공

**구현 방식:**
* Bucket4j 라이브러리 사용 (Token Bucket 알고리즘)
* Caffeine 캐시로 클라이언트별 버킷 관리
* 클라이언트 식별: IP + User-Agent
* X-Forwarded-For 헤더 지원 (프록시 환경 대응)

**응답 헤더:**
* `X-RateLimit-Remaining`: 남은 요청 횟수
* `Retry-After`: 다음 요청 가능 시간 (초)

**429 응답 예시:**
```json
{
  "code": "RATE_LIMIT",
  "message": "Too many refresh requests"
}
```

### 로그아웃 (POST /api/v1/users/logout)

**처리 과정:**

1. HttpOnly 쿠키에서 RefreshToken 추출
2. DB에서 해당 RefreshToken 삭제
   - `refreshTokenRepository.findByToken(refreshToken).ifPresent(refreshTokenRepository::delete)`
3. RefreshToken 쿠키 삭제
   - `Max-Age=0` 설정하여 즉시 만료

**응답:**
```json
{
  "success": true,
  "message": "성공적으로 로그아웃되었습니다.",
  "data": null
}
```

**클라이언트 처리:**
* 메모리(State)에 저장된 AccessToken 삭제
* 로그인 페이지로 리다이렉트

---

## 보안 전략

### XSS (Cross-Site Scripting) 방어

**1. RefreshToken을 HttpOnly 쿠키로 관리**

* JavaScript에서 접근 불가 (`document.cookie`로 읽을 수 없음)
* XSS 공격으로 스크립트가 삽입되어도 RefreshToken 탈취 불가
* 쿠키 속성: `HttpOnly; Secure; SameSite=Strict`

**2. AccessToken을 메모리(State)에만 저장**
* LocalStorage, SessionStorage 사용 안 함
* 페이지 새로고침 시 AccessToken 소실 → RefreshToken으로 재발급
* XSS로 메모리 접근 시도 시에도 15분 유효기간으로 피해 최소화

**3. Secure 플래그 (HTTPS 전용)**
* 프로덕션 환경에서 쿠키는 HTTPS 연결에서만 전송
* 중간자 공격(MITM)으로부터 보호

**4. SameSite=Strict**
* 크로스 사이트 요청 시 쿠키 전송 차단
* CSRF 공격 1차 방어선

### CSRF (Cross-Site Request Forgery) 방어

**1. AccessToken을 API Body로 전달**
* Authorization 헤더에 Bearer 토큰 포함
* 크로스 사이트 요청에서는 커스텀 헤더 설정 불가 (CORS 정책)
* 공격자가 사용자의 브라우저를 통해 요청을 보내도 AccessToken을 포함할 수 없음

**2. SameSite=Strict 쿠키 속성**
* RefreshToken 쿠키는 동일 사이트 요청에서만 전송
* 외부 사이트에서 발생한 요청에는 쿠키가 포함되지 않음

**3. CORS 정책**
* 허용된 Origin만 API 접근 가능
* Preflight 요청(OPTIONS)으로 사전 검증
* Credentials 포함 요청은 명시적으로 허용된 Origin만 가능

**CORS 설정 (`CorsConfig.java`):**
```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(List.of("http://localhost:5050", "https://yourdomain.com"));
    config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    config.setAllowedHeaders(List.of("*"));
    config.setAllowCredentials(true); // 쿠키 포함 허용
    config.setMaxAge(3600L);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", config);
    return source;
}
```

### 토큰 탈취 대응

**1. Refresh Token Rotation (RTR)**

* RefreshToken 사용 시 기존 토큰 즉시 무효화
* 탈취된 토큰이 사용되면 정상 사용자의 토큰도 무효화되어 이상 징후 감지
* 공격자와 정상 사용자 모두 재로그인 필요 → 관리자 알림 트리거 가능

**2. 짧은 AccessToken 유효기간 (15분)**
* 탈취되어도 15분 후 자동 만료
* 공격 시간 창 최소화

**3. 일회용 토큰 (EmailVerification, SocialSignupPending, OneTimeCode)**
* 사용 즉시 DB에서 삭제
* 재사용 불가능
* 짧은 유효기간 (1분 ~ 15분)

**4. DB 기반 RefreshToken 관리**
* 서버에서 언제든지 특정 토큰 무효화 가능
* 의심스러운 활동 감지 시 해당 사용자의 모든 RefreshToken 삭제 가능
* 로그아웃 시 즉시 DB에서 삭제

### 비밀번호 보안

**1. BCrypt 암호화**
* 단방향 해시 함수 (복호화 불가)
* Salt 자동 생성 (레인보우 테이블 공격 방어)
* 적응형 해시 함수 (컴퓨팅 파워 증가에 대응)

**구현 코드:**
```java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}

// 회원가입 시
String encodedPassword = passwordEncoder.encode(rawPassword);

// 로그인 시
boolean matches = passwordEncoder.matches(rawPassword, encodedPassword);
```

**2. 비밀번호 업그레이드 인코딩**
* 로그인 시 기존 인코딩 방식이 구식인지 확인
* 필요 시 자동으로 최신 방식으로 재암호화

```java
if (passwordEncoder.upgradeEncoding(user.getPassword())) {
    user.updatePassword(passwordEncoder.encode(request.getPassword()));
}
```

### 민감 정보 로깅 방지

**LogMaskingUtil 사용:**
* 토큰: 앞 8자만 표시 (`eyJhbGci...`)
* 이메일: 일부 마스킹 (`u***@example.com`)
* 에러 메시지: 민감 정보 제거

**구현 예시:**
```java
log.info("로그인 성공. Email: {}", LogMaskingUtil.maskEmail(user.getEmail()));
log.debug("토큰 생성. Token: {}", LogMaskingUtil.maskToken(accessToken));
```

### 보안 유틸리티 구현

#### CookieUtil

**주요 기능:**
1. RefreshToken 쿠키 생성
2. 요청에서 RefreshToken 추출
3. RefreshToken 쿠키 삭제

**구현 상세:**
```java
@Component
@RequiredArgsConstructor
public class CookieUtil {
    private final CookieProperties cookieProperties;

    // RefreshToken 쿠키 생성
    public void addRefreshTokenCookie(HttpServletResponse response, String refreshToken) {
        ResponseCookie cookie = ResponseCookie
            .from(cookieProperties.getRefreshTokenName(), refreshToken)
            .httpOnly(cookieProperties.isHttpOnly())
            .secure(cookieProperties.isSecure())
            .path(cookieProperties.getPath())
            .maxAge(cookieProperties.getRefreshTokenMaxAge())
            .sameSite(cookieProperties.getSameSite())
            .domain(cookieProperties.getDomain()) // 조건부 적용
            .build();

        response.addHeader("Set-Cookie", cookie.toString());
    }

    // RefreshToken 추출
    public Optional<String> getRefreshToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return Optional.empty();

        return Arrays.stream(cookies)
            .filter(cookie -> cookie.getName().equals(
                cookieProperties.getRefreshTokenName()))
            .map(Cookie::getValue)
            .findFirst();
    }

    // RefreshToken 쿠키 삭제 (maxAge=0)
    public void deleteRefreshTokenCookie(HttpServletResponse response) {
        ResponseCookie cookie = buildRefreshCookie("", 0);
        response.addHeader("Set-Cookie", cookie.toString());
    }
}
```

**도메인 설정:**
* 로컬 환경: 도메인 미설정 (localhost 자동 적용)
* 프로덕션: `.yourdomain.com` (서브도메인 간 공유)

#### ErrorResponseWriter

**목적:**
* 인증/인가 실패 시 일관된 JSON 에러 응답 생성
* LocalDateTime 직렬화 지원 (JavaTimeModule 등록)

**구현:**
```java
public final class ErrorResponseWriter {
    private static final ObjectMapper objectMapper;

    static {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
    }

    public static void write(
        HttpServletRequest request,
        HttpServletResponse response,
        int statusCode,
        String message,
        String errorCode
    ) throws IOException {
        response.setStatus(statusCode);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        ApiResponse<Void> errorResponse = ApiResponse.error(errorCode, message);
        objectMapper.writeValue(response.getOutputStream(), errorResponse);

        log.warn("에러 응답 작성 - URI: {}, Status: {}, Code: {}",
            request.getRequestURI(), statusCode, errorCode);
    }
}
```

**사용 위치:**
* JwtAuthenticationEntryPoint (401 응답)
* JwtAccessDeniedHandler (403 응답)
* RefreshRateLimitFilter (429 응답)

#### CORS 설정

**CorsConfig:**
```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Value("${cors.allowed-origins}")
    private String[] allowedOrigins;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // 허용 Origin
        configuration.setAllowedOrigins(Arrays.asList(allowedOrigins));

        // 허용 메서드
        configuration.setAllowedMethods(
            Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));

        // 허용 헤더
        configuration.setAllowedHeaders(Arrays.asList("*"));

        // 인증 정보 포함 허용 (쿠키)
        configuration.setAllowCredentials(true);

        // Preflight 캐시 시간
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

**application.yml:**
```yaml
cors:
  allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:5050,http://localhost:3000}
  allowed-methods: GET,POST,PUT,DELETE,OPTIONS
  allowed-headers: *
  max-age: 3600
```

**보안 고려사항:**
* `allowedOrigins`에 와일드카드(`*`) 사용 금지
* `allowCredentials=true`와 와일드카드 동시 사용 불가
* 프로덕션에서는 정확한 도메인만 허용

---

## 에러 처리

### 에러 응답 형식

모든 에러는 일관된 형식으로 반환됩니다.

**구조:**
```json
{
  "success": false,
  "message": "사용자에게 표시할 에러 메시지",
  "code": "ERROR_CODE",
  "status": 400,
  "timestamp": "2025-11-01T12:34:56.789",
  "path": "/api/v1/users/login"
}
```

### 주요 에러 코드

**인증 관련 (401, 403):**

| 에러 코드 | HTTP 상태 | 메시지 | 발생 상황 |
|-----------|-----------|--------|-----------|
| AUTH_001 | 401 | 인증이 필요합니다. | AccessToken 없이 보호된 API 접근 |
| AUTH_002 | 403 | 접근 권한이 없습니다. | 권한 부족 |
| AUTH_003 | 401 | 이메일 또는 비밀번호가 올바르지 않습니다. | 로그인 실패 |
| AUTH_004 | 403 | 이메일 인증이 완료되지 않았습니다. | 미인증 사용자 로그인 시도 |

**토큰 관련 (401):**

| 에러 코드 | HTTP 상태 | 메시지 | 발생 상황 |
|-----------|-----------|--------|-----------|
| TOKEN_001 | 401 | 유효하지 않은 토큰입니다. | JWT 형식 오류 |
| TOKEN_002 | 401 | 만료된 토큰입니다. | JWT 만료 |
| TOKEN_003 | 401 | 토큰 서명이 유효하지 않습니다. | JWT 서명 검증 실패 |
| TOKEN_004 | 401 | 지원되지 않는 형식의 토큰입니다. | JWT 형식 미지원 |
| TOKEN_005 | 401 | 리프레시 토큰이 유효하지 않습니다. | RefreshToken 없음/만료/사용됨 |

**이메일 및 소셜 인증 (400, 401, 410):**

| 에러 코드 | HTTP 상태 | 메시지 | 발생 상황 |
|-----------|-----------|--------|-----------|
| VERIFY_001 | 401 | 유효하지 않은 인증 세션입니다. | EmailVerificationToken 불일치 |
| VERIFY_002 | 410 | 인증 세션이 만료되었습니다. | EmailVerificationToken 만료 |
| VERIFY_003 | 400 | 인증 코드가 올바르지 않습니다. | 6자리 OTP 불일치 |
| VERIFY_004 | 400 | 요청 이메일과 토큰의 이메일이 일치하지 않습니다. | 이메일 불일치 |
| VERIFY_005 | 401 | 소셜 회원가입 세션이 유효하지 않습니다. | SocialSignupPendingToken 무효 |
| VERIFY_006 | 401 | 일회용 코드가 유효하지 않거나 만료되었습니다. | OneTimeCode 무효/만료/사용됨 |

**사용자 관련 (404, 409):**

| 에러 코드 | HTTP 상태 | 메시지 | 발생 상황 |
|-----------|-----------|--------|-----------|
| USER_001 | 404 | 사용자를 찾을 수 없습니다. | 존재하지 않는 사용자 |
| USER_002 | 409 | 이미 사용 중인 이메일입니다. | 이메일 중복 |
| USER_003 | 409 | 이미 다른 방법으로 가입된 이메일입니다. | Provider 충돌 |
| USER_004 | 404 | 사용자를 찾을 수 없거나 이미 인증된 사용자입니다. | 재발송 불가 |

**비즈니스 규칙 위반 (400):**

| 에러 코드 | HTTP 상태 | 메시지 | 발생 상황 |
|-----------|-----------|--------|-----------|
| RULE_001 | 400 | 비밀번호가 일치하지 않습니다. | 비밀번호 확인 불일치 |
| RULE_002 | 400 | 만 14세 이상만 가입할 수 있습니다. | 나이 제한 |
| RULE_003 | 400 | 기타 직업 선택 시 상세 정보는 필수입니다. | jobDetail 누락 |
| RULE_004 | 400 | 현재 비밀번호가 올바르지 않습니다. | 비밀번호 변경 시 |
| RULE_005 | 400 | 새 비밀번호는 현재 비밀번호와 달라야 합니다. | 동일 비밀번호 |
| RULE_006 | 400 | 소셜 로그인 사용자는 비밀번호를 변경할 수 없습니다. | 소셜 계정 |

**약관 관련 (400, 404):**

| 에러 코드 | HTTP 상태 | 메시지 | 발생 상황 |
|-----------|-----------|--------|-----------|
| TERMS_001 | 404 | 약관을 찾을 수 없거나 버전이 일치하지 않습니다. | 약관 조회 실패 |
| TERMS_002 | 400 | 필수 약관에 동의해야 합니다. | 필수 약관 미동의 |

### 에러 처리 흐름

**1. JwtAuthenticationFilter에서의 에러 처리:**

* JWT 검증 실패 시 `TrainException` 발생
* 필터에서 예외를 catch하여 로깅만 수행
* SecurityContext에 인증 정보를 설정하지 않고 다음 필터로 진행
* Public API는 통과, Protected API는 `JwtAuthenticationEntryPoint`에서 401 응답

**2. JwtAuthenticationEntryPoint:**
```java
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");

        ErrorResponse errorResponse = ErrorResponse.builder()
                .code("AUTH_001")
                .message("인증이 필요합니다.")
                .status(401)
                .timestamp(LocalDateTime.now())
                .path(request.getRequestURI())
                .build();

        response.getWriter().write(objectMapper.writeValueAsString(errorResponse));
    }
}
```

**3. GlobalExceptionHandler:**
* Controller에서 발생한 `TrainException`을 catch
* ErrorCode에 정의된 메시지와 상태 코드로 응답 생성
* 유효성 검증 실패(`@Valid`)는 400 응답으로 변환

```java
@ExceptionHandler(TrainException.class)
public ResponseEntity<ErrorResponse> handleTrainException(TrainException ex, HttpServletRequest request) {
    ErrorResponse errorResponse = ErrorResponse.builder()
            .code(ex.getErrorCode().getCode())
            .message(ex.getMessage())
            .status(ex.getErrorCode().getStatus())
            .timestamp(LocalDateTime.now())
            .path(request.getRequestURI())
            .build();

    return ResponseEntity.status(ex.getErrorCode().getStatus()).body(errorResponse);
}
```

**4. 클라이언트 에러 처리 권장 사항:**
* 401 에러: 로그인 페이지로 리다이렉트
* 403 에러: 권한 없음 페이지 표시
* 410 에러 (VERIFY_002): 재발송 안내
* 429 에러: Retry-After 헤더 확인 후 대기

---

## API 엔드포인트 명세

### 인증 관련 API

#### 1. 로컬 회원가입

**엔드포인트:** `POST /api/v1/users/signup`

**인증:** 불필요

**요청 Body:**
```json
{
  "email": "user@example.com",
  "password": "password123!",
  "passwordConfirm": "password123!",
  "name": "홍길동",
  "birthDate": "1990-01-01",
  "jobType": "EMPLOYEE",
  "jobDetail": null,
  "consents": [
    { "termsId": 1, "agreed": true },
    { "termsId": 2, "agreed": true }
  ]
}
```

**필드 설명:**
* `email`: 이메일 주소 (필수, 이메일 형식)
* `password`: 비밀번호 (필수, 8자 이상)
* `passwordConfirm`: 비밀번호 확인 (필수, password와 일치)
* `name`: 이름 (필수, 2-50자)
* `birthDate`: 생년월일 (필수, yyyy-MM-dd, 만 14세 이상)
* `jobType`: 직업 유형 (필수, EMPLOYEE/STUDENT/JOB_SEEKER/OTHER)
* `jobDetail`: 직업 상세 (jobType이 OTHER인 경우 필수)
* `consents`: 약관 동의 목록 (필수)

**응답 (201 Created):**
```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다. 이메일 인증을 진행해주세요.",
  "data": {
    "userId": 123,
    "email": "user@example.com",
    "name": "홍길동",
    "emailVerified": false,
    "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**에러 응답:**
* 400: 입력값 유효성 검증 실패
* 409: 이메일 중복 (USER_002)

---

#### 2. 이메일 인증

**엔드포인트:** `POST /api/v1/verification/email`

**인증:** 불필요

**요청 Body:**
```json
{
  "email": "user@example.com",
  "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "verificationCode": "123456"
}
```

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "이메일 인증이 완료되었습니다.",
  "data": {
    "success": true,
    "message": "이메일 인증이 완료되었습니다.",
    "emailVerified": true
  }
}
```

**에러 응답:**
* 400: 인증 코드 불일치 (VERIFY_003)
* 401: 토큰 불일치 (VERIFY_001)
* 410: 토큰 만료 (VERIFY_002)

---

#### 3. 이메일 인증 코드 재발송

**엔드포인트:** `POST /api/v1/verification/email/resend`

**인증:** 불필요

**요청 Body:**
```json
{
  "email": "user@example.com",
  "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "인증 이메일이 재발송되었습니다.",
  "data": {
    "success": true,
    "message": "인증 코드가 재발송되었습니다.",
    "emailVerificationToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**에러 응답:**
* 404: 사용자를 찾을 수 없거나 이미 인증됨 (USER_004)

---

#### 4. 로컬 로그인

**엔드포인트:** `POST /api/v1/users/login`

**인증:** 불필요

**요청 Body:**
```json
{
  "email": "user@example.com",
  "password": "password123!"
}
```

**응답 (200 OK):**
* 헤더: `Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict; Max-Age=1209600; Path=/`
* Body:
```json
{
  "success": true,
  "message": "로그인에 성공했습니다.",
  "data": {
    "userId": 123,
    "email": "user@example.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

**에러 응답:**
* 401: 로그인 실패 (AUTH_003)
* 403: 이메일 미인증 (AUTH_004)

---

#### 5. 로그아웃

**엔드포인트:** `POST /api/v1/users/logout`

**인증:** 불필요 (쿠키만 있으면 됨)

**요청:** 없음

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "성공적으로 로그아웃되었습니다.",
  "data": null
}
```

---

#### 6. AccessToken 갱신

**엔드포인트:** `POST /api/v1/users/refresh`

**인증:** RefreshToken 쿠키 필요

**요청:** 없음 (쿠키 자동 전송)

**응답 (200 OK):**
* 헤더: `Set-Cookie: refreshToken=[새로운 토큰]; HttpOnly; Secure; SameSite=Strict`
* Body:
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

**에러 응답:**
* 401: RefreshToken 없음/만료/무효 (TOKEN_005)
* 429: Rate Limit 초과

---

#### 7. 일회용 코드-토큰 교환

**엔드포인트:** `POST /api/v1/users/token/exchange`

**인증:** 불필요

**요청 Body:**
```json
{
  "code": "a1b2c3d4e5f6g7h8"
}
```

**응답 (200 OK):**
* 헤더: `Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict`
* Body:
```json
{
  "success": true,
  "message": "토큰 교환에 성공했습니다.",
  "data": {
    "userId": 123,
    "email": "user@gmail.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

**에러 응답:**
* 401: 일회용 코드 무효/만료 (VERIFY_006)

---

#### 8. 소셜 회원가입 완료

**엔드포인트:** `POST /api/v1/verification/social/complete`

**인증:** Authorization 헤더에 SOCIAL_SIGNUP_PENDING_TOKEN 필요

**요청:**
* 헤더: `Authorization: Bearer [SOCIAL_SIGNUP_PENDING_TOKEN]`
* Body:
```json
{
  "socialSignupPendingToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "birthDate": "1990-01-01",
  "jobType": "EMPLOYEE",
  "jobDetail": null,
  "consents": [
    { "termsId": 1, "agreed": true },
    { "termsId": 2, "agreed": true }
  ]
}
```

**응답 (200 OK):**
* 헤더: `Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict`
* Body:
```json
{
  "success": true,
  "message": "소셜 회원가입 및 로그인이 완료되었습니다.",
  "data": {
    "userId": 123,
    "email": "user@gmail.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": null
  }
}
```

**에러 응답:**
* 400: 입력값 유효성 검증 실패
* 401: 토큰 무효/만료 (VERIFY_005)

---

### 사용자 프로필 API

#### 9. 내 프로필 조회

**엔드포인트:** `GET /api/v1/users/profile`

**인증:** AccessToken 필요

**요청:**
* 헤더: `Authorization: Bearer [ACCESS_TOKEN]`

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "프로필 조회에 성공했습니다.",
  "data": {
    "userId": 123,
    "email": "user@example.com",
    "name": "홍길동",
    "birthDate": "1990-01-01",
    "jobType": "EMPLOYEE",
    "jobDetail": null,
    "provider": "LOCAL",
    "emailVerified": true,
    "createdAt": "2025-11-01T10:00:00"
  }
}
```

**에러 응답:**
* 401: 인증 필요 (AUTH_001)

---

#### 10. 내 프로필 수정

**엔드포인트:** `PUT /api/v1/users/profile`

**인증:** AccessToken 필요

**요청:**
* 헤더: `Authorization: Bearer [ACCESS_TOKEN]`
* Body:
```json
{
  "name": "홍길동",
  "birthDate": "1990-01-01",
  "jobType": "EMPLOYEE",
  "jobDetail": null
}
```

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "프로필이 성공적으로 수정되었습니다.",
  "data": {
    "userId": 123,
    "email": "user@example.com",
    "name": "홍길동",
    "birthDate": "1990-01-01",
    "jobType": "EMPLOYEE",
    "jobDetail": null,
    "provider": "LOCAL",
    "emailVerified": true,
    "createdAt": "2025-11-01T10:00:00"
  }
}
```

**에러 응답:**
* 400: 입력값 유효성 검증 실패
* 401: 인증 필요 (AUTH_001)

---

#### 11. 비밀번호 변경

**엔드포인트:** `PUT /api/v1/users/password`

**인증:** AccessToken 필요

**요청:**
* 헤더: `Authorization: Bearer [ACCESS_TOKEN]`
* Body:
```json
{
  "currentPassword": "oldPassword123!",
  "newPassword": "newPassword456!",
  "newPasswordConfirm": "newPassword456!"
}
```

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "비밀번호가 성공적으로 변경되었습니다.",
  "data": null
}
```

**에러 응답:**
* 400: 현재 비밀번호 불일치 (RULE_004)
* 400: 새 비밀번호 불일치 (RULE_001)
* 400: 동일 비밀번호 (RULE_005)
* 401: 인증 필요 (AUTH_001)
* 403: 소셜 계정 (RULE_006)

---

## 인증 플로우 다이어그램

### 로컬 회원가입 및 로그인 플로우

```
[클라이언트]                [백엔드]                    [DB]
    |                          |                         |
    |--POST /signup----------->|                         |
    |                          |--User 생성------------->|
    |                          |--EmailVerification---->|
    |                          |--이메일 발송 (비동기)    |
    |<-emailVerificationToken--|                         |
    |                          |                         |
    |--POST /verification----->|                         |
    |  (token + code)          |--검증 (이중)----------->|
    |                          |--User.emailVerified=true|
    |                          |--EmailVerification 삭제-|
    |<-200 OK------------------|                         |
    |                          |                         |
    |--POST /login------------>|                         |
    |  (email + password)      |--User 조회------------->|
    |                          |--비밀번호 검증           |
    |                          |--토큰 생성               |
    |                          |--RefreshToken 저장----->|
    |<-AccessToken (Body)------|                         |
    |<-RefreshToken (Cookie)---|                         |
```

**주요 특징:**
* 이메일 인증은 JWT 토큰 + 6자리 OTP 이중 검증
* 인증 완료 시 EmailVerification 레코드 즉시 삭제 (일회용)
* 로그인 시 AccessToken은 Body, RefreshToken은 HttpOnly 쿠키로 분리 전달

### 소셜 로그인 플로우 (기존 회원)

```
[클라이언트]     [백엔드]        [소셜 플랫폼]      [DB]
    |               |                |              |
    |--리다이렉트--->|                |              |
    |               |--인증 요청----->|              |
    |<-로그인 페이지-|                |              |
    |--로그인------->|                |              |
    |               |<-사용자 정보----|              |
    |               |--SocialAccount 조회---------->|
    |               |--OneTimeCode 생성------------>|
    |<-리다이렉트----|                |              |
    |  (?code=xxx)  |                |              |
    |               |                |              |
    |--POST /token/exchange---------->|              |
    |  (code)       |--OneTimeCode 검증------------>|
    |               |--OneTimeCode 삭제------------>|
    |               |--토큰 생성                     |
    |               |--RefreshToken 저장----------->|
    |<-AccessToken (Body)-------------|              |
    |<-RefreshToken (Cookie)----------|              |
```

**주요 특징:**
* URL에 AccessToken 직접 노출 방지 (보안 강화)
* OneTimeCode는 1분 만료, 사용 즉시 DB에서 삭제
* 브라우저 히스토리에 민감 정보 남지 않음

### 소셜 로그인 플로우 (신규 회원)

```
[클라이언트]     [백엔드]        [소셜 플랫폼]      [DB]
    |               |                |              |
    |--리다이렉트--->|                |              |
    |               |--인증 요청----->|              |
    |<-로그인 페이지-|                |              |
    |--로그인------->|                |              |
    |               |<-사용자 정보----|              |
    |               |--SocialAccount 조회 (없음)--->|
    |               |--PendingSocialUser 생성------>|
    |<-리다이렉트----|                |              |
    |  (?token=xxx) |                |              |
    |               |                |              |
    |--추가 정보 입력|                |              |
    |               |                |              |
    |--POST /social/complete--------->|              |
    |  (token + 추가정보)              |              |
    |               |--토큰 검증                     |
    |               |--PendingSocialUser 조회------->|
    |               |--User + SocialAccount 생성---->|
    |               |--PendingSocialUser 삭제------->|
    |               |--토큰 생성                     |
    |               |--RefreshToken 저장----------->|
    |<-AccessToken (Body)-------------|              |
    |<-RefreshToken (Cookie)----------|              |
```

**주요 특징:**
* SOCIAL_SIGNUP_PENDING_TOKEN으로 추가 정보 입력 대기
* 회원가입 완료 시 즉시 로그인 처리
* PendingSocialUser 레코드 삭제로 일회용 보장

### 토큰 갱신 플로우 (RTR)

```
[클라이언트]                [백엔드]                    [DB]
    |                          |                         |
    |--POST /refresh---------->|                         |
    |  (RefreshToken 쿠키)     |--RefreshToken 조회----->|
    |                          |--만료 검증               |
    |                          |--기존 토큰 삭제--------->|
    |                          |--새 토큰 쌍 생성         |
    |                          |--새 RefreshToken 저장--->|
    |<-새 AccessToken (Body)---|                         |
    |<-새 RefreshToken (Cookie)|                         |
```

**주요 특징:**
* Refresh Token Rotation (RTR) 방식
* 기존 RefreshToken 즉시 삭제 후 새 토큰 발급
* 토큰 탈취 감지 가능 (재사용 시 양쪽 모두 무효화)
* Rate Limiting 적용 (10초 내 2회 제한)

---

## 향후 개선 로드맵

본 섹션은 현재 구현된 인증/인가 시스템의 품질, 성능, 보안, 안정성을 향상시키기 위한 개선 계획을 단계별로 제시합니다.

### 단기 계획 (1-3개월)

**목표:** 즉각적인 보안 강화 및 사용자 경험 개선

**1. Redis 기반 토큰 관리**
* **현재 문제:** DB 기반 RefreshToken 및 OneTimeCode 관리로 인한 DB 부하
* **개선 방안:**
  - Redis를 도입하여 RefreshToken, OneTimeCode, EmailVerification 등 임시 데이터 관리
  - TTL 자동 만료로 스케줄러 부담 감소
  - 토큰 조회 성능 향상 (DB → Redis: ~100배 빠름)
* **예상 효과:** 토큰 갱신 API 응답 시간 50% 단축, DB 부하 30% 감소

**2. Rate Limiting 고도화**
* **현재 문제:** 토큰 갱신 엔드포인트만 Rate Limiting 적용
* **개선 방안:**
  - 로그인, 회원가입, 이메일 인증 등 주요 엔드포인트에 Rate Limiting 확대
  - IP + User-Agent + User ID 조합으로 정교한 제한
  - Sliding Window 알고리즘 적용
* **예상 효과:** 무차별 대입 공격(Brute Force) 방어, API 남용 방지

**3. 로그인 시도 횟수 제한 및 계정 잠금**
* **현재 문제:** 무제한 로그인 시도 가능
* **개선 방안:**
  - 5회 실패 시 계정 일시 잠금 (15분)
  - 10회 실패 시 이메일 인증 필요
  - 관리자 알림 기능
* **예상 효과:** 계정 탈취 시도 차단, 보안 사고 조기 감지

**4. 비밀번호 정책 강화**
* **현재 문제:** 최소 8자 이상만 요구
* **개선 방안:**
  - 대소문자, 숫자, 특수문자 조합 필수
  - 최소 10자 이상
  - 이전 비밀번호 재사용 방지 (최근 3개)
  - 비밀번호 강도 측정 (zxcvbn 라이브러리)
* **예상 효과:** 비밀번호 추측 공격 방어력 향상


### 중기 계획 (3-6개월)

**목표:** 고급 보안 기능 및 사용자 편의성 향상

**1. 2FA (Two-Factor Authentication) 도입**
* **개선 방안:**
  - TOTP (Time-based One-Time Password) 지원 (Google Authenticator, Authy)
  - SMS 인증 옵션 제공
  - 백업 코드 생성 (2FA 기기 분실 대비)
  - 신뢰할 수 있는 디바이스 등록 기능
* **예상 효과:** 계정 보안 수준 대폭 향상, 피싱 공격 방어

**2. 디바이스 지문 인식 (Device Fingerprinting)**
* **개선 방안:**
  - 브라우저 지문 수집 (User-Agent, 화면 해상도, 타임존, 플러그인 등)
  - 새로운 디바이스 로그인 시 이메일 알림
  - 의심스러운 디바이스 차단 기능
  - 디바이스별 세션 관리
* **예상 효과:** 비정상 접근 감지, 계정 탈취 조기 발견

**3. 세션 관리 페이지**
* **개선 방안:**
  - 현재 활성 디바이스 목록 표시
  - 디바이스별 마지막 접속 시간, 위치, IP 정보
  - 원격 로그아웃 기능 (특정 디바이스 강제 로그아웃)
  - 모든 디바이스 로그아웃 기능
* **예상 효과:** 사용자가 직접 보안 관리 가능, 투명성 향상

**4. IP 기반 접근 제한 및 지역 차단**
* **개선 방안:**
  - GeoIP 데이터베이스 연동
  - 특정 국가/지역에서의 접근 차단 옵션
  - VPN/Proxy 감지 및 차단
  - 화이트리스트/블랙리스트 관리
* **예상 효과:** 해외 해킹 시도 차단, 지역 기반 보안 정책 적용

**5. 소셜 계정 연동/해제 기능**
* **개선 방안:**
  - 하나의 계정에 여러 소셜 계정 연동
  - 주 로그인 방식 변경 (로컬 ↔ 소셜)
  - 소셜 계정 해제 시 비밀번호 설정 강제
* **예상 효과:** 사용자 편의성 향상, 계정 통합 관리


### 장기 계획 (6-12개월)

**목표:** 엔터프라이즈급 보안 및 확장성 확보

**1. Role 기반 권한 관리 (RBAC) 고도화**
* **개선 방안:**
  - 세분화된 권한 체계 (ROLE_USER, ROLE_ADMIN, ROLE_MODERATOR 등)
  - 리소스별 권한 설정 (READ, WRITE, DELETE)
  - 동적 권한 할당 (관리자 페이지)
  - 권한 상속 및 그룹 관리
* **예상 효과:** 복잡한 권한 요구사항 대응, 관리 효율성 향상

**2. 의심스러운 활동 감지 시스템 (Anomaly Detection)**
* **개선 방안:**
  - 머신러닝 기반 이상 행동 탐지
  - 평소와 다른 시간대/위치 로그인 감지
  - 비정상적인 API 호출 패턴 분석
  - 실시간 알림 및 자동 차단
* **예상 효과:** 제로데이 공격 대응, 보안 사고 예방

**3. 통합 이메일 관리 시스템**
* **개선 방안:**
  - 이메일 템플릿 관리 시스템 (관리자 페이지)
  - 다국어 이메일 지원
  - 이메일 발송 이력 추적
  - 이메일 발송 실패 재시도 로직
  - SendGrid, AWS SES 등 전문 서비스 연동
* **예상 효과:** 이메일 전달률 향상, 관리 편의성 증대

**4. 감사 로그 (Audit Log) 시스템**
* **개선 방안:**
  - 모든 인증/인가 이벤트 기록
  - 사용자 행동 추적 (로그인, 로그아웃, 비밀번호 변경 등)
  - 관리자 작업 로그
  - 로그 검색 및 필터링 기능
  - 규정 준수 (GDPR, ISO 27001) 대응
* **예상 효과:** 보안 사고 분석, 컴플라이언스 충족

**5. 비밀번호 없는 인증 (Passwordless Authentication)**
* **개선 방안:**
  - 매직 링크 로그인 (이메일로 일회용 링크 전송)
  - WebAuthn/FIDO2 지원 (생체 인증, 보안 키)
  - SMS OTP 로그인
* **예상 효과:** 사용자 편의성 극대화, 비밀번호 관련 보안 위험 제거


### 초장기 계획 (12개월 이상)

**목표:** 차세대 인증 시스템 및 글로벌 확장

**1. 분산 인증 시스템 (Distributed Authentication)**
* **개선 방안:**
  - 마이크로서비스 아키텍처 대응
  - OAuth 2.0 Authorization Server 구축
  - OpenID Connect (OIDC) 지원
  - 외부 서비스에 인증 제공 (SSO)
* **예상 효과:** 서비스 확장성 확보, 파트너사 연동 용이

**2. 블록체인 기반 신원 인증 (DID)**
* **개선 방안:**
  - 탈중앙화 신원 증명 (Decentralized Identity)
  - 사용자가 자신의 데이터 완전 통제
  - 개인정보 최소 공개 (Zero-Knowledge Proof)
* **예상 효과:** 프라이버시 보호 극대화, 차세대 인증 표준 선도

**3. AI 기반 보안 위협 대응**
* **개선 방안:**
  - 실시간 위협 인텔리전스 연동
  - 자동화된 보안 패치 및 업데이트
  - 예측적 보안 분석 (Predictive Security Analytics)
  - 자가 치유 시스템 (Self-Healing System)
* **예상 효과:** 보안 운영 자동화, 신속한 위협 대응

**4. 글로벌 확장 대응**
* **개선 방안:**
  - 다중 리전 배포 (Multi-Region Deployment)
  - 지역별 데이터 주권 준수 (Data Residency)
  - CDN 기반 토큰 전달 최적화
  - 글로벌 Rate Limiting 및 DDoS 방어
* **예상 효과:** 전 세계 사용자 대응, 서비스 안정성 향상

**5. 양자 컴퓨팅 대응 암호화**
* **개선 방안:**
  - Post-Quantum Cryptography (PQC) 알고리즘 도입
  - 양자 내성 암호 (Quantum-Resistant Encryption)
  - 하이브리드 암호화 방식 (기존 + 양자 내성)
* **예상 효과:** 미래 보안 위협 선제 대응

---

### 개선 우선순위 매트릭스

| 개선 항목 | 중요도 | 긴급도 | 구현 난이도 | 우선순위 |
|-----------|--------|--------|-------------|----------|
| Redis 도입 | 높음 | 높음 | 중간 | 1 |
| Rate Limiting 확대 | 높음 | 높음 | 낮음 | 2 |
| 로그인 시도 제한 | 높음 | 높음 | 낮음 | 3 |
| 비밀번호 정책 강화 | 중간 | 높음 | 낮음 | 4 |
| 2FA 도입 | 높음 | 중간 | 중간 | 5 |
| 디바이스 지문 인식 | 중간 | 중간 | 중간 | 6 |
| 세션 관리 페이지 | 중간 | 중간 | 낮음 | 7 |
| IP 기반 제한 | 중간 | 낮음 | 중간 | 8 |
| RBAC 고도화 | 높음 | 낮음 | 높음 | 9 |
| 이상 행동 탐지 | 높음 | 낮음 | 높음 | 10 |

---

## 부록

### JWT 토큰 구조

**AccessToken 클레임:**
```json
{
  "userId": 123,
  "email": "user@example.com",
  "type": "ACCESS",
  "iat": 1698825600,
  "exp": 1698826500
}
```

**RefreshToken 클레임:**
```json
{
  "userId": 123,
  "email": "user@example.com",
  "type": "REFRESH",
  "iat": 1698825600,
  "exp": 1700035200
}
```

**EmailVerificationToken 클레임:**
```json
{
  "userId": 123,
  "email": "user@example.com",
  "type": "EMAIL_VERIFICATION",
  "iat": 1698825600,
  "exp": 1698826500
}
```

**SocialSignupPendingToken 클레임:**
```json
{
  "provider": "GOOGLE",
  "providerId": "1234567890",
  "email": "user@gmail.com",
  "name": "홍길동",
  "type": "SOCIAL_SIGNUP_PENDING",
  "iat": 1698825600,
  "exp": 1698826500
}
```

### 쿠키 설정 상세

**RefreshToken 쿠키 속성:**
```
Set-Cookie: refreshToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...;
            HttpOnly;
            Secure;
            SameSite=Strict;
            Max-Age=1209600;
            Path=/
```

**속성 설명:**
* `HttpOnly`: JavaScript 접근 차단 (XSS 방어)
* `Secure`: HTTPS 연결에서만 전송 (MITM 방어)
* `SameSite=Strict`: 크로스 사이트 요청 시 쿠키 미전송 (CSRF 방어)
* `Max-Age=1209600`: 14일 (초 단위)
* `Path=/`: 모든 경로에서 쿠키 전송

### 환경 변수 설정

**application.yml:**
```yaml
jwt:
  secret: ${JWT_SECRET}  # Base64 인코딩된 256비트 이상 키
  access-token-expiration: 900000  # 15분 (밀리초)
  refresh-token-expiration: 1209600000  # 14일 (밀리초)

cookie:
  refresh-token-name: refreshToken
  max-age: 1209600  # 14일 (초)
  http-only: true
  secure: true  # 프로덕션에서 true
  same-site: Strict
  path: /

app:
  frontend:
    base-url: ${FRONTEND_BASE_URL:http://localhost:5050}

spring:
  mail:
    host: ${MAIL_HOST}
    port: ${MAIL_PORT}
    username: ${MAIL_USERNAME}
    password: ${MAIL_PASSWORD}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

**.env 파일 예시:**
```env
JWT_SECRET=your-base64-encoded-secret-key-here
FRONTEND_BASE_URL=http://localhost:5050
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

### Properties 클래스

**JwtProperties:**
```java
@Component
@ConfigurationProperties(prefix = "jwt")
public class JwtProperties {
    private String secret;                    // JWT 서명 키 (Base64)
    private Long accessTokenExpiration;       // 15분 (밀리초)
    private Long refreshTokenExpiration;      // 14일 (밀리초)
}
```

**CookieProperties:**
```java
@Component
@ConfigurationProperties(prefix = "cookie")
public class CookieProperties {
    private String refreshTokenName;          // 쿠키 이름
    private String domain;                    // 쿠키 도메인
    private String path;                      // 쿠키 경로 (/)
    private Integer refreshTokenMaxAge;       // 14일 (초)
    private boolean secure;                   // HTTPS 전용
    private String sameSite;                  // Strict
    private boolean httpOnly;                 // JavaScript 접근 차단
}
```

### 데이터 정리 스케줄러

**DataCleanupScheduler:**
* 만료된 EmailVerification 레코드 삭제: 매일 02:00
* 만료된 PendingSocialUser 레코드 삭제: 매일 02:00
* 만료된 RefreshToken 레코드 삭제: 매일 03:00
* 만료된 OneTimeCode 레코드 삭제: 매 시간

```java
@Scheduled(cron = "0 0 2 * * *")  // 매일 02:00
public void cleanupExpiredEmailVerifications() {
    LocalDateTime now = LocalDateTime.now();
    int deletedCount = emailVerificationRepository.deleteByExpiryDateBefore(now);
    log.info("만료된 이메일 인증 레코드 정리 완료. 삭제된 레코드 수: {}", deletedCount);
}

@Scheduled(fixedRate = 3600000)  // 1시간마다
public void cleanupExpiredOneTimeCodes() {
    LocalDateTime now = LocalDateTime.now();
    int deletedCount = oneTimeCodeRepository.deleteByExpiryDateBefore(now);
    if (deletedCount > 0) {
        log.info("만료된 일회용 코드 정리 완료. 삭제된 코드 수: {}", deletedCount);
    }
}
```

### Enum 클래스

#### Provider (인증 제공자)

```java
public enum Provider {
    LOCAL("로컬", "email", "local"),           // 이메일/비밀번호
    KAKAO("카카오", "https://kauth.kakao.com", "kakao"),
    GOOGLE("구글", "https://accounts.google.com", "google"),
    NAVER("네이버", "https://nid.naver.com", "naver");
}
```

**주요 메서드:**
* `fromRegistrationId(String)`: OAuth2 registrationId로 Provider 조회
* `isLocal()`: 로컬 회원가입 방식인지 확인
* `isSocial()`: 소셜 로그인 방식인지 확인

**비즈니스 규칙:**
* PRIMARY 제공자가 LOCAL이면 비밀번호 필수
* PRIMARY 제공자가 소셜이면 비밀번호 null

#### UserStatus (사용자 계정 상태)

```java
public enum UserStatus {
    ACTIVE("활성"),      // 정상 상태
    INACTIVE("휴면"),    // 1년 미접속 (로그인 시 자동 복구)
    SUSPENDED("정지"),   // 약관 위반 (관리자 승인 필요)
    WITHDRAWN("탈퇴");   // 회원 탈퇴 (복구 불가)
}
```

**주요 메서드:**
* `isActive()`: 활성 상태 확인
* `canLogin()`: 로그인 가능 여부 (ACTIVE, INACTIVE만 가능)
* `canRecover()`: 복구 가능 여부
* `isTerminated()`: 완전 종료 상태 확인

**상태 전환:**
* 회원가입 → ACTIVE
* 1년 미접속 → INACTIVE (휴면)
* 약관 위반 → SUSPENDED (정지)
* 회원 탈퇴 → WITHDRAWN (복구 불가)

#### JobType (직업 유형)

```java
public enum JobType {
    STUDENT("학생"),
    JOB_SEEKER("취업준비생"),
    EMPLOYEE("직장인"),
    SELF_EMPLOYED("자영업자"),
    FREELANCER("프리랜서"),
    HOUSEWIFE("주부"),
    OTHER("기타");  // jobDetail 필수
}
```

**주요 메서드:**
* `requiresDetail()`: OTHER 선택 시 true (jobDetail 필수)
* `fromDisplayName(String)`: 표시명으로 JobType 조회

#### TermsType (약관 종류)

```java
public enum TermsType {
    TERMS_OF_SERVICE("이용약관", true, 1),           // 필수
    PRIVACY_POLICY("개인정보 처리방침", true, 2),    // 필수
    MARKETING_CONSENT("마케팅 수신 동의", false, 3); // 선택
}
```

**주요 메서드:**
* `sorted()`: 표시 순서대로 정렬된 리스트 반환

**법적 요구사항:**
* TERMS_OF_SERVICE: 서비스 이용약관 (필수)
* PRIVACY_POLICY: 개인정보 처리방침 (필수, 개인정보보호법 제39조의8)
* MARKETING_CONSENT: 마케팅 수신 동의 (선택, 정보통신망법 제50조)

---

## 참고 자료 (References)

* [RFC 7519 - JSON Web Token (JWT)](https://datatracker.ietf.org/doc/html/rfc7519)
* [RFC 6749 - OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
* [OWASP - Cross Site Scripting (XSS)](https://owasp.org/www-community/attacks/xss/)
* [OWASP - Cross-Site Request Forgery (CSRF)](https://owasp.org/www-community/attacks/csrf)
* [Spring Security Documentation](https://docs.spring.io/spring-security/reference/index.html)
* [Spring Security OAuth2 Client](https://docs.spring.io/spring-security/reference/servlet/oauth2/client/index.html)

---

변경 이력 (Change Log)

| 버전 | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|--------|----------------|
| v1.0 | 2025.11.01 | 왕택준 | 최초 작성 |
