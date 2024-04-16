function trimmed = trimZeros(vec,option)

    if option == "all"
        %trim all zeros:
        trimmed = vec(find(vec,1,'first'):find(vec,1,'last'));
    elseif option == "leading"
        %trim leading zeros:
        trimmed = vec(find(vec,1,'first'):length(vec));
    elseif option == "trailing"
        %trim trailing zeros:
        trimmed = vec(1:find(vec,1,'last'));
    else
        disp("Valid flags are: 'all', 'leading', 'trailing'")
    end
end

