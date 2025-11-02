# Dialogym 프론트엔드 아키텍처

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.02

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: 아키텍처를 이해하고 코드 구현 및 유지보수를 담당하는 개발자
* **백엔드 개발자**: 프론트엔드 구조를 이해하고 API 연동을 설계하는 개발자
* **시스템 아키텍트**: 전체 시스템 아키텍처를 설계하고 기술 의사결정을 하는 담당자
* **데브옵스 엔지니어**: 빌드 및 배포 파이프라인을 구성하는 담당자
* **신규 팀원**: Dialogym 프론트엔드 전체 구조를 빠르게 학습해야 하는 신규 합류자

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym 프론트엔드의 전체 아키텍처를 정의합니다.
React 19, Vite, React Router v7을 기반으로 구축되었으며, Zustand로 상태를 관리하고 Axios로 HTTP 통신을 처리합니다.
토큰 기반 인증 시스템을 채택하여 액세스 토큰은 메모리에, 리프레시 토큰은 HttpOnly 쿠키로 관리합니다.
레이어드 아키텍처로 Pages, Components, Services, Stores를 분리하여 관심사를 명확히 구분합니다.
자동 토큰 갱신과 에러 처리를 인터셉터로 중앙화하여 개발 생산성과 보안성을 확보합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [기술 스택](#기술-스택)
3. [프로젝트 구조](#프로젝트-구조)
4. [핵심 아키텍처 패턴](#핵심-아키텍처-패턴)
5. [상태 관리 전략](#상태-관리-전략)
6. [API 통신 레이어](#api-통신-레이어)
7. [인증 플로우](#인증-플로우)
8. [라우팅 시스템](#라우팅-시스템)
9. [스타일링 전략](#스타일링-전략)
10. [보안 고려사항](#보안-고려사항)
11. [성능 최적화](#성능-최적화)
12. [개발 가이드](#개발-가이드)
13. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 Dialogym 프론트엔드의 전체 아키텍처와 주요 기술 스택, 디렉토리 구조, 개발 패턴을 상세히 기록한 아키텍처 설계 문서입니다.

프론트엔드 아키텍처는 코드 품질, 유지보수성, 확장성을 결정하는 핵심 요소입니다.
명확한 아키텍처 정의를 통해 개발자는 일관된 패턴으로 개발하고, 신규 팀원은 빠르게 코드베이스를 이해할 수 있습니다.

본 문서는 Dialogym 프론트엔드의 모든 개발, 리팩토링, 기술 의사결정에 적용되며, 아키텍처 변경 시 반드시 업데이트해야 합니다.

---

## 기술 스택

### 핵심 라이브러리

React 19.1.1을 UI 라이브러리로 사용하고, Vite 7.1.11을 빌드 도구 및 개발 서버로 사용합니다.
React Router DOM 7.9.4로 클라이언트 사이드 라우팅을 구현합니다.

### 상태 관리

Zustand 5.0.8을 경량 상태 관리 라이브러리로 사용합니다.
zustand/middleware/immer로 불변성을 관리하고, zustand/middleware/devtools로 개발자 도구를 통합합니다.
zustand-persist로 상태 영속화를 필요시 적용합니다.

### HTTP 통신

Axios 1.12.2를 HTTP 클라이언트로 사용합니다.
인터셉터를 통한 토큰 관리와 자동 토큰 갱신 로직을 구현합니다.

### UI 및 스타일링

Ant Design 5.27.4를 UI 컴포넌트 라이브러리로 사용하고, SASS/SCSS를 CSS 전처리기로 사용합니다.
CSS Modules로 컴포넌트 스코프 스타일링을 적용하며, React Icons 5.5.0으로 아이콘을 관리합니다.

### 기타 주요 라이브러리

react-hot-toast 2.6.0으로 토스트 알림을 표시하고, react-markdown 10.1.0으로 마크다운을 렌더링합니다.
OpenAI 4.104.0으로 OpenAI API를 호출하며, @ricky0123/vad-react와 vad-web으로 음성 활동을 감지합니다.

### 개발 도구

ESLint 9.33.0으로 코드를 린팅하고, Storybook 9.1.15로 컴포넌트를 개발 및 문서화합니다.
Vitest 4.0.3로 테스트 프레임워크를 구성하며, Playwright 1.56.1로 E2E 테스트를 수행합니다.

---

## 프로젝트 구조

### 디렉토리 구조

```
src/
├── assets/          # 정적 리소스 (이미지, 폰트)
├── components/      # 재사용 가능한 UI 컴포넌트
├── hooks/           # 커스텀 React 훅
├── layouts/         # 레이아웃 컴포넌트
├── loaders/         # 라우트 로더 함수
├── pages/           # 페이지 컴포넌트
├── routes/          # 라우팅 설정
├── services/        # API 서비스 레이어
├── stores/          # Zustand 스토어
├── utils/           # 유틸리티 함수
├── App.jsx          # 루트 애플리케이션 컴포넌트
├── main.jsx         # 애플리케이션 진입점
└── index.css        # 글로벌 스타일
```

### 레이어 구분

Presentation Layer는 Pages와 Components로 UI를 렌더링합니다.
Business Logic Layer는 Stores와 Hooks로 비즈니스 로직을 관리합니다.
Data Access Layer는 Services로 API 호출을 캡슐화하고, Utils로 공통 유틸리티를 제공합니다.

### Path Alias

@/ 경로는 src/ 디렉토리를 가리키는 별칭으로 사용합니다.
예시로 `import Button from '@/components/Button'`과 같이 작성합니다.

---

## 핵심 아키텍처 패턴

### 애플리케이션 진입점

main.jsx에서 React 19의 createRoot API를 사용하여 애플리케이션을 렌더링합니다.

```jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';

ReactDOM.createRoot(document.getElementById('root')).render(
    <App />
);
```

Strict Mode는 미사용하며 필요시 추가할 수 있습니다.

### 루트 컴포넌트

App.jsx는 최초 진입 시 인증 부트스트랩을 실행하고, 글로벌 토스트 알림을 설정하며, 라우터를 제공합니다.

```jsx
function App() {
    useAuthBootstrap();

    return (
        <>
            <Toaster />
            <RouterProvider router={router} />
        </>
    );
}
```

### 레이아웃 시스템

AppLayout은 Outlet을 통한 중첩 라우팅을 지원하고, 조건부 헤더를 렌더링하며, 페이지별 타이틀을 관리합니다.

헤더 숨김 페이지는 웰컴 페이지 (/), 인증 관련 페이지 (/login, /signup 등), 대화 페이지 (/dialogue)입니다.

### 커스텀 훅

useAuthBootstrap은 앱 최초 로드 시 인증 상태를 초기화하고 리프레시 토큰으로 액세스 토큰 재발급을 시도합니다.
usePageTitle은 라우트별 페이지 타이틀을 자동으로 설정하여 document.title을 업데이트합니다.
useRealtimeSession은 실시간 세션을 관리합니다 (WebSocket 등).

---

## 상태 관리 전략

### Zustand Store 패턴

Immer 미들웨어로 불변성을 자동 관리하고, DevTools 미들웨어로 디버깅을 지원하며, 선택적 셀렉터 훅을 제공합니다.

```javascript
export const useAuthStore = create(
  devtools(
    immer((set, get) => ({
      user: null,
      accessToken: null,
      status: 'idle',

      login: async (credentials) => { /* ... */ },
      logout: async () => { /* ... */ },
      fetchUser: async () => { /* ... */ },
    })),
    { name: 'auth-store' }
  )
);
```

### 주요 스토어

authStore는 인증 상태 및 사용자 정보를 관리합니다.

### 셀렉터 훅

필요한 상태만 구독하여 성능을 최적화합니다.

```javascript
export const useIsAuthenticated = () => useAuthStore((s) => s.status === 'authenticated');
export const useAuthUser = () => useAuthStore((s) => s.user);
```

---

## API 통신 레이어

### 서비스 구조

```
services/
├── apiClient.js       # Axios 인스턴스 및 인터셉터
├── tokenManager.js    # 토큰 관리 유틸리티
├── authService.js     # 인증 관련 API
├── userService.js     # 사용자 관련 API
├── feedbackService.js # 피드백 관련 API
└── termsService.js    # 약관 관련 API
```

### apiClient 핵심 기능

동적 백엔드 URL 설정으로 환경에 따라 자동으로 백엔드 URL을 결정합니다.

```javascript
function getBackendBaseUrl() {
  const baseUrl = import.meta.env.VITE_API_BASE_URL;
  if (baseUrl && baseUrl.trim()) return baseUrl;

  const useDynamicHost = import.meta.env.VITE_USE_DYNAMIC_HOST === 'true';
  const backendPort = import.meta.env.VITE_BACKEND_PORT || '9090';

  if (useDynamicHost) {
    const { hostname, protocol } = window.location;
    return `${protocol}//${hostname}:${backendPort}`;
  }
  return `http://localhost:${backendPort}`;
}
```

요청 인터셉터는 모든 요청에 자동으로 Authorization 헤더를 추가하고 메모리에서 액세스 토큰을 가져옵니다.

응답 인터셉터는 401 에러를 자동 처리하고, 액세스 토큰 만료 시 자동 갱신하며, 토큰 갱신 중 중복 요청을 방지합니다 (큐 시스템).
갱신 실패 시 자동 로그아웃을 수행합니다.

### 토큰 관리 전략

액세스 토큰은 메모리(Zustand 스토어)에만 저장하여 XSS 공격에 대비합니다.
리프레시 토큰은 HttpOnly 쿠키로 백엔드에서 관리하여 XSS 공격을 방지합니다.
토큰 갱신 시 동시성을 제어합니다 (refreshQueue).

---

## 인증 플로우

### 초기화 플로우

main.jsx에서 App 컴포넌트를 렌더링하고, App.jsx에서 useAuthBootstrap 훅을 실행합니다.
authStore.initializeAuth()를 호출하여 리프레시 토큰으로 액세스 토큰 재발급을 시도합니다.
성공 시 사용자 정보를 로드하고, 실패 시 로그아웃 상태를 유지합니다.

### 로그인 플로우

사용자가 로그인 폼을 제출하면 authStore.login(credentials)를 호출합니다.
백엔드에서 액세스 토큰 및 리프레시 토큰(쿠키)를 반환하고, 액세스 토큰을 메모리(Zustand)에 저장합니다.
사용자 정보를 자동 로드하고 보호된 페이지로 리다이렉트합니다.

### 토큰 갱신 플로우

API 요청 시 401 에러가 발생하면 (액세스 토큰 만료) 응답 인터셉터가 에러를 감지합니다.
리프레시 토큰으로 새 액세스 토큰을 요청하고, 새 토큰을 메모리에 저장합니다.
실패한 원본 요청을 재시도하며, 갱신 실패 시 자동 로그아웃을 수행합니다.

### 로그아웃 플로우

authStore.logout()를 호출하면 백엔드에 로그아웃을 요청하여 리프레시 토큰을 무효화합니다.
프론트엔드 상태를 초기화하고 로그인 페이지로 리다이렉트합니다.

---

## 라우팅 시스템

### 라우트 트리

```
/ (AppLayout)
├── / (WelcomePage)
├── /login
├── /signup
├── /email-verification
├── /callback
├── /social-signup
└── Protected Routes
    ├── /scenarios
    ├── /dialogue
    ├── /create
    ├── /feedback/:sessionId
    └── /my-profile
```

### 라우터 구조

createBrowserRouter를 사용하며 (React Router v7) 중첩 라우팅 패턴을 적용하고 보호된 라우트 (ProtectedRoute)를 구현합니다.

### ProtectedRoute

인증되지 않은 사용자를 차단하고 로그인 페이지로 리다이렉트합니다.

```javascript
export function ProtectedRoute() {
  const { isInitialized, status } = useAuthStore();
  const location = useLocation();

  if (!isInitialized) {
    return <LoadingSpinner message="세션 확인 중..." />;
  }

  if (status === 'unauthenticated') {
    const next = encodeURIComponent(location.pathname + location.search);
    return <Navigate to={`/login?next=${next}`} replace />;
  }

  return <Outlet />;
}
```

---

## 스타일링 전략

### CSS Modules

컴포넌트별 스타일을 격리하며 파일명은 ComponentName.module.scss 형식을 사용합니다.

```jsx
import styles from './Button.module.scss';

function Button() {
  return <button className={styles.button}>Click</button>;
}
```

### 글로벌 스타일

src/index.css에 전역 스타일 및 CSS 변수를 정의하고, src/App.css에 앱 레벨 스타일을 정의합니다.

### Ant Design 커스터마이징

테마 설정은 필요시 App.jsx에서 ConfigProvider를 사용합니다.

---

## 보안 고려사항

### 토큰 보안

액세스 토큰은 메모리에만 저장하여 XSS 공격에 대비하고, 리프레시 토큰은 HttpOnly 쿠키로 XSS 공격을 방지합니다.
CSRF 방지를 위해 withCredentials: true를 설정합니다.

### API 통신

HTTPS를 사용하며 (프로덕션) CORS를 설정하고, 요청 타임아웃을 10초로 설정합니다.

---

## 성능 최적화

### 코드 스플리팅

React Router의 lazy loading을 활용할 수 있으며, 동적 import로 번들 크기를 최적화합니다.

### 상태 관리 최적화

Zustand의 선택적 구독으로 불필요한 리렌더링을 방지하고, 셀렉터 훅을 활용합니다.

### 빌드 최적화

Vite의 빠른 HMR (Hot Module Replacement)을 사용하며, 프로덕션 빌드 시 자동 최적화를 적용합니다.

---

## 개발 가이드

### 개발 명령어

```bash
# 개발 서버 시작 (포트 5050)
npm run dev

# 프로덕션 빌드
npm run build

# 빌드 미리보기
npm run preview

# 린팅
npm run lint

# Storybook 실행
npm run storybook

# Storybook 빌드
npm run build-storybook
```

### 파일 명명 규칙

컴포넌트는 PascalCase (예: UserProfile.jsx)를 사용하고, 훅은 camelCase with use 접두사 (예: useAuth.js)를 사용합니다.
서비스는 camelCase with Service 접미사 (예: authService.js)를 사용하며, 스토어는 camelCase with Store 접미사 (예: authStore.js)를 사용합니다.
유틸리티는 camelCase (예: normalize.js)를 사용합니다.

### Import 순서

React 및 외부 라이브러리를 먼저 import하고, 내부 컴포넌트 및 훅을 import합니다.
서비스 및 유틸리티를 import하고, 마지막으로 스타일을 import합니다.

### 환경 변수

VITE_API_BASE_URL은 백엔드 API 기본 URL을 지정하고, VITE_USE_DYNAMIC_HOST는 동적 호스트 사용 여부를 결정합니다.
VITE_BACKEND_PORT는 백엔드 포트를 설정하며 (기본값: 9090) .env는 개발 환경 설정, .env.production은 프로덕션 환경 설정, .env.template은 환경 변수 템플릿입니다.

### 테스트 전략

Storybook은 컴포넌트 단위 개발 및 문서화, 시각적 테스트, 접근성 테스트 (@storybook/addon-a11y)를 지원합니다.
Vitest는 단위 테스트 및 통합 테스트, Storybook과 통합 테스트를 지원하며, Playwright는 브라우저 기반 E2E 테스트, Vitest와 통합을 지원합니다.

### 문제 해결

토큰 갱신 실패 시 리프레시 토큰 만료는 자동 로그아웃으로 처리되고, 네트워크 오류는 에러 메시지 표시 및 재시도 유도로 처리됩니다.
CORS 이슈는 백엔드에서 CORS 설정을 확인하고 withCredentials: true 설정을 확인합니다.
환경 변수 미적용은 Vite 재시작이 필요하며 VITE_ 접두사를 확인합니다.

---

## 참고 자료 (References)

### 공식 문서

- [React 공식 문서](https://react.dev/)
- [Vite 공식 문서](https://vitejs.dev/)
- [Zustand 공식 문서](https://zustand-demo.pmnd.rs/)
- [React Router 공식 문서](https://reactrouter.com/)
- [Ant Design 공식 문서](https://ant.design/)
- [Axios 공식 문서](https://axios-http.com/)

### 내부 문서

- [Dialogym API 명세서](../api/api-specification.md)
- [인증 시스템 설계 문서](./frontend-authentication-security-design.md)
- [피드백 시스템 설계 문서](./frontend-feedback-system-design.md)
- [페이지 및 컴포넌트 명세서](./frontend-pages-components-specification.md)

### 추가 리소스

- [ESLint 공식 문서](https://eslint.org/)
- [Storybook 공식 문서](https://storybook.js.org/)
- [Vitest 공식 문서](https://vitest.dev/)
- [Playwright 공식 문서](https://playwright.dev/)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.11.02 | 왕택준 | 최초 작성 |
