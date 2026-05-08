# Quantum Fiber Simulator — Text and Thesis Repository

This directory contains the theoretical, analytical, and manuscript-oriented material associated with the Quantum Fiber Simulator project.

The repository is organized as a modular scientific workspace supporting:

- theoretical development,
- analytical derivations,
- MATLAB simulator implementation,
- numerical validation,
- thesis writing,
- future extensions toward realistic quantum fiber-channel models.

The structure is intentionally separated into independent but synchronized layers in order to preserve:

- analytical traceability,
- implementation modularity,
- reproducibility of numerical results,
- consistency between theory and simulation.

The overall organization follows the repository policies and writing conventions defined throughout the project documentation.

---

# Scope of the Project

The project studies the propagation of polarization-entangled photon pairs through optical fibers using a quantum-information-oriented formalism.

The current implementation focuses on:

- two-qubit polarization-entangled states,
- local unitary fiber transformations,
- phase-induced evolution,
- correlation observables,
- density-matrix formalism,
- effective decoherence and depolarization models,
- entanglement and nonlocality metrics.

The theoretical framework progressively evolves from:

1. ideal Bell states,
2. deterministic local phase evolution,
3. ensemble averaging,
4. mixed-state descriptions,
5. noisy quantum channels,
6. effective fiber models.

This hierarchy mirrors the simulator architecture and the thesis structure.

---

# Repository Structure

Text/
├── Thesis/
├── Derivations/
├── Notes/
├── Sources/
└── Archive/

---

# Directory Overview

## Thesis/

Contains the manuscript-oriented material for the thesis.

Thesis/
├── Appendix/
├── Bibliography/
├── Chapters/
├── Figures/
├── Styles/
├── Tables/
├── main.tex
└── main.pdf

### Purpose

This directory contains the structured LaTeX manuscript corresponding to the current thesis development stage.

The organization follows a modular report-class hierarchy:

| Chapter | Topic |
|---|---|
| 1 | General Framework |
| 2 | Modeling Strategy |
| 3 | Physical and Mathematical Representation |
| 4 | Quantitative Characterization of Two-Qubit States |
| 5 | Numerical Experiments and Results |

The current chapter structure is aligned with the simulator development workflow and the progressive refinement strategy adopted throughout the project.

---

## Thesis/Chapters/

Contains the main scientific content of the manuscript.

Current chapters:

01_General_Framework.tex
02_Modeling_Strategy.tex
03_Physical_and_Mathematical_Representation.tex
04_Quantitative_Characterization_of_Two-Qubit_States.tex
05_Numerical_Experiments_and_Results.tex

These chapters develop:

- the physical motivation,
- the quantum-information formalism,
- the effective fiber models,
- the density-operator framework,
- the numerical experiments validating the simulator.

The organization follows the writing and hierarchy policies defined in the LaTeX style guides.

---

## Thesis/Appendix/

Contains selected derivations and supplementary analytical material intended to support the thesis manuscript.

Current appendices:

A_reduced_density_operators.tex
B_fidelity_pure_reference_state.tex
C_concurrence_and_reduced_density_operators.tex

Appendices are reserved for:

- mathematically central derivations,
- reproducibility-oriented calculations,
- derivations repeatedly referenced in the main text.

Not all derivations belong in the appendices; larger analytical developments are maintained separately inside Derivations/.

---

## Thesis/Figures/

Contains figures generated during numerical experiments and theoretical visualization.

Current structure:

Figures/
├── Experiment_1/
├── Experiment_2/
├── Experiment_3/
├── Experiment_4/
├── Schematics/
└── Theory/

The current figures include:

- correlation validation plots,
- correlation tensor visualizations,
- fidelity/purity/concurrence evolution,
- CHSH nonlocality analysis,
- Bloch-sphere measurement-axis representations.

The figure organization follows the progressive experiment structure implemented in the simulator.

---

## Thesis/Styles/

Contains shared LaTeX style modules.

Styles/
├── formatting.tex
├── macros.tex
├── metadata.tex
├── notation.tex
├── packages.tex
└── theorem_styles.tex

This modular structure separates:

- package loading,
- formatting rules,
- reusable macros,
- notation conventions,
- theorem environments,
- document metadata.

The style organization is consistent with the repository policy for scalable manuscript development.

---

## Derivations/

Contains dedicated analytical derivations and mathematical expansions.

Current derivations:

D1_density_operator_expectation_values.tex
D2_partial_trace_maximally_entangled_states.tex
D3_phase_shifted_bell_state_metrics.tex
D4_correlation_tensor_phase_model.tex

This directory acts as a reusable mathematical support repository.

It contains:

- full derivations,
- tensor expansions,
- analytical validations,
- intermediate calculations,
- exploratory analytical work.

These files are intentionally separated from the thesis manuscript to preserve readability and maintain a clean conceptual flow in the main text.

Examples include:

- explicit derivation of reduced density operators,
- Bell-state metric derivations,
- correlation tensor derivations,
- analytical validation of phase-evolved states.

---

## Notes/

Contains exploratory material and temporary research notes.

Typical contents include:

- advisor discussions,
- PMD modeling ideas,
- future extensions,
- exploratory reasoning,
- implementation planning,
- experimental considerations.

This directory is intentionally informal and is not directly tied to the final manuscript structure.

---

## Sources/

Contains external references and scientific material used throughout the project.

Current sources include:

- Nielsen & Chuang,
- lecture notes,
- Bell inequality references,
- quantum tomography material,
- quantum optics references.

Example files:

bell_on_the_einstein_podolsky_rosen_paradox.pdf
Quantum_State_Tomography.pdf
quantum-computation-and-quantum-information-nielsen-chuang.pdf

These references support both the theoretical framework and the simulator implementation.

---

## Archive/

Contains deprecated or superseded material.

This directory stores:

- previous monolithic thesis versions,
- outdated derivations,
- experimental drafts,
- temporary repository structures.

Archived content is preserved for reproducibility and historical traceability.

---

# Modeling Philosophy

The simulator follows a progressive refinement hierarchy:

Ideal Bell states
    ↓
Local phase evolution
    ↓
General local unitaries
    ↓
Density matrices
    ↓
Quantum channels
    ↓
Effective fiber models

The current implementation intentionally prioritizes:

- analytical transparency,
- mathematical consistency,
- modular simulator design,
- reproducibility of numerical results.

Optimization and high-performance considerations are currently secondary to validation and theoretical consistency.

---

# Current Physical and Numerical Capabilities

## Implemented

- Bell-state initialization,
- two-qubit Hilbert-space formalism,
- local unitary evolution,
- reduced phase model,
- correlation tensor computation,
- arbitrary local measurement axes,
- CHSH nonlocality analysis,
- density-operator formalism,
- partial trace,
- purity computation,
- fidelity evaluation,
- concurrence evaluation,
- random phase ensemble averaging,
- depolarizing channel simulations,
- automated MATLAB plotting pipeline.

---

# Current Numerical Experiments

## Experiment 1 — Deterministic Phase Sweep

Studies coherent phase evolution of Bell states under local Z-axis rotations.

Includes:

- analytical vs numerical correlation validation,
- correlation tensor evolution,
- state-metric analysis.

---

## Experiment 2 — Random Phase Ensemble

Studies effective decoherence induced by ensemble-averaged random phase realizations.

Includes:

- uniform, constant, and Gaussian phase distributions,
- ensemble density matrices,
- degradation of correlations and state metrics.

---

## Experiment 3 — Depolarizing Channel

Studies effective depolarization of Bell states through mixed-state evolution.

Includes:

- purity degradation,
- fidelity decay,
- concurrence suppression,
- analytical validation against theoretical predictions.

---

## Experiment 4 — CHSH Nonlocality

Studies Bell inequality violation under:

- coherent phase evolution,
- depolarizing noise.

Includes:

- fixed-axis CHSH analysis,
- maximal CHSH violation,
- Bloch-sphere visualization of measurement axes.

---

# MATLAB–Theory Correspondence

The simulator maintains an explicit mapping between the mathematical formalism and the MATLAB implementation.

| Mathematical Object | MATLAB Representation |
|---|---|
| |ψ⟩ | complex column vector |
| ρ | density matrix |
| U | unitary matrix |
| σ_i ⊗ σ_j | Kronecker-product operator |
| ⟨O⟩ | expectation value |
| T_ij | correlation tensor element |

This direct mapping preserves analytical traceability and simplifies validation against theoretical predictions.

---

# Writing and Documentation Standards

The repository adopts strict formatting and documentation conventions for both MATLAB and LaTeX material.

The conventions include:

- structured LaTeX hierarchy,
- standardized equation labeling,
- modular manuscript organization,
- explicit notation consistency,
- documented MATLAB function templates,
- centralized plotting styles and palettes.

Relevant guides:

- latex_style.txt
- latex_repository_format.txt
- Code_format.txt
- symbology.txt

These conventions ensure consistency across:

- derivations,
- simulator code,
- manuscript text,
- numerical analysis.

---

# Physical Interpretation of the Current Model

The present modeling stage focuses on the effective action of optical fibers on polarization-entangled photon pairs.

After compensation of global polarization rotations, the dominant residual effect is modeled as a relative phase shift between horizontal and vertical polarization components.

This leads to an effective evolution of the form:

(|01⟩ + e^{iθ}|10⟩) / √2

where θ depends on fiber-induced birefringence and propagation conditions.

The simulator is therefore designed to investigate:

- how measurable correlations evolve under phase accumulation,
- how ensemble averaging produces effective decoherence,
- how depolarization affects entanglement and nonlocality,
- how realistic fiber effects can be progressively incorporated.

The long-term objective is to connect experimentally observable quantities with a consistent quantum-information-based simulation framework.

---

# Long-Term Objective

The long-term objective is the development of:

- a validated quantum fiber-channel simulator,
- a reproducible computational research environment,
- a structured derivation repository,
- a scientifically rigorous thesis manuscript,
- an extensible framework for advanced quantum-optical channel modeling.

Future extensions include:

- frequency-dependent fiber models,
- polarization mode dispersion (PMD),
- stochastic concatenated fiber segments,
- generalized CPTP channels,
- quantum tomography workflows,
- experimental-data integration,
- high-performance numerical scaling.

The repository is therefore designed not only as a thesis project, but as a modular research framework supporting future developments in quantum communication and quantum-optical simulation.