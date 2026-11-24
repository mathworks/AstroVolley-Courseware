function [vveci,vvecf,df,a,e] = lambertTargeting(mu,rveci,rvecf,dt0,direc,tol)

%LAMBERTTARGETING Solves Lambert's problem using universal variables (f and g)
%
%   [vveci,vvecf,df,a,e] = LAMBERTTARGETING(mu,rveci,rvecf,dt,direc)
%      vveci = initial velocity vector for  conic trajectory between rveci and rvecf
%      vvecf = final   velocity vector from conic trajectory between rveci and rvecf
%      df    = transfer angle, difference in true anomaly (degrees)
%      a     = semi-major axis of transfer orbit
%      e     = eccentricity of transfer orbit
%      mu    = gravitational constant
%      rveci = initial position vector
%      rvecf = final position vector
%      dt    = transfer time (seconds)
%      direc = direction from rveci to rvecf (positive = short [default], negative = long)
%
%   Vallado, "Fundamentals of Astrodynamics and Applications" (Sec. 7.6, Alg. 55)

if ~exist('direc','var')
    direc = 1;
end

if ~exist('tol','var')
    tol = 1e-12;
end

ri = norm(rveci);  % initial position vector magnitude
rf = norm(rvecf);  % final   position vector magnitude

cosdf = dot(rveci,rvecf)/(ri*rf);
sindf = sign(direc)*sqrt(1 - cosdf^2);
df = atan2(sindf,cosdf)*180/pi;
df = df + 360*(df<0);
    
A = sign(direc)*sqrt(ri*rf*(1 + cosdf));
if (A == 0)
    error('Unique transfer orbit for the given parameters cannot be found.');
end

% initialize psi and upper and lower limits
psi = 0; c2 = 1/2; c3 = 1/6;
psiu = 4*pi*pi; psil = -4*pi; dt = Inf; i = 0;
while (abs(dt - dt0) > tol)
    y = ri + rf + A*(psi*c3 - 1)/sqrt(c2);
    
    j = 0;
    while ((A > 0) && (y < 0))
        psi = 0.8*(1 - (ri + rf)*sqrt(c2)/A)/c3; % solve y eqn for y = 0
        [c2,c3] = getc2c3(psi);
        psil = psi;
        y = ri + rf + A*(psi*c3 - 1)/sqrt(c2);
        j = j + 1;
        if (j > 10)
            break
        end
    end
    
    chi = sqrt(y/c2);
    dt  = ((chi^3)*c3 + A*sqrt(y))/sqrt(mu);
    if (dt <= dt0)
        psil = psi;
    else
        psiu = psi;
    end
    psi = (psiu + psil)/2;
    [c2,c3] = getc2c3(psi);
    
    i = i + 1;
    if (i == 100)
        error(['Algorithm has not converged after ' int2str(i) ...
            ' iterations (dt error = ' num2str(abs(dt - dt0)) ...
            ', tol = ' num2str(tol) ' seconds).']);
    end
end

f     = 1 - y/ri;
gdot  = 1 - y/rf;
g     = A*sqrt(y/mu);

vveci = (     rvecf - f*rveci)/g;
vvecf = (gdot*rvecf -   rveci)/g;

vi = norm(vveci);
a  = 1/(2/ri - vi*vi/mu);
e  = norm(((vi^2 - mu/ri)*rveci - dot(rveci,vveci)*vveci)/mu);

end % lambertTargeting function

%=========================================================================%

function [c2,c3] = getc2c3(psi)

% Vallado, "Fundamentals of Astrodynamics and Applications" (Sec. 2.2, Alg. 1)

if (psi > 1e-9)
    c2 = (1 - cos(sqrt(psi)))/psi;
    c3 = (sqrt(psi) - sin(sqrt(psi)))/sqrt(psi^3);

elseif (psi < -1e-9)
    c2 = (1 - cosh(sqrt(-psi)))/psi;
    c3 = (sinh(sqrt(-psi)) - sqrt(-psi))/sqrt((-psi)^3);

else
    c2 = 1/2;
    c3 = 1/6;
end

end % getc2c3 function