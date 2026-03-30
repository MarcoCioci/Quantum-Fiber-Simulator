function results_phase_baseline = phase_baseline_sweep(theta_values)
% PHASE_BASELINE_SWEEP  Compute Experiment 1 numerical baseline data.
%
% Objective:
%   Compute the deterministic phase-sweep data associated with
%   Experiment 1 of the simulator.
%
%   Starting from the fixed Bell input state |psi_plus>, this function:
%       - sweeps the relative phase theta
%       - applies the reduced local fiber model
%       - computes the aligned two-qubit Pauli correlations
%
% Input:
%   theta_values - numeric vector of phase values in radians
%                  (optional; default = 25 values in [0, 2*pi])
%
% Output:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .c_xx
%       .c_yy
%       .c_zz
%
% Notes:
%   This function provides the numerical data for Experiment 1 and is
%   intentionally limited to that scenario.
%
%   The input state is fixed to:
%       |psi_plus>
%
%   The local evolution is:
%       U_A = phase_unitary(theta)
%       U_B = I
%
%   Plotting is intentionally excluded from this function.
%   Visualization and theory comparison should be handled separately by
%   experiment-level routines.

    % =========================
    % Robustness checks
    % =========================
    if nargin < 1
        N = 25;
        theta_values = linspace(0, 2*pi, N);
    end

    if ~isnumeric(theta_values) || ~isvector(theta_values)
        error('phase_baseline_sweep:InvalidInputType', ...
            'theta_values must be a numeric vector.');
    end

    if isempty(theta_values)
        error('phase_baseline_sweep:EmptyInput', ...
            'theta_values must not be empty.');
    end

    if ~isreal(theta_values)
        error('phase_baseline_sweep:ComplexInput', ...
            'theta_values must be a real-valued vector.');
    end

    theta_values = theta_values(:).';   % force row vector
    N = numel(theta_values);

    % =========================
    % Main computations
    % =========================
    psi0 = bell_state('psi_plus');

    results_phase_baseline = struct();
    results_phase_baseline.theta_values = theta_values;
    results_phase_baseline.c_xx = zeros(1, N);
    results_phase_baseline.c_yy = zeros(1, N);
    results_phase_baseline.c_zz = zeros(1, N);

    % Main sweep
    for idx = 1:N
        theta = theta_values(idx);

        U_A = phase_unitary(theta);
        U_B = eye(2, 2);

        psi = apply_unitary(U_A, U_B, psi0);
        corr = compute_correlations(psi);

        results_phase_baseline.c_xx(idx) = real(corr.c_xx);
        results_phase_baseline.c_yy(idx) = real(corr.c_yy);
        results_phase_baseline.c_zz(idx) = real(corr.c_zz);
    end

end