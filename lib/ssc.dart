import 'commands/main.dart';

Future<int> run(List<String> args) => MainCommand().run(args) as Future<int>;
