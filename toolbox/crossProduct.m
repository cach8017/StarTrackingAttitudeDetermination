% cross product calculator
clc
clear

x1=input("xcomp1: ");
y1=input("ycomp1: ");
z1=input("zcomp1: ");

x2=input("\nxcomp2: ");
y2=input("ycomp2: ");
z2=input("zcomp2: ");

crossprodx = (y1*z2-z1*y2);
crossprody = -(x1*z2-z1*x2);
crossprodz = (x1*y2-y1*x2);

fprintf("\n< %d , %d , %d >\n",crossprodx,crossprody,crossprodz);
disp("AND");
fprintf("< %d , %d , %d >\n\n\n",-1*crossprodx,-1*crossprody,-1*crossprodz);

magUnitVec = (crossprodx*crossprodx+crossprody*crossprody+crossprodz*crossprodz)^0.5;

disp("Unit Vectors: " )
fprintf("\n< %f , %f , %f >\n",crossprodx/magUnitVec,crossprody/magUnitVec,crossprodz/magUnitVec);
disp("AND");
fprintf("< %f , %f , %f >\n",-1*crossprodx/magUnitVec,-1*crossprody/magUnitVec,-1*crossprodz/magUnitVec);

arrVec1x = [0,x1];
arrVec1y = [0,y1];
arrVec1z = [0,z1]; 

arrVec2x = [0,x2];
arrVec2y = [0,y2];
arrVec2z = [0,z2];

cross1x = [0,crossprodx];
cross1y = [0,crossprody];
cross1z = [0,crossprodz];

cross2x = [0,-crossprodx];
cross2y = [0,-crossprody];
cross2z = [0,-crossprodz];

plot3(arrVec1x,arrVec1y,arrVec1z,"r");
grid on
hold on
plot3(arrVec2x,arrVec2y,arrVec2z,"b");
hold on
plot3(cross1x,cross1y,cross1z,"c");
hold on
plot3(cross2x,cross2y,cross2z,"m");
hold off