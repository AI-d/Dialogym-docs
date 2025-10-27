# 팀 AId 회의록

**담당자:** [진도희](https://github.com/dohee-jin)

**일시**: 2025.10.24

**장소**: 학원

**참석자**:  왕택준(팀장), 김경민(SM), 진도희  

---

## 1. 오늘 다룬 의제

1. 배포 과정에서 발생한 DNS 레코드 충돌 및 리다이렉트 문제 해결
2. Feedback 기능 구현 방향 공유
3. GPT Realtime API 아키텍처 개선 (WebSocket → WebRTC P2P)

---

## 2. 주요 논의  

* **왕택준 (팀장)**
  * Feedback 중심 단순 조회 모델 설계 공유
  * History 기능을 별도 엔티티가 아닌 조회 기능으로 구현하기로 결정
  * `DialogueSession` ↔ `Feedback` 1:1 관계 설계
  * 데이터 정합성 우선, 통계 조회 성능은 추후 최적화로 대응

* **김경민**
  * 프론트엔드-백엔드 도메인 DNS 레코드 충돌 문제 해결
  * Nginx 설정 변경 및 도메인 구조 분리 완료
  * Route 53으로 DNS 관리 체계 이전 계획 수립
  * `api.dialogym.shop` 백엔드 전용 도메인으로 분리 완료
  
* **진도희**
  * GPT Realtime API 통신 방식 개선 (WebSocket → WebRTC P2P)
  * GPT 음성 응답 재생 기능 및 사용자 인터랙션 상태 관리 구현
  * 오디오 큐 시스템, 턴 테이킹 로직 추가
  * `isSpeaking`, `isAiResponding` 상태로 자연스러운 대화 흐름 제어

---

## 3. 결정 사항

* **인프라**: DNS 관리를 가비아에서 AWS Route 53으로 전면 이전
* **백엔드**: Feedback 기능은 단순 조회 모델(Option 2)로 구현
* **프론트엔드**: WebRTC P2P 아키텍처로 전환하여 실시간 음성 대화 품질 개선

---

## 4. 공통 작업

### 회의 중 공동 합의·진행 사항
* 도메인 구조 정리 완료 (백엔드: `api.dialogym.shop`, 프론트: `www.dialogym.shop`)
* 각 파트별 기술 스택 및 구현 방향 공유

### 회의 후 공통 TODO
* Route 53 네임서버 전환 후 전체 도메인 동작 검증
* API 연동 테스트 (프론트-백엔드 간 Feedback 기능)

---

## 5. 개별 담당 (순서: 팀장, 팀원 가나다 순)

* **왕택준 (팀장)**
  * `domain/history` 패키지 삭제
  * `Feedback` 엔티티 설계 및 JPA 구현
  * `FeedbackRepository` 구현 (주요 조회 쿼리 작성)
  * Feedback 관련 DTO 4종 설계
    * `FeedbackCreateRequest`, `FeedbackChoiceRequest`, `FeedbackResponse`, `FeedbackHistoryResponse`
  * `FeedbackService` 비즈니스 로직 구현
    * `createFeedback`, `chooseAlternative`, `getFeedback`, `getFeedbackHistory`
  * `FeedbackController` API 엔드포인트 구현
    * `POST /api/v1/feedbacks`
    * `PUT /api/v1/feedbacks/{sessionId}/choice`
    * `GET /api/v1/feedbacks/{sessionId}`
    * `GET /api/v1/feedbacks/users/{userId}/history`
  * Swagger (OpenAPI) 문서화 적용

* **김경민**
  * Route 53 네임서버 전환 작업
  * Route 53 레코드 구성 (dialogym.shop, www.dialogym.shop → CloudFront / api.dialogym.shop → EC2)
  * CloudFront 인증서 검증 및 정책 확인
  * 최종 도메인 접근 테스트 (curl 검증)
  
  
* **진도희**
  * WebRTC P2P 아키텍처 전환 작업 완료
  * GPT 음성 응답 재생 기능 구현
    * 오디오 큐 시스템 구현
    * 턴 테이킹 로직 구현
  * 사용자 인터랙션 상태 관리 개선
    * `isSpeaking`, `isAiResponding` 상태 추가
  * 세션 관리 개선 (axios를 통한 동적 sessionId 사용)
  
---

## 6. 리스크 및 이슈

* **DNS 전파 시간**: Route 53 네임서버 변경 후 전파 완료까지 최대 48시간 소요 가능
* **통계 조회 성능**: Feedback 데이터가 대량 누적될 경우 조회 성능 저하 가능성 존재 (추후 캐싱/집계 테이블로 최적화 필요)
* **WebRTC 브라우저 호환성**: 일부 구형 브라우저에서 WebRTC 지원 제한 가능성

---

## 7. 차기 회의 계획

* **일정**: 2025.10.27

* **예상 의제**:
  * Route 53 전환 결과 및 도메인 동작 확인
  * Feedback API 구현 진행 상황 점검
  * WebRTC 전환 후 음성 대화 품질 테스트 결과 공유
  * 프론트-백엔드 통합 테스트 계획