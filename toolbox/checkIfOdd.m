function count = checkIfOdd(vec)


count = 0;
for i=1:length(vec)

    if mod(vec(i), 2) == 1

        count = count + 1;
        %disp("Found an odd number");
    else
        %disp("Didn't find one");
    end
    
end

end