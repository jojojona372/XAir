%% Data generator for XAir
% License: GNU AGPLv3
% Authors: Jos Havinga, Bram Harbers, Wiard van der Weijden, Jona van der Pal
% Student number: s2523221
% Original date: 22-02-2022
% Current version: 07032022
% Description:
% Generates the data that XAir needs, and stores it in a file for later
% use. It's much faster than generating this data every time XAir is used.
% XAirDataGen was written by Jos Havinga, Bram Harbers, and Wiard van der Weijden.
% It was improved for ease of use by Jona van der Pal.
% Also utilises gasprop, written by e.s.j.beitler@student.utwente.nl

function XAirDataGen(unit)
start = tic;
disp("Generating necessary data, this might take a while...");

%% Declaring reference values
tic
Pref = 1;               % bar
TrefC = 0;              % °C
TrefK = C2K(TrefC);     % K
Tref = TrefK;
sref = 6.778;           % kJ/kgK
href = 273.4;           % kJ/kg
R = 0.287;              % kJ/kgK

Pmin = 0.01;
Pmax = 100;
Tmin = C2K(TrefC);
Tmax = C2K(1200);

N = 201;

% First create vectors with all values of temperature to be evaluated:
Trange = linspace(Tmin,Tmax,N);
% Do the same for pressure, but use a logarithmic scale as follows:
Prange = exp(linspace(log(Pmin), log(Pmax), N));
% With Prange and Trange, a grid of pressure and temperature can be
% created:
[Tgrid,Pgrid] = meshgrid(Trange,Prange); 
% To store the enthalpy and entropy, create an array of size N by N with
% NaN values (indeed, enthalpy could also be stored in a vector only as it
% is not a function of pressure):
hgrid = NaN(N);
sgrid = NaN(N);

% As enthalpy is only a function of temperature, it is sufficient to create
% a loop that runs over all temperatures.
% First, the enthalpy at the reference temperature (the first temperature)
% is already known. Therefore, the first column of the enthalpy grid is
% known:
hgrid(:,1) = href;
% Then, create a loop that runs over all other values of temperature. From
% the 2nd until the N'th temperature:
for i = 2:N
    % For all pressures (row numbers) the enthalpy will be the the same.
    % Therefore, the full column can be determined at once. The difference
    % in enthalpy with respect to the reference state can be determined
    % with gasprop:
    hgrid(:,i) = href + gasprop('air', Tref, Trange(i));
end

% Then, the entropy must be determined. Entropy is function of pressure and
% temperature. Therefore, a double for loop must be used. The outer loop
% runs over all pressures, and the inner loop over all temperatures:
% For first pressure value until N'th pressure value:
for i = 1:N
    % For the first (reference) temperature, equation (2) from the exercise
    % sheet must be used:
    sgrid(i,1) = sref - R*log(Pgrid(i,1)/Pref);
    % For the second until the N'th temperature, another for loop must be
    % used:
    for j = 2:N
        % To determine the entropy change from the previous temperature
        % until the current, the specific heat capacity at constant
        % pressure must be known. This is a function of temperature.
        % Therefore, the average value in between the previous and the
        % current temperature will be used to determine this value. This
        % average temperature is:
        meanTemp = (Tgrid(i,j-1) + Tgrid(i,j))/2;
        % And the specific heat capacity at constant pressure at this
        % temperature can be determined with gasprop:
        c_p = gasprop('air',meanTemp);
        % With this c_p, the new entropy can be determined with equation
        % (7) from the exercise sheet. sgrid(i,j-1) is the entropy at the
        % previous temperature, Tgrid(i,j-1) is the previous temperature,
        % and Tgrid(i,j) is the current temperature:
        sgrid(i,j) = sgrid(i,j-1) + c_p*log(Tgrid(i,j)/Tgrid(i,j-1));
    end
end

% if ~exist('unit','var')
%     unit = 'K';
% end
% If the mode is set to 'C' for °C, XAir must be used with degrees celsius
% as temperature input. Otherwise the input temperature must be in Kelvin.
unit = upper(unit);
try
    if unit == 'C'
        % This is necessary to make sure XAir works with temperatures entered in
        % °C instead of Kelvin
        Tgrid = Tgrid-273.15;
        disp("In-/output temperature is set to degrees Celsius.")
    elseif unit == 'K'
        disp("In-/output temperature is set to Kelvin.")
%         disp("To set in-/output temperature to degrees Celsius, enter XAirDataGen('C') into the console.")
    else
        error('MATLAB:minrhs','')
    end
catch ME
    switch ME.identifier
        case 'MATLAB:minrhs'
            error('MATLAB:minrhs',"Please enter a valid unit for input temperature. Options are 'C' for °C and 'K' for Kelvin.")
        otherwise
            rethrow(ME)
    end
end

fprintf("\n")
disp("Data generated succesfully.")
toc

%% Create interpolation functions
tic
% Now, the data that is created can be used to create a set of
% interpolation functions. For the scatteredInterpolant and the
% griddedInterpolant functions, the output will be a function in itself.
% The chosen names are as follows: T_ps for example means temperature (T)
% as function of pressure (p) and enthropy (s).

% Enthalpy is a function of temperature only. Therefore, the functions h_T
% and T_h can be created, using the griddedInterpolant. For these fits,
% only one row of the Tgrid and hgrid arrays are needed:
% Enthalpy as function of temperature
h_T = griddedInterpolant(Tgrid(1,:),hgrid(1,:));
% Temperature as function of enthalpy
T_h = griddedInterpolant(hgrid(1,:),Tgrid(1,:));

% For the functions created with scatteredInterpolant, the data must be
% entered as a vector instead of an array. To convert an array to a vector,
% use (:). Therefore, the following functions can be created:
% Temperature as function of pressure and entropy
T_ps = scatteredInterpolant(Pgrid(:),sgrid(:),Tgrid(:));
% Enthalpy as function of presssure and entropy
h_ps = scatteredInterpolant(Pgrid(:),sgrid(:),hgrid(:));
% Pressure as function of enthalpy and entropy
p_hs = scatteredInterpolant(hgrid(:),sgrid(:),Pgrid(:));
% Pressure as function of temperature and entropy
p_Ts = scatteredInterpolant(Tgrid(:),sgrid(:),Pgrid(:));
% Entropy as function of temperature and pressure
s_Tp = scatteredInterpolant(Tgrid(:),Pgrid(:),sgrid(:));
% Entropy as function of enthalpy and pressure
s_ph = scatteredInterpolant(Pgrid(:),hgrid(:),sgrid(:));

disp("Functions generated succesfully.")
toc

%% Saving functions
tic
% Saves the generated functions to a file so it can be loaded later
save XAirData.mat h_T T_h T_ps h_ps p_hs p_Ts s_Tp s_ph unit
disp("Functions saved succesfully.")
toc
disp("Total time was "+toc(start)+" seconds.")
fprintf("\n")
end

function K = C2K(T)
    K = T + 273.15;
end
