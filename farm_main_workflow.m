function data = farm_main_workflow( data, channel_description )
% FARM_MAIN_WORKFLOW is a wrapper that will will perform FARM denoisng.
% VERY IMPORTANT : It is optimized for EMG data.
%
% SYNTAX
%       data = FARM_MAIN_WORKFLOW( data )
%
% INPUT
%       - data                : see <a href="matlab: help farm_check_data">farm_check_data</a>
%       - channel_description : can be channel index [1 2 ...] or a regex (char or cellstr) for data.label
%
%
%
% See also farm_check_data


if nargin==0, help(mfilename('fullpath')); return; end


%% Check input arguments

narginchk(2,2)

farm_check_data( data )


%% ------------------------------------------------------------------------
%% FARM
% Main FARM functions are below.

% A lot of functions use what is called "regular expressions" (regex). It allows to recognize patterns in strings of characters
% This a powerfull tool, which is common to almost all programing languages. Open some documentation with : doc regular-expressions


%% Check input data
farm_check_data( data )


%% Channel selection
% In your dataset, you might have different nature of signal, for exemple EMG + Accelerometer.
% To perform FARM pipeline only on EMG, you need to select the corresponding channels.

% Select channel for the next processing steps
data = farm_select_channel( data, channel_description );

fprintf('channel selected : %s \n', data.selected_channels_name{:})


%% Initial HPF @ 30Hz

data = farm_initial_hpf( data );


%% Which channel with greater artifacts ?

data = farm_detect_channel_with_greater_artifact( data );
fprintf('channel with greater artifacts : %s \n', data.label{data.target_channel})


%% Add slice markers : initialize sdur & dtime

data = farm_add_slice_marker( data );


%% Prepare slice candidates for the template generation

data = farm_pick_slice_for_template( data );


%% Optimize slice markers : optimize sdur & dtime
% with an unconstrained non-linear optimization

data = farm_optimize_sdur_dtime( data );


%% Slice correction : compute slice template using best candidates

data = farm_compute_slice_template( data );


%% Volume correction : replace volume-segment (dtime) by 0
% In the FARM article, this method is more advanced, and overwrite less points
% But I didn't succed to code it properly, so I used a "zero filling"

data = farm_volume_correction( data );


%% Revove noise residuals using PCA
% Here, the templates will be substracted, then PCA will be perform on the residuals.
% PCs will bi fitted to theses residials, and substracted.

data = farm_optimize_slice_template_using_PCA( data );


%% Revove noise residuals using ANC
% ANC will remove the last residuals not fitted by the PCs

% Don't know why ANC diverges in this dataset
% Clue : in Niazy et al., they think the filtering diverges when the amplitude is large,
% which is the case for EMG burst compared to EEG.

% data = farm_adaptive_noise_cancellation( data );


%% Remove slice markers
% More convenient

data = farm_remove_slice_marker( data );


end % function
