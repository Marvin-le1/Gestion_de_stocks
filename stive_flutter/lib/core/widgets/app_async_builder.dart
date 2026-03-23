import 'package:flutter/material.dart';

class AppAsyncBuilder<T> extends StatelessWidget {
  const AppAsyncBuilder({
    required this.future,
    required this.builder,
    super.key,
  });

  final Future<T> future;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Aucune donnee'));
        }
        return builder(snapshot.data as T);
      },
    );
  }
}
