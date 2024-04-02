part of dartz;

// universally quantified monoid
// might seem pointless to separate from monoid in dart, but clarifies intent

abstract mixin class PlusEmpty<F> implements Plus<F> {
  F empty<A>(); // () => F[A]
}

abstract mixin class PlusEmptyOps<F, A> implements PlusOps<F, A> {
  //F empty(); // () => F[A]
}