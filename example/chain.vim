let s:V = vital#of('vital')
let s:Closure = s:V.import('Data.Closure')
let s:_ = s:V.import('Underscore').import()

echo s:_.chain(range(1,100))
    \.select('v:val % 3 == 0')
    \.tap(s:Closure.build(":echo 'len: ' . len(a:1)").to_function())
    \.map('v:val * v:val')
    \.reject('v:val < 500')
    \.drop(3)
    \.foldl(0, 'v:memo + v:val')
    \.value()
" =>
"   len: 33
"   109296

" http://underscorejs.org/#chaining
let lyrics = [
\  {'line': 1, 'words': "I'm a lumberjack and I'm okay"},
\  {'line': 2, 'words': "I sleep all night and I work all day"},
\  {'line': 3, 'words': "He's a lumberjack and he's okay"},
\  {'line': 4, 'words': "He sleeps all night and he works all day"}
\]

function! s:word_cnt(memo, val) abort
    let a:memo[a:val] = get(a:memo, a:val, 0) + 1
    return a:memo
endfunction

echo s:_.chain(lyrics)
    \.map("split(v:val.words, ' ')")
    \.flatten()
    \.foldl({}, function('s:word_cnt'))
    \.value()

" Data.Closure
echo s:_.chain(lyrics)
    \.map("split(v:val.words, ' ')")
    \.flatten()
    \.foldl({}, s:Closure.build("
        \:let a:1[a:2] = get(a:1, a:2, 0) + 1 | return a:1
    \").to_function())
    \.value()

" => {'all': 4, 'day': 2, 'and': 4, 'okay': 2, 'I': 2, 'sleeps': 1, 'He': 1, 'He''s': 1, 'a': 2, 'sleep': 1, 'works': 1, 'he': 1, 'I''m': 2, 'work': 1, 'he''s': 1, 'lumberjack': 2, 'night': 2}

" http://underscorejs.org/#chain
let stooges = [{'name': 'curly', 'age': 25}, {'name': 'moe', 'age': 21}, {'name': 'larry', 'age': 23}]
let youngest = s:_.chain(stooges)
    \.sort_by('v:val.age')
    \.map('v:val.name . " is " . v:val.age')
    \.first()
    \.value()
echo youngest
" => "moe is 21"

