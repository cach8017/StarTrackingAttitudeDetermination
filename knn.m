load('3Dcoordinates_stars_sorted.mat');

star200NN.dict = zeros(500,200);
star200NN.ind  = zeros(500,200);

for i=1:500

    distsI = sqrt((x-x(i)).^2 + (y-y(i)).^2 + (z-z(i)).^2);
    [sortedDist, sortedInd] = sort(distsI);

    star200NN.dict(i,:) = sortedDist(2:201); % exclude self distance
    star200NN.ind(i,:) = sortedInd(2:201);   % exclude self distance

end

save('star200NN.mat','star200NN');