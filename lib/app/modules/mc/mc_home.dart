import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class MooncellToolsPage extends StatelessWidget {
  const MooncellToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mooncell wiki"),
      ),
      body: ListView(
        // padding: EdgeInsets.symmetric(),
        children: [
          buildCard(Text(
            Language.isZH ? '一些适用于Mooncell wiki编辑/导出相关的工具' : 'This page contains tools for Mooncell - a Chinese wiki',
            textAlign: TextAlign.center,
          )),
          buildCard(buildMardkown("""### $kStarChar2 注意事项
- App 语言需设置为 **简体中文**, 首选翻译语言需设置为 **国服(简体中文)->日服(日本語)->其他** !!! 否则翻译将会出错
- 导出结果可能存在错误或未解析的地方，请检查并完善后再编辑至wiki网站
- 使用前请确保使用最新版app
- 若存在错误，请积极反馈
- 前往文档查看本页最新内容: <https://docs.chaldea.center/zh/guide/mooncell>
""")),
          TileGroup(
            header: S.current.quest,
            children: [
              ListTile(
                title: buildMardkown("""### $kStarChar2 导出特定关卡
- 进入到目标关卡的详情页，右上角菜单选择“导出至Mooncell”即可，复制wiki代码至对应页面

### $kStarChar2 导出一组关卡
- 进入某个活动或主线的页面，所有关卡被分类为 主线关卡/Free本/团体战/高难度关卡 等，选择一个分类进入，
右上角点击“导出至Mooncell”。根据情况决定是否需要设置背景色。

### $kStarChar2 注意事项
- 开放条件需再次确认并修改/增加
- 主线关卡的固定掉落和Free本的掉落需留意关卡的样本数，样本数过低可能数据不准确
"""),
              )
            ],
          ),
          TileGroup(
            header: S.current.summon_banner,
            children: [
              ListTile(
                title: buildMardkown("""### 前言
以“唠唠叨叨超五棱郭推荐召唤2”为例: 一个卡池公告往往会包含多组pickup，会被分为多个子卡池，数据结构分别为:
- Mooncell: 
  - 卡池页面: [唠唠叨叨超五棱郭推荐召唤2](https://fgo.wiki/w/唠唠叨叨超五棱郭推荐召唤2)
  - 模拟器页面: [唠唠叨叨超五棱郭推荐召唤2/模拟器](https://fgo.wiki/w/唠唠叨叨超五棱郭推荐召唤2/模拟器)
  - 各子卡池的概率分布表: [唠唠叨叨超五棱郭推荐召唤2/模拟器/data1](https://fgo.wiki/w/唠唠叨叨超五棱郭推荐召唤2/模拟器/data1), data2, ...

- FGO原始卡池数据只有独立的子卡池数据
  - ぐだぐだ超五稜郭 沖田総司(セイバー)ピックアップ召喚
  - ぐだぐだ超五稜郭 土方歳三ピックアップ召喚

### $kStarChar2 导出同一组卡池
1. 请确保app数据版本最新
2. 首页-卡池-原始卡池数据进入，选择日服
3. 勾选目标卡池，第一次勾选时app将会自动勾选其他同组的卡池，若有缺失或未选择，请手动修改
4. 点击创建Mooncell卡池，等待自动解析完成
5. 公告处列出了官网(<https://news.fate-go.jp>)前两页的卡池公告
6. 若本卡池公告在列表中，选中将自动提取 日文卡池名、日服公告链接、标题图
7. 在中文卡池名处填写正确的翻译，方可链接到正确的wiki页面
8. 分别复制 “卡池”/“模拟器”/“dataX”的数据，并点击创建页面跳转到对应的wiki页面粘贴
9. “下载标题图”到本地，并点击“上传标题图”打开wiki的文件上传页面


### $kStarChar2 注意事项
- 概率表需检查各行概率及总概率是否正确
- 关联卡池和活动等需手动填写
"""),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(child: child),
      ),
    );
  }

  Widget buildMardkown(String data) {
    return MarkdownBody(
      data: data,
      onTapLink: (text, href, title) {
        if (href != null) {
          launch(href);
        }
      },
    );
  }
}
