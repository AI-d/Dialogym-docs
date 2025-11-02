# Dialogym 논리 ERD

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.01

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 논리 모델을 기반으로 JPA 엔티티와 물리 ERD를 설계하는 담당자
* **데이터베이스 관리자**: 정규화와 제약 조건을 검토하고 물리 설계를 준비하는 담당자
* **API 설계자**: 엔티티 간 관계를 이해하고 RESTful API를 설계하는 담당자
* **신규 합류자**: Dialogym 프로젝트의 정규화된 데이터 구조와 제약 조건을 학습해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym 프로젝트의 논리적 데이터 모델을 정의합니다.
개념 ERD를 기반으로 정규화를 수행하여 제3정규형을 달성하였으며, 모든 엔티티는 적절한 기본 키, 외래 키, 유니크 제약을 갖습니다.
일부 JSON 필드는 유연성을 위해 의도적으로 역정규화하였으며, 인덱스 전략과 제약 조건을 명확히 정의합니다.
총 12개의 테이블로 구성되며, 사용자 인증, 대화 훈련, 피드백 생성의 모든 비즈니스 로직을 지원합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [논리 ERD 다이어그램](#논리-erd-다이어그램)
3. [엔티티 상세 설명](#엔티티-상세-설명)
4. [정규화 수준](#정규화-수준)
5. [제약 조건](#제약-조건)
6. [인덱스 전략](#인덱스-전략)

---

## 문서 개요 (Overview)

본 문서는 Dialogym 프로젝트의 논리적 데이터 모델을 정규화와 제약 조건 관점에서 정의하기 위해 작성되었습니다.

개념 ERD가 비즈니스 관점의 데이터 구조를 표현한다면, 논리 ERD는 기술적 관점에서 정규화된 데이터 구조를 표현합니다.
이를 통해 데이터 중복을 최소화하고 무결성을 보장하며, 물리 ERD 설계의 명확한 기준을 제공합니다.

본 문서는 데이터베이스 설계, JPA 엔티티 설계, API 설계에 적용되며, 모든 백엔드 개발자가 준수해야 하는 데이터 모델 표준입니다.

---

## 논리 ERD 다이어그램

```mermaid
erDiagram
    USER ||--o{ REFRESH_TOKEN : has
    USER ||--o{ SOCIAL_ACCOUNT : links
    USER ||--o{ EMAIL_VERIFICATION : requests
    USER ||--o{ ONE_TIME_CODE : generates
    USER ||--o{ USER_CONSENT : agrees
    USER ||--o{ SCENARIO : creates
    USER ||--o{ DIALOGUE_SESSION : participates

    TERMS ||--o{ USER_CONSENT : requires

    SCENARIO ||--o{ DIALOGUE_SESSION : uses

    DIALOGUE_SESSION ||--o{ TRANSCRIPT : contains
    DIALOGUE_SESSION ||--|| FEEDBACK : produces

    USER {
        PK id BIGINT
        UK email VARCHAR
        password VARCHAR
        name VARCHAR
        birth_date DATE
        job_type ENUM
        job_detail VARCHAR
        primary_provider ENUM
        email_verified BOOLEAN
        status ENUM
        last_login_at DATETIME
        created_at DATETIME
        deleted_at DATETIME
    }

    REFRESH_TOKEN {
        PK id BIGINT
        FK user_id BIGINT
        UK token VARCHAR
        expiry_date DATETIME
        created_at DATETIME
    }

    SOCIAL_ACCOUNT {
        PK id BIGINT
        FK user_id BIGINT
        UK provider_provider_id
        provider ENUM
        provider_id VARCHAR
        social_email VARCHAR
        social_name VARCHAR
        is_connected BOOLEAN
        last_login_at DATETIME
    }

    EMAIL_VERIFICATION {
        PK id BIGINT
        FK user_id BIGINT
        email VARCHAR
        UK verification_token VARCHAR
        code VARCHAR
        expiry_date DATETIME
        is_verified BOOLEAN
        verified_at DATETIME
        created_at DATETIME
    }

    ONE_TIME_CODE {
        PK id BIGINT
        UK code VARCHAR
        user_id VARCHAR
        expiry_date DATETIME
        used BOOLEAN
    }

    PENDING_SOCIAL_USER {
        PK id BIGINT
        UK pending_token VARCHAR
        provider ENUM
        provider_id VARCHAR
        email VARCHAR
        name VARCHAR
        expiry_date DATETIME
        used BOOLEAN
        used_at DATETIME
        created_at DATETIME
    }

    TERMS {
        PK id BIGINT
        UK type_version
        type ENUM
        version VARCHAR
        title VARCHAR
        content TEXT
        is_required BOOLEAN
        is_active BOOLEAN
    }

    USER_CONSENT {
        PK id BIGINT
        FK user_id BIGINT
        FK terms_id BIGINT
        is_agreed BOOLEAN
        consented_at DATETIME
        revoked_at DATETIME
    }

    SCENARIO {
        PK id BIGINT
        FK owner_id BIGINT
        title VARCHAR
        role TEXT
        description TEXT
        prompt TEXT
        voice VARCHAR
        difficulty VARCHAR
        category VARCHAR
        locale VARCHAR
        status VARCHAR
        is_default BOOLEAN
        created_at DATETIME
        updated_at DATETIME
    }

    DIALOGUE_SESSION {
        PK id BIGINT
        UK session_id VARCHAR
        FK user_id BIGINT
        FK scenario_id BIGINT
        status ENUM
        started_at DATETIME
        ended_at DATETIME
        audio_url VARCHAR
        audio_duration_seconds INT
        realtime_metrics JSON
        janus_room_id BIGINT
        janus_user_feed_id BIGINT
        janus_bot_feed_id BIGINT
        ai_realtime_session_id VARCHAR
        created_at DATETIME
        updated_at DATETIME
    }

    TRANSCRIPT {
        PK id BIGINT
        FK session_id BIGINT
        speaker ENUM
        content TEXT
        timestamp DATETIME
        start_time_ms BIGINT
        end_time_ms BIGINT
        confidence_score FLOAT
        created_at DATETIME
    }

    FEEDBACK {
        PK id BIGINT
        UK session_id BIGINT
        total_score INT
        speech_rate_score INT
        filler_words_score INT
        politeness_score INT
        clarity_score INT
        improvement_points JSON
        original_transcript TEXT
        alternative_a TEXT
        alternative_b TEXT
        alternative_c TEXT
        final_choice TEXT
        chosen_alternative VARCHAR
        ai_prompt TEXT
        ai_raw_response TEXT
        created_at DATETIME
        updated_at DATETIME
    }
```

---

## 엔티티 상세 설명

### USER (사용자)

시스템을 사용하는 회원 정보를 저장합니다.

**제약 조건**:
- PK: id (BIGINT AUTO_INCREMENT)
- UK: (email, primary_provider) - 같은 제공자 내에서 이메일 중복 불가
- 정규화: 제3정규형 (3NF)
- 특이사항: Soft delete (deleted_at)

**관계**:
- REFRESH_TOKEN: 1:N (사용자당 여러 토큰 가능)
- SOCIAL_ACCOUNT: 1:N (여러 소셜 계정 연동 가능)
- DIALOGUE_SESSION: 1:N (여러 대화 세션 참여 가능)

### REFRESH_TOKEN (리프레시 토큰)

사용자의 리프레시 토큰을 저장하며, 멀티 디바이스를 지원합니다.

**제약 조건**:
- PK: id
- FK: user_id → USER(id) ON DELETE CASCADE
- UK: token (중복 불가)

**관계**:
- USER: N:1 (사용자당 여러 토큰 가능)

### SOCIAL_ACCOUNT (소셜 계정)

사용자가 연동한 소셜 로그인 계정 정보를 저장합니다.

**제약 조건**:
- PK: id
- FK: user_id → USER(id) ON DELETE CASCADE
- UK: (provider, provider_id) - 동일 제공자 내 고유

**관계**:
- USER: N:1 (사용자당 여러 소셜 계정 연동 가능)

### EMAIL_VERIFICATION (이메일 인증)

이메일 인증을 위한 일회용 코드와 토큰을 저장합니다.

**제약 조건**:
- PK: id
- FK: user_id → USER(id) ON DELETE CASCADE
- UK: verification_token

**특이사항**:
- 일회용 (인증 완료 시 삭제)
- 10분 만료

### ONE_TIME_CODE (일회용 코드)

소셜 로그인 후 프론트엔드에 토큰을 안전하게 전달하기 위한 일회용 코드입니다.

**제약 조건**:
- PK: id
- UK: code

**특이사항**:
- 1분 만료
- 사용 즉시 삭제

### PENDING_SOCIAL_USER (소셜 회원가입 대기)

소셜 로그인 후 추가 정보 입력을 대기 중인 사용자 정보를 임시 저장합니다.

**제약 조건**:
- PK: id
- UK: pending_token

**특이사항**:
- 15분 만료
- 회원가입 완료 시 삭제

### TERMS (약관)

서비스 이용약관, 개인정보 처리방침 등을 버전별로 관리합니다.

**제약 조건**:
- PK: id
- UK: (type, version) - 약관 종류와 버전의 조합은 고유

**정규화**:
- 약관 버전 관리를 위한 별도 테이블
- 약관 변경 이력 추적 가능

### USER_CONSENT (사용자 약관 동의)

사용자가 특정 약관에 동의한 이력을 저장합니다.

**제약 조건**:
- PK: id
- FK: user_id → USER(id) ON DELETE CASCADE
- FK: terms_id → TERMS(id) ON DELETE CASCADE

**관계**:
- N:M 해소 테이블 (USER ↔ TERMS)

### SCENARIO (시나리오)

대화 훈련을 위한 시나리오 정보를 저장합니다.

**제약 조건**:
- PK: id
- FK: owner_id → USER(id) ON DELETE SET NULL (NULL 가능)

**특이사항**:
- 기본 시나리오 (owner_id = NULL)
- 사용자 생성 시나리오 (owner_id = 사용자 ID)

### DIALOGUE_SESSION (대화 세션)

사용자가 진행하는 대화 훈련 세션 정보를 저장합니다.

**제약 조건**:
- PK: id
- UK: session_id (UUID)
- FK: user_id → USER(id) ON DELETE CASCADE
- FK: scenario_id → SCENARIO(id) ON DELETE CASCADE

**특이사항**:
- WebRTC(Janus) 세션 정보 포함
- OpenAI Realtime API 세션 정보 포함
- realtime_metrics는 JSON 타입으로 유연하게 저장

### TRANSCRIPT (발화 내역)

대화 세션 중 주고받은 모든 대화 내용을 저장합니다.

**제약 조건**:
- PK: id
- FK: session_id → DIALOGUE_SESSION(id) ON DELETE CASCADE

**관계**:
- DIALOGUE_SESSION: N:1 (세션당 여러 발화)

### FEEDBACK (피드백)

AI가 대화를 분석하여 생성한 피드백을 저장합니다.

**제약 조건**:
- PK: id
- UK: session_id (1:1 관계)
- FK: session_id → DIALOGUE_SESSION(id) ON DELETE CASCADE

**특이사항**:
- improvement_points는 JSON 타입으로 유연한 구조 지원
- original_transcript는 성능을 위해 중복 저장 (의도적 역정규화)

---

## 정규화 수준

### 제1정규형 (1NF)

모든 테이블이 제1정규형을 만족합니다.

- 모든 속성이 원자값 (Atomic Value)
- 반복 그룹 제거
- 각 행은 고유하게 식별 가능 (기본 키 존재)

### 제2정규형 (2NF)

모든 테이블이 제2정규형을 만족합니다.

- 부분 함수 종속 제거
- 모든 비키 속성이 기본키에 완전 함수 종속
- 복합 키가 있는 테이블도 부분 종속 없음

### 제3정규형 (3NF)

모든 테이블이 제3정규형을 만족합니다.

- 이행적 함수 종속 제거
- 비키 속성 간 종속성 제거
- 각 속성은 기본 키에만 종속

### 의도적 역정규화

성능과 유연성을 위해 일부 역정규화를 적용했습니다.

**FEEDBACK.original_transcript**:
- 이유: TRANSCRIPT 테이블 조인 없이 빠른 조회
- 트레이드오프: 저장 공간 증가, 데이터 중복

**JSON 필드 사용**:
- FEEDBACK.improvement_points
- DIALOGUE_SESSION.realtime_metrics
- 이유: 스키마 변경 없이 유연한 데이터 저장
- 트레이드오프: 쿼리 최적화 제한, 정규화 위배

---

## 제약 조건

### 기본 키 (Primary Key)

모든 테이블은 BIGINT AUTO_INCREMENT 타입의 기본 키를 갖습니다.

```sql
PRIMARY KEY (id)
```

### 외래 키 (Foreign Key)

외래 키는 참조 무결성을 보장하며, 삭제 정책을 명확히 정의합니다.

**ON DELETE CASCADE**:
```sql
-- 사용자 삭제 시 관련 데이터 자동 삭제
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
```

적용 테이블: REFRESH_TOKEN, SOCIAL_ACCOUNT, EMAIL_VERIFICATION, USER_CONSENT, DIALOGUE_SESSION, TRANSCRIPT, FEEDBACK

**ON DELETE SET NULL**:
```sql
-- 시나리오 소유자 삭제 시 NULL 처리 (기본 시나리오로 전환)
FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL
```

적용 테이블: SCENARIO

### 유니크 제약 (Unique Constraint)

중복을 방지하기 위한 유니크 제약을 설정합니다.

**복합 유니크**:
- USER: (email, primary_provider)
- SOCIAL_ACCOUNT: (provider, provider_id)
- TERMS: (type, version)

**단일 유니크**:
- REFRESH_TOKEN: token
- EMAIL_VERIFICATION: verification_token
- ONE_TIME_CODE: code
- PENDING_SOCIAL_USER: pending_token
- DIALOGUE_SESSION: session_id
- FEEDBACK: session_id

### NOT NULL 제약

필수 속성에는 NOT NULL 제약을 적용합니다.

**비즈니스 규칙 반영**:
- USER: email, name, birth_date, primary_provider (필수)
- USER: password (소셜 로그인 시 NULL 허용)
- SCENARIO: owner_id (기본 시나리오는 NULL)

### 체크 제약 (Check Constraint)

ENUM 타입으로 허용된 값만 입력되도록 제한합니다.

**ENUM 적용**:
- USER.job_type: STUDENT, JOB_SEEKER, EMPLOYEE, SELF_EMPLOYED, FREELANCER, HOUSEWIFE, OTHER
- USER.primary_provider: LOCAL, GOOGLE, KAKAO, NAVER
- USER.status: ACTIVE, INACTIVE, SUSPENDED, WITHDRAWN
- SOCIAL_ACCOUNT.provider: GOOGLE, KAKAO, NAVER
- DIALOGUE_SESSION.status: ONGOING, COMPLETED, FAILED
- TRANSCRIPT.speaker: USER, AI

---

## 인덱스 전략

### 기본 키 인덱스

모든 테이블의 기본 키는 자동으로 CLUSTERED INDEX가 생성됩니다.

### 외래 키 인덱스

JOIN 성능을 향상시키기 위해 외래 키에 인덱스를 생성합니다.

**인덱스 생성 대상**:
- user_id (모든 관련 테이블)
- session_id (TRANSCRIPT, FEEDBACK)
- scenario_id (DIALOGUE_SESSION)
- terms_id (USER_CONSENT)

### 검색 인덱스

WHERE 절에서 자주 사용되는 컬럼에 인덱스를 생성합니다.

**단일 컬럼 인덱스**:
- USER: email, status, last_login_at
- EMAIL_VERIFICATION: email, expiry_date
- REFRESH_TOKEN: expiry_date
- FEEDBACK: created_at

### 복합 인덱스

다중 조건 검색을 최적화하기 위해 복합 인덱스를 생성합니다.

**복합 인덱스**:
- USER: (email, primary_provider)
- SOCIAL_ACCOUNT: (provider, provider_id)
- EMAIL_VERIFICATION: (email, code)
- TERMS: (type, version)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.11.01 | 왕택준 | 초안 작성 및 템플릿 적용 |
