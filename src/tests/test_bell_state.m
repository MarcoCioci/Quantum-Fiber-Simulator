function test_bell_state()
% TEST_BELL_STATE  Validate Bell state construction

    disp('Running test_bell_state...');

    types = {'psi_plus', 'psi_minus', 'phi_plus', 'phi_minus'};

    for k = 1:length(types)
        psi = bell_state(types{k});

        % Check normalization
        assert(abs(norm(psi) - 1) < 1e-12, ...
            'Bell state is not normalized.');

        % Check dimension
        assert(isequal(size(psi), [4,1]), ...
            'Bell state has incorrect dimension.');
    end

    disp('test_bell_state passed.');
end