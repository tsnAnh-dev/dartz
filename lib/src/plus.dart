part of dartz;

// universally quantified semigroup
// might seem pointless to separate from semigroup in dart, but clarifies intent

abstract mixin class Plus<F> {
  F plus<A>(F f1, F f2);
}

abstract mixin class PlusOps<F, A> {
  F plus(covariant F fa2); // F[A] => F[A]
}