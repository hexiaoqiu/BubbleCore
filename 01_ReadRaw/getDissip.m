function [r_c,dissipType,delta_r] = getDissip(caseRawDir)
%GETDISSIP Read legacy Frozen Top Bubble dissipation parameters.
%   This three-output interface is retained for historical FTB utilities.
%   It now checks TYPOBS before interpreting dissip.dat, so a nonlinear
%   Rayleigh parameter file can never be mistaken for the FTB format.
%   New model-aware code should use GETBUBBLEPLUSMODEL followed by
%   GETDISSIPPARAMETERS.

    model = getBubblePlusModel(caseRawDir);
    dissip = getDissipParameters(caseRawDir,model);

    if model.isFTB
        r_c = dissip.r_c;
        dissipType = dissip.dissipType;
        delta_r = dissip.delta_r;
    else
        r_c = NaN;
        dissipType = NaN;
        delta_r = NaN;
    end
end
