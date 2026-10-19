# 目录层级工具的排除边界

`getFirstLevelFolders(rootDir)`、`getSecondLevelFolders(rootDir)`和
`getThirdLevelFolders(rootDir)`分别返回精确第一、第二、第三级目录的完整路径列cell数组。

从rootDir的直接子目录开始逐层检查名称：任一层目录名称包含连续子串`readme`
（忽略大小写）就排除该目录及其全部后代，不再遍历该分支。
rootDir本身和rootDir以上的路径不参与检查。文件、`.`和`..`不计入结果。
例如rootDir为A：A/B/C/ReadMe、A/B/ReadMe/C、A/ReadMe/B/C都排除；
如果A自身名为ReadMe，仍正常检查其下的B/C/D。

第二级工具先取得合规第一级目录，再筛选其直接子目录；第三级工具在合规第二级目录上
做相同步骤。筛选规则集中于第一级工具，不对整个绝对路径做关键词搜索，不改变动画算法。
空结果返回0×1 cell，根目录不存在报错。`read_me`或`read me`不含连续readme，不扩展排除。
独立测试位于`tools/tests/testFolderBranchExclusion.m`，只创建临时目录。

## 直接子目录工具

以下旧入口也仅检查输入根目录下的直接子目录名称，按相同的readme子串规则筛选，
根目录及祖先不参与检查。它们不递归，不自动进入已排除目录的后代；
调用者显式把一个readme目录作为新的输入根时，仍正常扫描其子目录。

- `00_asmCase/getDnsSubcaseDirList(rootPath)`：完整路径列cell，沿用`dir`顺序，
  不进行数值排序；因此`1、10、2`保持此顺序。`getDNS(rootDir)`沿用此发现结果。
- `11_SubFolderFileSearch/getSubFolder(src)`：路径列cell，相对输入仍返回相对路径。
- `01_ReadRaw/getCaseRawDir(rawRoot)`：`[numCase, allCaseRawList]`，实际深度为一级，
  路径列cell也保留输入的相对/绝对形式。

三个函数的空结果均为0×1 cell，`numCase`为0；修复了旧getSubFolder返回`{[]}`及
getCaseRawDir空目录变量未定义的问题。不增加时间拼接逻辑，不改排序或读取算法。
筛选显式写在各入口中，以保留旧接口的路径形式及既有路径依赖。
独立测试同时覆盖这三个入口的顺序、相对路径、空目录及多层逐次扫描。
BubblePlus旧`getAllFolders`入口仍返回`dir`结构体数组，其测试位于BubblePlus的
`tests/testRepositoryBoundaries.m`；未将该历史目录新增到正式路径配置。
