function darkMode(f)
    set(f,'Color',[0 0 0]);

    for i=1:length(f.Children)
        if isa(f.Children(i),'matlab.graphics.axis.Axes')
            ax = f.Children(i);
            set(ax,'XColor',[1 1 1]);
            set(ax,'YColor',[1 1 1]);
            set(ax,'ZColor',[1 1 1]);
            set(ax,'GridColor',[0.8 0.8 0.8]);
            set(ax,'Color',[0 0 0]);
            set(ax.Title,'Color',[1 1 1]);
            set(ax.Legend,'Color',[0.15 0.15 0.15],'EdgeColor',[1 1 1],'TextColor',[1 1 1]);
        end

    end
end