clear
dfs

n = [10 1];
d = [1 100];

% numerators
num = n(1,:);
if length(n(:,1))>1
    for i=2:length(n(:,1))
        num = conv(num, n(i,:));
    end
end

% denominators
den = d(1,:);
if length(d(:,1))>1
    for i=2:length(d(:,1))
        den = conv(den, d(i,:));
    end
end

% bode plot
bode(num,den)
grid on
