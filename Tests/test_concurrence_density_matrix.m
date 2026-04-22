function test_concurrence_density_matrix()
% TEST_CONCURRENCE_DENSITY_MATRIX  Validate concurrence for pure and mixed two-qubit density matrices.
%
% Objective:
%   Verify that concurrence_density_matrix correctly reproduces the
%   theoretical concurrence values introduced in Section 4.4 of the thesis
%   guide, including both pure-state density operators and genuine mixed
%   states.
%
%   The following cases are tested:
%
%       1. Pure Bell-state density operator:
%          C = 1
%
%       2. Pure separable-state density operator:
%          C = 0
%
%       3. Phase-evolved Bell-like pure density operator:
%          C = 1 for every theta
%
%       4. Completely decohered random-phase ensemble:
%          C = 0
%
%       5. Random-phase ensemble with partial coherence mu:
%          C = |mu|
%
%       6. Maximally mixed two-qubit state:
%          C = 0
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The test raises an error if any expected value is not matched within
%   numerical tolerance. If all checks pass, a success message is printed.

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-8;

    fprintf('Running test_concurrence_density_matrix...\n');


    % =========================
    % Test 1: Pure Bell-state density operator
    % =========================

    psi_bell = bell_state('psi_plus');
    rho_bell = state_to_density_matrix(psi_bell);
    C_bell = concurrence_density_matrix(rho_bell);

    assert(abs(C_bell - 1.0) < tolerance, ...
        'test_concurrence_density_matrix:BellDensityFailed', ...
        'Concurrence of the Bell-state density matrix should be 1.');


    % =========================
    % Test 2: Pure separable-state density operator
    % =========================

    psi_sep = [1; 0; 0; 0];
    rho_sep = state_to_density_matrix(psi_sep);
    C_sep = concurrence_density_matrix(rho_sep);

    assert(abs(C_sep - 0.0) < tolerance, ...
        'test_concurrence_density_matrix:SeparableDensityFailed', ...
        'Concurrence of a separable pure-state density matrix should be 0.');


    % =========================
    % Test 3: Phase-evolved Bell-like pure density operator
    % =========================

    theta = pi / 5;

    U_A = eye(2);
    U_B = phase_unitary(theta);

    psi_phase = apply_unitary(U_A, U_B, psi_bell);
    rho_phase = state_to_density_matrix(psi_phase);
    C_phase = concurrence_density_matrix(rho_phase);

    assert(abs(C_phase - 1.0) < tolerance, ...
        'test_concurrence_density_matrix:PhaseDensityFailed', ...
        'Phase-evolved Bell-like pure density matrix should have concurrence 1.');


    % =========================
    % Test 4: Completely decohered random-phase ensemble
    % =========================

    rho_decohered = [0,   0,   0, 0; ...
                     0, 1/2,   0, 0; ...
                     0,   0, 1/2, 0; ...
                     0,   0,   0, 0];

    C_decohered = concurrence_density_matrix(rho_decohered);

    assert(abs(C_decohered - 0.0) < tolerance, ...
        'test_concurrence_density_matrix:DecoheredEnsembleFailed', ...
        'Fully decohered random-phase ensemble should have concurrence 0.');


    % =========================
    % Test 5: Random-phase ensemble with partial coherence mu
    % =========================

    mu = 0.6 * exp(1i * pi / 4);

    rho_mu = [0,        0,         0, 0; ...
              0,      1/2, conj(mu)/2, 0; ...
              0,   mu/2,        1/2, 0; ...
              0,        0,         0, 0];

    C_mu = concurrence_density_matrix(rho_mu);
    C_mu_expected = abs(mu);

    assert(abs(C_mu - C_mu_expected) < tolerance, ...
        'test_concurrence_density_matrix:PartialCoherenceEnsembleFailed', ...
        'Random-phase ensemble concurrence should equal |mu|.');


    % =========================
    % Test 6: Maximally mixed two-qubit state
    % =========================

    rho_max_mixed = eye(4) / 4;
    C_max_mixed = concurrence_density_matrix(rho_max_mixed);

    assert(abs(C_max_mixed - 0.0) < tolerance, ...
        'test_concurrence_density_matrix:MaximallyMixedFailed', ...
        'Maximally mixed two-qubit state should have concurrence 0.');


    % =========================
    % Success message
    % =========================

    fprintf('test_concurrence_density_matrix passed successfully.\n');

end