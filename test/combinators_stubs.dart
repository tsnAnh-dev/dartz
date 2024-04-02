// Fake enumerators combinators until a Dart 2 compatible version is released

import 'dart:async';

import 'enumerators_stubs.dart';

Enumeration<List<A>> listsOf<A>(Enumeration<A> enumeration) => enumeration.flatMap((a) => Enumeration(() => Stream.fromIterable([[], [a], [a, a], [a, a, a]])));

Enumeration<Map<K, V>> mapsOf<K, V>(Enumeration<K> keys, Enumeration<V> values) {
  List<K> ks = <K>[];
  return keys.flatMap((k) {
    ks.add(k);
    return values.map((v) => ks.fold({}, (acc, k) => acc..[k] = v));
  });
}

final Enumeration<int> ints = Enumeration(() => Stream.fromIterable([-2, -1, 0, 1, 2]));

final Enumeration<String> strings = Enumeration(() => Stream.fromIterable(["", "a", "ab", "abc"]));

final Enumeration<bool> bools = Enumeration(() => Stream.fromIterable([false, true]));

