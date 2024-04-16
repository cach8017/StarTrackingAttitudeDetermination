function f = calcFact(num)

f = 1;
while num > 0

    f = f * num;
    num = num - 1;
    %disp("ran once");

end

end