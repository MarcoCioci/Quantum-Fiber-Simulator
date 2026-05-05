function results_phase_baseline = phase_baseline_sweep(theta_values)
% PHASE_BASELINE_SWEEP  Compute Experiment 1 numerical baseline data.
%
% Objective:
%   Compute the deterministic phase-sweep data associated with
%   Experiment 1 of the simulator.
%
%   Starting from the fixed Bell input state |Ψ⁺⟩, this function:
%       - sweeps the relative phase θ
%       - applies the reduced local fiber model
%       - computes the full two-qubit Pauli correlation tensor
%       - extracts aligned two-qubit Pauli correlations
%       - computes global and reduced purities
%       - computes fidelity with respect to the reference Bell state |Ψ⁺⟩
%       - computes concurrence of the propagated pure state
%
% Input:
%   theta_values - numeric vector of phase values in radians
%                  (optional; default = 25 values in [0, 2*π])
%
% Output:
%   results_phase_baseline - structure containing:
%       .theta_values
%       .correlation_tensor
%       .c_xx
%       .c_yy
%       .c_zz
%       .purity_global
%       .purity_A
%       .purity_B
%       .fidelity_psi_plus
%       .concurrence
%
% Notes:
%   The input state is fixed to:
%       |Ψ⁺⟩
%
%   The local evolution is:
%       U_A = phase_unitary(θ)
%       U_B = I
%
%   The expected analytical tensor is:
%
%       T(θ) =
%       [ cos(θ), -sin(θ),  0  ;
%         sin(θ),  cos(θ),  0  ;
%         0,           0,   -1 ]
%

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

    if any(~isfinite(theta_values))
        error('phase_baseline_sweep:InvalidValues', ...
              'theta_values must not contain NaN or Inf values.');
    end

    theta_values = theta_values(:).';
    N = numel(theta_values);


    % =========================
    % Main computation
    % =========================

    psi_ref = bell_state('psi_plus');

    results_phase_baseline = struct();
    results_phase_baseline.theta_values = theta_values;

    results_phase_baseline.correlation_tensor = zeros(3, 3, N);

    results_phase_baseline.c_xx = zeros(1, N);
    results_phase_baseline.c_yy = zeros(1, N);
    results_phase_baseline.c_zz = zeros(1, N);

    results_phase_baseline.purity_global = zeros(1, N);
    results_phase_baseline.purity_A = zeros(1, N);
    results_phase_baseline.purity_B = zeros(1, N);

    results_phase_baseline.fidelity_psi_plus = zeros(1, N);
    results_phase_baseline.concurrence = zeros(1, N);

    for idx = 1:N
        theta = theta_values(idx);

        U_A = phase_unitary(theta);
        U_B = eye(2);

        psi = apply_unitary(U_A, U_B, psi_ref);
        rho = state_to_density_matrix(psi);

        T = compute_correlation_tensor(rho);
        corr = compute_correlations(rho);

        rho_A = partial_trace_B(rho);
        rho_B = partial_trace_A(rho);

        results_phase_baseline.correlation_tensor(:, :, idx) = T;

        results_phase_baseline.c_xx(idx) = real(corr.c_xx);
        results_phase_baseline.c_yy(idx) = real(corr.c_yy);
        results_phase_baseline.c_zz(idx) = real(corr.c_zz);

        results_phase_baseline.purity_global(idx) = compute_purity(rho);
        results_phase_baseline.purity_A(idx) = compute_purity(rho_A);
        results_phase_baseline.purity_B(idx) = compute_purity(rho_B);

        results_phase_baseline.fidelity_psi_plus(idx) = compute_fidelity(rho, psi_ref);
        results_phase_baseline.concurrence(idx) = compute_concurrence(psi);
    end

end