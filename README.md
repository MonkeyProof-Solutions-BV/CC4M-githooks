# CC4M-githooks

To maintain high code quality in your repository, it's helpful to run a static code checker before committing changes. In this repository, files are stored for automating a CC4M run on your MATLAB code using a pre-commit hook.

## Block the commit
The root folder of the repositry contains the files as explained in a [blog](https://monkeyproofsolutions.nl/about/blog/cc4m/using-githooks) on this topic.

* [pre-commit](pre-commit) shell script executed by Git.
* [precommit_example.m](precommit_example.m) MATLAB function as called from the shell script.

## Block, but allow to overrule
The folder [with_proceed_dialog](with_proceed_dialog) contains derivatives from the files above, that implement a question dialog in the MATLAB script to allow for committing the changes, regardless of the violations.


# Links

* Details explanation in [blog](https://monkeyproofsolutions.nl/about/blog/cc4m/using-githooks)