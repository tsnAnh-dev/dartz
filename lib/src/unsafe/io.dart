part of dartz_unsafe;

class _RandomAccessFileRef implements FileRef {
  final RandomAccessFile _f;

  _RandomAccessFileRef(this._f);
}

Future<RandomAccessFile> unwrapFileRef(FileRef ref) =>
    ref is _RandomAccessFileRef
        ? Future.value(ref._f)
        : Future.error("Not a valid FileRef: $ref");

Future unsafeIOInterpreter(IOOp io) {
  return switch (io) {
    Readln() => Future.value(stdin.readLineSync()),
    Println() => () {
        print(io.s);
        return Future.value(unit);
      }(),
    Attempt() => unsafePerformIO(io.fa).then(io.succeed).catchError(io.fail),
    Fail() => Future.error(io.failure),
    OpenFile() => File(io.path)
        .open(mode: io.openForRead ? FileMode.read : FileMode.write)
        .then((f) => _RandomAccessFileRef(f)),
    CloseFile() =>
      unwrapFileRef(io.file).then((f) => f.close().then((_) => unit)),
    ReadBytes() => unwrapFileRef(io.file).then((f) =>
        f.read(io.byteCount).then((bytes) => UnmodifiableListView(bytes))),
    WriteBytes() => unwrapFileRef(io.file)
        .then((f) => f.writeFrom(io.bytes.toList()).then((_) => unit)),
    Execute() => Process.run(io.command, io.arguments.toList()).then(
        (pr) => ExecutionResult(pr.exitCode, cast(pr.stdout), cast(pr.stderr))),
    Delay() => Future.delayed(io.duration, () => unsafePerformIO(io.a)),
    Gather() => io.ops.traverseFuture(unsafePerformIO).then(io.cast),
  };
}

Future<A> unsafePerformIO<A>(Free<IOOp, A> io) =>
    io.foldMapFuture(unsafeIOInterpreter);

Future<Either<Object, IList<A>>> unsafeConveyIO<A>(
        Conveyor<Free<IOOp, dynamic>, A> conveyor) =>
    unsafePerformIO(IOM.attempt(Conveyor.runLogIO(conveyor)));
