function R = M2(theta) 

    dtr = pi/180;
    
    ctheta = cos(dtr*theta);
    stheta = sin(dtr*theta);
    
    R = [ctheta,0,-stheta;0,1,0;stheta,0,ctheta];

return