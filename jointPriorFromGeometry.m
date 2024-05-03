
%% For up to 20 hypotheses for star 1:

hypHistory = zeros(starsInFrame+1,20);

star1prior = starPriors{1};
for hyp=1:20

    allStarIDsInFrame = zeros(starsInFrame,2);

    % Retrieve ID and prior currently under investigation
    starID_i = star1prior(hyp,1);
    starPr_i = star1prior(hyp,2);

    allStarIDsInFrame(1,:) = [starID_i starPr_i];

    % Get sorted distances to neighbors again
    dxc = starEstData(:,2)-starEstData(1,2);
    dyc = starEstData(:,3)-starEstData(1,3);
    dzc = starEstData(:,4)-starEstData(1,4);

    dists = sqrt(dxc.^2 + dyc.^2 + dzc.^2)';
    sortedDists = sort(dists);

    % IF star 1 is actually starID_i, what would its neighbors be?
    for nbor=2:starsInFrame
        
        starNborprior = starPriors{nbor};

        distNbor = sortedDists(nbor);
        magNbor = starEstData(nbor,5);

        truthDists = star200NN.dict(starID_i,:);
        truthMags = mag(star200NN.ind(starID_i,:));

        [~,ind] = mink(abs(truthDists - distNbor) + abs(50*(truthMags - magNbor)), 10);

        potentialNeighbors = star200NN.ind(starID_i,ind);

        potentialNeighborPriors = 0*potentialNeighbors;
        for i=1:length(potentialNeighborPriors)
            sid = starNborprior(:,1);
            spr = starNborprior(:,2);
            potentialNeighborPriors(i) = spr(sid==potentialNeighbors(i));
        end

        [prior,ind] = max(potentialNeighborPriors);

        allStarIDsInFrame(nbor,:) = [potentialNeighbors(ind) prior];

    end

    jointprior = prod(allStarIDsInFrame(:,2));
    hypHistory(:,hyp) = [allStarIDsInFrame(:,1); jointprior];

end


[~,bestHypIndex] = max(hypHistory(end,:));
bestHyp = hypHistory(1:end-1,bestHypIndex);

%fprintf('\n True | Guess\n--------------\n');
%for i=1:starsInFrame
%     fprintf('%5d | %5d\n',starEstData(i,1),bestHyp(i));
%end


%% Attitude Determination

% Determine Attitude using Gradient Descent
% Set intial guess using two of the stars in frame
if size(starEstData,1) >= 2

    % Truth
    starInertialData = [x(starEstData(:,1)); y(starEstData(:,1)); z(starEstData(:,1))];
    [truth_sol, truth_fval] = attDet(starEstData, starInertialData);
    BbarN_KNOWN = MRP2C(truth_sol);
    BbarB_KNOWN = BbarN_KNOWN * BN';
    PRV_KNOWN = C2PRV(BbarB_KNOWN);

    % Hypothesis
    starInertialData = [x(bestHyp); y(bestHyp); z(bestHyp)];
    [hyp_sol, hyp_fval] = attDet(starEstData, starInertialData);
    BbarN_UNKNOWN = MRP2C(hyp_sol);
    BbarB_UNKNOWN = BbarN_UNKNOWN * BN';
    PRV_UNKNOWN = C2PRV(BbarB_UNKNOWN);

end

