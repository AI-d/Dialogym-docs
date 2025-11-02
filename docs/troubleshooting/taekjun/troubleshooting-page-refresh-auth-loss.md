# 트러블슈팅: 페이지 새로고침 시 로그인 풀림 인증 상태 초기화 로직 개선

**담당자 (Author)**: [이름](GitHub 주소)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.31

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **전체 개발자**: React + Zustand 기반 인증 상태 관리를 다루는 팀원
* **Tech Lead**: 인증 아키텍처 설계와 보안 정책 수립에 활용하는 책임자
* **신규 합류자**: 프로젝트의 인증 플로우와 상태 관리 방식을 학습해야 하는 멤버

---

## 핵심 요약 (Executive Summary)

비즈니스 페이지에서 새로고침 시 로그인이 풀리는 문제가 발생했습니다. 원인은 (1) 로그인 시 토큰을 localStorage에 저장하지 않음, (2) 페이지 로드 시 인증 상태 초기화 로직 미완성, (3) 초기화 완료 플래그 미설정으로 인한 헤더 렌더링 문제였습니다. 로그인 플로우에 토큰 저장 로직 추가, initializeAuth에서 쿠키 기반 refresh 엔드포인트 호출, isInitialized 플래그 설정으로 해결했습니다.

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

React + Zustand 기반의 SPA 애플리케이션에서 JWT 토큰 기반 인증을 구현했으나, 페이지 새로고침 시 로그인 상태가 유지되지 않는 문제가 발생했습니다. 사용자가 로그인 후 비즈니스 페이지에서 새로고침하면 헤더가 사라지고 로그인이 풀리는 현상으로, 사용자 경험에 치명적인 영향을 미쳤습니다. 리프레시 토큰은 HttpOnly 쿠키로 유지되고 있었으나, 프론트엔드의 상태 관리와 초기화 로직이 불완전하여 발생한 문제였습니다.

---

## 1. 문제 현상

### 1-1. 주요 증상
* **문제**: 로그인 후 비즈니스 페이지에서 새로고침 시 로그인이 풀림
* **증상**:
  - 새로고침 전: 헤더에 사용자 이름 표시, 정상 작동
  - 새로고침 후: 헤더 완전히 사라짐, 인증 필요한 기능 사용 불가
* **상황**: 모든 페이지에서 새로고침 시 동일하게 발생

### 1-2. 에러 정보
* **에러 메시지**:
  - 콘솔: `저장된 accessToken 만료, refresh 시도`
  - 네트워크: `/users/profile` 500 에러 (서버 문제)
* **재현 조건**:
  1. 로그인 성공
  2. 임의의 페이지 이동
  3. 브라우저 새로고침 (F5 또는 Ctrl+R)
* **빈도**: 항상 발생 (100%)

### 1-3. 환경 정보
* **운영체제**: Windows
* **브라우저**: Chrome 최신 버전
* **관련 버전**:
  - React 18
  - Zustand 4.x
  - Axios (API 클라이언트)
  - JWT 토큰 (액세스 토큰 15분 유효)

---

## 2. 원인 분석

### 2-1. 1차 분석
사용자가 "리프레시 토큰은 계속 남아 있다"고 언급하여 토큰 자체는 유지되고 있으나, 프론트엔드 상태 관리에 문제가 있음을 추정했습니다.

### 2-2. 2차 분석
코드 분석 결과 다음 문제들을 발견:
1. `authStore.js`의 `login`, `exchangeCode`, `completeSocialSignup` 함수에서 응답받은 토큰을 localStorage에 저장하지 않음
2. `initializeAuth` 함수가 정의되어 있으나 `isInitialized` 플래그를 설정하지 않음
3. `AppHeader` 컴포넌트가 `status === 'unauthenticated'`만 체크하여 초기화 중(`idle` 상태)에도 헤더를 표시하려 시도

### 2-3. 근본 원인

**문제점 1: 토큰 저장 누락**
```javascript
// 문제 코드
login: async (credentials) => {
    const resp = await authService.login(credentials);
    set({ accessToken: resp.accessToken }); // 메모리에만 저장
    await get().fetchUser();
}
```
- 로그인 성공 시 토큰을 Zustand store에만 저장
- localStorage에 저장하지 않아 새로고침 시 토큰 소실

**문제점 2: 초기화 플래그 미설정**
```javascript
// 문제 코드
initializeAuth: async () => {
    try {
        // ... 인증 로직
        set({ status: 'authenticated', user: userProfile }); // isInitialized 누락
    } catch (error) {
        set({ status: 'unauthenticated', user: null }); // isInitialized 누락
    }
}
```
- `isInitialized` 플래그를 설정하지 않아 `ProtectedRoute`가 무한 로딩

**문제점 3: 헤더 렌더링 조건 불완전**
```javascript
// 문제 코드
if (status === 'unauthenticated') return null;
```
- 초기화 전(`idle` 상태)에도 헤더를 렌더링하려 시도
- 사용자 정보가 없는 상태에서 렌더링 오류 발생

**문제점 4: 불필요한 API 호출**
```javascript
// 문제 코드
initializeAuth: async () => {
    const storedAccessToken = localStorage.getItem('accessToken');
    if (storedAccessToken) {
        // ... 토큰 검증
    }
    // accessToken이 없어도 refresh 시도
    const refreshResp = await apiClient.post('/users/refresh'); // 401 에러 발생
}
```
- 로그인하지 않은 상태(localStorage에 토큰 없음)에서도 refresh 엔드포인트 호출
- 불필요한 401 에러 발생 및 네트워크 낭비

---

## 3. 디버깅 과정

### 3-1. 사용한 디버깅 기법
- Chrome DevTools Application 탭 (localStorage, Cookies 확인)
- React DevTools (Zustand store 상태 확인)
- Network 탭 (API 호출 및 응답 확인)
- 코드 정적 분석 (파일 간 데이터 흐름 추적)

### 3-2. 핵심 문제 발견 과정

**1단계: authStore 확인**
```javascript
// src/stores/authStore.js 분석
const initialState = {
    user: null,
    accessToken: null,
    status: 'idle',
    error: null,
    isInitialized: false, // 플래그는 있으나 설정 안 됨
};
```

**결과**: `isInitialized` 플래그가 정의되어 있으나 어디서도 `true`로 설정하지 않음

**2단계: 로그인 플로우 추적**
```javascript
// login 함수 확인
login: async (credentials) => {
    const resp = await authService.login(credentials);
    set({ accessToken: resp.accessToken }); // localStorage 저장 없음
    await get().fetchUser();
}
```

**결과**: 토큰을 메모리(Zustand store)에만 저장, localStorage 저장 누락

**3단계: 초기화 로직 확인**
```javascript
// useAuthBootstrap.js
useEffect(() => {
    const bootstrap = async () => {
        await initializeAuth(); // 호출은 되지만...
    };
    bootstrap();
}, []);
```

**결과**: `initializeAuth`는 호출되지만 내부에서 `isInitialized` 설정 안 함

**4단계: authService 확인**
```javascript
// src/services/authService.js
// refreshToken 함수가 없음!
```

**결과**: `initializeAuth`에서 호출하는 `authService.refreshToken` 함수가 존재하지 않음

**5단계: apiClient 인터셉터 확인**
```javascript
// src/services/apiClient.js
apiClient.interceptors.response.use(
    (response) => response,
    async (error) => {
        // 401 에러 시 자동 refresh 로직 있음
        const refreshResp = await apiClient.post('/users/refresh');
        // 하지만 localStorage에 저장 안 함
    }
);
```

**결과**: 자동 refresh 로직은 있으나 새 토큰을 localStorage에 저장하지 않음

---

## 4. 해결 과정

### 4-1. 시도했던 해결책들

**A안: localStorage 기반 refreshToken 함수 추가**
```javascript
// authService.js에 추가
export async function refreshToken(refreshToken) {
    const {data} = await apiClient.post('/users/token/refresh', {refreshToken});
    return unwrap(data).data;
}
```

**결과**: 함수는 추가했으나 서버가 쿠키 기반 인증을 사용하여 불필요

**B안: 쿠키 기반 refresh 로직으로 변경 (채택)**
```javascript
// initializeAuth 수정
const storedAccessToken = localStorage.getItem('accessToken');
if (storedAccessToken) {
    set({ accessToken: storedAccessToken });
    try {
        const userProfile = await userService.getMyProfile();
        set({ status: 'authenticated', user: userProfile, isInitialized: true });
        return;
    } catch (error) {
        console.log('저장된 accessToken 만료, refresh 시도');
    }
}

// 쿠키 기반 refresh 시도
const refreshResp = await apiClient.post('/users/refresh');
const newAccessToken = refreshResp.data?.data?.accessToken;
localStorage.setItem('accessToken', newAccessToken);
```

**성공**: 서버의 쿠키 기반 인증 방식과 일치

### 4-2. 최종 해결책

**변경 1: 로그인 시 토큰 localStorage 저장**
```javascript
// src/stores/authStore.js
login: async (credentials) => {
    set({ status: 'loading', error: null });
    try {
        const resp = await authService.login(credentials);

        // 토큰 저장 추가
        localStorage.setItem('accessToken', resp.accessToken);
        if (resp.refreshToken) {
            localStorage.setItem('refreshToken', resp.refreshToken);
        }

        set({ accessToken: resp.accessToken });
        await get().fetchUser();
    } catch (error) {
        set({ status: 'unauthenticated', error: error.response?.data || error });
        throw error;
    }
}
```

**변경 2: initializeAuth에서 isInitialized 플래그 설정 및 불필요한 API 호출 방지**
```javascript
// src/stores/authStore.js
initializeAuth: async () => {
    try {
        const storedAccessToken = localStorage.getItem('accessToken');

        // accessToken이 없으면 로그인 안 한 상태로 간주 (추가)
        if (!storedAccessToken) {
            set({
                status: 'unauthenticated',
                user: null,
                isInitialized: true,
            });
            return; // 불필요한 refresh 호출 방지
        }

        // accessToken이 있으면 store에 설정하고 사용자 정보 가져오기 시도
        set({ accessToken: storedAccessToken });

        try {
            const userProfile = await userService.getMyProfile();
            set({
                status: 'authenticated',
                user: userProfile,
                isInitialized: true, // 플래그 설정
            });
            return;
        } catch (error) {
            console.log('저장된 accessToken 만료, refresh 시도');
        }

        // accessToken이 만료된 경우에만 refresh 시도 (쿠키 기반)
        const refreshResp = await apiClient.post('/users/refresh');
        const newAccessToken = refreshResp.data?.data?.accessToken;

        if (!newAccessToken) {
            throw new Error('No access token in refresh response');
        }

        localStorage.setItem('accessToken', newAccessToken);
        set({ accessToken: newAccessToken });

        const userProfile = await userService.getMyProfile();

        set({
            status: 'authenticated',
            user: userProfile,
            isInitialized: true, // 플래그 설정
        });

    } catch (error) {
        console.error('인증 초기화 실패:', error);
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');

        set({
            status: 'unauthenticated',
            user: null,
            isInitialized: true, // 실패 시에도 플래그 설정
        });
    }
}
```

**변경 3: AppHeader에서 초기화 상태 체크**
```javascript
// src/components/Header/AppHeader.jsx
const AppHeader = () => {
    const isInitialized = useAuthStore((s) => s.isInitialized);
    const status = useAuthStore((s) => s.status);

    // 초기화 전이거나 인증되지 않은 경우 헤더 숨김
    if (!isInitialized || status === 'unauthenticated') return null;

    // ... 헤더 렌더링
}
```

**변경 4: apiClient 인터셉터에서 토큰 저장**
```javascript
// src/services/apiClient.js
try {
    const refreshResp = await apiClient.post('/users/refresh');
    const newAccessToken = normalized?.data?.accessToken || normalized?.data;

    if (!newAccessToken) throw new Error('No access token in refresh response.');

    // localStorage에 새 토큰 저장 추가
    localStorage.setItem('accessToken', newAccessToken);

    const {useAuthStore} = await import('@/stores/authStore');
    const authStore = useAuthStore.getState();
    authStore.setAccessToken(newAccessToken);
    authStore.fetchUser();

    // ... 나머지 로직
}
```

**성공 이유**:
- localStorage에 토큰을 저장하여 새로고침 후에도 토큰 유지
- 초기화 완료 플래그로 UI 렌더링 타이밍 제어
- 쿠키 기반 refresh로 서버 인증 방식과 일치
- 자동 refresh 시에도 토큰 저장으로 일관성 유지
- 로그인하지 않은 상태에서 불필요한 API 호출 방지 (성능 개선)

---

## 5. 테스트 검증

### 5-1. 테스트 방법
1. **로그인 후 토큰 저장 확인**
   - 로그인 수행
   - DevTools > Application > Local Storage 확인
   - `accessToken` 키 존재 여부 확인

2. **새로고침 후 상태 유지 확인**
   - 로그인 후 비즈니스 페이지 이동
   - F5로 새로고침
   - 헤더 표시 여부 및 사용자 정보 확인

3. **토큰 만료 시 자동 갱신 확인**
   - localStorage의 accessToken을 임의로 수정
   - API 호출 시도
   - Network 탭에서 `/users/refresh` 호출 확인

### 5-2. 검증 결과
* **변경 전**:
  - 새로고침 시 로그인 풀림 (100%)
  - localStorage에 토큰 없음
  - 헤더 사라짐

* **변경 후**:
  - 새로고침 시 로그인 유지 (100%)
  - localStorage에 accessToken 저장 확인
  - 헤더 정상 표시
  - 콘솔 로그: "저장된 accessToken 만료, refresh 시도" → 정상 동작

---

## 6. 성능 영향 분석

### 6-1. 변경 전후 비교

**측정 항목**:
- **초기 로딩 시간**: 변화 없음 (localStorage 읽기는 동기 작업이지만 매우 빠름)
- **새로고침 후 인증 복원 시간**:
  - 변경 전: 불가능 (로그인 페이지로 리다이렉트)
  - 변경 후: ~500ms (localStorage 읽기 + API 호출)
- **메모리 사용량**: 미미한 증가 (토큰 문자열 저장)

### 6-2. 리소스 사용량
- **localStorage**: ~200 bytes (accessToken 저장)
- **네트워크**:
  - 로그인 상태: 새로고침 시 `/users/profile` 또는 `/users/refresh` 1회 호출
  - 비로그인 상태: API 호출 없음 (개선됨)
  - 토큰 만료 시 자동 refresh 추가 호출
- **CPU**: 무시 가능한 수준

### 6-3. 사용자 경험 영향
- **긍정적 영향**:
  - 새로고침 후에도 로그인 상태 유지
  - 재로그인 불필요로 사용자 편의성 대폭 향상
  - 작업 중단 없이 연속적인 사용 가능
- **부정적 영향**: 없음

---

## 7. 관련 이슈 및 예방책

### 7-1. 유사한 함정 회피 방법

**위험한 패턴**:
```javascript
// ❌ 나쁜 예: 메모리에만 상태 저장
const [token, setToken] = useState(null);
// 새로고침 시 소실됨
```

**안전한 패턴**:
```javascript
// ✅ 좋은 예: localStorage와 메모리 상태 동기화
const saveToken = (token) => {
    localStorage.setItem('accessToken', token);
    setToken(token);
};
```

**위험한 패턴**:
```javascript
// ❌ 나쁜 예: 초기화 완료 플래그 없음
if (status === 'unauthenticated') return <Redirect />;
// 초기화 중에도 리다이렉트 발생
```

**안전한 패턴**:
```javascript
// ✅ 좋은 예: 초기화 완료 대기
if (!isInitialized) return <Loading />;
if (status === 'unauthenticated') return <Redirect />;
```

**위험한 패턴**:
```javascript
// ❌ 나쁜 예: 조건 없이 API 호출
initializeAuth: async () => {
    const token = localStorage.getItem('accessToken');
    if (token) { /* 검증 */ }
    // 토큰 없어도 refresh 시도
    await apiClient.post('/users/refresh'); // 불필요한 401 에러
}
```

**안전한 패턴**:
```javascript
// ✅ 좋은 예: 토큰 존재 여부 확인 후 API 호출
initializeAuth: async () => {
    const token = localStorage.getItem('accessToken');
    if (!token) {
        set({ status: 'unauthenticated', isInitialized: true });
        return; // 불필요한 API 호출 방지
    }
    // 토큰이 있을 때만 검증 및 refresh 시도
}
```

### 7-2. 코드 리뷰 체크포인트
- [ ] 로그인 성공 시 토큰을 localStorage에 저장하는가?
- [ ] 페이지 로드 시 localStorage에서 토큰을 읽어오는가?
- [ ] 초기화 완료 플래그(`isInitialized`)를 모든 경로에서 설정하는가?
- [ ] 토큰 갱신 시 localStorage도 업데이트하는가?
- [ ] 로그아웃 시 localStorage를 정리하는가?
- [ ] 보호된 라우트가 초기화 완료를 기다리는가?
- [ ] 로그인하지 않은 상태에서 불필요한 API 호출을 하지 않는가?

### 7-3. 추가 예방 방법

**1. 토큰 저장 유틸리티 함수 작성**
```javascript
// src/utils/tokenStorage.js
export const tokenStorage = {
    save: (accessToken, refreshToken) => {
        localStorage.setItem('accessToken', accessToken);
        if (refreshToken) {
            localStorage.setItem('refreshToken', refreshToken);
        }
    },
    get: () => ({
        accessToken: localStorage.getItem('accessToken'),
        refreshToken: localStorage.getItem('refreshToken'),
    }),
    clear: () => {
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
    }
};
```

**2. 초기화 상태 훅 작성**
```javascript
// src/hooks/useAuthInitialized.js
export const useAuthInitialized = () => {
    const isInitialized = useAuthStore((s) => s.isInitialized);
    const status = useAuthStore((s) => s.status);

    return {
        isInitialized,
        isAuthenticated: isInitialized && status === 'authenticated',
        isUnauthenticated: isInitialized && status === 'unauthenticated',
    };
};
```

**3. E2E 테스트 추가**
```javascript
// cypress/e2e/auth-persistence.cy.js
describe('인증 상태 유지', () => {
    it('새로고침 후에도 로그인 상태 유지', () => {
        cy.login(); // 로그인 헬퍼
        cy.visit('/scenarios');
        cy.reload();
        cy.get('[data-testid="user-menu"]').should('be.visible');
    });
});
```

---

## 8. 결론 및 배운 점

### 8-1. 주요 성과
1. **새로고침 후 로그인 상태 유지 100% 달성**
2. **사용자 경험 대폭 개선** (재로그인 불필요)
3. **인증 플로우 완성도 향상** (초기화 로직 체계화)
4. **토큰 관리 일관성 확보** (저장/갱신/삭제 통일)
5. **불필요한 API 호출 제거** (비로그인 상태에서 401 에러 방지)

### 8-2. 기술적 학습

**JWT 토큰 관리 베스트 프랙티스**:
- **액세스 토큰**: localStorage에 저장 (짧은 유효기간)
- **리프레시 토큰**: HttpOnly 쿠키 (XSS 공격 방어)
- **자동 갱신**: API 인터셉터에서 401 에러 처리
- **초기화**: 페이지 로드 시 토큰 복원 및 검증

**React 상태 관리와 영속성**:
- Zustand store는 메모리 상태 (새로고침 시 소실)
- localStorage와 동기화 필요
- 초기화 플래그로 렌더링 타이밍 제어

**인증 플로우 설계 원칙**:
1. 로그인 → 토큰 저장 (메모리 + localStorage)
2. API 호출 → 토큰 자동 첨부
3. 401 에러 → 자동 refresh
4. 페이지 로드 → 토큰 복원 및 검증
5. 로그아웃 → 토큰 완전 삭제

### 8-3. 프로세스 개선

**인증 관련 체크리스트 작성**:
- [ ] 로그인 시 토큰 localStorage 저장
- [ ] 페이지 로드 시 토큰 복원
- [ ] 토큰 갱신 시 localStorage 업데이트
- [ ] 로그아웃 시 localStorage 정리
- [ ] 초기화 완료 플래그 설정
- [ ] 보호된 라우트에서 초기화 대기

**코드 리뷰 강화**:
- 인증 관련 PR은 필수 체크리스트 확인
- localStorage 사용 시 동기화 로직 검토
- 상태 플래그 설정 누락 여부 확인

### 8-4. 장기적 개선 방향

**보안 강화**:
- localStorage 대신 sessionStorage 고려 (탭 닫으면 삭제)
- 토큰 암호화 저장 검토
- Refresh token rotation 구현

**모니터링 추가**:
- 토큰 갱신 실패율 추적
- 인증 초기화 실패 로그 수집
- 사용자별 세션 지속 시간 분석

**개발자 경험 개선**:
- 토큰 관리 유틸리티 라이브러리화
- 인증 상태 디버깅 도구 개발
- 인증 플로우 다이어그램 문서화

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 담당자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.10.31 | [이름] | 최초 작성 |
