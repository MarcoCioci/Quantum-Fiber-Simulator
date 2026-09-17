function test_bbm92_qber()
% TEST_BBM92_QBER  Validate BBM92 QBER evaluation for representative two-qubit states.

    tolerance = 1e-12;

    %--------------------------------------------------------------
    % Ideal |Psi+>
    %
    % Z basis: ideal anticorrelation
    % X basis: ideal correlation
    %
    % Expected:
    % Q_Z = 0
    % Q_X = 0
    %--------------------------------------------------------------

    psi_plus = bell_state('psi_plus');

    qber = compute_bbm92_qber(psi_plus);

    assert( ...
        abs(qber.Q_Z) < tolerance, ...
        'test_bbm92_qber:IdealPsiPlusQZ', ...
        'Ideal |Psi+> must have Q_Z = 0.');

    assert( ...
        abs(qber.Q_X) < tolerance, ...
        'test_bbm92_qber:IdealPsiPlusQX', ...
        'Ideal |Psi+> must have Q_X = 0.');

    %--------------------------------------------------------------
    % Coherent phase-shifted Bell state
    %
    % |Psi_theta> =
    % (|HV> + exp(i theta)|VH>) / sqrt(2)
    %
    % Expected:
    %
    % Q_Z = 0
    % Q_X = (1 - cos(theta)) / 2
    %
    % The state remains maximally entangled.
    %--------------------------------------------------------------

    theta = pi / 2;

    U_phase = phase_unitary(theta);

    psi_phase = apply_unitary( ...
        eye(2), ...
        U_phase, ...
        psi_plus);

    qber_phase = compute_bbm92_qber(psi_phase);

    expected_Q_Z = 0;
    expected_Q_X = (1 - cos(theta)) / 2;

    assert( ...
        abs(qber_phase.Q_Z - expected_Q_Z) < tolerance, ...
        'test_bbm92_qber:PhaseQZ', ...
        'Incorrect Q_Z for the phase-shifted Bell state.');

    assert( ...
        abs(qber_phase.Q_X - expected_Q_X) < tolerance, ...
        'test_bbm92_qber:PhaseQX', ...
        'Incorrect Q_X for the phase-shifted Bell state.');

    concurrence_phase = compute_concurrence(psi_phase);

    assert( ...
        abs(concurrence_phase - 1) < tolerance, ...
        'test_bbm92_qber:PhaseConcurrence', ...
        'A local coherent phase shift must preserve concurrence.');

    %--------------------------------------------------------------
    % Fully dephased |Psi+> state
    %
    % rho =
    % 1/2 |HV><HV| + 1/2 |VH><VH|
    %
    % Expected:
    %
    % Q_Z = 0
    % Q_X = 1/2
    % C   = 0
    %--------------------------------------------------------------

    H = computational_basis('0');
    V = computational_basis('1');

    HV = tensor_product(H, V);
    VH = tensor_product(V, H);

    rho_dephased = ...
        0.5 * (HV * HV') ...
        + 0.5 * (VH * VH');

    qber_dephased = compute_bbm92_qber(rho_dephased);

    assert( ...
        abs(qber_dephased.Q_Z) < tolerance, ...
        'test_bbm92_qber:DephasedQZ', ...
        'Fully dephased |Psi+> must have Q_Z = 0.');

    assert( ...
        abs(qber_dephased.Q_X - 0.5) < tolerance, ...
        'test_bbm92_qber:DephasedQX', ...
        'Fully dephased |Psi+> must have Q_X = 1/2.');

    concurrence_dephased = compute_concurrence(rho_dephased);

    assert( ...
        abs(concurrence_dephased) < tolerance, ...
        'test_bbm92_qber:DephasedConcurrence', ...
        'Fully dephased |Psi+> must have zero concurrence.');

    %--------------------------------------------------------------
    % Maximally mixed state
    %
    % rho = I_4 / 4
    %
    % Expected:
    %
    % Q_Z = 1/2
    % Q_X = 1/2
    % C   = 0
    %--------------------------------------------------------------

    rho_mixed = eye(4) / 4;

    qber_mixed = compute_bbm92_qber(rho_mixed);

    assert( ...
        abs(qber_mixed.Q_Z - 0.5) < tolerance, ...
        'test_bbm92_qber:MixedQZ', ...
        'Maximally mixed state must have Q_Z = 1/2.');

    assert( ...
        abs(qber_mixed.Q_X - 0.5) < tolerance, ...
        'test_bbm92_qber:MixedQX', ...
        'Maximally mixed state must have Q_X = 1/2.');

    concurrence_mixed = compute_concurrence(rho_mixed);

    assert( ...
        abs(concurrence_mixed) < tolerance, ...
        'test_bbm92_qber:MixedConcurrence', ...
        'Maximally mixed state must have zero concurrence.');

    %--------------------------------------------------------------
    % Mean QBER consistency
    %--------------------------------------------------------------

    assert( ...
        abs(qber.Q_mean - 0.5 * (qber.Q_Z + qber.Q_X)) < tolerance, ...
        'test_bbm92_qber:MeanIdeal', ...
        'Incorrect mean QBER for ideal |Psi+>.');

    assert( ...
        abs(qber_phase.Q_mean ...
        - 0.5 * (qber_phase.Q_Z + qber_phase.Q_X)) < tolerance, ...
        'test_bbm92_qber:MeanPhase', ...
        'Incorrect mean QBER for phase-shifted |Psi+>.');

    assert( ...
        abs(qber_dephased.Q_mean ...
        - 0.5 * (qber_dephased.Q_Z + qber_dephased.Q_X)) < tolerance, ...
        'test_bbm92_qber:MeanDephased', ...
        'Incorrect mean QBER for fully dephased |Psi+>.');

    assert( ...
        abs(qber_mixed.Q_mean ...
        - 0.5 * (qber_mixed.Q_Z + qber_mixed.Q_X)) < tolerance, ...
        'test_bbm92_qber:MeanMixed', ...
        'Incorrect mean QBER for maximally mixed state.');

    fprintf('test_bbm92_qber passed.\n');

end