# Storybook 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.10

**문서 버전 (Version)**: v0.2

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: React 컴포넌트의 Story 파일을 작성하고 Storybook을 활용하는 담당자
* **디자이너**: UI 컴포넌트를 Storybook에서 확인하고 피드백하는 담당자
* **신규 합류자**: Storybook 설정, Story 작성법, 실행 방법을 처음 학습하는 신규 멤버

---

## 핵심 요약 (Executive Summary)

본 문서는 Storybook을 활용한 컴포넌트 문서화 방법을 정의합니다.
Storybook은 컴포넌트를 독립적으로 개발하고 시각적으로 테스트할 수 있는 도구입니다.
모든 공개 컴포넌트에는 Story 파일이 필수이며, `tags: ['autodocs']`를 설정하여 자동 문서화를 활성화합니다.
Story 파일은 컴포넌트와 동일한 디렉토리에 `.stories.js` 확장자로 작성합니다.
프로젝트는 vanilla React 기반으로 구성되며, components/와 pages/ 디렉토리의 컴포넌트에 Story를 작성합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Storybook 소개](#storybook-소개)
3. [프로젝트 설정](#프로젝트-설정)
4. [Story 파일 작성](#story-파일-작성)
5. [Args와 Controls](#args와-controls)
6. [자동 문서화 (Autodocs)](#자동-문서화-autodocs)
7. [프로젝트 컴포넌트 Story 작성](#프로젝트-컴포넌트-story-작성)
8. [Storybook 실행](#storybook-실행)
9. [배포](#배포)
10. [작성 원칙](#작성-원칙)

---

## 문서 개요 (Overview)

본 문서는 trAIn-frontend 프로젝트에서 Storybook을 활용한 컴포넌트 문서화 방법을 표준화하기 위해 작성되었습니다.

컴포넌트 개발 시 전체 애플리케이션을 실행하지 않고 독립적으로 개발하고 테스트할 필요가 있습니다.
또한 디자이너와 다른 개발자가 컴포넌트의 props와 동작 방식을 쉽게 이해할 수 있는 시각적 문서가 필요합니다.

Storybook은 이러한 문제를 해결하며, JSDoc과 결합하여 완전한 컴포넌트 명세서를 자동 생성합니다.
프로젝트는 vanilla React와 SCSS를 사용하며, components/와 pages/ 디렉토리 구조를 따릅니다.

---

## Storybook 소개

### Storybook이란?

Storybook은 UI 컴포넌트를 독립적으로 개발하고 문서화할 수 있는 오픈소스 도구입니다.

**주요 기능:**
- 컴포넌트 독립 개발 환경
- Props 변경에 따른 실시간 미리보기
- 자동 문서 생성 (Autodocs)
- 다양한 상태(state) 시각화
- 접근성(a11y) 테스트

---

### Storybook 활용 시나리오

**개발자:**
- 애플리케이션 전체를 실행하지 않고 컴포넌트 개발
- 다양한 props 조합 테스트
- 엣지 케이스 확인

**디자이너:**
- 구현된 컴포넌트 시각적 확인
- 디자인 시스템 일관성 검증
- 인터랙션 동작 확인

**팀 전체:**
- 컴포넌트 명세서로 활용
- 재사용 가능한 컴포넌트 검색
- 온보딩 자료로 활용

---

## 프로젝트 설정

### 설치

Storybook이 이미 설치되어 있지 않다면 다음 명령어로 설치합니다.

```bash
npx storybook@latest init
```

---

### 프로젝트 구조

trAIn-frontend 프로젝트의 Storybook 구조입니다.

```
src/
├── components/
│   ├── Auth/                           # 인증 관련 컴포넌트
│   │   ├── SocialButton.jsx
│   │   ├── SocialButton.module.scss
│   │   └── SocialButton.stories.js      ← Story 파일
│   │
│   ├── Header/                         # 헤더 컴포넌트
│   │   ├── AppHeader.jsx
│   │   ├── AppHeader.module.scss
│   │   └── AppHeader.stories.js
│   │
│   ├── Dialogue/                       # 대화 관련 컴포넌트
│   │   └── (향후 추가될 컴포넌트들)
│   │
│   ├── History/                        # 히스토리 관련 컴포넌트
│   │   └── (향후 추가될 컴포넌트들)
│   │
│   ├── Profile/                        # 프로필 관련 컴포넌트
│   │   └── (향후 추가될 컴포넌트들)
│   │
│   ├── Scenario/                       # 시나리오 관련 컴포넌트
│   │   └── (향후 추가될 컴포넌트들)
│   │
│   └── Welcome/                        # 웰컴 관련 컴포넌트
│       └── (향후 추가될 컴포넌트들)
│
├── pages/
│   ├── Auth/                           # 인증 페이지
│   │   ├── EmailVerificationPage.jsx
│   │   ├── EmailVerificationPage.module.scss
│   │   ├── EmailVerificationPage.stories.js  ← Story 파일
│   │   ├── SignupPage.jsx
│   │   ├── SignupPage.module.scss
│   │   └── SignupPage.stories.js
│   │
│   ├── Welcome/                        # 웰컴 페이지
│   │   ├── WelcomePage.jsx
│   │   ├── WelcomePage.module.scss
│   │   └── WelcomePage.stories.js
│   │
│   └── (다른 페이지들...)
│
└── layouts/
    ├── AppLayout.jsx
    └── AppLayout.stories.js             ← 레이아웃 Story
```

**규칙:**
- Story 파일은 컴포넌트와 같은 디렉토리에 위치
- 파일명은 `{ComponentName}.stories.js` 형식
- components/와 pages/ 컴포넌트 모두 Story 작성 필수

---

### Storybook 설정 파일

`.storybook/main.js`

```javascript
export default {
  stories: [
    '../src/components/**/*.stories.@(js|jsx)',
    '../src/pages/**/*.stories.@(js|jsx)',
    '../src/layouts/**/*.stories.@(js|jsx)',
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/addon-docs',
    '@storybook/addon-controls',
    '@storybook/addon-viewport',
  ],
  framework: {
    name: '@storybook/react-vite',
    options: {},
  },
  docs: {
    autodocs: 'tag',
  },
};
```

---

### SCSS 지원 설정

`.storybook/preview.js`

```javascript
import '../src/index.css';
// 글로벌 SCSS 스타일 import
import '../src/styles/global.scss'; // 만약 있다면

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
  layout: 'centered', // 기본 레이아웃
};
```

---

## Story 파일 작성

### 기본 구조

Story 파일은 컴포넌트의 다양한 상태를 정의합니다.

```javascript
import { SocialButton } from './SocialButton';

/**
 * SocialButton 컴포넌트는 소셜 로그인을 위한 버튼입니다.
 */
export default {
  title: 'Components/Auth/SocialButton',
  component: SocialButton,
  tags: ['autodocs'],
  argTypes: {
    provider: {
      control: 'select',
      options: ['google', 'kakao', 'naver'],
      description: '소셜 로그인 제공자',
    },
    disabled: {
      control: 'boolean',
      description: '버튼 비활성화 여부',
    },
    onClick: {
      action: 'clicked',
      description: '클릭 이벤트 핸들러',
    },
  },
};

/**
 * 기본 Google 소셜 버튼
 */
export const Google = {
  args: {
    provider: 'google',
    onClick: () => alert('Google 로그인'),
  },
};

/**
 * Kakao 소셜 버튼
 */
export const Kakao = {
  args: {
    provider: 'kakao',
    onClick: () => alert('Kakao 로그인'),
  },
};

/**
 * Naver 소셜 버튼
 */
export const Naver = {
  args: {
    provider: 'naver',
    onClick: () => alert('Naver 로그인'),
  },
};

/**
 * 비활성화된 상태
 */
export const Disabled = {
  args: {
    provider: 'google',
    disabled: true,
  },
};
```

---

### Story 제목 규칙

**components/ 디렉토리 컴포넌트:**
```javascript
export default {
  title: 'Components/Auth/SocialButton',    // components/Auth/
  title: 'Components/Header/AppHeader',     // components/Header/
  title: 'Components/Dialogue/ChatBox',    // components/Dialogue/
};
```

**pages/ 디렉토리 컴포넌트:**
```javascript
export default {
  title: 'Pages/Auth/SignupPage',           // pages/Auth/
  title: 'Pages/Welcome/WelcomePage',       // pages/Welcome/
};
```

**layouts/ 디렉토리 컴포넌트:**
```javascript
export default {
  title: 'Layouts/AppLayout',              // layouts/
};
```

---

### Default Export (메타데이터)

```javascript
export default {
  title: 'Components/Auth/SocialButton',    // Storybook 사이드바 경로
  component: SocialButton,                  // 대상 컴포넌트
  tags: ['autodocs'],                       // 자동 문서화 활성화
  parameters: {
    layout: 'centered',                     // 스토리 레이아웃
  },
  argTypes: {
    // Props 컨트롤 설정
  },
};
```

---

### Named Export (개별 Story)

각 Story는 컴포넌트의 특정 상태를 나타냅니다.

```javascript
export const Primary = {
  args: {
    provider: 'google',
    onClick: () => alert('클릭됨'),
  },
};
```

**Story 네이밍 규칙:**
- PascalCase 사용
- 상태를 명확히 표현 (Primary, Disabled, Loading 등)
- 한글 설명은 JSDoc 주석으로 추가

---

## Args와 Controls

### Args란?

Args는 컴포넌트에 전달되는 props입니다.
Storybook UI에서 Args를 동적으로 변경하여 컴포넌트의 동작을 확인할 수 있습니다.

---

### ArgTypes 설정

ArgTypes는 각 prop의 컨트롤 타입과 설명을 정의합니다.

```javascript
export default {
  component: EmailVerificationPage,
  tags: ['autodocs'],
  argTypes: {
    email: {
      control: 'text',
      description: '인증할 이메일 주소',
    },
    isLoading: {
      control: 'boolean',
      description: '로딩 상태 여부',
    },
    error: {
      control: 'text',
      description: '에러 메시지',
    },
    onVerify: {
      action: 'verified',
      description: '인증 완료 핸들러',
    },
    onResend: {
      action: 'resent',
      description: '재전송 핸들러',
    },
  },
};
```

---

### Control 타입

| Control 타입 | 용도 | 예시 |
|--------------|------|------|
| `boolean` | true/false 토글 | disabled, isLoading |
| `text` | 문자열 입력 | email, message |
| `number` | 숫자 입력 | countdown, maxLength |
| `range` | 슬라이더 | progress, volume |
| `select` | 드롭다운 선택 | provider, size |
| `radio` | 라디오 버튼 | align, position |
| `color` | 색상 선택 | backgroundColor |
| `date` | 날짜 선택 | startDate |
| `object` | JSON 편집 | style, config |

---

## 자동 문서화 (Autodocs)

### Autodocs란?

Autodocs는 JSDoc 주석과 Story 정보를 기반으로 컴포넌트 문서를 자동 생성합니다.

**활성화 방법:**
```javascript
export default {
  component: SocialButton,
  tags: ['autodocs'],  // 이 태그 추가
};
```

---

### Autodocs 구성 요소

Autodocs 페이지는 다음 섹션으로 구성됩니다.

1. **컴포넌트 설명**: JSDoc의 컴포넌트 설명
2. **Props Table**: 모든 props의 타입, 기본값, 설명
3. **Stories**: 정의된 모든 Story의 미리보기
4. **Controls**: 실시간 props 조작 패널

---

### JSDoc과 Autodocs 연동

JSDoc 주석이 Autodocs에 자동으로 반영됩니다.

```javascript
/**
 * @typedef {Object} SocialButtonProps
 * @property {'google'|'kakao'|'naver'} provider - 소셜 로그인 제공자
 * @property {boolean} [disabled=false] - 버튼 비활성화 여부
 * @property {Function} onClick - 클릭 이벤트 핸들러
 */

/**
 * 소셜 로그인을 위한 재사용 가능한 버튼 컴포넌트입니다.
 *
 * @param {SocialButtonProps} props - 소셜 버튼 props
 * @returns {JSX.Element}
 */
function SocialButton({ provider, disabled = false, onClick }) {
  // ...
}
```

이 JSDoc 주석은 Autodocs의 Props Table에 자동으로 나타납니다.

---

## 프로젝트 컴포넌트 Story 작성

### 1. 인증 컴포넌트 (SocialButton)

```javascript
// src/components/Auth/SocialButton.stories.js
import { SocialButton } from './SocialButton';

/**
 * 소셜 로그인을 위한 버튼 컴포넌트
 * Google, Kakao, Naver 로그인을 지원합니다.
 */
export default {
  title: 'Components/Auth/SocialButton',
  component: SocialButton,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
  argTypes: {
    provider: {
      control: 'select',
      options: ['google', 'kakao', 'naver'],
      description: '소셜 로그인 제공자',
    },
    disabled: {
      control: 'boolean',
      description: '버튼 비활성화 여부',
    },
    onClick: {
      action: 'clicked',
      description: '클릭 이벤트 핸들러',
    },
  },
};

export const Google = {
  args: {
    provider: 'google',
  },
};

export const Kakao = {
  args: {
    provider: 'kakao',
  },
};

export const Naver = {
  args: {
    provider: 'naver',
  },
};

export const Disabled = {
  args: {
    provider: 'google',
    disabled: true,
  },
};
```

---

### 2. 헤더 컴포넌트 (AppHeader)

```javascript
// src/components/Header/AppHeader.stories.js
import { AppHeader } from './AppHeader';

/**
 * 애플리케이션 상단 헤더
 */
export default {
  title: 'Components/Header/AppHeader',
  component: AppHeader,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
  argTypes: {
    user: {
      control: 'object',
      description: '로그인된 사용자 정보',
    },
    onLogout: {
      action: 'logout',
      description: '로그아웃 핸들러',
    },
  },
};

/**
 * 로그인하지 않은 상태
 */
export const LoggedOut = {};

/**
 * 로그인된 상태
 */
export const LoggedIn = {
  args: {
    user: {
      name: '홍길동',
      email: 'hong@example.com',
    },
  },
};
```

---

### 3. 페이지 컴포넌트 (SignupPage)

```javascript
// src/pages/Auth/SignupPage.stories.js
import { SignupPage } from './SignupPage';

/**
 * 회원가입 페이지
 */
export default {
  title: 'Pages/Auth/SignupPage',
  component: SignupPage,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
  argTypes: {
    currentStep: {
      control: 'number',
      description: '현재 단계 (1: 약관동의, 2: 정보입력)',
    },
    isLoading: {
      control: 'boolean',
      description: '로딩 상태',
    },
    error: {
      control: 'text',
      description: '에러 메시지',
    },
  },
};

/**
 * 약관 동의 단계
 */
export const Step1_Terms = {
  args: {
    currentStep: 1,
  },
};

/**
 * 사용자 정보 입력 단계
 */
export const Step2_UserInfo = {
  args: {
    currentStep: 2,
  },
};

/**
 * 로딩 상태
 */
export const Loading = {
  args: {
    currentStep: 2,
    isLoading: true,
  },
};

/**
 * 에러 상태
 */
export const WithError = {
  args: {
    currentStep: 2,
    error: '이미 사용 중인 이메일입니다.',
  },
};
```

---

### 4. 레이아웃 컴포넌트 (AppLayout)

```javascript
// src/layouts/AppLayout.stories.js
import { AppLayout } from './AppLayout';

/**
 * 애플리케이션 전체 레이아웃
 */
export default {
  title: 'Layouts/AppLayout',
  component: AppLayout,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
  argTypes: {
    children: {
      control: 'text',
      description: '레이아웃 내부 콘텐츠',
    },
  },
};

/**
 * 기본 레이아웃
 */
export const Default = {
  args: {
    children: '<div>페이지 콘텐츠가 여기에 들어갑니다</div>',
  },
};
```

---

## Storybook 실행

### 개발 모드 실행

```bash
npm run storybook
```

기본적으로 `http://localhost:6006`에서 실행됩니다.

---

### 빌드

정적 파일로 빌드하여 배포할 수 있습니다.

```bash
npm run build-storybook
```

빌드 결과는 `storybook-static/` 디렉토리에 생성됩니다.

---

## 배포

### GitHub Pages 배포

1. Storybook 빌드
```bash
npm run build-storybook
```

2. `storybook-static/` 디렉토리를 GitHub Pages에 배포

3. `.github/workflows/storybook.yml` 생성
```yaml
name: Deploy Storybook

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run build-storybook
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./storybook-static
```

---

### Netlify / Vercel 배포

**Netlify:**
- Build command: `npm run build-storybook`
- Publish directory: `storybook-static`

**Vercel:**
- Build command: `npm run build-storybook`
- Output directory: `storybook-static`

---

## 작성 원칙

### Story 작성 대상

**필수 작성:**
- components/ 디렉토리의 모든 재사용 가능한 컴포넌트
- layouts/ 디렉토리의 모든 레이아웃 컴포넌트

**선택 작성:**
- pages/ 컴포넌트 (복잡한 상태를 가진 페이지만)
- 매우 간단한 내부 컴포넌트

**작성하지 않음:**
- services/ 디렉토리 (API 서비스)
- stores/ 디렉토리 (상태 관리)
- hooks/ 디렉토리 (커스텀 훅)
- routes/ 디렉토리 (라우팅 설정)

---

### Story 작성 규칙

**필수 Story:**
- Default (기본 상태)
- 주요 variant별 Story
- Disabled, Loading 등 특수 상태

**Story 설명:**
- 각 Story 위에 JSDoc 주석으로 설명 추가
- 언제 이 상태를 사용하는지 명시

**Args 설정:**
- 실제 사용 케이스를 반영한 현실적인 값 사용
- 모든 필수 props 포함

---

### 네이밍 규칙

**파일명:**
```
SocialButton.jsx
SocialButton.module.scss
SocialButton.stories.js
```

**Story 제목:**
```javascript
export default {
  title: 'Components/Auth/SocialButton',   // components/Auth/
  title: 'Components/Header/AppHeader',    // components/Header/
  title: 'Pages/Auth/SignupPage',          // pages/Auth/
  title: 'Layouts/AppLayout',              // layouts/
};
```

**Story 이름:**
```javascript
export const Primary = { ... };
export const Disabled = { ... };
export const Loading = { ... };
```

---

### 필수 설정

모든 Story 파일에 다음 항목이 필수입니다.

```javascript
export default {
  title: 'Category/ComponentName',  // ✓ 필수
  component: Component,              // ✓ 필수
  tags: ['autodocs'],                // ✓ 필수 (자동 문서화)
  argTypes: {
    // props 컨트롤 정의
  },
};
```

---

### 좋은 예시

```javascript
/**
 * SocialButton 컴포넌트는 소셜 로그인을 위한 버튼입니다.
 */
export default {
  title: 'Components/Auth/SocialButton',
  component: SocialButton,
  tags: ['autodocs'],
  argTypes: {
    provider: {
      control: 'select',
      options: ['google', 'kakao', 'naver'],
      description: '소셜 로그인 제공자',
    },
    disabled: {
      control: 'boolean',
      description: '버튼 비활성화 여부',
    },
  },
};

/**
 * 기본 Google 버튼 - 구글 로그인에 사용
 */
export const Google = {
  args: {
    provider: 'google',
    onClick: () => alert('Google 로그인'),
  },
};

/**
 * 비활성화된 상태 - 로그인이 불가능할 때 사용
 */
export const Disabled = {
  args: {
    provider: 'google',
    disabled: true,
  },
};
```

---

변경 이력 (Change Log)

| 버전   | 변경 일자      | 작성자 | 주요 변경 내용 |
|------|------------|--------|----------------|
| v0.2 | 2025.10.27 | 왕택준 | trAIn-frontend 프로젝트 구조에 맞게 리팩토링 |
| v0.1 | 2025.10.10 | 왕택준 | 최초 작성 |