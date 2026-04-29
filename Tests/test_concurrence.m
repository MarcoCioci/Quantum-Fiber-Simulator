function test_concurrence()
% TEST_CONCURRENCE  Validate concurrence for representative two-qubit pure and mixed states.
%
% Objective:
%   Verify that compute_concurrence correctly reproduces the theoretical
%   concurrence values introduced in Section 4.4 of the thesis guide.
%
%   The following cases are tested:
%
%       1. Separable computational-basis pure state:
%          C = 0
%
%       2. Bell state |Psi+> as pure-state vector:
%          C = 1
%
%       3. Phase-evolved Bell-like pure state:
%          C = 1 for every θ
%
%       4. Generic separable product pure state:
%          C = 0
%
%       5. Generic partially entangled pure state:
%          C = 2*|ad - bc|
%
%       6. Bell state represented as density matrix:
%          C = 1
%
%       7. Maximally mixed two-qubit state:
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

    tolerance = 1e-12;

    fprintf('Running test_concurrence...\n');


    % =========================
    % Test 1: Separable computational-basis pure state
    % =========================

    psi_sep_basis = [1; 0; 0; 0];
    C_sep_basis = compute_concurrence(psi_sep_basis);

    assert(abs(C_sep_basis - 0.0) < tolerance, ...
        'test_concurrence:SeparableBasisFailed', ...
        'Concurrence of |00> should be 0.');


    % =========================
    % Test 2: Bell state |Psi+> as pure-state vector
    % =========================

    psi_bell = bell_state('psi_plus');
    C_bell = compute_concurrence(psi_bell);

    assert(abs(C_bell - 1.0) < tolerance, ...
        'test_concurrence:BellStatePureFailed', ...
        'Concurrence of |Psi+> should be 1.');


    % =========================
    % Test 3: Phase-evolved Bell-like pure state
    % =========================

    theta = pi / 3;

    U_A = eye(2);
    U_B = phase_unitary(theta);

    psi_phase = apply_unitary(U_A, U_B, psi_bell);
    C_phase = compute_concurrence(psi_phase);

    assert(abs(C_phase - 1.0) < tolerance, ...
        'test_concurrence:PhaseEvolvedBellFailed', ...
        'Phase-evolved Bell-like state should remain maximally entangled.');


    % =========================
    % Test 4: Generic separable product pure state
    % =========================

    psi_A = [sqrt(3)/2; 1/2];
    psi_B = [1/sqrt(2); 1/sqrt(2)];

    psi_product = kron(psi_A, psi_B);
    C_product = compute_concurrence(psi_product);

    assert(abs(C_product - 0.0) < tolerance, ...
        'test_concurrence:GenericProductStateFailed', ...
        'Concurrence of a separable product state should be 0.');


    % =========================
    % Test 5: Generic partially entangled pure state
    % =========================

    psi_partial = [sqrt(3)/2; 0; 0; 1/2];
    C_partial = compute_concurrence(psi_partial);
    C_partial_expected = sqrt(3) / 2;

    assert(abs(C_partial - C_partial_expected) < tolerance, ...
        'test_concurrence:PartiallyEntangledStateFailed', ...
        'Concurrence of the test pure state does not match the analytical value.');


    % =========================
    % Test 6: Bell state as density matrix
    % =========================

    rho_bell = state_to_density_matrix(psi_bell);
    C_rho_bell = compute_concurrence(rho_bell);

    assert(abs(C_rho_bell - 1.0) < tolerance, ...
        'test_concurrence:BellStateDensityFailed', ...
        'Concurrence of Bell-state density matrix should be 1.');


    % =========================
    % Test 7: Maximally mixed two-qubit state
    % =========================

    rho_mixed = eye(4) / 4;
    C_mixed = compute_concurrence(rho_mixed);

    assert(abs(C_mixed - 0.0) < tolerance, ...
        'test_concurrence:MaximallyMixedStateFailed', ...
        'Concurrence of the maximally mixed state should be 0.');


    % =========================
    % Success message
    % =========================

    fprintf('test_concurrence passed.\n');

end