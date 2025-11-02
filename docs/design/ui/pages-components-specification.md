# 페이지 및 컴포넌트 명세서

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.02

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: 페이지 및 컴포넌트 구현 및 유지보수를 담당하는 개발자
* **UI/UX 디자이너**: 컴포넌트 구조와 인터페이스를 이해하고 디자인하는 디자이너
* **프로덕트 매니저**: 기능 요구사항과 컴포넌트 구조를 파악하는 담당자
* **QA 엔지니어**: 테스트 케이스 작성을 위해 컴포넌트 동작을 이해해야 하는 담당자
* **신규 팀원**: Dialogym 프론트엔드 구조를 빠르게 학습해야 하는 신규 합류자

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym 프론트엔드의 모든 페이지와 컴포넌트 구조를 정의합니다.
React 19, React Router v7, Zustand를 기반으로 구현되었으며, SCSS Modules로 스타일링합니다.
페이지는 Welcome, User, Auth, Scenario, Dialogue, Feedback 등 6개 주요 영역으로 구성됩니다.
컴포넌트는 도메인별로 분리되어 재사용성과 유지보수성을 확보하며, 커스텀 훅으로 로직을 캡슐화합니다.
상태 관리는 Zustand Store로 중앙 집중화하고, React Hook Form과 Yup으로 폼을 관리합니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [애플리케이션 구조](#애플리케이션-구조)
3. [라우팅 구조](#라우팅-구조)
4. [레이아웃](#레이아웃)
5. [페이지 명세](#페이지-명세)
6. [컴포넌트 명세](#컴포넌트-명세)
7. [Hooks](#hooks)
8. [서비스](#서비스)
9. [상태 관리](#상태-관리)
10. [유틸리티](#유틸리티)
11. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 Dialogym 프론트엔드의 모든 페이지와 컴포넌트 구조, 역할, Props, 상태 관리를 상세히 기록한 기술 명세서입니다.

프론트엔드 개발에서 명확한 컴포넌트 명세는 코드 재사용성, 유지보수성, 협업 효율성을 높이는 핵심 요소입니다.
이 문서를 통해 개발자는 각 컴포넌트의 책임과 인터페이스를 명확히 이해하고, 일관된 패턴으로 개발할 수 있습니다.

본 문서는 Dialogym 프론트엔드의 모든 개발, 리팩토링, 코드 리뷰 활동에 적용되며, 컴포넌트 추가 또는 변경 시 반드시 업데이트해야 합니다.

---

## 애플리케이션 구조

### 디렉토리 구조

```
src/
├── assets/                 # 정적 리소스 (이미지, 폰트 등)
├── components/             # 재사용 가능한 컴포넌트
│   ├── Auth/              # 인증 관련 컴포넌트
│   ├── common/            # 공통 컴포넌트
│   ├── Dialogue/          # 대화 관련 컴포넌트
│   ├── Feedback/          # 피드백 관련 컴포넌트
│   ├── Header/            # 헤더 컴포넌트
│   ├── Scenario/          # 시나리오 관련 컴포넌트
│   ├── User/              # 사용자 관련 컴포넌트
│   └── Welcome/           # 웰컴 페이지 컴포넌트
├── hooks/                 # 커스텀 훅
├── layouts/               # 레이아웃 컴포넌트
├── loaders/               # 데이터 로더
├── pages/                 # 페이지 컴포넌트
│   ├── Auth/              # 인증 페이지
│   ├── Dialogue/          # 대화 페이지
│   ├── Feedback/          # 피드백 페이지
│   ├── Scenario/          # 시나리오 페이지
│   ├── User/              # 사용자 페이지
│   └── Welcome/           # 웰컴 페이지
├── routes/                # 라우팅 설정
├── services/              # API 서비스
├── stores/                # 상태 관리 (Zustand)
├── utils/                 # 유틸리티 함수
├── App.jsx                # 루트 컴포넌트
├── main.jsx               # 엔트리 포인트
└── index.css              # 글로벌 스타일
```

### 기술 스택

Core는 React 19, React Router v7, Vite를 사용합니다.
상태 관리는 Zustand와 Immer를 사용하고, 스타일링은 SCSS Modules와 CSS Variables를 사용합니다.
폼 관리는 React Hook Form과 Yup(검증)을 사용하며, HTTP 클라이언트는 Axios를 사용합니다.
UI는 React Hot Toast(알림), React Icons(아이콘)를 사용하고, 날짜 처리는 date-fns를 사용합니다.

### 컴포넌트 설계 원칙

단일 책임 원칙으로 하나의 컴포넌트는 하나의 책임만 가집니다.
컴포지션으로 작은 컴포넌트를 조합하여 복잡한 UI를 구성하고, Props 인터페이스로 명확하고 일관된 Props 정의를 사용합니다.
상태 끌어올리기로 필요한 최소 레벨에서 상태를 관리하며, 재사용성으로 도메인 로직과 UI를 분리합니다.

### 네이밍 컨벤션

컴포넌트는 PascalCase (LoginPage, UserProfile)를 사용하고, 파일명은 컴포넌트명과 동일 (LoginPage.jsx)하게 작성합니다.
Props는 camelCase (onClick, userName, isLoading)를 사용하고, 이벤트 핸들러는 handle 접두사 (handleClick, handleSubmit)를 사용합니다.
Boolean Props는 is/has 접두사 (isOpen, hasError, canEdit)를 사용하며, 스타일 파일은 컴포넌트명.module.scss를 사용합니다.

---

## 라우팅 구조

### 라우트 트리

```
/                           → WelcomePage (public)
/login                      → LoginPage (public)
/signup                     → SignupPage (public)
/email-verification         → EmailVerificationPage (public)
/callback                   → CallbackPage (public, OAuth)
/social-signup              → SocialSignupPage (public, OAuth)

/dashboard                  → DashboardPage (protected)
/profile                    → ProfilePage (protected)
/settings                   → SettingsPage (protected)

/scenarios                  → ScenarioListPage (protected)
/scenarios/:id              → ScenarioDetailPage (protected)

/dialogue/session/:id       → DialoguePage (protected)

/feedback                   → FeedbackListPage (protected)
/feedback/:id               → FeedbackDetailPage (protected)

/history                    → HistoryPage (protected)
/history/:sessionId         → SessionDetailPage (protected)
```

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
          { path: 'scenarios', element: <ScenarioListPage /> },
          { path: 'scenarios/:id', element: <ScenarioDetailPage /> },
          { path: 'dialogue/session/:id', element: <DialoguePage /> },
          { path: 'feedback', element: <FeedbackListPage /> },
          { path: 'feedback/:id', element: <FeedbackDetailPage /> },
          { path: 'history', element: <HistoryPage /> },
          { path: 'history/:sessionId', element: <SessionDetailPage /> },
        ]
      }
    ]
  }
]);
```

---

## 레이아웃

### RootLayout

전체 애플리케이션의 루트 레이아웃으로 Header와 Outlet을 포함합니다.

```javascript
export function RootLayout() {
  return (
    <div className="root-layout">
      <Header />
      <main className="main-content">
        <Outlet />
      </main>
      <Toaster position="top-right" />
    </div>
  );
}
```

### Header

사용자 인증 상태에 따라 네비게이션을 표시합니다.

```javascript
export function Header() {
  const { status, user, logout } = useAuthStore();
  const navigate = useNavigate();

  if (status === 'unauthenticated') {
    return (
      <header className="header">
        <div className="header-left">
          <Link to="/">Dialogym</Link>
        </div>
        <nav className="header-right">
          <Link to="/login">로그인</Link>
          <Link to="/signup">회원가입</Link>
        </nav>
      </header>
    );
  }

  return (
    <header className="header">
      <div className="header-left">
        <Link to="/dashboard">Dialogym</Link>
      </div>
      <nav className="header-nav">
        <Link to="/scenarios">시나리오</Link>
        <Link to="/history">히스토리</Link>
        <Link to="/feedback">피드백</Link>
      </nav>
      <div className="header-right">
        <Link to="/profile">{user?.name}</Link>
        <button onClick={logout}>로그아웃</button>
      </div>
    </header>
  );
}
```

### Props

Props는 없으며, authStore에서 상태를 직접 구독합니다.

---

## 페이지 명세

### WelcomePage

방문자에게 서비스를 소개하고 회원가입 또는 로그인을 유도합니다.

**주요 기능**:
- 서비스 소개 섹션
- 주요 기능 설명
- 소셜 로그인 버튼 (Google, Kakao, Naver)
- 로컬 로그인 및 회원가입 링크

**상태 관리**:
- 전역 상태 없음 (Stateless)

**컴포넌트 구조**:
```javascript
<WelcomePage>
  <Hero />
  <Features />
  <SocialLoginButtons />
  <CTASection />
</WelcomePage>
```

### LoginPage

이메일과 비밀번호로 로그인합니다.

**주요 기능**:
- 이메일/비밀번호 입력 폼
- 입력 검증 (React Hook Form + Yup)
- 로그인 처리 (authStore.login)
- 소셜 로그인 옵션
- 회원가입 링크

**상태 관리**:
- authStore: login(), status, error

**Props**: 없음

**폼 검증**:
```javascript
const schema = yup.object({
  email: yup.string().email('유효한 이메일을 입력하세요').required('이메일을 입력하세요'),
  password: yup.string().min(8, '비밀번호는 8자 이상이어야 합니다').required('비밀번호를 입력하세요')
});
```

### SignupPage

신규 사용자 회원가입을 처리합니다.

**주요 기능**:
- Step 1: 약관 동의
- Step 2: 정보 입력 (이메일, 비밀번호, 이름, 생년월일, 직업)
- 입력 검증
- 회원가입 처리
- 이메일 인증 페이지로 이동

**상태 관리**:
- authStore: signup()
- termsStore: getActiveTerms()

**컴포넌트 구조**:
```javascript
<SignupPage>
  {currentStep === 1 && <SignupStep1 />}
  {currentStep === 2 && <SignupStep2 />}
</SignupPage>
```

### EmailVerificationPage

이메일 인증 코드를 입력받아 검증합니다.

**주요 기능**:
- 6자리 인증 코드 입력
- 코드 검증 (authService.verifyEmail)
- 재발송 기능 (60초 쿨다운)
- 인증 완료 후 완료 페이지로 이동

**상태 관리**:
- location.state: email, emailVerificationToken
- 로컬 상태: verificationCode, isVerifying, cooldown

### DashboardPage

로그인 후 메인 대시보드를 표시합니다.

**주요 기능**:
- 사용자 환영 메시지
- 최근 대화 세션
- 추천 시나리오
- 학습 통계
- 빠른 액션 (새 대화 시작, 피드백 작성)

**상태 관리**:
- authStore: user
- sessionStore: recentSessions
- scenarioStore: recommendedScenarios

**컴포넌트 구조**:
```javascript
<DashboardPage>
  <WelcomeSection user={user} />
  <RecentSessions sessions={recentSessions} />
  <RecommendedScenarios scenarios={recommendedScenarios} />
  <QuickActions />
</DashboardPage>
```

### ScenarioListPage

사용자가 선택할 수 있는 시나리오 목록을 표시합니다.

**주요 기능**:
- 시나리오 목록 조회
- 필터링 (난이도, 카테고리)
- 정렬 (인기순, 최신순)
- 검색
- 시나리오 카드 클릭 시 상세 페이지로 이동

**상태 관리**:
- scenarioStore: fetchScenarios, scenarios, filters

**컴포넌트 구조**:
```javascript
<ScenarioListPage>
  <ScenarioFilters />
  <ScenarioGrid>
    {scenarios.map(scenario => <ScenarioCard key={scenario.id} scenario={scenario} />)}
  </ScenarioGrid>
  <Pagination />
</ScenarioListPage>
```

### ScenarioDetailPage

선택한 시나리오의 상세 정보를 표시합니다.

**주요 기능**:
- 시나리오 상세 정보 (제목, 설명, 난이도, 카테고리, 예상 시간)
- 시나리오 시작 버튼
- 관련 피드백
- 학습 목표

**상태 관리**:
- scenarioStore: getScenarioById
- sessionStore: createSession

**Props**: 없음 (useParams로 id 추출)

### DialoguePage

실시간 대화 세션을 진행합니다.

**주요 기능**:
- WebRTC 연결 (OpenAI Realtime API)
- 음성 입력/출력
- 실시간 대화 텍스트 표시
- 대화 종료
- 세션 완료 후 피드백 페이지로 이동

**상태 관리**:
- sessionStore: currentSession, transcripts
- realtimeStore: connectionStatus, isRecording

**컴포넌트 구조**:
```javascript
<DialoguePage>
  <DialogueHeader session={currentSession} />
  <TranscriptPanel transcripts={transcripts} />
  <AudioControls isRecording={isRecording} onToggle={toggleRecording} />
  <EndSessionButton onEnd={handleEndSession} />
</DialoguePage>
```

### FeedbackListPage

사용자가 작성한 피드백 목록을 표시합니다.

**주요 기능**:
- 피드백 목록 조회
- 필터링 (날짜, 평점)
- 정렬
- 피드백 카드 클릭 시 상세 페이지로 이동

**상태 관리**:
- feedbackStore: fetchFeedbacks, feedbacks, filters

### FeedbackDetailPage

선택한 피드백의 상세 내용을 표시합니다.

**주요 기능**:
- 피드백 상세 정보 (평점, 코멘트, 작성일)
- 관련 세션 정보
- 수정 및 삭제 버튼

**상태 관리**:
- feedbackStore: currentFeedback, updateFeedback, deleteFeedback

### ProfilePage

사용자 프로필 정보를 표시하고 수정합니다.

**주요 기능**:
- 프로필 정보 조회
- 프로필 수정 (이름, 생년월일, 직업)
- 프로필 이미지 업로드
- 비밀번호 변경

**상태 관리**:
- authStore: user, updateProfile

### HistoryPage

사용자의 대화 히스토리를 표시합니다.

**주요 기능**:
- 세션 목록 조회
- 필터링 (날짜, 시나리오)
- 정렬
- 세션 카드 클릭 시 상세 페이지로 이동

**상태 관리**:
- sessionStore: fetchSessions, sessions, filters

---

## 컴포넌트 명세

### 공통 컴포넌트

#### Button

범용 버튼 컴포넌트입니다.

**Props**:
```javascript
{
  children: ReactNode,
  variant: 'primary' | 'secondary' | 'danger',
  size: 'small' | 'medium' | 'large',
  disabled: boolean,
  loading: boolean,
  onClick: () => void,
  type: 'button' | 'submit' | 'reset',
  className?: string
}
```

#### Input

범용 입력 컴포넌트입니다.

**Props**:
```javascript
{
  type: 'text' | 'email' | 'password' | 'number',
  value: string,
  onChange: (value: string) => void,
  placeholder: string,
  error?: string,
  disabled: boolean,
  required: boolean,
  className?: string
}
```

#### Modal

모달 컨테이너 컴포넌트입니다.

**Props**:
```javascript
{
  open: boolean,
  onClose: () => void,
  title?: string,
  children: ReactNode,
  size: 'small' | 'medium' | 'large',
  closeOnBackdropClick: boolean,
  className?: string
}
```

#### LoadingSpinner

로딩 상태를 표시합니다.

**Props**:
```javascript
{
  size: 'small' | 'medium' | 'large',
  message?: string,
  fullScreen: boolean
}
```

#### ErrorMessage

에러 메시지를 표시합니다.

**Props**:
```javascript
{
  message: string,
  onRetry?: () => void,
  className?: string
}
```

### 인증 컴포넌트

#### SocialLoginButtons

소셜 로그인 버튼들을 렌더링합니다.

**Props**:
```javascript
{
  providers: Array<'google' | 'kakao' | 'naver'>,
  onProviderClick: (provider: string) => void
}
```

#### SignupStep1

약관 동의 단계 컴포넌트입니다.

**Props**:
```javascript
{
  consents: Array<ConsentItem>,
  setConsents: (consents: Array<ConsentItem>) => void,
  onNext: () => void
}
```

#### SignupStep2

정보 입력 단계 컴포넌트입니다.

**Props**:
```javascript
{
  formData: SignupFormData,
  setFormData: (data: SignupFormData) => void,
  consents: Array<ConsentItem>,
  onSubmit: (e: Event) => void,
  onBack: () => void,
  isSubmitting: boolean
}
```

### 시나리오 컴포넌트

#### ScenarioCard

시나리오 카드를 표시합니다.

**Props**:
```javascript
{
  scenario: {
    id: string,
    title: string,
    description: string,
    difficulty: 'EASY' | 'MEDIUM' | 'HARD',
    category: string,
    estimatedTime: number,
    thumbnail?: string
  },
  onClick: (id: string) => void
}
```

#### ScenarioFilters

시나리오 필터링 UI입니다.

**Props**:
```javascript
{
  filters: {
    difficulty?: string,
    category?: string,
    sortBy: string,
    sortOrder: 'asc' | 'desc'
  },
  onFilterChange: (key: string, value: any) => void
}
```

### 대화 컴포넌트

#### TranscriptPanel

대화 내용을 표시합니다.

**Props**:
```javascript
{
  transcripts: Array<{
    speaker: 'USER' | 'AI',
    content: string,
    timestamp: string
  }>,
  autoScroll: boolean
}
```

#### AudioControls

음성 녹음 컨트롤입니다.

**Props**:
```javascript
{
  isRecording: boolean,
  onToggle: () => void,
  disabled: boolean
}
```

### 피드백 컴포넌트

#### FeedbackModal

피드백 작성 모달입니다.

**Props**:
```javascript
{
  sessionId: string,
  onClose: () => void,
  onSuccess?: () => void
}
```

#### StarRating

별점 입력 컴포넌트입니다.

**Props**:
```javascript
{
  value: number,
  onChange: (value: number) => void,
  disabled: boolean,
  size: 'small' | 'medium' | 'large'
}
```

#### FeedbackCard

피드백 카드를 표시합니다.

**Props**:
```javascript
{
  feedback: {
    feedbackId: string,
    rating: number,
    comment: string,
    createdAt: string,
    updatedAt: string
  },
  onEdit?: (id: string) => void,
  onDelete?: (id: string) => void
}
```

---

## Hooks

### useAuthBootstrap

앱 초기화 시 인증 상태를 복원합니다.

```javascript
export function useAuthBootstrap() {
  const initializeAuth = useAuthStore((s) => s.initializeAuth);

  useEffect(() => {
    initializeAuth();
  }, [initializeAuth]);
}
```

### useProtectedAction

인증이 필요한 액션을 감싸서 미인증 시 로그인 페이지로 리다이렉트합니다.

```javascript
export function useProtectedAction() {
  const { status } = useAuthStore();
  const navigate = useNavigate();

  return useCallback((action) => {
    if (status === 'authenticated') {
      action();
    } else {
      navigate('/login');
    }
  }, [status, navigate]);
}
```

### useFeedbackPolling

주기적으로 피드백 데이터를 갱신합니다.

```javascript
export function useFeedbackPolling(interval = 30000) {
  const { fetchFeedbacks } = useFeedbackStore();

  useEffect(() => {
    const timer = setInterval(() => {
      fetchFeedbacks();
    }, interval);

    return () => clearInterval(timer);
  }, [fetchFeedbacks, interval]);
}
```

---

## 서비스

### authService

인증 관련 API 호출을 담당합니다.

**메서드**:
- signup(payload): 회원가입
- login(payload): 로그인
- logout(): 로그아웃
- verifyEmail(payload): 이메일 인증
- resendVerificationEmail(email): 인증 코드 재발송
- exchangeToken(code): 소셜 로그인 토큰 교환
- completeSocialSignup(payload): 소셜 회원가입 완료

### scenarioService

시나리오 관련 API 호출을 담당합니다.

**메서드**:
- getScenarios(params): 시나리오 목록 조회
- getScenarioById(id): 시나리오 상세 조회
- getRecommendedScenarios(): 추천 시나리오 조회

### sessionService

대화 세션 관련 API 호출을 담당합니다.

**메서드**:
- createSession(scenarioId): 세션 생성
- getSessionById(id): 세션 조회
- completeSession(id): 세션 완료
- getSessions(params): 세션 목록 조회

### feedbackService

피드백 관련 API 호출을 담당합니다.

**메서드**:
- createFeedback(payload): 피드백 작성
- getFeedbacks(params): 피드백 목록 조회
- getFeedbackById(id): 피드백 상세 조회
- updateFeedback(id, payload): 피드백 수정
- deleteFeedback(id): 피드백 삭제

---

## 상태 관리

### authStore

사용자 인증 상태를 관리합니다.

**상태**:
```javascript
{
  user: User | null,
  accessToken: string | null,
  status: 'idle' | 'loading' | 'authenticated' | 'unauthenticated',
  error: any | null,
  isInitialized: boolean
}
```

**액션**:
- initializeAuth()
- login(credentials)
- signup(payload)
- logout()
- exchangeCode(code)
- completeSocialSignup(payload)

### scenarioStore

시나리오 데이터를 관리합니다.

**상태**:
```javascript
{
  scenarios: Scenario[],
  currentScenario: Scenario | null,
  filters: FilterOptions,
  pagination: PaginationState,
  status: 'idle' | 'loading' | 'success' | 'error'
}
```

**액션**:
- fetchScenarios(filters)
- getScenarioById(id)
- fetchRecommendedScenarios()

### sessionStore

대화 세션 데이터를 관리합니다.

**상태**:
```javascript
{
  sessions: Session[],
  currentSession: Session | null,
  transcripts: Transcript[],
  status: 'idle' | 'loading' | 'success' | 'error'
}
```

**액션**:
- createSession(scenarioId)
- fetchSessions(filters)
- getSessionById(id)
- completeSession(id)
- addTranscript(transcript)

### feedbackStore

피드백 데이터를 관리합니다.

**상태**:
```javascript
{
  feedbacks: Feedback[],
  currentFeedback: Feedback | null,
  statistics: FeedbackStats,
  filters: FilterOptions,
  pagination: PaginationState,
  status: 'idle' | 'loading' | 'success' | 'error'
}
```

**액션**:
- createFeedback(payload)
- fetchFeedbacks(filters)
- getFeedbackById(id)
- updateFeedback(id, payload)
- deleteFeedback(id)
- fetchStatistics()

---

## 유틸리티

### dateUtils

날짜 포맷팅 유틸리티입니다.

**함수**:
```javascript
formatDate(date, format): 날짜를 지정된 형식으로 포맷
formatRelativeTime(date): 상대적 시간 표시 (3시간 전, 어제 등)
isToday(date): 오늘인지 확인
isYesterday(date): 어제인지 확인
```

### validationUtils

입력 검증 유틸리티입니다.

**함수**:
```javascript
isValidEmail(email): 이메일 형식 검증
isValidPassword(password): 비밀번호 강도 검증
isValidPhoneNumber(phone): 전화번호 형식 검증
sanitizeInput(input): 입력값 sanitization
```

### apiUtils

API 응답 처리 유틸리티입니다.

**함수**:
```javascript
unwrap(response): API 응답 데이터 추출
handleApiError(error): API 에러 처리
buildQueryString(params): 쿼리 스트링 생성
```

---

## 참고 자료 (References)

### 공식 문서

- [React 공식 문서](https://react.dev/)
- [React Router v6](https://reactrouter.com/)
- [Zustand 공식 문서](https://docs.pmnd.rs/zustand/getting-started/introduction)
- [React Hook Form](https://react-hook-form.com/)
- [Yup](https://github.com/jquense/yup)

### 내부 문서

- [Dialogym API 명세서](../api/api-specification.md)
- [프론트엔드 아키텍처 문서](./frontend-architecture.md)
- [인증 시스템 설계 문서](./frontend-authentication-security-design.md)
- [피드백 시스템 설계 문서](./frontend-feedback-system-design.md)

### 스타일 가이드

- [컴포넌트 네이밍 가이드](./component-naming-guide.md)
- [SCSS 스타일 가이드](./scss-style-guide.md)
- [접근성 가이드](./accessibility-guide.md)

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.11.02 | 왕택준 | 최초 작성 |
