/**
 * Author: Elizabeth Harper
 */
module eph.opt.js.options;

import eph.opt.js.optionfac;
import eph.opt.js.option;
import eph.opt.js.soption;

/**
 * Singleton implementation of the `OptionFactory` interface
 * using the `SimpleOption` type as the implementation for
 * the `Option` interface.
 */
public const class OptionFactoryImpl : OptionFactory {
  private static OptionFactoryImpl instance;

  /**
   * Return: A new option of some wrapping the given value.
   */
  public const(Option!R) some(R)(const R val)
  in {
    static if(__traits(compiles, val is null))
      assert(val !is null, "some() called with null");
  }
  out(o) {
    assert(o !is null, "some() returned null");
    assert(o.isSome, "some() returned empty option");
  }
  do {
    return new SimpleOption!R(val);
  }
  ///
  static unittest {
    const auto op = new OptionFactoryImpl().some!int(3);

    assert(op.isSome);
    assert(op.unwrap == 3);
  }


  /**
   * Return: A new option of none for the given type.
   */
  public const(Option!R) none(R)()
  out(o) {
    assert(o !is null);
    assert(o.isNone);
  }
  do {
    return new SimpleOption!R();
  }
  ///
  static unittest {
    const auto fac = new OptionFactoryImpl;
    const auto op = fac.none!int;

    assert(op.isNone);
  }


  /**
   * Return: If the given value is null, an option of none
   *         will be returned.  If the given value is not
   *         null an option of some wrapping the given value
   *         will be returned.
   */
  public const(Option!R) maybe(R)(const R val)
  out(o) {
    assert(o !is null);
    static if(__traits(compiles, val is null)) {
      assert((val is null && o.isNone) || (val !is null && o.isSome));
    } else {
      assert(o.isSome);
    }
  }
  do {
    return val !is null ? some!R(val) : none!R();
  }
  ///
  static unittest {
    const auto fac = new OptionFactoryImpl;

    const auto opA = fac.maybe!string(null);
    assert(opA.isNone);

    const auto opB = fac.maybe!string("3");
    assert(opB.isSome);
    assert(opB.unwrap == "3");
  }


  /**
   * Return: The singleton instance of the Options class.
   *         An instance will be created if one does not
   *         already exist;
   */
  public static OptionFactoryImpl getInstance() {
    return instance is null
      ? instance = new OptionFactoryImpl()
      : instance;
  }
  ///
  static unittest {
    assert(getInstance() == instance);
  }
}

public class Options {
  /**
   * Static access to `maybe()`.
   *
   * Return: If the given value is null, an option of none
   *         will be returned.  If the given value is not
   *         null an option of some wrapping the given value
   *         will be returned.
   */
  public static const(Option!R) maybe(R)(const R val)
  out(o) {
    assert(o !is null);
    static if(__traits(compiles, val is null)) {
      assert((val is null && o.isNone) || (val !is null && o.isSome));
    } else {
      assert(o.isSome);
    }
  }
  do {
    return OptionFactoryImpl.getInstance().maybe!R(val);
  }
  ///
  static unittest {
    const auto opA = Options.maybe!string(null);
    assert(opA.isNone);

    const auto opB = Options.maybe!string("3");
    assert(opB.isSome);
    assert(opB.unwrap == "3");
  }


  /**
   * Static access to `none()`.
   *
   * Return: A new option of none for the given type.
   */
  public static const(Option!R) none(R)()
  out(o) {
    assert(o !is null);
    assert(o.isNone);
  }
  do {
    return OptionFactoryImpl.getInstance().none!R();
  }
  ///
  static unittest {
    const auto op = Options.none!int;

    assert(op.isNone);
  }


  /**
   * Static access to `some()`.
   *
   * Return: A new option of some wrapping the given value.
   */
  public static const(Option!R) some(R)(const R val)
  in {
    static if(__traits(compiles, val is null))
      assert(val !is null);
  }
  out(o) {
    assert(o !is null);
    assert(o.isSome);
  }
  do {
    return OptionFactoryImpl.getInstance().some!R(val);
  }
  ///
  static unittest {
    const auto op = Options.some!int(3);

    assert(op.isSome);
    assert(op.unwrap == 3);
  }
}
