let s:V = vital#of('vital')
let s:Closure = s:V.import('Data.Closure')
let s:un = s:V.import('Underscore')
let s:_ = s:un.import()
function! s:_(...) abort
    return call(s:_._, a:000, s:_)
endfunction

function! s:lambda(x, ...) abort
    return call(s:Closure.build, [a:x] + a:000).to_function()
endfunction

function! s:fibonacchi_impl(n) abort
    " Called once for the unique given argument
    " echo a:n
    return a:n is 0 ? 0
    \    : a:n is 1 ? 1
    \    : s:Fibonacchi(a:n-1) + s:Fibonacchi(a:n-2)
endfunction
let s:Fibonacchi = s:_.memoize(function('s:fibonacchi_impl'))
echo s:Fibonacchi(30) | " => 832040

" lambda version
let s:Fib = s:_.memoize(s:lambda(':return  a:1 is 0 ? 0 : a:1 is 1 ? 1 : Fib(a:1-1) + Fib(a:1-2)', s:))
echo s:Fib(18) | " => 2584

