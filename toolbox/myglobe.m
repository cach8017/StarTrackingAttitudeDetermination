function myglobe(ptype)

if(nargin<1) ptype=1; end

   load topo
   topo=wrap(topo,0,180);
	
   %%% Earth Radius in meters %%%
   re=6378137;
   dtr=pi/180;
	
   %%% Map onto Oblate Spheroid Earth %%%
   gdlat=dtr*[-90:7.5:90];
   gdlon=dtr*[-180:15:180];
	
   [lon,lat]=meshgrid(gdlon,gdlat);

   clat = cos(lat);
   slat = sin(lat);
   clon = cos(lon);
   slon = sin(lon);
   
   xx = re*clat.*clon;
   yy = re*clat.*slon;
   zz = re*slat;

   clf
   
   if(ptype==1)
      wh=surface(xx,yy,zz,'FaceColor','texture','CData',topo);
      colormap(topomap1);
   else
      wh=surface(xx,yy,zz,'FaceColor','texture','CData',sign(topo));
      if(ptype==2)
          landclr=[255 204 153]/255*.9; %tan
          seaclr=[153 204 255]/255*.9;  %blue
      elseif(ptype==3)
          landclr=[153 255 153]/255*.7; %green
          seaclr=[153 217 255]/255*.9;  %blue
      elseif(ptype==4)
          landclr=[1 1 1]*.4;  %gray
          seaclr=[1 1 1]*.9;   %gray
      else
          landclr=[1 1 1]*.4; %gray
          seaclr=[1 1 1];     %white
      end
      clrmap=ones(32,1)*seaclr;
      clrmap=[clrmap; ones(32,1)*landclr];
      colormap(clrmap);   
   end
   
   % Now view the globe so the Greenwich meridian is directly
   % facing the viewer
   view(90,25);
%    set(gca,'NextPlot','add','Visible','off');
   axis equal
   grid on
   shading flat
   
return

function wmat = wrap(xmat,drow,dcol)
% WRAP - Shifts data within a matrix by delta row and delta col,
%        while wrapping data to backfill matrix.
%
% wmat = WRAP(xmat,drow,dcol) or
% wmat = WRAP(xmat,[drow dcol])
% Author: Matt Fox, March 2000
%
% See also: SHIFT

[mrows,ncols]=size(xmat);

if(nargin==1) shmat=xmat; return; end
if(nargin==2)
  szd=prod(size(drow));
  if( szd == 2 )dcol=drow(2); drow=drow(1); end
  if( szd==1 ) 
    dcol=0;
    if( mrows==1 & ncols~=1 ) dcol=drow; drow=0; end
  end
end

drow=rem(drow,mrows);
dcol=rem(dcol,ncols);

ind=(1:mrows*ncols)';
ind=reshape(ind,mrows,ncols);

mind=(1:mrows)';
nind=(1:ncols)';

ind=[ind ind ind; ind ind ind; ind ind ind];

mstart = mrows+1-drow;
nstart = ncols+1-dcol;
mend   = mstart+mrows-1;
nend   = nstart+ncols-1;

sind = ind(mstart:mend,nstart:nend);
sind = reshape(sind,mrows*ncols,1);
wmat = xmat(sind);
wmat = reshape(wmat,mrows,ncols);

return
