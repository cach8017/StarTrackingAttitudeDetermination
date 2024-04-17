function pictureData = takePicture(STARS,CAM,NB,plotflag)

    if plotflag
        % Clear skybox
        figure(1);
        if length(get(gca,'Children')) > 1
            delete(gca().Children(1));
        end
    
        % Set up figure
        f2 = figure(2); clf; hold on; 
        f2.Position = [1133 81 560 420]; f2.Name = "Image";
        axis equal; axis([0 1024 0 1024]); % Image bounds
        labels(gca,{'$u$ [px]','$v$ [px]'},'');
        fixfig(figure(2)); grid off;
    end

    % Create container for imaged stars [index u v]
    pictureData = [];
    
    for i=1:STARS.Nstars
    
        ihat = NB(:,1); jhat = NB(:,2); khat = NB(:,3);
    
        starPos = [STARS.x(i) STARS.y(i) STARS.z(i)]'; % Inertial star position

        if dot(starPos,CAM.pointVector_N) > 0 % If star is in front of camera:
            
            % Pinhole model measurement (including measurement noise)
            u_i = CAM.umax - (CAM.f * (starPos'*jhat) / (starPos'*ihat) + CAM.u0 + CAM.sigma_u*randn(1));
            v_i = CAM.f * (starPos'*khat) / (starPos'*ihat) + CAM.v0 + CAM.sigma_v*randn(1);
    
            if inFOV([u_i;v_i],CAM)
                if plotflag
                    % Plot projected point on image
                    figure(2);
                    plot(u_i,v_i,'.','MarkerSize',30,'Color',[1 1 1]); hold on;
                    darkMode(f2);
                    % Plot imaged star on skybox
                    figure(1);
                    plot3(starPos(1),starPos(2),starPos(3),'.','MarkerSize',30,'Color',[1 0 0]);
                end
                
                % Save measurements from image
                pictureData = [pictureData; i, u_i, v_i];
            end
        end
    
    end
    

    % % Orient skybox to show imaged region
    % figure(1);
    % ax = gca; 
    % ax.CameraTarget = CAM.pointVector_N';
    % ax.CameraPosition = [0 0 0];
    % ax.CameraViewAngle = 40;
    % ax.CameraUpVector = CAM.upVector_N';

end