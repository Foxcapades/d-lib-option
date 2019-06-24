module eph.opt.esex;

public class EmptySomeException : Exception {
  this() {
    super("null value given to some()");
  }
}