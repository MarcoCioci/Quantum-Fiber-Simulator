function test_bloch_vector()
% TEST_BLOCH_VECTOR  Validate Bloch/Stokes parameter extraction

    disp('Running test_bloch_vector...');

    tol = 1e-12;

    % =========================
    % Test 1: Maximally mixed state
    % =========================
    rho = eye(2) / 2;
    bloch = compute_bloch_vector(rho);

    assert(abs(bloch.sx) < tol, ...
        'sx incorrect for maximally mixed state.');

    assert(abs(bloch.sy) < tol, ...
        'sy incorrect for maximally mixed state.');

    assert(abs(bloch.sz) < tol, ...
        'sz incorrect for maximally mixed state.');

    assert(norm(bloch.vector - [0; 0; 0]) < tol, ...
        'Bloch vector incorrect for maximally mixed state.');

    % =========================
    % Test 2: Pure state |0><0|
    % =========================
    rho = [1 0; 0 0];
    bloch = compute_bloch_vector(rho);

    assert(abs(bloch.sx) < tol, ...
        'sx incorrect for |0><0|.');

    assert(abs(bloch.sy) < tol, ...
        'sy incorrect for |0><0|.');

    assert(abs(bloch.sz - 1) < tol, ...
        'sz incorrect for |0><0|.');

    assert(norm(bloch.vector - [0; 0; 1]) < tol, ...
        'Bloch vector incorrect for |0><0|.');

    % =========================
    % Test 3: Pure state |1><1|
    % =========================
    rho = [0 0; 0 1];
    bloch = compute_bloch_vector(rho);

    assert(abs(bloch.sx) < tol, ...
        'sx incorrect for |1><1|.');

    assert(abs(bloch.sy) < tol, ...
        'sy incorrect for |1><1|.');

    assert(abs(bloch.sz + 1) < tol, ...
        'sz incorrect for |1><1|.');

    assert(norm(bloch.vector - [0; 0; -1]) < tol, ...
        'Bloch vector incorrect for |1><1|.');

    disp('test_bloch_vector passed.');
end