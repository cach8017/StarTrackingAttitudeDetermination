function CAM = createCamera(NB)
    
    % Camera is aligned with b1 axis. Rotate to find inertial camera
    % pointing axis.
    CAM.pointVector_B = [1 0 0]';
    CAM.pointVector_N = NB * CAM.pointVector_B;
    % Top of image aligns with top of camera.
    CAM.upVector_B = [0 0 1]';
    CAM.upVector_N = NB * CAM.upVector_B;
    
    % Camera parameters
    CAM.f = 2.000e3;
    CAM.umin = 0;         CAM.vmin = 0;
    CAM.umax = 1024;      CAM.vmax = 1024;
    CAM.u0 = CAM.umax/2;  CAM.v0 = CAM.vmax/2;
    CAM.k1 = 7e-13; % radial distortion coefficients of the lens
    CAM.k2 = 4e-13; % radial distortion coefficients of the lens

    % Measurement noise
    CAM.sigma_u = 0;      CAM.sigma_v = 0;
    CAM.sigma_mag = 0.01;

end