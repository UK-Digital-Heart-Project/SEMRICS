function WI = pft_WeightedImage(Mo, T1, T2, TR, TE, NoisePC)

% Avoid areas where any of the maps is zero
Area = (Mo > 0) & (T1 > 0) & (T2 > 0);

% Create a 2D array for the current slice
WI = zeros(size(Mo), 'double');

% Add some precision to the data
pd = double(Mo);
t1 = double(T2);
t2 = double(T2);

tr = double(TR);
te = double(TE);

% Calculate the weighted image without added noise
WI(Area) = pd(Area).*(1.0 - 2.0*exp(-(tr - te/2)./t1(Area)) + exp(-tr./t1(Area))).*exp(-(te./t2(Area)));

% If the noise level required is 0.0, make an early return at this point
TOL = 1.0e-6;

if (NoisePC < TOL)
  return;
end

% Otherwise, make the image complex before transformation to time domain
Re = WI;
Im = zeros(size(Mo), 'double');

Cplx = complex(Re, Im);

% Transform to time-domain in-place
Cplx = ifft2(Cplx);

% Locate the signal peak and add the requisite amount of noise
Magn = abs(Cplx);

Peak = max(Magn(:));

RealNoise = 0.01*NoisePC*Peak*normrnd(0.0, 1.0, size(Magn));
ImagNoise = 0.01*NoisePC*Peak*normrnd(0.0, 1.0, size(Magn));

Noise = complex(RealNoise, ImagNoise);

Cplx = Cplx + Noise;

% Tranform back to image domain and take the modulus mode
Cplx = fft2(Cplx);

WI = uint16(abs(Cplx));

end









