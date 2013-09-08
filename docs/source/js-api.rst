JS API
======

All **objclint** analyzis performed with JavaScript.

.. code:: javascript

    var objc_msg = cursor.kind=="ObjCMessageExpr";
    var nsassert_method = cursor.spelling == "handleFailureInMethod:object:file:lineNumber:description:";

    if(objc_msg && nsassert_method) {
        lint.reportError("Using NSAssert() may cause retin cycles. Try NSCAssert() instead");
    }

There are two global objects:

1. ``cursor``
#. ``lint``

And number of other objects that you can get:

1. ``token``
#. ``objc-method-declaration``

Cursor object
-------------

Cursor is one of the most significant objects in objclint. Clang builds Abstract Syntax Tree of every source file and allows us to visit every element of it as **cursor** and its childs. Every time javascript validator called you have global **cursor** object that can be analyzed.

**cursor** have following properties:

``lineNumber``
    Line number of **cursor**.

``column``
    Line column of **cursor**.

``offset``
    Global offset in file.

``fileName``
    Current file name.

``displayName``
    Retrieve the display name for the entity referenced by this cursor.

    The display name contains extra information that helps identify the cursor,
    such as the parameters of a function or template or the arguments of a 
    class template specialization.

``USR``
    Retrieve a Unified Symbol Resolution (USR) for the entity referenced
    by the given cursor.

    A Unified Symbol Resolution (USR) is a string that identifies a particular
    entity (function, class, variable, etc.) within a program. USRs can be
    compared across translation units to determine, e.g., when references in
    one translation refer to an entity defined in another translation unit.

``spelling``
    Retrieve a range for a piece that forms the cursors spelling name.
    Most of the times there is only one range for the complete spelling but for
    objc methods and objc message expressions, there are multiple pieces for each
    selector identifier.

``kind``
    Retrieve the kind of the given cursor. See `clang documentation <http://clang.llvm.org/doxygen/group__CINDEX.html#gaaccc432245b4cd9f2d470913f9ef0013>`_ for full list (ignore ``CXCursor`` prefix).
