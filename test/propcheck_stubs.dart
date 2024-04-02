// Fake propcheck until a Dart 2 compatible version is released

import 'dart:async';

import 'package:dart3z/dartz.dart';
import 'package:test/test.dart';

import 'enumerators_stubs.dart';

class QuickCheck {
  QuickCheck({seed = 0, maxSuccesses = 100, maxSize = 100, quiet = false});

  void check(Property property) {
    expect(property.check(), completion(equals(true)));
  }
}

class Property {
  final Function0<Future<bool>> check;
  Property(this.check);
}

Property forall<A>(Enumeration<A> ea, bool property(A x)) => Property(() => ea.forall(property));

Property forall2<A,B>(Enumeration<A> ea, Enumeration<B> eb, bool property(A a, B b)) => Property(() => ea.flatMap((a) => eb.map((b) => property(a, b))).forall((b) => b));

Property forall3<A,B,C>(Enumeration<A> ea, Enumeration<B> eb, Enumeration<C> ec, bool property(A a, B b, C c)) => Property(() => ea.flatMap((a) => eb.flatMap((b) => ec.map((c) => property(a, b, c)))).forall((b) => b));
