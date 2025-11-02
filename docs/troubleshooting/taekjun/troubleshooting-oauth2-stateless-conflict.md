# 트러블슈팅: OAuth2 로그인 실패 STATELESS 환경에서 HttpSessionOAuth2AuthorizationRequestRepository 설정으로 해결

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.25

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 개발자**: JWT STATELESS 환경에서 OAuth2 클라이언트 구현 시 참고해야 하는 팀원
* **Tech Lead**: Spring Security 설정과 OAuth2 state 파라미터 보안 정책 수립에 활용하는 책임자
* **신규 합류자**: OAuth 2.0 Authorization Code Grant Flow와 CSRF 방어 메커니즘을 학습해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

소셜 로그인 시도 후 콜백 URL로 리다이렉트될 때 401 Unauthorized 에러 또는 /login?error 페이지로 이동하는 문제가 발생했습니다. 원인은 JWT 인증을 위해 설정한 SessionCreationPolicy.STATELESS 정책과 CSRF 방어를 위해 세션에 state 파라미터를 저장해야 하는 OAuth2 프로토콜의 요구사항이 충돌했기 때문입니다. SecurityConfig의 oauth2Login() 설정에 HttpSessionOAuth2AuthorizationRequestRepository를 명시적으로 지정하여 OAuth2 인증 과정에서만 일시적으로 세션을 사용하도록 허용함으로써 문제를 해결했습니다.

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

JWT 기반 STATELESS 인증 시스템과 OAuth2 소셜 로그인의 통합 과정에서 두 인증 방식의 근본적인 설계 철학 차이로 인한 충돌이 발생했습니다. OAuth 2.0 표준의 보안 요구사항과 Spring Security의 세션 정책 간의 균형점을 찾아야 하는 복잡한 상황이었습니다.

---

## 1. 문제 현상

### 1-1. 주요 증상
* **문제**: Google, Kakao, Naver 소셜 로그인 시도 후 인증 코드를 포함한 콜백 URL로 돌아온 직후 인증 실패
* **증상**: /login?error 페이지로 리다이렉션되거나 최종적으로 401 Unauthorized 에러 발생
* **상황**: 모든 소셜 로그인 프로바이더에서 동일하게 발생

### 1-2. 에러 정보
* **에러 메시지**: 명시적인 에러 메시지는 없었으나 DEBUG 로그에 `Redirecting to /login?error` 기록
* **재현 조건**: SecurityConfig에 sessionCreationPolicy(SessionCreationPolicy.STATELESS)가 설정된 상태에서 소셜 로그인 시도
* **빈도**: 100% 발생

### 1-3. 환경 정보
* **프레임워크**: Spring Boot 3.x, Spring Security 6.x
* **관련 버전**: spring-boot-starter-oauth2-client 3.x
* **인증 방식**: JWT 기반 STATELESS

**문제 발생 플로우**:
```
1. 사용자가 소셜 로그인 버튼 클릭
2. /oauth2/authorization/{provider}로 리다이렉트
3. 외부 OAuth 서버에서 인증 완료
4. /login/oauth2/code/{provider}로 콜백
5. 여기서 인증 실패 → /login?error로 리다이렉트
6. 최종적으로 401 Unauthorized 응답
```

---

## 2. 원인 분석

### 2-1. 1차 분석
콜백 URL이 permitAll()에 등록되어 있음에도 401 에러가 발생한다는 것은 Spring Security의 OAuth2 처리 필터 체인 내부에서 인증이 실패했음을 의미

### 2-2. 2차 분석
OAuth 2.0 Authorization Code Grant Flow의 보안 메커니즘 분석:
1. 클라이언트가 인증 요청 시 임의의 state 값을 생성하여 세션에 저장
2. 인증 서버가 콜백 시 이 state 값을 그대로 반환
3. 클라이언트는 콜백으로 받은 state와 세션에 저장된 state 비교하여 CSRF 공격 방어

### 2-3. 근본 원인
**문제점**:
- SecurityConfig에 설정된 SessionCreationPolicy.STATELESS 때문에 서버가 HTTP 세션을 생성하거나 사용하지 않음
- OAuth2 모듈이 1단계에서 state 값을 세션에 저장하지 못함
- 3단계에서 콜백으로 받은 state 값을 비교할 대상이 없어 CSRF 공격으로 간주하고 인증 실패

**기술적 배경**:
```java
// 문제가 된 설정
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
        .sessionManagement(session -> 
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 세션 사용 금지
        .oauth2Login(oauth2 -> oauth2
            .successHandler(oAuth2AuthenticationSuccessHandler)
        ) // state 저장을 위한 세션 필요
        .build();
}

// OAuth2 내부 동작 (의사코드)
// 1단계: 인증 요청 시
String state = generateRandomState();
session.setAttribute("oauth2_state", state); // STATELESS에서 실패
redirectToProvider(authUrl + "?state=" + state);

// 3단계: 콜백 처리 시  
String callbackState = request.getParameter("state");
String sessionState = session.getAttribute("oauth2_state"); // null 반환
if (!Objects.equals(callbackState, sessionState)) {
    throw new OAuth2AuthenticationException("State mismatch"); // 여기서 실패
}
```

---

## 3. 디버깅 과정

### 3-1. 사용한 디버깅 기법
- Spring Security DEBUG 로그 활성화
- OAuth2 인증 플로우 단계별 추적
- 브라우저 개발자 도구를 통한 요청/응답 분석
- Spring Security 필터 체인 동작 분석

### 3-2. 핵심 문제 발견 과정

**1단계: 콜백 URL 접근성 확인**
```java
// SecurityConfig 설정 확인
.authorizeHttpRequests(auth -> auth
    .requestMatchers("/login/oauth2/code/**").permitAll() // 정상 설정됨
)
```

**결과**: URL 접근 권한은 정상, 내부 처리에서 문제 발생

**2단계: OAuth2 내부 로그 분석**
```
DEBUG o.s.s.o.c.w.OAuth2AuthorizationRequestRedirectFilter : Authorization request
DEBUG o.s.s.o.c.w.OAuth2LoginAuthenticationFilter : Authentication failed: State mismatch
```

**결과**: state 파라미터 불일치로 인한 인증 실패 확인

**3단계: 세션 정책과 OAuth2 요구사항 충돌 분석**
```java
// STATELESS 정책 확인
sessionCreationPolicy(SessionCreationPolicy.STATELESS)

// OAuth2에서 필요한 세션 저장소
OAuth2AuthorizationRequestRepository<OAuth2AuthorizationRequest> repository
```

**결과**: 세션 정책 충돌이 근본 원인임을 확인

**4단계: Spring Security OAuth2 소스 코드 분석**
```java
// DefaultOAuth2AuthorizationRequestResolver.java
public OAuth2AuthorizationRequest resolve(HttpServletRequest request) {
    // state 생성 후 세션에 저장 시도
    String state = this.stateGenerator.generateKey();
    // HttpSessionOAuth2AuthorizationRequestRepository 사용
}
```

**결과**: 명시적인 AuthorizationRequestRepository 설정 필요성 확인

---

## 4. 해결 과정

### 4-1. 시도했던 해결책들

**A안: 세션 정책을 IF_REQUIRED로 변경 (실패)**
```java
.sessionManagement(session -> 
    session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
```
- 소셜 로그인은 성공했지만 JWT 기반 API 서버라는 핵심 설계 원칙 위배
- STATELESS 아키텍처의 장점 상실

**B안: 쿠키 기반 AuthorizationRequestRepository 사용 고려 (검토 후 보류)**
```java
@Bean
public OAuth2AuthorizationRequestRepository<OAuth2AuthorizationRequest> 
    cookieAuthorizationRequestRepository() {
    return new CookieOAuth2AuthorizationRequestRepository();
}
```
- 구현 복잡도 증가
- 추가 보안 고려사항 발생

### 4-2. 최종 해결책

SecurityConfig의 oauth2Login() 설정에서 OAuth2 인증 과정에서만 HTTP 세션을 사용하도록 명시적으로 지정

```java
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
        .sessionManagement(session -> 
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 전체는 STATELESS 유지
        .oauth2Login(oauth2 -> oauth2
            .authorizationEndpoint(auth -> auth
                .authorizationRequestRepository(
                    new HttpSessionOAuth2AuthorizationRequestRepository()) // OAuth2에서만 세션 사용
            )
            .successHandler(oAuth2AuthenticationSuccessHandler)
        )
        .build();
}
```

**성공 이유**:
- 전체 애플리케이션은 STATELESS 정책 유지
- OAuth2 인증 과정에서만 일시적으로 세션 사용 허용
- state 파라미터의 안전한 저장 및 검증 가능
- Spring Security의 표준적인 STATELESS + OAuth2 통합 방법

---

## 5. 테스트 검증

### 5-1. 테스트 방법
- Google, Kakao, Naver 각 소셜 로그인 전체 플로우 테스트
- 로그인 성공 후 JWT 토큰 발급 확인
- 일반 API 호출 시 STATELESS 동작 확인

### 5-2. 검증 결과
* **변경 전**: 모든 소셜 로그인에서 state mismatch로 인증 실패 (100%)
* **변경 후**: 모든 소셜 로그인 성공적으로 완료 (100% 성공)

**성공 테스트 케이스**:
```bash
# Google 소셜 로그인
1. GET /oauth2/authorization/google → 302 redirect to Google
2. Google 인증 완료 → 302 redirect to /login/oauth2/code/google?code=...&state=...
3. 서버에서 state 검증 성공 → JWT 토큰 발급
4. 클라이언트로 리다이렉트 with tokens

# Kakao 소셜 로그인
1. GET /oauth2/authorization/kakao → 302 redirect to Kakao
2. Kakao 인증 완료 → 302 redirect to /login/oauth2/code/kakao?code=...&state=...
3. 서버에서 state 검증 성공 → JWT 토큰 발급
4. 클라이언트로 리다이렉트 with tokens

# JWT API 호출 (STATELESS 확인)
Authorization: Bearer {accessToken}
→ 세션 없이 토큰만으로 인증 성공
```

---

## 6. 성능 영향 분석

### 6-1. 변경 전후 비교

**측정 항목**:
- 소셜 로그인 성공률: 0% → 100%
- 일반 API 성능: 변화 없음 (여전히 STATELESS)
- 메모리 사용량: OAuth2 인증 시에만 임시 세션 생성으로 미미한 증가

### 6-2. 리소스 사용량
- **메모리**: OAuth2 인증 중에만 일시적으로 세션 생성 (평소 시간의 < 1%)
- **CPU**: 세션 생성/삭제 오버헤드 무시 가능
- **네트워크**: 변화 없음

### 6-3. 사용자 경험 영향
소셜 로그인이 정상적으로 작동하게 되어 사용자 접근성 대폭 개선

---

## 7. 관련 이슈 및 예방책

### 7-1. 유사한 함정 회피 방법

**위험한 패턴**:
- STATELESS JWT 서버에 별도 고려 없이 OAuth2 클라이언트 의존성 추가
- OAuth 2.0의 state 파라미터 보안 메커니즘에 대한 이해 부족
- Spring Security 세션 정책과 OAuth2 요구사항 간의 충돌 간과

**안전한 패턴**:
- STATELESS 환경에서 OAuth2 구현 시 state 파라미터 처리 방식 반드시 커스터마이징
- HttpSessionOAuth2AuthorizationRequestRepository 또는 CookieOAuth2AuthorizationRequestRepository 명시적 설정
- OAuth 2.0 보안 모범 사례 준수

### 7-2. 코드 리뷰 체크포인트
- [ ] SessionCreationPolicy.STATELESS와 OAuth2 클라이언트 동시 사용 시 충돌 여부 확인
- [ ] OAuth2AuthorizationRequestRepository 명시적 설정 여부 검증
- [ ] 소셜 로그인 전체 플로우 테스트 포함 여부
- [ ] state 파라미터 보안 검증 로직 확인

### 7-3. 추가 예방 방법
- OAuth 2.0 표준 및 보안 고려사항 팀 교육
- STATELESS + OAuth2 통합 패턴 문서화
- 소셜 로그인 통합 테스트 자동화

```java
// 표준 STATELESS + OAuth2 설정 템플릿
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
        .sessionManagement(session -> 
            session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .oauth2Login(oauth2 -> oauth2
            .authorizationEndpoint(auth -> auth
                .authorizationRequestRepository(
                    new HttpSessionOAuth2AuthorizationRequestRepository()))
            .successHandler(customSuccessHandler)
            .failureHandler(customFailureHandler)
        )
        .build();
}
```

---

## 8. 결론 및 배운 점

### 8-1. 주요 성과
1. **소셜 로그인 기능 완전 복구**: 모든 OAuth2 프로바이더에서 정상 동작
2. **아키텍처 일관성 유지**: STATELESS 원칙을 훼손하지 않으면서 OAuth2 통합
3. **보안 수준 향상**: OAuth 2.0 표준의 CSRF 방어 메커니즘 정상 작동

### 8-2. 기술적 학습

**OAuth 2.0 state 파라미터의 중요성**:
- CSRF 공격 방어를 위한 핵심 메커니즘
- 클라이언트와 서버 간의 요청-응답 매칭을 통한 보안 강화
- 세션이나 쿠키와 같은 상태 저장소 필수 요구

**Spring Security 커스터마이징**:
- SecurityConfig의 다양한 DSL 메서드를 통한 세밀한 제어 가능
- 서로 다른 인증 방식 간의 충돌 해결 방법
- 프레임워크 기본 동작과 커스텀 요구사항 간의 균형점 찾기

**JWT와 OAuth2의 통합 설계**:
- STATELESS 아키텍처와 상태 기반 OAuth2의 조화
- 보안과 성능 간의 트레이드오프 고려
- 하이브리드 인증 시스템의 설계 원칙

### 8-3. 프로세스 개선

**인증 시스템 개발 체크리스트에 추가**:
- [ ] 세션 정책과 인증 방식 간의 호환성 검증
- [ ] OAuth2 state 파라미터 처리 방식 명시적 설정
- [ ] 모든 소셜 로그인 프로바이더 전체 플로우 테스트
- [ ] STATELESS 아키텍처 원칙 준수 여부 확인

### 8-4. 장기적 개선 방향

**보안 강화**:
- CookieOAuth2AuthorizationRequestRepository 도입 고려 (세션 완전 제거)
- OAuth2 토큰 저장 방식 개선 (HttpOnly 쿠키 vs localStorage)
- PKCE (Proof Key for Code Exchange) 적용 검토

**모니터링 및 분석**:
- 소셜 로그인 성공률 메트릭 수집
- OAuth2 인증 단계별 성능 모니터링
- 보안 이벤트 (state mismatch 등) 알림 설정

**아키텍처 발전**:
- 마이크로서비스 환경에서의 OAuth2 토큰 공유 전략
- API Gateway를 통한 중앙화된 인증 처리
- OAuth2 리소스 서버와 인증 서버 분리 고려

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 담당자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.25 | 왕택준 | 최초 작성 |
