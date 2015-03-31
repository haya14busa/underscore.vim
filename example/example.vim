let s:V = vital#of('vital')
let s:Underscore = s:V.import('Underscore')
let s:Closure = s:V.import('Data.Closure')
let s:_ = s:Underscore.import()

function! s:_(...) abort
    return call(s:_._, a:000, s:_)
endfunction

echo s:_(range(10)).reject('v:val < 5')

function! Echo(x, ...) abort
    echo a:x
endfunction

function! Add(x, y) abort
    return a:x + a:y
endfunction

echo s:_.chain(range(10))
    \.collect('v:val + 1')
    \.initial()
    \.tap(s:Closure.build(":echo 'initial: ' . string(a:1) ").to_function())
    \.collect('v:val * v:val')
    \.tap(s:Closure.build(":echo 'power: ' . string(a:1) ").to_function())
    \.select('v:val > 30')
    \.tap(s:Closure.build(":echo 'x > 30: ' . string(a:1) ").to_function())
    \.foldl(0, 'v:memo + v:val')
    \.value()

echo '==='
echo s:_.chain(range(1,10))
    \.foldl(1, 'v:memo * 2')
    \.value()
echo '==='
echo 'result: ' . s:_.chain(range(1,100))
    \.select('v:val % 3 == 0')
    \.tap(s:Closure.build(":echo 'len: ' . len(a:1)").to_function())
    \.map('v:val * v:val')
    \.drop(3)
    \.foldl(0, 'v:memo + v:val')
    \.value()
echo '==='

echo s:_.chain(range(10))
    \.collect('v:val * 2')
    \.select('v:val % 3 == 0')
    \.each(function('Echo'))
    \.collect('v:val * 10')
    \.reduce(0, function('Add'))
    \.value()

echo s:_(range(1,10)).reduce(0, 'v:memo + v:val')

echo s:_.is_funcref('hoge')
echo s:_.is_funcref(function('tr'))

echo '-'
echo s:_(range(1, 100)).find(-1, 'v:val % 33 == 0')
echo s:_(range(1, 100)).select('v:val % 33 == 0')

echo s:_(range(10)).select('v:val % 2 == 0')
echo s:_(range(10)).reject('v:val % 2 == 0')

echo s:_([1,1,1,1,0]).filter('v:val')
echo s:_([1,1,1,1,0]).every()
echo s:_([1,1,1,1,1]).every()
echo s:_([2,4,6]).every('v:val % 2 == 0')
echo s:_([2,4,7]).every('v:val % 2 == 0')
echo s:_([2,4,7]).some('v:val % 2 == 0')


echo s:_([2,4,6]).map(s:_.identity)

echo s:_([2,4,6]).contains(4)

echo s:_([1,-10,-3,-4,5]).sort()
echo s:_([1,-10,-3,-4,5]).sort_by(function('abs'))
echo s:_.chain([1,-10,-3,-4,5])
    \.sort_by(function('abs'))
    \.map('v:val + 5')
    \.sort('n')
    \.value()
    " \.reverse()

echo s:_(['a', 'b', 'ab', 'bc']).group_by('len(v:val)')
echo s:_(['a', 'b', 'ab', 'bc']).group_by(function('len'))


echo s:_.chain(range(1,9) + range(5,15))
    \.uniq()
    \.value()

echo s:_.chain(range(1,9) + range(5,15))
    \.tap(s:Closure.build(':echo "==="').to_function())
    \.tap(s:Closure.build(':echo a:1').to_function())
    \.uniq()
    \.tap(s:Closure.build(':echo a:1').to_function())
    \.tap(s:Closure.build(':echo "==="').to_function())
    \.value()

echo s:_.chain([ ['moe', 'larry', 'curly'], [30, 40, 50], [1, 0, 0] ])
    \.zip()
    \.value()

