function showSkybox(STARS)

    f1 = figure(1); clf; hold on; 
    f1.Position = [1133 581 560 420]; % Set default figure position
    f1.Name = "Skybox";
    
    plot3(STARS.x,STARS.y,STARS.z,'.','Color',[1 1 1],'MarkerSize',10);
    axis vis3d;
    darkMode(f1);
    labels(gca,{'X','Y','Z'},'');
    
    % Zoom out a bit
    camzoom(0.6);
    view(-30,30);

    fixfig(gcf); grid off;
end