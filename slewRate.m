%% Slew Rate %%
att = [60 -10 0]'; % deg (Euler321)
BN = Euler3212C( deg2rad(att) );

CAM = starCamera(BN);

% 
plotflag = true;
POV = true;

f1ax = []; f2ax = []; % Initialize axes

if plotflag
    % Show Starmap %
    showSkybox(STARS);
end

% Slew Rate
for i=1:0.25:1000

    % Slew profile
    att = [30+10*i -10*sin(i) 0]'; % deg (Euler321)
    BN = Euler3212C( deg2rad(att) );

    CAM.point(BN);

    % pictureData rows: [i u v mag]
    % starEstData rows: [i xc yc zc mag]
    [pictureData,starEstData,f1ax,f2ax] = takePicture(STARS,CAM,BN,plotflag,POV,f1ax,f2ax);
    pause(0.1);

end