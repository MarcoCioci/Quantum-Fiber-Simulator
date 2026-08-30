[omega_offsets_A, ~] = pmd_frequency_grid(101, 4e12);
[omega_offsets_B, ~] = pmd_frequency_grid(101, 4e12);

sigma_sum = 0.2e12;          % [rad/s]
sigma_difference = 1.5e12;   % [rad/s]

spectral_weights = pmd_joint_spectral_weights( ...
    omega_offsets_A, omega_offsets_B, sigma_sum, sigma_difference);