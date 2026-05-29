function [postMesh] = makeSphPostMesh(dns, nPhi, nTheta)
%MAKESPHPOSTMESH Build the spherical post-processing mesh for one DNS case.

    postMesh = obtainSphMesh( ...
            0, pi*2, ...
            dns.theta_c, pi/2, ...
            nPhi, nTheta);
    postMesh.phi0 = 0;
    postMesh.phi1 = pi*2;
    postMesh.theta0 = dns.theta_c;
    postMesh.theta1 = pi/2;
    postMesh.nPhi = nPhi;
    postMesh.nTheta = nTheta;
    postMesh.heightInTheta = postMesh.theta1 - postMesh.theta0;
    postMesh.dTheta = postMesh.heightInTheta/(nTheta - 1);
    
end
