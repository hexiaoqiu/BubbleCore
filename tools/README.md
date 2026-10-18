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
