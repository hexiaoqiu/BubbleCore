function postMesh = makeSphPostMeshFTB(dns, nPhi, nTheta)
%MAKESPHPOSTMESHFTB Build a spherical post-processing mesh for the FTB model.
%   POSTMESH = MAKESPHPOSTMESHFTB(DNS, NPHI, NTHETA) builds the mesh from
%   the frozen-top boundary DNS.THETA_C to the equator at pi/2.

    postMesh = obtainSphMesh( ...
        0, 2*pi, ...
        dns.theta_c, pi/2, ...
        nPhi, nTheta);
    postMesh.phi0 = 0;
    postMesh.phi1 = 2*pi;
    postMesh.theta0 = dns.theta_c;
    postMesh.theta1 = pi/2;
    postMesh.nPhi = nPhi;
    postMesh.nTheta = nTheta;
    postMesh.heightInTheta = postMesh.theta1 - postMesh.theta0;
    postMesh.dTheta = postMesh.heightInTheta/(nTheta - 1);
end
