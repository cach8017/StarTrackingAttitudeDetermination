function R = M3(psi) 

    dtr = pi/180;
    
    cpsi = cos(dtr*psi);
    spsi = sin(dtr*psi);
    
    R = [cpsi,spsi,0;-spsi,cpsi,0;0,0,1];

return