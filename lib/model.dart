
import 'package:countdown/sync_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Model {
  SyncList<Event> _events;

  Model();

  Future<Null> initialize() async {
    assert (_events == null);
    var prefs = await SharedPreferences.getInstance();

    this._events = SyncList(
      prefsIdentifier: '__',
      prefs: prefs,
      decoder: (json) => Event.fromJson(json)
    );

    assert (_events != null);
  }

  Iterable<Event> get events => _events;

  int get numberOfEvents => _events.length;

  Event eventAt(int index) => _events[index];

  void addEvent(Event e) => _events.add(e);

  void removeEvent(Event e) => _events.remove(e);
}

/// Global access singleton
class Global {
  static final Global _instance = Global._internal();

  factory Global() => _instance;

  Global._internal();

  var quote = Quote();
}

/// A class to aide in parsing from a JSON HTTP GET request into a formatted [toString]
class Quote {
  final String content;
  final String author;

  Quote({this.content = '', this.author = ''});

  Quote.fromJson(Map<String, dynamic> json) : this(
    content: json['contents']['quotes'][0]['quote'],
    author: json['contents']['quotes'][0]['author']
  );

  String get _greeting {
    var hour = DateTime.now().hour;
    print(hour.toString());

    if (hour >=  5 && hour < 12) return 'Have an amazing morning 😀';
    if (hour >= 12 && hour < 19) return 'Have a nice afternoon 🥳';
    if (hour >= 19 || hour <  5) return 'Have a fantastic night 🥱';

    throw Exception('Did not satisfy any condition');
  }

  @override
  String toString() => content.isEmpty ? _greeting : '"$content" — $author';
}

/// In contrast to the [Duration] class, the fields of [NormalizedDuration] are
/// discrete parts of the total remaining time and do not represent the entire
/// duration each
class NormalizedDuration {
  final int days, hours, minutes, seconds;

  NormalizedDuration.custom([this.days = 0, this.hours = 0, this.minutes = 0, this.seconds = 0]);

  NormalizedDuration({@required Duration totalDuration})
      : this.seconds = totalDuration.inSeconds.remainder(Duration.secondsPerMinute),
        this.minutes = totalDuration.inMinutes.remainder(Duration.minutesPerHour),
        this.hours   = totalDuration.inHours.remainder(Duration.hoursPerDay),
        this.days    = totalDuration.inDays;

  /// Formats the duration as a [String]; for example: `42 days 23 hrs 59 mins 00 secs`
  @override
  String toString() => '$days days, $hours hrs, $minutes mins, $seconds secs';
}

class Event implements Comparable<Event> {
  final String   title;
  final DateTime start;
  final DateTime end;
  final Color    color;

  bool get isOver => end.difference(DateTime.now()) <= Duration(seconds: 0);

  NormalizedDuration get timeRemaining => NormalizedDuration(
      totalDuration: DateTime.now().difference(end).abs()
  );

  Event({@required this.title, @required this.end, @required this.color})
      : start = DateTime.now(),
        assert (end != null),
        assert (color != null),
        assert (end.isAfter(DateTime.now()));

  /// Deserialize an [Event] instance from a JSON map
  Event.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        color = Color(json['color'] as int),
        start = DateTime.fromMillisecondsSinceEpoch(json['start'] as int),
        end   = DateTime.fromMillisecondsSinceEpoch(json['end'] as int);

  /// Serialize this instance to a JSON map
  Map<String, dynamic> toJson() => {
    'title' : title,
    'color' : color.value,
    'start' : start.millisecondsSinceEpoch,
    'end'   : end.millisecondsSinceEpoch
  };

  @override
  String toString() => toJson().toString();

  @override
  int compareTo(Event other) => this.end.compareTo(other.end);
}