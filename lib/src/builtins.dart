part of dartz;

// TODO: Monoids over floating point types tend to be law breakers... use with care!

class NumSumMonoid extends Monoid<num> {
  @override num zero() => 0;
  @override num append(num n1, num n2) => n1+n2;
}

final Monoid<num> NumSumMi = NumSumMonoid();

class IntSumMonoid extends Monoid<int> {
  @override int zero() => 0;
  @override int append(int n1, int n2) => n1+n2;
}

final Monoid<int> IntSumMi = IntSumMonoid();


class NumProductMonoid extends Monoid<num> {
  @override num zero() => 1;
  @override num append(num n1, num n2) => n1*n2;
}

final Monoid<num> NumProductMi = NumProductMonoid();

class NumMaxSemigroup extends Semigroup<num> {
  @override num append(num n1, num n2) => n1 > n2 ? n1 : n2;
}

final Semigroup<num> NumMaxSi = NumMaxSemigroup();

class NumMinSemigroup extends Semigroup<num> {
  @override num append(num n1, num n2) => n1 < n2 ? n1 : n2;
}

final Semigroup<num> NumMinSi = NumMinSemigroup();

class StringMonoid extends Monoid<String> {
  @override String zero() => "";
  @override String append(String s1, String s2) => s1 + s2;
}

final Monoid<String> StringMi = StringMonoid();

class BooleanDisjunctionMonoid extends Monoid<bool> {
  @override bool zero() => false;
  @override bool append(bool b1, bool b2) => b1 || b2;
}

final Monoid<bool> BoolOrMi = BooleanDisjunctionMonoid();

class BooleanConjunctionMonoid extends Monoid<bool> {
  @override bool zero() => true;
  @override bool append(bool b1, bool b2) => b1 && b2;
}

final Monoid<bool> BoolAndMi = BooleanConjunctionMonoid();

final Order<num> NumOrder = ComparableOrder<num>();

class _IntOrder extends Order<int> {
  @override  Ordering order(int i1, int i2) => i1 < i2 ? Ordering.LT : (i1 > i2 ? Ordering.GT : Ordering.EQ);
}

final Order<int> IntOrder = _IntOrder();

final Order<double> DoubleOrder = ComparableOrder<double>();

final Order<String> StringOrder = ComparableOrder<String>();

@pragma('dart2js:as:trust')
A cast<A>(dynamic a) {
  return a as A;
}

class IteratorEq<A> extends Eq<Iterator<A>> {
  final Eq<A> _aEq;

  IteratorEq(this._aEq);

  @override bool eq(Iterator<A> i1, Iterator<A> i2) {
    while(true) {
      final i1Next = i1.moveNext();
      final i2Next = i2.moveNext();
      if (i1Next != i2Next) {
        return false;
      } else if (i1Next) {
        if (_aEq.neq(i1.current, i2.current)) {
          return false;
        }
      } else {
        return true;
      }
    }
  }
}

final Eq<Iterator<dynamic>> ObjectIteratorEq = IteratorEq(ObjectEq);
Eq<Iterator<A>> iteratorEq<A>(Eq<A> aEq) => IteratorEq(aEq);
