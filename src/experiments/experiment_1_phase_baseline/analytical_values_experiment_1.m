function analytics = analytical_values_experiment_1(theta)
% ANALYTICAL_VALUES_EXPERIMENT_1
% Analytical predictions for the fixed-phase evolution experiment.
%
% Objective:
%   Return the analytical quantities associated with the reduced phase
%   model applied to the Bell state
%
%       |ψ(θ)⟩ = (|01⟩ + exp(iθ)|10⟩)/sqrt(2)
%
%   used in Experiment 1.
%
% Input:
%   theta - real scalar or vector of phase values
%
% Output:
%   analytics - structure containing analytical predictions:
%
%       analytics.theta
%       analytics.c_xx
%       analytics.c_yy
%       analytics.c_zz
%       analytics.gamma_AB
%       analytics.gamma_A
%       analytics.gamma_B
%       analytics.F_psi_plus
%       analytics.C
%       analytics.T
%
% Notes:
%   The returned correlation tensor follows the convention
%
%       T(θ) =
%           [ cos(θ)  -sin(θ)   0
%             sin(θ)   cos(θ)   0
%                0        0    -1 ]
%
%   If theta contains N values:
%
%       analytics.T
%
%   is returned as a 3x3xN array.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('analytical_values_experiment_1:InvalidNumInputs', ...
              'Expected 1 input argument: theta.');
    end

    if ~isnumeric(theta) || ~isreal(theta)
        error('analytical_values_experiment_1:InvalidTheta', ...
              'theta must be a real numeric scalar or vector.');
    end

    if any(~isfinite(theta), 'all')
        error('analytical_values_experiment_1:InvalidThetaValues', ...
              'theta must contain only finite values.');
    end


    % =========================
    % Main computation
    % =========================

    theta = theta(:).';    % Force row vector

    N = numel(theta);

    % ---------------------------------
    % Correlations
    % ---------------------------------

    analytics.theta = theta;

    analytics.c_xx = cos(theta);
    analytics.c_yy = cos(theta);
    analytics.c_zz = -ones(size(theta));

    analytics.c_xy = -sin(theta);
    analytics.c_yx =  sin(theta);


    % ---------------------------------
    % State metrics
    % ---------------------------------

    analytics.gamma_AB = ones(size(theta));

    analytics.gamma_A = 0.5 * ones(size(theta));
    analytics.gamma_B = 0.5 * ones(size(theta));

    analytics.F_psi_plus = (1 + cos(theta)) / 2;

    analytics.C = ones(size(theta));


    % ---------------------------------
    % Correlation tensor
    % ---------------------------------

    analytics.T = zeros(3, 3, N);

    for k = 1:N

        t = theta(k);

        analytics.T(:, :, k) = ...
            [ cos(t), -sin(t), 0; ...
              sin(t),  cos(t), 0; ...
              0,       0,     -1 ];

    end

end