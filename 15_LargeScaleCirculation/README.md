# Historical LSC implementations

The current BubblePlus LSC roll workflow is maintained in the companion repository:
`1_BubblePlus/05_BubblePlusCore/02_LSC_Roll`.

`lscFindInterval.m` and `lscLagranTraceCube.m` have moved there without changes to
their function names or algorithms. Add that directory to the MATLAB path when
using historical functions here that call these helpers (including
`lscGetAllLSC`, `lscGetAllLSCVer2` through `lscGetAllLSCVer5`, and
`lscGetAllLSCRelease`). Update both repositories together.

The other historical implementations in this directory have been left unchanged.

## 默认路径与职责边界（增量 7）

本目录是历史模型分析代码，不是当前 LSC 工作流的基础依赖。
`setupBubblePlusPath` 不再将本目录加入正式路径；没有删除或搬动这里的实现。
当前 BubblePlus 正式 LSC 不调用这里的函数。

需要复现旧实验时，先配置正式路径，再显式加入本目录；此时需要同时使用
BubblePlus 的 `02_LSC_Roll/lscFindInterval.m`。已经确认的直接调用者是
`lscGetAllLSC`、`lscGetAllLSCVer2`—`lscGetAllLSCVer5`、`lscGetAllLSCRelease`。
`lscExtractRolls`、`lscGetAllRolls` 是间接调用者。
没有发现本目录对 `lscLagranTraceCube` 的直接调用，前文两函数迁移说明不表示
每个历史入口都依赖两者。

不要用 `genpath` 把历史目录重新混入默认路径。本目录保留的反向依赖属于明确的
历史复现边界，不应作为 BubbleCore 通用基础模块的依赖。
