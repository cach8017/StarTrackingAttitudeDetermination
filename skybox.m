%%
wipe;

load('bright_stars.mat');
load('3Dcoordinates_stars_sorted.mat');


%% Generate Starmap %%
f = figure;
scatter3(x,y,z,'white','filled');
axis vis3d;
darkMode(f);