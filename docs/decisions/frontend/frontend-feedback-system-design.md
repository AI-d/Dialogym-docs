# Dialogym 프론트엔드 피드백 시스템 설계

**담당자 (Author)**: [왕택준](https://github.com/TJK98)

**검토자 (Reviewer / PO·SM)**: [왕택준](https://github.com/TJK98)

**작성일 (Created)**: 2025.11.02

**문서 버전 (Version)**: v1.0

**문서 상태 (Status)**: Draft

---

## 대상 독자 (Intended Audience)

* **프론트엔드 개발자**: 피드백 시스템 구현 및 유지보수를 담당하는 개발자
* **백엔드 개발자**: 프론트엔드 피드백 시스템을 이해하고 API를 연동하는 개발자
* **UX/UI 디자이너**: 피드백 시스템의 사용자 경험을 설계하는 디자이너
* **프로덕트 매니저**: 피드백 시스템의 요구사항과 우선순위를 결정하는 담당자
* **신규 팀원**: Dialogym 피드백 시스템을 빠르게 학습해야 하는 신규 합류자

---

## 핵심 요약 (Executive Summary)

본 문서는 Dialogym 프론트엔드의 피드백 시스템 전체 설계를 정의합니다.
Zustand와 Immer를 활용한 중앙 집중식 상태 관리를 채택하고, React Hook Form과 Yup으로 폼 검증을 수행합니다.
피드백 CRUD 작업을 지원하며, 필터링과 페이지네이션으로 대량 데이터를 효율적으로 처리합니다.
낙관적 업데이트로 사용자 경험을 향상시키고, 메모이제이션과 가상 스크롤링으로 성능을 최적화합니다.
실시간 업데이트는 Polling 방식을 사용하며, 향후 WebSocket으로 전환할 계획입니다.

---

## 목차 (Table of Contents)

1. [문서 개요](#문서-개요-overview)
2. [시스템 개요](#시스템-개요)
3. [피드백 아키텍처](#피드백-아키텍처)
4. [상태 관리 설계](#상태-관리-설계-feedbackstore)
5. [API 클라이언트 설계](#api-클라이언트-설계)
6. [피드백 서비스 설계](#피드백-서비스-설계-feedbackservice)
7. [피드백 작성 플로우](#피드백-작성-플로우)
8. [피드백 조회 및 관리](#피드백-조회-및-관리)
9. [실시간 업데이트](#실시간-업데이트)
10. [성능 최적화](#성능-최적화)
11. [에러 처리 및 복구](#에러-처리-및-복구)
12. [베스트 프랙티스](#베스트-프랙티스)
13. [향후 개선사항](#향후-개선사항)
14. [체크리스트](#체크리스트)
15. [참고 자료](#참고-자료-references)

---

## 문서 개요 (Overview)

본 문서는 Dialogym 프론트엔드의 피드백 시스템 설계와 구현을 상세히 기록한 기능 설계 문서입니다.

피드백 시스템은 사용자 경험 개선과 서비스 품질 향상의 핵심 기능입니다.
명확한 설계 문서화를 통해 개발자 간 공통된 이해를 확보하고, 사용자 요구사항을 체계적으로 구현하며, 신규 합류자의 학습 곡선을 단축합니다.

본 문서는 Dialogym 프론트엔드의 모든 피드백 관련 개발, 유지보수, 개선 활동에 적용되며, 시스템 변경 시 반드시 업데이트해야 합니다.

---

## 시스템 개요

### 피드백 시스템 목적

Dialogym의 피드백 시스템은 사용자가 대화 세션에 대한 피드백을 작성하고 관리할 수 있는 기능을 제공합니다.

사용자의 학습 경험을 개선하고, 대화 품질 향상을 위한 데이터를 수집하며, 사용자 참여도를 증대시킵니다.
AI 모델 개선을 위한 피드백 데이터를 축적합니다.

### 핵심 기술 스택

상태 관리는 Zustand와 Immer를 사용하고, HTTP 클라이언트는 Axios (apiClient 재사용)를 채택합니다.
폼 관리는 React Hook Form과 Yup으로 처리하며, UI 컴포넌트는 자체 구현(Rating, TextArea, Modal)합니다.
알림은 React Hot Toast를 사용하고, 실시간 업데이트는 Polling과 WebSocket(향후)으로 처리합니다.

### 주요 기능

피드백 작성은 대화 세션에 대한 평점 및 코멘트를 작성할 수 있습니다.
피드백 조회는 내가 작성한 피드백 목록을 조회할 수 있으며, 피드백 수정은 기존 피드백 내용을 수정할 수 있습니다.
피드백 삭제는 작성한 피드백을 삭제할 수 있고, 피드백 통계는 평균 평점과 피드백 개수 등을 제공합니다.
필터링 및 정렬은 날짜와 평점 기준으로 수행하며, 페이지네이션은 대량 피드백을 효율적으로 로딩합니다.

### 설계 원칙

사용자 중심으로 직관적이고 간편한 피드백 작성 경험을 제공합니다.
성능 최적화로 빠른 로딩과 부드러운 인터랙션을 보장하며, 데이터 무결성으로 피드백 데이터의 정확성을 보장합니다.
확장성으로 새로운 피드백 유형 추가가 용이하고, 접근성으로 모든 사용자가 쉽게 사용할 수 있도록 합니다.

---

## 피드백 아키텍처

### 전체 구조

```
┌─────────────────────────────────────────────────────────────┐
│                         React App                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           feedbackStore (Zustand + Immer)              │  │
│  │  - feedbacks: Feedback[]                               │  │
│  │  - currentFeedback: Feedback | null                    │  │
│  │  - statistics: FeedbackStats                           │  │
│  │  - filters: FilterOptions                              │  │
│  │  - pagination: PaginationState                         │  │
│  │  - status: 'idle' | 'loading' | 'success' | 'error'   │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ↕                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              feedbackService (API 호출)                │  │
│  │  - createFeedback()                                    │  │
│  │  - getFeedbacks()                                      │  │
│  │  - getFeedbackById()                                   │  │
│  │  - updateFeedback()                                    │  │
│  │  - deleteFeedback()                                    │  │
│  │  - getFeedbackStats()                                  │  │
│  └───────────────────────────────────────────────────────┘  │
│                            ↕                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  apiClient (Axios)                     │  │
│  │  - Authorization 헤더 자동 추가                       │  │
│  │  - 401 에러 자동 처리                                 │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                      Backend API                             │
│  - 피드백 CRUD 작업                                         │
│  - 피드백 통계 계산                                         │
│  - 피드백 검증 및 필터링                                    │
│  - 권한 확인 (본인 피드백만 수정 및 삭제)                  │
└─────────────────────────────────────────────────────────────┘
```

### 데이터 흐름

#### 피드백 작성

사용자가 대화 세션을 완료하면 피드백 작성 모달이 표시됩니다.
사용자가 평점 및 코멘트를 입력하고 feedbackStore.createFeedback(payload)를 호출합니다.
POST /api/v1/feedbacks로 요청하면 서버는 Body에 feedbackId, rating, comment, createdAt을 반환합니다.
feedbackStore 상태를 업데이트하고 성공 메시지를 표시한 후 피드백 목록 페이지로 이동(선택적)합니다.

#### 피드백 조회

사용자가 피드백 목록 페이지에 접근하면 feedbackStore.fetchFeedbacks(filters)를 호출합니다.
GET /api/v1/feedbacks?page=1&size=10&sort=createdAt,desc로 요청하면 서버는 Body에 content (Feedback[]), totalElements, totalPages를 반환합니다.
feedbackStore 상태를 업데이트하고 피드백 목록을 렌더링합니다.

#### 피드백 수정

사용자가 피드백 수정 버튼을 클릭하면 기존 피드백 데이터를 로드하고 수정 모달을 표시합니다(기존 데이터 pre-fill).
사용자가 내용을 수정하고 feedbackStore.updateFeedback(feedbackId, payload)를 호출합니다.
PUT /api/v1/feedbacks/{feedbackId}로 요청하면 서버는 Body에 feedbackId, rating, comment, updatedAt을 반환합니다.
feedbackStore 상태를 업데이트(해당 피드백만)하고 성공 메시지를 표시합니다.

#### 피드백 삭제

사용자가 피드백 삭제 버튼을 클릭하면 확인 다이얼로그를 표시합니다.
사용자가 확인하면 feedbackStore.deleteFeedback(feedbackId)를 호출합니다.
DELETE /api/v1/feedbacks/{feedbackId}로 요청하면 서버는 204 No Content를 반환합니다.
feedbackStore에서 해당 피드백을 제거하고 성공 메시지를 표시합니다.

---

## 상태 관리 설계 (feedbackStore)

### 상태 구조

```javascript
{
  feedbacks: Feedback[],
  currentFeedback: Feedback | null,

  statistics: {
    totalCount: number,
    averageRating: number,
    ratingDistribution: {
      1: number,
      2: number,
      3: number,
      4: number,
      5: number
    }
  },

  filters: {
    sessionId: string | null,
    minRating: number | null,
    maxRating: number | null,
    startDate: string | null,
    endDate: string | null,
    sortBy: 'createdAt' | 'rating',
    sortOrder: 'asc' | 'desc'
  },

  pagination: {
    page: number,
    size: number,
    totalElements: number,
    totalPages: number
  },

  status: 'idle' | 'loading' | 'success' | 'error',
  error: any | null
}
```

### Feedback 데이터 모델

```javascript
interface Feedback {
  feedbackId: string;
  sessionId: string;
  userId: string;
  rating: number;          // 1-5
  comment: string;
  createdAt: string;       // ISO 8601
  updatedAt: string;       // ISO 8601

  session?: {
    sessionId: string;
    title: string;
    duration: number;
  };

  user?: {
    userId: string;
    name: string;
    profileImage: string;
  };
}
```

### 주요 액션

#### createFeedback(payload)

대화 세션에 대한 피드백을 생성하고, 입력을 검증하며, 상태를 업데이트합니다.

```javascript
createFeedback: async (payload) => {
  set({ status: 'loading', error: null });
  try {
    const newFeedback = await feedbackService.createFeedback(payload);

    set((state) => ({
      feedbacks: [newFeedback, ...state.feedbacks],
      status: 'success'
    }));

    await get().fetchStatistics();

    return newFeedback;
  } catch (error) {
    set({ status: 'error', error: error.response?.data || error });
    throw error;
  }
}
```

Payload는 sessionId, rating (1-5), comment (최대 1000자)를 포함합니다.

#### fetchFeedbacks(filters)

필터링 및 정렬된 피드백 목록을 조회하고, 페이지네이션을 지원하며, 캐싱 전략을 적용합니다.

```javascript
fetchFeedbacks: async (filters = {}) => {
  set({ status: 'loading', error: null });
  try {
    const response = await feedbackService.getFeedbacks({
      ...get().filters,
      ...filters,
      page: get().pagination.page,
      size: get().pagination.size
    });

    set({
      feedbacks: response.content,
      pagination: {
        page: response.page,
        size: response.size,
        totalElements: response.totalElements,
        totalPages: response.totalPages
      },
      status: 'success'
    });
  } catch (error) {
    set({ status: 'error', error: error.response?.data || error });
    throw error;
  }
}
```

#### updateFeedback(feedbackId, payload)

기존 피드백을 수정하고, 낙관적 업데이트를 적용하며, 실패 시 롤백합니다.

```javascript
updateFeedback: async (feedbackId, payload) => {
  const previousFeedbacks = get().feedbacks;

  set((state) => ({
    feedbacks: state.feedbacks.map((f) =>
      f.feedbackId === feedbackId
        ? { ...f, ...payload, updatedAt: new Date().toISOString() }
        : f
    ),
    status: 'loading'
  }));

  try {
    const updatedFeedback = await feedbackService.updateFeedback(feedbackId, payload);

    set((state) => ({
      feedbacks: state.feedbacks.map((f) =>
        f.feedbackId === feedbackId ? updatedFeedback : f
      ),
      status: 'success'
    }));

    return updatedFeedback;
  } catch (error) {
    set({ feedbacks: previousFeedbacks, status: 'error', error: error.response?.data || error });
    throw error;
  }
}
```

#### deleteFeedback(feedbackId)

피드백을 삭제하고, 낙관적 업데이트를 적용하며, 실패 시 롤백합니다.

```javascript
deleteFeedback: async (feedbackId) => {
  const previousFeedbacks = get().feedbacks;

  set((state) => ({
    feedbacks: state.feedbacks.filter((f) => f.feedbackId !== feedbackId),
    status: 'loading'
  }));

  try {
    await feedbackService.deleteFeedback(feedbackId);

    set({ status: 'success' });

    await get().fetchStatistics();
  } catch (error) {
    set({ feedbacks: previousFeedbacks, status: 'error', error: error.response?.data || error });
    throw error;
  }
}
```

#### fetchStatistics()

피드백 통계를 조회하여 totalCount, averageRating, ratingDistribution을 가져옵니다.

```javascript
fetchStatistics: async () => {
  try {
    const stats = await feedbackService.getFeedbackStats();
    set({ statistics: stats });
  } catch (error) {
    console.error('Failed to fetch statistics:', error);
  }
}
```

### 셀렉터

필요한 상태만 구독하여 성능을 최적화합니다.

```javascript
export const useFeedbacks = () => useFeedbackStore((s) => s.feedbacks);
export const useCurrentFeedback = () => useFeedbackStore((s) => s.currentFeedback);
export const useFeedbackStatistics = () => useFeedbackStore((s) => s.statistics);
export const useFeedbackStatus = () => useFeedbackStore((s) => s.status);
```

---

## API 클라이언트 설계

기존 인증 시스템의 apiClient를 재사용하여 Authorization 헤더를 자동으로 추가하고, 401 에러를 자동으로 처리합니다.

```javascript
import apiClient from '@/services/apiClient';

export const feedbackApi = {
  create: (payload) => apiClient.post('/feedbacks', payload),
  getList: (params) => apiClient.get('/feedbacks', { params }),
  getById: (id) => apiClient.get(`/feedbacks/${id}`),
  update: (id, payload) => apiClient.put(`/feedbacks/${id}`, payload),
  delete: (id) => apiClient.delete(`/feedbacks/${id}`),
  getStats: () => apiClient.get('/feedbacks/stats')
};
```

apiClient는 withCredentials: true로 쿠키를 자동 전송하며, Request Interceptor로 Authorization 헤더를 추가하고, Response Interceptor로 401 에러 시 자동 토큰 갱신을 수행합니다.

---

## 피드백 서비스 설계 (feedbackService)

API 호출 로직을 캡슐화하고, 응답 데이터를 정규화(unwrap)하며, 타입 안전성을 제공합니다.

```javascript
import { feedbackApi } from '@/services/apiClient';
import { unwrap } from '@/utils/apiUtils';

export const feedbackService = {
  createFeedback: async (payload) => {
    const { data } = await feedbackApi.create(payload);
    return unwrap(data).data;
  },

  getFeedbacks: async (params) => {
    const { data } = await feedbackApi.getList(params);
    return unwrap(data).data;
  },

  getFeedbackById: async (id) => {
    const { data } = await feedbackApi.getById(id);
    return unwrap(data).data;
  },

  updateFeedback: async (id, payload) => {
    const { data } = await feedbackApi.update(id, payload);
    return unwrap(data).data;
  },

  deleteFeedback: async (id) => {
    await feedbackApi.delete(id);
  },

  getFeedbackStats: async () => {
    const { data } = await feedbackApi.getStats();
    return unwrap(data).data;
  }
};
```

---

## 피드백 작성 플로우

### FeedbackModal 컴포넌트

React Hook Form과 Yup을 사용하여 폼을 관리하고 검증합니다.

```javascript
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';

const schema = yup.object({
  rating: yup.number().min(1).max(5).required('평점을 선택해주세요'),
  comment: yup.string().max(1000, '코멘트는 1000자 이하로 입력해주세요').required('코멘트를 입력해주세요')
});

export const FeedbackModal = ({ sessionId, onClose, onSuccess }) => {
  const { register, handleSubmit, formState: { errors }, setValue } = useForm({
    resolver: yupResolver(schema),
    defaultValues: { rating: 0, comment: '' }
  });

  const { createFeedback, status } = useFeedbackStore();

  const onSubmit = async (data) => {
    try {
      await createFeedback({ sessionId, ...data });
      toast.success('피드백이 작성되었습니다');
      onSuccess?.();
      onClose();
    } catch (error) {
      toast.error(error.response?.data?.message || '피드백 작성에 실패했습니다');
    }
  };

  return (
    <Modal open onClose={onClose}>
      <form onSubmit={handleSubmit(onSubmit)}>
        <h2>피드백 작성</h2>

        <StarRating
          value={watch('rating')}
          onChange={(value) => setValue('rating', value)}
        />
        {errors.rating && <p className="error">{errors.rating.message}</p>}

        <textarea
          {...register('comment')}
          placeholder="세션에 대한 피드백을 작성해주세요"
          rows={5}
        />
        {errors.comment && <p className="error">{errors.comment.message}</p>}

        <button type="submit" disabled={status === 'loading'}>
          {status === 'loading' ? '작성 중...' : '작성하기'}
        </button>
      </form>
    </Modal>
  );
};
```

### StarRating 컴포넌트

접근성과 사용자 경험을 고려한 별점 입력 컴포넌트입니다.

```javascript
export const StarRating = ({ value, onChange, disabled = false }) => {
  const [hoverValue, setHoverValue] = useState(0);

  return (
    <div className="star-rating" role="radiogroup" aria-label="평점 선택">
      {[1, 2, 3, 4, 5].map((star) => (
        <button
          key={star}
          type="button"
          role="radio"
          aria-checked={value === star}
          aria-label={`${star}점`}
          className={star <= (hoverValue || value) ? 'star filled' : 'star'}
          onClick={() => !disabled && onChange(star)}
          onMouseEnter={() => !disabled && setHoverValue(star)}
          onMouseLeave={() => setHoverValue(0)}
          disabled={disabled}
        >
          ★
        </button>
      ))}
    </div>
  );
};
```

---

## 피드백 조회 및 관리

### FeedbackListPage 컴포넌트

피드백 목록을 조회하고 필터링 및 페이지네이션을 제공합니다.

```javascript
export const FeedbackListPage = () => {
  const { feedbacks, pagination, status, fetchFeedbacks } = useFeedbackStore();

  useEffect(() => {
    fetchFeedbacks();
  }, [fetchFeedbacks]);

  const handlePageChange = (newPage) => {
    useFeedbackStore.setState((state) => ({
      pagination: { ...state.pagination, page: newPage }
    }));
    fetchFeedbacks();
  };

  if (status === 'loading') {
    return <LoadingSpinner />;
  }

  if (status === 'error') {
    return <ErrorMessage message="피드백을 불러오는데 실패했습니다" />;
  }

  return (
    <div className="feedback-list-page">
      <h1>내 피드백</h1>

      <FeedbackFilters />

      <div className="feedback-list">
        {feedbacks.map((feedback) => (
          <FeedbackCard key={feedback.feedbackId} feedback={feedback} />
        ))}
      </div>

      <Pagination
        currentPage={pagination.page}
        totalPages={pagination.totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};
```

### FeedbackCard 컴포넌트

개별 피드백을 표시하고 수정 및 삭제 기능을 제공합니다.

```javascript
export const FeedbackCard = memo(({ feedback }) => {
  const { updateFeedback, deleteFeedback } = useFeedbackStore();
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);

  const handleDelete = async () => {
    if (window.confirm('정말 삭제하시겠습니까?')) {
      try {
        await deleteFeedback(feedback.feedbackId);
        toast.success('피드백이 삭제되었습니다');
      } catch (error) {
        toast.error('삭제에 실패했습니다');
      }
    }
  };

  return (
    <div className="feedback-card">
      <div className="feedback-header">
        <StarRating value={feedback.rating} disabled />
        <span className="feedback-date">
          {new Date(feedback.createdAt).toLocaleDateString()}
        </span>
      </div>

      <p className="feedback-comment">{feedback.comment}</p>

      <div className="feedback-actions">
        <button onClick={() => setIsEditModalOpen(true)}>수정</button>
        <button onClick={handleDelete}>삭제</button>
      </div>

      {isEditModalOpen && (
        <FeedbackEditModal
          feedback={feedback}
          onClose={() => setIsEditModalOpen(false)}
        />
      )}
    </div>
  );
}, (prevProps, nextProps) => {
  return prevProps.feedback.feedbackId === nextProps.feedback.feedbackId &&
         prevProps.feedback.updatedAt === nextProps.feedback.updatedAt;
});
```

### FeedbackFilters 컴포넌트

필터링 옵션을 제공합니다.

```javascript
export const FeedbackFilters = () => {
  const { filters, fetchFeedbacks } = useFeedbackStore();

  const handleFilterChange = (key, value) => {
    useFeedbackStore.setState((state) => ({
      filters: { ...state.filters, [key]: value }
    }));
    fetchFeedbacks();
  };

  return (
    <div className="feedback-filters">
      <select
        value={filters.sortBy}
        onChange={(e) => handleFilterChange('sortBy', e.target.value)}
      >
        <option value="createdAt">작성일</option>
        <option value="rating">평점</option>
      </select>

      <select
        value={filters.sortOrder}
        onChange={(e) => handleFilterChange('sortOrder', e.target.value)}
      >
        <option value="desc">내림차순</option>
        <option value="asc">오름차순</option>
      </select>

      <input
        type="number"
        min="1"
        max="5"
        placeholder="최소 평점"
        value={filters.minRating || ''}
        onChange={(e) => handleFilterChange('minRating', e.target.value ? Number(e.target.value) : null)}
      />
    </div>
  );
};
```

---

## 실시간 업데이트

### Polling 방식

현재는 주기적으로 API를 호출하여 데이터를 갱신합니다.

```javascript
export const useFeedbackPolling = (interval = 30000) => {
  const { fetchFeedbacks } = useFeedbackStore();

  useEffect(() => {
    const timer = setInterval(() => {
      fetchFeedbacks();
    }, interval);

    return () => clearInterval(timer);
  }, [fetchFeedbacks, interval]);
};
```

간단하고 구현이 쉬우며, 서버 부하가 예측 가능합니다.
하지만 실시간성이 떨어지고 불필요한 요청이 발생할 수 있습니다.

### WebSocket 방식 (향후)

실시간 양방향 통신으로 즉각적인 업데이트를 제공합니다.

```javascript
export const useFeedbackWebSocket = () => {
  useEffect(() => {
    const ws = new WebSocket('wss://api.dialogym.com/ws/feedbacks');

    ws.onopen = () => {
      console.log('WebSocket connected');
    };

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      handleWebSocketMessage(data);
    };

    ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    ws.onclose = () => {
      console.log('WebSocket disconnected');
    };

    return () => ws.close();
  }, []);
};

const handleWebSocketMessage = (data) => {
  switch (data.type) {
    case 'FEEDBACK_CREATED':
      useFeedbackStore.getState().addFeedback(data.feedback);
      break;

    case 'FEEDBACK_UPDATED':
      useFeedbackStore.getState().updateFeedbackInList(data.feedback);
      break;

    case 'FEEDBACK_DELETED':
      useFeedbackStore.getState().removeFeedback(data.feedbackId);
      break;
  }
};
```

실시간 업데이트가 가능하고 서버 부하가 감소하며 사용자 경험이 향상됩니다.
하지만 구현이 복잡하고 인프라 비용이 증가하며 연결 관리가 필요합니다.

---

## 성능 최적화

### 메모이제이션

React.memo를 사용하여 불필요한 리렌더링을 방지합니다.

```javascript
import { memo } from 'react';

export const FeedbackCard = memo(({ feedback }) => {
  // ...
}, (prevProps, nextProps) => {
  return prevProps.feedback.feedbackId === nextProps.feedback.feedbackId &&
         prevProps.feedback.updatedAt === nextProps.feedback.updatedAt;
});
```

### 가상 스크롤링

react-window를 사용하여 대량의 피드백을 효율적으로 렌더링합니다.

```javascript
import { FixedSizeList } from 'react-window';

export const FeedbackList = ({ feedbacks }) => {
  const Row = ({ index, style }) => (
    <div style={style}>
      <FeedbackCard feedback={feedbacks[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={feedbacks.length}
      itemSize={200}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
};
```

### 디바운싱

lodash의 debounce를 사용하여 검색 입력을 최적화합니다.

```javascript
import { useCallback } from 'react';
import { debounce } from 'lodash';

export const FeedbackSearch = () => {
  const { fetchFeedbacks } = useFeedbackStore();

  const debouncedSearch = useCallback(
    debounce((query) => {
      fetchFeedbacks({ search: query });
    }, 500),
    []
  );

  return (
    <input
      type="text"
      placeholder="피드백 검색..."
      onChange={(e) => debouncedSearch(e.target.value)}
    />
  );
};
```

---

## 에러 처리 및 복구

### 에러 타입

네트워크 에러는 인터넷 연결 끊김, 서버 응답 없음, 타임아웃을 포함합니다.
인증 에러는 401 Unauthorized (토큰 만료), 403 Forbidden (권한 없음)을 포함합니다.
검증 에러는 400 Bad Request (잘못된 요청), 422 Unprocessable Entity (검증 실패)를 포함합니다.
서버 에러는 500 Internal Server Error, 503 Service Unavailable을 포함합니다.

### 에러 처리 전략

apiClient Interceptor로 401 에러 시 토큰 갱신을 시도하고, 네트워크 에러 시 연결 확인 메시지를 표시합니다.

```javascript
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        await authStore.getState().refreshToken();
        return apiClient(originalRequest);
      } catch (refreshError) {
        authStore.getState().logout();
        return Promise.reject(refreshError);
      }
    }

    if (!error.response) {
      toast.error('네트워크 연결을 확인해주세요');
    }

    return Promise.reject(error);
  }
);
```

### 재시도 로직

Exponential Backoff로 실패 시 지수적으로 대기 시간을 증가시킵니다.

```javascript
const retryWithBackoff = async (fn, maxRetries = 3, delay = 1000) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;

      const waitTime = delay * Math.pow(2, i);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
};
```

---

## 베스트 프랙티스

### 코드 구조

```
src/
├── components/
│   └── feedback/
│       ├── FeedbackModal.jsx
│       ├── FeedbackEditModal.jsx
│       ├── FeedbackCard.jsx
│       ├── FeedbackFilters.jsx
│       ├── StarRating.jsx
│       └── index.js
├── pages/
│   └── FeedbackListPage.jsx
├── stores/
│   └── feedbackStore.js
├── services/
│   ├── apiClient.js
│   └── feedbackService.js
├── hooks/
│   └── useFeedbackPolling.js
└── utils/
    └── dateUtils.js
```

### 네이밍 컨벤션

컴포넌트는 PascalCase (FeedbackModal, StarRating)를 사용하고, 함수는 camelCase (createFeedback, handleSubmit)를 사용합니다.
상수는 UPPER_SNAKE_CASE (MAX_COMMENT_LENGTH)를 사용하며, 파일은 컴포넌트는 PascalCase, 유틸리티는 camelCase를 사용합니다.

### 접근성

ARIA 속성을 사용하여 스크린 리더 지원을 강화합니다.

```javascript
<button
  onClick={handleClick}
  aria-label="피드백 삭제"
  aria-describedby="delete-description"
>
  🗑️
</button>
```

키보드 네비게이션을 지원하여 키보드만으로도 모든 기능을 사용할 수 있게 합니다.

```javascript
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick();
    }
  }}
>
  클릭 가능한 요소
</div>
```

---

## 향후 개선사항

### 단기 개선 (1-3개월)

피드백 템플릿은 자주 사용하는 피드백 템플릿을 저장하고 재사용합니다.
피드백 태그는 태그를 추가하여 분류 및 검색을 개선합니다.
피드백 통계 대시보드는 시각화된 통계 대시보드를 제공하며, 피드백 알림은 새로운 응답이나 댓글에 대한 알림을 제공합니다.

### 중기 개선 (3-6개월)

AI 기반 피드백 분석은 감정 분석 및 인사이트를 제공하고, 피드백 비교 기능은 여러 세션의 피드백을 비교합니다.
피드백 익스포트는 CSV, Excel, PDF 형식으로 내보내기를 지원하며, 피드백 응답 기능은 관리자가 피드백에 응답할 수 있게 합니다.

### 장기 개선 (6-12개월)

다국어 지원은 피드백 시스템의 다국어를 지원하고, 피드백 게임화는 보상 시스템 (포인트, 배지)을 도입합니다.
피드백 커뮤니티는 사용자들이 피드백을 공유하고 토론하며, 음성 피드백은 음성으로 피드백을 작성할 수 있게 합니다.

---

## 체크리스트

### 구현 체크리스트

기본 기능으로 피드백 작성 (평점 + 코멘트), 피드백 목록 조회, 피드백 상세 조회, 피드백 수정, 피드백 삭제, 피드백 통계 조회를 완료했습니다.

상태 관리로 Zustand 스토어 구현, Immer 미들웨어 적용, 낙관적 업데이트, 에러 처리 및 롤백을 완료했습니다.

UI/UX로 피드백 작성 모달, 피드백 수정 모달, 별점 입력 컴포넌트, 피드백 카드 컴포넌트, 필터링 컴포넌트, 페이지네이션을 완료했습니다.

### 배포 전 체크리스트

코드 품질로 ESLint 검사 통과, Prettier 포맷팅 완료, 타입 검사 통과 (PropTypes), 코드 리뷰 완료를 확인합니다.

테스트로 모든 테스트 통과, 테스트 커버리지 70% 이상, 크로스 브라우저 테스트, 모바일 반응형 테스트를 확인합니다.

성능으로 Lighthouse 점수 90 이상, 번들 크기 최적화, 이미지 최적화, API 응답 시간 확인을 검증합니다.

---

## 참고 자료 (References)

### 공식 문서

- [React 공식 문서](https://react.dev/)
- [Zustand 공식 문서](https://docs.pmnd.rs/zustand/getting-started/introduction)
- [React Hook Form 공식 문서](https://react-hook-form.com/)
- [Yup 공식 문서](https://github.com/jquense/yup)
- [Axios 공식 문서](https://axios-http.com/)

### 관련 아티클

- [Optimistic UI Updates in React](https://www.apollographql.com/docs/react/performance/optimistic-ui/)
- [Error Handling in React](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [React Performance Optimization](https://react.dev/learn/render-and-commit)
- [Accessibility in React](https://react.dev/learn/accessibility)

### 내부 문서

- [Dialogym API 명세서](../api/api-specification.md)
- [프론트엔드 아키텍처 문서](./frontend-architecture.md)
- [인증 시스템 설계 문서](./frontend-authentication-security-design.md)
- [컴포넌트 라이브러리 가이드](./component-library-guide.md)

### 도구 및 라이브러리

상태 관리는 Zustand (https://github.com/pmndrs/zustand)와 Immer (https://immerjs.github.io/immer/)를 사용합니다.

폼 관리는 React Hook Form (https://react-hook-form.com/)과 Yup (https://github.com/jquense/yup)을 사용합니다.

HTTP 클라이언트는 Axios (https://axios-http.com/)를 사용하고, UI 라이브러리는 React Hot Toast (https://react-hot-toast.com/)를 사용합니다.

테스트는 Vitest (https://vitest.dev/)와 React Testing Library (https://testing-library.com/react)를 사용하며, 성능은 React Window (https://github.com/bvaughn/react-window)와 Web Vitals (https://github.com/GoogleChrome/web-vitals)를 사용합니다.

---

변경 이력 (Change Log)

| 버전 | 변경 일자 | 작성자 | 주요 변경 내용 |
|------|-----------|--------|----------------|
| v1.0 | 2025.11.02 | 왕택준 | 최초 작성 |
