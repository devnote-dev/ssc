import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ssc/ssc.dart';

Future<Never> main(List<String> args) async {
  // because Windows...
  for (final (index, arg) in args.indexed) {
    if (arg.contains(' ')) {
      args[index] = '"$arg"';
    }
  }

  try {
    exit(await run(args));
  } on UsageException catch (e) {
    print(e.message);
    exit(1);
  }
}
