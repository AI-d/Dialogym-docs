# 성능 테스트 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.07

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **백엔드 개발자**: 성능 병목을 분석하고 최적화하는 담당자
* **DevOps 엔지니어**: 부하 테스트와 인프라 성능을 검증하는 담당자
* **QA 엔지니어**: 성능 테스트 시나리오를 작성하고 실행하는 담당자
* **프론트엔드 개발자**: 클라이언트 성능을 측정하고 개선하는 담당자

---

## 핵심 요약 (Executive Summary)

본 문서는 dialogym 프로젝트의 성능 테스트 방법과 도구 사용법을 정의합니다.
k6를 사용하여 부하 테스트를 수행하고, RPS와 응답 시간을 측정합니다.
JMeter로 스트레스 테스트를 실행하여 시스템 한계점을 파악합니다.
VisualVM과 Spring Boot Actuator로 JVM 성능을 모니터링하고 최적화합니다.
Lighthouse로 프론트엔드 성능을 측정하고 개선합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [부하 테스트 (k6)](#부하-테스트-k6)
3. [스트레스 테스트 (JMeter)](#스트레스-테스트-jmeter)
4. [백엔드 프로파일링](#백엔드-프로파일링)
5. [프론트엔드 성능 측정](#프론트엔드-성능-측정)
6. [데이터베이스 성능](#데이터베이스-성능)
7. [성능 목표 지표](#성능-목표-지표)

---

## 문서 개요 (Overview)

본 문서는 성능 테스트 프로세스를 명확히 하기 위해 작성되었습니다.

성능 문제는 사용자 경험을 저하시키고, 서버 비용을 증가시키며, 장애를 유발할 수 있습니다. 부하 테스트, 스트레스 테스트, 프로파일링을 통해 성능 병목을 사전에 파악하고 최적화합니다.

---

## 부하 테스트 (k6)

### k6 설치

```bash
# macOS
brew install k6

# Linux
curl -s https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz | tar xvz
sudo mv k6-v0.47.0-linux-amd64/k6 /usr/local/bin/

# Windows (Chocolatey)
choco install k6
```

### 기본 부하 테스트

`k6/load-test.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 100 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'https://api-staging.dialogym.com';

export default function () {
  // 헬스체크
  let response = http.get(`${BASE_URL}/actuator/health`);
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });

  sleep(1);

  // 로그인
  response = http.post(
    `${BASE_URL}/api/auth/login`,
    JSON.stringify({
      email: 'test@example.com',
      password: 'password123',
    }),
    {
      headers: { 'Content-Type': 'application/json' },
    }
  );

  check(response, {
    'login successful': (r) => r.status === 200,
    'has token': (r) => r.json('token') !== undefined,
  });

  const token = response.json('token');

  sleep(1);

  // 사용자 목록 조회
  response = http.get(`${BASE_URL}/api/users`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  check(response, {
    'users fetched': (r) => r.status === 200,
  });

  sleep(2);
}
```

### 실행

```bash
# 로컬 테스트
k6 run k6/load-test.js

# Staging 테스트
k6 run --env BASE_URL=https://api-staging.dialogym.com k6/load-test.js
```

---

## 스트레스 테스트 (JMeter)

### JMeter 설치

```bash
# macOS
brew install jmeter

# Linux/Windows
# https://jmeter.apache.org/download_jmeter.cgi 에서 다운로드
```

### 테스트 플랜 생성

1. **Thread Group 설정**
```
Number of Threads: 100
Ramp-up Period: 60초
Loop Count: 10
```

2. **HTTP Request 설정**
```
Server: api-staging.dialogym.com
Port: 443
Protocol: https
Path: /api/users
Method: GET
```

3. **HTTP Header Manager**
```
Authorization: Bearer ${token}
Content-Type: application/json
```

4. **Listeners 추가**
- View Results Tree
- Aggregate Report
- Graph Results

### CLI 실행

```bash
# 테스트 실행
jmeter -n -t test-plan.jmx -l results.jtl

# HTML 리포트 생성
jmeter -g results.jtl -o report/
```

---

## 백엔드 프로파일링

### Spring Boot Actuator

**build.gradle:**

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    runtimeOnly 'io.micrometer:micrometer-registry-prometheus'
}
```

**application.yml:**

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

**메트릭 확인:**

```bash
# 헬스체크
curl http://localhost:8080/actuator/health

# JVM 메모리
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# HTTP 요청 수
curl http://localhost:8080/actuator/metrics/http.server.requests
```

### VisualVM 사용

```bash
# VisualVM 설치
brew install --cask visualvm

# 애플리케이션 실행 (JMX 활성화)
java -Dcom.sun.management.jmxremote \
     -Dcom.sun.management.jmxremote.port=9010 \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -Dcom.sun.management.jmxremote.ssl=false \
     -jar build/libs/app.jar

# VisualVM 실행 및 localhost:9010 연결
```

**VisualVM 주요 기능:**
- CPU 프로파일링
- 메모리 힙 덤프
- Thread 분석
- GC 모니터링

### JProfiler 사용

```bash
# JProfiler 설치
# https://www.ej-technologies.com/products/jprofiler/overview.html

# 애플리케이션에 에이전트 추가
java -agentpath:/path/to/jprofiler/bin/agent.so \
     -jar build/libs/app.jar
```

### 메모리 누수 탐지

```java
// 힙 덤프 생성 (프로그래매틱)
import com.sun.management.HotSpotDiagnosticMXBean;
import java.lang.management.ManagementFactory;

public class HeapDumpUtil {
    public static void dumpHeap(String filePath) throws Exception {
        HotSpotDiagnosticMXBean bean = ManagementFactory
            .getPlatformMXBean(HotSpotDiagnosticMXBean.class);
        bean.dumpHeap(filePath, true);
    }
}
```

```bash
# CLI로 힙 덤프 생성
jmap -dump:live,format=b,file=heap.bin <PID>

# 힙 덤프 분석
jhat heap.bin
# 브라우저에서 http://localhost:7000 접속
```

### GC 로깅

```bash
# GC 로그 활성화
java -Xlog:gc*:file=gc.log:time,uptime,level,tags \
     -jar build/libs/app.jar

# GC 로그 분석
# https://gceasy.io/ 에 업로드
```

---

## 프론트엔드 성능 측정

### Lighthouse 사용

```bash
# 설치
npm install -g lighthouse

# 실행
lighthouse https://staging.dialogym.com \
  --output html \
  --output-path ./lighthouse-report.html

# 특정 카테고리만
lighthouse https://staging.dialogym.com \
  --only-categories=performance \
  --output json
```

### Chrome DevTools Performance

```
1. Chrome DevTools 열기 (F12)
2. Performance 탭 선택
3. Record 버튼 클릭
4. 페이지 조작
5. Stop 버튼 클릭
6. 결과 분석:
   - FCP (First Contentful Paint)
   - LCP (Largest Contentful Paint)
   - TBT (Total Blocking Time)
   - CLS (Cumulative Layout Shift)
```

### React DevTools Profiler

```
1. React DevTools 설치
2. Profiler 탭 선택
3. Record 시작
4. 컴포넌트 조작
5. Record 종료
6. 렌더링 시간 분석
```

### Bundle 분석

**vite.config.js:**

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    react(),
    visualizer({
      filename: './dist/stats.html',
      open: true,
    }),
  ],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom', 'react-router-dom'],
        },
      },
    },
  },
});
```

---

## 데이터베이스 성능

### PostgreSQL 쿼리 분석

```sql
-- EXPLAIN ANALYZE 사용
EXPLAIN ANALYZE
SELECT u.*, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.created_at > '2025-01-01'
GROUP BY u.id;

-- 느린 쿼리 로그 확인
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### 인덱스 최적화

```sql
-- 인덱스 생성
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);

-- 복합 인덱스
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at);

-- 인덱스 사용 확인
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan;
```

### HikariCP 최적화

**application.yml:**

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 10
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000
```

---

## 성능 목표 지표

### 백엔드 API

| 메트릭 | 목표 | 허용 |
|--------|------|------|
| 응답 시간 (p95) | < 200ms | < 500ms |
| 응답 시간 (p99) | < 500ms | < 1000ms |
| RPS (초당 요청) | > 100 | > 50 |
| 에러율 | < 0.1% | < 1% |
| CPU 사용률 | < 70% | < 85% |
| 메모리 사용률 | < 80% | < 90% |
| GC 일시 정지 | < 50ms | < 100ms |

### 프론트엔드

| 메트릭 | 목표 | 허용 |
|--------|------|------|
| FCP | < 1.5s | < 2.5s |
| LCP | < 2.5s | < 4s |
| TBT | < 200ms | < 600ms |
| CLS | < 0.1 | < 0.25 |
| Bundle Size | < 500KB | < 1MB |

### 데이터베이스

| 메트릭 | 목표 | 허용 |
|--------|------|------|
| 쿼리 시간 (평균) | < 10ms | < 50ms |
| 쿼리 시간 (p95) | < 50ms | < 200ms |
| Connection Pool 사용률 | < 70% | < 85% |
| 인덱스 히트율 | > 99% | > 95% |

---

## 관련 문서

* [테스트 전략](testing-strategy.md)
* [API 테스트](api-testing.md)
* [백엔드 배포](../deployment/deployment-backend.md)
* [프론트엔드 배포](../deployment/deployment-frontend.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.07 | 왕택준 | 최초 작성 |
