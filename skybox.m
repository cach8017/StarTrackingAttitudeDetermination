%%
wipe;

load('bright_stars.mat');
load('3Dcoordinates_stars_sorted.mat');

Nstars = length(x);

%% Generate Starmap %%
f1 = figure(1); hold on; f1.Position = [1133 581 560 420];
plot3(x,y,z,'.','Color',[1 1 1],'MarkerSize',10);
axis vis3d;
darkMode(f1);
labels(gca,{'X','Y','Z'},'');
camzoom(0.7);

%% Setup and Orient Camera %%
%sigma0_BN = [0.0 0.0 0.0]'; % MRP
%BN0 = MRP2C(sigma0_BN);'

BN0 = Euler3212C(pi/180*[0 40 0]');
NB0 = BN0';

CAM.pointVector_N = NB0 * [1 0 0]';
CAM.upVector_N = NB0 * [0 0 1]';

CAM.f = 2.089795918367347e3;
CAM.umin = 0;         CAM.vmin = 0;
CAM.umax = 1024;      CAM.vmax = 1024;
CAM.u0 = CAM.umax/2;  CAM.v0 = CAM.vmax/2;


%% Take a Picture %%
f2 = figure(2); hold on; f2.Position = [1133 81 560 420];
axis equal; axis([0 1024 0 1024]);

for i=1:Nstars

    ihat = NB0(:,1); jhat = NB0(:,2); khat = NB0(:,3);

    starPos = [x(i) y(i) z(i)]'; % inertial star position
    if dot(starPos,CAM.pointVector_N) > 0 % Star is in front of camera
        
        u_i = CAM.umax - (CAM.f * (starPos'*jhat) / (starPos'*ihat) + CAM.u0);
        v_i = CAM.f * (starPos'*khat) / (starPos'*ihat) + CAM.v0;

        if inFOV([u_i;v_i],CAM)
            figure(2);
            plot(u_i,v_i,'.','MarkerSize',30,'Color',[1 1 1]); hold on;
            darkMode(f2);
            figure(1);
            plot3(starPos(1),starPos(2),starPos(3),'.','MarkerSize',30,'Color',[1 0 0]);
        end
    end

end

figure(1);
ax = gca; 
ax.CameraTarget = CAM.pointVector_N';
ax.CameraPosition = [0 0 0];
ax.CameraViewAngle = 40;
ax.CameraUpVector = CAM.upVector_N';

function visible = inFOV(pos, CAM)
    inHorz = pos(1) >= CAM.umin && pos(1) <= CAM.umax;
    inVert = pos(2) >= CAM.vmin && pos(2) <= CAM.vmax;
    visible = inHorz && inVert;
end
