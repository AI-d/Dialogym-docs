# JavaDoc 작성 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.10

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: Java/Spring 코드에 JavaDoc 주석을 작성하는 담당자
* **풀스택 개발자**: 백엔드 코드에 타입 정보와 설명을 추가하여 문서화하는 담당자
* **신규 합류자**: JavaDoc 작성 규칙을 처음 학습하고 팀의 코드 문서화 표준을 따라야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 프로젝트의 Java 코드에 JavaDoc 주석을 작성하는 표준을 정의합니다.
JavaDoc은 클래스, 메서드, 필드에 대한 설명을 제공하여 코드 가독성과 유지보수성을 향상시킵니다.
모든 public 클래스와 public 메서드에는 JavaDoc 주석이 필수입니다.
주석은 간결하고 명확하게 작성하며, 예외 상황은 @throws 태그로 명시합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [JavaDoc 기본 구조](#javadoc-기본-구조)
3. [주요 태그](#주요-태그)
4. [클래스 문서화](#클래스-문서화)
5. [메서드 문서화](#메서드-문서화)
6. [필드 문서화](#필드-문서화)
7. [작성 원칙](#작성-원칙)

---

## 문서 개요 (Overview)

본 문서는 팀 내 Java 코드의 일관된 문서화를 위해 작성되었습니다.

코드 리뷰 과정에서 클래스의 목적, 메서드의 역할, 매개변수의 의미를 이해하는 데 시간이 소요되는 문제가 발생했습니다.
JavaDoc 주석을 표준화하여 코드 자체가 명세서 역할을 할 수 있도록 하고, IDE의 자동완성 기능을 활용할 수 있도록 합니다.

본 가이드는 Swagger와 연계하여 API 명세서를 자동 생성하는 데 활용됩니다.

---

## JavaDoc 기본 구조

JavaDoc 주석은 `/**`로 시작하고 `*/`로 끝나며, 클래스나 메서드 정의 바로 위에 작성합니다.

```java
/**
 * 클래스나 메서드에 대한 설명을 작성합니다.
 *
 * @param name 매개변수 설명
 * @return 반환 값 설명
 */
public boolean exampleMethod(String name) {
    return true;
}
```

---

## 주요 태그

### @param

메서드의 매개변수를 설명합니다.

**형식:**
```java
@param 매개변수명 설명
```

**예시:**
```java
/**
 * 사용자 정보를 조회합니다.
 *
 * @param userId 사용자 ID
 * @param includeProfile 프로필 정보 포함 여부
 * @return 사용자 정보 객체
 */
public User getUser(String userId, boolean includeProfile) {
    // ...
}
```

---

### @return

메서드의 반환 값을 설명합니다.

**형식:**
```java
@return 설명
```

**예시:**
```java
/**
 * 두 숫자의 합을 계산합니다.
 *
 * @param a 첫 번째 숫자
 * @param b 두 번째 숫자
 * @return 두 숫자의 합
 */
public int add(int a, int b) {
    return a + b;
}
```

---

### @throws (또는 @exception)

메서드가 던질 수 있는 예외를 설명합니다.

**형식:**
```java
@throws 예외클래스명 설명
```

**예시:**
```java
/**
 * 파일을 읽어옵니다.
 *
 * @param filePath 파일 경로
 * @return 파일 내용
 * @throws FileNotFoundException 파일을 찾을 수 없을 때
 * @throws IOException 파일 읽기 실패 시
 */
public String readFile(String filePath) throws FileNotFoundException, IOException {
    // ...
}
```

---

### @see

관련된 클래스나 메서드를 참조합니다.

**예시:**
```java
/**
 * 사용자를 생성합니다.
 *
 * @param user 생성할 사용자 정보
 * @return 생성된 사용자
 * @see User
 * @see #updateUser(User)
 */
public User createUser(User user) {
    // ...
}
```

---

### @deprecated

더 이상 사용하지 않는 메서드나 클래스를 표시합니다.

**예시:**
```java
/**
 * 사용자 정보를 조회합니다.
 *
 * @deprecated getUserV2()를 사용하세요.
 * @param userId 사용자 ID
 * @return 사용자 정보
 */
@Deprecated
public User getUser(String userId) {
    // ...
}
```

---

### @since

메서드나 클래스가 추가된 버전을 명시합니다.

**예시:**
```java
/**
 * 사용자 프로필을 업데이트합니다.
 *
 * @param userId 사용자 ID
 * @param profile 프로필 정보
 * @since 1.2.0
 */
public void updateProfile(String userId, Profile profile) {
    // ...
}
```

---

### @author

클래스 작성자를 명시합니다.

**예시:**
```java
/**
 * 사용자 관리를 담당하는 서비스 클래스입니다.
 *
 * @author 왕택준
 * @since 1.0.0
 */
public class UserService {
    // ...
}
```

---

## 클래스 문서화

### 일반 클래스

```java
/**
 * 사용자 관리를 위한 서비스 클래스입니다.
 * 사용자 생성, 조회, 수정, 삭제 기능을 제공합니다.
 *
 * @author 왕택준
 * @since 1.0.0
 */
public class UserService {

    /**
     * 사용자 저장소
     */
    private final UserRepository userRepository;

    /**
     * UserService 생성자
     *
     * @param userRepository 사용자 저장소
     */
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // 메서드들...
}
```

---

### 인터페이스

```java
/**
 * 사용자 저장소 인터페이스입니다.
 * 사용자 데이터의 영속성을 담당합니다.
 *
 * @author 왕택준
 * @since 1.0.0
 */
public interface UserRepository {

    /**
     * 사용자를 저장합니다.
     *
     * @param user 저장할 사용자
     * @return 저장된 사용자
     */
    User save(User user);

    /**
     * ID로 사용자를 조회합니다.
     *
     * @param id 사용자 ID
     * @return 조회된 사용자, 없으면 빈 Optional
     */
    Optional<User> findById(Long id);
}
```

---

### Entity/DTO 클래스

```java
/**
 * 사용자 엔티티 클래스입니다.
 *
 * @author 왕택준
 * @since 1.0.0
 */
@Entity
@Table(name = "users")
public class User {

    /**
     * 사용자 고유 ID
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 사용자 이름 (필수, 최대 50자)
     */
    @Column(nullable = false, length = 50)
    private String name;

    /**
     * 이메일 주소 (필수, 고유값)
     */
    @Column(nullable = false, unique = true)
    private String email;

    /**
     * 계정 생성 일시
     */
    @CreatedDate
    private LocalDateTime createdAt;

    // getter, setter...
}
```

---

## 메서드 문서화

### Service 메서드

```java
/**
 * 새로운 사용자를 생성합니다.
 * 이메일 중복 검사를 수행한 후 사용자를 저장합니다.
 *
 * @param userDto 생성할 사용자 정보
 * @return 생성된 사용자
 * @throws DuplicateEmailException 이메일이 이미 존재할 때
 */
public User createUser(UserDto userDto) {
    if (userRepository.existsByEmail(userDto.getEmail())) {
        throw new DuplicateEmailException("이미 존재하는 이메일입니다.");
    }

    User user = new User();
    user.setName(userDto.getName());
    user.setEmail(userDto.getEmail());

    return userRepository.save(user);
}
```

---

### Controller 메서드

```java
/**
 * 사용자 목록을 조회합니다.
 * 페이징과 정렬을 지원합니다.
 *
 * @param page 페이지 번호 (0부터 시작)
 * @param size 페이지 크기
 * @param sort 정렬 기준 (예: name,asc)
 * @return 사용자 목록과 페이징 정보
 */
@GetMapping("/users")
public ResponseEntity<Page<UserDto>> getUsers(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size,
    @RequestParam(defaultValue = "id,desc") String sort
) {
    Pageable pageable = PageRequest.of(page, size, Sort.by(sort));
    Page<UserDto> users = userService.getUsers(pageable);
    return ResponseEntity.ok(users);
}
```

---

### Private 메서드

Private 메서드도 복잡한 로직을 포함하면 JavaDoc을 작성합니다.

```java
/**
 * 사용자 권한을 검증합니다.
 *
 * @param user 검증할 사용자
 * @param requiredRole 필요한 권한
 * @return 권한이 있으면 true, 없으면 false
 */
private boolean hasPermission(User user, Role requiredRole) {
    return user.getRoles().contains(requiredRole);
}
```

---

## 필드 문서화

### 상수

```java
/**
 * 최대 로그인 시도 횟수
 */
private static final int MAX_LOGIN_ATTEMPTS = 5;

/**
 * 세션 만료 시간 (밀리초)
 */
private static final long SESSION_TIMEOUT = 30 * 60 * 1000;
```

---

### 인스턴스 변수

```java
/**
 * 사용자 저장소
 */
private final UserRepository userRepository;

/**
 * 비밀번호 암호화 유틸리티
 */
private final PasswordEncoder passwordEncoder;

/**
 * 이메일 발송 서비스
 */
private final EmailService emailService;
```

---

## 작성 원칙

### 필수 작성 대상

다음 항목에는 반드시 JavaDoc 주석을 작성합니다.

- 모든 public 클래스
- 모든 public 메서드
- 모든 인터페이스와 인터페이스 메서드
- public 상수 필드
- 복잡한 private 메서드

---

### 작성 규칙

**명확성:**
- 설명은 간결하고 명확하게 작성합니다
- 첫 문장은 마침표로 끝나는 완전한 문장으로 작성합니다
- 불필요한 장황한 설명은 피합니다

**일관성:**
- 팀 전체가 동일한 용어와 형식을 사용합니다
- @param, @return, @throws 순서를 일관되게 유지합니다

**완전성:**
- 모든 매개변수와 반환 값에 대한 설명을 포함합니다
- 모든 예외(@throws)를 명시합니다
- null을 반환하거나 null을 허용하는 경우 명시합니다

---

### HTML 태그 사용

JavaDoc에서는 HTML 태그를 사용할 수 있습니다.

```java
/**
 * 사용자를 생성합니다.
 * <p>
 * 다음 검증을 수행합니다:
 * <ul>
 *   <li>이메일 형식 검증</li>
 *   <li>이메일 중복 검사</li>
 *   <li>비밀번호 강도 검증</li>
 * </ul>
 * </p>
 *
 * @param userDto 생성할 사용자 정보
 * @return 생성된 사용자
 */
public User createUser(UserDto userDto) {
    // ...
}
```

---

### 인라인 태그

**{@code}**: 코드 스타일 텍스트
```java
/**
 * {@code userId}는 null일 수 없습니다.
 */
```

**{@link}**: 다른 클래스나 메서드 링크
```java
/**
 * {@link User} 객체를 반환합니다.
 * {@link #createUser(UserDto)}를 참조하세요.
 */
```

**{@value}**: 상수 값 표시
```java
/**
 * 최대 시도 횟수는 {@value #MAX_LOGIN_ATTEMPTS}입니다.
 */
```

---

### 나쁜 예시

```java
/**
 * 유저 생성
 * @param u
 * @return u
 */
public User createUser(UserDto u) {
    return null;
}
```

**문제점:**
- 설명이 불명확 ("유저 생성"은 너무 간단)
- 매개변수명이 축약됨
- 매개변수와 반환 값 설명 누락
- 예외 처리 누락

---

### 좋은 예시

```java
/**
 * 새로운 사용자를 생성합니다.
 * 이메일 중복 검사를 수행한 후 사용자를 저장합니다.
 *
 * @param userDto 생성할 사용자 정보 (이름, 이메일 포함)
 * @return 생성된 사용자 객체 (ID 포함)
 * @throws DuplicateEmailException 이메일이 이미 존재할 때
 * @throws IllegalArgumentException userDto가 null이거나 필수 필드가 누락된 경우
 */
public User createUser(UserDto userDto) {
    if (userDto == null) {
        throw new IllegalArgumentException("userDto는 null일 수 없습니다.");
    }

    if (userRepository.existsByEmail(userDto.getEmail())) {
        throw new DuplicateEmailException("이미 존재하는 이메일입니다: " + userDto.getEmail());
    }

    User user = new User();
    user.setName(userDto.getName());
    user.setEmail(userDto.getEmail());

    return userRepository.save(user);
}
```

---

### JavaDoc 생성

JavaDoc HTML 문서를 생성하려면:

```bash
# Gradle
./gradlew javadoc
```

`build/docs/javadoc/` (Gradle)에서 확인할 수 있습니다.

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.10 | 왕택준 | 최초 작성 |
