clear; clc; dfs;
load('3Dcoordinates_stars_sorted.mat');

%% Package star data into STARS struct
STARS.Nstars = length(x);
STARS.x = x; STARS.y = y; STARS.z = z;

%% Generate Starmap %%
showSkybox(STARS);

%% Setup and Orient Camera %%
initialAttitude = [60 -10 0]'; % deg (Euler321)
BN = Euler3212C( deg2rad(initialAttitude) );
NB = BN';

CAM = createCamera(NB);

%% Take Picture
f1ax = []; f2ax = []; % Initialize axes
for i=1:1%0.25:1000

    % Slew profile
    initialAttitude = [30+5*i 40+10*cos(i/4) 5*i]'; % deg (Euler321)
    BN = Euler3212C( deg2rad(initialAttitude) );
    NB = BN';
    
    CAM = createCamera(NB);

    [pictureData,starEstData,f1ax,f2ax] = takePicture(STARS,CAM,NB,true,f1ax,f2ax);
    pause(0.1);

end
% pictureData: [i u v]
% starEstData: [i xc yc zc]

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



