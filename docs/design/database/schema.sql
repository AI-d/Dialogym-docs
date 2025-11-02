-- ============================================
-- trAIn 프로젝트 데이터베이스 스키마
-- ============================================
-- 작성자: 왕택준
-- 작성일: 2025.11.01
-- 설명: 인증, 시나리오, 세션, 피드백 시스템의 전체 테이블 구조
-- ============================================

-- ============================================
-- 1. 사용자 및 인증 관련 테이블
-- ============================================

-- 사용자 테이블
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(60),  -- BCrypt 암호화, 소셜 계정은 NULL
    name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    -- JobType Enum: STUDENT, JOB_SEEKER, EMPLOYEE, SELF_EMPLOYED, FREELANCER, HOUSEWIFE, OTHER
    job_type ENUM('STUDENT', 'JOB_SEEKER', 'EMPLOYEE', 'SELF_EMPLOYED', 'FREELANCER', 'HOUSEWIFE', 'OTHER') NOT NULL,
    job_detail VARCHAR(20),
    -- Provider Enum: LOCAL, GOOGLE, KAKAO, NAVER
    primary_provider ENUM('LOCAL', 'GOOGLE', 'KAKAO', 'NAVER') NOT NULL,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    -- UserStatus Enum: ACTIVE, INACTIVE, SUSPENDED, WITHDRAWN
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'WITHDRAWN') NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME,
    created_at DATETIME NOT NULL,
    deleted_at DATETIME,
    UNIQUE KEY uk_email_provider (email, primary_provider),
    INDEX idx_user_email (email),
    INDEX idx_user_status (status),
    INDEX idx_user_last_login (last_login_at)
);

-- 리프레시 토큰 테이블
CREATE TABLE refresh_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    expiry_date DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    INDEX idx_rt_user (user_id),
    INDEX idx_rt_token (token),
    INDEX idx_rt_expiry (expiry_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 소셜 계정 연동 테이블
CREATE TABLE social_accounts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    -- Provider Enum: GOOGLE, KAKAO, NAVER (LOCAL 제외)
    provider ENUM('GOOGLE', 'KAKAO', 'NAVER') NOT NULL,
    provider_id VARCHAR(100) NOT NULL,
    social_email VARCHAR(100) NOT NULL,
    social_name VARCHAR(100) NOT NULL,
    is_connected BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at DATETIME,
    UNIQUE KEY uk_provider_provider_id (provider, provider_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 이메일 인증 테이블
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
    INDEX idx_ev_token (verification_token),
    INDEX idx_ev_user (user_id),
    INDEX idx_ev_email (email),
    INDEX idx_ev_email_code (email, code),
    INDEX idx_ev_expiry (expiry_date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 일회용 코드 테이블 (소셜 로그인 기존 회원용)
CREATE TABLE one_time_codes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL UNIQUE,
    user_id VARCHAR(20) NOT NULL,
    expiry_date DATETIME NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    INDEX idx_otc_user (user_id)
);

-- 소셜 회원가입 대기 테이블
CREATE TABLE pending_social_users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pending_token VARCHAR(500) NOT NULL UNIQUE,
    -- Provider Enum: GOOGLE, KAKAO, NAVER (LOCAL 제외)
    provider ENUM('GOOGLE', 'KAKAO', 'NAVER') NOT NULL,
    provider_id VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    expiry_date DATETIME NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    used_at DATETIME,
    created_at DATETIME NOT NULL,
    INDEX idx_psu_token (pending_token),
    INDEX idx_psu_provider (provider, provider_id),
    INDEX idx_psu_expiry (expiry_date)
);

-- ============================================
-- 2. 약관 관련 테이블
-- ============================================

-- 약관 테이블
CREATE TABLE terms (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    -- TermsType Enum: TERMS_OF_SERVICE, PRIVACY_POLICY, MARKETING_CONSENT
    type ENUM('TERMS_OF_SERVICE', 'PRIVACY_POLICY', 'MARKETING_CONSENT') NOT NULL,
    version VARCHAR(20) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uk_terms_type_version (type, version),
    INDEX idx_terms_type_active (type, is_active)
);

-- 사용자 약관 동의 테이블
CREATE TABLE user_consents (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    terms_id BIGINT NOT NULL,
    is_agreed BOOLEAN NOT NULL DEFAULT TRUE,
    consented_at DATETIME NOT NULL,
    revoked_at DATETIME,
    INDEX idx_uc_user_terms (user_id, terms_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (terms_id) REFERENCES terms(id) ON DELETE CASCADE
);

-- ============================================
-- 3. 시나리오 관련 테이블
-- ============================================

-- 시나리오 테이블
CREATE TABLE scenario (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(120) NOT NULL,
    role TEXT NOT NULL,
    description TEXT,
    prompt TEXT NOT NULL,
    voice VARCHAR(16) NOT NULL,  -- ALLOY, ASH, BALLAD, CORAL, ECHO, SAGE, SHIMMER, VERSE, MARIN, CEDAR
    difficulty VARCHAR(16) NOT NULL,  -- EASY, MEDIUM, HARD
    category VARCHAR(24) NOT NULL,  -- WORK, RELATIONSHIP, FAMILY, FRIEND, DAILY
    locale VARCHAR(10) NOT NULL DEFAULT 'ko-KR',
    status VARCHAR(16) NOT NULL DEFAULT 'PUBLISHED',  -- DRAFT, PUBLISHED, DELETED
    is_default BOOLEAN NOT NULL DEFAULT TRUE,
    owner_id BIGINT,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- 4. 대화 세션 관련 테이블
-- ============================================

-- 대화 세션 테이블
CREATE TABLE dialogue_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    scenario_id BIGINT NOT NULL,
    -- SessionStatus Enum: ONGOING, COMPLETED, FAILED
    status ENUM('ONGOING', 'COMPLETED', 'FAILED') NOT NULL,
    started_at DATETIME NOT NULL,
    ended_at DATETIME,
    audio_url VARCHAR(255),
    audio_duration_seconds INT,
    realtime_metrics JSON,
    janus_room_id BIGINT,
    janus_user_feed_id BIGINT,
    janus_bot_feed_id BIGINT,
    ai_realtime_session_id VARCHAR(128),
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (scenario_id) REFERENCES scenario(id) ON DELETE CASCADE
);

-- 발화 내역 테이블
CREATE TABLE transcripts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id BIGINT NOT NULL,
    -- Speaker Enum: USER, AI
    speaker ENUM('USER', 'AI') NOT NULL,
    content TEXT NOT NULL,
    timestamp DATETIME NOT NULL,
    start_time_ms BIGINT,
    end_time_ms BIGINT,
    confidence_score FLOAT,
    created_at DATETIME NOT NULL,
    INDEX idx_session_id (session_id),
    FOREIGN KEY (session_id) REFERENCES dialogue_sessions(id) ON DELETE CASCADE
);

-- ============================================
-- 5. 피드백 관련 테이블
-- ============================================

-- 피드백 테이블
CREATE TABLE feedbacks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id BIGINT NOT NULL UNIQUE,
    total_score INT NOT NULL,
    speech_rate_score INT NOT NULL,
    filler_words_score INT NOT NULL,
    politeness_score INT NOT NULL,
    clarity_score INT NOT NULL,
    improvement_points JSON,
    original_transcript TEXT,
    alternative_a TEXT,
    alternative_b TEXT,
    alternative_c TEXT,
    final_choice TEXT,
    chosen_alternative VARCHAR(10),  -- A, B, C, CUSTOM
    ai_prompt TEXT,
    ai_raw_response TEXT,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    INDEX idx_feedback_session_id (session_id),
    INDEX idx_feedback_created_at (created_at),
    FOREIGN KEY (session_id) REFERENCES dialogue_sessions(id) ON DELETE CASCADE
);

-- ============================================
-- 테이블 관계 요약
-- ============================================
-- users (1) ─── (N) refresh_tokens
-- users (1) ─── (N) social_accounts
-- users (1) ─── (N) email_verifications
-- users (1) ─── (N) user_consents
-- users (1) ─── (N) scenario (owner)
-- users (1) ─── (N) dialogue_sessions
--
-- terms (1) ─── (N) user_consents
--
-- scenario (1) ─── (N) dialogue_sessions
--
-- dialogue_sessions (1) ─── (N) transcripts
-- dialogue_sessions (1) ─── (1) feedbacks
-- ============================================

-- ============================================
-- Enum 타입 상세 설명
-- ============================================

-- Provider (인증 제공자)
-- - LOCAL: 이메일/비밀번호 로컬 회원가입
-- - GOOGLE: 구글 소셜 로그인
-- - KAKAO: 카카오 소셜 로그인
-- - NAVER: 네이버 소셜 로그인
-- 사용 테이블: users.primary_provider, social_accounts.provider, pending_social_users.provider

-- UserStatus (사용자 계정 상태)
-- - ACTIVE: 활성 상태 (정상)
-- - INACTIVE: 비활성 상태 (1년 미접속 휴면, 로그인 시 자동 복구)
-- - SUSPENDED: 정지 상태 (약관 위반, 관리자 승인 필요)
-- - WITHDRAWN: 탈퇴 상태 (복구 불가)
-- 사용 테이블: users.status

-- JobType (직업 유형)
-- - STUDENT: 학생
-- - JOB_SEEKER: 취업준비생
-- - EMPLOYEE: 직장인
-- - SELF_EMPLOYED: 자영업자
-- - FREELANCER: 프리랜서
-- - HOUSEWIFE: 주부
-- - OTHER: 기타 (job_detail 필수)
-- 사용 테이블: users.job_type

-- TermsType (약관 종류)
-- - TERMS_OF_SERVICE: 서비스 이용약관 (필수)
-- - PRIVACY_POLICY: 개인정보 처리방침 (필수, 개인정보보호법 제39조의8)
-- - MARKETING_CONSENT: 마케팅 수신 동의 (선택, 정보통신망법 제50조)
-- 사용 테이블: terms.type

-- SessionStatus (세션 상태)
-- - ONGOING: 진행 중
-- - COMPLETED: 정상 완료 (피드백 생성 가능)
-- - FAILED: 오류로 인한 실패
-- 사용 테이블: dialogue_sessions.status

-- Speaker (화자 구분)
-- - USER: 훈련 중인 사용자
-- - AI: AI 상대방
-- 사용 테이블: transcripts.speaker

-- ============================================
-- 인덱스 전략
-- ============================================
-- 1. 기본 키 (PRIMARY KEY): 모든 테이블의 id 컬럼
-- 2. 유니크 인덱스 (UNIQUE): 중복 방지 (email+provider, token 등)
-- 3. 외래 키 인덱스: JOIN 성능 향상 (user_id, session_id 등)
-- 4. 검색 인덱스: WHERE 절 성능 향상 (status, created_at 등)
-- 5. 복합 인덱스: 다중 조건 검색 최적화 (email+code 등)

-- ============================================
-- 데이터 정리 정책
-- ============================================
-- 1. email_verifications: 만료된 레코드 매일 02:00 삭제
-- 2. pending_social_users: 만료된 레코드 매일 02:00 삭제
-- 3. refresh_tokens: 만료된 토큰 매일 03:00 삭제
-- 4. one_time_codes: 만료된 코드 매 시간 삭제
-- 5. users (deleted_at): Soft delete 방식, 실제 삭제는 별도 정책 필요

-- ============================================
