# Quiver

## Crameri 色图库

完整第三方包位于`CrameriColourMaps/`（原`plotRelated`中的六个相关文件）。
MAT色表、预览图片、上游说明和许可证均保留；源码仅将资源读取改为相对函数目录的绝对路径，
不改变色表或插值算法。BubblePlus的`setupBubblePlusPath`会显式加入此子目录；
独立使用BubbleCore时需自行加入该子目录，不必加入含重复图形工具的`plotRelated`。
调用接口和上游引用说明见[Crameri包说明](CrameriColourMaps/README.md)。

Here you find 2 MATLAB functions: SetQuiverColor and SetQuiverLength.
They allow you to change the appearance of quiver plot in MATLAB.
You can change the color of each arrow (SetQuiverColor) and
change the length of each arrow (SetQuiverLength) in units of the x/y/z axis.
It gives better control of what is going on.

You simply need to give the handle to the function and a magnitude for
SetQuiverColor or SetQuiverLength function.

In addition, the SetQuiverColor function offer the possibility to provide a
maximum and minimum value that would be different to that of the magnitudes that
you request. This allows to saturate or only use part of the colormap range.
The desired colormap should also be provided.
