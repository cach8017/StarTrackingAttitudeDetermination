%%--------------------------------------------------------------------------
%   Trapezoidal Integral                                      
%      Author: Jack Fox                                                    
%        Date: 04/22/2023                                                  
%%--------------------------------------------------------------------------  
%   Inputs:                                                                
%      x             =   x values
%      y             =   y values
%                                                                      
%   Outputs:                                                               
%      res           =   integral estimate using the sum of the averages of
%                        each interval times the interval size
%%--------------------------------------------------------------------------
function res = trapezoidalIntegral(x,y)
    
    res = 0;
    for i=1:length(x)-1
        res = res + 0.5*(y(i+1)+y(i)) * (x(i+1)-x(i));
    end

end