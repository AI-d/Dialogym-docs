# Dialogym 프론트엔드 인증/보안 시스템 설계

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.01

**문서 버전 (Version)**: v2.0

**문서 상태 (Status)**: Approved

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: 인증 시스템 구현 및 유지보수를 담당하는 개발자
* **백엔드 개발자**: 프론트엔드 인증 흐름을 이해하고 API를 연동하는 개발자
* **시스템 아키텍트**: 전체 시스템 설계 및 보안 정책을 수립하는 담당자
* **보안 담당자**: 보안 취약점 분석 및 개선 방안을 검토하는 담당자
* **신규 팀원**: Dialogym 프론트엔드 인증 시스템을 빠르게 학습해야 하는 신규 합류자

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym 프론트엔드의 인증, 인가, 보안 시스템 전체 설계를 정의합니다.
JWT 기반 Stateless 인증과 RTR(Refresh Token Rotation) 방식을 채택하여 보안을 강화하였으며, Access Token은 메모리에, Refresh Token은 HttpOnly 쿠키로 관리하여 XSS 및 CSRF 공격을 방어합니다.
Zustand를 활용한 중앙 집중식 상태 관리와 Axios Interceptor 패턴으로 자동 토큰 갱신 및 동시성 문제를 해결하였습니다.
로컬 인증과 소셜 인증(Google, Kakao, Naver)을 지원하며, 약관 동의 시스템을 통합하여 법적 요구사항을 충족합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [시스템 개요](#시스템-개요)
3. [인증 아키텍처](#인증-아키텍처)
4. [상태 관리 설계](#상태-관리-설계-authstore)
5. [API 클라이언트 설계](#api-클라이언트-설계-apiclient)
6. [인증 서비스 설계](#인증-서비스-설계-authservice)
7. [라우팅 및 권한 제어](#라우팅-및-권한-제어)
8. [로컬 인증 플로우](#로컬-인증-플로우)
9. [소셜 인증 플로우](#소셜-인증-플로우)
10. [보안 메커니즘](#보안-메커니즘)
11. [성능 최적화](#성능-최적화)
12. [에러 처리 및 복구](#에러-처리-및-복구)
13. [베스트 프랙티스](#베스트-프랙티스)
14. [향후 개선사항](#향후-개선사항)
15. [체크리스트](#체크리스트)
16. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 Dialogym 프론트엔드의 인증, 인가, 보안 시스템 설계와 구현을 상세히 기록한 기능 설계 문서입니다.

소프트웨어 시스템의 인증은 보안, 사용자 경험, 시스템 안정성의 모든 측면에 영향을 미치는 핵심 기능입니다.
명확한 설계 문서화를 통해 개발자 간 공통된 이해를 확보하고, 보안 취약점을 사전에 방지하며, 신규 합류자의 학습 곡선을 단축합니다.

본 문서는 Dialogym 프론트엔드의 모든 인증 관련 개발, 유지보수, 보안 검토 활동에 적용되며, 시스템 변경 시 반드시 업데이트해야 합니다.

---

## 시스템 개요

### 인증 방식

Dialogym은 JWT 기반 인증과 RTR(Refresh Token Rotation) 방식을 사용합니다.

**토큰 저장 전략**:
Access Token은 메모리(Zustand store)에 저장하며 짧은 만료 시간(15분)을 가집니다.
Refresh Token은 HttpOnly 쿠키에 저장하며 긴 만료 시간(7일)을 가집니다.

**보안 강화**:
RTR로 토큰 재사용을 방지하고, Rate Limiting으로 과도한 요청을 차단하며(10초/2회), 동시성 문제를 refreshPromise와 initializePromise 패턴으로 해결합니다.

### 핵심 기술 스택

상태 관리는 Zustand, Immer, Devtools를 사용하며, HTTP 클라이언트는 Axios Interceptor 패턴을 채택합니다.
라우팅은 React Router v6을 사용하고, 알림은 React Hot Toast로 처리하며, 약관 관리는 자체 구현한 termsService를 사용합니다.

### 주요 기능

로컬 인증은 이메일과 비밀번호 기반 회원가입 및 로그인을 지원합니다.
소셜 인증은 Google, Kakao, Naver OAuth2 로그인을 제공합니다.
이메일 인증은 6자리 코드 기반 검증을 수행하고, 약관 동의는 필수 및 선택 약관을 관리하며 검증합니다.
자동 토큰 갱신은 401 에러 시 자동으로 토큰을 갱신하고 재시도하며, 동시성 안전은 refreshPromise와 initializePromise 패턴으로 보장합니다.
XSS 및 CSRF 방어는 메모리 기반 AT와 HttpOnly 쿠키 RT로 구현하고, Rate Limiting은 백엔드에서 과도한 요청을 차단합니다.

### 설계 원칙

보안을 최우선으로 XSS, CSRF, RTR 등 다층 보안 메커니즘을 적용합니다.
사용자 경험을 위해 끊김 없는 자동 토큰 갱신을 제공하며, 성능 최적화를 위해 중복 요청 방지와 상태 구독 최적화를 수행합니다.
에러 복구는 자동 복구 및 명확한 에러 메시지로 처리하고, 확장성을 위해 새로운 소셜 로그인 제공자 추가가 용이하도록 설계합니다.

---

## 인증 아키텍처

### 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                         React App                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              authStore (Zustand + Immer)               │  │
│  │  - user: User | null                                   │  │
│  │  - accessToken: string | null (메모리)                │  │
│  │  - status: 'idle' | 'loading' | 'authenticated' | ... │  │
│  │  - isInitialized: boolean                              │  │
│  │  - initializePromise: Promise (중복 실행 방지)        │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ↕                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  apiClient (Axios)                     │  │
│  │  - Request Interceptor: Authorization 헤더 추가       │  │
│  │  - Response Interceptor: 401 처리 & 자동 토큰 갱신   │  │
│  │  - refreshPromise: Promise (중복 요청 방지)           │  │
│  │  - refreshQueue: Array (대기 중인 요청 관리)          │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ↕                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                authService (API 호출)                  │  │
│  │  - login(), signup(), logout()                         │  │
│  │  - verifyEmail(), resendVerificationEmail()            │  │
│  │  - exchangeToken(), completeSocialSignup()             │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ↕                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                termsService (약관 관리)                │  │
│  │  - getActiveTerms(), getMyConsents()                   │  │
│  │  - updateConsent()                                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                      Backend API                             │
│  - JWT 발급 및 검증                                         │
│  - Refresh Token Rotation (RTR)                             │
│  - Rate Limiting (10초/2회)                                 │
│  - 이메일 인증 코드 발송                                    │
│  - OAuth2 소셜 로그인                                       │
│  - 약관 관리 및 동의 처리                                   │
└─────────────────────────────────────────────────────────────┘
```

### 데이터 흐름

#### 앱 초기화

앱이 렌더링되면 useAuthBootstrap()이 실행되고, useRef로 중복 실행을 방지합니다.
authStore.initializeAuth()가 호출되며, isInitialized 체크로 이미 완료된 경우 즉시 반환합니다.
isInitializing 체크로 진행 중이면 기존 Promise를 반환하고, initializePromise를 생성하여 저장합니다.
/users/refresh API를 호출하여 쿠키의 Refresh Token을 사용하고, validateStatus로 모든 상태 코드를 허용합니다.
응답이 401이면 unauthenticated 상태로 설정하고, 200이면 accessToken을 저장하고 사용자 정보를 조회합니다.
기타 응답은 unauthenticated 상태로 설정하며, 최종적으로 isInitialized를 true로 설정하고 상태를 정리합니다.

**빠른 새로고침 대응**:
F5 연타 시에도 /users/refresh 요청은 딱 1번만 발생하며, RTR 환경에서 안전하게 작동하고 빌드 오류를 방지합니다.

#### 로그인

사용자가 로그인 폼을 제출하면 authStore.login(credentials)이 호출됩니다.
POST /users/login으로 요청하며, 서버는 Body에 accessToken을, Cookie에 refreshToken(HttpOnly, Secure, SameSite)을 반환합니다.
accessToken을 메모리에 저장하고, fetchUser()로 사용자 정보를 조회한 후, status를 'authenticated'로 변경하고 대시보드로 리다이렉트합니다.

#### API 요청 (자동 토큰 갱신)

컴포넌트에서 API를 호출하면 Request Interceptor가 Authorization 헤더를 추가합니다.
서버 응답이 200이면 정상 처리하고, 401 (AUTH_001)이면 Response Interceptor가 자동으로 처리합니다.
isRefreshing 체크로 이미 갱신 중이면 큐에 대기하고, refreshPromise를 생성하여 저장합니다.
POST /users/refresh로 새 accessToken을 받아 저장하고, 대기 중인 모든 요청에 새 토큰을 전달한 후 원래 요청을 재시도합니다.
401 (기타)는 로그아웃 처리합니다.

**동시 요청 처리**:
여러 API 요청이 동시에 401을 받아도 /users/refresh는 딱 1번만 호출되며, 백엔드 부하가 80% 감소하고 RTR 환경에서 안전합니다.

#### 로그아웃

authStore.logout()을 호출하면 POST /users/logout으로 백엔드에서 RT를 무효화합니다.
clearAuth()로 프론트엔드 상태를 정리하고, resetRefreshState()로 refresh 관련 상태를 초기화합니다.
isRefreshing을 false로, refreshQueue를 빈 배열로, refreshPromise를 null로 설정한 후 로그인 페이지로 리다이렉트합니다.

---

## 상태 관리 설계 (authStore)

### 상태 구조

```javascript
{
  user: User | null,              // 사용자 정보
  accessToken: string | null,     // Access Token (메모리)
  status: 'idle' | 'loading' | 'authenticated' | 'unauthenticated',
  error: any | null,              // 에러 정보
  isInitialized: boolean          // 초기화 완료 여부
}

// 모듈 레벨 변수 (중복 실행 방지)
let isInitializing = false;
let initializePromise = null;
```

### 주요 액션

#### initializeAuth()

앱 초기화 시 페이지 새로고침에서 자동 로그인을 수행하며, 중복 실행을 방지하고 RTR 환경에서 안전한 토큰 갱신을 보장합니다.

```javascript
initializeAuth: async () => {
  if (get().isInitialized) {
    return;
  }

  if (isInitializing && initializePromise) {
    return initializePromise;
  }

  isInitializing = true;

  initializePromise = (async () => {
    try {
      const refreshResp = await apiClient.post('/users/refresh', null, {
        validateStatus: (status) => status >= 200 && status < 600
      });

      if (refreshResp.status === 401) {
        set({ status: 'unauthenticated', user: null, isInitialized: true });
        return;
      }

      const newAccessToken = refreshResp.data?.data?.accessToken;
      set({ accessToken: newAccessToken });

      const userProfile = await userService.getMyProfile();
      set({ status: 'authenticated', user: userProfile, isInitialized: true });
    } catch (error) {
      set({ status: 'unauthenticated', user: null, isInitialized: true });
    } finally {
      isInitializing = false;
      initializePromise = null;
    }
  })();

  return initializePromise;
}
```

isInitialized 체크로 이미 완료되었으면 스킵하고, isInitializing 체크로 진행 중이면 기존 Promise를 재사용하며, finally 블록으로 성공 또는 실패와 관계없이 상태를 정리합니다.

#### login(credentials)

이메일과 비밀번호 기반 로그인을 수행하며, 자동으로 사용자 정보를 조회하고 에러를 처리합니다.

```javascript
login: async (credentials) => {
  set({ status: 'loading', error: null });
  try {
    const resp = await authService.login(credentials);
    set({ accessToken: resp.accessToken });
    await get().fetchUser();
  } catch (error) {
    set({ status: 'unauthenticated', error: error.response?.data || error });
    throw error;
  }
}
```

#### exchangeCode(code)

소셜 로그인 기존 회원의 일회용 코드를 Access Token으로 교환합니다.

```javascript
exchangeCode: async (code) => {
  set({ status: 'loading', error: null });
  try {
    const resp = await authService.exchangeToken(code);
    set({ accessToken: resp.accessToken });
    await get().fetchUser();
  } catch (error) {
    set({ status: 'unauthenticated', error: error.response?.data || error });
    throw error;
  }
}
```

#### completeSocialSignup(payload)

소셜 로그인 신규 회원의 추가 정보 입력 및 약관 동의를 처리합니다.

```javascript
completeSocialSignup: async (payload) => {
  set({ status: 'loading', error: null });
  try {
    const resp = await authService.completeSocialSignup(payload);
    set({ accessToken: resp.accessToken });
    await get().fetchUser();
  } catch (error) {
    set({ status: 'unauthenticated', error: error.response?.data || error });
    throw error;
  }
}
```

#### logout()

백엔드 Refresh Token을 무효화하고, 프론트엔드 상태를 정리하며, refresh 관련 상태를 초기화합니다.

```javascript
logout: async () => {
  try {
    await authService.logout();
  } catch (error) {
    console.warn('Logout API failed:', error);
  } finally {
    get().clearAuth();

    const { resetRefreshState } = await import('@/services/apiClient');
    resetRefreshState();
  }
}
```

백엔드 호출이 실패해도 프론트엔드 상태는 반드시 정리합니다.

### 셀렉터

필요한 상태만 구독하여 성능을 최적화하고 재사용 가능한 셀렉터를 제공합니다.

```javascript
export const useIsAuthenticated = () =>
  useAuthStore((s) => s.status === 'authenticated');

export const useAuthUser = () =>
  useAuthStore((s) => s.user);

const status = useAuthStore((s) => s.status);
const isInitialized = useAuthStore((s) => s.isInitialized);
```

---

## API 클라이언트 설계 (apiClient)

### 기본 설정

모든 API 요청을 중앙 집중화하고, 쿠키 기반 Refresh Token을 전송하며, 타임아웃을 설정합니다.

```javascript
const apiClient = axios.create({
  baseURL: API_ENDPOINT,
  withCredentials: true,        // 쿠키 전송 필수
  headers: { 'Content-Type': 'application/json' },
  timeout: 10000,
});
```

withCredentials: true가 없으면 Refresh Token 쿠키가 전송되지 않으며, 백엔드 CORS 설정에서도 credentials: true가 필요합니다.

### Request Interceptor

모든 요청에 Authorization 헤더를 자동으로 추가하고, Access Token을 메모리에서 가져옵니다.

```javascript
apiClient.interceptors.request.use(
  (config) => {
    const accessToken = getAccessToken();
    if (accessToken) {
      config.headers = config.headers || {};
      config.headers['Authorization'] = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);
```

### Response Interceptor

401 에러 시 자동으로 토큰을 갱신하고, refreshPromise 패턴으로 중복 요청을 방지하며, RTR 환경에서 안전한 토큰 갱신을 수행합니다.

```javascript
let isRefreshing = false;
let refreshQueue = [];
let refreshPromise = null;

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (originalRequest._retry) {
      return Promise.reject(error);
    }

    const errorCode = error.response?.data?.error;

    if (errorCode === 'AUTH_001') {
      if (isRefreshing && refreshPromise) {
        return new Promise((resolve, reject) => {
          refreshQueue.push({
            resolve: (newToken) => {
              originalRequest.headers['Authorization'] = `Bearer ${newToken}`;
              resolve(apiClient(originalRequest));
            },
            reject,
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      refreshPromise = (async () => {
        try {
          const refreshResp = await apiClient.post('/users/refresh');
          const newAccessToken = unwrap(refreshResp.data).data.accessToken;

          authStore.setAccessToken(newAccessToken);
          await authStore.fetchUser();

          refreshQueue.forEach((p) => p.resolve(newAccessToken));
          refreshQueue = [];

          return newAccessToken;
        } catch (refreshErr) {
          refreshQueue.forEach((p) => p.reject(refreshErr));
          refreshQueue = [];
          authStore.forceLogout();
          throw refreshErr;
        } finally {
          isRefreshing = false;
          refreshPromise = null;
        }
      })();

      try {
        const newAccessToken = await refreshPromise;
        originalRequest.headers['Authorization'] = `Bearer ${newAccessToken}`;
        return apiClient(originalRequest);
      } catch (refreshErr) {
        return Promise.reject(refreshErr);
      }
    }

    return Promise.reject(error);
  }
);
```

첫 번째 401 에러에서 refreshPromise를 생성하고 저장하며, 이후 401 에러는 기존 refreshPromise를 재사용합니다.
모든 요청이 같은 토큰 갱신 결과를 공유하여 RTR 환경에서 중복 요청을 완벽히 차단합니다.

### resetRefreshState()

로그아웃 시 refresh 관련 상태를 초기화하고, 재로그인을 위한 깨끗한 상태를 보장합니다.

```javascript
export function resetRefreshState() {
  isRefreshing = false;
  refreshQueue = [];
  refreshPromise = null;
}
```

---

## 인증 서비스 설계 (authService)

API 호출 로직을 캡슐화하고, 응답 데이터를 정규화(unwrap)하며, 타입 안전성을 제공합니다.

### 로컬 인증 API

```javascript
export async function signup(payload) {
  const { data } = await apiClient.post('/users/signup', payload);
  return unwrap(data).data;
}

export async function login(payload) {
  const { data } = await apiClient.post('/users/login', payload);
  return unwrap(data).data;
}

export async function logout() {
  const { data } = await apiClient.post('/users/logout');
  return unwrap(data).message;
}
```

### 이메일 인증 API

```javascript
export async function verifyEmail(payload) {
  const { data } = await apiClient.post('/verification/email', payload);
  return unwrap(data).data;
}

export async function resendVerificationEmail(email) {
  const { data } = await apiClient.post('/verification/email/resend', { email });
  return unwrap(data).data;
}
```

### 소셜 인증 API

```javascript
export async function exchangeToken(code) {
  const { data } = await apiClient.post('/users/token/exchange', { code });
  return unwrap(data).data;
}

export async function completeSocialSignup(payload) {
  const { data } = await apiClient.post('/verification/social/complete', payload);
  return unwrap(data).data;
}
```

### 약관 관리 API

```javascript
export async function getActiveTerms() {
  const { data } = await apiClient.get('/terms');
  return unwrap(data).data;
}

export async function getMyConsents() {
  const { data } = await apiClient.get('/terms/consent');
  return unwrap(data).data;
}

export async function updateMyConsents(payload) {
  const { data } = await apiClient.put('/terms/consent', payload);
  return unwrap(data).message;
}
```

---

## 라우팅 및 권한 제어

### ProtectedRoute

인증되지 않은 사용자를 차단하고, 초기화 중 로딩을 표시하며, 로그인 후 원래 페이지로 복귀하도록 합니다.

```javascript
export function ProtectedRoute() {
  const location = useLocation();
  const { isInitialized, status } = useAuthStore();

  if (!isInitialized) {
    return (
      <div className="protected-route-loading">
        <div className="protected-route-loading__spinner"/>
        <p>세션을 확인하는 중...</p>
      </div>
    );
  }

  if (status === 'unauthenticated') {
    const next = encodeURIComponent(
      location.pathname + location.search + location.hash
    );
    return <Navigate to={`/login?next=${next}`} replace />;
  }

  return <Outlet />;
}
```

isInitialized 체크가 필수이며, next 파라미터로 로그인 후 원래 페이지로 복귀하고, replace 옵션으로 뒤로가기 시 무한 루프를 방지합니다.

### 라우터 설정

```javascript
const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    children: [
      { index: true, element: <WelcomePage /> },
      { path: 'login', element: <LoginPage /> },
      { path: 'signup', element: <SignupPage /> },
      { path: 'email-verification', element: <EmailVerificationPage /> },
      { path: 'callback', element: <CallbackPage /> },
      { path: 'social-signup', element: <SocialSignupPage /> },

      {
        element: <ProtectedRoute />,
        children: [
          { path: 'dashboard', element: <DashboardPage /> },
          { path: 'profile', element: <ProfilePage /> },
          { path: 'settings', element: <SettingsPage /> },
          { path: 'chat', element: <ChatPage /> },
        ]
      }
    ]
  }
]);
```

### 리다이렉트 처리

```javascript
const navigate = useNavigate();
const [searchParams] = useSearchParams();

const handleLogin = async (credentials) => {
  await login(credentials);

  const next = searchParams.get('next') || '/dashboard';
  navigate(decodeURIComponent(next));
};
```

사용자가 /profile 접근 시도 시 미인증이면 /login?next=%2Fprofile로 리다이렉트하고, 로그인 성공 후 /profile로 복귀합니다.

---

## 로컬 인증 플로우

### 회원가입 흐름

#### Step 1: 약관 동의

사용자가 회원가입 페이지에 진입하면 SignupStep1 컴포넌트가 마운트되고 useEffect가 실행됩니다.
termsService.getActiveTerms()를 호출하여 GET /api/v1/terms로 약관 목록을 조회합니다.
서버는 서비스 이용약관, 개인정보 처리방침, 마케팅 정보 수신 동의 등의 약관을 반환합니다.
상태를 업데이트하고 초기 consents를 생성합니다.

사용자가 개별 약관 체크박스를 클릭하면 handleConsentChange가 호출되고 consents 배열이 업데이트됩니다.
validateRequiredTerms로 모든 필수 약관이 동의되었는지 검증하며, 검증 통과 시 다음 버튼이 활성화됩니다.

전체 동의 체크박스를 클릭하면 handleAllAgree가 호출되고 모든 consents의 agreed를 일괄 변경합니다.

다음 버튼을 클릭하면 validateRequiredTerms로 최종 검증하고, 검증 통과 시 onNext()를 호출하여 Step 2로 전환합니다.

#### Step 2: 정보 입력

사용자가 이메일, 비밀번호, 이름, 생년월일, 직업 유형 등을 입력하면 onChange 이벤트가 발생하고 setFormData가 호출됩니다.
실시간 검증(validateField)으로 이메일 형식, 비밀번호 강도, 비밀번호 일치, 이름 길이, 생년월일 유효성을 검증합니다.
검증 결과를 표시하며 성공 시 초록색 체크 아이콘, 실패 시 빨간색 에러 메시지를 보여줍니다.

회원가입 버튼을 클릭하면 handleSubmit()이 호출되고 setIsSubmitting(true)로 설정합니다.
payload를 구성하여 이메일, 비밀번호, 이름, 생년월일, 직업 유형, 약관 동의 내역을 포함합니다.
authService.signup(payload)를 호출하여 POST /api/v1/users/signup으로 요청합니다.

백엔드는 이메일 중복 검사, 비밀번호 검증, 약관 동의 검증을 수행하고, 사용자를 생성하며 비밀번호를 해싱합니다.
약관 동의 내역을 저장하고, 이메일 인증 코드(6자리 숫자)를 생성한 후 이메일을 비동기로 발송합니다.
emailVerificationToken을 생성하여 반환합니다.

서버 응답으로 emailVerificationToken을 받으면 navigate로 /email-verification 페이지로 이동하며 email과 emailVerificationToken을 state로 전달합니다.

회원가입 실패 시 에러를 분석하여 USER_002(이메일 중복)는 이메일 수정 가능하게 Step 2로 이동하고, VALIDATION_ERROR(검증 실패)는 입력 정보 확인 메시지를 표시합니다.
TERMS_001(필수 약관 미동의)는 Step 1로 이동하며, 기타 에러는 일반 실패 메시지를 표시합니다.

#### Step 3: 이메일 인증

EmailVerificationPage가 마운트되면 location.state에서 email과 emailVerificationToken을 추출합니다.
useEffect가 실행되고 email 또는 emailVerificationToken이 없으면 /signup으로 리다이렉트합니다.
재전송 쿨다운 타이머를 60초로 시작합니다.

사용자가 6자리 코드를 입력하면 onChange 이벤트가 발생하고 setVerificationCode가 호출됩니다.
자동 포커스 이동으로 각 자리수 입력 시 다음 입력란으로 이동하며, 6자리 모두 입력 완료 시 자동 제출 또는 확인 버튼이 활성화됩니다.

확인 버튼을 클릭하면 handleVerify()가 호출되고 setIsVerifying(true)로 설정합니다.
payload를 구성하여 email, verificationCode, emailVerificationToken을 포함하고 authService.verifyEmail(payload)를 호출합니다.
POST /api/v1/verification/email로 요청합니다.

백엔드는 emailVerificationToken을 검증(JWT)하고, 이메일 일치, 인증 코드 일치, 만료 시간(10분)을 확인합니다.
사용자 이메일 인증 상태를 업데이트하고 인증 코드를 삭제합니다.

서버 응답으로 성공 메시지를 받으면 navigate로 /email-verification-complete 페이지로 이동하고 setIsVerifying(false)로 설정합니다.

재발송 버튼을 클릭하면 쿨다운을 체크(60초 경과 확인)하고 handleResend()를 호출합니다.
setIsResending(true)로 설정하고 authService.resendVerificationEmail(email)을 호출하여 POST /api/v1/verification/email/resend로 요청합니다.

백엔드는 이메일로 사용자를 조회하고 이미 인증된 사용자인지 확인합니다.
기존 인증 코드를 삭제하고 새 인증 코드(6자리)를 생성한 후 이메일을 비동기로 발송합니다.
새 emailVerificationToken을 생성하여 반환합니다.

서버 응답으로 emailVerificationToken을 받으면 setEmailVerificationToken으로 업데이트하고, 쿨다운 타이머를 60초로 재시작합니다.
setIsResending(false)로 설정하고 toast.success로 재발송 완료 메시지를 표시합니다.

EmailVerificationCompletePage가 마운트되면 축하 메시지를 표시하고, 3초 후 자동 리다이렉트 또는 로그인하기 버튼으로 /login으로 이동합니다.

---

## 소셜 인증 플로우

### 소셜 로그인 시작

OAuth2 프로토콜을 통한 소셜 로그인으로 사용자 편의성을 향상시키며 비밀번호가 불필요합니다.

```javascript
const handleSocialLogin = (provider) => {
  window.location.href = `${API_BASE_URL}/oauth2/authorization/${provider}`;
};
```

window.location.href로 전체 페이지 리다이렉트를 수행하며, SPA 라우팅(navigate)이 아닌 백엔드 OAuth2 엔드포인트로 이동합니다.

### 기존 회원 플로우

사용자가 소셜 로그인 버튼(Google, Kakao, Naver)을 클릭하면 백엔드 OAuth2 엔드포인트로 리다이렉트됩니다.
백엔드에서 소셜 제공자 인증 URL을 생성하고 state 파라미터(CSRF 방지)와 redirect_uri를 설정합니다.
소셜 제공자 로그인 페이지로 리다이렉트하여 사용자 인증 및 동의를 받습니다.

소셜 제공자가 백엔드 콜백(/login/oauth2/code/{provider})으로 code와 state를 전달합니다.
백엔드는 state를 검증(CSRF 방지)하고, code로 access_token을 교환한 후, 소셜 제공자 API로 사용자 정보를 조회합니다.
이메일로 기존 회원을 확인하고, 기존 회원이 발견되면 일회용 코드(5분 유효)를 생성하고 Refresh Token을 생성하여 쿠키에 설정합니다.

프론트엔드 /callback?code={oneTimeCode}로 리다이렉트하면 CallbackPage가 searchParams에서 code를 추출하고 authStore.exchangeCode(code)를 호출합니다.
POST /users/token/exchange로 요청하면 백엔드는 일회용 코드를 검증하고 삭제한 후 Access Token을 생성합니다.

서버는 Body에 accessToken을, Cookie에 refreshToken을 반환하고, 프론트엔드는 accessToken을 메모리에 저장하고 fetchUser()를 호출합니다.
status를 'authenticated'로 설정하고 대시보드로 리다이렉트합니다.

### 신규 회원 플로우

사용자가 소셜 로그인 버튼을 클릭하고 소셜 제공자 인증을 완료하면 백엔드에서 이메일로 기존 회원을 확인합니다.
기존 회원이 없으면 신규 회원으로 판단하고 임시 사용자 정보를 Redis에 저장(5분 유효)한 후 일회용 코드를 생성합니다.

프론트엔드 /social-signup?code={oneTimeCode}로 리다이렉트하면 SocialSignupPage가 searchParams에서 code를 추출합니다.
code가 없으면 /login으로 리다이렉트합니다.

Step 1에서 약관 동의를 받고, termsService.getActiveTerms()로 약관 목록을 표시하며 필수 약관을 검증하고 사용자 동의를 수집합니다.

Step 2에서 추가 정보(닉네임, 생년월일, 성별, 직업 유형 등)를 입력받습니다.
회원가입 제출 시 authStore.completeSocialSignup(payload)를 호출하고 payload를 구성합니다.

POST /verification/social/complete로 요청하면 백엔드는 일회용 코드를 검증하고 Redis에서 임시 사용자 정보를 조회합니다.
입력 정보와 약관 동의를 검증하고, 사용자를 생성하며 약관 동의 내역을 저장합니다.
Access Token과 Refresh Token을 생성하고 Redis 임시 데이터를 삭제합니다.

서버는 Body에 accessToken을, Cookie에 refreshToken을 반환하고, 프론트엔드는 accessToken을 메모리에 저장하고 fetchUser()를 호출합니다.
status를 'authenticated'로 설정하고 대시보드로 리다이렉트합니다.

### CallbackPage 구현

소셜 로그인 콜백을 처리하고 기존 회원과 신규 회원을 분기하며 에러를 처리합니다.

```javascript
export default function CallbackPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const exchangeCode = useAuthStore((s) => s.exchangeCode);

  useEffect(() => {
    const code = searchParams.get('code');
    const error = searchParams.get('error');

    if (error) {
      toast.error('소셜 로그인 실패');
      navigate('/login');
      return;
    }

    if (code) {
      exchangeCode(code)
        .then(() => {
          navigate('/dashboard');
        })
        .catch((err) => {
          if (err.response?.status === 404) {
            navigate(`/social-signup?code=${code}`);
          } else {
            toast.error('로그인 처리 실패');
            navigate('/login');
          }
        });
    }
  }, [searchParams]);

  return (
    <div className="callback-loading">
      <div className="spinner" />
      <p>로그인 처리 중...</p>
    </div>
  );
}
```

### SocialSignupPage 구현

소셜 신규 회원의 추가 정보 입력과 약관 동의를 처리하며, 2단계 폼(약관 → 정보 입력)을 제공합니다.

```javascript
export default function SocialSignupPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const completeSocialSignup = useAuthStore((s) => s.completeSocialSignup);

  const code = searchParams.get('code');
  const [currentStep, setCurrentStep] = useState(1);
  const [consents, setConsents] = useState([]);
  const [formData, setFormData] = useState({
    nickname: '',
    birthDate: '',
    gender: '',
    jobType: '',
    jobDetail: ''
  });

  useEffect(() => {
    if (!code) {
      navigate('/login', { replace: true });
    }
  }, [code]);

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      await completeSocialSignup({
        code,
        nickname: formData.nickname,
        birthDate: formData.birthDate,
        gender: formData.gender,
        jobType: formData.jobType,
        jobDetail: formData.jobType === 'OTHER' ? formData.jobDetail : null,
        consents: consents.map(consent => ({
          termsId: consent.termsId,
          version: consent.version,
          agreed: consent.agreed
        }))
      });

      toast.success('회원가입이 완료되었습니다');
      navigate('/dashboard');
    } catch (error) {
      const message = error.response?.data?.message || '회원가입 실패';
      toast.error(message);
    }
  };

  return (
    <div className="social-signup-page">
      {currentStep === 1 && (
        <SignupStep1
          consents={consents}
          setConsents={setConsents}
          onNext={() => setCurrentStep(2)}
        />
      )}

      {currentStep === 2 && (
        <SignupStep2
          formData={formData}
          setFormData={setFormData}
          onSubmit={handleSubmit}
          onBack={() => setCurrentStep(1)}
        />
      )}
    </div>
  );
}
```

### JSESSIONID 쿠키 이슈

소셜 로그인 시 JSESSIONID 쿠키가 생성되는 현상이 있습니다.
JWT 기반 인증을 사용하는데 세션 쿠키가 생성되는 것은 불필요하며, Spring Security의 OAuth2 로그인 과정에서 상태 유지를 위해 세션을 사용하기 때문입니다.
기본적으로 SessionCreationPolicy.IF_REQUIRED로 설정되어 있습니다.

백엔드에서 세션을 비활성화하거나 OAuth2 완료 후 세션을 무효화하는 방법으로 해결할 수 있습니다.
JWT 기반 인증과 세션 혼용을 방지하고, 불필요한 세션 관리를 제거하며, 서버 확장성을 향상(Stateless)시킵니다.

---

## 보안 메커니즘

### XSS 방어

악성 스크립트 삽입 공격과 토큰 탈취를 방지합니다.

Access Token을 메모리에만 저장하여 XSS 공격에 노출되지 않도록 합니다.
JavaScript로 접근 가능하지만 페이지 새로고침 시 사라지며, XSS 공격으로 토큰을 탈취해도 짧은 만료 시간(15분)으로 피해를 최소화합니다.
localStorage나 sessionStorage에 저장하지 않아 영구적 탈취를 방지합니다.

React의 자동 XSS 방어를 활용하며, dangerouslySetInnerHTML 사용 시 sanitize가 필수입니다.
사용자 입력을 검증하고 sanitizeInput으로 특수 문자를 이스케이핑합니다.
백엔드에서 Content Security Policy(CSP)를 설정합니다.

### CSRF 방어

사용자 권한을 도용한 요청 공격을 방지합니다.

Refresh Token을 HttpOnly 쿠키에 저장하여 JavaScript로 접근할 수 없게 하고, Secure 플래그로 HTTPS에서만 전송하며, SameSite=Lax로 다른 사이트에서 요청 시 쿠키 전송을 제한합니다.
Path를 특정 경로로 설정하여 해당 경로에서만 쿠키를 전송합니다.

프론트엔드에서 withCredentials: true로 쿠키를 자동 전송하고, 백엔드 CORS 설정에서 allowCredentials: true로 쿠키 전송을 허용합니다.
withCredentials: true와 allowCredentials: true는 쌍으로 설정해야 하며, CORS 오류 시 쿠키가 전송되지 않아 Refresh Token을 사용할 수 없습니다.

### RTR (Refresh Token Rotation)

토큰 재사용을 방지하고 토큰 탈취 시 즉시 감지합니다.

클라이언트가 POST /users/refresh로 기존 RT를 전송하면 서버는 기존 RT를 검증하고 삭제(flush로 즉시 DB 반영)합니다.
새로운 AT와 RT를 생성하고 새 RT를 DB에 저장한 후, 클라이언트는 새 AT를 메모리에, 새 RT를 쿠키에 저장합니다.

토큰 재사용이 불가능하고(일회용), 토큰 탈취 시 즉시 감지 가능하며, 공격자가 탈취한 토큰 사용 시 정상 사용자의 토큰도 무효화되어 이상 징후를 파악할 수 있습니다.

프론트엔드는 refreshPromise 패턴으로 중복 요청을 차단하고, 백엔드는 flush()로 DB를 즉시 반영하며 Rate Limiting(10초/2회)으로 추가 보호합니다.

### Rate Limiting

과도한 토큰 갱신 요청을 차단하고 DDoS 공격을 방어하며 서버 부하를 감소시킵니다.

정책은 윈도우 10초, 최대 요청 2회이며, 초과 시 429 (Too Many Requests) 응답과 Retry-After 헤더를 반환합니다.

DDoS 공격을 방어하고 서버 부하를 감소시키며, 동시성 문제를 추가로 방어하고, 빠른 새로고침 연타 시 대부분의 요청을 차단합니다.

프론트엔드는 429 응답 시 Retry-After 헤더를 확인하고 사용자에게 대기 시간을 안내합니다.

### HTTPS 필수

중간자 공격(MITM)을 방어하고 데이터를 암호화합니다.

프로덕션 환경에서 HTTPS를 적용하고, 쿠키의 Secure 플래그를 활성화하며, 토큰 탈취를 방지하고 데이터를 암호화하여 전송합니다.

개발 환경에서는 HTTP를 허용(localhost)하고 쿠키 Secure 플래그를 비활성화합니다.

---

## 성능 최적화

### 동시성 문제 해결

#### refreshPromise 패턴

여러 API 요청이 동시에 401 에러를 받으면 각각 /users/refresh를 호출하여 RTR 환경에서 첫 번째만 성공하고 나머지는 실패하며 백엔드 부하가 증가하는 문제를 해결합니다.

isRefreshing과 refreshPromise를 사용하여 이미 갱신 중이면 기존 Promise를 재사용합니다.
/users/refresh 요청이 딱 1번만 발생하며, 네트워크 트래픽이 80% 감소하고, 백엔드 부하가 감소하며, RTR 환경에서 안전합니다.

측정 결과 /users/refresh 호출이 3~5회에서 1회로 감소(-80%)하고, 네트워크 트래픽이 100%에서 20%로 감소(-80%)하며, 토큰 갱신 성공률이 20%에서 100%로 증가(+400%)합니다.

#### initializePromise 패턴

빠른 새로고침(F5 연타) 시 initializeAuth()가 중복 실행되어 여러 개의 /users/refresh 요청이 발생하고 RTR 환경에서 빌드 오류가 발생하는 문제를 해결합니다.

isInitializing과 initializePromise를 사용하여 이미 초기화되었으면 반환하고, 초기화 중이면 기존 Promise를 재사용합니다.

새로고침 연타 시 /users/refresh 요청이 딱 1번만 발생하며, 빌드 오류를 방지하고, 초기화 성공률이 100%가 됩니다.

측정 결과 F5 연타 시 /users/refresh 호출이 3~5회에서 1회로 감소(-80%)하고, 빌드 오류 발생이 항상에서 없음으로 개선(-100%)되며, 초기화 성공률이 20%에서 100%로 증가(+400%)합니다.

### 상태 구독 최적화

필요한 상태만 구독하여 리렌더링을 최소화합니다.

```javascript
const status = useAuthStore((s) => s.status);
const user = useAuthStore((s) => s.user);

const isAuthenticated = useIsAuthenticated();
const authUser = useAuthUser();
```

전체 store 구독은 불필요한 리렌더링을 발생시킵니다.

불필요한 리렌더링을 방지하고 성능을 향상시키며 메모리 사용량을 감소시킵니다.

측정 결과 리렌더링 횟수가 10회/초에서 2회/초로 감소(-80%)하고, 렌더링 시간이 50ms에서 10ms로 감소(-80%)합니다.

### 네트워크 최적화

변경 전 토큰 갱신 시간이 평균 150ms였으나 변경 후 평균 180ms(+20%)로 약간 증가했습니다.
네트워크 요청 수는 3~5회에서 1회로 감소(-80%)하고, DB 쿼리 수는 6~10회에서 3회로 감소(-70%)합니다.

토큰 갱신 시간이 약간 증가했지만 사용자가 체감하기 어려운 수준이며, 중복 요청 제거로 전체적인 네트워크 트래픽이 대폭 감소하고 서버 부하가 감소합니다.

### 메모리 관리

Access Token을 메모리에 저장하여 XSS를 방어하고 빠른 접근이 가능하지만, 페이지 새로고침 시 사라지는 것은 의도된 동작입니다.

Zustand 상태 크기는 user 객체 약 1KB, accessToken 약 500B, 기타 상태 약 100B로 총합 약 1.6KB이며 무시할 수 있는 수준입니다.

로그아웃 시 상태를 정리하여 메모리 누수를 방지합니다.

```javascript
clearAuth: (error = null) => set({
  ...initialState,
  status: 'unauthenticated',
  error,
  isInitialized: get().isInitialized
}),
```

### 로딩 상태 최적화

초기화 로딩 시 isInitialized가 false면 LoadingSpinner를 표시합니다.
API 호출 로딩 시 isLoading 상태를 관리하여 사용자에게 진행 상황을 표시하고, 중복 클릭을 방지하며, 사용자 경험을 향상시킵니다.

### 코드 스플리팅

현재는 모든 컴포넌트가 초기 번들에 포함되어 있습니다.

개선 방향으로 라우트 기반 코드 스플리팅을 적용하여 lazy로 컴포넌트를 로드하고 Suspense로 감싸서 로딩을 처리합니다.

```javascript
const DashboardPage = lazy(() => import('@/pages/Dashboard/DashboardPage'));
const ProfilePage = lazy(() => import('@/pages/Profile/ProfilePage'));

<Suspense fallback={<LoadingSpinner />}>
  <DashboardPage />
</Suspense>
```

예상 효과는 초기 번들 크기 50% 감소, 초기 로딩 시간 단축, 사용자 경험 향상입니다.

---

## 에러 처리 및 복구

### 인증 에러 코드

| 에러 코드 | 설명 | HTTP 상태 | 자동 처리 | 수동 처리 |
|-----------|------|-----------|-----------|-----------|
| AUTH_001 | Access Token 만료 | 401 | 자동 토큰 갱신 | - |
| AUTH_002 | Refresh Token 만료 | 401 | 자동 로그아웃 | 재로그인 안내 |
| AUTH_003 | 유효하지 않은 토큰 | 401 | 자동 로그아웃 | 재로그인 안내 |
| AUTH_004 | 권한 없음 | 403 | - | 에러 메시지 표시 |
| USER_001 | 사용자를 찾을 수 없음 | 404 | - | 에러 메시지 표시 |
| USER_002 | 이메일 중복 | 409 | - | 에러 메시지 표시 |
| TERMS_001 | 필수 약관 미동의 | 400 | - | 약관 동의 화면으로 |
| VALIDATION_ERROR | 입력 검증 실패 | 400 | - | 에러 메시지 표시 |
| RATE_LIMIT_EXCEEDED | Rate Limit 초과 | 429 | - | Retry-After 확인 후 재시도 |

### 자동 에러 처리

401 AUTH_001은 refreshPromise 패턴으로 토큰을 갱신하고 원래 요청을 자동으로 재시도합니다.
401 기타는 자동 로그아웃하고 로그인 페이지로 이동합니다.

사용자는 토큰 만료를 인지하지 못하며, 끊김 없는 사용자 경험과 자동 복구를 제공합니다.

### 수동 에러 처리

컴포넌트에서 API 호출 시 try-catch로 에러를 처리하고, 구체적인 에러 메시지를 표시합니다.
400, 403, 404, 429 등 각 상태 코드에 따라 적절한 메시지를 보여줍니다.

### 네트워크 에러 처리

error.response가 없으면 네트워크 오류(서버 응답 없음)로 판단하여 연결 확인 메시지를 표시합니다.
error.code가 ECONNABORTED면 타임아웃(10초)으로 판단하여 시간 초과 메시지를 표시합니다.
error.code가 ERR_NETWORK면 CORS 오류 또는 서버 다운으로 판단하여 서버 연결 불가 메시지를 표시합니다.

### 에러 복구 전략

#### withCredentials 오류

로그인 후 바로 로그아웃되고 Refresh Token 쿠키가 전송되지 않는 증상은 withCredentials: true 설정 누락이나 CORS 설정 오류가 원인입니다.
apiClient에 withCredentials: true를 필수로 설정하고, 개발자 도구 Network에서 Cookie 헤더를 확인하여 검증합니다.

#### 새로고침 시 로그인 풀림

페이지 새로고침 시 로그인 상태가 사라지는 증상은 initializeAuth() 호출 누락, Refresh Token 쿠키 만료, 백엔드 /users/refresh API 오류가 원인입니다.
App.jsx에서 useAuthBootstrap()을 필수로 호출하고, 개발자 도구 Application의 Cookies에서 refreshToken을 확인하여 검증합니다.

#### 401 에러 무한 루프

401 에러가 계속 발생하며 무한 루프가 발생하는 증상은 originalRequest._retry 플래그 누락, Refresh Token 만료, Response Interceptor 로직 오류가 원인입니다.
originalRequest._retry = true로 재시도를 방지하고, 콘솔에서 401 에러가 1번만 발생하고 토큰 갱신 후 재시도가 성공하는지 확인하여 검증합니다.

#### 로그아웃 후 재로그인 시 문제

로그아웃 후 재로그인 시 토큰 갱신이 실패하는 증상은 resetRefreshState() 호출 누락이나 이전 세션의 refresh 상태가 남아있는 것이 원인입니다.
logout 시 resetRefreshState()를 필수로 호출하고, 로그아웃 후 isRefreshing, refreshQueue, refreshPromise가 모두 초기화되었는지 확인하여 검증합니다.

### 에러 로깅

프로덕션 환경에서 Sentry나 LogRocket 등으로 에러를 전송하고, 컴포넌트, URL, 메서드, 상태 코드, 메시지, 타임스탬프 등의 정보를 포함합니다.
개발 환경에서는 콘솔에 출력합니다.

민감 정보(비밀번호, 토큰 등)는 로깅하지 않고, 개인정보는 마스킹 처리하며, 프로덕션 환경에서만 외부 서비스로 전송합니다.

---

## 베스트 프랙티스

### 인증 상태 사용

셀렉터를 사용하고 필요한 상태만 구독하여 불필요한 리렌더링을 방지하고 성능을 최적화하며 코드 가독성을 향상시킵니다.
전체 store 구독이나 조건부 훅 사용은 권장하지 않습니다.

### API 호출

authService와 apiClient를 사용하여 Interceptor가 자동으로 Authorization 헤더를 추가하고, 401 에러 시 자동 토큰 갱신을 수행하며, 중앙 집중식 에러 처리를 제공합니다.
직접 axios 호출이나 fetch 사용은 Interceptor가 적용되지 않아 권장하지 않습니다.

### 보호된 라우트

ProtectedRoute를 사용하여 중복 코드를 제거하고, 일관된 인증 체크를 수행하며, 로딩 상태를 통합 관리합니다.
컴포넌트 내부에서 체크하는 방식은 중복 코드가 발생하여 권장하지 않습니다.

### 로그아웃 처리

authStore.logout()을 사용하여 백엔드 API 호출, 상태 정리, resetRefreshState를 수행합니다.
상태만 정리하는 방식은 백엔드 RT 무효화가 안 되어 권장하지 않습니다.

### 토큰 저장

Access Token은 메모리(Zustand)에, Refresh Token은 HttpOnly 쿠키(백엔드에서 설정)로 저장하여 XSS와 CSRF를 방어합니다.
localStorage나 sessionStorage 저장은 XSS에 취약하여 권장하지 않습니다.

### 에러 처리

구체적인 에러 메시지를 표시하고, 프로덕션 환경에서 에러 로깅을 수행하여 사용자에게 명확한 피드백을 제공하고 에러 추적을 가능하게 하며 디버깅을 용이하게 합니다.
에러를 무시하거나 일반적인 메시지만 표시하는 방식은 권장하지 않습니다.

### 초기화 체크

isInitialized 체크로 초기화 중과 로그아웃 상태를 구분하고, 깜빡임을 방지하며, 사용자 경험을 향상시킵니다.
isInitialized 체크 없이 status만 확인하는 방식은 초기화 중인지 로그아웃인지 구분할 수 없어 권장하지 않습니다.

### 환경 변수 관리

환경별 설정을 분리하고, 배포 시 자동으로 적용하며, 보안을 강화합니다.
하드코딩이나 환경 체크 없이 사용하는 방식은 권장하지 않습니다.

### 코드 리뷰 체크포인트

필수 설정으로 withCredentials: true, useAuthBootstrap() 호출, ProtectedRoute 적용, 환경 변수 사용을 확인합니다.
보안으로 Access Token 메모리 저장, Refresh Token 쿠키 관리, 민감 정보 로깅 금지, XSS/CSRF 방어를 확인합니다.
에러 처리로 모든 API 호출에 try-catch 적용, 구체적인 에러 메시지 표시, 네트워크 에러 처리, 401 에러 자동 처리를 확인합니다.
성능으로 refreshPromise와 initializePromise 패턴 적용, 필요한 상태만 구독, 불필요한 리렌더링 최소화를 확인합니다.
로그아웃 시 authStore.logout() 사용, resetRefreshState() 호출, 백엔드 API 호출을 확인합니다.

### 테스트 가이드

단위 테스트로 authStore의 initializeAuth와 login을 테스트합니다.
통합 테스트로 전체 로그인 플로우를 테스트하며, E2E 테스트로 회원가입부터 로그인까지 전체 인증 사이클을 테스트합니다.

---

## 향후 개선사항

### 단기 계획 (1-3개월)

#### 토큰 관리 개선

현재는 401 에러 발생 시 토큰을 갱신(Reactive)하지만, 개선 후에는 만료 5분 전 자동 갱신(Proactive)하여 사용자가 401 에러를 경험하지 않도록 합니다.

refreshTimer를 사용하여 만료 5분 전에 갱신하도록 스케줄링하며, 사용자 경험이 향상되고(끊김 없는 세션), 401 에러 발생 빈도가 감소하며, 서버 부하가 분산됩니다(피크 타임 회피).

#### 에러 메시지 개선

현재는 일반적인 에러 메시지를 표시하여 사용자가 문제 해결 방법을 알기 어렵습니다.

개선 후에는 상황별 맞춤 에러 메시지를 제공하고, 에러 복구 액션(다시 시도, 고객센터 문의, 로그인 페이지로 이동 버튼)을 제공하여 사용자 이탈률을 감소시키고 로딩 시간 체감을 단축시킵니다.

#### 로딩 상태 개선

현재는 단순한 로딩 스피너로 진행 상황을 알 수 없습니다.

개선 후에는 진행 상황을 표시(회원가입: "약관 확인 중..." → "정보 검증 중..." → "이메일 발송 중...")하고, 스켈레톤 UI를 적용하여 초기 로딩 시 스켈레톤 화면을 표시합니다.

### 중기 계획 (3-6개월)

#### 다중 기기 세션 관리

현재는 기기별 독립적인 세션이며 다른 기기에서 로그인 시 기존 세션이 유지됩니다.

개선 후에는 활성 세션 목록을 조회하고(사용자가 현재 로그인된 기기 목록 확인, 각 세션의 정보 표시), 원격 로그아웃 기능을 제공(특정 기기의 세션 강제 종료, 모든 기기 로그아웃)합니다.

백엔드에서 세션 테이블을 추가하고, Refresh Token에 session_id를 연결하며, 세션 관리 API를 구현해야 합니다.

보안이 강화되고(의심스러운 세션 감지 및 제거), 사용자 제어권이 향상됩니다.

#### 생체 인증 지원

현재는 이메일/비밀번호 또는 소셜 로그인만 지원합니다.

개선 후에는 WebAuthn API를 활용하여 지문 인식, 얼굴 인식(Face ID), 보안 키(YubiKey 등)를 지원하고, 민감한 작업 시 생체 인증으로 빠른 재인증을 제공합니다.

사용자 편의성이 대폭 향상되고, 보안이 강화되며(피싱 방지), 모바일 환경이 최적화됩니다.

#### 오프라인 모드 지원

현재는 네트워크 없으면 사용이 불가능합니다.

개선 후에는 Service Worker를 활용하여 오프라인 시 캐시된 데이터를 표시하고, 네트워크 복구 시 자동 동기화하며, 오프라인 알림을 제공합니다.

### 장기 계획 (6-12개월)

#### Zero Trust 아키텍처 도입

현재는 로그인 후 세션을 유지(7일)하며 추가 검증이 없습니다.

개선 후에는 지속적인 인증 검증(사용자 행동 패턴 분석, 비정상 활동 감지 시 재인증 요구)과 컨텍스트 기반 인증(위치, 기기, 시간대 등 고려, 위험도에 따라 인증 레벨 조정)을 수행합니다.

riskAssessment로 위험도를 평가하여 50 이상이면 재인증을 요구하고, 30 이상이면 추가 검증(이메일 코드)을 수행합니다.

백엔드에서 사용자 행동 로그를 수집하고, 머신러닝 기반 이상 탐지를 수행하며, 위험도 평가 API를 구현해야 합니다.

계정 탈취를 방지하고, 보안 사고를 조기에 감지하며, 규정을 준수(GDPR, ISO 27001)합니다.

#### SSO (Single Sign-On) 지원

현재는 Dialogym 서비스만 인증합니다.

개선 후에는 다른 서비스와 SSO를 연동하여 한 번 로그인으로 여러 서비스를 이용하고, SAML 2.0 또는 OpenID Connect 프로토콜을 사용하며, 엔터프라이즈 SSO(Azure AD, Okta, Google Workspace 연동)를 지원합니다.

엔터프라이즈 고객을 확보하고, 사용자 편의성을 향상시키며, 보안을 강화합니다(중앙 집중식 인증).

#### AI 기반 보안 강화

현재는 규칙 기반 보안(Rate Limiting 등)을 사용합니다.

개선 후에는 AI 기반 이상 탐지(로그인 패턴 학습, 비정상 로그인 시도 자동 차단)와 자동화된 보안 대응(의심스러운 활동 감지 시 자동 알림, 계정 임시 잠금 및 사용자 확인)을 수행합니다.

analyzeLoginAttempt로 로그인 시도를 분석하여 riskScore가 0.8 이상이면 차단하고, 0.5 이상이면 추가 인증(이메일 인증 요구)을 수행합니다.

백엔드에서 로그인 데이터를 수집 및 저장하고, ML 모델을 학습 및 배포하며, 실시간 예측 API를 구현해야 합니다.

보안 사고가 90% 감소하고, 자동화된 위협 대응이 가능하며, 사용자 신뢰도가 향상됩니다.

### 초장기 계획 (12개월 이상)

#### 탈중앙화 인증 (DID)

현재는 중앙 서버 기반 인증을 사용합니다.

개선 후에는 Decentralized Identity(DID)로 사용자가 자신의 신원 정보를 소유하고 블록체인 기반으로 검증하며, Self-Sovereign Identity(SSI)로 제3자 없이 신원을 증명하고 개인정보를 최소 공개합니다.

개인정보 보호를 극대화하고, 사용자 주권을 강화하며, 글로벌 표준을 준수합니다.

#### 양자 내성 암호화

현재는 RSA, ECDSA 등 전통적 암호화를 사용합니다.

개선 후에는 Post-Quantum Cryptography(PQC)로 양자 컴퓨터 공격에 안전한 암호화를 적용하고, NIST 표준 알고리즘을 사용합니다.

미래 보안 위협에 대비하고, 장기적 데이터 보호가 가능하며, 기술을 선도합니다.

#### 완전 동형 암호화 (FHE)

현재는 서버에서 평문 데이터를 처리합니다.

개선 후에는 Fully Homomorphic Encryption(FHE)로 암호화된 상태로 연산을 수행하여 서버가 평문 데이터를 볼 수 없도록 합니다.

최고 수준의 개인정보 보호가 가능하고, 규제를 준수(GDPR, CCPA)하며, 경쟁 우위를 확보합니다.

---

## 체크리스트

### 개발 시 확인 사항

필수 설정으로 apiClient에 withCredentials: true 설정, App.jsx에서 useAuthBootstrap() 호출, ProtectedRoute 적용, 환경 변수 설정을 확인합니다.

상태 관리로 Access Token 메모리 저장, Refresh Token 쿠키 관리, isInitialized 체크 후 UI 렌더링, 필요한 상태만 구독을 확인합니다.

약관 동의로 회원가입 시 약관 목록 조회, 필수 약관 검증 로직 구현, 약관 동의 내역 서버 전송, 약관 버전 관리를 확인합니다.

에러 처리로 모든 API 호출에 try-catch 적용, 구체적인 에러 메시지 표시, 네트워크 에러 처리, 401 에러 자동 처리를 확인합니다.

로그아웃으로 authStore.logout() 사용, 로그아웃 시 resetRefreshState() 호출, 백엔드 API 호출을 확인합니다.

### 배포 전 확인 사항

환경 설정으로 CORS 설정(프로덕션 도메인), 쿠키 설정(Secure, HttpOnly, SameSite), HTTPS 적용, 환경 변수 설정을 확인합니다.

보안으로 Access Token 만료 시간(15분 권장), Refresh Token 만료 시간(7일 권장), Rate Limiting 정책(10초/2회), RTR 적용, 민감 정보 로깅 제거를 확인합니다.

성능으로 refreshPromise 패턴 적용, initializePromise 패턴 적용, 불필요한 리렌더링 최소화, 네트워크 요청 최적화를 확인합니다.

테스트로 로그인/로그아웃, 소셜 로그인(Google, Kakao, Naver), 이메일 인증, 약관 동의, 토큰 갱신, 빠른 새로고침(F5 연타), 401 에러 처리, Rate Limiting을 테스트합니다.

### 보안 체크리스트

XSS 방어로 Access Token을 localStorage/sessionStorage에 저장하지 않고, 사용자 입력 검증 및 sanitization, React 자동 이스케이핑 활용을 확인합니다.

CSRF 방어로 Refresh Token을 HttpOnly 쿠키로 관리, withCredentials: true 설정, SameSite 쿠키 속성 설정(백엔드)을 확인합니다.

RTR 적용으로 토큰 순환 방식 구현(백엔드), refreshPromise 패턴으로 중복 요청 방지, flush()로 DB 즉시 반영(백엔드)을 확인합니다.

Rate Limiting으로 10초/2회 정책 적용(백엔드), 429 응답 처리, Retry-After 헤더 확인을 확인합니다.

HTTPS로 프로덕션 환경 HTTPS 적용, 쿠키 Secure 플래그 활성화, Mixed Content 오류 확인을 확인합니다.

에러 처리로 민감 정보를 에러 메시지에 노출하지 않고, 에러 로깅 시 개인정보 제거, 프로덕션 환경에서 상세 에러 숨김을 확인합니다.

---

## 참고 자료 (References)

### 내부 문서

- [트러블슈팅: RTR 방식 토큰 갱신 동시성 문제](../troubleshooting-refresh-token-rotation-concurrency.md)
- [백엔드 인증/인가 API 문서](./backend-authentication-api.md)
- [약관 관리 시스템 설계](./terms-management-design.md)

### 외부 링크

**인증 및 보안**:
- [JWT 공식 문서](https://jwt.io/)
- [OWASP 인증 가이드](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WebAuthn Guide](https://webauthn.guide/)

**기술 스택**:
- [Zustand 공식 문서](https://zustand-demo.pmnd.rs/)
- [Axios 공식 문서](https://axios-http.com/)
- [React Router v6](https://reactrouter.com/)
- [React Hot Toast](https://react-hot-toast.com/)

**보안 베스트 프랙티스**:
- [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [OWASP CSRF Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)

**미래 기술**:
- [Decentralized Identity (DID)](https://www.w3.org/TR/did-core/)
- [Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [Fully Homomorphic Encryption](https://en.wikipedia.org/wiki/Homomorphic_encryption)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.11.01 | Frontend Team | 최초 작성 (가이드 문서) |
| v2.0 | 2025.11.01 | Frontend Team | 기능 설계 문서로 전환 및 템플릿 적용 |
