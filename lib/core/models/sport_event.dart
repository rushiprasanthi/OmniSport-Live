import 'sport_type.dart';

enum EventLifecycleState {
  upcoming, // 'pre'
  live,     // 'in'
  finished; // 'post'

  static EventLifecycleState fromRawState(String raw) {
    switch (raw.toLowerCase()) {
      case 'in':
      case 'live':
        return EventLifecycleState.live;
      case 'post':
      case 'final':
      case 'completed':
        return EventLifecycleState.finished;
      default:
        return EventLifecycleState.upcoming;
    }
  }
}

abstract class SportEvent {
  String get id;
  SportType get sportType;
  String get leagueName;
  String get statusDetail;
  String get state; // 'pre', 'in', 'post'

  bool get isLive => state == 'in';
  bool get isUpcoming => state == 'pre';
  bool get isFinished => state == 'post';

  EventLifecycleState get lifecycleState =>
      EventLifecycleState.fromRawState(state);
}