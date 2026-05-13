enum ConversationMode { voice, text, write }
enum FriendStatus { pending, paired }
enum MessageRole { ai, user }

class DiaryEntry {
  final int id;
  final String date;
  final String text;
  final ConversationMode mode;

  const DiaryEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.mode,
  });

  DiaryEntry copyWith({
    int? id,
    String? date,
    String? text,
    ConversationMode? mode,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      text: text ?? this.text,
      mode: mode ?? this.mode,
    );
  }
}

class Message {
  final int id;
  final MessageRole role;
  final String text;

  const Message({
    required this.id,
    required this.role,
    required this.text,
  });
}

class Friend {
  final int id;
  final String nickname;
  final String relation;
  final String contact;
  final FriendStatus status;

  const Friend({
    required this.id,
    required this.nickname,
    required this.relation,
    required this.contact,
    required this.status,
  });

  Friend copyWith({
    int? id,
    String? nickname,
    String? relation,
    String? contact,
    FriendStatus? status,
  }) {
    return Friend(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      relation: relation ?? this.relation,
      contact: contact ?? this.contact,
      status: status ?? this.status,
    );
  }
}

class ConversationState {
  final List<Message> messages;
  final bool isActive;

  const ConversationState({
    this.messages = const [],
    this.isActive = false,
  });

  ConversationState copyWith({
    List<Message>? messages,
    bool? isActive,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isActive: isActive ?? this.isActive,
    );
  }
}
