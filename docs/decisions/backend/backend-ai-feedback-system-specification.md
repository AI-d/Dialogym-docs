# Dialogym 벡엔드 AI 기반 피드백 생성 시스템 구현 명세서

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.01

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: AI 피드백 시스템의 전체 구조와 Spring AI 활용 방식을 이해하고 유지보수해야 하는 담당자
* **AI/ML 엔지니어**: 프롬프트 엔지니어링 및 AI 모델 통합 방식을 검토하는 담당자
* **프론트엔드 개발자**: 피드백 API 호출 및 응답 데이터 처리를 구현해야 하는 담당자
* **신규 합류자**: 프로젝트의 AI 피드백 생성 시스템을 빠르게 파악해야 하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Spring AI와 OpenAI ChatGPT 4.0을 활용한 대화 피드백 자동 생성 시스템의 구현 명세를 정의합니다. 사용자의 대화 세션이 완료되면 DB에 저장된 전체 대화 내역(Transcript)을 분석하여 발화속도, 추임새, 공손도, 명료성 4가지 항목을 0-25점씩 균등 배분하여 총 100점 만점으로 점수화합니다. AI는 단일 호출로 전체 대화 흐름 분석, 문장별 상세 분석, 3가지 스타일의 개선안(간결/공손/따뜻)을 생성하며, 재시도 메커니즘(최대 3회, 선형 백오프)을 통해 안정성을 보장합니다. 생성된 피드백은 DB에 저장되어 사용자 히스토리, 통계, 성장 추이 분석에 활용됩니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [시스템 아키텍처](#시스템-아키텍처)
3. [데이터베이스 스키마](#데이터베이스-스키마)
4. [AI 피드백 생성 플로우](#ai-피드백-생성-플로우)
5. [Spring AI 통합](#spring-ai-통합)
6. [프롬프트 엔지니어링](#프롬프트-엔지니어링)
7. [점수 체계 및 등급](#점수-체계-및-등급)
8. [에러 처리 및 재시도](#에러-처리-및-재시도)
9. [API 엔드포인트 명세](#api-엔드포인트-명세)
10. [피드백 통계 및 분석](#피드백-통계-및-분석)
11. [성능 최적화](#성능-최적화)
12. [부록](#부록)
13. [향후 개선사항 로드맵](#향후-개선사항-로드맵)
14. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 trAIn 프로젝트의 AI 기반 피드백 생성 시스템 전체 구현 내역을 상세히 기술합니다.
 사용자가 대화 훈련을 완료하면 Spring AI를 통해 OpenAI ChatGPT 4.0 모델이 전체 대화를 종합 분석하여 점수화하고 구체적인 개선안을 제시합니다. 실제 코드 구현을 기반으로 AI 통합 방식, 프롬프트 설계, 데이터 흐름, 에러 처리 전략을 포함하여 시스템 전체를 이해할 수 있도록 작성되었습니다.

본 명세서는 다음과 같은 목적으로 활용됩니다.

* 신규 개발자의 AI 시스템 이해 및 온보딩 자료
* AI 피드백 시스템 유지보수 및 확장 시 참고 문서
* 프롬프트 개선 및 AI 모델 업그레이드 가이드
* 프론트엔드-백엔드 간 피드백 API 계약 명세

---

## 시스템 아키텍처

### 전체 구조

본 시스템은 Spring AI 프레임워크를 활용하여 OpenAI ChatGPT 4.0 모델과 통합된 피드백 생성 파이프라인을 구성합니다.

**핵심 설계 원칙:**

* **단일 AI 호출**: 전체 분석을 한 번의 API 호출로 완료하여 비용 및 응답 시간 최적화
* **종합 분석**: 전체 대화 흐름 + 문장별 상세 분석 + 개선안을 하나의 프롬프트로 요청
* **재시도 메커니즘**: 일시적 오류 대비 최대 3회 재시도 (선형 백오프: 1초 → 2초 → 3초)
* **데이터 기반**: DB에 저장된 실제 대화 내역(Transcript)을 분석 소스로 활용
* **확장 가능성**: 프롬프트 템플릿 분리로 AI 모델 변경 및 분석 항목 추가 용이

### 컴포넌트 구성

```
[클라이언트]
    ↓
[FeedbackController]
    ↓
[FeedbackService] ← 비즈니스 로직 및 트랜잭션 관리
    ↓
[FeedbackPromptService] ← AI 통합 및 프롬프트 생성
    ↓
[Spring AI ChatModel] ← OpenAI API 추상화
    ↓
[OpenAI ChatGPT 4.0 API]
    ↓
[AI 응답 파싱 및 검증]
    ↓
[Feedback 엔티티 저장]
    ↓
[응답 반환]
```

**주요 컴포넌트:**

1. **FeedbackController**: HTTP 엔드포인트 제공 및 요청/응답 처리
2. **FeedbackService**: 피드백 생성/조회/통계 비즈니스 로직
3. **FeedbackPromptService**: AI 프롬프트 생성 및 응답 파싱 전담
4. **DialogueSessionService**: 대화 세션 및 Transcript 조회
5. **Spring AI ChatModel**: OpenAI API 통신 추상화 레이어
6. **Feedback 엔티티**: 피드백 데이터 영속화

### 데이터 흐름

```
1. 사용자 대화 완료
   ↓
2. DialogueSession 상태 = COMPLETED
   ↓
3. Transcript 레코드들이 DB에 저장됨
   ↓
4. 클라이언트가 POST /api/v1/feedbacks/sessions/{sessionId} 호출
   ↓
5. FeedbackService.generateFeedbackWithAI() 실행
   ↓
6. DialogueSession + Transcripts 조회
   ↓
7. FeedbackPromptService.generatePrompt() - 프롬프트 생성
   ↓
8. ChatModel.call(prompt) - AI API 호출 (재시도 포함)
   ↓
9. AI 응답 JSON 파싱 및 검증
   ↓
10. Feedback 엔티티 생성 및 DB 저장
   ↓
11. FeedbackResponse 반환 (종합 분석 포함)
```

---

## 데이터베이스 스키마

### feedbacks 테이블

```sql
CREATE TABLE feedbacks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id VARCHAR(36) NOT NULL UNIQUE,  -- DialogueSession FK

    -- 점수 (균등 배분: 각 25점, 총 100점)
    total_score INT NOT NULL,                -- 0-100
    speech_rate_score INT NOT NULL,          -- 0-25 (발화속도)
    filler_words_score INT NOT NULL,         -- 0-25 (추임새)
    politeness_score INT NOT NULL,           -- 0-25 (공손도)
    clarity_score INT NOT NULL,              -- 0-25 (명료성)

    -- 개선 포인트 (JSON)
    improvement_points JSON,

    -- 원본 및 개선안
    original_transcript TEXT,                -- 분석 대상 원본 발화
    alternative_a TEXT,                      -- 간결한 스타일
    alternative_b TEXT,                      -- 공손한 스타일
    alternative_c TEXT,                      -- 따뜻한 스타일

    -- 사용자 선택
    chosen_alternative VARCHAR(10),          -- A, B, C, CUSTOM
    final_choice TEXT,                       -- 최종 선택된 개선안

    -- AI 디버깅 정보
    ai_prompt TEXT,                          -- 사용된 프롬프트
    ai_raw_response TEXT,                    -- AI 원본 응답

    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,

    FOREIGN KEY (session_id) REFERENCES dialogue_sessions(session_id),
    INDEX idx_feedback_session_id (session_id),
    INDEX idx_feedback_created_at (created_at)
);
```

### dialogue_sessions 테이블

```sql
CREATE TABLE dialogue_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id VARCHAR(36) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    scenario_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL,             -- IN_PROGRESS, COMPLETED, FAILED
    started_at DATETIME NOT NULL,
    ended_at DATETIME,
    audio_url VARCHAR(500),
    audio_duration_seconds INT,
    realtime_metrics JSON,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (scenario_id) REFERENCES scenarios(id),
    INDEX idx_user_id (user_id)
);
```

### transcripts 테이블

```sql
CREATE TABLE transcripts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    session_id BIGINT NOT NULL,              -- DialogueSession FK
    speaker VARCHAR(20) NOT NULL,            -- USER, AI
    content TEXT NOT NULL,                   -- 발화 내용
    timestamp DATETIME NOT NULL,             -- 발화 시각
    start_time_ms BIGINT,                    -- 시작 시간 (밀리초)
    end_time_ms BIGINT,                      -- 종료 시간 (밀리초)
    confidence_score FLOAT,                  -- 음성 인식 신뢰도 (0.0-1.0)
    created_at DATETIME NOT NULL,

    FOREIGN KEY (session_id) REFERENCES dialogue_sessions(id),
    INDEX idx_session_id (session_id)
);
```

**주요 특징:**
* `feedbacks`와 `dialogue_sessions`는 1:1 관계
* `transcripts`는 대화 세션당 여러 개 존재 (1:N)
* `confidence_score`로 음성 인식 품질 추적
* `improvement_points`는 JSON 형태로 유연한 구조 지원

---

## AI 피드백 생성 플로우

### 전체 프로세스

```
1. 대화 세션 완료
   - 사용자가 시나리오 기반 대화 훈련 완료
   - DialogueSession.status = COMPLETED
   - Transcript 레코드들이 DB에 저장됨

2. 피드백 생성 요청
   - POST /api/v1/feedbacks/sessions/{sessionId}
   - FeedbackService.generateFeedbackWithAI(sessionId) 호출

3. 세션 검증
   - DialogueSession 조회 (User, Scenario 포함)
   - 상태 확인: COMPLETED 여부
   - 중복 피드백 확인: 이미 존재하면 409 에러

4. 대화 데이터 수집
   - Transcripts 조회 (시간순 정렬)
   - 사용자 발화만 필터링 (Speaker.USER)
   - 분석 가능 여부 확인 (isAnalyzable())
     * 신뢰도 0.7 이상
     * 내용 길이 3자 이상
     * 공백 아님

5. AI 프롬프트 생성
   - 전체 대화 흐름 구성 (AI + USER 번갈아가며)
   - 사용자 발화만 번호 매겨서 개별 분석용 구성
   - 대표 발화 선택 (가장 긴 문장)
   - 시나리오 정보 포함 (제목, 설명)

6. AI API 호출 (재시도 포함)
   - ChatModel.call(prompt) 실행
   - 최대 3회 재시도
   - 선형 백오프: 1초 → 2초 → 3초

7. AI 응답 파싱
   - JSON 블록 추출 (```json ... ``` 또는 { ... })
   - 점수 추출 및 검증 (0-100, 각 항목 0-25)
   - 전체 분석, 문장별 분석, 개선안 파싱

8. Feedback 엔티티 생성 및 저장
   - 기본 정보 (점수, 개선안) 저장
   - AI 프롬프트 및 원본 응답 저장 (디버깅용)

9. 응답 반환
   - FeedbackResponse 생성
   - 종합 분석 포함 (overallAnalysis, sentenceAnalyses, conversationImprovement)
```

### 상세 플로우 다이어그램

```
[클라이언트]      [FeedbackService]   [FeedbackPromptService]   [ChatModel]   [DB]
     |                    |                      |                   |          |
     |--POST /feedbacks-> |                      |                   |          |
     |                    |                      |                   |          |
     |                    |---세션 조회---------> |                   |          |
     |                    |                      |-------------------|-DB 조회->|
     |                    |<--Session+Transcripts|                   |          |
     |                    |                      |                   |          |
     |                    |---상태 검증           |                   |          |
     |                    |---중복 확인--------- -|-------------------|-DB 조회-> |
     |                    |                      |                   |          |
     |                    |---프롬프트 생성 요청-> |                   |          |
     |                    |                      |---대화 데이터 분석  |          |
     |                    |                      |---프롬프트 구성     |          |
     |                    |                      |                   |          |
     |                    |                      |---AI 호출--------> |          |
     |                    |                      |                   |-OpenAI-->|
     |                    |                      |                   |<-응답----|
     |                    |                      |<--AI 응답--------- |          |
     |                    |                      |                   |          |
     |                    |                      |---응답 파싱        |          |
     |                    |                      |---검증             |          |
     |                    |<--FeedbackResponse---|                    |          |
     |                    |                      |                    |          |
     |                    |---Feedback 저장------|------------------- |-DB 저장->|
     |                    |                      |                    |          |
     |<--FeedbackResponse-|                      |                    |          |
```

### 핵심 메서드 호출 순서

**1. FeedbackService.generateFeedbackWithAI()**
```java
public FeedbackResponse generateFeedbackWithAI(String sessionId) {
    // 1. 세션 조회 및 검증
    DialogueSession session = dialogueSessionService.getSessionWithUserAndScenario(sessionId);

    // 2. 상태 확인
    if (!session.getStatus().isCompleted()) {
        throw new TrainException(SESSION_INVALID_STATUS);
    }

    // 3. 중복 확인
    if (feedbackRepository.existsByDialogueSessionSessionId(sessionId)) {
        throw new TrainException(FEEDBACK_ALREADY_EXISTS);
    }

    // 4. AI 종합 분석 생성
    FeedbackResponse comprehensiveFeedback =
        feedbackPromptService.generateFeedbackFromAI(session);

    // 5. DB 저장
    Feedback savedFeedback = createFeedbackFromRequest(basicRequest, session);

    // 6. 응답 반환 (종합 분석 포함)
    return FeedbackResponse.withComprehensiveAnalysis(
        savedFeedback,
        comprehensiveFeedback.overallAnalysis(),
        comprehensiveFeedback.sentenceAnalyses(),
        comprehensiveFeedback.conversationImprovement()
    );
}
```

**2. FeedbackPromptService.generateFeedbackFromAI()**
```java
public FeedbackResponse generateFeedbackFromAI(DialogueSession dialogueSession) {
    Exception lastException = null;

    // 재시도 루프 (최대 3회)
    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
        try {
            // 1. 프롬프트 생성
            String comprehensivePrompt = generatePrompt(dialogueSession);

            // 2. AI API 호출
            String aiResponse = callChatGPT(comprehensivePrompt);

            // 3. 응답 파싱
            FeedbackResponse response =
                parseComprehensiveResponse(aiResponse, dialogueSession);

            return response;

        } catch (Exception e) {
            lastException = e;

            if (attempt < MAX_RETRIES) {
                waitBeforeRetry(attempt); // 1초, 2초, 3초
            }
        }
    }

    // 모든 재시도 실패
    throw new TrainException(AI_ANALYSIS_FAILED, lastException.getMessage());
}
```

---

## Spring AI 통합

### Spring AI 설정

**ChatClientConfig.java:**
```java
@Configuration
public class ChatClientConfig {

    @Bean
    public ChatClient chatClient(OpenAiChatModel chatModel) {
        return ChatClient.builder(chatModel).build();
    }
}
```

**application.yml:**
```yaml
spring:
  ai:
    openai:
      api-key: ${OPENAI_API_KEY}
      chat:
        options:
          model: gpt-4o  # ChatGPT 4.0
          temperature: 0.7
          max-tokens: 4000
```

### ChatModel 사용

**AI API 호출:**
```java
private String callChatGPT(String prompt) throws Exception {
    log.info("ChatGPT 4.0 호출 시작 - prompt length: {}", prompt.length());

    try {
        Prompt chatPrompt = new Prompt(prompt);
        ChatResponse response = chatModel.call(chatPrompt);

        String aiResponse = response.getResult().getOutput().getContent();
        log.info("ChatGPT 4.0 응답 받음 - response length: {}", aiResponse.length());

        return aiResponse;

    } catch (Exception e) {
        log.error("ChatGPT 4.0 호출 실패", e);
        throw new Exception("AI API 호출에 실패했습니다: " + e.getMessage());
    }
}
```

**주요 특징:**
* **Spring AI 추상화**: OpenAI API를 직접 호출하지 않고 Spring AI의 ChatModel 인터페이스 사용
* **설정 외부화**: API 키 및 모델 파라미터를 application.yml로 관리
* **모델 변경 용이**: ChatModel 구현체만 교체하면 다른 AI 모델 사용 가능
* **에러 처리**: Spring AI가 제공하는 예외 처리 메커니즘 활용

### Spring AI 의존성

**build.gradle:**
```gradle
dependencies {
    // Spring AI
    implementation 'org.springframework.ai:spring-ai-openai-spring-boot-starter:1.0.0-M3'

    // JSON 처리
    implementation 'com.fasterxml.jackson.core:jackson-databind'
    implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
}
```

---

## 프롬프트 엔지니어링

### 프롬프트 구조

AI에게 전달되는 프롬프트는 다음과 같은 구조로 구성됩니다:

```
1. 역할 정의
   - "당신은 대화 훈련 전문가입니다"

2. 시나리오 정보
   - 제목, 설명

3. 전체 대화 흐름
   - [사용자] 발화
   - [상대방] 발화
   - 시간순 정렬

4. 개별 분석 대상
   - [문장 1] 사용자 발화
   - [문장 2] 사용자 발화
   - ...

5. 분석 요청사항
   - 1단계: 전체 대화 흐름 분석
   - 2단계: 개별 문장 분석
   - 3단계: 종합 점수 및 개선안

6. 응답 형식 지정
   - JSON 스키마 제공
   - 필드별 설명
```

### 실제 프롬프트 템플릿

```java
private String generatePrompt(DialogueSession dialogueSession) {
    // 1. 대화 데이터 수집
    List<Transcript> transcripts = dialogueSession.getTranscripts();
    List<Transcript> userTranscripts = transcripts.stream()
        .filter(Transcript::isAnalyzable)
        .sorted(Comparator.comparing(Transcript::getTimestamp))
        .toList();

    // 2. 전체 대화 흐름 구성
    StringBuilder fullConversation = new StringBuilder();
    fullConversation.append("=== 전체 대화 흐름 ===\n");
    for (Transcript transcript : transcripts) {
        String speaker = transcript.getSpeaker() == Speaker.USER ? "사용자" : "상대방";
        fullConversation.append(String.format("[%s] %s\n", speaker, transcript.getContent()));
    }

    // 3. 사용자 발화만 번호 매기기
    StringBuilder userSentences = new StringBuilder();
    userSentences.append("\n=== 개별 분석 대상 (사용자 발화만) ===\n");
    for (int i = 0; i < userTranscripts.size(); i++) {
        userSentences.append(String.format("[문장 %d] %s\n",
            i + 1, userTranscripts.get(i).getContent()));
    }

    // 4. 대표 발화 선택 (가장 긴 문장)
    String representativeTranscript = userTranscripts.stream()
        .max(Comparator.comparingInt(t -> t.getContent().length()))
        .map(Transcript::getContent)
        .orElse(userTranscripts.get(0).getContent());

    // 5. 프롬프트 조합
    return String.format("""
        당신은 대화 훈련 전문가입니다. 다음 대화를 종합적으로 분석해주세요.

        ## 시나리오 정보
        제목: %s
        설명: %s

        %s

        %s

        ## 분석 요청사항

        **1단계: 전체 대화 흐름 분석**
        - 대화가 어떻게 진행되었는지 전반적인 흐름 평가
        - 사용자의 소통 패턴과 특징 분석
        - 전체적인 개선 방향 제시

        **2단계: 개별 문장 분석**
        - 각 사용자 발화의 구체적인 문제점 지적
        - 문장별 개선된 버전 제시
        - 문제의 심각도와 개선 방법 제안

        **3단계: 종합 점수 및 개선안**
        - 전체 대화를 고려한 종합 점수 산출
        - 3가지 스타일의 대표 개선안 제시 (대표 문장: "%s")

        다음 JSON 형식으로 응답해주세요:

        ```json
        {
          "totalScore": 전체점수(0-100),
          "speechRateScore": 발화속도점수(0-25),
          "fillerWordsScore": 추임새점수(0-25),
          "politenessScore": 공손도점수(0-25),
          "clarityScore": 명료성점수(0-25),
          "improvementPoints": [
            {
              "type": "문제유형",
              "description": "문제설명",
              "suggestion": "개선제안"
            }
          ],
          "originalTranscript": "%s",
          "alternativeA": "간결한 스타일 개선안",
          "alternativeB": "공손한 스타일 개선안",
          "alternativeC": "따뜻한 스타일 개선안",
          "overallAnalysis": {
            "conversationFlow": "전체 대화 흐름에 대한 평가",
            "communicationPattern": "사용자의 소통 패턴 분석",
            "overallImprovements": [
              {
                "category": "conversation_flow|confidence|structure",
                "description": "개선영역설명",
                "suggestion": "구체적개선방법"
              }
            ]
          },
          "sentenceAnalyses": [
            {
              "sequence": 문장순서,
              "content": "원본문장",
              "issues": [
                {
                  "type": "filler_words|incomplete_sentence|vague_explanation",
                  "count": 문제발생횟수,
                  "impact": "high|medium|low",
                  "suggestion": "개선제안"
                }
              ],
              "improvedVersion": "개선된문장"
            }
          ],
          "conversationImprovement": {
            "currentPattern": "현재 대화에서 나타난 패턴",
            "improvedPattern": "이상적인 대화 패턴",
            "fullImprovedDialogue": "전체 대화를 개선한 완전한 예시"
          }
        }
        ```

        JSON만 응답하고 다른 설명은 포함하지 마세요.
        """,
        dialogueSession.getScenario().getTitle(),
        dialogueSession.getScenario().getDescription(),
        fullConversation,
        userSentences,
        representativeTranscript,
        representativeTranscript
    );
}
```

### 프롬프트 설계 원칙

**1. 명확한 역할 정의**
* "당신은 대화 훈련 전문가입니다"로 AI의 역할 명시
* 전문가 관점에서 분석하도록 유도

**2. 구조화된 입력**
* 전체 대화 흐름과 개별 문장을 분리하여 제공
* 번호를 매겨 참조 용이하게 구성

**3. 단계별 분석 요청**
* 1단계: 전체 흐름 → 2단계: 개별 문장 → 3단계: 종합 점수
* 점진적 분석으로 정확도 향상

**4. 명시적 JSON 스키마**
* 응답 형식을 JSON으로 명확히 지정
* 필드별 타입과 설명 제공
* 파싱 오류 최소화

**5. 예시 제공**
* 대표 문장을 명시하여 개선안 생성 가이드
* 문제 유형 예시 제공 (filler_words, incomplete_sentence 등)

---

## 점수 체계 및 등급

### 점수 구성 (균등 배분)

**총점: 100점**

| 항목 | 배점 | 설명 |
|------|------|------|
| 발화속도 (Speech Rate) | 0-25점 | 말하는 속도의 적절성 평가 |
| 추임새 (Filler Words) | 0-25점 | "음...", "그..." 등 불필요한 표현 빈도 |
| 공손도 (Politeness) | 0-25점 | 상대방에 대한 예의와 존중 표현 |
| 명료성 (Clarity) | 0-25점 | 의사 전달의 명확성과 구체성 |

**점수 검증:**
```java
@PrePersist
@PreUpdate
private void validateScores() {
    // 각 점수 범위 검증 (0-25)
    if (speechRateScore < 0 || speechRateScore > 25) {
        throw new IllegalArgumentException("발화속도 점수 범위 오류");
    }
    // ... 다른 항목도 동일하게 검증

    // 총점 범위 검증 (0-100)
    if (totalScore < 0 || totalScore > 100) {
        throw new IllegalArgumentException("전체 점수 범위 오류");
    }

    // 점수 합계 검증
    int calculatedTotal = speechRateScore + fillerWordsScore +
                          politenessScore + clarityScore;

    if (totalScore != calculatedTotal) {
        throw new IllegalArgumentException("점수 합계 불일치");
    }
}
```

### 등급 체계

**등급 산출:**
```java
public String getScoreGrade() {
    if (totalScore >= 90) return "A";
    if (totalScore >= 80) return "B";
    if (totalScore >= 70) return "C";
    if (totalScore >= 60) return "D";
    return "F";
}
```

| 등급 | 점수 범위 | 설명 |
|------|-----------|------|
| A | 90-100점 | 매우 우수 - 거의 완벽한 대화 능력 |
| B | 80-89점 | 우수 - 약간의 개선 여지 있음 |
| C | 70-79점 | 보통 - 몇 가지 개선 필요 |
| D | 60-69점 | 미흡 - 상당한 개선 필요 |
| F | 0-59점 | 불합격 - 전반적인 재학습 필요 |

### 개선 포인트 구조

**improvementPoints JSON 형식:**
```json
[
  {
    "type": "filler_words",
    "description": "추임새 사용 빈도가 높습니다",
    "suggestion": "'음...', '그...' 등의 표현을 줄이고 잠시 멈춤으로 대체하세요",
    "count": 5
  },
  {
    "type": "incomplete_sentence",
    "description": "문장이 완결되지 않은 경우가 있습니다",
    "suggestion": "문장을 끝까지 완성하여 명확하게 전달하세요",
    "count": 3
  },
  {
    "type": "vague_explanation",
    "description": "설명이 모호한 부분이 있습니다",
    "suggestion": "구체적인 예시나 수치를 사용하여 명확하게 설명하세요",
    "count": 2
  }
]
```

---

## 에러 처리 및 재시도

### 재시도 메커니즘

**설정:**
```java
private static final int MAX_RETRIES = 3;
private static final int BASE_DELAY_MS = 1000; // 1초 기본 지연
```

**재시도 로직:**
```java
public FeedbackResponse generateFeedbackFromAI(DialogueSession dialogueSession) {
    Exception lastException = null;

    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
        try {
            // AI 호출 및 파싱
            String comprehensivePrompt = generatePrompt(dialogueSession);
            String aiResponse = callChatGPT(comprehensivePrompt);
            FeedbackResponse response = parseComprehensiveResponse(aiResponse, dialogueSession);

            log.info("종합 피드백 응답 생성 성공 - sessionId: {}, attempt: {}",
                    dialogueSession.getSessionId(), attempt);

            return response;

        } catch (Exception e) {
            lastException = e;

            if (attempt < MAX_RETRIES) {
                log.warn("종합 피드백 응답 생성 실패, 재시도 예정 - attempt: {}/{}",
                        attempt, MAX_RETRIES);

                waitBeforeRetry(attempt); // 선형 백오프
            }
        }
    }

    // 모든 재시도 실패
    throw new TrainException(AI_ANALYSIS_FAILED,
            String.format("종합 피드백 생성에 %d회 시도했지만 모두 실패했습니다", MAX_RETRIES));
}
```

**선형 백오프 (Linear Backoff):**
```java
private void waitBeforeRetry(int attempt) {
    try {
        int delayMs = BASE_DELAY_MS * attempt; // 1초, 2초, 3초
        log.info("재시도 전 {}ms 대기 중...", delayMs);
        Thread.sleep(delayMs);
    } catch (InterruptedException ie) {
        Thread.currentThread().interrupt();
        log.warn("재시도 대기 중 인터럽트 발생");
    }
}
```

**재시도 전략:**
* **1차 시도**: 즉시 실행
* **2차 시도**: 1초 대기 후 실행
* **3차 시도**: 2초 대기 후 실행
* **최종 실패**: 3초 대기 후 실행 → 실패 시 예외 발생

### 에러 유형 및 처리

**1. 세션 상태 오류**
```java
if (!session.getStatus().isCompleted()) {
    throw new TrainException(SESSION_INVALID_STATUS);
}
```
* **원인**: 대화가 완료되지 않은 세션에 대한 피드백 생성 시도
* **HTTP 상태**: 400 Bad Request
* **메시지**: "세션 상태가 유효하지 않습니다"

**2. 중복 피드백**
```java
if (feedbackRepository.existsByDialogueSessionSessionId(sessionId)) {
    throw new TrainException(FEEDBACK_ALREADY_EXISTS);
}
```
* **원인**: 이미 피드백이 존재하는 세션
* **HTTP 상태**: 409 Conflict
* **메시지**: "이미 피드백이 생성되었습니다"

**3. 대화 내용 부족**
```java
if (userTranscripts.isEmpty()) {
    throw new TrainException(INSUFFICIENT_DIALOGUE_CONTENT,
            "분석 가능한 사용자 발화가 충분하지 않습니다.");
}
```
* **원인**: 분석 가능한 사용자 발화가 없음
* **HTTP 상태**: 400 Bad Request
* **메시지**: "분석할 대화 내용이 부족합니다"

**4. AI API 호출 실패**
```java
catch (Exception e) {
    log.error("ChatGPT 4.0 호출 실패", e);
    throw new Exception("AI API 호출에 실패했습니다: " + e.getMessage());
}
```
* **원인**: OpenAI API 네트워크 오류, 타임아웃, 할당량 초과 등
* **HTTP 상태**: 500 Internal Server Error
* **메시지**: "AI 분석에 실패했습니다"
* **재시도**: 최대 3회

**5. AI 응답 파싱 실패**
```java
catch (Exception e) {
    log.error("종합 분석 응답 파싱 실패", e);
    throw new TrainException(AI_RESPONSE_PARSE_ERROR,
            "종합 분석 결과 파싱에 실패했습니다: " + e.getMessage());
}
```
* **원인**: JSON 형식 오류, 필수 필드 누락, 타입 불일치 등
* **HTTP 상태**: 500 Internal Server Error
* **메시지**: "AI 응답 파싱에 실패했습니다"
* **재시도**: 최대 3회

### JSON 파싱 전략

**1. JSON 블록 추출:**
```java
private String extractJsonFromResponse(String response) {
    // 1순위: ```json 블록에서 JSON 추출
    int jsonStart = response.indexOf("```json");
    int jsonEnd = response.indexOf("```", jsonStart + 7);

    if (jsonStart != -1 && jsonEnd != -1) {
        return response.substring(jsonStart + 7, jsonEnd).trim();
    }

    // 2순위: { } 블록 찾기
    int braceStart = response.indexOf("{");
    int braceEnd = response.lastIndexOf("}");

    if (braceStart != -1 && braceEnd != -1) {
        return response.substring(braceStart, braceEnd + 1);
    }

    throw new TrainException(AI_RESPONSE_PARSE_ERROR,
            "AI 응답에서 JSON을 찾을 수 없습니다.");
}
```

**2. 필드 파싱 및 검증:**
```java
private FeedbackResponse parseComprehensiveResponse(String aiResponse,
                                                     DialogueSession dialogueSession) {
    try {
        String jsonContent = extractJsonFromResponse(aiResponse);
        JsonNode jsonNode = objectMapper.readTree(jsonContent);

        // 필수 필드 추출
        int totalScore = jsonNode.get("totalScore").asInt();
        int speechRateScore = jsonNode.get("speechRateScore").asInt();
        // ... 다른 필드들

        // 선택적 필드 파싱 (null 허용)
        FeedbackResponse.OverallAnalysis overallAnalysis =
            parseOverallAnalysis(jsonNode.get("overallAnalysis"));

        return FeedbackResponse.builder()
                .totalScore(totalScore)
                .speechRateScore(speechRateScore)
                // ...
                .overallAnalysis(overallAnalysis)
                .build();

    } catch (Exception e) {
        log.error("종합 분석 응답 파싱 실패", e);
        throw new TrainException(AI_RESPONSE_PARSE_ERROR, e.getMessage());
    }
}
```

**3. 안전한 선택적 필드 파싱:**
```java
private FeedbackResponse.OverallAnalysis parseOverallAnalysis(JsonNode overallNode) {
    if (overallNode == null || overallNode.isNull()) return null;

    try {
        return FeedbackResponse.OverallAnalysis.builder()
                .conversationFlow(overallNode.get("conversationFlow").asText())
                .communicationPattern(overallNode.get("communicationPattern").asText())
                .overallImprovements(parseImprovements(overallNode.get("overallImprovements")))
                .build();
    } catch (Exception e) {
        log.warn("전체 분석 파싱 실패", e);
        return null; // 선택적 필드이므로 null 반환
    }
}
```

---

## API 엔드포인트 명세

### 1. AI 자동 피드백 생성

**엔드포인트:** `POST /api/v1/feedbacks/sessions/{sessionId}`

**인증:** 필요 (AccessToken)

**요청:**
* Path Parameter: `sessionId` (String) - 피드백을 생성할 세션 ID

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "AI 피드백이 생성되었습니다.",
  "data": {
    "id": 1,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "scenarioId": 1,
    "scenarioTitle": "고객 불만 응대",
    "totalScore": 75,
    "scoreGrade": "C",
    "speechRateScore": 20,
    "fillerWordsScore": 15,
    "politenessScore": 22,
    "clarityScore": 18,
    "improvementPoints": "[{\"type\":\"filler_words\",\"description\":\"추임새 사용 빈도가 높습니다\",\"suggestion\":\"'음...', '그...' 등의 표현을 줄이세요\"}]",
    "originalTranscript": "음... 그게 말이죠, 저희가 최선을 다하고 있습니다.",
    "alternativeA": "저희가 최선을 다하고 있습니다.",
    "alternativeB": "고객님, 저희가 최선을 다해 해결하겠습니다.",
    "alternativeC": "걱정하지 마세요. 저희가 정성껏 도와드리겠습니다.",
    "chosenAlternative": null,
    "finalChoice": null,
    "isChoiceComplete": false,
    "createdAt": "2025-11-01T14:30:00",
    "updatedAt": "2025-11-01T14:30:00",
    "overallAnalysis": {
      "conversationFlow": "대화가 전반적으로 방어적인 태도로 진행되었습니다...",
      "communicationPattern": "사용자는 추임새를 자주 사용하며 자신감이 부족해 보입니다...",
      "overallImprovements": [
        {
          "category": "confidence",
          "description": "자신감 있는 태도 필요",
          "suggestion": "추임새를 줄이고 명확한 문장으로 말하세요"
        }
      ]
    },
    "sentenceAnalyses": [
      {
        "sequence": 1,
        "content": "음... 그게 말이죠, 저희가 최선을 다하고 있습니다.",
        "issues": [
          {
            "type": "filler_words",
            "count": 2,
            "impact": "high",
            "suggestion": "추임새를 제거하고 바로 본론으로 들어가세요"
          }
        ],
        "improvedVersion": "저희가 최선을 다하고 있습니다."
      }
    ],
    "conversationImprovement": {
      "currentPattern": "방어적이고 자신감 없는 대화 패턴",
      "improvedPattern": "자신감 있고 명확한 대화 패턴",
      "fullImprovedDialogue": "[개선된 전체 대화 예시]"
    }
  }
}
```

**에러 응답:**
* 400: 세션 미완료 또는 대화 내용 부족
* 409: 이미 피드백 존재
* 500: AI 분석 실패

---

### 2. 피드백 조회

**엔드포인트:** `GET /api/v1/feedbacks/{sessionId}`

**인증:** 필요 (AccessToken)

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "피드백 조회 성공",
  "data": {
    "id": 1,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "totalScore": 75,
    "scoreGrade": "C",
    // ... 나머지 필드
  }
}
```

---

### 3. 개선안 선택

**엔드포인트:** `PUT /api/v1/feedbacks/{sessionId}/choice`

**인증:** 필요 (AccessToken)

**요청 Body:**
```json
{
  "chosenAlternative": "A",  // A, B, C, CUSTOM
  "finalChoice": null        // CUSTOM 선택 시 필수
}
```

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "개선안이 선택되었습니다.",
  "data": {
    "id": 1,
    "chosenAlternative": "A",
    "finalChoice": "저희가 최선을 다하고 있습니다.",
    "isChoiceComplete": true
  }
}
```

---

### 4. 피드백 히스토리 조회

**엔드포인트:** `GET /api/v1/feedbacks/users/{userId}/history`

**인증:** 필요 (AccessToken)

**Query Parameters:**
* `page`: 페이지 번호 (기본값: 0)
* `size`: 페이지 크기 (기본값: 20)
* `sort`: 정렬 기준 (기본값: createdAt,desc)

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "피드백 히스토리 조회 성공",
  "data": {
    "content": [
      {
        "feedbackId": 1,
        "sessionId": "550e8400-e29b-41d4-a716-446655440000",
        "scenarioTitle": "고객 불만 응대",
        "totalScore": 75,
        "scoreGrade": "C",
        "isChoiceComplete": true,
        "createdAt": "2025-11-01T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 15,
    "totalPages": 1
  }
}
```

---

### 5. 피드백 통계 조회

**엔드포인트:** `GET /api/v1/feedbacks/users/{userId}/stats`

**인증:** 필요 (AccessToken)

**응답 (200 OK):**
```json
{
  "success": true,
  "message": "피드백 통계 조회 성공",
  "data": {
    "totalCount": 15,
    "averageScore": 78.5,
    "averageSpeechRateScore": 20.2,
    "averageFillerWordsScore": 18.5,
    "averagePolitenessScore": 21.3,
    "averageClarityScore": 18.5,
    "maxScore": 92,
    "minScore": 65,
    "recentWeekCount": 3,
    "recentMonthCount": 8,
    "completedChoiceCount": 12,
    "pendingChoiceCount": 3,
    "gradeDistribution": {
      "gradeA": 2,
      "gradeB": 5,
      "gradeC": 6,
      "gradeD": 2,
      "gradeF": 0
    },
    "monthlyScores": [
      {
        "yearMonth": "2025-10",
        "averageScore": 75.5,
        "count": 5
      },
      {
        "yearMonth": "2025-11",
        "averageScore": 82.3,
        "count": 10
      }
    ]
  }
}
```

---

## 피드백 통계 및 분석

### 통계 계산 로직

**1. 기본 통계:**
```java
// 총 피드백 수
long totalCount = feedbackRepository.countByUserId(userId);

// 평균 점수
Double averageScore = feedbackRepository.findAverageScoreByUserId(userId);

// 세부 항목별 평균
Object[] detailedAverages = feedbackRepository.findDetailedScoreAveragesByUserId(userId);
```

**2. 최근 활동:**
```java
LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
LocalDateTime monthAgo = LocalDateTime.now().minusDays(30);

List<Feedback> recentWeekFeedbacks =
    feedbackRepository.findByUserIdAndDateRange(userId, weekAgo, LocalDateTime.now());

List<Feedback> recentMonthFeedbacks =
    feedbackRepository.findByUserIdAndDateRange(userId, monthAgo, LocalDateTime.now());
```

**3. 등급 분포:**
```java
private FeedbackStatsResponse.GradeDistribution calculateGradeDistribution(
        List<Feedback> feedbacks) {
    long gradeA = feedbacks.stream().filter(f -> f.getTotalScore() >= 90).count();
    long gradeB = feedbacks.stream().filter(f -> f.getTotalScore() >= 80 && f.getTotalScore() < 90).count();
    long gradeC = feedbacks.stream().filter(f -> f.getTotalScore() >= 70 && f.getTotalScore() < 80).count();
    long gradeD = feedbacks.stream().filter(f -> f.getTotalScore() >= 60 && f.getTotalScore() < 70).count();
    long gradeF = feedbacks.stream().filter(f -> f.getTotalScore() < 60).count();

    return FeedbackStatsResponse.GradeDistribution.builder()
            .gradeA(gradeA)
            .gradeB(gradeB)
            .gradeC(gradeC)
            .gradeD(gradeD)
            .gradeF(gradeF)
            .build();
}
```

**4. 월별 추이 (최근 6개월):**
```java
private List<FeedbackStatsResponse.MonthlyScore> calculateMonthlyScores(
        List<Feedback> feedbacks) {
    List<FeedbackStatsResponse.MonthlyScore> monthlyScores = new ArrayList<>();

    LocalDateTime now = LocalDateTime.now();
    for (int i = 5; i >= 0; i--) {
        LocalDateTime monthStart = now.minusMonths(i)
                .withDayOfMonth(1)
                .withHour(0).withMinute(0).withSecond(0);
        LocalDateTime monthEnd = monthStart.plusMonths(1).minusSeconds(1);

        List<Feedback> monthFeedbacks = feedbacks.stream()
                .filter(f -> f.getCreatedAt().isAart)
                          && f.getCreatedAt().isBefore(monthEnd))
                .toList();

        if (!monthFeedbacks.isEmpty()) {
            double avgScore = monthFeedbacks.stream()
                    .mapToInt(Feedback::getTotalScore)
                    .average()
                    .orElse(0.0);

            monthlyScores.add(FeedbackStatsResponse.MonthlyScore.builder()
                    .yearMonth(String.format("%04d-%02d",
                            monthStart.getYear(), monthStart.getMonthValue()))
                    .averageScore(Math.round(avgScore * 10.0) / 10.0)
                    .count((long) monthFeedbacks.size())
                    .build());
        }
    }

    return monthlyScores;
}
```

### 성장 추이 분석

**사용 사례:**
* 사용자 대시보드에 성장 그래프 표시
* 월별 평균 점수 변화 추적
* 학습 효과 측정
* 개선 영역 식별

**프론트엔드 활용 예시:**
```javascript
// 월별 점수 추이 그래프
const chartData = {
  labels: stats.monthlyScores.map(m => m.yearMonth),
  datasets: [{
    label: '평균 점수',
    data: stats.monthlyScores.map(m => m.averageScore),
    borderColor: 'rgb(75, 192, 192)',
    tension: 0.1
  }]
};

// 등급 분포 파이 차트
const gradeData = {
  labels: ['A', 'B', 'C', 'D', 'F'],
  datasets: [{
    data: [
      stats.gradeDistribution.gradeA,
      stats.gradeDistribution.gradeB,
      stats.gradeDistribution.gradeC,
      stats.gradeDistribution.gradeD,
      stats.gradeDistribution.gradeF
    ]
  }]
};
```

---

## 성능 최적화

### 1. 단일 AI 호출

**최적화 전 (다중 호출):**
```
1. 전체 분석 호출 (1회)
2. 문장별 분석 호출 (N회)
3. 개선안 생성 호출 (1회)
총: N+2회 호출
```

**최적화 후 (단일 호출):**
```
1. 종합 분석 호출 (1회)
   - 전체 분석
   - 문장별 분석
   - 개선안 생성
총: 1회 호출
```

**효과:**
* API 호출 비용 절감: 약 70-90%
* 응답 시간 단축: 약 60-80%
* 일관성 향상: 단일 컨텍스트에서 분석

### 2. 데이터베이스 최적화

**인덱스 전략:**
```sql
-- 세션 ID 조회 최적화
CREATE INDEX idx_feedback_session_id ON feedbacks(session_id);

-- 사용자별 히스토리 조회 최적화
CREATE INDEX idx_session_user_id ON dialogue_sessions(user_id);

-- 생성일 기준 정렬 최적화
CREATE INDEX idx_feedback_created_at ON feedbacks(created_at);

-- Transcript 조회 최적화
CREATE INDEX idx_transcript_session_id ON transcripts(session_id);
```

**N+1 문제 해결:**
```java
// Fetch Join 사용
@Query("SELECT ds FROM DialogueSession ds " +
       "JOIN FETCH ds.user " +
       "JOIN FETCH ds.scenario " +
       "WHERE ds.sessionId = :sessionId")
DialogueSession findBySessionIdWithUserAndScenario(@Param("sessionId") String sessionId);
```

### 3. 캐싱 전략

**통계 데이터 캐싱:**
```java
@Cacheable(value = "feedbackStats", key = "#userId")
public FeedbackStatsResponse getFeedbackStats(Long userId) {
    // 통계 계산 로직
}

@CacheEvict(value = "feedbackStats", key = "#userId")
public FeedbackResponse generateFeedbackWithAI(String sessionId) {
    // 새 피드백 생성 시 캐시 무효화
}
```

### 4. 비동기 처리 (선택적)

**대용량 히스토리 조회:**
```java
@Async
public CompletableFuture<List<FeedbackHistoryResponse>> getAllFeedbackHistoryAsync(Long userId) {
    List<Feedback> feedbacks = feedbackRepository.findByUserIdOrderByCreatedAtDesc(userId);
    List<FeedbackHistoryResponse> responses = feedbacks.stream()
            .map(FeedbackHistoryResponse::from)
            .collect(Collectors.toList());
    return CompletableFuture.completedFuture(responses);
}
```

### 5. AI 응답 타임아웃 설정

**application.yml:**
```yaml
spring:
  ai:
    openai:
      chat:
        options:
          timeout: 30s  # 30초 타임아웃
```

---

## 부록

### AI 응답 예시

**전체 JSON 응답:**
```json
{
  "totalScore": 75,
  "speechRateScore": 20,
  "fillerWordsScore": 15,
  "politenessScore": 22,
  "clarityScore": 18,
  "improvementPoints": [
    {
      "type": "filler_words",
      "description": "추임새 사용 빈도가 높습니다 (5회)",
      "suggestion": "'음...', '그...' 등의 표현을 줄이고 잠시 멈춤으로 대체하세요"
    },
    {
      "type": "incomplete_sentence",
      "description": "문장이 완결되지 않은 경우가 있습니다 (3회)",
      "suggestion": "문장을 끝까지 완성하여 명확하게 전달하세요"
    }
  ],
  "originalTranscript": "음... 그게 말이죠, 저희가 최선을 다하고 있습니다.",
  "alternativeA": "저희가 최선을 다하고 있습니다.",
  "alternativeB": "고객님, 저희가 최선을 다해 해결하겠습니다.",
  "alternativeC": "걱정하지 마세요. 저희가 정성껏 도와드리겠습니다.",
  "overallAnalysis": {
    "conversationFlow": "대화가 전반적으로 방어적인 태도로 진행되었으며, 고객의 불만을 적극적으로 해결하려는 자세가 부족했습니다. 추임새가 많아 자신감이 부족해 보이며, 명확한 해결책 제시가 미흡했습니다.",
    "communicationPattern": "사용자는 추임새를 자주 사용하며 문장을 완결하지 못하는 경향이 있습니다. 공손한 표현은 사용하고 있으나, 구체적인 설명이 부족하여 신뢰감을 주기 어렵습니다.",
    "overallImprovements": [
      {
        "category": "confidence",
        "description": "자신감 있는 태도 필요",
        "suggestion": "추임새를 줄이고 명확한 문장으로 말하세요. 잠시 멈춤을 활용하여 생각을 정리한 후 말하는 것이 좋습니다."
      },
      {
        "category": "structure",
        "description": "체계적인 대화 구조 필요",
        "suggestion": "문제 파악 → 공감 표현 → 해결책 제시 → 확인의 순서로 대화를 구조화하세요."
      }
    ]
  },
  "sentenceAnalyses": [
    {
      "sequence": 1,
      "content": "음... 그게 말이죠, 저희가 최선을 다하고 있습니다.",
      "issues": [
        {
          "type": "filler_words",
          "count": 2,
          "impact": "high",
          "suggestion": "추임새('음...', '그게 말이죠')를 제거하고 바로 본론으로 들어가세요"
        },
        {
          "type": "vague_explanation",
          "count": 1,
          "impact": "medium",
          "suggestion": "'최선을 다하고 있다'는 추상적입니다. 구체적인 조치를 설명하세요"
        }
      ],
      "improvedVersion": "저희가 현재 문제 해결을 위해 담당 부서와 협의 중입니다."
    },
    {
      "sequence": 2,
      "content": "그러니까... 조금만 기다려 주시면...",
      "issues": [
        {
          "type": "filler_words",
          "count": 1,
          "impact": "high",
          "suggestion": "'그러니까...'를 제거하세요"
        },
        {
          "type": "incomplete_sentence",
          "count": 1,
          "impact": "high",
          "suggestion": "문장을 완결하여 명확하게 전달하세요"
        }
      ],
      "improvedVersion": "잠시만 기다려 주시면 확인 후 바로 연락드리겠습니다."
    }
  ],
  "conversationImprovement": {
    "currentPattern": "방어적이고 자신감 없는 대화 패턴. 추임새가 많고 구체적인 해결책 제시가 부족함.",
    "improvedPattern": "자신감 있고 명확한 대화 패턴. 구체적인 조치와 일정을 제시하여 신뢰감을 줌.",
    "fullImprovedDialogue": "[고객] 제품에 문제가 있는데 언제 해결되나요?\n[개선된 응답] 고객님, 불편을 드려 죄송합니다. 현재 문제를 확인 중이며, 오늘 오후 3시까지 담당자가 직접 연락드려 해결 방안을 안내해 드리겠습니다. 추가로 궁금하신 사항이 있으시면 언제든지 말씀해 주세요."
  }
}
```

### 환경 변수 설정

**application.yml:**
```yaml
spring:
  ai:
    openai:
      api-key: ${OPENAI_API_KEY}
      chat:
        options:
          model: gpt-4o
          temperature: 0.7
          max-tokens: 4000
          timeout: 30s

  datasource:
    url: jdbc:mysql://localhost:3306/train_db
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}

  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true

logging:
  level:
    com.aid.train.backend.domain.feedback: DEBUG
    org.springframework.ai: INFO
```

**.env 파일:**
```env
OPENAI_API_KEY=sk-proj-...
DB_USERNAME=train_user
DB_PASSWORD=your_password
```

### 주요 의존성

**build.gradle:**
```gradle
dependencies {
    // Spring Boot
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'

    // Spring AI
    implementation 'org.springframework.ai:spring-ai-openai-spring-boot-starter:1.0.0-M3'

    // Database
    runtimeOnly 'com.mysql:mysql-connector-j'

    // JSON
    implementation 'com.fasterxml.jackson.core:jackson-databind'
    implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'

    // Lombok
    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'

    // Test
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

---

## 향후 개선사항 로드맵

### 단기 계획 (1-3개월)

#### 1. 점수 산정 기준 명확화

* **목표**: AI 점수 산정의 투명성 및 일관성 향상
* **방안**:
  - 프롬프트에 명시적 점수 기준 추가 (발화속도: 150-180 음절/분 = 25점, 추임새: 0-1개 = 25점 등)
  - 각 점수 구간별 구체적 예시 포함
  - AI가 점수 산정 이유를 설명하도록 요청

#### 2. Fallback 전략 도입

* **목표**: AI 분석 실패 시에도 최소한의 피드백 제공
* **방안**:
  - 1단계: 정상 프롬프트 (최대 3회 재시도)
  - 2단계: 간소화 프롬프트 (1회 시도, 점수만 산정)
  - 3단계: 기본 피드백 (고정 점수 70점 제공)

#### 3. AI 응답 품질 개선

* **목표**: 파싱 실패율 0.1% 이하로 감소
* **방안**:
  - Structured Output API 도입 (OpenAI Function Calling)
  - JSON Schema 기반 응답 강제
  - 응답 검증 로직 강화 (Pydantic 스타일 검증)
  - Few-shot 예시 프롬프트 추가

#### 4. 재시도 전략 고도화

* **목표**: 일시적 오류 복구율 95% 이상
* **방안**:
  - 지수 백오프(Exponential Backoff)로 전환 (1초 → 2초 → 4초)
  - Circuit Breaker 패턴 도입 (연속 실패 시 일시 중단)
  - 재시도 횟수를 동적으로 조정 (API 상태 기반)

#### 5. 비용 최적화 전략

* **목표**: API 비용 30% 절감
* **방안**:
  - 티어별 차등 모델 (무료: GPT-4o-mini, 유료: GPT-4o)
  - 프롬프트 길이 최적화 (핵심 발화만 선택, 30% 절감)
  - 배치 처리 (Batch API 활용, 50% 할인)
  - 캐싱 전략 (유사 패턴 재사용)

#### 6. 보안 및 프라이버시 강화

* **목표**: 사용자 데이터 보호 및 규정 준수
* **방안**:
  - API 키 관리 (AWS Secrets Manager, 3개월마다 로테이션)
  - 대화 내용 암호화 저장 (AES-256)
  - 데이터 보관 정책 (30일 후 자동 삭제)
  - GDPR 대응 (데이터 삭제/다운로드 기능)

#### 7. 프롬프트 버전 관리 시스템

* **목표**: 배포 없이 프롬프트 수정 및 A/B 테스트
* **방안**:
  - DB 기반 프롬프트 템플릿 관리
  - 버전별 활성화/비활성화
  - A/B 테스트 지원
  - 롤백 기능

#### 8. 모니터링 및 알림 시스템

* **목표**: AI 성능 실시간 추적 및 이상 감지
* **방안**:
  - AOP 기반 메트릭 수집 (응답 시간, 파싱 성공률, 재시도 발생률)
  - Slack 알림 (파싱 실패율 10% 초과, API 비용 80% 초과 등)
  - Grafana 대시보드 구축

#### 9. 실시간 피드백 프리뷰

* **목표**: 대화 중 실시간 간단 피드백 제공
* **방안**:
  - WebSocket 기반 스트리밍 분석
  - 발화 직후 즉시 간단한 점수 표시
  - 추임새/발화속도 실시간 카운팅
  - 최종 피드백은 세션 완료 후 상세 분석

#### 10. 캐싱 및 성능 최적화

* **목표**: 응답 시간 50% 단축
* **방안**:
  - Redis 기반 통계 데이터 캐싱
  - DB 쿼리 최적화 (Batch Fetch, Query Hint)
  - AI 응답 부분 캐싱 (유사 대화 패턴)
  - CDN을 통한 정적 개선안 템플릿 제공

---

### 중기 계획 (3-6개월)

#### 1. 다중 AI 모델 지원

* **목표**: 비용 최적화 및 품질 향상
* **방안**:
  - GPT-4o (상세 분석), GPT-4o-mini (간단 분석) 선택적 사용
  - Claude 3.5 Sonnet 통합 (대안 모델)
  - 모델별 성능/비용 비교 대시보드
  - A/B 테스트로 최적 모델 선정

#### 2. 맞춤형 피드백 생성

* **목표**: 사용자 수준별 개인화된 피드백
* **방안**:
  - 사용자 프로필 기반 난이도 조정
  - 과거 피드백 이력 반영 (반복 문제 강조)
  - 직업군별 특화 분석 (고객 응대, 면접, 프레젠테이션)
  - 학습 목표 설정 및 진도 추적

#### 3. 음성 특징 분석 추가

* **목표**: 텍스트 외 음성 데이터 활용
* **방안**:
  - 음성 톤 분석 (감정, 자신감 수준)
  - 발화 속도 정밀 측정 (음절/분)
  - 억양 패턴 분석
  - 침묵 구간 분석 (적절한 pause)

#### 4. 피드백 품질 평가 시스템

* **목표**: AI 피드백의 정확도 검증
* **방안**:
  - 사용자 만족도 평가 (5점 척도)
  - 전문가 검수 샘플링 (월 100건)
  - 피드백 수용률 추적 (개선안 선택 비율)
  - 품질 메트릭 대시보드

---

### 장기 계획 (6-12개월)

#### 1. Fine-tuned 전용 모델 개발

* **목표**: 대화 훈련 특화 AI 모델
* **방안**:
  - 자체 데이터셋 구축 (10,000+ 대화 샘플)
  - GPT-4o Fine-tuning (OpenAI API)
  - 도메인 특화 프롬프트 최적화
  - 한국어 대화 특성 반영 강화

#### 2. 멀티모달 분석

* **목표**: 음성 + 텍스트 + 영상 통합 분석
* **방안**:
  - 표정 분석 (웹캠 활용)
  - 제스처 분석 (자세, 손동작)
  - 시선 처리 분석
  - 종합 커뮤니케이션 점수 산출

#### 3. 실시간 코칭 시스템

* **목표**: 대화 중 즉각적인 가이드 제공
* **방안**:
  - 실시간 문제 감지 (추임새 과다 등)
  - 화면 알림으로 즉시 피드백
  - 대화 흐름 가이드 제시
  - AI 코치 음성 안내 (선택적)

#### 4. 협업 학습 기능

* **목표**: 팀 단위 학습 및 비교 분석
* **방안**:
  - 팀 평균 점수 대시보드
  - 동료 피드백 시스템
  - 베스트 프랙티스 공유
  - 팀 리더보드 및 성과 추적

#### 5. 산업별 특화 시나리오

* **목표**: 직무별 맞춤 훈련 콘텐츠
* **방안**:
  - 콜센터 전용 시나리오 (100+)
  - 영업/마케팅 시나리오
  - 의료/법률 전문 용어 대응
  - 산업별 평가 기준 차별화

---

### 초장기 계획 (12개월 이상)

#### 1. 자체 AI 모델 개발

* **목표**: 완전 독립적인 AI 인프라 구축
* **방안**:
  - LLaMA 3 기반 자체 모델 학습
  - 한국어 대화 특화 데이터셋 (100,000+ 샘플)
  - 온프레미스 GPU 클러스터 구축
  - API 비용 제로화 및 데이터 주권 확보

#### 2. 뇌과학 기반 학습 최적화

* **목표**: 과학적 학습 효과 극대화
* **방안**:
  - 간격 반복 학습(Spaced Repetition) 알고리즘
  - 망각 곡선 기반 복습 스케줄링
  - 인지 부하 최적화 (난이도 자동 조절)
  - 학습 효과 뇌파 측정 연구 (선택적)

#### 3. 글로벌 다국어 지원

* **목표**: 전 세계 시장 진출
* **방안**:
  - 영어, 중국어, 일본어 등 10개 언어 지원
  - 문화권별 대화 예절 반영
  - 현지 전문가 검수 시스템
  - 글로벌 벤치마크 데이터 구축

#### 4. AI 튜터 에이전트

* **목표**: 완전 자율 학습 시스템
* **방안**:
  - 개인별 학습 계획 자동 생성
  - 약점 분석 및 맞춤 훈련 제공
  - 장기 성장 목표 설정 및 관리
  - 동기부여 및 격려 메시지 자동 생성

#### 5. 메타버스 통합

* **목표**: 가상 환경에서의 몰입형 훈련
* **방안**:
  - VR 기반 대화 시뮬레이션
  - 아바타 간 실시간 대화 훈련
  - 가상 회의실/상담실 환경 구현
  - 햅틱 피드백 (긴장도 감지)

#### 6. 산업 표준 플랫폼

* **목표**: 대화 훈련 분야의 de facto 표준
* **방안**:
  - 오픈 API 제공 (타 서비스 연동)
  - 플러그인 생태계 구축
  - 학술 연구 데이터 공개 (익명화)
  - 국제 표준화 기구 협력

---

### 개선사항 우선순위 매트릭스

| 항목 | 영향도 | 난이도 | 우선순위 |
|------|--------|--------|----------|
| 점수 산정 기준 명확화 | 높음 | 낮음 | ⭐⭐⭐⭐⭐ |
| Fallback 전략 | 높음 | 낮음 | ⭐⭐⭐⭐⭐ |
| Structured Output API | 높음 | 낮음 | ⭐⭐⭐⭐⭐ |
| 실시간 피드백 프리뷰 | 높음 | 중간 | ⭐⭐⭐⭐⭐ |
| 비용 최적화 | 높음 | 중간 | ⭐⭐⭐⭐ |
| 보안 강화 | 높음 | 중간 | ⭐⭐⭐⭐ |
| 프롬프트 버전 관리 | 중간 | 낮음 | ⭐⭐⭐⭐ |
| 모니터링 | 중간 | 낮음 | ⭐⭐⭐⭐ |
| 캐싱 최적화 | 중간 | 낮음 | ⭐⭐⭐⭐ |
| 다중 AI 모델 지원 | 높음 | 중간 | ⭐⭐⭐⭐ |
| 맞춤형 피드백 | 높음 | 높음 | ⭐⭐⭐⭐ |
| Fine-tuned 모델 | 매우높음 | 높음 | ⭐⭐⭐ |
| 멀티모달 분석 | 높음 | 매우높음 | ⭐⭐⭐ |
| 자체 AI 모델 | 매우높음 | 매우높음 | ⭐⭐ |

---

### 예상 효과

**단기 개선 후 (1-3개월):**

- 점수 일관성: 20% 향상
- 피드백 제공 성공률: 95% → 99.9%
- AI 응답 파싱 성공률: 95% → 99.9%
- 평균 응답 시간: 5초 → 2.5초
- API 비용: 30% 절감
- 사용자 이탈률: 50% 감소

**중기 개선 후 (3-6개월):**

- 사용자 만족도: 85% → 95%
- 피드백 정확도: 90% → 95%
- 학습 효과: 40% 향상

**장기 개선 후 (6-12개월):**

- 시장 점유율: 업계 1위
- 월간 활성 사용자: 100만+
- 글로벌 진출: 10개국

**초장기 개선 후 (12개월 이상):**

- API 비용: 제로화
- 완전 자율 학습 시스템 구축
- 대화 훈련 분야 글로벌 표준

---

## 참고 자료 (References)

* [Spring AI Documentation](https://docs.spring.io/spring-ai/reference/)
* [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
* [OpenAI ChatGPT 4.0 Model](https://platform.openai.com/docs/models/gpt-4)
* [Prompt Engineering Guide](https://www.promptingguide.ai/)
* [JSON Schema Specification](https://json-schema.org/)

---

변경 이력 (Change Log)

| 버전 | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|--------|----------------|
| v1.0 | 2025.11.01 | 왕택준 | 최초 작성 |