import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// --- State Providers for UI state ---
final currentScreenProvider = StateProvider<String>((ref) => 'S1');
final lastConversationModeProvider = StateProvider<ConversationMode>((ref) => ConversationMode.voice);
final selectedDiaryIdProvider = StateProvider<int?>((ref) => null);
final selectedFriendIdProvider = StateProvider<int?>((ref) => null);
final pendingDiaryProvider = StateProvider<DiaryEntry?>((ref) => null);

// --- Notifiers for Complex State ---

// Conversation Notifier
class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier() : super(const ConversationState());

  void startConversation() {
    state = state.copyWith(isActive: true, messages: []);
  }

  void endConversation() {
    state = state.copyWith(isActive: false);
  }

  void addMessage(Message message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }
  
  void clearMessages() {
    state = state.copyWith(messages: []);
  }
}

final conversationProvider = StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});

// Diaries Notifier (Mock Initial Data)
final _initialDiaries = [
  const DiaryEntry(id: 1, date: "2026-05-12", mode: ConversationMode.voice, text: "오늘은 오랜만에 일찍 일어났다. 창문을 열었는데 바람이 생각보다 시원해서 잠깐 멍하니 서 있었다. 별 일 없는 하루였는데, 그게 나쁘지 않았다."),
  const DiaryEntry(id: 2, date: "2026-05-10", mode: ConversationMode.text, text: "엄마랑 또 부딪혔다. 사소한 일인데 왜 매번 이렇게까지 되는지 모르겠다. 방에 들어와서 한참을 누워있었다. 머리가 복잡해서 아무것도 하기 싫었다."),
  const DiaryEntry(id: 3, date: "2026-05-07", mode: ConversationMode.voice, text: "검정고시 책을 펴긴 했는데 한 페이지도 못 봤다. 집중이 안 된다. 그래도 펴긴 했으니까 오늘은 그걸로 됐다고 생각하기로 했다."),
];

class DiariesNotifier extends StateNotifier<List<DiaryEntry>> {
  DiariesNotifier() : super(_initialDiaries);

  void addDiary(DiaryEntry diary) {
    state = [diary, ...state];
  }

  void updateDiary(DiaryEntry diary) {
    state = [
      for (final d in state)
        if (d.id == diary.id) diary else d,
    ];
  }

  void deleteDiary(int id) {
    state = state.where((d) => d.id != id).toList();
  }
  
  void clearAll() {
    state = [];
  }
}

final diariesProvider = StateNotifierProvider<DiariesNotifier, List<DiaryEntry>>((ref) {
  return DiariesNotifier();
});

// Friends Notifier
class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier() : super([]);

  void addFriend(Friend friend) {
    state = [...state, friend];
  }

  void updateFriend(Friend friend) {
    state = [
      for (final f in state)
        if (f.id == friend.id) friend else f,
    ];
  }

  void deleteFriend(int id) {
    state = state.where((f) => f.id != id).toList();
  }
  
  void clearAll() {
    state = [];
  }
}

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  return FriendsNotifier();
});
