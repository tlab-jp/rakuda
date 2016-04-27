verify = <<EOS
1,4c1,4
< 1,ほげ１００,テストカラム１００
< 2,ほげ１０１,テストカラム１０１
< 3,ほげ200,テストカラム200
< 4,ほげ201,テストカラム201
---
> 100,ほげ１００,テストカラム１００
> 101,ほげ１０１,テストカラム１０１
> 200,ほげ200,テストカラム200
> 201,ほげ201,テストカラム201
EOS

result = `diff dist/verify/after/Test dist/verify/before/Test`

if verify == result
  puts "Success!"
  exit 0
else
  puts "Error!"
  puts result
  exit 1
end
