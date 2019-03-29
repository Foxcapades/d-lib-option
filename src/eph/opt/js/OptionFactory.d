/**
 * Author: Elizabeth Harper
 */
module eph.opt.js.optionfac;

import eph.opt.js.option;

/**
 * Factory for creating instances of the Option type.
 */
public interface OptionFactory {

  /**
   * Return: A new option of some wrapping the given value.
   */
  public Option!R some(R)(const R val)
  in {
    static if(__traits(compiles, val is null))
      assert(val !is null);
  }
  out(o) {
    assert(o !is null);
    assert(o.isSome);
  }

  /**
   * Return: A new option of none for the given type.
   */
  public Option!R none(R)()
  out(o) {
    assert(o !is null);
    assert(o.isNone);
  }

  /**
   * Return: If the given value is null, an option of none
   *         will be returned.  If the given value is not
   *         null an option of some wrapping the given value
   *         will be returned.
   */
  public Option!R maybe(R)(const R val)
  out(o) {
    assert(o !is null);
    static if(__traits(compiles, val is null)) {
      assert((val is null && o.isNone) || (val !is null && o.isSome));
    } else {
      assert(o.isSome);
    }
  }
}
