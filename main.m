clear; clc;
load('3Dcoordinates_stars_sorted.mat');

%% Package star data into STARS struct
STARS.Nstars = length(x);
STARS.x = x; STARS.y = y; STARS.z = z;

%% Generate Starmap %%
showSkybox(STARS);

%% Setup and Orient Camera %%
initialAttitude = [30 0 0]'; % deg (Euler321)
BN = Euler3212C( deg2rad(initialAttitude) );
NB = BN';

CAM = createCamera(NB);

%% Take Picture
for i=1:5
    pictureData = takePicture(STARS,CAM,NB,true)
end
%% Determine Attitude using Gradient Descent
% Set intial guess using one of the stars in frame

%starInd = pictureData(1,1);
%BN_est(:,1) = [STARS.x(starInd); STARS.y(starInd); STARS.z(starInd)] / CAM.pointVector_B;

%sigma_BN_est = gradientDescent(pictureData,STARS,BN_est,learningRate,numiter);





