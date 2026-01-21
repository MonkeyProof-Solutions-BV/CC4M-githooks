# CC4M-githooks

To maintain high code quality in your repository, it's helpful to run a static code checker before committing changes. In this repository, files are stored for automating a CC4M run on your MATLAB code using a pre-commit hook.

We'll integrate CC4M (Code Checker for MATLAB) into a Git pre-commit hook to automatically verify code compliance against the guidelines before allowing it to be committed. Here’s how it works:

* When you commit changes, the pre-commit hook first runs CC4M.
* If no issues are found, the commit proceeds.
* If violations are detected, the report is shown and using a dialog the commit can either be canceled, or allowed anyway.


## Prerequisits
In order to be able to use this pre-commit hook, your system needs:
* MATLAB (2020b or later)
* CC4M (minimum 2.21)
* Python (supported by used MATLAB installation, see [link](https://www.mathworks.com/support/requirements/python-compatibility.html). Minimum Python version 3.8.
* Git

## Installation

By default, the pre-commit hook runs CC4M in a dedicated MATLAB session that remains active. Whenever files need to be checked, CC4M is executed within this session via Python using the `matlabengine` module. To support this workflow, a Python environment with the [`matlabengine`](https://pypi.org/project/matlabengine/) package installed is required.

Because `matlabengine` is tied to a specific MATLAB release—and the code must be accessible from the pre-commit hook—an installation procedure is provided:

1. Clone this repository.
2. Open MATLAB with CC4M installed.
3. In the local working copy, navigate to the matlab folder.
4. Run `install.m`, which:
    - Creates a Python environment at `fullfile(userpath(), 'cc4m', 'python')`
    - Installs the `matlabengine` package from PyPI
    - Adds the MATLAB files to `userpath()`
5. Copy the `pre-commit` file to the `./.git/hooks` directory of each local repository where you want to enable the `pre-commit action.`
6. Adapt the repository-specific `pre-commit` to make sure:
    - Correct MATLAB version is used
    - CC4M License is available.
    - The desired blocking levels are configured.
    - The desired 'changedOnlyScope' defined. 
        - `file` (When a file has changes, violations in the whole file are reported.
        - `block` When a *function*, *properties* or *methods* block has changes, violations in the whole block are reported.
        - `line` Only violations on the changed lines are reported[^lines].

## Use

After the installation procedure, every commit will trigger a CC4M run on all MATLAB files that are part of the commit. The first check takes more time, as a new MATLAB session is started using the `matlabengine`. This session will be reused with the following commits.

When all checks pass, the files will be committed. In case of violations, there are blocking violations and violations that optionally are allowed. In the first case - the commit is cancelled automatically, in the latter you can still commit, by answering "y" to the following question (as displayed in your Git Client) "Violations found, do you still want to commit? (y/N)".
 

### Connect with open development session

You can reuse the MATLAB session you have open already, by sharing the engine with the name "CC4M_MATLAB_SESSION" or runnning `cc4m_connectpy()` .

# Links

* Repository on GitHub:  [https://github.com/MonkeyProof-Solutions-BV/CC4M-githooks](https://github.com/MonkeyProof-Solutions-BV/CC4M-githooks)
* Detailed explanation in [blog](https://monkeyproofsolutions.nl/about/blog/cc4m/using-githooks)