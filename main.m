clear; clc;
load('3Dcoordinates_stars_sorted.mat');

% Package star data into STARS struct
STARS.Nstars = length(x);
STARS.x = x; STARS.y = y; STARS.z = z;
STARS.mag = mag;

%% STAR IDENTIFICATION %%
load('star200NN.mat');

yaws = 0:1:360;
pitches = -90:1:90;
%yaws = 160;
%pitches = 70;

[YAWS, PITCHES] = meshgrid(yaws, pitches);
ROLLS = 0 * ones(size(YAWS));
HYPCOSTS = nan(size(YAWS));
TRUECOSTS = nan(size(YAWS));
NUMSTARS = nan(size(YAWS));

CAM = starCamera(eye(3));

plotflag = false; % show figures
POV = false;      % orient 3D to show POV

if plotflag
    showSkybox(STARS);
end

f1ax = []; f2ax = [];
for yy=1:length(yaws)
    for pp=1:length(pitches)

        att = [YAWS(pp,yy) PITCHES(pp,yy) ROLLS(pp,yy)]'; % deg (Euler321)
        fprintf('True initial attitude (YPR): [%.2f %.2f %.2f]\n',att');
        
        BN = Euler3212C( deg2rad(att) );
        CAM.point(BN);
        
        [pictureData,starEstData,f1ax,f2ax] = takePicture(STARS,CAM,BN,plotflag,POV,f1ax,f2ax);

        % -- Compute priors for all stars in frame -- %
        starsInFrame = size(starEstData,1);
        
        Jhist = zeros(STARS.Nstars,starsInFrame);
        
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
                    for bkmk = remainingAvailableIndex:200
                        residual = abs(sortedDists(nbor)-star200NN.dict(row,bkmk));
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
        
        % Scale costs into appropriate prior distribution
        for i=1:starsInFrame
        
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

        if starsInFrame > 0
            jointPriorFromGeometry;
            HYPCOSTS(pp,yy) = PRV_UNKNOWN(1);
            TRUECOSTS(pp,yy) = PRV_KNOWN(1);
            NUMSTARS(pp,yy) = starsInFrame;
        end

    end
end

%%
figure(3); clf;
subplot(2,2,1);
contourf(YAWS,PITCHES,abs(rad2deg(TRUECOSTS)),50,'EdgeColor','none');
ax = gca; ax.XDir = 'reverse'; ax.YDir = 'reverse';
labels(ax,{'Yaw [deg]','Pitch [deg]'},'Att. Est. Costs (KNOWN STARS): Roll = 0 deg');
clb = colorbar; axis equal;
ylabel(clb,'Att. Est. Error (deg)','FontName','Times New Roman');

subplot(2,2,2);
contourf(YAWS,PITCHES,abs(rad2deg(HYPCOSTS)),50,'EdgeColor','none');
ax = gca; ax.XDir = 'reverse'; ax.YDir = 'reverse';
fixfig(gcf);
labels(ax,{'Yaw [deg]','Pitch [deg]'},'Att. Est. Costs (UNKNOWN STARS): Roll = 0 deg');
clb = colorbar; axis equal;
ylabel(clb,'Att. Est. Error (deg)','FontName','Times New Roman');
fixfig(gcf);

subplot(2,2,3);
contourf(YAWS,PITCHES,NUMSTARS,50,'EdgeColor','none');
ax = gca; ax.XDir = 'reverse'; ax.YDir = 'reverse';
fixfig(gcf);
labels(ax,{'Yaw [deg]','Pitch [deg]'},'Number of Stars');
clb = colorbar; axis equal;
fixfig(gcf);

%% Slew Rate %%
% att = [60 -10 0]'; % deg (Euler321)
% BN = Euler3212C( deg2rad(att) );
% 
% CAM = starCamera(BN);
% 
% plotflag = true; % show figures
% POV = false;      % orient 3D to show POV
% 
% f1ax = []; f2ax = []; % Initialize axes
% 
% if plotflag
%     % Show Starmap %
%     showSkybox(STARS);
% end
% 
% % Slew Animation
% for i=1:0.05:1000
% 
%     % Slew profile
%     att = [30+10*i -10*sin(i) 0]'; % deg (Euler321)
%     BN = Euler3212C( deg2rad(att) );
% 
%     CAM.point(BN);
% 
%     % pictureData rows: [i u v mag]
%     % starEstData rows: [i xc yc zc mag]
%     [pictureData,starEstData,f1ax,f2ax] = takePicture(STARS,CAM,BN,plotflag,POV,f1ax,f2ax);
%     pause(0.1);
% 
% end

