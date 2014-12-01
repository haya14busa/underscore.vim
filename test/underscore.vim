let s:suite = themis#suite('underscore')
let s:assert = themis#helper('assert')

function! s:suite.before() abort
    let s:V = vital#of('vital')
    let s:Un = s:V.import('Underscore')
    let s:_ = s:Un.import()
endfunction

function! s:_(...) abort
    return call(s:Un.underscore, a:000)
endfunction

