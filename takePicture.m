function [pictureData,starEstData,f1ax,f2ax] = takePicture(STARS,CAM,NB,plotflag,f1ax,f2ax)

    if plotflag
        % Clear skybox
        if isempty(f1ax)
            figure(1); f1ax=gca; 
        end

        chil = f1ax.Children;
        for j=1:length(chil)
            if chil(j).DisplayName == "meas"
                delete(chil(j));
            end
        end
    
        % Set up image figure
        if isempty(f2ax)
            f2 = figure(2); f2ax=gca; 
            hold on; f2ax.Box='on';
            f2.Position = [1133 81 560 420]; f2.Name = "Image";
            axis equal; axis([0 1024 0 1024]); % Image bounds
            labels(gca,{'$u$ [px]','$v$ [px]'},'');
            fixfig(figure(2)); grid off;
            darkMode(f2);
        end

        chil = f2ax.Children;
        for i=1:length(chil)
            delete(chil(i));
        end

    end

    % Create container for imaged stars [index u v]
    pictureData = [];
    % Create container for imaged stars [index xc yc zc]
    starEstData = [];
    % Create container for imaged stars [index xn yn zn]
    starInertial = [];

    for i=1:STARS.Nstars
    
        ihat = NB(:,1); jhat = NB(:,2); khat = NB(:,3);
    
        % True star position and magnitude
        starPos = [STARS.x(i) STARS.y(i) STARS.z(i)]'; % Inertial star position
        starMag = STARS.mag(i);

        if dot(starPos,CAM.pointVector_N) > 0 % If star is in front of camera:
            
            % Pixel noise (from finding pixel location in bright area)
            v_u = CAM.sigma_u*randn(1);
            v_v = CAM.sigma_v*randn(1);

            % Pinhole model measurement (including measurement noise)
            u_i = CAM.umax - (CAM.f * (starPos'*jhat) / (starPos'*ihat) + CAM.u0 + v_u);
            v_i = CAM.f * (starPos'*khat) / (starPos'*ihat) + CAM.v0 + v_v;

            if inFOV([u_i;v_i],CAM)

                % Incorporate Distortion: Distorted 2D pixels 
                % Eq (5) in http://mesh.brown.edu/3DP-2018/calibration.html
                r_squared = (u_i-CAM.u0)^2 + (v_i - CAM.v0)^2; 
                distortion_factor = 1/(1 + CAM.k1 * r_squared + CAM.k2 * r_squared^2);
                
                % 3D Coordinates in Body Frame
                yc = -distortion_factor*(u_i-CAM.u0)/CAM.f;
                zc =  distortion_factor*(v_i-CAM.v0)/CAM.f;
                xc = sqrt(1-yc^2-zc^2); % normalize range by 1 
                inertial = NB * [xc;yc;zc];

                % Add noise to magnitude
                starMag = starMag+CAM.sigma_mag*randn(1);

                % Save measurements from image
                pictureData = [pictureData; i, u_i, v_i, starMag];
                starEstData = [starEstData; i, xc, yc, zc, starMag];
                starInertial = [starInertial; i, inertial(1), inertial(2), inertial(3)];

            end

        end
    
    end
    
    if plotflag
        % Plot projected point on image
        plot(f2ax,pictureData(:,2)',pictureData(:,3)','.','MarkerSize',20,'Color',[1 1 1]); hold on;

        % Plot imaged star on skybox
        plot3(f1ax,starInertial(:,2)',starInertial(:,3)',starInertial(:,4)','.','MarkerSize',20,'Color',[1 0 0],'DisplayName','meas');
   

        plotBoundingBox(CAM,NB,f1ax); 

        % Orient skybox to show imaged region 
        f1ax.CameraTarget = CAM.pointVector_N';
        f1ax.CameraPosition = [0 0 0];
        f1ax.CameraViewAngle = 40;
        f1ax.CameraUpVector = CAM.upVector_N';
    end

end


function plotBoundingBox(CAM,NB,f1ax)

    % Clear previous bounding box
    chil = f1ax.Children;
    for i=1:length(chil)
        if chil(i).DisplayName == "view" || chil(i).DisplayName == "box"
            delete(chil(i));
        end
    end

    N = 20;

    us = [CAM.umin*ones(1,N),linspace(CAM.umin,CAM.umax,N),CAM.umax*ones(1,N),flip(linspace(CAM.umin,CAM.umax,N))];
    vs = [linspace(CAM.vmin,CAM.vmax,N),CAM.vmax*ones(1,N),flip(linspace(CAM.vmin,CAM.vmax,N)),CAM.vmin*ones(1,N)];

    % Incorporate Distortion:
    r_squared = (us - CAM.u0).^2 + (vs - CAM.v0).^2;  
    distortion_factor = 1 ./ (1 + CAM.k1 * r_squared + CAM.k2 * r_squared.^2);

    ys = -distortion_factor.*(us-CAM.u0)/CAM.f;
    zs =  distortion_factor.*(vs-CAM.v0)/CAM.f;
    xs = sqrt(1 - ys.^2 - zs.^2);
    
    inertialPos = NB * [xs; ys; zs];

    plot3(f1ax,inertialPos(1,:),inertialPos(2,:),inertialPos(3,:),'-','Color','y','DisplayName','box');

    for i=[1,N+1,2*N+1,3*N+1]
        plot3(f1ax,[0 inertialPos(1,i)],[0 inertialPos(2,i)],[0 inertialPos(3,i)],'--','Color',[0.6 0.6 0.6],'DisplayName','view');
    end

end