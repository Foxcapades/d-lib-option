module eph.opt.unex;

public class UnwrapException : Exception {
  public this() {
    super("attempted to unwrap an option of none");
  }
}