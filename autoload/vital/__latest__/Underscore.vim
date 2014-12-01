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

let s:_ = {}

function! s:_(value) abort
    let obj = deepcopy(s:_obj)
    let obj._val = a:value
    return obj
endfunction

function! s:_.chain(value) abort
    let obj = s:_(a:value)
    let obj._chain = 1
    return obj
endfunction

function! s:_.filter(f) abort
    return type(a:f) ==# type('')
    \   ? filter(self._val, a:f)
    \   : filter(self._val, 'a:f(v:val)')
endfunction

let s:_obj = { '_chain' : 0 }

for s:method in keys(s:_)
    execute join([
    \   'function! s:_obj.' . s:method . '(...) abort',
    \   '    let r = call(s:_.' . s:method . ', a:000, self)',
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

function! s:make() abort
    return s:_
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
