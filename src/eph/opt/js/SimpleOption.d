/**
 * Author: Elizabeth Harper
 */
module eph.opt.js.soption;

import eph.opt.js.option;
import eph.opt.unex: UnwrapException;

/**
 * Basic implementation of the Option interface.
 *
 * This implementation is private and it's direct use should
 * be avoided.  Instead see implementations of the
 * OptionFactory interface.
 */
package class SimpleOption(T) : Option!T {
  private T value;
  private bool set;


  ///
  package this(T val)
  in {
    static if(__traits(compiles, val is null))
      assert(val !is null);
  }
  do {
    value = val;
    set = true;
  }


  ///
  package this() {
    value = T.init;
    set = false;
  }


  /**
   * Return: true if this option is of some, else false.
   */
  public bool isSome() const
  {
    return set;
  }
  ///
  static unittest {
    assert(new SimpleOption!int(3).isSome);
  }


  /**
   * Return: true if this option is of none, else false.
   */
  public bool isNone() const
  {
    return !set;
  }
  ///
  static unittest {
    assert(new SimpleOption!int().isNone);
  }


  /**
   * Return: If this option is of some, this method returns
   *         a new option of some wrapping the return value
   *         of the given function.  If this option is of
   *         none, returns a new option of none, typed as
   *         the return value for the given function.
   */
  public Option!R map(R)(R function(const T) fn)
  in {
    assert(fn !is null);
  }
  do {
    return isSome
      ? new SimpleOption!R(fn(value))
      : new SimpleOption!R();
  }
  ///
  static unittest {
    import std.conv: to;

    assert(new SimpleOption!int(3).map(i => i.to!string).unwrap == "3");

    auto fnB = function string(const int _) {throw new Exception("this shouldn't be called");};
    assert(new SimpleOption!int().map(fnB).isNone);
  }


  /**
   * Return: If this option is of some, this method returns
   *         a new option of some wrapping the return value
   *         of the given delegate.  If this option is of
   *         none, returns a new option of none, typed as
   *         the return value for the given delegate.
   */
  public Option!R map(R)(R delegate(const T) fn)
  in {
    assert(fn !is null);
  }
  do {
    return isSome ? new SimpleOption!R(fn(value)) : new SimpleOption!R();
  }
  ///
  static unittest {
    import std.conv: to;

    auto fnA = delegate string(const int i) {
      return to!string(i);
    };
    assert(new SimpleOption!int(3).map(fnA).unwrap == "3");

    auto fnB = delegate string(const int _) {
      throw new Exception("this shouldn't be called");
    };
    assert(new SimpleOption!int().map(fnB).isNone);
  }


  /**
   * Return: If this option is of some, this method returns
   *         the option value returned by the given
   *         function.  If this option is of none, returns a
   *         new option of none, typed as the return value
   *         for the given function.
   */
  public Option!R flatMap(R)(Option!R function(const T) fn)
  in {
    assert(fn !is null);
  }
  do {
    return isSome ? fn(value) : new SimpleOption!R();
  }
  ///
  static unittest {
    import std.conv: to;

    auto fnA = function Option!string(const int i) {
      return new SimpleOption!string(to!string(i));
    };
    assert(new SimpleOption!int(3).flatMap(fnA).unwrap == "3");

    assert(new SimpleOption!int().map(delegate string(const int _) {
      throw new Exception("this shouldn't be called"); }).isNone);
  }


  /**
   * Return: If this option is of some, this method returns
   *         the option value returned by the given
   *         delegate.  If this option is of none, returns a
   *         new option of none, typed as the return value
   *         for the given delegate.
   */
  public Option!R flatMap(R)(Option!R delegate(const T) fn)
  in {
    assert(fn !is null);
  }
  do {
    return isSome ? fn(value) : new SimpleOption!R();
  }
  ///
  static unittest {
    import std.conv: to;

    auto opA = new SimpleOption!int(3);
    auto fnA = function Option!string(const int i) {
      return new SimpleOption!string(i.to!string);
    };
    assert(opA.flatMap(fnA).unwrap == "3");

    auto opB = new SimpleOption!int();
    auto fnB = delegate string(const int _) {
      throw new Exception("this shouldn't be called");
    };
    assert(opB.map(fnB).isNone);
  }


  /**
   * Return: The value wrapped by this option provided that
   *         it is an option of some.
   */
  public T unwrap() const
  in {
    assert(isSome);
  }
  do {
    return value;
  }
  ///
  static unittest {
    auto op = new SimpleOption!int(3);
    assert(op.unwrap == 3);
  }


  /**
   * Return: If the current option is of none, the provided
   *         alternate value.  If the current option is of
   *         some, the wrapped value.
   */
  public T orElse(T alt) const
  in{
    static if(__traits(compiles, alt is null))
      assert(alt !is null);
  }
  do {
    return isSome ? value : alt;
  }
  ///
  static unittest {
    assert(new SimpleOption!int(3).orElse(4) == 3);
    assert(new SimpleOption!int().orElse(4) == 4);
  }


  /**
   * Return: If the current option is of none, the return
   *         value of the provided function.  If the current
   *         option is of some, the wrapped value.
   */
  public T orElse(T function() fn) const
  in{
    assert(fn !is null);
  }
  do {
    return isSome ? value : fn();
  }
  ///
  static unittest {
    auto opA = new SimpleOption!int(3);
    assert(opA.orElse(function int() {throw new Exception("this should not be called");}) == 3);

    auto opB = new SimpleOption!int();
    assert(opB.orElse(function int() {return 4;}) == 4);
  }


  /**
   * Return: If the current option is of none, the return
   *         value of the provided delegate.  If the current
   *         option is of some, the wrapped value.
   */
  public T orElse(T delegate() fn) const
  in {
    assert(fn !is null);
  }
  do {
    return isSome ? value : fn();
  }
  ///
  static unittest {
    assert(new SimpleOption!int(3).orElse(delegate int() {
      throw new Exception("this should not be called");}) == 3);

    assert(new SimpleOption!int().orElse(delegate int() {return 4;}) == 4);
  }

    /*------------------------------------------------------*\
  | Operator Overloads
  \*------------------------------------------------------*/

  override bool opEquals(Object other)
  {
    if (other is this)
      return true;
    if (auto f = cast(Option!T)other) {
      if (f.isNone ^ this.isNone)
        return false;
      return f.isNone || f.unwrap == this.value;
    }
    return false;
  }
  ///
  static unittest {
    auto noneA  = new SimpleOption!int();
    auto noneB  = new SimpleOption!int();
    auto some2a = new SimpleOption!int(2);
    auto some2b = new SimpleOption!int(2);
    auto some3  = new SimpleOption!int(3);

    assert(noneA == noneB, "Empty options should be considered equal");
    assert(noneA != some3);
    assert(some2a == some2b);
    assert(some2a != some3);
  }

}
