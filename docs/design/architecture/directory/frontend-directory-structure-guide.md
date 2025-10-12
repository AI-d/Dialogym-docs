# 프론트엔드 디렉토리 구조 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.10

**문서 버전 (Version)**: v0.1

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: React 프로젝트 구조를 이해하고 컴포넌트를 올바른 위치에 작성하는 담당자
* **풀스택 개발자**: 프론트엔드 코드베이스 구조를 파악하고 기능을 개발하는 담당자
* **신규 합류자**: 프로젝트 디렉토리 구조와 파일 위치 규칙을 처음 학습하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Ant Design 기반 React 프로젝트의 디렉토리 구조를 정의합니다.
프로젝트는 기능 중심(feature-based) 구조를 채택하며, 비즈니스 로직은 features/ 디렉토리에 도메인별로 격리됩니다.
Ant Design 컴포넌트는 최대한 활용하되, 프로젝트 고유 스타일이 필요한 경우에만 shared/components/ui/에서 래핑합니다.
모든 공개 컴포넌트에는 Storybook Story 파일이 필수이며, 파일 네이밍은 PascalCase를 따릅니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Ant Design 기반 구조](#ant-design-기반-구조)
3. [전체 디렉토리 구조](#전체-디렉토리-구조)
4. [디렉토리별 상세 설명](#디렉토리별-상세-설명)
5. [파일 네이밍 규칙](#파일-네이밍-규칙)
6. [Import 경로 규칙](#import-경로-규칙)
7. [CSS 작성 규칙](#css-작성-규칙)
8. [운영 원칙](#운영-원칙)

---

## 문서 개요 (Overview)

본 문서는 프로젝트의 프론트엔드 디렉토리 구조를 표준화하기 위해 작성되었습니다.

프로젝트 규모가 커지면서 파일을 어디에 위치시켜야 할지, 어떤 기준으로 디렉토리를 나눠야 할지에 대한 혼란이 발생했습니다.
일관된 디렉토리 구조는 코드 검색성을 높이고, 신규 개발자의 온보딩 시간을 단축하며, 유지보수성을 향상시킵니다.

본 가이드는 Ant Design UI 라이브러리를 기반으로 하며, 기능 중심(feature-based) 아키텍처를 채택합니다.

---

## Ant Design 기반 구조

### Ant Design이란?

Ant Design은 엔터프라이즈급 React UI 라이브러리로, 60개 이상의 고품질 컴포넌트를 제공합니다.

---

### Ant Design이 제공하는 것

**UI 컴포넌트:**

- 기본: Button, Icon, Typography
- 레이아웃: Layout, Grid, Space, Divider
- 폼: Form, Input, Select, DatePicker, Upload
- 데이터 표시: Table, Card, List, Tree, Tabs
- 피드백: Modal, Message, Notification, Drawer
- 내비게이션: Menu, Dropdown, Pagination, Breadcrumb

**추가 제공:**

- 아이콘 시스템 (@ant-design/icons)
- 테마/스타일 시스템 (ConfigProvider)
- 폼 관리 및 유효성 검증
- 반응형 그리드 (24 컬럼)

---

### 우리가 만들어야 하는 것

**비즈니스 로직:**

- API 호출 및 데이터 관리
- 상태 관리 (Zustand, Redux 등)
- 인증/인가 로직
- 데이터 변환 및 가공

**도메인 컴포넌트:**

- 로그인 폼
- 대시보드 위젯
- 사용자 프로필 카드
- 도메인 특화 UI

**기타:**

- 라우팅 (React Router)
- 소셜 로그인 버튼 (브랜드 스타일)
- 커스텀 차트 및 시각화

---

### 디렉토리 구조 설계 원칙

**Ant Design 활용:**

- Ant Design 컴포넌트를 최대한 직접 사용
- 프로젝트 고유 스타일이 필요한 경우에만 shared/components/ui/에서 래핑
- 대부분의 경우 CSS를 새로 작성하지 않음

**기능 중심 구조:**

- 비즈니스 도메인별로 features/ 디렉토리에 격리
- 각 feature는 components, hooks, api, stores로 구성
- 재사용 가능한 것만 shared/로 이동

---

## 전체 디렉토리 구조

```
src/
├── app/                           # 앱 설정 및 진입점
│   ├── App.jsx                    # 메인 App 컴포넌트
│   ├── router.jsx                 # React Router 설정
│   └── providers.jsx              # Context Providers
│
├── features/                      # 기능별 모듈 (도메인 로직)
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm/
│   │   │   │   ├── LoginForm.jsx
│   │   │   │   ├── LoginForm.stories.js
│   │   │   │   └── LoginForm.css (필요시)
│   │   │   ├── SignupForm/
│   │   │   └── SocialLoginButtons/
│   │   ├── hooks/
│   │   │   ├── useAuth.js
│   │   │   └── useLogin.js
│   │   ├── api/
│   │   │   └── authApi.js
│   │   └── stores/
│   │       └── authStore.js
│   │
│   ├── dashboard/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── api/
│   │   └── stores/
│   │
│   └── users/
│       ├── components/
│       ├── hooks/
│       ├── api/
│       └── stores/
│
├── shared/                        # 공유 리소스
│   ├── components/
│   │   ├── ui/                    # Ant Design 래핑
│   │   │   ├── Button/
│   │   │   │   ├── Button.jsx
│   │   │   │   ├── Button.stories.js
│   │   │   │   └── Button.css (선택)
│   │   │   ├── Input/
│   │   │   ├── SocialButton/
│   │   │   │   ├── GoogleButton.jsx
│   │   │   │   ├── GoogleButton.stories.js
│   │   │   │   ├── KakaoButton.jsx
│   │   │   │   ├── NaverButton.jsx
│   │   │   │   └── SocialButton.css
│   │   │   └── Card/
│   │   │
│   │   └── layout/                # 레이아웃 컴포넌트
│   │       ├── Header/
│   │       │   ├── Header.jsx
│   │       │   ├── Header.stories.js
│   │       │   └── Header.css
│   │       ├── Sidebar/
│   │       ├── Footer/
│   │       └── MainLayout/
│   │
│   ├── hooks/                     # 공통 커스텀 훅
│   │   ├── useDebounce.js
│   │   ├── useLocalStorage.js
│   │   └── useMediaQuery.js
│   │
│   ├── utils/                     # 유틸리티 함수
│   │   ├── formatters.js
│   │   ├── validators.js
│   │   ├── constants.js
│   │   └── api.js
│   │
│   ├── types/                     # 타입 정의 (JSDoc)
│   │   ├── user.js
│   │   └── auth.js
│   │
│   └── styles/                    # 전역 스타일
│       ├── global.css
│       ├── variables.css
│       └── antd-theme.js
│
├── pages/                         # 페이지 컴포넌트
│   ├── LoginPage/
│   │   └── LoginPage.jsx
│   ├── SignupPage/
│   ├── DashboardPage/
│   ├── UsersPage/
│   └── NotFoundPage/
│
├── assets/                        # 정적 리소스
│   ├── images/
│   │   └── logo.png
│   ├── icons/
│   │   ├── google.svg
│   │   ├── kakao.svg
│   │   └── naver.svg
│   └── fonts/
│
├── .storybook/                    # Storybook 설정
│   ├── main.js
│   ├── preview.js
│   └── manager.js
│
├── main.jsx                       # 앱 진입점
├── index.html
├── vite.config.js
└── package.json
```

---

## 디렉토리별 상세 설명

### app/ - 앱 설정

애플리케이션의 최상위 설정과 진입점을 관리합니다.

**App.jsx**
```javascript
import { RouterProvider } from 'react-router-dom';
import { Providers } from './providers';
import router from './router';

function App() {
  return (
    <Providers>
      <RouterProvider router={router} />
    </Providers>
  );
}

export default App;
```

**providers.jsx**
```javascript
import { ConfigProvider } from 'antd';
import koKR from 'antd/locale/ko_KR';
import theme from '@/shared/styles/antd-theme';

export function Providers({ children }) {
  return (
    <ConfigProvider locale={koKR} theme={theme}>
      {children}
    </ConfigProvider>
  );
}
```

**router.jsx**
```javascript
import { createBrowserRouter } from 'react-router-dom';
import LoginPage from '@/pages/LoginPage';
import DashboardPage from '@/pages/DashboardPage';

const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  { path: '/dashboard', element: <DashboardPage /> },
]);

export default router;
```

---

### features/ - 기능별 모듈

비즈니스 도메인별로 구조화된 모듈입니다.

**구조 원칙:**
- 각 feature는 독립적인 모듈
- 다른 feature에 직접 의존하지 않음
- shared/를 통해서만 코드 공유

**하위 디렉토리:**

**components/**
해당 기능에만 사용되는 컴포넌트입니다.

```javascript
// features/auth/components/LoginForm/LoginForm.jsx
import { Form, Input, Button } from 'antd';
import { useAuth } from '../../hooks/useAuth';
import GoogleButton from '@/shared/components/ui/SocialButton/GoogleButton';

/**
 * 로그인 폼 컴포넌트
 */
function LoginForm() {
  const { login, isLoading } = useAuth();

  const handleSubmit = (values) => {
    login(values);
  };

  return (
    <Form onFinish={handleSubmit}>
      <Form.Item name="email" rules={[{ required: true }]}>
        <Input placeholder="이메일" />
      </Form.Item>
      <Form.Item name="password" rules={[{ required: true }]}>
        <Input.Password placeholder="비밀번호" />
      </Form.Item>
      <Button type="primary" htmlType="submit" loading={isLoading}>
        로그인
      </Button>
      <GoogleButton onClick={() => window.location.href = '/api/auth/google'} />
    </Form>
  );
}

export default LoginForm;
```

**hooks/**
비즈니스 로직을 담은 커스텀 훅입니다.

```javascript
// features/auth/hooks/useAuth.js
import { useAuthStore } from '../stores/authStore';
import { authApi } from '../api/authApi';

/**
 * 인증 관련 비즈니스 로직 훅
 */
export function useAuth() {
  const { setUser, setToken } = useAuthStore();

  const login = async (credentials) => {
    const response = await authApi.login(credentials);
    setToken(response.token);
    setUser(response.user);
  };

  const logout = () => {
    setToken(null);
    setUser(null);
  };

  return { login, logout };
}
```

**api/**
API 호출 함수들입니다.

```javascript
// features/auth/api/authApi.js
import { apiClient } from '@/shared/utils/api';

/**
 * 인증 관련 API
 */
export const authApi = {
  login: async (credentials) => {
    const response = await apiClient.post('/auth/login', credentials);
    return response.data;
  },

  logout: async () => {
    await apiClient.post('/auth/logout');
  },
};
```

**stores/**
Zustand 상태 관리입니다.

```javascript
// features/auth/stores/authStore.js
import { create } from 'zustand';

/**
 * 인증 상태 관리 스토어
 */
export const useAuthStore = create((set) => ({
  user: null,
  token: null,
  setUser: (user) => set({ user }),
  setToken: (token) => set({ token }),
}));
```

---

### shared/components/ui/ - Ant Design 래핑

Ant Design 컴포넌트를 프로젝트 스타일에 맞게 래핑합니다.

**언제 래핑하나요?**

- 프로젝트 전체에서 일관된 스타일 적용
- props 인터페이스 단순화
- 추가 기능 확장

**예시 1: 기본 래핑**

```javascript
// shared/components/ui/Button/Button.jsx
import { Button as AntButton } from 'antd';
import './Button.css';

/**
 * 프로젝트 표준 버튼 컴포넌트
 *
 * @param {Object} props
 * @param {'primary'|'secondary'|'danger'} props.variant - 버튼 스타일
 * @param {boolean} props.disabled - 비활성화 여부
 * @param {Function} props.onClick - 클릭 핸들러
 */
function Button({ variant = 'primary', ...props }) {
  return (
    <AntButton
      type={variant}
      className="project-button"
      {...props}
    />
  );
}

export default Button;
```

```css
/* Button.css - 프로젝트 고유 스타일만 추가 */
.project-button {
  border-radius: 8px;
  font-weight: 600;
}
```

**예시 2: 소셜 버튼**

```javascript
// shared/components/ui/SocialButton/GoogleButton.jsx
import { Button } from 'antd';
import { GoogleOutlined } from '@ant-design/icons';
import './SocialButton.css';

/**
 * 구글 로그인 버튼
 *
 * @param {Object} props
 * @param {Function} props.onClick - 클릭 핸들러
 * @param {string} props.children - 버튼 텍스트
 */
function GoogleButton({ onClick, children = '구글로 시작하기' }) {
  return (
    <Button
      icon={<GoogleOutlined />}
      size="large"
      block
      onClick={onClick}
      className="social-btn google-btn"
    >
      {children}
    </Button>
  );
}

export default GoogleButton;
```

```css
/* SocialButton.css */
.social-btn {
  font-weight: 600;
  margin-bottom: 12px;
}

.google-btn {
  border-color: #4285f4;
  color: #4285f4;
}

.google-btn:hover {
  background-color: #4285f4;
  color: white;
}

.kakao-btn {
  background-color: #fee500;
  border-color: #fee500;
  color: #000000;
}

.naver-btn {
  background-color: #03c75a;
  border-color: #03c75a;
  color: white;
}
```

---

### shared/components/layout/ - 레이아웃 컴포넌트

페이지 레이아웃을 구성하는 컴포넌트들입니다.

```javascript
// shared/components/layout/MainLayout/MainLayout.jsx
import { Layout } from 'antd';
import Header from '../Header';
import Sidebar from '../Sidebar';
import Footer from '../Footer';

const { Content } = Layout;

/**
 * 메인 레이아웃
 */
function MainLayout({ children }) {
  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header />
      <Layout>
        <Sidebar />
        <Content style={{ padding: '24px' }}>
          {children}
        </Content>
      </Layout>
      <Footer />
    </Layout>
  );
}

export default MainLayout;
```

---

### shared/hooks/ - 공통 훅

프로젝트 전역에서 재사용되는 커스텀 훅입니다.

```javascript
// shared/hooks/useDebounce.js
import { useState, useEffect } from 'react';

/**
 * 값을 디바운스합니다.
 *
 * @param {*} value - 디바운스할 값
 * @param {number} delay - 지연 시간 (ms)
 * @returns {*} 디바운스된 값
 */
export function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}
```

---

### shared/utils/ - 유틸리티

순수 함수 형태의 헬퍼 함수들입니다.

```javascript
// shared/utils/formatters.js

/**
 * 날짜를 형식화합니다.
 *
 * @param {Date} date - 날짜 객체
 * @param {string} format - 형식 (기본: 'YYYY-MM-DD')
 * @returns {string} 형식화된 날짜 문자열
 */
export function formatDate(date, format = 'YYYY-MM-DD') {
  // 날짜 포맷팅 로직
}

/**
 * 금액을 형식화합니다.
 *
 * @param {number} amount - 금액
 * @returns {string} 형식화된 금액 (예: "1,000,000원")
 */
export function formatCurrency(amount) {
  return `${amount.toLocaleString('ko-KR')}원`;
}
```

---

### pages/ - 페이지

라우팅 단위의 페이지 컴포넌트입니다.

**역할:**

- features의 컴포넌트들을 조합
- 페이지 레벨 데이터 로딩
- 레이아웃 적용

```javascript
// pages/DashboardPage/DashboardPage.jsx
import MainLayout from '@/shared/components/layout/MainLayout';
import DashboardCard from '@/features/dashboard/components/DashboardCard';
import { useDashboard } from '@/features/dashboard/hooks/useDashboard';

/**
 * 대시보드 페이지
 */
function DashboardPage() {
  const { data, isLoading } = useDashboard();

  if (isLoading) return <div>Loading...</div>;

  return (
    <MainLayout>
      <DashboardCard data={data} />
    </MainLayout>
  );
}

export default DashboardPage;
```

---

## 파일 네이밍 규칙

### 컴포넌트

**파일명:** PascalCase
```
Button.jsx
LoginForm.jsx
UserProfile.jsx
```

**폴더명:** PascalCase
```
Button/
LoginForm/
UserProfile/
```

---

### 훅

**파일명:** camelCase, use 접두사
```
useAuth.js
useDebounce.js
useUserData.js
```

---

### 유틸리티

**파일명:** camelCase
```
formatters.js
validators.js
constants.js
```

---

### 스토어

**파일명:** camelCase, Store 접미사
```
authStore.js
userStore.js
dashboardStore.js
```

---

### API

**파일명:** camelCase, Api 접미사
```
authApi.js
userApi.js
dashboardApi.js
```

---

### Storybook

**파일명:** {ComponentName}.stories.js
```
Button.stories.js
LoginForm.stories.js
```

---

## Import 경로 규칙

### 절대 경로 사용 (권장)

```javascript
import Button from '@/shared/components/ui/Button';
import { useAuth } from '@/features/auth/hooks/useAuth';
import { formatDate } from '@/shared/utils/formatters';
```

---

### vite.config.js 설정

```javascript
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

---

### Import 순서

```javascript
// 1. 외부 라이브러리
import { useState } from 'react';
import { Button, Form } from 'antd';

// 2. 절대 경로 (shared)
import { useDebounce } from '@/shared/hooks/useDebounce';
import { formatDate } from '@/shared/utils/formatters';

// 3. 절대 경로 (features)
import { useAuth } from '@/features/auth/hooks/useAuth';

// 4. 상대 경로
import './LoginForm.css';
```

---

## CSS 작성 규칙

### 언제 CSS를 작성하나요?

**작성하는 경우:**

- Ant Design에 없는 완전히 새로운 UI
- 브랜드 컬러/스타일 적용 (소셜 버튼)
- 복잡한 레이아웃
- Ant Design 기본 스타일을 크게 변경해야 하는 경우

**작성하지 않는 경우 (대부분):**

- Ant Design 기본 스타일로 충분한 경우
- inline style이나 className으로 해결 가능한 경우
- ConfigProvider로 전역 테마 설정 가능한 경우

---

### CSS 파일 위치

컴포넌트와 같은 폴더에 위치합니다.

```
Button/
├── Button.jsx
├── Button.stories.js
└── Button.css (필요시)
```

---

### 전역 스타일

```
shared/styles/
├── global.css           # 전역 CSS
├── variables.css        # CSS 변수
└── antd-theme.js        # Ant Design 테마
```

**antd-theme.js 예시:**
```javascript
export default {
  token: {
    colorPrimary: '#1890ff',
    borderRadius: 8,
    fontSize: 14,
  },
  components: {
    Button: {
      borderRadius: 8,
      fontWeight: 600,
    },
  },
};
```

---

## 운영 원칙

### 1. 기능별 분리

비즈니스 도메인별로 features/ 디렉토리에 격리합니다.

**올바른 예:**
```
features/
├── auth/
├── dashboard/
└── users/
```

**잘못된 예:**
```
features/
├── components/  ← 도메인별로 나누지 않음
├── hooks/
└── api/
```

---

### 2. 공유 컴포넌트

재사용 가능한 것만 shared/에 위치시킵니다.

**shared/에 위치:**

- 3개 이상의 feature에서 사용
- 범용적인 UI 컴포넌트
- 도메인 독립적

**features/에 위치:**

- 특정 도메인에만 사용
- 비즈니스 로직 포함
- 도메인 종속적

---

### 3. Ant Design 최대 활용

**기본 원칙:**

- Ant Design 컴포넌트를 직접 사용
- 필요시에만 shared/components/ui/에서 래핑
- CSS는 최소화

**래핑 기준:**

- 프로젝트 전체에서 동일한 스타일 적용
- props 인터페이스 단순화 필요
- 추가 기능 확장 필요

---

### 4. Storybook 필수

모든 공개 컴포넌트는 `.stories.js` 파일이 필수입니다.

```
Button/
├── Button.jsx
├── Button.stories.js  ← 필수
└── Button.css
```

---

### 5. 비즈니스 로직 분리

컴포넌트에서 비즈니스 로직을 분리합니다.

**올바른 예:**
```javascript
// LoginForm.jsx
function LoginForm() {
  const { login } = useAuth();  // 로직은 훅에
  return <Form onFinish={login} />;
}

// hooks/useAuth.js
export function useAuth() {
  const login = async (credentials) => {
    // 비즈니스 로직
  };
  return { login };
}
```

**잘못된 예:**
```javascript
// LoginForm.jsx
function LoginForm() {
  const login = async (credentials) => {
    // 컴포넌트에 비즈니스 로직 ✗
    const response = await fetch('/api/login', ...);
  };
  return <Form onFinish={login} />;
}
```

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.10 | 왕택준 | 최초 작성 |
