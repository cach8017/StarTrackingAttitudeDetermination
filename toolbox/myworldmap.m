function myworldmap(ptype,aux)

if(nargin<1) ptype=3; end;
if(nargin<2) aux=0; end

if(ptype==1)
   load topo
   topo=wrap(topo,0,180);
   surface((-179.5:179.5),(-89.5:89.5),topo);
   colormap(topomap1);
   shading flat
   set(gca, ...
      'NextPlot','add', ...
      'Visible','off');
   axis equal
   axis([-180 180 -85 85]);
   axis on
   grid on
elseif(ptype==2)
   load topo
   topo=wrap(topo,0,180);
   surface((-179.5:179.5),(-89.5:89.5),sign(topo));
   
   landclr=[255 204 153]/255*.9; %tan
   seaclr=[153 204 255]/255*.9;  %blue
   clrmap=ones(32,1)*seaclr;
   clrmap=[clrmap; ones(32,1)*landclr];
   colormap(clrmap);   
   shading flat
   set(gca, ...
      'NextPlot','add', ...
      'Visible','off');
   axis equal
   axis([-180 180 -85 85]);
   axis on
   grid on
else
   center=aux;
   if( center==0 )
     load topo
     topo=wrap(topo,0,180);
     contour((-179.5:179.5),(-89.5:89.5),topo,[0 0],'k');
     axis equal
     axis([-180 180 -85 85]);
     grid on
   end
   if( center ~=0 )
     dlon=center;
     load topo
     topo=wrap(topo,0,180);
     topo=wrap(topo,0,dlon);
     contour((-179.5+dlon:179.5+dlon),(-89.5:89.5),topo,[0 0],'k');
     axis equal
     axis([-180+dlon 180+dlon -85 85]);
     grid on
   end
end

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


