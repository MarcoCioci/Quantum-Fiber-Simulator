function test_concurrence_pure_state()
% TEST_CONCURRENCE_PURE_STATE  Validate concurrence for representative pure two-qubit states.
%
% Objective:
%   Verify that concurrence_pure_state correctly reproduces the theoretical
%   concurrence values introduced in Section 4.4 of the thesis guide.
%
%   The following cases are tested:
%
%       1. Separable computational-basis state:
%          C = 0
%
%       2. Bell state |Psi+>:
%          C = 1
%
%       3. Phase-evolved Bell-like state:
%          C = 1 for every theta
%
%       4. Generic separable product state:
%          C = 0
%
%       5. Generic partially entangled pure state:
%          C = 2*|ad - bc|
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

    fprintf('Running test_concurrence_pure_state...\n');


    % =========================
    % Test 1: Separable computational-basis state
    % =========================

    psi_sep_basis = [1; 0; 0; 0];
    C_sep_basis = concurrence_pure_state(psi_sep_basis);

    assert(abs(C_sep_basis - 0.0) < tolerance, ...
        'test_concurrence_pure_state:SeparableBasisFailed', ...
        'Concurrence of |00> should be 0.');


    % =========================
    % Test 2: Bell state |Psi+>
    % =========================

    psi_bell = bell_state('psi_plus');
    C_bell = concurrence_pure_state(psi_bell);

    assert(abs(C_bell - 1.0) < tolerance, ...
        'test_concurrence_pure_state:BellStateFailed', ...
        'Concurrence of |Psi+> should be 1.');


    % =========================
    % Test 3: Phase-evolved Bell-like state
    % =========================

    theta = pi / 3;

    U_A = eye(2);
    U_B = phase_unitary(theta);

    psi_phase = apply_unitary(U_A, U_B, psi_bell);
    C_phase = concurrence_pure_state(psi_phase);

    assert(abs(C_phase - 1.0) < tolerance, ...
        'test_concurrence_pure_state:PhaseEvolvedBellFailed', ...
        'Phase-evolved Bell-like state should remain maximally entangled.');


    % =========================
    % Test 4: Generic separable product state
    % =========================

    psi_A = [sqrt(3)/2; 1/2];
    psi_B = [1/sqrt(2); 1/sqrt(2)];

    psi_product = kron(psi_A, psi_B);
    C_product = concurrence_pure_state(psi_product);

    assert(abs(C_product - 0.0) < tolerance, ...
        'test_concurrence_pure_state:GenericProductStateFailed', ...
        'Concurrence of a separable product state should be 0.');


    % =========================
    % Test 5: Generic partially entangled pure state
    % =========================

    psi_partial = [sqrt(3)/2; 0; 0; 1/2];
    C_partial = concurrence_pure_state(psi_partial);
    C_partial_expected = sqrt(3) / 2;

    assert(abs(C_partial - C_partial_expected) < tolerance, ...
        'test_concurrence_pure_state:PartiallyEntangledStateFailed', ...
        'Concurrence of the test pure state does not match the analytical value.');


    % =========================
    % Success message
    % =========================

    fprintf('test_concurrence_pure_state passed successfully.\n');

end