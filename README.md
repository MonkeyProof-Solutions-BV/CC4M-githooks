# CC4M-githooks


## Static Code Analysis with CC4M Pre-Commit Hook

To ensure consistent code quality, this repository includes support for running static code analysis on MATLAB source files prior to committing changes. The analysis is performed using [CC4M (Code Checker for MATLAB)](https://monkeyproofsolutions.nl/products/code-checker-for-matlab/) and is integrated into the Git workflow via a **pre-commit hook**.
The pre-commit hook automatically invokes CC4M during the commit process to verify that modified MATLAB files comply with the defined coding guidelines. This check can even run in your current active session, see [below](#connect-with-open-development-session).

## Workflow

The pre-commit process operates as follows:

1. When a commit is initiated, the Git pre-commit hook executes CC4M on the relevant MATLAB files.
2. If CC4M reports no violations, the commit proceeds normally.
3. If violations are detected, a report is generated and presented to the user; and the user is prompted in the Git client: "Violations found, do you still want to commit? (y/N)". Answer either

   * **N** to cancel the commit to address the reported issues, or
   * **y** to proceed with the commit despite the detected violations.

This mechanism helps enforce coding standards while still allowing controlled overrides when necessary.


## Prerequisits
To use the CC4M pre-commit hook provided in this repository, the following software components must be installed and properly configured on the system:
* MATLAB R2020b or later
* CC4M version 2.21 or later
* Python in a version supported by the installed MATLAB release, see [the MATLAB–Python compatibility matrix](https://www.mathworks.com/support/requirements/python-compatibility.html). <br>
The minimum Python version required for the hook mechanism is 3.8.
* Git

Ensure that all dependencies are accessible from the environment in which Git commands are executed.

## Installation

By default, the pre-commit hook executes CC4M within a dedicated MATLAB session that remains persistently active across checks.
Whenever MATLAB files need to be analyzed, CC4M is invoked in this session through Python using the MATLAB Engine API for Python  ([`matlabengine`](https://pypi.org/project/matlabengine/)) module. 

This execution model requires a Python environment in which the appropriate version of `matlabengine` is installed. The required `matlabengine` package version is determined by the MATLAB release in use, as the MATLAB Engine API is tightly coupled to a specific MATLAB version. The installation procedure described in the following section sets up this Python environment and installs the correct `matlabengine` package to ensure compatibility with the configured MATLAB release.


1. Clone the repository to your local machine.
2. Start MATLAB with CC4M installed and licensed.
3. Verify Python is availalbe using [`pyenv`](https://mathworks.com/help/matlab/ref/pyenv.html).  
   ```
   pe = pyenv()
   ```
   This command returns the current Python configuration. Refer to the MATLAB documentation for `pyenv` for instructions on modifying the configuration, including links for downloading a compatible Python version if required.

4. From your MATLAB session navigate to the [./matlab/](./matlab/) folder in the local working copy.
5. Run the installation script [`install_git_hooks.m`](./matlab/install_git_hooks.m). This script performs the following actions:
    - Creates a dedicated Python environment at `fullfile(userpath(), 'cc4m', 'python')`.
    - Installs the appropriate `matlabengine` package from PyPI.
    - Copies the required MATLAB support files from [./matlab/](./matlab/) to `userpath()`.
6. Enable the pre-commit hook by copying the [`pre-commit`](./pre-commit) file to the `./.git/hooks` directory of each local repository where the hook should be active.
7. Configure the repository-specific `pre-commit` to ensure:
    - The correct MATLAB version is selected.
    - A valid CC4M license is available.
    - The desired blocking levels are configured.
    - The appropriate 'changedOnlyScope' defined. 
        - `file` (When a file has changes, violations in the whole file are reported.
        - `block` When a *function*, *properties* or *methods* block has changes, violations in the whole block are reported.
        - `line` Only violations on the changed lines are reported[^lines].

### Install hook without the use of Python

The reason for using Python in the hook is performance: from Python the `matlabengine` can be used to connect with a MATLAB session that can stay open or even used in between the commits.         

If for some reason direct calls to MATLAB are needed, release [v1.0.0](https://github.com/MonkeyProof-Solutions-BV/CC4M-githooks/releases/tag/v1.0.0) of the CC4M githooks is implemented without the Python intermediate layer. 


## Connect with open development session

To reuse the MATLAB session you have open already, enable sharing the engine with the name "CC4M_MATLAB_SESSION" or run [`cc4m_connectpy()`](./matlab/cc4m_connectpy.m).
Additional benefit is that (dependency) analysis is performed on exact same MATLAB path definition.

# Links

* Repository on GitHub:  [https://github.com/MonkeyProof-Solutions-BV/CC4M-githooks](https://github.com/MonkeyProof-Solutions-BV/CC4M-githooks)
* Detailed explanation in [blog](https://monkeyproofsolutions.nl/about/blog/cc4m/using-githooks)