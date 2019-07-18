/**
 * Option type struct.
 *
 * Author: Elizabeth Harper
 */
module eph.opt.cs.option;

import eph.opt.unex: UnwrapException;

/**
 * Option type representing a potential value which may or
 * may not exist.
 */
public struct option(T)
{
  package T value;
  package bool set;

  /**
   * Attempts to unwrap an option value.
   *
   * Checks via contract that this is an option of some.
   *
   * Return: The value wrapped by this option provided that
   *         it is an option of some.
   */
  @nogc
  public const(T) unwrap() const
  in{
    assert(set, "tried to unwrap an option of none");
  }
  do {
    return value;
  }
  ///
  unittest {
    assert(3 == 3.some.unwrap());
  }


  /**
   * Returns either the unwrapped value of this option if
   * the option is of some, or else returns the parameter
   * value passed to this function.
   *
   * Params:
   *   alt = alternate value to return if this is an option
   *         of none.
   *
   * Return: If the current option is of none, the provided
   *         alternate value.  If the current option is of
   *         some, the wrapped value.
   */
  @nogc
  public const(T) orElse(T alt) const
  in {
    static if(__traits(compiles, alt is null))
      assert(alt !is null);
  }
  do {
    return isSome ? value : alt;
  }
  ///
  unittest {
    assert(none!int.orElse(3) == 3);
    assert(4.some.orElse(3) == 4);
  }


  /**
   * Returns either the unwrapped value of this option, if
   * the option is of some, or else calls the given function
   * and returns the result.
   *
   * Params:
   *   fn =  function which will provide an alternate value
   *         if this is an option of none.
   *
   * Return: If the current option is of none, the return
   *         value of the provided function.  If the current
   *         option is of some, the wrapped value.
   */
  public const(T) orElse(T function() fn) const
  in {
    assert(fn !is null, "passed a null delegate to option.orElse");
  }
  do {
    return isSome ? value : fn();
  }
  ///
  unittest {
    assert(none!int.orElse(() => 3) == 3);

    auto fnSome = function int() { throw new Exception("this should not be called"); };
    auto oSome = some(4);
    assert(oSome.orElse(fnSome) == 4);
  }


  /**
   * Return: If the current option is of none, the return
   *         value of the provided delegate.  If the current
   *         option is of some, the wrapped value.
   */
  public const(T) orElse(T delegate() fn) const
  in {
    assert(fn !is null, "passed a null delegate to option.orElse");
  }
  do {
    return isSome ? value : fn();
  }
  ///
  unittest {
    assert(none!int.orElse(() => 3) == 3);

    auto fnSome = delegate int() { throw new Exception("this should not be called"); };
    assert(4.some.orElse(fnSome) == 4);
  }


  /**
   * Return: true if this option is of some, else false.
   */
  @nogc
  public bool isSome() const
  {
    return set;
  }
  ///
  unittest {
    assert(!none!int.isSome);
    assert(4.some.isSome);
  }


  /**
   * Return: true if this option is of none, else false.
   */
  @nogc
  public bool isNone() const
  {
    return !set;
  }
  ///
  unittest {
    assert(none!int.isNone);
    assert(!some(4).isNone);
  }


  /**
   * Return: If this option is of some, this method returns
   *         a new option of some wrapping the return value
   *         of the given function.  If this option is of
   *         none, returns a new option of none, typed as
   *         the return value for the given function.
   */
  public const(option!R) map(R)(R function(T) fn) const
  in {
    assert(fn !is null, "passed a null function to option.map");
  }
  do {
    return isSome ? some!R(fn(value)) : none!R();
  }
  ///
  unittest {
    import std.conv: to;

    auto fnNone = function string(int x) {
      throw new Exception("this should not be called");
    };
    auto intNone = none!int;
    const option!string strNone = intNone.map(fnNone);
    assert(strNone.isNone);

    auto fnSome = function string(int x) { return x.to!string; };
    auto intSome = some(4);
    const option!string strSome = intSome.map(fnSome);
    assert(strSome.unwrap == "4");
  }


  /**
   * Return: If this option is of some, this method returns
   *         a new option of some wrapping the return value
   *         of the given delegate.  If this option is of
   *         none, returns a new option of none, typed as
   *         the return value for the given delegate.
   */
  public const(option!R) map(R)(R delegate(T) fn) const
  in {
    assert(fn !is null, "passed a null delegate to option.map");
  }
  do {
    return isSome ? some!R(fn(value)) : none!R();
  }
  ///
  unittest {
    import std.conv: to;

    auto fnNone = delegate string(int x) {
      throw new Exception("this should not be called");
    };
    auto intNone = none!int;
    const option!string strNone = intNone.map(fnNone);
    assert(strNone.isNone);

    auto fnSome = delegate string(int x) { return x.to!string; };
    auto intSome = some(4);
    const option!string strSome = intSome.map(fnSome);
    assert(strSome.unwrap == "4");
  }


  /**
   * Return: If this option is of some, this method returns
   *         the option value returned by the given
   *         function.  If this option is of none, returns a
   *         new option of none, typed as the return value
   *         for the given function.
   */
  public const(option!R) flatMap(R)(option!R function(T) fn) const
  in {
    assert(fn !is null, "passed a null function to option.flatMap");
  }
  do {
    return isSome ? fn(value) : none!R();
  }
  ///
  unittest {
    import std.conv: to;

    auto fnNone = function option!string(int i) {
      throw new Exception("this should not be called");
    };
    assert(none!int.flatMap(fnNone).isNone);

    auto fnSome = function option!string(int i) { return some(to!string(i)); };
    assert(3.some.flatMap(fnSome).unwrap == "3");
  }


  /**
   * Return: If this option is of some, this method returns
   *         the option value returned by the given
   *         delegate.  If this option is of none, returns a
   *         new option of none, typed as the return value
   *         for the given delegate.
   */
  public const(option!R) flatMap(R)(option!R delegate(T) fn) const
  in {
    assert(fn !is null, "passed a null delegate to option.flatMap");
  }
  do {
    return isSome ? fn(value) : none!R();
  }
  ///
  unittest {
    import std.conv: to;

    auto fnNone = delegate option!string(int i) {
      throw new Exception("this should not be called");
    };
    assert(none!int.flatMap(fnNone).isNone);

    auto fnSome = delegate option!string(int i) { return some(to!string(i)); };
    assert(3.some.flatMap(fnSome).unwrap == "3");
  }

  /*------------------------------------------------------*\
  | Operator Overloads
  \*------------------------------------------------------*/

  bool opEquals(U : T)(const ref option!U other) const
  {
    if (other.isNone ^ this.isNone)
      return false;
    return other.isNone || other.value == this.value;
  }
  ///
  unittest {
    auto noneA  = none!int;
    auto noneB  = none!int;
    auto some2a = some!int(2);
    auto some2b = some!int(2);
    auto some3  = some!int(3);

    assert(noneA == noneB);
    assert(noneA != some3);
    assert(some2a == some2b);
    assert(some2a != some3);
  }
}


/**
 * Return: An option of some wrapping the given value.
 */
public const(option!R) some(R)(R val)
in {
  static if(__traits(compiles, val is null))
    assert(val !is null, "tried to wrap a null as an option of some");
}
out(t) {
  assert(t.isSome());
}
do {
  return option!R(val, true);
}
///
unittest {
  assert(some(3).unwrap == 3);
}


/**
 * Return: An option of none.
 */
public const(option!R) none(R)()
out(t) {
  assert(t.isNone);
}
do {
  return option!R(R.init, false);
}
///
unittest {
  assert(none!int.isNone);
}


/**
 * Return: If the given input is null, returns an empty
 *         option.  If the given input is not null, returns
 *         an option of that value.
 */
public const(option!R) maybe(R)(R val)
out(o) {
  static if(__traits(compiles, val is null))
    assert((val is null && o.isNone) || (val !is null && o.isSome));
}
do {
  static if(__traits(compiles, val is null))
    return val is null
      ? option!R(null, false)
      : option!R(val, true);
  else
    return option!R(val, true);
}
///
unittest {
  auto val = 3;

  const auto a = maybe!(int*)(null);
  assert(a.isNone);

  const auto b = maybe!(int*)(&val);
  assert(b.isSome);
}
