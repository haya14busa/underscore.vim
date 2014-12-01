"=============================================================================
" FILE: autoload/vital/__latest__/Underscore.vim
" AUTHOR: haya14busa
" Last Change: 01-12-2014.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! s:_vital_loaded(V) abort
  let s:V = a:V
  let s:List = s:V.import('Data.List')
  let s:Prelude = s:V.import('Prelude')
endfunction

function! s:_vital_depends() abort
  return ['Data.List', 'Prelude']
endfunction

let s:_ = {}

function! s:_(value) abort
    let obj = deepcopy(s:_obj)
    let obj._val = a:value
    return obj
endfunction

function! s:underscore(value) abort
    return s:_(a:value)
endfunction

function! s:_.chain(value) abort
    let obj = s:_(a:value)
    let obj._chain = 1
    return obj
endfunction

" Iter:

function! s:_.each(xs, f) abort
    let F = s:_.is_string(a:f) ? function(a:f) : a:f
    for x in a:xs
        call F(x)
    endfor
    return a:xs
endfunction
let s:_.for_each = s:_.each

function! s:_.map(xs, f, ...) abort
    return s:_.is_string(a:f)
    \   ? map(copy(a:xs), a:f)
    \   : map(copy(a:xs), 'call(a:f, [v:val], self)')
endfunction
let s:_.collect = s:_.map

function! s:_.reduce(xs, memo, f) abort
    if s:_.is_funcref(a:f)
        let memo = a:memo
        for x in a:xs
            let memo = a:f(memo, x)
        endfor
        return memo
    else
        return s:List.foldl(a:f, a:memo, a:xs)
    endif
endfunction
let s:_.foldl = s:_.reduce
let s:_.inject = s:_.reduce


function! s:_.reduceRight(xs, memo, f) abort
    return s:_.reduce(reverse(copy(a:xs)), a:memo, a:f)
endfunction
let s:_.foldr = s:_.reduceRight

function! s:_.find(xs, default, f) abort
    if s:_.is_funcref(a:f)
        for x in a:xs
            if a:f(x)
                return x
            endif
        endfor
        return a:default
    else
        return s:List.find(a:xs, a:default, a:f)
    endif
endfunction
let s:_.detect = s:_.find

function! s:_.filter(xs, f) abort
    return s:_.is_string(a:f)
    \   ? filter(copy(a:xs), a:f)
    \   : filter(copy(a:xs), 'call(a:f, [v:val], self)')
endfunction
let s:_.select = s:_.filter

function! s:_.reject(xs, f) abort
    return s:_.is_string(a:f)
    \   ? filter(copy(a:xs), '!(' . a:f . ')')
    \   : filter(copy(a:xs), '!call(a:f, [v:val], self)')
endfunction

" xs, f
function! s:_.every(xs, ...) abort
    let F = get(a:, 1, s:_.identity)
    return s:_.chain(a:xs).filter(F).length().value() is# len(a:xs)
endfunction
let s:_.all = s:_.every

" xs, f
function! s:_.some(xs, ...) abort
    let F = get(a:, 1, s:_.identity)
    return !empty(s:_.chain(a:xs).filter(F).length())
endfunction
let s:_.any = s:_.some

function! s:_.contains(xs, value) abort
    return s:List.has(a:xs, a:value)
endfunction
let s:_.include = s:_.contains

function! s:_.sort(xs, ...) abort
    if a:0 is 0
        return sort(a:xs)
    elseif a:1 is 0 || a:1 == '' || a:1 == 1 || a:1 =~# '[in]'
        return sort(a:xs, a:1)
    else
        return s:List.sort(a:xs, a:1)
    endif
endfunction

function! s:_.sort_by(xs, f) abort
    if s:_.is_funcref(a:f)
        let s:_F = a:f
        return s:_.chain(a:xs)
            \.map(function('s:_make_pair'))
            \.sort('a:a[1] ==# a:b[1] ? 0 : a:a[1] ># a:b[1] ? 1 : -1')
            \.map('v:val[0]')
            \.value()
    else
        return s:List.sort_by(a:xs, a:f)
    endif
endfunction

function! s:_.reverse(xs) abort
    return reverse(copy(a:xs))
endfunction

function! s:_.group_by(xs, f) abort
    if s:_.is_funcref(a:f)
        let s:_F = a:f
        let result = {}
        let list = s:_(a:xs).map(function('s:_make_pair'))
        for x in list
            let Val = x[0]
            let key = type(x[1]) !=# type('') ? string(x[1]) : x[1]
            if has_key(result, key)
                call add(result[key], Val)
            else
                let result[key] = [Val]
            endif
            unlet Val
        endfor
        return result
    else
        return s:List.group_by(a:xs, a:f)
    endif
endfunction

" xs, n
function! s:_.take(xs, ...) abort
    let r = a:xs[0 : get(a:, 1, 1) - 1]
    return len(r) is 1 ? r[0] : r
endfunction
let s:_.first = s:_.take
let s:_.head = s:_.take

" xs, n
function! s:_.initial(xs, ...) abort
    let idx = len(a:xs) - 1 - get(a:, 1, 1)
    return idx >= 0 ? a:xs[0 : idx] : []
endfunction

function! s:_.last(xs, ...) abort
    return call(s:_.take, [s:_(a:xs).reverse()] + a:000, self)
endfunction

function! s:_.tail(xs, ...) abort
    return a:xs[get(a:, 1, 1):]
endfunction
let s:_.rest = s:_.tail
let s:_.drop = s:_.tail

function! s:_.flatten(xs, ...) abort
    return call(s:List.flatten, [a:xs] + a:000)
endfunction

function! s:_.uniq_by(xs, f) abort
    if s:_.is_funcref(a:f)
        let s:_F = a:f
        let list = s:_(a:xs).map(function('s:_make_pair'))
        let i = 0
        let seen = {}
        while i < len(list)
            let key = string(list[i][1])
            if has_key(seen, key)
                call remove(list, i)
            else
                let seen[key] = 1
                let i += 1
            endif
        endwhile
        return map(list, 'v:val[0]')
    else
        return s:List.uniq_by(a:xs, a:f)
    endif
endfunction

function! s:_.uniq(xs) abort
    return s:_.uniq_by(a:xs, s:_.identity)
endfunction

function! s:_.tap(obj, interceptor) abort
    call a:interceptor(a:obj)
    return a:obj
endfunction

function! s:_.zip(xs) abort
    return s:_(s:List.zip(a:xs)).flatten(1)
endfunction

" Util:

let s:_.TRUE = !0
let s:_.FALSE = 0

function! s:_.identity(x) abort
    return a:x
endfunction

function! s:_.length(xs) abort
    return len(a:xs)
endfunction
let s:_.size = s:_.length

function! s:_.is_number(...) abort
    return call(s:Prelude.is_number, a:000)
endfunction
function! s:_.is_float(...) abort
    return call(s:Prelude.is_float, a:000)
endfunction
function! s:_.is_string(...) abort
    return call(s:Prelude.is_string, a:000)
endfunction
function! s:_.is_funcref(...) abort
    return call(s:Prelude.is_funcref, a:000)
endfunction
function! s:_.is_list(...) abort
    return call(s:Prelude.is_list, a:000)
endfunction
function! s:_.is_dict(...) abort
    return call(s:Prelude.is_dict, a:000)
endfunction

" Chaining Obj:

let s:_obj = { '_chain' : 0 }

for s:method in keys(s:_)
    execute join([
    \   'function! s:_obj.' . s:method . '(...) abort',
    \   '    let r = call(s:_.' . s:method . ', [self._val] + a:000, self)',
    \   '    unlet self._val',
    \   '    let self._val = r',
    \   '    return self._chain ? self : self._val',
    \   'endfunction'
    \  ], "\n")
endfor
unlet s:method

function! s:_obj.value() abort
    return self._val
endfunction

function! s:import() abort
    return deepcopy(s:_)
endfunction


" Helper:

function! s:_make_pair(x) abort
    return [a:x, call(s:_F, [a:x], {})]
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
