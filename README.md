# 某游戏音乐解包工具

仅供个人存档备份，以便于每次版本更新能解包出新的音乐文件。脚本由 Google Gemini 生成。

## 更新步骤

1. clone 仓库到 StreamingAssets/InstallResource/txtp 路径；
2. 执行 wwiser，选择上级目录中 Music_ 开头的所有 .bnk 文件，分析并导出所有的 txtp；
3. 执行 copy_wem_to_txtp.bat，会自动将上级目录中的所有 .media.wem 文件复制到 txtp/wem 目录下并去掉名称中的 .media；
4. 执行 rename_txtp.py，会自动读取 StreamingAssets/Audio/GeneratedSoundBanks/Wwise_IDs.h 中的事件名-事件 ID 映射，并重命名所有已知的 .txtp 文件；
5. 用安装好 vgmstream 插件（附带在本项目 fb2k 目录下）的 foobar2000 打开所有 .txtp 文件，全选并转换成默认的 OGG Vorbis 120k 到 ogg 目录下；（oggenc2 工具附带在本项目 fb2k 目录下）。
