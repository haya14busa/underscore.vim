"=============================================================================
" FILE: autoload/vital/__latest__/Underscore.vim
" AUTHOR: haya14busa
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
endfunction

function! s:_vital_depends() abort
    return ['Data.List']
endfunction

let s:_ = {}

function! s:import() abort
    return deepcopy(s:_)
endfunction

function! s:_._(value) abort
    let obj = deepcopy(self._obj)
    let obj._val = a:value
    return obj
endfunction

function! s:_.chain(value) abort
    let obj = self._(a:value)
    let obj._chain = 1
    return obj
endfunction

" Collections:

function! s:_.each(xs, f) abort
    let F = s:_.is_string(a:f) ? function(a:f) : a:f
    for x in a:xs
        call F(x, index(a:xs, x))
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
    let F = get(a:, 1, function('s:_truthy'))
    return !empty(s:_._(a:xs).filter(F))
endfunction
let s:_.any = s:_.some

function! s:_.contains(xs, value) abort
    return s:List.has(a:xs, a:value)
endfunction
let s:_.include = s:_.contains

function! s:_.sort(xs, ...) abort
    let xs = copy(a:xs)
    if empty(a:0)
        return sort(xs)
    elseif s:_.is_funcref(a:1) || a:1 is 0 || a:1 == '' || a:1 == 1 || a:1 =~# '[in]'
        return sort(xs, a:1)
    else
        return s:List.sort(xs, a:1)
    endif
endfunction

function! s:_.sort_by(xs, f) abort
    let xs = copy(a:xs)
    if s:_.is_funcref(a:f)
        let s:_F = a:f
        return s:_.chain(xs)
            \.map(function('s:_make_pair'))
            \.sort('a:a[1] ==# a:b[1] ? 0 : a:a[1] ># a:b[1] ? 1 : -1')
            \.map('v:val[0]')
            \.value()
    else
        return s:List.sort_by(xs, a:f)
    endif
endfunction

function! s:_.reverse(xs) abort
    return reverse(copy(a:xs))
endfunction

function! s:_.group_by(xs, f) abort
    if s:_.is_funcref(a:f)
        let s:_F = a:f
        let result = {}
        let list = s:_._(a:xs).map(function('s:_make_pair'))
        for x in list
            let Val = x[0]
            let key = s:_.is_string(x[1]) ? x[1] : string(x[1])
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

function! s:_.length(xs) abort
    return len(a:xs)
endfunction
let s:_.size = s:_.length

" Arrays:

" xs, n
function! s:_.take(xs, ...) abort
    let i = get(a:, 1, 1)
    if (i <= 0)
        return []
    else
        let r = a:xs[0 : max([0, i - 1])]
        return len(r) is 1 ? r[0] : r
    endif
endfunction
let s:_.first = s:_.take
let s:_.head = s:_.take

" xs, n
function! s:_.initial(xs, ...) abort
    let idx = len(a:xs) - 1 - get(a:, 1, 1)
    return idx >= 0 ? a:xs[0 : idx] : []
endfunction

function! s:_.last(xs, ...) abort
    let r = call(s:_.take, [s:_._(a:xs).reverse()] + a:000, self)
    return s:_.is_list(r) ? reverse(r) : r
endfunction

function! s:_.tail(xs, ...) abort
    return a:xs[get(a:, 1, 1):]
endfunction
let s:_.rest = s:_.tail
let s:_.drop = s:_.tail

function! s:_.compact(xs) abort
    return s:_._(a:xs).filter(function('s:_truthy'))
endfunction

function! s:_.flatten(xs, ...) abort
    return call(s:List.flatten, [a:xs] + a:000)
endfunction

function! s:_.uniq(xs) abort
    return s:_.uniq_by(a:xs, s:_.identity)
endfunction
let s:_.unique = s:_.uniq

function! s:_.uniq_by(xs, f) abort
    if s:_.is_funcref(a:f)
        let s:_F = a:f
        let list = s:_._(a:xs).map(function('s:_make_pair'))
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
let s:_.unique_by = s:_.uniq_by

function! s:_.zip(...) abort
    return call(s:List.zip, a:000)
endfunction

" @overwrite
function! s:_.pop(...) abort
    return call(s:List.pop, a:000)
endfunction

function! s:_.push(...) abort
    return call(s:List.push, a:000)
endfunction

" @overwrite
function! s:_.shift(...) abort
    return call(s:List.shift, a:000)
endfunction

function! s:_.unshift(...) abort
    return call(s:List.unshift, a:000)
endfunction

" Functions:

" TODO: test
let s:_memoizes = { 'ID' : 0 }
function! s:_memoizes.register(memoize_obj) abort
    let self.ID += 1
    let s:_memoizes[self.ID] = a:memoize_obj
    return self.ID
endfunction

let s:_memoize = { 'cache' : {} }

function! s:_memoize.new() abort
    return deepcopy(self)
endfunction

function! s:_.memoize(F, ...) abort
    let memoize = s:_memoize.new()
    let memoize.f = a:F
    let memoize.hasher = get(a:, 1, s:_.identity)
    function! memoize.memo_f(key) abort
        let key = self.hasher(a:key)
        if !has_key(self.cache, key)
            let self.cache[key] = self.f(key)
        endif
        return self.cache[key]
    endfunction
    let id = s:_memoizes.register(memoize)
    " memoize instance string
    let ins_str = "s:_memoizes['" . id . "']"
    execute join([
    \   'function! s:_memoize_' . id . '(...) abort',
    \   '    return call(' . ins_str . '.memo_f, a:000, ' . ins_str .')',
    \   'endfunction'
    \  ], "\n")
    return s:_function('s:_memoize_' . id)
endfunction

" Objects:

function! s:_.tap(obj, interceptor) abort
    call a:interceptor(a:obj)
    return a:obj
endfunction

function! s:_.is_number(x) abort
    return type(a:x) is type(0)
endfunction
function! s:_.is_float(x) abort
    return type(a:x) is type(0.0)
endfunction
function! s:_.is_string(x) abort
    return type(a:x) is type('')
endfunction
function! s:_.is_funcref(x) abort
    return type(a:x) is type(function('tr'))
endfunction
function! s:_.is_list(x) abort
    return type(a:x) is type([])
endfunction
function! s:_.is_dict(x) abort
    return type(a:x) is type({})
endfunction

function! s:_.functions(obj) abort
    return sort(filter(keys(a:obj), 's:_.is_funcref(a:obj[v:val])'))
endfunction
let s:_.methods = s:_.functions

" Util:

let s:_.TRUE = !0
let s:_.FALSE = 0

function! s:_.identity(x) abort
    return a:x
endfunction

" Chaining Obj:

let s:_._obj = { '_chain' : 0 }

" underscore object management for extention
let s:_objects = { '_ID' : 0 }
function! s:_objects.register(obj) abort
    let self._ID += 1
    let self[self._ID] = deepcopy(a:obj)
    return self._ID
endfunction

function! s:_.mixin(obj) abort
    let id = s:_objects.register(a:obj)
    for method in s:_.functions(a:obj)
        let self[method] = s:_objects[id][method]
        execute join([
        \   'function! self._obj.' . method . '(...) abort',
        \   '    let r = call(s:_objects[' . id . '].' . method . ', [self._val] + a:000, self)',
        \   '    unlet self._val',
        \   '    let self._val = r',
        \   '    return self._chain ? self : self._val',
        \   'endfunction'
        \  ], "\n")
    endfor
endfunction

" Add all of the Underscore functions to the wrapper object.
call s:_.mixin(s:_)

function! s:_._obj.value() abort
    return self._val
endfunction

function! s:_._obj.chain() abort
    let self._chain = s:_.TRUE
    return self
endfunction

function! s:_._obj.pop() abort
    let x = call(s:List.pop, [self._val])
    return self._chain ? self : x
endfunction

function! s:_._obj.shift() abort
    let x = call(s:List.shift, [self._val])
    return self._chain ? self : x
endfunction

" Helper:

" function() wrapper
if v:version > 703 || v:version == 703 && has('patch1170')
    function! s:_function(fstr) abort
        return function(a:fstr)
    endfunction
else
    function! s:_SID() abort
        return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
    endfunction
    let s:_s = '<SNR>' . s:_SID() . '_'
    function! s:_function(fstr) abort
        return function(substitute(a:fstr, 's:', s:_s, 'g'))
    endfunction
endif

let s:_F = s:_.identity
function! s:_make_pair(x) abort
    return [a:x, call(s:_F, [a:x], {})]
endfunction

function! s:_truthy(x) abort
    return (!s:_.is_number(a:x) || a:x) &&
    \      (!s:_.is_string(a:x) || a:x != "")
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
