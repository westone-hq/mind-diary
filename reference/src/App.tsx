import React, { useState, useEffect, useRef } from 'react';
import { Menu, MoreHorizontal, MessageCircle, BookOpen, Users, Mic, ArrowUp, ArrowLeft, Pause, Play, Keyboard, X, ChevronLeft, ChevronRight, Sprout, PenLine, Plus, ChevronDown, Share2, Bell, FileText, Shield, Trash2, Phone, MessageSquare, MapPin } from 'lucide-react';

// --- Constants ---
const MOCK_AI_RESPONSES = [
  "응, 듣고 있어. 천천히 말해도 돼.",
  "그랬구나. 그때 기분이 어땠어?",
  "음, 그 마음 알 것 같아.",
  "오늘 그런 일이 있었구나.",
  "더 얘기해줄래?"
];

const MOCK_USER_UTTERANCES = [
  "오늘 좀 짜증났어",
  "그냥 별일 없었어",
  "친구랑 좀 다퉜는데",
  "잠을 못 잤어",
  "괜찮은 하루였어"
];

const INITIAL_DIARIES = [
  {
    id: 1,
    date: "2026-05-12",
    mode: "voice",
    text: "오늘은 오랜만에 일찍 일어났다. 창문을 열었는데 바람이 생각보다 시원해서 잠깐 멍하니 서 있었다. 별 일 없는 하루였는데, 그게 나쁘지 않았다."
  },
  {
    id: 2,
    date: "2026-05-10",
    mode: "text",
    text: "엄마랑 또 부딪혔다. 사소한 일인데 왜 매번 이렇게까지 되는지 모르겠다. 방에 들어와서 한참을 누워있었다. 머리가 복잡해서 아무것도 하기 싫었다."
  },
  {
    id: 3,
    date: "2026-05-07",
    mode: "voice",
    text: "검정고시 책을 펴긴 했는데 한 페이지도 못 봤다. 집중이 안 된다. 그래도 펴긴 했으니까 오늘은 그걸로 됐다고 생각하기로 했다."
  },
  {
    id: 4,
    date: "2026-05-04",
    mode: "write",
    text: "친구한테 오랜만에 연락이 왔다. 잘 지내냐는 말에 잘 지낸다고 답했다. 사실 잘 모르겠다. 그래도 누가 안부 물어봐주는 게 좀 좋았다."
  },
  {
    id: 5,
    date: "2026-05-01",
    mode: "text",
    text: "5월이 시작됐다. 시간이 빨리 가는 것 같기도 하고 느린 것 같기도 하다. 오늘은 그냥 하루종일 음악만 들었다."
  }
];

const MOCK_DIARY_TEXTS = [
  "오늘은 하루 종일 마음이 조금 무거웠다. 특별한 일이 있었던 건 아닌데, 그냥 그런 날이었다. 이런 날도 있는 거라고 스스로에게 말해본다.",
  "친구와 있었던 일을 다시 떠올려봤다. 그때는 잘 모르겠던 감정이 이제 조금 정리된다. 완벽하게 풀린 건 아니지만, 그래도 조금은 가벼워졌다.",
  "잠을 못 잔 하루였다. 머리가 복잡할 때마다 잠이 잘 안 온다. 내일은 좀 일찍 누워봐야겠다. 그래도 오늘 이렇게 풀어내고 나니 한결 낫다.",
  "오늘은 그냥 별일 없이 지나갔다. 별일 없는 하루도 괜찮은 하루다. 매일 뭔가 대단한 일이 있어야 하는 건 아니니까.",
  "괜찮은 하루였다. 작은 일이지만 기분이 좋았던 순간이 몇 번 있었다. 그런 순간들을 기억해두고 싶다."
];

// --- Interfaces ---
interface DiaryEntry {
  id: number;
  date: string;
  text: string;
  mode: 'voice' | 'text' | 'write';
}

interface Message {
  role: 'ai' | 'user';
  text: string;
  id: number;
}

interface ConversationState {
  messages: Message[];
  isActive: boolean;
}

interface Friend {
  id: number;
  nickname: string;
  relation: string;
  contact: string;
  status: 'pending' | 'paired';
}

interface NavigateProps {
  navigate: (screenId: string) => void;
  conversation: ConversationState;
  setConversation: React.Dispatch<React.SetStateAction<ConversationState>>;
  diaries: DiaryEntry[];
  setDiaries: React.Dispatch<React.SetStateAction<DiaryEntry[]>>;
  pendingDiary: DiaryEntry | null;
  setPendingDiary: React.Dispatch<React.SetStateAction<DiaryEntry | null>>;
  lastConversationMode: 'voice' | 'text' | 'write';
  setLastConversationMode: (mode: 'voice' | 'text' | 'write') => void;
  selectedDiaryId: number | null;
  setSelectedDiaryId: (id: number | null) => void;
  friends: Friend[];
  setFriends: React.Dispatch<React.SetStateAction<Friend[]>>;
  selectedFriendId: number | null;
  setSelectedFriendId: (id: number | null) => void;
  isDrawerOpen: boolean;
  setIsDrawerOpen: (v: boolean) => void;
  showToast: boolean;
  setShowToast: (v: boolean) => void;
  toastMessage: string;
  setToastMessage: (v: string) => void;
}

// --- Components ---

function GlobalHeader({ navigate, currentScreen, onBack, onMenuOpen, onCrisisOpen }: { navigate: (id: string) => void, currentScreen: string, onBack?: () => void, onMenuOpen?: () => void, onCrisisOpen?: () => void }) {
  const isS2 = currentScreen === 'S2';
  const isS3 = currentScreen === 'S3';
  const isS4 = currentScreen === 'S4';
  const isS6 = currentScreen === 'S6';
  const isS8 = currentScreen === 'S8';
  const showBack = isS2 || isS3 || isS4 || isS6 || isS8;

  return (
    <header className="h-[56px] px-[16px] flex items-center justify-between shrink-0 bg-transparent z-10">
      <div className="w-[44px] h-[44px] flex items-center justify-start">
        {showBack && (
          <button onClick={onBack} aria-label="뒤로가기" className="flex items-center justify-center p-1 -ml-1">
            <ArrowLeft className="w-[24px] h-[24px] text-text-main" />
          </button>
        )}
      </div>
      <div className="flex-1" />
      <div className="flex items-center space-x-[12px]">
        <button onClick={onCrisisOpen} aria-label="도움" className="flex items-center justify-center p-1">
          <Sprout className="w-[24px] h-[24px] text-text-main" />
        </button>
        <button onClick={onMenuOpen} aria-label="메뉴" className="flex items-center justify-center p-1 -mr-1">
          <Menu className="w-[24px] h-[24px] text-text-main" />
        </button>
      </div>
    </header>
  );
}

function GlobalTabBar({ currentScreen, navigate }: { currentScreen: string, navigate: (id: string) => void }) {
  // S1, S2, S3, S4 belong to the first tab (대화/기록흐름)
  const isMessageActive = ['S1', 'S2', 'S3', 'S4'].includes(currentScreen);
  const isBookActive = currentScreen === 'S5';
  const isUsersActive = currentScreen === 'S7';

  // Certain screens hide the tab bar
  if (['S2', 'S3', 'S4'].includes(currentScreen)) return null;

  return (
    <nav className="h-[64px] mb-safe flex items-center justify-around shrink-0 bg-bg-base border-t border-divider">
      <button onClick={() => navigate('S1')} aria-label="대화" className="flex items-center justify-center w-full h-full">
        <MessageCircle className={`w-[24px] h-[24px] ${isMessageActive ? 'text-primary' : 'text-text-faint'}`} />
      </button>
      <button onClick={() => navigate('S5')} aria-label="기록" className="flex items-center justify-center w-full h-full">
        <BookOpen className={`w-[24px] h-[24px] ${isBookActive ? 'text-primary' : 'text-text-faint'}`} />
      </button>
      <button onClick={() => navigate('S7')} aria-label="친구" className="flex items-center justify-center w-full h-full">
        <Users className={`w-[24px] h-[24px] ${isUsersActive ? 'text-primary' : 'text-text-faint'}`} />
      </button>
    </nav>
  );
}

function MessageList({ messages, isWaitingAi, scrollRef }: { messages: Message[], isWaitingAi: boolean, scrollRef: React.RefObject<HTMLDivElement | null> }) {
  return (
    <div 
      ref={scrollRef}
      className="flex-1 overflow-y-auto px-[16px] py-[12px] space-y-[8px]"
    >
      {messages.map((msg) => (
        <div 
          key={msg.id}
          className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
        >
          <div 
            className={`max-w-[75%] p-[12px] px-[16px] rounded-[18px] text-[16px] leading-[1.6] text-text-main ${
              msg.role === 'user' ? 'bg-bg-user' : 'bg-bg-ai'
            }`}
          >
            {msg.text}
          </div>
        </div>
      ))}
      {isWaitingAi && (
        <div className="flex justify-start">
          <div className="bg-bg-ai p-[12px] px-[16px] rounded-[18px] flex items-center space-x-[4px]">
            <div className="w-[6px] h-[6px] bg-text-sub rounded-full animate-dot-pulse" style={{ animationDelay: '0s' }} />
            <div className="w-[6px] h-[6px] bg-text-sub rounded-full animate-dot-pulse" style={{ animationDelay: '0.2s' }} />
            <div className="w-[6px] h-[6px] bg-text-sub rounded-full animate-dot-pulse" style={{ animationDelay: '0.4s' }} />
          </div>
        </div>
      )}
    </div>
  );
}

function EndConfirmSheet({ onConfirm, onCancel, title, primaryLabel }: { onConfirm: () => void, onCancel: () => void, title?: string, primaryLabel?: string }) {
  return (
    <div className="absolute inset-0 z-50 flex flex-col justify-end">
      <div 
        className="absolute inset-0 bg-[#00000040]" 
        onClick={onCancel}
      />
      <div className="relative bg-card-white rounded-t-[18px] px-[24px] py-[24px] animate-in slide-in-from-bottom duration-300">
        <div className="flex flex-col items-center">
          <div className="w-[40px] h-[4px] bg-divider rounded-full mb-[16px]" />
          <h2 className="text-[16px] text-text-main font-medium mb-[16px]">{title || "대화를 끝낼까?"}</h2>
          
          <button 
            onClick={onConfirm}
            className={`w-full h-[52px] ${title?.includes('버릴까') ? 'bg-bg-user' : 'bg-primary'} text-card-white rounded-[18px] text-[16px] font-medium mb-[8px]`}
          >
            {primaryLabel || "끝내고 일기로 정리하기"}
          </button>
          
          <button 
            onClick={onCancel}
            className="w-full h-[52px] bg-transparent text-text-sub rounded-[18px] text-[16px]"
          >
            {title?.includes('버릴까') ? "여기서 마저 정리하기" : "계속 이야기하기"}
          </button>
        </div>
      </div>
    </div>
  );
}

function ConfirmDialog({ onConfirm, onCancel, title, description, confirmLabel }: { onConfirm: () => void, onCancel: () => void, title: string, description: string, confirmLabel: string }) {
  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-6">
      <div className="absolute inset-0 bg-[#00000040]" onClick={onCancel} />
      <div className="relative bg-card-white rounded-[18px] w-full max-w-[320px] p-[24px] flex flex-col items-center">
        <h3 className="text-[16px] text-text-main font-medium mb-[16px]">{title}</h3>
        <p className="text-[14px] text-text-sub text-center leading-[1.6] mb-[24px]">{description}</p>
        <div className="flex w-full space-x-[8px]">
          <button onClick={onCancel} className="flex-1 h-[48px] border border-divider rounded-[18px] text-text-sub text-[14px]">취소</button>
          <button onClick={onConfirm} className="flex-1 h-[48px] bg-bg-user text-card-white rounded-[18px] text-[14px]">{confirmLabel}</button>
        </div>
      </div>
    </div>
  );
}

function CrisisSheet({ isOpen, onClose, setShowToast, setToastMessage }: { isOpen: boolean, onClose: () => void, setShowToast: (v: boolean) => void, setToastMessage: (m: string) => void }) {
  const resources = [
    { icon: <Phone className="w-[24px] h-[24px] text-primary" />, title: "1393", label: "자살예방상담전화", href: "tel:1393" },
    { icon: <Phone className="w-[24px] h-[24px] text-primary" />, title: "1388", label: "청소년상담전화", href: "tel:1388" },
    { icon: <Phone className="w-[24px] h-[24px] text-primary" />, title: "1577-0199", label: "정신건강위기상담", href: "tel:1577-0199" },
    { icon: <MessageSquare className="w-[24px] h-[24px] text-primary" />, title: "109", label: "SOS 문자상담", href: "sms:109" },
    { 
      icon: <MapPin className="w-[24px] h-[24px] text-primary" />, 
      title: "가까운 쉼터", 
      label: "청소년쉼터 찾기", 
      onClick: () => {
        setToastMessage('준비 중이야');
        setShowToast(true);
        setTimeout(() => setShowToast(false), 1500);
      }
    },
  ];

  return (
    <div className={`fixed inset-0 z-[200] flex flex-col justify-end transition-opacity duration-300 ${isOpen ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'}`}>
      <div className="absolute inset-0 bg-[#00000040]" onClick={onClose} />
      
      <div className={`relative bg-card-white rounded-t-[18px] w-full max-w-[375px] mx-auto px-[16px] pt-[12px] pb-[24px] transition-transform duration-200 ease-out ${isOpen ? 'translate-y-0' : 'translate-y-full'}`}>
        <div className="flex flex-col items-center mb-[16px]">
          <div className="w-[40px] h-[4px] bg-divider rounded-full" />
        </div>
        
        <div className="px-[8px] mb-[16px]">
          <h3 className="text-[16px] text-text-main font-medium">지금 누군가와 이야기하고 싶다면</h3>
        </div>
        
        <div className="space-y-[8px]">
          {resources.map((res, i) => (
            res.href ? (
              <a 
                key={i}
                href={res.href}
                className="flex items-center h-[64px] px-[16px] border border-divider rounded-[18px] bg-card-white active:bg-divider/10 transition-colors"
                onClick={(e) => {
                  // Standard behavior for tel/sms links
                }}
              >
                <div className="w-[40px] flex justify-center shrink-0">
                  {res.icon}
                </div>
                <div className="ml-[12px] flex flex-col items-start">
                  <span className="text-[16px] text-text-main font-medium">{res.title}</span>
                  <span className="text-[13px] text-text-sub">{res.label}</span>
                </div>
              </a>
            ) : (
              <button 
                key={i}
                onClick={res.onClick}
                className="flex items-center h-[64px] px-[16px] border border-divider rounded-[18px] bg-card-white w-full text-left active:bg-divider/10 transition-colors"
              >
                <div className="w-[40px] flex justify-center shrink-0">
                  {res.icon}
                </div>
                <div className="ml-[12px] flex flex-col items-start">
                  <span className="text-[16px] text-text-main font-medium">{res.title}</span>
                  <span className="text-[13px] text-text-sub">{res.label}</span>
                </div>
              </button>
            )
          ))}
        </div>
      </div>
    </div>
  );
}

function Drawer({ isOpen, onClose, navigate, setToastMessage, setShowToast, setShowEraseDialog1 }: { isOpen: boolean, onClose: () => void, navigate: (id: string) => void, setToastMessage: (m: string) => void, setShowToast: (v: boolean) => void, setShowEraseDialog1: (v: boolean) => void }) {
  const handleItemClick = (action: 'S7' | 'toast') => {
    if (action === 'S7') {
      onClose();
      navigate('S7');
    } else {
      setToastMessage('준비 중이야');
      setShowToast(true);
      setTimeout(() => setShowToast(false), 1500);
    }
  };

  return (
    <div 
      className={`fixed inset-0 z-[100] flex transition-opacity duration-300 ${isOpen ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'}`}
    >
      <div className="absolute inset-0 bg-[#00000040]" onClick={onClose} />
      
      <div 
        className={`relative w-[75%] h-full bg-[#F2EEE5] border-r border-divider flex flex-col transition-transform duration-200 ease-out ${isOpen ? 'translate-x-0' : '-translate-x-full'}`}
      >
        <div className="h-[96px] px-[24px] flex flex-col justify-end pb-[16px]">
          <h2 className="text-[18px] text-text-main font-medium">마음일기 사용자</h2>
        </div>
        
        <div className="h-[1px] bg-divider w-full" />
        
        <div className="flex flex-col">
          <button 
            onClick={() => handleItemClick('S7')}
            className="h-[56px] px-[24px] flex items-center space-x-[16px] active:bg-divider/10"
          >
            <Users className="w-[20px] h-[20px] text-text-sub" />
            <span className="text-[16px] text-text-main">친구 관리</span>
          </button>
          
          <button 
            onClick={() => handleItemClick('toast')}
            className="h-[56px] px-[24px] flex items-center space-x-[16px] active:bg-divider/10"
          >
            <Bell className="w-[20px] h-[20px] text-text-sub" />
            <span className="text-[16px] text-text-main">알림</span>
          </button>
          
          <button 
            onClick={() => handleItemClick('toast')}
            className="h-[56px] px-[24px] flex items-center space-x-[16px] active:bg-divider/10"
          >
            <FileText className="w-[20px] h-[20px] text-text-sub" />
            <span className="text-[16px] text-text-main">약관</span>
          </button>
          
          <button 
            onClick={() => handleItemClick('toast')}
            className="h-[56px] px-[24px] flex items-center space-x-[16px] active:bg-divider/10"
          >
            <Shield className="w-[20px] h-[20px] text-text-sub" />
            <span className="text-[16px] text-text-main">개인정보 처리방침</span>
          </button>
          
          <div className="h-[1px] bg-divider mx-[24px]" />
          
          <button 
            onClick={() => {
              setShowEraseDialog1(true);
            }}
            className="h-[56px] px-[24px] flex items-center space-x-[16px] active:bg-divider/10"
          >
            <Trash2 className="w-[20px] h-[20px] text-[#E5C1C5]" />
            <span className="text-[16px] text-[#E5C1C5]">모든 흔적 지우기</span>
          </button>
        </div>
        
        <div className="flex-1" />
      </div>
    </div>
  );
}

function S1({ navigate, conversation, setConversation }: NavigateProps) {
  const [inputText, setInputText] = useState('');
  const hasInput = inputText.trim().length > 0;

  const handleAction = () => {
    // Start session if not already active
    if (!conversation.isActive) {
      setConversation({ messages: [], isActive: true });
    }

    if (hasInput) {
      console.log('User input:', inputText);
      // In a real app, we would push the first message here
      navigate('S3');
    } else {
      navigate('S2');
    }
  };

  return (
    <div className="flex-1 flex flex-col relative leading-[1.6]">
      <div className="flex-1 flex flex-col pt-[40%] items-center">
        <p className="text-text-faint text-[16px]">오늘 하루 어땠어?</p>
      </div>

      <div className="mx-[16px] mb-[8px] flex flex-row items-center">
        <input
          type="text"
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="메시지 입력"
          className="h-[48px] flex-1 rounded-[18px] bg-card-white border border-divider px-[16px] text-text-main text-[16px] placeholder:text-text-faint outline-none focus:outline-none focus:ring-0"
        />
        <button
          onClick={handleAction}
          className="ml-[8px] w-[48px] h-[48px] rounded-[24px] bg-primary flex items-center justify-center shrink-0"
          aria-label={hasInput ? "전송" : "음성 입력"}
        >
          {hasInput ? <ArrowUp className="w-[24px] h-[24px] text-card-white" /> : <Mic className="w-[24px] h-[24px] text-card-white" />}
        </button>
      </div>
    </div>
  );
}

function S2({ navigate, conversation, setConversation, showExitSheet, setShowExitSheet, setLastConversationMode }: NavigateProps & { showExitSheet: boolean, setShowExitSheet: (v: boolean) => void }) {
  const [isPaused, setIsPaused] = useState(false);
  const [isWaitingAi, setIsWaitingAi] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const [userMsgCount, setUserMsgCount] = useState(0);

  // Initialize session if entering from somewhere else
  useEffect(() => {
    setLastConversationMode('voice');
    if (!conversation.isActive) {
      setConversation({ messages: [], isActive: true });
    }
  }, []); // Only once on mount

  // Auto-scroll to bottom
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [conversation.messages, isWaitingAi]);

  // Handle mock utterance
  const addMockUtterance = () => {
    if (isWaitingAi) return;

    const userText = MOCK_USER_UTTERANCES[userMsgCount % MOCK_USER_UTTERANCES.length];
    const userMessage: Message = { role: 'user', text: userText, id: Date.now() };
    
    setConversation(prev => ({
      ...prev,
      messages: [...prev.messages, userMessage]
    }));
    setUserMsgCount(prev => prev + 1);
    setIsWaitingAi(true);

    // AI Delay
    setTimeout(() => {
      const aiText = MOCK_AI_RESPONSES[userMsgCount % MOCK_AI_RESPONSES.length];
      const aiMessage: Message = { role: 'ai', text: aiText, id: Date.now() + 1 };
      
      setConversation(prev => ({
        ...prev,
        messages: [...prev.messages, aiMessage]
      }));
      setIsWaitingAi(false);
    }, 800);
  };

  return (
    <div className="flex-1 flex flex-col relative overflow-hidden">
      {/* Mock logic header button */}
      <button 
        onClick={addMockUtterance}
        className="self-end text-[12px] text-text-faint px-[16px] py-[8px] focus:outline-none"
      >
        [테스트] 사용자 발화 추가
      </button>

      {/* 채팅 영역 */}
      <MessageList messages={conversation.messages} isWaitingAi={isWaitingAi} scrollRef={scrollRef} />

      {/* Wave Indicator Area */}
      <div className="h-[120px] shrink-0 flex flex-col items-center justify-center">
        <div className="flex items-center justify-center space-x-[6px]">
          {[0, 1, 2, 3, 4].map((i) => (
            <div 
              key={i}
              className={`w-[4px] rounded-[2px] transition-colors duration-300 ${
                isWaitingAi ? 'bg-bg-user' : 'bg-primary'
              } ${!isPaused ? 'animate-wave' : ''}`}
              style={{
                animationDelay: `${[0, 0.15, 0.3, 0.15, 0][i]}s`
              }}
            />
          ))}
        </div>
        <p className="mt-[12px] text-[14px] text-text-sub">
          {isWaitingAi ? "잠깐만" : "듣고 있어"}
        </p>
      </div>

      {/* Bottom Control Bar */}
      <div className="h-[64px] bg-bg-base border-t border-divider flex items-center justify-around shrink-0">
        <button 
          onClick={() => setIsPaused(!isPaused)} 
          className="w-[48px] h-[48px] flex items-center justify-center text-text-sub"
        >
          {isPaused ? <Play className="w-[24px] h-[24px]" /> : <Pause className="w-[24px] h-[24px]" />}
        </button>
        <button 
          onClick={() => navigate('S3')} 
          className="w-[48px] h-[48px] flex items-center justify-center text-text-sub"
        >
          <Keyboard className="w-[24px] h-[24px]" />
        </button>
        <button 
          onClick={() => setShowExitSheet(true)} 
          className="w-[48px] h-[48px] flex items-center justify-center text-bg-user"
        >
          <X className="w-[24px] h-[24px]" />
        </button>
      </div>

      {/* Bottom Sheet Overlay */}
      {showExitSheet && (
        <EndConfirmSheet 
          onConfirm={() => {
            setConversation(prev => ({ ...prev, isActive: false }));
            setShowExitSheet(false);
            navigate('S4');
          }}
          onCancel={() => setShowExitSheet(false)}
        />
      )}
    </div>
  );
}

function S3({ navigate, conversation, setConversation, showExitSheet, setShowExitSheet, setLastConversationMode }: NavigateProps & { showExitSheet: boolean, setShowExitSheet: (v: boolean) => void }) {
  const [inputText, setInputText] = useState('');
  const [isWaitingAi, setIsWaitingAi] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Initialize session
  useEffect(() => {
    setLastConversationMode('text');
    if (!conversation.isActive) {
      setConversation({ messages: [], isActive: true });
    }
  }, []);

  // Auto-scroll
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [conversation.messages, isWaitingAi]);

  // Adjust textarea height
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = '48px';
      const scrollHeight = textareaRef.current.scrollHeight;
      textareaRef.current.style.height = `${Math.min(Math.max(scrollHeight, 48), 120)}px`;
    }
  }, [inputText]);

  const handleSend = () => {
    const trimmed = inputText.trim();
    if (!trimmed || isWaitingAi) return;

    const userMessage: Message = { role: 'user', text: trimmed, id: Date.now() };
    const userCount = conversation.messages.filter(m => m.role === 'user').length;

    setConversation(prev => ({
      ...prev,
      messages: [...prev.messages, userMessage]
    }));
    setInputText('');
    setIsWaitingAi(true);

    setTimeout(() => {
      const aiText = MOCK_AI_RESPONSES[userCount % MOCK_AI_RESPONSES.length];
      const aiMessage: Message = { role: 'ai', text: aiText, id: Date.now() + 1 };
      
      setConversation(prev => ({
        ...prev,
        messages: [...prev.messages, aiMessage]
      }));
      setIsWaitingAi(false);
    }, 800);
  };

  return (
    <div className="flex-1 flex flex-col relative overflow-hidden">
      {/* 채팅 영역 */}
      <MessageList messages={conversation.messages} isWaitingAi={isWaitingAi} scrollRef={scrollRef} />

      {/* 하단 입력바 */}
      <div className="bg-bg-base border-t border-divider px-[16px] py-[8px] flex items-center shrink-0 min-h-[64px]">
        <textarea
          ref={textareaRef}
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="메시지 입력"
          className="flex-1 bg-card-white border border-divider rounded-[18px] px-[16px] py-[12px] text-[16px] text-text-main placeholder:text-text-faint outline-none resize-none overflow-y-auto leading-[1.4] no-scrollbar"
          rows={1}
        />
        <div className="ml-[8px] shrink-0">
          {inputText.trim().length > 0 ? (
            <button
              onClick={handleSend}
              className="w-[48px] h-[48px] rounded-full bg-primary flex items-center justify-center"
              aria-label="전송"
            >
              <ArrowUp className="w-[24px] h-[24px] text-card-white" />
            </button>
          ) : (
            <button
              onClick={() => navigate('S2')}
              className="w-[48px] h-[48px] rounded-full flex items-center justify-center text-text-sub"
              aria-label="음성 모드"
            >
              <Mic className="w-[24px] h-[24px]" />
            </button>
          )}
        </div>
      </div>

      {/* Bottom Sheet Overlay */}
      {showExitSheet && (
        <EndConfirmSheet 
          onConfirm={() => {
            setConversation(prev => ({ ...prev, isActive: false }));
            setShowExitSheet(false);
            navigate('S4');
          }}
          onCancel={() => setShowExitSheet(false)}
        />
      )}
    </div>
  );
}

function S5({ navigate, diaries, setSelectedDiaryId }: NavigateProps) {
  const [viewMonth, setViewMonth] = useState({ 
    year: new Date().getFullYear(), 
    month: new Date().getMonth() + 1 
  });

  const handlePrevMonth = () => {
    setViewMonth(prev => {
      if (prev.month === 1) return { year: prev.year - 1, month: 12 };
      return { year: prev.year, month: prev.month - 1 };
    });
  };

  const handleNextMonth = () => {
    setViewMonth(prev => {
      if (prev.month === 12) return { year: prev.year + 1, month: 1 };
      return { year: prev.year, month: prev.month + 1 };
    });
  };

  const getDaysInMonth = (year: number, month: number) => new Date(year, month, 0).getDate();
  const getStartDayOfMonth = (year: number, month: number) => new Date(year, month - 1, 1).getDay();

  const formatDate = (year: number, month: number, day: number) => {
    return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  };

  const todayStr = formatDate(new Date().getFullYear(), new Date().getMonth() + 1, new Date().getDate());

  const days = [];
  const startDay = getStartDayOfMonth(viewMonth.year, viewMonth.month);
  const totalDays = getDaysInMonth(viewMonth.year, viewMonth.month);
  
  // Previous month padding
  const prevMonth = viewMonth.month === 1 ? 12 : viewMonth.month - 1;
  const prevYear = viewMonth.month === 1 ? viewMonth.year - 1 : viewMonth.year;
  const prevMonthTotalDays = getDaysInMonth(prevYear, prevMonth);
  for (let i = startDay - 1; i >= 0; i--) {
    days.push({ day: prevMonthTotalDays - i, month: prevMonth, year: prevYear, current: false });
  }

  // Current month days
  for (let i = 1; i <= totalDays; i++) {
    days.push({ day: i, month: viewMonth.month, year: viewMonth.year, current: true });
  }

  // Next month padding (up to 42 cells)
  const nextMonth = viewMonth.month === 12 ? 1 : viewMonth.month + 1;
  const nextYear = viewMonth.month === 12 ? viewMonth.year + 1 : viewMonth.year;
  const remaining = 42 - days.length;
  for (let i = 1; i <= remaining; i++) {
    days.push({ day: i, month: nextMonth, year: nextYear, current: false });
  }

  const diaryMap = diaries.reduce((acc, diary) => {
    acc[diary.date] = diary.id;
    return acc;
  }, {} as Record<string, number>);

  return (
    <div className="flex-1 flex flex-col bg-bg-base overflow-y-auto no-scrollbar">
      {/* Month Navigation */}
      <div className="px-[16px] py-[16px] flex items-center justify-center space-x-[16px]">
        <button onClick={handlePrevMonth} className="p-1">
          <ChevronLeft className="w-[24px] h-[24px] text-text-sub" />
        </button>
        <h2 className="text-[18px] text-text-main font-medium">{viewMonth.year}년 {viewMonth.month}월</h2>
        <button onClick={handleNextMonth} className="p-1">
          <ChevronRight className="w-[24px] h-[24px] text-text-sub" />
        </button>
      </div>

      {/* Calendar Grid */}
      <div className="px-[16px]">
        <div className="grid grid-cols-7 mb-[8px]">
          {['일', '월', '화', '수', '목', '금', '토'].map((d, i) => (
            <div key={d} className={`text-[12px] text-center font-medium ${i === 0 ? 'text-[#E5C1C5]' : i === 6 ? 'text-primary' : 'text-text-faint'}`}>
              {d}
            </div>
          ))}
        </div>
        <div className="grid grid-cols-7">
          {days.map((d, i) => {
            const dateStr = formatDate(d.year, d.month, d.day);
            const hasDiary = d.current && diaryMap[dateStr];
            const isToday = dateStr === todayStr;

            return (
              <button
                key={i}
                disabled={!d.current || !hasDiary}
                onClick={() => {
                  if (hasDiary) {
                    setSelectedDiaryId(diaryMap[dateStr]);
                    navigate('S6');
                  }
                }}
                className={`aspect-square p-[4px] relative flex flex-col items-center justify-center focus:outline-none`}
              >
                {isToday && (
                  <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[32px] h-[32px] bg-[#C3E2DD80] rounded-full z-0" />
                )}
                <span className={`text-[14px] z-10 ${d.current ? 'text-text-main font-medium' : 'text-text-faint'}`}>
                  {d.day}
                </span>
                <div className="h-[14px] mt-[4px]">
                  {hasDiary && <Sprout className="w-[10px] h-[10px] text-primary" />}
                </div>
              </button>
            );
          })}
        </div>
      </div>

      <div className="mx-[16px] h-[1px] bg-divider my-[16px]" />

      {/* Recent Diary List */}
      <div className="px-[16px] pb-[24px]">
        {diaries.length > 0 ? (
          <div className="space-y-[12px]">
            {diaries.map(diary => {
              const d = new Date(diary.date);
              const dateText = `${d.getMonth() + 1}월 ${d.getDate()}일`;
              const preview = diary.text.slice(0, 50) + (diary.text.length > 50 ? "..." : "");
              
              return (
                <button
                  key={diary.id}
                  onClick={() => {
                    setSelectedDiaryId(diary.id);
                    navigate('S6');
                  }}
                  className="w-full bg-card-white rounded-[18px] p-[16px] text-left flex flex-col"
                >
                  <span className="text-[14px] text-text-sub">{dateText}</span>
                  <p className="mt-[4px] text-[14px] text-text-main line-clamp-2 leading-[1.5]">
                    {preview}
                  </p>
                </button>
              );
            })}
          </div>
        ) : (
          <div className="py-[32px] flex justify-center">
            <p className="text-[14px] text-text-sub">아직 일기가 없어</p>
          </div>
        )}
      </div>
    </div>
  );
}

function S4({ navigate, conversation, setConversation, diaries, setDiaries, pendingDiary, setPendingDiary, lastConversationMode, showExitSheet, setShowExitSheet }: NavigateProps & { showExitSheet: boolean, setShowExitSheet: (v: boolean) => void }) {
  const [isConverting, setIsConverting] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [editStartText, setEditStartText] = useState('');
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [showToast, setShowToast] = useState(false);

  useEffect(() => {
    // Generate pending diary on mount
    const formatDate = (date: Date) => {
      const y = date.getFullYear();
      const m = String(date.getMonth() + 1).padStart(2, '0');
      const d = String(date.getDate()).padStart(2, '0');
      return `${y}-${m}-${d}`;
    };

    const conversationLength = conversation.messages.length;
    const mockText = conversationLength === 0 
      ? MOCK_DIARY_TEXTS[0] 
      : MOCK_DIARY_TEXTS[conversationLength % MOCK_DIARY_TEXTS.length];

    setPendingDiary({
      id: Date.now(),
      date: formatDate(new Date()),
      mode: lastConversationMode,
      text: mockText
    });

    setConversation(prev => ({ ...prev, isActive: false }));

    const timer = setTimeout(() => {
      setIsConverting(false);
    }, 1200);

    return () => clearTimeout(timer);
  }, []);

  const handleSave = () => {
    if (!pendingDiary) return;
    setDiaries(prev => [pendingDiary, ...prev]);
    // Clear conversation only on save/delete completion
    setConversation({ messages: [], isActive: false });
    setShowToast(true);
    setTimeout(() => {
      setShowToast(false);
      navigate('S1');
      setPendingDiary(null);
    }, 1500);
  };

  const handleDelete = () => {
    setConversation({ messages: [], isActive: false });
    setPendingDiary(null);
    navigate('S1');
  };

  const formattedDateString = (dateStr: string) => {
    if (!dateStr) return "";
    const date = new Date(dateStr);
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const dayNames = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    const day = dayNames[date.getDay()];
    return `${m}월 ${d}일 ${day}`;
  };

  return (
    <div className="flex-1 flex flex-col relative overflow-hidden">
      <div className="py-[16px] flex justify-center">
        <p className="text-[14px] text-text-sub">{formattedDateString(pendingDiary?.date || "")}</p>
      </div>

      <div className="flex-1 px-[16px] overflow-y-auto">
        <div className="bg-card-white rounded-[18px] p-[24px] min-h-[200px]">
          {isConverting ? (
            <div className="space-y-[12px] animate-pulse-slow">
              <div className="h-[14px] w-full bg-divider rounded-[8px]" />
              <div className="h-[14px] w-[80%] bg-divider rounded-[8px]" />
              <div className="h-[14px] w-[90%] bg-divider rounded-[8px]" />
              <div className="h-[14px] w-[60%] bg-divider rounded-[8px]" />
            </div>
          ) : isEditing ? (
            <textarea
              value={pendingDiary?.text || ""}
              onChange={(e) => setPendingDiary(prev => prev ? { ...prev, text: e.target.value } : null)}
              className="w-full min-h-[200px] text-[16px] text-text-main leading-[1.7] outline-none resize-none bg-transparent"
              autoFocus
            />
          ) : (
            <p className="text-[16px] text-text-main leading-[1.7] select-text">
              {pendingDiary?.text}
            </p>
          )}
        </div>
      </div>

      <div className="p-[16px] pt-[8px] pb-[16px] space-y-[16px]">
        <button
          disabled={isConverting}
          onClick={handleSave}
          className={`w-full h-[52px] rounded-[18px] text-[16px] font-medium transition-colors ${
            isConverting ? 'bg-divider text-text-faint' : 'bg-primary text-card-white'
          }`}
        >
          저장하기
        </button>

        {!isEditing ? (
          <div className="flex justify-center space-x-[32px]">
            <button 
              disabled={isConverting}
              onClick={() => { setIsEditing(true); setEditStartText(pendingDiary?.text || ''); }}
              className={`text-[14px] ${isConverting ? 'text-text-faint' : 'text-text-sub'}`}
            >
              수정
            </button>
            <button 
              disabled={isConverting}
              onClick={() => setShowDeleteDialog(true)}
              className={`text-[14px] ${isConverting ? 'text-text-faint' : 'text-text-sub'}`}
            >
              삭제
            </button>
          </div>
        ) : (
          <div className="flex justify-center">
            <button 
              onClick={() => { setIsEditing(false); setPendingDiary(prev => prev ? { ...prev, text: editStartText } : null); }}
              className="text-[14px] text-text-sub"
            >
              되돌리기
            </button>
          </div>
        )}
      </div>

      {showToast && (
        <div className="fixed bottom-[64px] left-1/2 -translate-x-1/2 z-[100] bg-text-main text-card-white px-[20px] py-[12px] rounded-[18px] text-[14px] animate-toast">
          저장됐어
        </div>
      )}

      {showDeleteDialog && (
        <ConfirmDialog 
          title="이 일기를 삭제할까?"
          description="지금 변환된 내용이 사라져. 대화는 다시 시작할 수 있어."
          confirmLabel="삭제"
          onConfirm={handleDelete}
          onCancel={() => setShowDeleteDialog(false)}
        />
      )}

      {showExitSheet && (
        <EndConfirmSheet 
          title="정리한 일기를 버릴까?"
          primaryLabel="버리고 돌아가기"
          onConfirm={() => {
            setConversation({ messages: [], isActive: false });
            setPendingDiary(null);
            setShowExitSheet(false);
            navigate('S1');
          }}
          onCancel={() => setShowExitSheet(false)}
        />
      )}
    </div>
  );
}

function S6({ navigate, diaries, setDiaries, selectedDiaryId, setSelectedDiaryId, setIsCrisisOpen, isDrawerOpen, setIsDrawerOpen }: NavigateProps & { setIsCrisisOpen: (v: boolean) => void, isDrawerOpen: boolean, setIsDrawerOpen: (v: boolean) => void }) {
  const diary = diaries.find(d => d.id === selectedDiaryId);
  const [isEditing, setIsEditing] = useState(false);
  const [editText, setEditText] = useState('');
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [showCancelDialog, setShowCancelDialog] = useState(false);
  const [showToast, setShowToast] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Initialize edit text
  useEffect(() => {
    if (diary) {
      setEditText(diary.text);
    }
  }, [diary, isEditing]);

  // Adjust textarea height
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = '200px';
      textareaRef.current.style.height = `${textareaRef.current.scrollHeight}px`;
    }
  }, [editText]);

  if (!diary) {
    return (
      <div className="flex-1 flex items-center justify-center p-6 text-text-sub text-[14px]">
        일기를 찾을 수 없어
      </div>
    );
  }

  const handleBack = () => {
    if (isEditing) {
      if (editText.trim() !== diary.text) {
        setShowCancelDialog(true);
      } else {
        setIsEditing(false);
      }
    } else {
      setSelectedDiaryId(null);
      navigate('S5');
    }
  };

  const handleSave = () => {
    if (!editText.trim()) return;
    setDiaries(prev => prev.map(d => d.id === diary.id ? { ...d, text: editText.trim() } : d));
    setIsEditing(false);
    setShowToast(true);
    setTimeout(() => setShowToast(false), 1500);
  };

  const handleDelete = () => {
    setDiaries(prev => prev.filter(d => d.id !== diary.id));
    setSelectedDiaryId(null);
    setShowDeleteDialog(false);
    navigate('S5');
  };

  const formatDateString = (dateStr: string) => {
    const date = new Date(dateStr);
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const dayNames = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
    const day = dayNames[date.getDay()];
    return `${m}월 ${d}일 ${day}`;
  };

  const ModeIcon = () => {
    switch (diary.mode) {
      case 'voice': return <Mic className="w-[14px] h-[14px] text-text-faint" />;
      case 'text': return <MessageCircle className="w-[14px] h-[14px] text-text-faint" />;
      case 'write': return <PenLine className="w-[14px] h-[14px] text-text-faint" />;
      default: return null;
    }
  };

  return (
    <div className="flex-1 flex flex-col relative overflow-hidden bg-bg-base">
      <GlobalHeader 
        navigate={navigate} 
        currentScreen="S6" 
        onBack={handleBack} 
        onMenuOpen={() => {
          if (isCrisisOpen) setIsCrisisOpen(false);
          setIsDrawerOpen(true);
        }}
        onCrisisOpen={() => {
          if (isDrawerOpen) setIsDrawerOpen(false);
          setIsCrisisOpen(true);
        }}
      />

      <div className="px-[16px] py-[24px] flex flex-col items-center shrink-0">
        <h2 className="text-[24px] text-text-main font-medium">{formatDateString(diary.date)}</h2>
        <div className="mt-[8px] flex items-center justify-center h-[14px]">
          <ModeIcon />
        </div>
      </div>

      <div className="flex-1 px-[24px] overflow-y-auto no-scrollbar pb-[24px]">
        {isEditing ? (
          <textarea
            ref={textareaRef}
            value={editText}
            onChange={(e) => setEditText(e.target.value)}
            className="w-full text-[16px] text-text-main leading-[1.7] bg-transparent outline-none resize-none border-none p-0 overflow-y-hidden"
          />
        ) : (
          <p className="text-[16px] text-text-main leading-[1.7] whitespace-pre-wrap select-text">
            {diary.text}
          </p>
        )}
      </div>

      <div className="px-[16px] pt-[8px] pb-[16px] bg-bg-base">
        {!isEditing ? (
          <>
            <div className="h-[1px] bg-divider w-full mb-[16px]" />
            <div className="flex justify-center space-x-[32px]">
              <button 
                onClick={() => setIsEditing(true)}
                className="text-[14px] text-text-sub py-[12px]"
              >
                수정
              </button>
              <button 
                onClick={() => setShowDeleteDialog(true)}
                className="text-[14px] text-text-faint py-[12px]"
              >
                삭제
              </button>
            </div>
          </>
        ) : (
          <button 
            onClick={handleSave}
            className="w-full h-[52px] bg-primary text-card-white rounded-[18px] text-[16px] font-medium"
          >
            저장하기
          </button>
        )}
      </div>

      {showToast && (
        <div className="fixed bottom-[64px] left-1/2 -translate-x-1/2 z-[100] bg-text-main text-card-white px-[20px] py-[12px] rounded-[18px] text-[14px] animate-toast">
          수정됐어
        </div>
      )}

      {showDeleteDialog && (
        <ConfirmDialog 
          title="이 일기를 삭제할까?"
          description="삭제하면 되돌릴 수 없어."
          confirmLabel="삭제"
          onConfirm={handleDelete}
          onCancel={() => setShowDeleteDialog(false)}
        />
      )}

      {showCancelDialog && (
        <ConfirmDialog 
          title="수정한 내용을 버릴까?"
          description="저장하지 않은 내용은 사라져."
          confirmLabel="버리기"
          onConfirm={() => {
            setIsEditing(false);
            setEditText(diary.text);
            setShowCancelDialog(false);
          }}
          onCancel={() => setShowCancelDialog(false)}
        />
      )}
    </div>
  );
}

function S7({ navigate, friends, setFriends, setSelectedFriendId }: NavigateProps) {
  const [showFriendMenuId, setShowFriendMenuId] = useState<number | null>(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [friendToDelete, setFriendToDelete] = useState<number | null>(null);

  const selectedFriend = friends.find(f => f.id === friendToDelete);

  const handleDelete = () => {
    if (friendToDelete !== null) {
      setFriends(prev => prev.filter(f => f.id !== friendToDelete));
      setFriendToDelete(null);
      setShowDeleteDialog(false);
    }
  };

  return (
    <div className="flex-1 flex flex-col bg-bg-base overflow-y-auto no-scrollbar relative">
      {friends.length === 0 ? (
        /* Empty State */
        <div className="flex-1 flex flex-col items-center justify-center -mt-[64px]">
          <p className="text-[14px] text-text-sub">아직 등록한 사람이 없어</p>
          <button 
            onClick={() => {
              setSelectedFriendId(null);
              navigate('S8');
            }}
            className="mt-[24px] w-[160px] h-[48px] border border-primary rounded-[18px] text-[14px] text-primary font-medium"
          >
            추가하기
          </button>
        </div>
      ) : (
        /* Populated State */
        <div className="px-[16px] pt-[16px] flex flex-col flex-1 pb-[24px]">
          <div className="space-y-[12px]">
            {friends.map(friend => (
              <div key={friend.id} className="bg-card-white rounded-[18px] p-[16px] flex items-center justify-between">
                <div className="flex-1 flex flex-col">
                  <span className="text-[16px] text-text-main font-medium">{friend.nickname}</span>
                  <div className="mt-[4px] flex items-center">
                    <span className="text-[14px] text-text-sub">{friend.relation}</span>
                    {friend.status === 'pending' && (
                      <div className="ml-[8px] bg-divider px-[8px] py-[2px] rounded-[12px] text-[11px] text-text-sub">
                        초대 중
                      </div>
                    )}
                  </div>
                </div>
                <button 
                  onClick={() => setShowFriendMenuId(friend.id)}
                  className="w-[44px] h-[44px] flex items-center justify-center -mr-[8px]"
                >
                  <MoreHorizontal className="w-[20px] h-[20px] text-text-faint" />
                </button>
              </div>
            ))}
          </div>

          <div className="mt-[16px] space-y-[16px]">
            {friends.length < 3 ? (
              <button 
                onClick={() => {
                  setSelectedFriendId(null);
                  navigate('S8');
                }}
                className="w-full h-[48px] border border-primary rounded-[18px] flex items-center justify-center space-x-[4px] text-primary"
              >
                <Plus className="w-[16px] h-[16px]" />
                <span className="text-[14px] font-medium">추가하기</span>
              </button>
            ) : (
              <p className="text-center py-[16px] text-[14px] text-text-sub">
                최대 3명까지 등록할 수 있어
              </p>
            )}
          </div>
        </div>
      )}

      {/* Friend Menu Bottom Sheet */}
      {showFriendMenuId !== null && (
        <div className="absolute inset-0 z-50 flex flex-col justify-end">
          <div 
            className="absolute inset-0 bg-[#00000040]" 
            onClick={() => setShowFriendMenuId(null)}
          />
          <div className="relative bg-card-white rounded-t-[18px] px-[16px] py-[16px] animate-in slide-in-from-bottom duration-300">
            <div className="flex flex-col items-center">
              <div className="w-[40px] h-[4px] bg-divider rounded-full mb-[16px]" />
              
              <button 
                onClick={() => {
                  setSelectedFriendId(showFriendMenuId);
                  setShowFriendMenuId(null);
                  navigate('S8');
                }}
                className="w-full h-[56px] px-[16px] flex items-center justify-start text-[16px] text-text-main"
              >
                수정
              </button>
              
              <div className="h-[1px] bg-divider w-full" />
              
              <button 
                onClick={() => {
                  setFriendToDelete(showFriendMenuId);
                  setShowFriendMenuId(null);
                  setShowDeleteDialog(true);
                }}
                className="w-full h-[56px] px-[16px] flex items-center justify-start text-[16px] text-[#E5C1C5]"
              >
                삭제
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Dialog */}
      {showDeleteDialog && (
        <ConfirmDialog 
          title={selectedFriend ? `${selectedFriend.nickname}을(를) 삭제할까?` : "이 친구를 삭제할까?"}
          description="연결이 끊어지고 받은 응원 메시지도 사라져."
          confirmLabel="삭제"
          onConfirm={handleDelete}
          onCancel={() => {
            setShowDeleteDialog(false);
            setFriendToDelete(null);
          }}
        />
      )}
    </div>
  );
}

function S8({ navigate, friends, setFriends, selectedFriendId, setSelectedFriendId, setIsCrisisOpen, isDrawerOpen, setIsDrawerOpen }: NavigateProps & { setIsCrisisOpen: (v: boolean) => void, isDrawerOpen: boolean, setIsDrawerOpen: (v: boolean) => void }) {
  const isEditMode = selectedFriendId !== null;
  const friend = friends.find(f => f.id === selectedFriendId);

  const [step, setStep] = useState<1 | 2>(1);
  const [nickname, setNickname] = useState('');
  const [relation, setRelation] = useState('');
  const [contact, setContact] = useState('');
  const [showRelationSheet, setShowRelationSheet] = useState(false);
  const [pairingCode, setPairingCode] = useState('');
  const [showCancelDialog, setShowCancelDialog] = useState(false);
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  // Initialize values for edit mode
  useEffect(() => {
    if (isEditMode && friend) {
      setNickname(friend.nickname);
      setRelation(friend.relation);
      setContact(friend.contact);
    }
  }, [isEditMode, friend]);

  const generatePairingCode = () => {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  };

  const hasChanges = () => {
    if (!friend) return false;
    return nickname !== friend.nickname || relation !== friend.relation || contact !== friend.contact;
  };

  const handleBack = () => {
    if (step === 2) {
      setStep(1);
    } else if (isEditMode) {
      if (hasChanges()) {
        setShowCancelDialog(true);
      } else {
        setSelectedFriendId(null);
        navigate('S7');
      }
    } else {
      navigate('S7');
    }
  };

  const handlePrimaryAction = () => {
    if (isEditMode) {
      setFriends(prev => prev.map(f => f.id === selectedFriendId ? { ...f, nickname, relation, contact } : f));
      setSelectedFriendId(null);
      setToastMessage('저장됐어');
      setShowToast(true);
      setTimeout(() => {
        setShowToast(false);
        navigate('S7');
      }, 1500);
    } else {
      if (!pairingCode) {
        setPairingCode(generatePairingCode());
      }
      setStep(2);
    }
  };

  const handleFinalize = () => {
    const newFriend: Friend = {
      id: Date.now(),
      nickname,
      relation,
      contact,
      status: 'pending'
    };
    setFriends(prev => [...prev, newFriend]);
    setSelectedFriendId(null);
    navigate('S7');
  };

  const isFormValid = nickname.trim() && relation && contact.trim();

  return (
    <div className="flex-1 flex flex-col relative overflow-hidden bg-bg-base">
      <GlobalHeader 
        navigate={navigate} 
        currentScreen="S8" 
        onBack={handleBack} 
        onMenuOpen={() => {
          if (isCrisisOpen) setIsCrisisOpen(false);
          setIsDrawerOpen(true);
        }}
        onCrisisOpen={() => {
          if (isDrawerOpen) setIsDrawerOpen(false);
          setIsCrisisOpen(true);
        }}
      />

      {step === 1 ? (
        <div className="flex-1 flex flex-col px-[16px] py-[8px] overflow-y-auto no-scrollbar">
          <div className="py-[16px]">
            <h2 className="text-[18px] text-text-main font-medium">
              {isEditMode ? "친구 정보 수정" : "새 친구 추가"}
            </h2>
          </div>

          <div className="mt-[16px] space-y-[20px]">
            {/* Nickname */}
            <div>
              <p className="text-[14px] text-text-sub mb-[8px]">별명</p>
              <input 
                type="text"
                value={nickname}
                onChange={(e) => setNickname(e.target.value)}
                maxLength={10}
                placeholder="어떻게 부를까?"
                className="w-full h-[48px] bg-card-white border border-divider rounded-[18px] px-[16px] text-[16px] text-text-main placeholder:text-text-faint outline-none"
              />
            </div>

            {/* Relation */}
            <div>
              <p className="text-[14px] text-text-sub mb-[8px]">관계</p>
              <button 
                onClick={() => setShowRelationSheet(true)}
                className="w-full h-[48px] bg-card-white border border-divider rounded-[18px] px-[16px] flex items-center justify-between"
              >
                <span className={`text-[16px] ${relation ? 'text-text-main' : 'text-text-faint'}`}>
                  {relation || "선택하기"}
                </span>
                <ChevronDown className="w-[20px] h-[20px] text-text-faint" />
              </button>
            </div>

            {/* Contact */}
            <div>
              <p className="text-[14px] text-text-sub mb-[8px]">연락처</p>
              <input 
                type="tel"
                value={contact}
                onChange={(e) => setContact(e.target.value)}
                placeholder="010-0000-0000"
                className="w-full h-[48px] bg-card-white border border-divider rounded-[18px] px-[16px] text-[16px] text-text-main placeholder:text-text-faint outline-none"
              />
            </div>
          </div>
        </div>
      ) : (
        <div className="flex-1 flex flex-col items-center justify-center px-[16px]">
          <p className="text-[16px] text-text-main">초대 코드가 만들어졌어</p>
          <div className="mt-[48px] flex space-x-[8px]">
            {pairingCode.split('').map((char, i) => (
              <span key={i} className="text-[32px] font-medium text-text-main uppercase">
                {char}
              </span>
            ))}
          </div>
          <p className="mt-[48px] text-[14px] text-text-sub text-center leading-[1.6] px-[24px]">
            상대가 같은 앱에서 이 코드를 입력하면 연결돼.
          </p>
        </div>
      )}

      {/* Action Area */}
      <div className="px-[16px] pb-[16px] pt-[8px] bg-bg-base">
        {step === 1 ? (
          <button
            disabled={!isFormValid}
            onClick={handlePrimaryAction}
            className={`w-full h-[52px] rounded-[18px] text-[16px] font-medium transition-colors ${
              isFormValid ? 'bg-primary text-card-white' : 'bg-divider text-text-faint'
            }`}
          >
            {isEditMode ? "저장하기" : "초대 보내기"}
          </button>
        ) : (
          <div className="flex flex-col space-y-[12px]">
            <button
              onClick={() => {
                setToastMessage('공유 시트가 열려');
                setShowToast(true);
                setTimeout(() => setShowToast(false), 1500);
              }}
              className="w-full h-[52px] bg-primary text-card-white rounded-[18px] text-[16px] font-medium flex items-center justify-center space-x-[8px]"
            >
              <Share2 className="w-[20px] h-[20px]" />
              <span>공유하기</span>
            </button>
            <button
              onClick={handleFinalize}
              className="w-full h-[48px] text-text-sub text-[14px] font-medium"
            >
              다음에 보내기
            </button>
          </div>
        )}
      </div>

      {/* Relation Bottom Sheet */}
      {showRelationSheet && (
        <div className="absolute inset-0 z-50 flex flex-col justify-end">
          <div 
            className="absolute inset-0 bg-[#00000040]" 
            onClick={() => setShowRelationSheet(false)}
          />
          <div className="relative bg-card-white rounded-t-[18px] py-[16px] animate-in slide-in-from-bottom duration-300">
            <div className="flex flex-col items-center">
              <div className="w-[40px] h-[4px] bg-divider rounded-full mb-[16px]" />
              <h3 className="text-[16px] text-text-main font-medium mb-[16px]">관계 선택</h3>
              
              <div className="h-[1px] bg-divider w-full" />
              
              {["가족", "친구", "선생님", "상담사", "기타"].map((item, idx, arr) => (
                <React.Fragment key={item}>
                  <button 
                    onClick={() => {
                      setRelation(item);
                      setShowRelationSheet(false);
                    }}
                    className="w-full h-[56px] px-[24px] flex items-center justify-start text-[16px] text-text-main active:bg-divider/20"
                  >
                    {item}
                  </button>
                  {idx !== arr.length - 1 && <div className="h-[1px] bg-divider w-full" />}
                </React.Fragment>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Toast */}
      {showToast && (
        <div className="fixed bottom-[64px] left-1/2 -translate-x-1/2 z-[100] bg-text-main text-card-white px-[20px] py-[12px] rounded-[18px] text-[14px] animate-toast">
          {toastMessage}
        </div>
      )}

      {/* Cancel Confirmation Dialog */}
      {showCancelDialog && (
        <ConfirmDialog 
          title="수정한 내용을 버릴까?"
          description="저장하지 않은 내용은 사라져."
          confirmLabel="버리기"
          onConfirm={() => {
            setSelectedFriendId(null);
            setShowCancelDialog(false);
            navigate('S7');
          }}
          onCancel={() => setShowCancelDialog(false)}
        />
      )}
    </div>
  );
}

function PlaceholderScreen({ screenId, navigate }: { screenId: string, navigate: (id: string) => void }) {
  return (
    <div className="flex-1 flex items-center justify-center p-6 text-text-sub text-[16px] leading-[1.6]">
      {screenId} (미구현) — <button className="ml-1 underline text-primary" onClick={() => navigate('S1')}>S1으로 돌아가기</button>
    </div>
  );
}

export default function App() {
  const [currentScreen, setCurrentScreen] = useState('S1');
  const [conversation, setConversation] = useState<ConversationState>({
    messages: [],
    isActive: false
  });
  const [diaries, setDiaries] = useState<DiaryEntry[]>(INITIAL_DIARIES);
  const [pendingDiary, setPendingDiary] = useState<DiaryEntry | null>(null);
  const [lastConversationMode, setLastConversationMode] = useState<'voice' | 'text' | 'write'>('voice');
  const [selectedDiaryId, setSelectedDiaryId] = useState<number | null>(null);
  const [friends, setFriends] = useState<Friend[]>([]);
  const [selectedFriendId, setSelectedFriendId] = useState<number | null>(null);
  const [showExitSheet, setShowExitSheet] = useState(false);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [isCrisisOpen, setIsCrisisOpen] = useState(false);
  const [showToast, setShowToast] = useState(false);
  const [toastMessage, setToastMessage] = useState('');
  const [showEraseDialog1, setShowEraseDialog1] = useState(false);
  const [showEraseDialog2, setShowEraseDialog2] = useState(false);

  const handleEraseAll = () => {
    setDiaries([]);
    setFriends([]);
    setConversation({ messages: [], isActive: false });
    setPendingDiary(null);
    setSelectedDiaryId(null);
    setSelectedFriendId(null);
    setShowEraseDialog2(false);
    setIsDrawerOpen(false);
    setToastMessage("모두 지워졌어");
    setShowToast(true);
    setTimeout(() => {
      setShowToast(false);
      setCurrentScreen('S1');
    }, 1500);
  };

  const renderScreen = () => {
    const props = { 
      navigate: setCurrentScreen, 
      conversation, 
      setConversation,
      diaries,
      setDiaries,
      pendingDiary,
      setPendingDiary,
      lastConversationMode,
      setLastConversationMode,
      selectedDiaryId,
      setSelectedDiaryId,
      friends,
      setFriends,
      selectedFriendId,
      setSelectedFriendId,
      showExitSheet,
      setShowExitSheet,
      isDrawerOpen,
      setIsDrawerOpen,
      isCrisisOpen,
      setIsCrisisOpen,
      showToast,
      setShowToast,
      toastMessage,
      setToastMessage
    };
    switch (currentScreen) {
      case 'S1': return <S1 {...props} />;
      case 'S2': return <S2 {...props} />;
      case 'S3': return <S3 {...props} />;
      case 'S4': return <S4 {...props} />;
      case 'S5': return <S5 {...props} />;
      case 'S6': return <S6 {...props} />;
      case 'S7': return <S7 {...props} />;
      case 'S8': return <S8 {...props} />;
      default: return <PlaceholderScreen screenId={currentScreen} {...props} />;
    }
  };

  return (
    <div className="h-[100dvh] w-full max-w-[375px] mx-auto bg-bg-base text-text-main flex flex-col font-sans overflow-hidden border-x border-divider relative">
      {currentScreen !== 'S6' && currentScreen !== 'S8' && (
        <GlobalHeader 
          navigate={setCurrentScreen} 
          currentScreen={currentScreen} 
          onMenuOpen={() => {
            if (isCrisisOpen) setIsCrisisOpen(false);
            setIsDrawerOpen(true);
          }}
          onCrisisOpen={() => {
            if (isDrawerOpen) setIsDrawerOpen(false);
            setIsCrisisOpen(true);
          }}
          onBack={(currentScreen === 'S2' || currentScreen === 'S3' || currentScreen === 'S4') ? () => setShowExitSheet(true) : undefined}
        />
      )}
      {renderScreen()}
      <GlobalTabBar currentScreen={currentScreen} navigate={setCurrentScreen} />
      
      <CrisisSheet 
        isOpen={isCrisisOpen} 
        onClose={() => setIsCrisisOpen(false)}
        setShowToast={setShowToast}
        setToastMessage={setToastMessage}
      />

      <Drawer 
        isOpen={isDrawerOpen} 
        onClose={() => setIsDrawerOpen(false)} 
        navigate={setCurrentScreen}
        setShowToast={setShowToast}
        setToastMessage={setToastMessage}
        setShowEraseDialog1={setShowEraseDialog1}
      />

      {showToast && (
        <div className="fixed bottom-[64px] left-1/2 -translate-x-1/2 z-[150] bg-text-main text-card-white px-[20px] py-[12px] rounded-[18px] text-[14px] animate-toast">
          {toastMessage}
        </div>
      )}

      {showEraseDialog1 && (
        <ConfirmDialog 
          title="정말 모두 지울까?"
          description="일기, 친구 목록을 포함한 모든 기록이 사라져."
          confirmLabel="다음"
          onConfirm={() => {
            setShowEraseDialog1(false);
            setShowEraseDialog2(true);
          }}
          onCancel={() => setShowEraseDialog1(false)}
        />
      )}

      {showEraseDialog2 && (
        <ConfirmDialog 
          title="한 번 더 확인할게"
          description="지우면 되돌릴 수 없어. 진짜 지울까?"
          confirmLabel="지우기"
          onConfirm={handleEraseAll}
          onCancel={() => setShowEraseDialog2(false)}
        />
      )}
    </div>
  );
}



