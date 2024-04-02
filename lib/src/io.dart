part of dartz;

sealed class IOOp<A> {}

class Readln extends IOOp<String> {}

class Println extends IOOp<Unit> {
  final String s;
  Println(this.s);
}

abstract class FileRef {}
class OpenFile extends IOOp<FileRef> {
  final String path;
  final bool openForRead;
  OpenFile(this.path, this.openForRead);
}

class ReadBytes extends IOOp<UnmodifiableListView<int>> {
  final FileRef file;
  final int byteCount;
  ReadBytes(this.file, this.byteCount);
}

class WriteBytes extends IOOp<Unit> {
  final FileRef file;
  final IList<int> bytes;
  WriteBytes(this.file, this.bytes);
}

class CloseFile extends IOOp<Unit> {
  final FileRef file;
  CloseFile(this.file);
}

class ExecutionResult {
  final int exitCode;
  final String stdout;
  final String stderr;
  ExecutionResult(this.exitCode, this.stdout, this.stderr);
}
class Execute extends IOOp<ExecutionResult> {
  final String command;
  final IList<String> arguments;
  Execute(this.command, this.arguments);
}

class Delay<A> extends IOOp<A> {
  final Duration duration;
  final Free<IOOp,A> a;
  Delay(this.duration, this.a);
}

class Attempt<A> extends IOOp<Either<Object, A>> {
  final Free<IOOp, A> fa;
  Attempt(this.fa);

  Either<Object, A> succeed(A a) => right(a);
  Either<Object, A> fail(Object err) => left(err);
}

class Fail<A> extends IOOp<A> {
  final Object failure;
  Fail(this.failure);
}

class Gather<A> extends IOOp<IList<A>> {
  final IList<Free<IOOp, A>> ops;
  final Function1<IList<dynamic>, IList<A>> cast;
  Gather(this.ops, this.cast);
}

class IOMonad extends FreeMonad<IOOp> implements MonadCatch<Free<IOOp, dynamic>> {
  @override Free<IOOp, A> pure<A>(A a) => Pure(a);
  @override Free<IOOp, Either<Object, A>> attempt<A>(covariant Free<IOOp, A> fa) => liftF(Attempt(fa));
  @override Free<IOOp, A> fail<A>(Object err) => liftF(Fail(err));
  // appease the twisted type system (issue #18)
  @override Free<IOOp, B> bind<A, B>(Free<IOOp, A> fa, Function1<A, Free<IOOp, B>> f) => super.bind(fa, f);
}

final IOMonad IOM = IOMonad();
final MonadCatch<Free<IOOp, dynamic>> IOMC = IOM;
MonadCatch<Free<IOOp, A>> iomc<A>() => cast(IOMC);

class IOOps<F> extends FreeOps<F, IOOp> {
  IOOps(FreeComposer<F, IOOp> composer) : super(composer);

  Free<F, String?> readln() => liftOp(Readln());

  Free<F, Unit> println(String s) => liftOp(Println(s));

  Free<F, FileRef> openFile(String path, bool openForRead) => liftOp(OpenFile(path, openForRead));

  Free<F, UnmodifiableListView<int>> readBytes(FileRef file, int byteCount) => liftOp(ReadBytes(file, byteCount));

  Free<F, Unit> writeBytes(FileRef file, IList<int> bytes) => liftOp(WriteBytes(file, bytes));

  Free<F, Unit> closeFile(FileRef file) => liftOp(CloseFile(file));

  Free<F, ExecutionResult> execute(String command, IList<String> arguments) => liftOp(Execute(command, arguments));

  Free<F, A> delay<A>(Duration duration, Free<IOOp, A> a) => liftOp(Delay(duration, a));

  Free<F, Either<Object, A>> attempt<A>(Free<IOOp, A> fa) => liftOp(Attempt(fa));

  Free<F, A> fail<A>(Object failure) => liftOp(Fail(failure));

  Free<F, IList<A>> gather<A>(IList<Free<IOOp, A>> ops) => liftOp(Gather(ops, (l) => l.map((e) => cast<A>(e))));
}

final io = IOOps<IOOp>(IdFreeComposer());
