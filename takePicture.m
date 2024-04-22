function [pictureData, starEstData] = takePicture(STARS,CAM,NB,plotflag)

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
    % Create container for imaged stars [index xc yc zc]
    starEstData = [];

    v_u = CAM.sigma_u*randn(1); % MOVE INSIDE THE FOR LOOP - TO HAVE NOISE FOR EACH STAR
    v_v = CAM.sigma_v*randn(1);

    for i=1:STARS.Nstars
    
        ihat = NB(:,1); jhat = NB(:,2); khat = NB(:,3);
    
        starPos = [STARS.x(i) STARS.y(i) STARS.z(i)]'; % Inertial star position

        if dot(starPos,CAM.pointVector_N) > 0 % If star is in front of camera:
            
            % Pinhole model measurement (including measurement noise)
            u_i = CAM.umax - (CAM.f * (starPos'*jhat) / (starPos'*ihat) + CAM.u0 + v_u);
            v_i = CAM.f * (starPos'*khat) / (starPos'*ihat) + CAM.v0 + v_v;
    
            u_i = round(u_i);
            v_i = round(v_i);
            % du = u_i - CAM.u0; 
            % dv = v_i - CAM.v0; 
            % k = 0.025;
            % u_i = u_i - k*du; 
            % v_i = v_i - k*dv; 

            if inFOV([u_i;v_i],CAM)
                if plotflag
                    % Plot projected point on image
                    figure(2);
                    plot(u_i,v_i,'.','MarkerSize',30,'Color',[1 1 1]); hold on;
                    darkMode(f2);
                    % Plot imaged star on skybox
                    figure(1);

                    % Recover inertial coordinate for plotting purposes
                    % v_b (measurement frame) 

                    % Incorporate Distortion: Distorted 2D pixels 
                    % Eq (5) in http://mesh.brown.edu/3DP-2018/calibration.html
                    r_squared = (u_i-CAM.u0)^2 + (v_i - CAM.v0)^2; 
                    distortion_factor = 1/(1 + CAM.k1 * r_squared + CAM.k2 * r_squared^2);
           
                    %u_d = u_i * distortion_factor;
                    %v_d = v_i * distortion_factor;
                    
                    % 3D Coordinates in Body Frame
                    yc = -distortion_factor*(u_i-CAM.u0)/CAM.f;
                    zc =  distortion_factor*(v_i-CAM.v0)/CAM.f;
                    xc = sqrt(1-yc^2-zc^2); % normalize range by 1 
                    inertial = NB * [xc;yc;zc];
                    plot3(inertial(1),inertial(2),inertial(3),'.','MarkerSize',30,'Color',[1 0 0]);


                end



                
                % Save measurements from image
                pictureData = [pictureData; i, u_i, v_i];
                starEstData = [starEstData; i, xc, yc, zc];

            end

        end
    
    end
    
    if plotflag
        plotBoundingBox(CAM,NB); 
    end

    % Orient skybox to show imaged region
    figure(1);
    ax = gca; 
    ax.CameraTarget = CAM.pointVector_N';
    ax.CameraPosition = [0 0 0];
    ax.CameraViewAngle = 40;
    ax.CameraUpVector = CAM.upVector_N';

end


function plotBoundingBox(CAM,NB)

    N = 20;

    us = [CAM.umin*ones(1,N),linspace(CAM.umin,CAM.umax,N),CAM.umax*ones(1,N),flip(linspace(CAM.umin,CAM.umax,N))];
    vs = [linspace(CAM.vmin,CAM.vmax,N),CAM.vmax*ones(1,N),flip(linspace(CAM.vmin,CAM.vmax,N)),CAM.vmin*ones(1,N)];

    % Incorporate Distortion:
    r_squared = (us - CAM.u0).^2 + (vs - CAM.v0).^2;  
    distortion_factor = 1 ./ (1 + CAM.k1 * r_squared + CAM.k2 * r_squared.^2);

    ys = -distortion_factor*(us-CAM.u0)/CAM.f;
    zs =  distortion_factor*(vs-CAM.v0)/CAM.f;
    xs = sqrt(1 - ys.^2 - zs.^2);
    
    inertialPos = NB * [xs; ys; zs];

    figure(1);
    plot3(inertialPos(1,:),inertialPos(2,:),inertialPos(3,:),'-','Color','y');

end