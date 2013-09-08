objclint
========

objclint is a clang based tool for performing code style guidelines check.

See http://objclint.ru for installation/usage.

## DONE

* Works with recent version of XCode
* Installation script
* JavaScript based validators
* Text reports generator
* Disable objclint with ``__objclint`` macro
* Configuration file
 * Support for multiple lints directories
 * Support for ignored files

## TODO

* do not interpret JS scripts for each translation unit. do it once. 
* support for Unicode in JS
* support for '#import' in js validators
* ...

## TODO checkers

* disallow retains in arc mode
