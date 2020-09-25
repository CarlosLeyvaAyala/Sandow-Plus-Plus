--x = 2147483647
x = 0
m = 6

for i = 1, 15 do
    print (x)
    x = (x + 1) % m
end

print(6 % 4 == 0)