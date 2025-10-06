# 롤백 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **DevOps 엔지니어**: 배포 실패 시 롤백을 수행하는 담당자
* **백엔드/프론트엔드 개발자**: 배포 후 문제 발생 시 즉시 대응하는 담당자
* **인프라 관리자**: 시스템 장애 시 복구를 책임지는 담당자

---

## 핵심 요약 (Executive Summary)

본 문서는 배포 실패 또는 프로덕션 장애 시 롤백 절차를 정의합니다.
백엔드는 Kubernetes에서 kubectl rollout undo 명령으로 이전 버전으로 즉시 롤백합니다.
프론트엔드는 S3에서 이전 빌드를 재배포하고 CloudFront 캐시를 무효화합니다.
데이터베이스 마이그레이션이 포함된 경우 별도의 복구 절차가 필요합니다.
롤백 후에는 원인 분석과 재발 방지 대책 수립이 필수입니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [롤백 판단 기준](#롤백-판단-기준)
3. [백엔드 롤백](#백엔드-롤백)
4. [프론트엔드 롤백](#프론트엔드-롤백)
5. [데이터베이스 롤백](#데이터베이스-롤백)
6. [긴급 핫픽스](#긴급-핫픽스)
7. [롤백 후 조치](#롤백-후-조치)

---

## 문서 개요 (Overview)

본 문서는 배포 실패와 장애 상황에서의 롤백 절차를 명확히 하기 위해 작성되었습니다.

프로덕션 환경에서 문제가 발생하면 빠른 롤백이 서비스 안정성을 유지하는 핵심입니다. 백엔드는 K8s 롤백, 프론트엔드는 S3 재배포를 통해 신속하게 복구합니다.

---

## 롤백 판단 기준

### 즉시 롤백

다음 상황에서는 즉시 롤백합니다:

- 서비스 응답 불가 (5xx 에러 급증)
- 핵심 기능 작동 불가 (로그인, 결제 등)
- 데이터 손실 또는 무결성 위반
- 보안 취약점 발견
- Java 애플리케이션 크래시

### 모니터링 후 판단

다음 상황에서는 모니터링 후 판단합니다:

- 일부 기능 오동작 (우회 가능)
- 성능 저하 (허용 범위 내)
- UI 버그 (기능 영향 없음)
- GC 일시 정지 증가 (임계치 이하)

### 롤백 불필요

다음 상황에서는 핫픽스로 대응합니다:

- 경미한 UI 스타일 이슈
- 로그 오류 (서비스 영향 없음)
- 문서 오타

---

## 백엔드 롤백

### Kubernetes 롤백

```bash
# 1. 현재 배포 상태 확인
kubectl get pods --namespace=production -l app=backend
kubectl rollout status deployment/backend-deployment --namespace=production

# 2. 이전 버전으로 즉시 롤백
kubectl rollout undo deployment/backend-deployment --namespace=production

# 3. 특정 리비전으로 롤백
kubectl rollout history deployment/backend-deployment --namespace=production
kubectl rollout undo deployment/backend-deployment --to-revision=3 --namespace=production

# 4. 롤백 상태 확인
kubectl rollout status deployment/backend-deployment --namespace=production
kubectl get pods --namespace=production -l app=backend
```

### 수동 이미지 변경

```bash
# 1. 안정 버전 이미지 태그 확인
aws ecr describe-images --repository-name dialogym-backend --region ap-northeast-2

# 2. 특정 이미지로 롤백
kubectl set image deployment/backend-deployment \
  backend=<계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/dialogym-backend:<stable-tag> \
  --namespace=production \
  --record

# 3. 상태 확인
kubectl rollout status deployment/backend-deployment --namespace=production
```

### Spring Boot Actuator 확인

```bash
# API 헬스체크
curl https://api.dialogym.com/actuator/health

# JVM 메모리 확인
curl https://api.dialogym.com/actuator/metrics/jvm.memory.used

# Pod 로그 확인
kubectl logs -f <pod-name> --namespace=production

# 에러 로그 필터링
kubectl logs <pod-name> --namespace=production | grep ERROR
```

### JAR 버전 확인

```bash
# Pod 내부에서 JAR 정보 확인
kubectl exec -it <pod-name> --namespace=production -- sh
java -jar app.jar --version

# Manifest 확인
unzip -p app.jar META-INF/MANIFEST.MF
```

---

## 프론트엔드 롤백

### S3 이전 버전 복구

```bash
# 1. S3 버킷의 버전 확인
aws s3api list-object-versions \
  --bucket dialogym-frontend-production \
  --prefix index.html

# 2. 이전 빌드 다운로드 (로컬에 백업이 있는 경우)
# Git 커밋 해시로 재빌드
git checkout <previous-commit>
cd frontend
npm ci
npm run build:production

# 3. S3 재배포
aws s3 sync dist/ s3://dialogym-frontend-production \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "index.html" \
  --exclude "*.html"

aws s3 sync dist/ s3://dialogym-frontend-production \
  --delete \
  --cache-control "no-cache, no-store, must-revalidate" \
  --exclude "*" \
  --include "*.html"
```

### CloudFront 캐시 무효화

```bash
# 전체 캐시 무효화
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/*"

# 특정 파일만 무효화
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/index.html" "/assets/*"

# 무효화 상태 확인
aws cloudfront get-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --id <INVALIDATION_ID>
```

### 확인

```bash
# S3 버킷 내용 확인
aws s3 ls s3://dialogym-frontend-production/ --recursive

# 브라우저 확인 (캐시 비활성화)
curl -I https://dialogym.com

# Lighthouse 성능 확인
lighthouse https://dialogym.com --output json
```

---

## 데이터베이스 롤백

### Flyway/Liquibase 마이그레이션 롤백

**Flyway 사용 시:**

```bash
# 마이그레이션 히스토리 확인
./gradlew flywayInfo

# 이전 버전으로 롤백 (rollback SQL 필요)
./gradlew flywayUndo

# 특정 버전으로 롤백
./gradlew flywayUndo -Dflyway.target=2
```

**Liquibase 사용 시:**

```bash
# 마이그레이션 히스토리 확인
./gradlew liquibaseHistory

# 특정 태그로 롤백
./gradlew liquibaseRollback -PliquibaseCommandValue=version_1.0
```

### 수동 SQL 롤백

```bash
# 1. RDS 접속
kubectl run -it --rm psql-client \
  --image=postgres:15 \
  --restart=Never \
  --namespace=production \
  -- psql -h <RDS_ENDPOINT> -U dbadmin -d dialogym_production

# 2. 수동 롤백 SQL 실행
BEGIN;

-- 예시: 테이블 컬럼 삭제
ALTER TABLE users DROP COLUMN new_column;

-- 확인 후 커밋
COMMIT;
-- 문제 발생 시: ROLLBACK;
```

### RDS 스냅샷 복구

```bash
# 1. 최신 스냅샷 확인
aws rds describe-db-snapshots \
  --db-instance-identifier dialogym-production-db \
  --region ap-northeast-2 \
  --query 'DBSnapshots[*].[DBSnapshotIdentifier,SnapshotCreateTime]' \
  --output table

# 2. 스냅샷에서 복구 (새 인스턴스 생성)
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier dialogym-production-db-restored \
  --db-snapshot-identifier <SNAPSHOT_ID> \
  --region ap-northeast-2

# 3. 엔드포인트 전환 (K8s Secret 업데이트)
kubectl edit secret backend-secrets --namespace=production
# datasource-url 값을 새 엔드포인트로 변경

# 4. 백엔드 재시작
kubectl rollout restart deployment/backend-deployment --namespace=production
```

### 백업에서 복구

```bash
# 1. 백업 다운로드 (S3 등)
aws s3 cp s3://dialogym-backups/db-backup-2025-10-07.sql.gz .

# 2. 백업 복원
gunzip db-backup-2025-10-07.sql.gz
psql -h <RDS_ENDPOINT> -U dbadmin -d dialogym_production < db-backup-2025-10-07.sql
```

---

## 긴급 핫픽스

### 시나리오: 프로덕션 긴급 수정

```bash
# 1. main 브랜치에서 hotfix 브랜치 생성
git switch main
git pull origin main
git switch -c hotfix/TRAIN-999-critical-fix

# 2. 수정 및 테스트
# 코드 수정
./gradlew test  # 백엔드 테스트
npm test        # 프론트엔드 테스트

# 3. 커밋
git add .
git commit -m "TRAIN-999 hotfix: 긴급 수정"

# 4. main에 직접 푸시
git push origin hotfix/TRAIN-999-critical-fix

# 5. PR 생성 및 즉시 병합
# GitHub에서 PR 생성 → Approve → Merge

# 6. 배포 확인
# GitHub Actions가 자동 배포
# 또는 수동 배포
kubectl set image deployment/backend-deployment \
  backend=<ECR_REGISTRY>/dialogym-backend:latest \
  --namespace=production

# 7. dev에도 동기화 (cherry-pick)
git switch dev
git cherry-pick <hotfix-commit-sha>
git push origin dev
```

### 긴급 배포 체크리스트

- 최소 1명 리뷰어 승인
- 테스트 통과 확인
- 롤백 계획 수립
- 팀 공지 (Slack 등)
- 배포 후 모니터링 (Actuator, CloudWatch)

---

## 롤백 후 조치

### 즉시 조치

```bash
# 1. 서비스 상태 확인
curl https://api.dialogym.com/actuator/health
curl https://dialogym.com

# 2. 로그 수집
kubectl logs --tail=1000 -l app=backend --namespace=production > backend-error-logs.txt

# 3. JVM 힙 덤프 (필요 시)
kubectl exec <pod-name> --namespace=production -- \
  jmap -dump:live,format=b,file=/tmp/heap.bin <PID>

kubectl cp <pod-name>:/tmp/heap.bin ./heap.bin --namespace=production

# 4. 팀 공지
# Slack에 상황 공유
```

### 사후 분석

다음 항목을 분석합니다:

1. **원인 파악**
   - 배포된 커밋 분석
   - 에러 로그 분석 (Stack Trace)
   - JVM 메모리/GC 로그 분석
   - 재현 테스트

2. **영향 범위**
   - 영향받은 사용자 수
   - 다운타임 시간
   - 데이터 무결성 확인
   - 재무적 영향 (결제 실패 등)

3. **재발 방지**
   - 테스트 케이스 추가
   - 모니터링 알림 개선
   - 배포 절차 개선
   - Circuit Breaker 패턴 적용 검토

### 사후 보고서 작성

```markdown
# 장애 보고서

## 요약
- 발생 시각: 2025-10-07 14:30 KST
- 종료 시각: 2025-10-07 14:45 KST
- 영향 범위: Production API 응답 불가
- 원인: HikariCP 연결 풀 고갈

## 타임라인
- 14:30: 배포 완료
- 14:32: 5xx 에러 급증 알림
- 14:33: JVM 메모리 사용률 90% 도달
- 14:35: 롤백 결정
- 14:38: Kubernetes 롤백 완료
- 14:45: 서비스 정상화 확인

## 원인 분석
- HikariCP maximum-pool-size 설정 누락 (기본값 10)
- Staging 환경에서 미발견 (트래픽 차이)
- Connection Leak 발생

## 기술적 상세
```java
// 문제 코드
@Transactional
public void processData() {
    // Connection이 해제되지 않음
    jdbcTemplate.query(...);
    throw new RuntimeException(); // Transaction rollback
}
```

## 재발 방지 대책
1. HikariCP 설정 표준화
   - maximum-pool-size: 20
   - leak-detection-threshold: 60000
2. Connection Pool 모니터링 강화
3. Staging 부하 테스트 시나리오 추가
4. 배포 전 체크리스트 업데이트

## 교훈
- 환경별 설정 차이 최소화 필요
- Connection Leak 탐지 자동화
- Staging 환경 트래픽 시뮬레이션 강화

---

## 관련 문서

* [백엔드 배포](deployment-backend.md)
* [프론트엔드 배포](deployment-frontend.md)
* [CI/CD 통합](ci-cd-integration.md)
* [성능 테스트](../development/performance-testing.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
