function test_purity()
% TEST_PURITY  Validate purity computations for pure, mixed, and reduced states.
%
% Objective:
%   Verify that compute_purity correctly reproduces the theoretical purity
%   values introduced in Section 4.2 of the thesis guide.
%
%   The following cases are tested:
%
%       1. Pure single-qubit state:
%          Tr(ρ^2) = 1
%
%       2. Maximally mixed single-qubit state:
%          Tr(ρ^2) = 1/2
%
%       3. Global Bell state:
%          Tr(ρ_AB^2) = 1
%
%       4. Reduced Bell-state marginals:
%          Tr(ρ_A^2) = Tr(ρ_B^2) = 1/2
%
%       5. Phase-evolved Bell-like state:
%          global purity remains 1
%          reduced purities remain 1/2
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

    tolerance = 1e-12;

    fprintf('Running test_purity...\n');


    % =========================
    % Test 1: Pure single-qubit state
    % =========================

    psi_pure = [1; 0];
    rho_pure = state_to_density_matrix(psi_pure);
    purity_pure = compute_purity(rho_pure);

    assert(abs(purity_pure - 1.0) < tolerance, ...
        'test_purity:PureStateFailed', ...
        'Purity of a pure single-qubit state should be 1.');


    % =========================
    % Test 2: Maximally mixed single-qubit state
    % =========================

    rho_mixed_qubit = eye(2) / 2;
    purity_mixed_qubit = compute_purity(rho_mixed_qubit);

    assert(abs(purity_mixed_qubit - 0.5) < tolerance, ...
        'test_purity:MaximallyMixedQubitFailed', ...
        'Purity of I/2 should be 1/2.');


    % =========================
    % Test 3: Global Bell-state purity
    % =========================

    psi_bell = bell_state('psi_plus');
    rho_bell = state_to_density_matrix(psi_bell);
    purity_bell_global = compute_purity(rho_bell);

    assert(abs(purity_bell_global - 1.0) < tolerance, ...
        'test_purity:BellGlobalFailed', ...
        'Global Bell state should have purity 1.');


    % =========================
    % Test 4: Reduced Bell-state purities
    % =========================

    rho_A_bell = partial_trace_B(rho_bell);
    rho_B_bell = partial_trace_A(rho_bell);

    purity_A_bell = compute_purity(rho_A_bell);
    purity_B_bell = compute_purity(rho_B_bell);

    assert(abs(purity_A_bell - 0.5) < tolerance, ...
        'test_purity:BellReducedAFailed', ...
        'Reduced state rho_A of a Bell state should have purity 1/2.');

    assert(abs(purity_B_bell - 0.5) < tolerance, ...
        'test_purity:BellReducedBFailed', ...
        'Reduced state rho_B of a Bell state should have purity 1/2.');


    % =========================
    % Test 5: Phase-evolved Bell-like state
    % =========================

    theta = pi / 3;

    U_A = eye(2);
    U_B = phase_unitary(theta);

    psi_phase = apply_unitary(U_A, U_B, psi_bell);
    rho_phase = state_to_density_matrix(psi_phase);

    purity_phase_global = compute_purity(rho_phase);
    rho_A_phase = partial_trace_B(rho_phase);
    rho_B_phase = partial_trace_A(rho_phase);

    purity_A_phase = compute_purity(rho_A_phase);
    purity_B_phase = compute_purity(rho_B_phase);

    assert(abs(purity_phase_global - 1.0) < tolerance, ...
        'test_purity:PhaseGlobalFailed', ...
        'Phase-evolved Bell-like state should remain globally pure.');

    assert(abs(purity_A_phase - 0.5) < tolerance, ...
        'test_purity:PhaseReducedAFailed', ...
        'Reduced state rho_A(theta) should have purity 1/2.');

    assert(abs(purity_B_phase - 0.5) < tolerance, ...
        'test_purity:PhaseReducedBFailed', ...
        'Reduced state rho_B(theta) should have purity 1/2.');


    % =========================
    % Success message
    % =========================

    fprintf('test_purity passed successfully.\n');

end