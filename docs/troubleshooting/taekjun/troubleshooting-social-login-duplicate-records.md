# 트러블슈팅: 소셜 로그인 중복 레코드 발생 삭제 로직 추가로 해결

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.29

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Resolved

---

## 대상 독자 (Intended Audience)

* **전체 개발자**: 소셜 로그인 중복 처리 로직을 이해해야 하는 팀원
* **Tech Lead**: 사용자 인증 흐름과 데이터 무결성 관리 책임자
* **신규 합류자**: 소셜 회원가입 프로세스를 학습해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

소셜 로그인 시도 중 회원가입을 완료하지 않고 재시도하면 `pending_social_users` 테이블에 중복 레코드가 생성되어 데이터베이스 무결성 문제 발생. 새 레코드 저장 전 기존 레코드를 삭제하는 로직을 추가하여 해결. `unique index (provider, provider_id)`로 중복을 방지할 수 있었으나, 재시도 시나리오를 고려해 삭제 방식 선택.

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

소셜 로그인(Google, Kakao, Naver)을 통한 신규 회원가입 프로세스에서 사용자가 중간에 이탈 후 재시도할 경우, `pending_social_users` 테이블에 동일한 `provider`와 `provider_id`를 가진 레코드가 중복으로 생성되는 문제 발생. 이는 데이터베이스 무결성을 해치고, 향후 유니크 제약 조건 추가 시 마이그레이션 실패 가능성 존재.

---

## 1. 문제 현상

### 1-1. 주요 증상
* **문제**: 소셜 로그인 재시도 시 `pending_social_users` 테이블에 중복 레코드 생성
* **증상**: 동일 사용자의 여러 `pending_token`이 DB에 존재
* **상황**: 
  - 1차 시도: 소셜 로그인 → 약관 동의 페이지 → 중간 이탈
  - 2차 시도: 동일 계정으로 재로그인 → 새 레코드 생성

### 1-2. 에러 정보
* **에러 메시지**: 명시적인 에러는 없음 (silent failure)
* **재현 조건**: 
  1. 소셜 로그인 성공
  2. 회원가입 완료 전 페이지 종료
  3. 동일 계정으로 재로그인
* **빈도**: 재시도 시마다 발생 (100%)

### 1-3. 환경 정보
* **운영체제**: Ubuntu 20.04 (개발 환경), MacOS (로컬 환경)
* **데이터베이스**: MariaDB 10.6
* **프레임워크**: Spring Boot 3.x, JPA
* **관련 버전**: Java 21

### 1-4. 데이터베이스 상태
```sql
-- 중복 레코드 예시
SELECT id, provider, provider_id, used, created_at 
FROM pending_social_users 
WHERE provider = 'GOOGLE' AND provider_id = '105952090000440291334';

+----+----------+------------------------+------+---------------------+
| id | provider | provider_id            | used | created_at          |
+----+----------+------------------------+------+---------------------+
|  1 | GOOGLE   | 105952090000440291334  | 0    | 2025-10-29 14:10:00 |
|  2 | GOOGLE   | 105952090000440291334  | 0    | 2025-10-29 14:15:00 |
|  3 | GOOGLE   | 105952090000440291334  | 0    | 2025-10-29 14:20:00 |
+----+----------+------------------------+------+---------------------+
```

---

## 2. 원인 분석

### 2-1. 1차 분석
`AuthService.processOAuth2User()` 메서드에서 신규 사용자 판단 시 `pending_social_users` 테이블 중복 체크 로직 부재

### 2-2. 2차 분석
기존 코드 구조:
```java
// 신규 회원인 경우
if (socialAccountOpt.isEmpty()) {
    // JWT 토큰 생성
    String pendingToken = jwtTokenProvider.generateSocialSignupPendingToken(...);
    
    // ❌ 기존 레코드 체크/삭제 없이 바로 저장
    PendingSocialUser pendingUser = PendingSocialUser.builder()
            .pendingToken(pendingToken)
            .provider(provider)
            .providerId(userInfo.providerId())
            .email(userInfo.email())
            .name(userInfo.name())
            .expiryDate(jwtTokenProvider.getExpiryDateTimeFromToken(pendingToken))
            .build();
    pendingSocialUserRepository.save(pendingUser); // ← 중복 생성!
}
```

### 2-3. 근본 원인

**문제점**:
1. **중복 체크 로직 부재**: 동일 `provider + provider_id` 조합의 기존 레코드 확인 없음
2. **유니크 제약 조건 없음**: 데이터베이스 레벨에서 중복 방지 메커니즘 부재
3. **재시도 시나리오 미고려**: 사용자가 회원가입을 완료하지 않고 재시도하는 경우를 고려하지 않음

**기술적 배경**:
- `pending_social_users` 테이블은 임시 저장소로 설계
- 회원가입 완료 시 `users` 및 `social_accounts` 테이블로 이동
- 미완료 레코드는 스케줄러로 정리하지만, 재시도 시 중복 생성 가능

---

## 3. 디버깅 과정

### 3-1. 사용한 디버깅 기법
- MariaDB 쿼리를 통한 데이터 확인
- Spring Boot 로그 분석
- Postman으로 소셜 로그인 API 반복 테스트
- JPA Auditing 타임스탬프 확인

### 3-2. 핵심 문제 발견 과정

**1단계: 문제 재현**
```bash
# 시나리오 재현
1. Chrome 시크릿 모드로 Google 로그인
2. 약관 동의 페이지까지 진행
3. 브라우저 종료
4. 다시 시크릿 모드로 동일 계정 로그인
5. DB 확인
```

**결과**: 매 재시도마다 새로운 레코드 생성 확인

**2단계: 코드 추적**
```java
// AuthService.java - processOAuth2User() 메서드
Optional<SocialAccount> socialAccountOpt = socialAccountRepository
        .findByProviderAndProviderId(provider, userInfo.providerId());

if (socialAccountOpt.isPresent()) {
    // 기존 회원 처리 ✅
} else {
    // 신규 회원 처리
    // ❌ 여기서 pending_social_users 중복 체크 없음!
    pendingSocialUserRepository.save(pendingUser);
}
```

**결과**: 중복 체크 로직 부재 확인

**3단계: 데이터베이스 스키마 확인**
```sql
SHOW CREATE TABLE pending_social_users;
-- ❌ UNIQUE INDEX (provider, provider_id) 없음!
```

**결과**: 데이터베이스 레벨 중복 방지 메커니즘 부재

---

## 4. 해결 과정

### 4-1. 시도했던 해결책들

**A안: 유니크 제약 조건 추가 (보류)**
```sql
ALTER TABLE pending_social_users 
ADD UNIQUE INDEX idx_provider_id (provider, provider_id);
```

**문제점**:
- 기존 중복 데이터 정리 필요
- 재시도 시 INSERT 실패로 에러 발생
- 에러 핸들링 복잡도 증가

**B안: INSERT 전 기존 레코드 삭제 (채택)**
```java
// 1. 기존 레코드 삭제
pendingSocialUserRepository.deleteByProviderAndProviderId(provider, providerId);

// 2. 새 레코드 저장
pendingSocialUserRepository.save(pendingUser);
```

**장점**:
- 구현 간단
- 재시도 시나리오 자연스럽게 처리
- 데이터베이스 스키마 변경 불필요

### 4-2. 최종 해결책

#### Step 1: Repository에 삭제 메서드 추가

**PendingSocialUserRepository.java**
```java
/**
 * 특정 provider + providerId의 기존 레코드를 모두 삭제합니다.
 * 새로운 소셜 로그인 시도 전에 이전 미완료 레코드를 정리합니다.
 * 
 * @param provider 소셜 제공자
 * @param providerId 소셜 플랫폼 고유 ID
 */
@Modifying
@Query("DELETE FROM PendingSocialUser psu WHERE psu.provider = :provider AND psu.providerId = :providerId")
void deleteByProviderAndProviderId(@Param("provider") Provider provider, @Param("providerId") String providerId);
```

#### Step 2: Service에서 삭제 로직 호출

**AuthService.java**
```java
public SocialCallbackResponseDto processOAuth2User(String registrationId, OAuth2User oAuth2User) {
    Provider provider = Provider.fromRegistrationId(registrationId);
    SocialUserInfo userInfo = extractSocialUserInfo(provider, oAuth2User);

    Optional<SocialAccount> socialAccountOpt = socialAccountRepository
            .findByProviderAndProviderId(provider, userInfo.providerId());

    if (socialAccountOpt.isPresent()) {
        // 기존 회원 처리
        User user = socialAccountOpt.get().getUser();
        user.updateLastLogin();
        String oneTimeCode = generateOneTimeCodeInDB(user.getId());
        
        return SocialCallbackResponseDto.builder()
                .isNewUser(false)
                .oneTimeCode(oneTimeCode)
                .email(user.getEmail())
                .name(user.getName())
                .provider(provider)
                .build();
    } else {
        // ✅ 신규 회원 처리 - 기존 레코드 삭제 후 저장
        log.info("신규 소셜 사용자 확인 ({}). Email: {}", provider, LogMaskingUtil.maskEmail(userInfo.email()));

        // 1. 기존 미완료 레코드 삭제
        pendingSocialUserRepository.deleteByProviderAndProviderId(provider, userInfo.providerId());
        log.debug("기존 pending_social_users 레코드 정리 완료. Provider: {}, ProviderId: {}", 
                provider, LogMaskingUtil.maskToken(userInfo.providerId()));

        // 2. JWT 토큰 생성
        String pendingToken = jwtTokenProvider.generateSocialSignupPendingToken(
                provider.name(), userInfo.providerId(), userInfo.email(), userInfo.name());

        // 3. 새 레코드 저장
        PendingSocialUser pendingUser = PendingSocialUser.builder()
                .pendingToken(pendingToken)
                .provider(provider)
                .providerId(userInfo.providerId())
                .email(userInfo.email())
                .name(userInfo.name())
                .expiryDate(jwtTokenProvider.getExpiryDateTimeFromToken(pendingToken))
                .build();
        pendingSocialUserRepository.save(pendingUser);

        log.info("신규 소셜 사용자 대기 토큰 생성 완료. Email: {}, Provider: {}",
                LogMaskingUtil.maskEmail(userInfo.email()), provider);

        return SocialCallbackResponseDto.builder()
                .isNewUser(true)
                .socialSignupPendingToken(pendingToken)
                .email(userInfo.email())
                .name(userInfo.name())
                .provider(provider)
                .build();
    }
}
```

**성공 이유**:
1. **재시도 시나리오 완벽 대응**: 기존 레코드를 자동으로 정리
2. **데이터 무결성 보장**: 항상 최신 레코드만 유지
3. **코드 간결성**: 복잡한 에러 핸들링 불필요
4. **트랜잭션 안정성**: `@Modifying` 쿼리로 원자적 삭제

---

## 5. 테스트 검증

### 5-1. 테스트 방법

#### 테스트 시나리오 1: 정상 회원가입
```
1. Google 로그인
2. 약관 동의
3. 추가 정보 입력
4. 회원가입 완료
→ ✅ 예상: pending_social_users 레코드 삭제, users 및 social_accounts 생성
```

#### 테스트 시나리오 2: 중간 이탈 후 재시도
```
1. Google 로그인
2. 약관 동의 페이지까지 진행
3. 브라우저 종료
4. 다시 동일 계정으로 로그인
→ ✅ 예상: 기존 레코드 삭제 후 새 레코드 생성
```

#### 테스트 시나리오 3: 여러 번 재시도
```
1~3. 위 과정 5회 반복
→ ✅ 예상: 항상 최신 레코드 1개만 존재
```

### 5-2. 검증 결과

#### 변경 전
```sql
SELECT COUNT(*) FROM pending_social_users 
WHERE provider = 'GOOGLE' AND provider_id = '105952090000440291334';
-- 결과: 5 (재시도 횟수만큼 증가)
```

#### 변경 후
```sql
SELECT COUNT(*) FROM pending_social_users 
WHERE provider = 'GOOGLE' AND provider_id = '105952090000440291334';
-- 결과: 1 (항상 최신 레코드만 존재)
```

#### 로그 확인
```
2025-10-29T14:25:30.123  INFO  --- 신규 소셜 사용자 확인 (GOOGLE). Email: w***@naver.com
2025-10-29T14:25:30.124 DEBUG  --- 기존 pending_social_users 레코드 정리 완료. Provider: GOOGLE, ProviderId: 105***334
2025-10-29T14:25:30.135  INFO  --- 신규 소셜 사용자 대기 토큰 생성 완료. Email: w***@naver.com, Provider: GOOGLE
```

**성공률**: 10회 테스트 모두 성공 (100%)

---

## 6. 성능 영향 분석

### 6-1. 변경 전후 비교

**측정 항목**:
- **소셜 로그인 응답 시간**: 변화 없음 (~200ms)
- **데이터베이스 쿼리 수**: +1 (DELETE 쿼리 추가)
- **중복 레코드 발생률**: 100% → 0%

### 6-2. 리소스 사용량

**데이터베이스**:
- **DELETE 쿼리 성능**: < 1ms (인덱스 활용)
- **저장 공간**: 중복 레코드 제거로 약간 감소
- **트랜잭션 오버헤드**: 무시 가능 수준

**애플리케이션**:
- **메모리**: 변화 없음
- **CPU**: 미미한 증가 (DELETE 쿼리 실행)

### 6-3. 사용자 경험 영향

**긍정적 영향**:
- 재시도 시에도 정상적으로 회원가입 진행 가능
- 데이터 무결성 보장으로 향후 문제 예방

**부정적 영향**:
- 없음 (응답 시간 변화 없음)

---

## 7. 관련 이슈 및 예방책

### 7-1. 유사한 함정 회피 방법

**위험한 패턴**:
```java
// ❌ 중복 체크 없이 바로 저장
repository.save(newRecord);
```

**안전한 패턴**:
```java
// ✅ 기존 레코드 삭제 후 저장
repository.deleteByUniqueKey(uniqueKey);
repository.save(newRecord);
```

또는

```java
// ✅ upsert 패턴 사용
Optional<Record> existing = repository.findByUniqueKey(uniqueKey);
if (existing.isPresent()) {
    existing.get().update(newData);
} else {
    repository.save(newRecord);
}
```

### 7-2. 코드 리뷰 체크포인트

- [ ] 임시 데이터 저장 시 중복 가능성 확인
- [ ] 재시도 시나리오 고려 여부 확인
- [ ] 유니크 제약 조건 또는 삭제 로직 존재 확인
- [ ] 트랜잭션 경계 적절성 검토

### 7-3. 추가 예방 방법

#### 데이터베이스 레벨
```sql
-- 향후 고려: 유니크 인덱스 추가 (선택적)
ALTER TABLE pending_social_users 
ADD UNIQUE INDEX idx_unique_social_pending (provider, provider_id);
```

#### 모니터링
```java
// 중복 레코드 감지 스케줄러
@Scheduled(cron = "0 0 * * * *") // 매 시간
public void detectDuplicates() {
    List<Object[]> duplicates = pendingSocialUserRepository
            .findDuplicateRecords();
    
    if (!duplicates.isEmpty()) {
        log.warn("중복 레코드 감지: {} 건", duplicates.size());
        // 알림 발송 또는 자동 정리
    }
}
```

#### 테스트 자동화
```java
@Test
void testSocialLoginRetry_shouldNotCreateDuplicates() {
    // Given
    String providerId = "test-provider-id";
    
    // When
    authService.processOAuth2User("google", mockOAuth2User);
    authService.processOAuth2User("google", mockOAuth2User); // 재시도
    
    // Then
    long count = pendingSocialUserRepository
            .countByProviderAndProviderId(Provider.GOOGLE, providerId);
    
    assertThat(count).isEqualTo(1);
}
```

---

## 8. 결론 및 배운 점

### 8-1. 주요 성과

1. **데이터 무결성 보장**: 중복 레코드 발생률 0% 달성
2. **재시도 시나리오 완벽 대응**: 사용자 경험 개선
3. **코드 품질 향상**: 명확한 의도를 가진 삭제 로직 추가
4. **문서화**: 트러블슈팅 과정 및 해결책 체계적 정리

### 8-2. 기술적 학습

**JPA @Modifying 쿼리**:
- 벌크 삭제/업데이트 작업에 적합
- `@Transactional`과 함께 사용 필수
- 영속성 컨텍스트 자동 비워짐 (clearAutomatically = true 옵션)

**임시 데이터 관리 전략**:
- 재시도 가능성을 항상 고려
- 유니크 제약 조건 vs 삭제 로직 트레이드오프 이해
- 스케줄러를 통한 만료 데이터 정리와 병행

**소셜 로그인 프로세스**:
- OAuth2 인증 후 추가 정보 입력 단계 분리
- 중간 이탈 시나리오 중요성 인식
- 토큰 기반 임시 저장소 패턴 이해

### 8-3. 프로세스 개선

**코드 리뷰 체크리스트 추가**:
- [ ] 임시 데이터 저장 로직에 중복 방지 메커니즘 존재 확인
- [ ] 재시도 시나리오 테스트 케이스 작성 확인
- [ ] 데이터베이스 제약 조건 문서화 확인

**테스트 전략 강화**:
- 정상 케이스뿐만 아니라 재시도/중단 시나리오 필수 테스트
- 데이터베이스 상태 검증 테스트 추가
- 통합 테스트에서 실제 DB 확인

### 8-4. 장기적 개선 방향

**데이터베이스 스키마 개선**:
- 유니크 제약 조건 추가 검토 (중복 방지 강화)
- 복합 인덱스 최적화 (provider, provider_id)

**모니터링 강화**:
- `pending_social_users` 테이블 크기 모니터링
- 회원가입 완료율 대시보드 추가
- 중복 레코드 감지 알림 시스템 구축

**스케줄러 최적화**:
- 만료된 레코드 자동 정리 주기 조정
- 미사용 토큰 통계 수집 및 분석

**사용자 경험 개선**:
- 회원가입 진행 상태 저장 (localStorage)
- 중단 지점부터 이어서 진행 가능하도록 개선

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 담당자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.29 | 왕택준 | 최초 작성 - 소셜 로그인 중복 레코드 문제 해결 |
