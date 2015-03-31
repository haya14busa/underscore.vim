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

let s:c = {}
function! s:c.collect(str) abort
    return toupper(a:str[0]) . tolower(a:str[1:])
endfunction

call s:_.mixin(s:c)

echo s:_('fabio').collect()
echo s:_.collect('fabio')

let s:d = {}
function! s:d.capitalize(str) abort
    return toupper(a:str[0]) . tolower(a:str[1:])
endfunction
let s:__ = s:un.import()
call s:__.mixin(s:d)

echo s:__.chain('vim').capitalize().value()
echo s:__.capitalize('vim')


