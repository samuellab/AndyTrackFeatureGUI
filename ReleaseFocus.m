    function ReleaseFocus(fig)
    %From http://www.mathworks.com/matlabcentral/newsreader/view_original/868358
    % By Heiko
        set(findobj(fig, 'Type', 'uicontrol'), 'Enable', 'off');
        drawnow;
        set(findobj(fig, 'Type', 'uicontrol'), 'Enable', 'on');
    end
        