# web-personal-finances
Personal finances flutter web app

Flutter: 3.29.3

Dart: 3.2.5

Run: `fvm flutter run -d Chrome`

Structure:
lib/
    /feature/
        bloc/
            bloc.dart
            event.dart
            state.dart
        model/
            model.dart
        repository/ (instead of service since its firebase)
            repository.dart
        widget/
            body.dart
            (any required widget related to body)
        screen.dart