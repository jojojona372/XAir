%% XAir Data Loader
% License: GNU AGPLv3
% Author: Jona van der Pal
% Student number: s2523221
% Original date: 22-02-2022
% Current version: 07032022
% Description:
% If the necessary data doesn't exist yet, it is generated automatically.
% This is useful when using XAir for the very first time, or when the file
% was altered or deleted.
function loadXAirData(unit)
    % If the mode is set to 'C' for °C, XAir must be used with degrees celsius
    % as temperature input. Otherwise the input temperature must be in Kelvin.
    if ~exist('unit','var')
        unit = 'C';
        disp("Temperature unit was set to °C by default.")
    end
    if ~exist('XAirData.mat','file')
        XAir("gen",unit)
    end
    
    % Initialising the functions as global empty arrays, so they can be
    % retrieved by XAir later.
    global h_T T_h T_ps h_ps p_hs p_Ts s_Tp s_ph %#ok<*NUSED>
    
    % Because who doesn't like loading statements with triple dots...
    disp("Loading XAir data...")
    tic
    load XAirData.mat h_T T_h T_ps h_ps p_hs p_Ts s_Tp s_ph
    disp("XAir data loaded succesfully.")
    toc
end