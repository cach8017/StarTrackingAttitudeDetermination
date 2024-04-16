function R = M1(phi) 
    
    dtr = pi/180;

    cphi = cos(dtr*phi);
    sphi = sin(dtr*phi);
    
    R = [1,0,0;0,cphi,sphi;0,-sphi,cphi];

return