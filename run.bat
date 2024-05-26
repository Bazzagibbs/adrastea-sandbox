@echo off

REM Playdate's build toolchain is pretty complicated, so I've written a build program to somewhat simplify the build process in a cross-platform way.
REM The build program can be used directly with `odin run .`, however some platform-specific scripts help with common configurations.

odin run . -debug -define:run_simulator=true

del adrastea-sandbox.exe
del adrastea-sandbox.pdb
