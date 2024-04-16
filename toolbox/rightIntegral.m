%%--------------------------------------------------------------------------
%   Right Integral                                      
%      Author: Jack Fox                                                    
%        Date: 04/22/2023                                                  
%%--------------------------------------------------------------------------  
%   Inputs:                                                                
%      x             =   x values
%      y             =   y values
%                                                                      
%   Outputs:                                                               
%      res           =   integral estimate using sum of the right values of 
%                        each interval times their interval size
%%--------------------------------------------------------------------------
function res = rightIntegral(x,y)
    
    res = 0;
    for i=1:length(x)-1
        res = res + y(i+1) * (x(i+1)-x(i));
    end

end