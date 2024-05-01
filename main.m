clear; clc; dfs;
load('3Dcoordinates_stars_sorted.mat');

%% Package star data into STARS struct
STARS.Nstars = length(x);
STARS.x = x; STARS.y = y; STARS.z = z;
STARS.mag = mag;

%% Generate Starmap %%
showSkybox(STARS);

%% Setup and Orient Camera %%
% initialAttitude = [60 -10 0]'; % deg (Euler321)
% BN = Euler3212C( deg2rad(initialAttitude) );
% NB = BN';
% 
% CAM = createCamera(NB);
% 
% % Slew Rate
% f1ax = []; f2ax = []; % Initialize axes
% for i=1:0.25:1000
% 
%     % Slew profile
%     attitude = [30+5*i 0 0]'; % deg (Euler321)
%     BN = Euler3212C( deg2rad(attitude) );
%     NB = BN';
% 
%     CAM = createCamera(NB);
% 
%     [pictureData,starEstData,f1ax,f2ax] = takePicture(STARS,CAM,NB,true,f1ax,f2ax);
%     pause(0.1);
% 
% end
% % pictureData: [i u v]
% % starEstData: [i xc yc zc]

%% Star Identification
load('star50NN.mat');

attitude = [60 90 0]'; % deg (Euler321)
BN = Euler3212C( deg2rad(attitude) );
NB = BN';
CAM = createCamera(NB);

[pictureData,starEstData,~,~] = takePicture(STARS,CAM,NB,true,[],[]);
starsInFrame = size(starEstData,1);

Jhist = zeros(STARS.Nstars,starsInFrame);

% For each star in the frame:
for star_i=1:starsInFrame

    dxc = starEstData(:,2)-starEstData(star_i,2);
    dyc = starEstData(:,3)-starEstData(star_i,3);
    dzc = starEstData(:,4)-starEstData(star_i,4);

    distsI = sqrt(dxc.^2 + dyc.^2 + dzc.^2)';
    sortedDists = sort(distsI);
    sortedDists = sortedDists(2:end);
    
    mag_i = starEstData(star_i,5);

    % For each row in the truth star dictionary: pair star_i's neighbors
    % with entries in that row. Sum the residuals and save as a cost.
    for row = 1:STARS.Nstars
        
        magResidual = abs(mag_i-mag(row));
        Jhist(row,star_i) = Jhist(row,star_i) + 50*magResidual;
    

        % Once a star has been "accepted" as a match with the truth star
        % dictionary, it cannot be re-used. The bookmark increments and
        % trims the remaining stars in the dictionary that can be used for
        % a match. The threshold may need to be tuned.
        remainingAvailableIndex = 1; 

        for nbor=1:length(sortedDists)
            
            residual = 0.75;
            for bkmk = remainingAvailableIndex:50
                residual = abs(sortedDists(nbor)-star50NN.dict(row,bkmk));
                if residual < 0.005 && magResidual < 3*CAM.sigma_mag
                    remainingAvailableIndex = bkmk+1;
                    break;
                else
                    residual = 0.75;
                end
            end


            % Save residual in costs
            Jhist(row,star_i) = Jhist(row,star_i) + residual;
    
        end

    end

end

% Cell array which will contain probability distribution and index for each
% LIVE hypothesis for each star
starPriors = cell(1,starsInFrame);

% Only keep LIVE hypotheses for each star ( < mean-2sigma )
% for that star
for i=1:starsInFrame

    mJ = mean(Jhist(:,i));
    stdJ = std(Jhist(:,i));
    % Save values less than the 2sigma bound (and respective indices)
    hyps = Jhist(:,i);
    
    inds = (1:500)';

    [sortedHyps, sortedInds] = sort(hyps,'ascend');
    sortedInds = inds(sortedInds);

    % Normalize using softmax function. Favors lower costs, can adjust base
    % to achieve desired scaling
    base = 0.5;
    scaleFactor = 3;
    scaledHyps = base.^(scaleFactor*sortedHyps)./sum(base.^(scaleFactor*sortedHyps));


    starPriors{i} = [sortedInds scaledHyps];

end


%% 


%% Attitude Determination

% Determine Attitude using Gradient Descent
% Set intial guess using two of the stars in frame
if size(starEstData,1) >= 2

    v1B = starEstData(1,2:4)';
    v2B = starEstData(2,2:4)';

    ind1 = starEstData(1,1);
    ind2 = starEstData(2,1);

    v1N = [x(ind1); y(ind1); z(ind1)];
    v2N = [x(ind2); y(ind2); z(ind2)];

    BbarNg = triad(v1N,v2N,v1B,v2B);
    MRPg = C2MRP(BbarNg);

    starInertialData = [x(starEstData(:,1)); y(starEstData(:,1)); z(starEstData(:,1))];

    Jg = costFunction(MRPg, starEstData(:,2:4)', starInertialData);

    [sol,fval] = fminunc(@(MRP) costFunction(MRP,starEstData(:,2:4)',starInertialData),MRPg);

    fprintf('Initial Guess: [%.12f %.12f %.12f]   Cost: %.12f\n',MRPg',Jg);
    fprintf('fminunc:       [%.12f %.12f %.12f]   Cost: %.12f\n',sol',fval);

    BbarQUEST = quest(starEstData(:,2:4)',starInertialData,ones(1,size(starInertialData,2)));
    MRPQ = C2MRP(BbarQUEST);
    
    fprintf('QUEST:         [%.12f %.12f %.12f]\n',MRPQ');


end

% Inputs:
%    sigmaBar   MRP representing estimated B/N attitude
%    stars_B    3xN stars measured from B frame
%    stars_N    3xN stars measured from N frame
% Outputs:
%    J          Scalar cost
function J = costFunction(sigmaBar, stars_B, stars_N)

    % Compute rotation matrix
    BbarN = MRP2C(sigmaBar);

    % Compute residuals
    residuals = (BbarN'*stars_B - stars_N);

    % Compute cost
    J = sum(sum(residuals.^2));
end



