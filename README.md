underscore.vim
==============

[![Build Status](https://travis-ci.org/haya14busa/underscore.vim.svg?branch=master)](https://travis-ci.org/haya14busa/underscore.vim)
[![Build status](https://ci.appveyor.com/api/projects/status/ks6gtsu46c1djoo6/branch/master)](https://ci.appveyor.com/project/haya14busa/underscore-vim/branch/master)
[![](http://img.shields.io/github/tag/haya14busa/underscore.vim.svg)](https://github.com/haya14busa/underscore.vim/releases)
[![](http://img.shields.io/github/issues/haya14busa/underscore.vim.svg)](https://github.com/haya14busa/underscore.vim/issues)
[![](http://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![](http://img.shields.io/badge/doc-%3Ah%20underscore.txt-red.svg)](doc/underscore.txt)

Vim script utility library :heartbeat: The sky is the limit!
------------------------------------------------------------

*underscore.vim* is a Vim script library that provides a whole mess of useful functional programming helpers.

```.vim
echo s:_.reject([1, 2, 3, 4, 5, 6], 'v:val % 2 == 0')
" => [1, 3, 5]

function! s:toFizzBuzz(x)
  return a:x%15 ? a:x%3 ? a:x%5 ? a:x : 'Buzz' : 'Fizz' : 'FizzBuzz'
endfunction

echo s:_._(range(20))
  \.chain()
  \.map('v:val + 1')
  \.filter('v:val % 2')
  \.map(function('s:toFizzBuzz'))
  \.value()
" => [1, 'Fizz', 'Buzz', 7, 'Fizz', 11, 13, 'FizzBuzz', 17, 19]
```

:package: Installation :package:
--------------------------------

1) Install [vital.vim] and underscore.vim with your favorite plugin manager.

```vim
NeoBundle 'vim-jp/vital.vim'
NeoBundle 'haya14busa/underscore.vim'

Plugin 'vim-jp/vital.vim'
Plugin 'haya14busa/underscore.vim'

Plug 'vim-jp/vital.vim'
Plug 'haya14busa/underscore.vim'
```

2) Embed underscore.vim into your plugin with `:Vitalize`.

```vim
:Vitalize . --name={plugin_name} Underscore
```

3) Import underscore.vim in your plugins

```vim
let s:V = vital#of('vital')
let s:_ = s:V.import('Underscore').import()
echo s:_.filter([1, '2', '3', 4.0, 5], s:_.is_string)
" => ['2', '3']
```

:orange_book: Documentation :orange_book:
-----------------------------------------

[**:h underscore.txt**](./doc/underscore.txt)

:tada: Examples :tada:
----------------------

###:globe_with_meridians: Real world(?) usage :globe_with_meridians:

```vim
let s:V = vital#of('vital')
let s:_ = s:V.import('Underscore').import()

function! s:scouter(...)
  let lines = readfile(expand(get(a:, 1, $MYVIMRC)))
  let p = '^\s*$\|^\s*["\\]'
  return s:_.chain(lines).reject(printf("v:val =~# '%s'", p)).length().value()
endfunction

" Count LOC of your vimrc
echo s:scouter()

" Return list of plugins in the given file or your vimrc
function! s:plugins(...)
  let lines = readfile(expand(get(a:, 1, $MYVIMRC)))
  let ignore = '^\s*$\|^\s*["\\]'
  let bundle = "\\v%(%(Neo)?Bundle%(Lazy)|Plug%(in)?) ''([^'']+%(/[^'']+)?)"
  return s:_.chain(lines)
    \.reject(printf("v:val =~# '%s'", ignore))
    \.select(printf("v:val =~# '%s'", bundle))
    \.map(printf("matchlist(v:val, '%s')[1]", bundle))
    \.sort()
    \.value()
endfunction

" Get installed plugins in vimrc
echo s:plugins()
echo len(s:plugins())
```

### :memo: Memoize fibonacch :memo:

```vim
let s:V = vital#of('vital')
let s:_ = s:V.import('Underscore').import()

function! s:_fib(n) abort
  return a:n < 2 ? a:n : s:fib(a:n-1) + s:fib(a:n-2)
endfunction

let s:fib = s:_.memoize(function('s:_fib'))
echo s:fib(24)
" => 46368
```

### :envelope: With Vital.Data.Closure :envelope:
[:h Vital.Data.Closure](https://github.com/vim-jp/vital.vim/blob/master/doc/vital-data-closure.txt)

```vim
let s:V = vital#of('vital')
let s:_ = s:V.import('Underscore').import()
let s:Closure = s:V.import('Data.Closure')
function! s:lambda(x, ...) abort
  return call(s:Closure.build, [a:x] + a:000).to_function()
endfunction

echo s:_.chain(range(1,100))
    \.select(s:lambda('= a:1 % 3 == 0'))
    \.tap(s:lambda(":echo 'len: ' . len(a:1)"))
    \.map(s:lambda('= a:1 * a:1'))
    \.reject(s:lambda('= a:1 < 500'))
    \.drop(3)
    \.foldl(0, s:lambda('+'))
    \.value()
" =>
"   len: 33
"   109296
```

### :zap: Extend to work with other library :zap:
- [vim-jp/vital.vim](https://github.com/vim-jp/vital.vim)

You can extend underscore.vim with `_.mixin()` :sparkles:
See [`:h _.mixin()`](doc/underscore.txt)

#### underscore-string.vim

```vim
let s:V = vital#of('vital')
let s:_ = s:V.import('Underscore').import()
call s:_.mixin(s:V.import('Data.String'))
call s:_.mixin(s:V.import('Data.String.Interpolation'))
echo s:_.chain("  underscore-${module}.js!  \r\n")
    \.format({'module': 'string'})
    \.replace('.js', '.vim')
    \.chomp()
    \.trim()
    \.pad_left(25, '.')
    \.value()
```

#### underscore-random.vim with closure

```vim
let s:V = vital#of('vital')
let s:_ = s:V.import('Underscore').import()
call s:_.mixin(s:V.import('Random'))

let s:Closure = s:V.import('Data.Closure')
function! s:lambda(x, ...) abort
    return call(s:Closure.build, [a:x] + a:000).to_function()
endfunction

echo s:_.chain(range(100))
    \.shuffle()
    \.take(3)
    \.foldl(0, s:lambda('+'))
    \.value()
" => random: 155
```

If you want to see more examples, please see [/example directory](./example).

:link: Links :link:
-------------------
The api and documentation are heavily inspired by [Underscore.js],
[lodash] and [Underscore.lua]. It's implementation are heavily
inspired by and taken from [vital.vim].

[Underscore.js]: http://underscorejs.org/
[lodash]: https://github.com/lodash/lodash
[Underscore.lua]: http://mirven.github.io/underscore.lua/
[vital.vim]: https://github.com/vim-jp/vital.vim

:bird: Author :bird:
--------------------
haya14busa (https://github.com/haya14busa)
