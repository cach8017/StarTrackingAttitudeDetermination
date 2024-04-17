function visible = inFOV(pos, CAM)
    inHorz = pos(1) >= CAM.umin && pos(1) <= CAM.umax;
    inVert = pos(2) >= CAM.vmin && pos(2) <= CAM.vmax;
    visible = inHorz && inVert;
end