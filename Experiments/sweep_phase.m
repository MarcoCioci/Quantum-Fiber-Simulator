function results_sweep_phase = sweep_phase(theta_values)
% SWEEP_PHASE  Perform a parameter sweep over the relative phase.
%
% Objective:
%   Evaluate how standard two-qubit correlations vary as a function
%   of the relative phase theta introduced by the reduced fiber model.
%
%   For each theta:
%       - construct the local unitary evolution
%       - propagate the input Bell state
%       - compute the correlation observables
%
% Input:
%   theta_values - array of phase values in radians
%                  (optional; default = 25 values in [0, 2*pi])
%
% Output:
%   results_sweep_phase - structure containing:
%       .theta
%       .c_xx
%       .c_yy
%       .c_zz
%
% Notes:
%   This is the first complete experiment in the simulator and serves as
%   a validation of the reduced phase model.
%
%   The input Bell state is fixed to |psi_plus>.
%   The local evolution used here is:
%
%       U_A = I
%       U_B = phase_unitary(theta)
%
%   Plotting is intentionally not performed inside this function.
%   Visualization should be handled separately.

    % =========================
    % Robustness checks
    % =========================

    if nargin < 1
        N = 25;
        theta_values = linspace(0, 2*pi, N);
    end

    if ~isnumeric(theta_values) || ~isvector(theta_values)
        error('sweep_phase:InvalidInputType', ...
            'theta_values must be a numeric vector.');
    end

    theta_values = theta_values(:).';   % force row vector
    N = numel(theta_values);

    % =========================
    % Initialization
    % =========================

    psi0 = bell_state('psi_plus');

    results_sweep_phase = struct();
    results_sweep_phase.theta = theta_values;
    results_sweep_phase.c_xx = zeros(1, N);
    results_sweep_phase.c_yy = zeros(1, N);
    results_sweep_phase.c_zz = zeros(1, N);

    
    % =========================
    % Main sweep
    % =========================

    for idx = 1:N
        theta = theta_values(idx);

        U_A = eye(2);
        U_B = phase_unitary(theta);

        psi = apply_unitary(U_A, U_B, psi0);
        corr = compute_correlations(psi);

        results_sweep_phase.c_xx(idx) = corr.c_xx;
        results_sweep_phase.c_yy(idx) = corr.c_yy;
        results_sweep_phase.c_zz(idx) = corr.c_zz;
    end

end