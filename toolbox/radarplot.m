function radarplot(data,altnames,catlabels,indices,fs)

    numCat = size(data,2);
    numSeries = size(data,1);

    %figure;
    for i=1:numSeries
    %subplot(1,numSeries,i);

        figure;
    
        for rho=indices
            thetas = pi/2+[0 2*pi/numCat.*(1:numCat)];
            plot(rho*cos(thetas),rho*sin(thetas),'-','Color',[0.5 0.5 0.5]);
            hold on;
        end
    
        grid off; axis equal;
        ax = gca; ax.XTick = []; ax.YTick = []; ax.FontName = 'Times New Roman'; ax.FontSize = 25;
        limFac = 1.4;
        ax.XLim = [-limFac*indices(end) limFac*indices(end)]; 
        ax.YLim = [-limFac*indices(end) limFac*indices(end)];
    
    
        
        %for i=1:numSeries
            patch([data(i,:) data(i,1)].*cos(thetas),[data(i,:) data(i,1)].*sin(thetas),mlc(i),'FaceAlpha',0.7);
        %end
    
        % labels
        for j=1:numCat
            text(1.2*indices(end)*cos(thetas(j)),1.2*indices(end)*sin(thetas(j)),catlabels{j},'FontName','Times New Roman','HorizontalAlignment','center','FontSize',fs);
        end

        xlabel(altnames{i});
    end

end