# Storybook 가이드

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.10.10

**문서 버전 (Version)**: v0.1

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
프로젝트는 Ant Design 기반으로 구성되며, shared/components/ui/와 features/의 컴포넌트에 Story를 작성합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [Storybook 소개](#storybook-소개)
3. [프로젝트 설정](#프로젝트-설정)
4. [Story 파일 작성](#story-파일-작성)
5. [Args와 Controls](#args와-controls)
6. [자동 문서화 (Autodocs)](#자동-문서화-autodocs)
7. [Ant Design 컴포넌트 Story 작성](#ant-design-컴포넌트-story-작성)
8. [Storybook 실행](#storybook-실행)
9. [배포](#배포)
10. [작성 원칙](#작성-원칙)

---

## 문서 개요 (Overview)

본 문서는 프로젝트에서 Storybook을 활용한 컴포넌트 문서화 방법을 표준화하기 위해 작성되었습니다.

컴포넌트 개발 시 전체 애플리케이션을 실행하지 않고 독립적으로 개발하고 테스트할 필요가 있습니다.
또한 디자이너와 다른 개발자가 컴포넌트의 props와 동작 방식을 쉽게 이해할 수 있는 시각적 문서가 필요합니다.

Storybook은 이러한 문제를 해결하며, JSDoc과 결합하여 완전한 컴포넌트 명세서를 자동 생성합니다.
프로젝트는 Ant Design UI 라이브러리를 기반으로 하며, shared/components/와 features/ 디렉토리 구조를 따릅니다.

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

Ant Design 기반 프로젝트의 Storybook 구조입니다.

```
src/
├── shared/
│   └── components/
│       ├── ui/                         # Ant Design 래핑 컴포넌트
│       │   ├── Button/
│       │   │   ├── Button.jsx
│       │   │   ├── Button.stories.js   ← Story 파일
│       │   │   └── Button.css
│       │   ├── Input/
│       │   │   ├── Input.jsx
│       │   │   └── Input.stories.js
│       │   └── SocialButton/
│       │       ├── GoogleButton.jsx
│       │       ├── GoogleButton.stories.js
│       │       ├── KakaoButton.jsx
│       │       ├── KakaoButton.stories.js
│       │       └── SocialButton.css
│       │
│       └── layout/                     # 레이아웃 컴포넌트
│           ├── Header/
│           │   ├── Header.jsx
│           │   └── Header.stories.js
│           └── Sidebar/
│               ├── Sidebar.jsx
│               └── Sidebar.stories.js
│
└── features/
    └── auth/
        └── components/
            ├── LoginForm/
            │   ├── LoginForm.jsx
            │   └── LoginForm.stories.js    ← Story 파일
            └── SignupForm/
                ├── SignupForm.jsx
                └── SignupForm.stories.js
```

**규칙:**
- Story 파일은 컴포넌트와 같은 디렉토리에 위치
- 파일명은 `{ComponentName}.stories.js` 형식
- shared/components/와 features/ 컴포넌트 모두 Story 작성 필수

---

### Storybook 설정 파일

`.storybook/main.js`

```javascript
export default {
  stories: [
    '../src/shared/components/**/*.stories.@(js|jsx)',
    '../src/features/**/components/**/*.stories.@(js|jsx)',
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
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

### Ant Design 통합

`.storybook/preview.js`

```javascript
import { ConfigProvider } from 'antd';
import koKR from 'antd/locale/ko_KR';
import theme from '../src/shared/styles/antd-theme';
import 'antd/dist/reset.css';
import '../src/shared/styles/global.css';

export const decorators = [
  (Story) => (
    <ConfigProvider locale={koKR} theme={theme}>
      <Story />
    </ConfigProvider>
  ),
];

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
};
```

---

## Story 파일 작성

### 기본 구조

Story 파일은 컴포넌트의 다양한 상태를 정의합니다.

```javascript
import Button from './Button';

/**
 * Button 컴포넌트는 사용자 액션을 트리거하는 데 사용됩니다.
 */
export default {
  title: 'Shared/UI/Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger'],
      description: '버튼의 시각적 스타일',
    },
    disabled: {
      control: 'boolean',
      description: '버튼 비활성화 여부',
    },
  },
};

/**
 * 기본 Primary 버튼
 */
export const Primary = {
  args: {
    label: '저장',
    variant: 'primary',
    onClick: () => alert('클릭됨'),
  },
};

/**
 * Secondary 스타일 버튼
 */
export const Secondary = {
  args: {
    label: '취소',
    variant: 'secondary',
    onClick: () => alert('클릭됨'),
  },
};

/**
 * 위험한 동작을 나타내는 Danger 버튼
 */
export const Danger = {
  args: {
    label: '삭제',
    variant: 'danger',
    onClick: () => alert('삭제됨'),
  },
};

/**
 * 비활성화된 버튼
 */
export const Disabled = {
  args: {
    label: '저장',
    variant: 'primary',
    disabled: true,
  },
};
```

---

### Story 제목 규칙

**shared/components/ui/ 컴포넌트:**
```javascript
export default {
  title: 'Shared/UI/ComponentName',
};
```

**shared/components/layout/ 컴포넌트:**
```javascript
export default {
  title: 'Shared/Layout/ComponentName',
};
```

**features/ 컴포넌트:**
```javascript
export default {
  title: 'Features/Auth/ComponentName',
};
```

---

### Default Export (메타데이터)

```javascript
export default {
  title: 'Shared/UI/Button',        // Storybook 사이드바 경로
  component: Button,                 // 대상 컴포넌트
  tags: ['autodocs'],                // 자동 문서화 활성화
  parameters: {
    layout: 'centered',              // 스토리 레이아웃
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
    label: '저장',
    variant: 'primary',
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
  component: Input,
  tags: ['autodocs'],
  argTypes: {
    type: {
      control: 'select',
      options: ['text', 'email', 'password', 'number'],
      description: 'Input 타입',
    },
    placeholder: {
      control: 'text',
      description: '플레이스홀더 텍스트',
    },
    disabled: {
      control: 'boolean',
      description: '비활성화 여부',
    },
    maxLength: {
      control: 'number',
      description: '최대 입력 길이',
    },
    onChange: {
      action: 'changed',
      description: '값 변경 핸들러',
    },
  },
};
```

---

### Control 타입

| Control 타입 | 용도 | 예시 |
|--------------|------|------|
| `boolean` | true/false 토글 | disabled, required |
| `text` | 문자열 입력 | label, placeholder |
| `number` | 숫자 입력 | maxLength, size |
| `range` | 슬라이더 | opacity, volume |
| `select` | 드롭다운 선택 | variant, size |
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
  component: Button,
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
 * @typedef {Object} ButtonProps
 * @property {string} label - 버튼에 표시될 텍스트
 * @property {'primary'|'secondary'|'danger'} variant - 버튼 스타일
 * @property {boolean} [disabled=false] - 버튼 비활성화 여부
 * @property {Function} onClick - 클릭 이벤트 핸들러
 */

/**
 * 재사용 가능한 버튼 컴포넌트입니다.
 *
 * @param {ButtonProps} props - 버튼 props
 * @returns {JSX.Element}
 */
function Button({ label, variant = 'primary', disabled = false, onClick }) {
  // ...
}
```

이 JSDoc 주석은 Autodocs의 Props Table에 자동으로 나타납니다.

---

## Ant Design 컴포넌트 Story 작성

### 1. Ant Design 래핑 컴포넌트

```javascript
// shared/components/ui/Button/Button.stories.js
import Button from './Button';

/**
 * 프로젝트 표준 버튼 컴포넌트
 * Ant Design Button을 래핑하여 일관된 스타일을 적용합니다.
 */
export default {
  title: 'Shared/UI/Button',
  component: Button,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger'],
      description: '버튼 스타일',
    },
    children: {
      control: 'text',
      description: '버튼 텍스트',
    },
    disabled: {
      control: 'boolean',
      description: '비활성화 여부',
    },
    onClick: {
      action: 'clicked',
      description: '클릭 핸들러',
    },
  },
};

export const Primary = {
  args: {
    variant: 'primary',
    children: '저장',
  },
};

export const Secondary = {
  args: {
    variant: 'secondary',
    children: '취소',
  },
};

export const Danger = {
  args: {
    variant: 'danger',
    children: '삭제',
  },
};

export const Disabled = {
  args: {
    variant: 'primary',
    children: '저장',
    disabled: true,
  },
};
```

---

### 2. 소셜 로그인 버튼

```javascript
// shared/components/ui/SocialButton/GoogleButton.stories.js
import GoogleButton from './GoogleButton';

/**
 * 구글 소셜 로그인 버튼
 */
export default {
  title: 'Shared/UI/SocialButton/Google',
  component: GoogleButton,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
};

/**
 * 기본 구글 버튼
 */
export const Default = {
  args: {
    onClick: () => alert('구글 로그인'),
  },
};

/**
 * 커스텀 텍스트
 */
export const CustomText = {
  args: {
    children: 'Sign in with Google',
    onClick: () => alert('구글 로그인'),
  },
};
```

---

### 3. 레이아웃 컴포넌트

```javascript
// shared/components/layout/Header/Header.stories.js
import Header from './Header';

/**
 * 애플리케이션 헤더
 */
export default {
  title: 'Shared/Layout/Header',
  component: Header,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
};

/**
 * 기본 헤더
 */
export const Default = {};

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

### 4. Features 컴포넌트

```javascript
// features/auth/components/LoginForm/LoginForm.stories.js
import LoginForm from './LoginForm';

/**
 * 로그인 폼
 */
export default {
  title: 'Features/Auth/LoginForm',
  component: LoginForm,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
};

/**
 * 기본 로그인 폼
 */
export const Default = {
  args: {
    onSubmit: (values) => {
      console.log('로그인:', values);
      alert('로그인 시도');
    },
  },
};

/**
 * 로딩 상태
 */
export const Loading = {
  args: {
    isLoading: true,
    onSubmit: (values) => console.log(values),
  },
};

/**
 * 에러 상태
 */
export const WithError = {
  args: {
    error: '이메일 또는 비밀번호가 올바르지 않습니다.',
    onSubmit: (values) => console.log(values),
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
- shared/components/ui/ 의 모든 컴포넌트
- shared/components/layout/ 의 모든 컴포넌트
- features/ 내 재사용 가능한 컴포넌트

**선택 작성:**
- pages/ 컴포넌트 (일반적으로 불필요)
- 매우 간단한 내부 컴포넌트

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
Button.jsx
Button.stories.js
```

**Story 제목:**
```javascript
export default {
  title: 'Shared/UI/Button',        // shared/components/ui/
  title: 'Shared/Layout/Header',    // shared/components/layout/
  title: 'Features/Auth/LoginForm', // features/
};
```

**Story 이름:**
```javascript
export const Primary = { ... };
export const Disabled = { ... };
export const Large = { ... };
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

### 나쁜 예시

```javascript
// Story 설명 없음
// autodocs 태그 없음
// argTypes 정의 없음
// title 경로 불명확
export default {
  component: Button,
};

export const Story1 = {
  args: {
    label: 'test',
  },
};
```

**문제점:**
- autodocs가 활성화되지 않음
- Story의 목적이 불명확
- Props 컨트롤이 자동 추론됨 (부정확할 수 있음)
- Storybook 사이드바에서 찾기 어려움

---

### 좋은 예시

```javascript
/**
 * Button 컴포넌트는 사용자 액션을 트리거하는 데 사용됩니다.
 * Ant Design Button을 래핑하여 프로젝트 표준 스타일을 적용합니다.
 */
export default {
  title: 'Shared/UI/Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger'],
      description: '버튼의 시각적 스타일',
    },
    disabled: {
      control: 'boolean',
      description: '버튼 비활성화 여부',
    },
  },
};

/**
 * 기본 Primary 버튼 - 주요 액션에 사용
 */
export const Primary = {
  args: {
    children: '저장',
    variant: 'primary',
    onClick: () => alert('저장되었습니다'),
  },
};

/**
 * 비활성화된 상태 - 액션을 수행할 수 없을 때 사용
 */
export const Disabled = {
  args: {
    children: '저장',
    variant: 'primary',
    disabled: true,
  },
};
```

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v0.1 | 2025.10.10 | 왕택준 | 최초 작성 |
