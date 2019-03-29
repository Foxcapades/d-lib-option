module eph.opt.js.option;

import eph.opt.unex: UnwrapException;

/**
 * Option type representing a potential value which may or
 * may not exist.
 */
public interface Option(T) {

  /**
   * Return: true if this option is of some, else false.
   */
  public bool isSome() const;


  /**
   * Return: true if this option is of none, else false.
   */
  public bool isNone() const;


  /**
   * Return: If this option is of some, this method returns
   *         a new option of some wrapping the return value
   *         of the given function.  If this option is of
   *         none, returns a new option of none, typed as
   *         the return value for the given function.
   */
  public Option!R map(R)(R function(const T) fn) const
  in(fn !is null);


  /**
   * Return: If this option is of some, this method returns
   *         a new option of some wrapping the return value
   *         of the given delegate.  If this option is of
   *         none, returns a new option of none, typed as
   *         the return value for the given delegate.
   */
  public Option!R map(R)(R delegate(const T) fn) const
  in(fn !is null);


  /**
   * Return: If this option is of some, this method returns
   *         the option value returned by the given
   *         function.  If this option is of none, returns a
   *         new option of none, typed as the return value
   *         for the given function.
   */
  public Option!R flatMap(R)(Option!R function(const T) fn) const
  in(fn !is null);


  /**
   * Return: If this option is of some, this method returns
   *         the option value returned by the given
   *         delegate.  If this option is of none, returns a
   *         new option of none, typed as the return value
   *         for the given delegate.
   */
  public Option!R flatMap(R)(Option!R delegate(const T)) const
  in(fn !is null);


  /**
   * Return: The value wrapped by this option provided that
   *         it is an option of some.
   */
  public T unwrap() const
  in(isSome);


  /**
   * Return: If the current option is of none, the provided
   *         alternate value.  If the current option is of
   *         some, the wrapped value.
   */
  public T orElse(T alt) const
  in {
    static if(__traits(compiles, alt is null))
      assert(alt !is null);
  };


  /**
   * Return: If the current option is of none, the return
   *         value of the provided function.  If the current
   *         option is of some, the wrapped value.
   */
  public T orElse(T function() fn) const
  in(fn !is null);


  /**
   * Return: If the current option is of none, the return
   *         value of the provided delegate.  If the current
   *         option is of some, the wrapped value.
   */
  public T orElse(T delegate() fn) const
  in(fn !is null);
}
