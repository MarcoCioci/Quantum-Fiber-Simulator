function rho_ensemble = random_phase_ensemble_state(theta_samples)
% RANDOM_PHASE_ENSEMBLE_STATE  Compute the ensemble-averaged state for Experiment 2.
%
% Objective:
%   Compute the ensemble-averaged two-qubit density matrix associated with
%   the random-phase noise model used in Experiment 2.
%
%   Starting from the fixed Bell input state |psi_plus>, this function:
%       - applies a sampled relative phase to each realization
%       - converts each pure output state into a density operator
%       - averages all realizations into a single ensemble state
%
% Input:
%   theta_samples - numeric vector of sampled phase values in radians
%
% Output:
%   rho_ensemble  - 4x4 complex density matrix representing the
%                   ensemble-averaged two-qubit state
%
% Notes:
%   This function provides the core mixed-state object for Experiment 2 and
%   is intentionally limited to that scenario.
%
%   The input state is fixed to:
%       |psi_plus>
%
%   The local evolution for each sampled realization is:
%       U_A = phase_unitary(theta_k)
%       U_B = I
%
%   The ensemble state is constructed as:
%       rho_ensemble = (1/N) * sum_k rho_k
%
%   where:
%       rho_k = |psi(theta_k)><psi(theta_k)|
%
%   Plotting and correlation analysis are intentionally excluded from this
%   function. Those tasks should be handled by experiment-level routines.

    % =========================
    % Robustness checks
    % =========================
    if nargin ~= 1
        error('random_phase_ensemble_state:InvalidNumInputs', ...
            'Expected exactly 1 input argument: theta_samples.');
    end

    if ~isnumeric(theta_samples) || ~isvector(theta_samples)
        error('random_phase_ensemble_state:InvalidInputType', ...
            'theta_samples must be a numeric vector.');
    end

    if isempty(theta_samples)
        error('random_phase_ensemble_state:EmptyInput', ...
            'theta_samples must not be empty.');
    end

    if ~isreal(theta_samples)
        error('random_phase_ensemble_state:ComplexInput', ...
            'theta_samples must be a real-valued vector.');
    end

    if any(~isfinite(theta_samples))
        error('random_phase_ensemble_state:NonFiniteInput', ...
            'theta_samples must contain only finite values.');
    end

    theta_samples = theta_samples(:).';   % force row vector
    N = numel(theta_samples);

    % =========================
    % Initialization
    % =========================
    psi0 = bell_state('psi_plus');
    rho_sum = zeros(4, 4);

    % =========================
    % Main ensemble construction
    % =========================
    for idx = 1:N
        theta = theta_samples(idx);

        U_A = phase_unitary(theta);
        U_B = eye(2, 2);

        psi = apply_unitary(U_A, U_B, psi0);
        rho_k = state_to_density_matrix(psi);

        rho_sum = rho_sum + rho_k;
    end

    rho_ensemble = rho_sum / N;

end