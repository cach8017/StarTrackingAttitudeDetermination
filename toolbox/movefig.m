function movefig(f,side)
    
    % move figure to side of screen

    if(strcmpi(side,'r') || strcmpi(side,'right'))
        f.Position = [769.8 41.8 766.4 740.8];
    elseif(strcmpi(side,'l') || strcmpi(side,'left'))
        f.Position = [1.8 41.8 766.4 740.8];
    elseif(strcmpi(side,'f') || strcmpi(side,'full'))
        f.Position = [1 41 1537 748.8];
    elseif(strcmpi(side,'tvl') || strcmpi(side,'tvleft'))
        f.Position = [-3119 205.8 960 957.6];
    elseif(strcmpi(side,'tvr') || strcmpi(side,'tvright'))
        f.Position = [-2159 205.8 960 957.6];
    elseif(strcmpi(side,'vert'))
        f.Position = [-1199 187.4 1200 1804.8];
    elseif(strcmpi(side,'tvfull'))
        f.Position = [-3119 205.8 1920 964.8];
    end

end