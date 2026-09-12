# Historical LSC implementations

The current BubblePlus LSC roll workflow is maintained in the companion repository:
`1_BubblePlus/05_BubblePlusCore/02_LSC_Roll`.

`lscFindInterval.m` and `lscLagranTraceCube.m` have moved there without changes to
their function names or algorithms. Add that directory to the MATLAB path when
using historical functions here that call these helpers (including
`lscGetAllLSC`, `lscGetAllLSCVer2` through `lscGetAllLSCVer5`, and
`lscGetAllLSCRelease`). Update both repositories together.

The other historical implementations in this directory have been left unchanged.
