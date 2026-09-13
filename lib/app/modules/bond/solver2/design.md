# FGO 羁绊最优编队求解器（solver2）设计文档

本文档是 solver2 的完整规范，固化 2026-09-01 设计评审会话的全部决策。
决策依据与备选方案见 `docs/adr/0008-solver2-reuses-v1-pool-modeling.md`。

## 1. 目标与非目标

### 1.1 目标

在以下约束下求最大队伍总羁绊（茶壶 ×1 计算，显示时再乘茶壶倍数）：

- 编队固定槽（从者/礼装 pin）与助战位（数量、位置完全由编队决定）

- 候选过滤：favorite、bond 上限、未实装（按 region）、自定义排除

- cost 预算（`ConstData.maxUserCost` 或用户覆盖）

并修复 v1 的三个缺陷：

| v1 缺陷        | 根因                                        | solver2 修复                       |
| :----------- | :---------------------------------------- | :------------------------------- |
| 从者重复         | 结果只到 class 级，无跨槽去重的实例化                    | §6.2 后处理实例化                      |
| 羁绊值非最高       | phase 2 节点上限 6 万太紧（显示 NOT proven optimal） | §5.3 上限提升至 120 万 + targeted 上界收紧 |
| 特性礼装无生效对象也佩戴 | 零贡献佩戴不降总分，混入平局                            | §6.1 边际贡献过滤                      |

### 1.2 非目标

- 不搜索「有无助战」的优劣——助战数量与位置是常量

- 不改变 v1 建模层对稀有效果的近似（见 §2.3 警告清单）

## 2. 数据建模层（复用 v1）

**solver2 原样复用 v1 的建模层**，不重写：

- `solver/ce_pool.dart`：`CeBondEffect`（效果原子：scope/rate/value + wearer
  侧与 target 侧条件，语义与 `FormationBondTab.calcResults` 一致）、
  `BondCeClass`（礼装等价类 + 容量 = 成员数）、`SupportCeCandidate`
  （助战位礼装候选）、`CeBondPool.build`

- `solver/svt_pool.dart`：`BondSvtClass` / `BondSvtMember`（从者等价类、
  灵基再临切片、容量 = 成员数）、`SvtBondPool.build`（含过滤规则、
  campaign、活动技能解析）

等价类与容量的术语定义见 `docs/context/bond-solver/CONTEXT.md`。

### 2.1 规则范围（与 v1 完全一致）

- per-slot 自定义加成（addRate / addValue）

- bond15（+250 进团队 rate 标量）

- 羁绊上限（isBondReachLimit：该槽不产出羁绊）

- 活动加成（self rate/value）、campaign、活动技能 team 效果

### 2.2 修正项

| 项        | 说明                                                                                                |
| :------- | :------------------------------------------------------------------------------------------------ |
| 取整       | **double floor**，表达式与 `formation_bond.dart` 的 `SvtBondBonusResult.totalBond` 字符级一致，禁止整数 `~/` 等价改写 |
| rate cap | `min(C, ConstData.constants.maxFriendShipUpRatio)`，只作用于 C，不作用于 B                                  |
| 助战前排     | +40（RateCount）作用于全队所有槽，受 `frontlineBonus` 开关控制                                                    |

## 3. 羁绊计算公式（权威定义）

### 3.1 RateCount 约定

游戏内部百分比基准 **1000 = 100%**（4% = 40，20% = 200）。

### 3.2 单从者公式

```dart
/// 每个产出羁绊的从者位（我方从者、非 bond-reach-limit）：
/// v = floor(floor(A * (1 + B / 1000)) * (1 + min(C, cap) / 1000)) + D
///
/// A：关卡基础羁绊值（quest.bond）
/// B：位置加成 = B_self + B_global（进第一次乘法，不受 cap）
/// C：比例加成总和（进第二次乘法，受 cap）
/// D：固定值加成 = D_team + D_self（乘法后相加，不受 cap）
int calcSlotBond(int A, int B, int C, int D) {
  int v = (A * (1 + B / 1000)).floor();
  v = (v * (1 + min(C, ConstData.constants.maxFriendShipUpRatio) / 1000)).floor();
  return v + D;
}
```

### 3.3 变量归类

| 加成类型                 | 数值           | 作用范围   | 公式变量             |
| :------------------- | :----------- | :----- | :--------------- |
| 我方从者在前排              | +200         | 仅该从者   | **B**（B\_self）   |
| 助战在前排                | +40          | 全队     | **B**（B\_global） |
| 礼装比例加成（flat）         | 礼装面板值        | 全队     | **C**（C\_team）   |
| 活动加成                 | 因从者而异        | 仅该从者   | **C**（C\_self）   |
| 特性匹配礼装               | +200/特性（可叠加） | 仅持有特性者 | **C**（C\_self）   |
| per-slot 自定义 addRate | 用户设定         | 仅该槽    | **C**（C\_self）   |
| 礼装固定加成（肖像类）          | 如 +50        | 全队     | **D**（D\_team）   |
| 活动值加成 / 自定义 addValue | 因从者/用户而定     | 各自范围   | **D**（D\_self）   |
| bond15               | +250         | 全队     | **C**（C\_team）   |

B\_self 与 B\_global 在 B 乘区内**相加**后参与第一次乘法。B 受
`option.frontlineBonus` 开关控制。

### 3.4 助战规则

- 助战槽不产出羁绊（`producesValue = false`）

- 助战在前排时为全队提供 `B_global = 40`；助战自身 `B_self = 0`

- 助战数量与位置由编队固定，搜索不枚举有无助战

- 助战位礼装：从 `SupportCeCandidate` 中搜索（仅 team-scope flat 效果，
  成本 0、不占 owned 容量）；pinned 助战礼装是常量

- GrandBoard 助战位的自由 equip3 不支持（保留 v1 警告）

### 3.5 队伍总羁绊

仅累加我方产出槽；助战、bond-reach-limit 槽不计。评估函数仅用于
叶节点精确计算与测试；搜索中间过程一律使用上界（§5.4）。

## 4. 搜索问题形式化

- **槽分类**（对编队 6 槽逐一判定）：

  1. 助战槽（CE 可能自由）
  2. 固定从者槽（equip1/equip3 可能自由）
  3. 自由槽（从者 + equip1 均自由）

- **item 空间**：每槽枚举（从者类 × 礼装类）组合 + 「空」选项，
  附 cost 与容量消费（从者类消费 1、礼装类按佩戴数消费）

- **约束**：cost 预算（固定槽已付 cost 先扣除）、各类容量

- **目标**：最大化 `Σ calcSlotBond`，并收集平局

## 5. 搜索算法（两阶段分支限界）

沿用 v1 两阶段骨架，修复 phase 2。核心状态（deferred 槽 + 团队标量
T/V + worn targeted 集合）语义与 v1 一致，以 v1 实现为参照重写。

### 5.1 Phase 1：无 targeted 子空间（精确）

- 排除 targeted 礼装 item，从者类按全部维度归并（v1 `dedupSvt`）

- MCKP-DP 松弛（逐槽、忽略容量）作为剩余槽上界

- item 按 DP 价值降序排列，先探优分支

### 5.2 Phase 2：全空间（seeded DFS）

以 phase 1 最优解为初始 incumbent，只找严格更优的 targeted 佩戴解。

### 5.3 Phase 2 修复点（Bug 2）

1. **节点上限提升至 120 万**（与 phase 1 相同；v1 为 6 万）
2. **targeted 上界收紧**：worn targeted 的收益不再只记给穿戴者，
   而是按 `剩余槽位数 × 最大单类接收收益 × maxMult` 计入 bound
   （v1 `_wornGain` 已有该形状，保留并复核）
3. **targeted item 排序**：按「真实期望收益」（对当前已确定接收者
   集合的实际 receipts，而非乐观全队收益）排序，让有收益的 targeted
   佩戴先被探索，尽早抬高 incumbent

### 5.4 上界设计原则（替代旧文档 §4.2 伪代码）

**有效性要求**：任意节点 `bound ≥ 该子树最优值`。所有乐观假设必须
只允许高估，不允许低估。评审确认的合法乐观项：

- B\_global 乐观假设（前排尚有空位且助战可用时）

- 未确定槽按 cSelf 降序、前排位优先分配（单调性保证最优分配）

- 为助战预留槽位（助战为常量，合法）

**性能要求（硬性）**：上界函数禁止每节点对候选全表扫描 / 排序
（旧伪代码 O(N log N)/节点不可接受）。必须预计算：

- 候选 cSelf 预排序数组（phase 内不变，O(1) 取前 k）

- MCKP-DP 表：`dp[槽位][剩余预算]`（忽略容量的松弛）

- flat rate 容量后缀和（`flatCapSuffix`）

- 每 item 的乐观 DP 值（构造时一次算好）

### 5.5 对称性破除

前排 / 后排内同 profile 的连续自由槽构成对称组，组内 item 下标
单调不减，消除同排列重复展开。

### 5.6 剪枝层次（自粗到细）

1. 节点级 bound（DP 松弛 + 团队标量乐观和）
2. item 级 pre-filter（item 自身 cost 参与 DP 下标）
3. 容量检查（`_capacityOk`）
4. 有序 break（dpValue 降序后前缀失效即断）

## 6. 结果层（新增）

### 6.1 tie 收集与边际贡献过滤（Bug 3 修复）

叶节点总分 == best 时，逐个检查 cost > 0 的佩戴 item 的**边际贡献**
（flat + self + targeted receipts 对最终队伍的合计）：

- 边际贡献 > 0 → 正常收集

- 边际贡献 == 0 → **跳过该 tie**——去掉该佩戴必存在总分相同且 cost
  更低的解（释放预算不降分），当前 tie 是冗余解

安全性论证：去掉零贡献 item 只释放预算与容量，不改变任何其他槽的
得分，因此同分可行解必然存在；最优值不会因此丢失。

**排列去重**：从者位置与各槽羁绊值完全一致、仅礼装在槽间互换且不改变
任何槽结果的解视为同一解，只收集一个（纯团队礼装无 self 效用，谁佩戴
不影响羁绊）。判定键 = 按槽（从者标识 + 该槽羁绊值）有序 + 全队礼装类
多重集**无序** + 助战礼装（有位性——助战礼装无持有要求，不可与自有
佩戴互换）。self 效用礼装的互换会改变各槽值 → 键不同 → 仍按不同解
展示。收集时按类级键去重（键含 phase 内类对象身份）；实例化后按具体
id 再做一次权威去重（同时滤掉 phase 2 重复发现 phase 1 解的情况）。

### 6.2 实例化（Bug 1 修复）

对每个收集的 tie 解追加后处理，把 class 级选择展开为**具体编队**：

1. 从者分配：同一从者类被多槽消费时，按槽序贪心分配 distinct 成员
   （类容量 ≥ 消费数，成员等价故任选）；limitCount 取该成员的任一
   合法值；固定槽已消费的容量先扣除
2. 礼装分配：同一礼装类的多次消费分配 distinct CE id（含 MLB 标记）
3. pinned CE / 助战 CE 不变
4. 输出具体 `PlayerSvtData` 级队伍，可直接「应用到编队」

搜索全程仍在 class 级进行；实例化只发生在搜索结束后。

### 6.3 provenOptimal 语义

任一 phase 触达节点上限 → `provenOptimal = false` + 警告
（保持 v1 语义与 UI 提示不变）。

## 7. 性能策略

- **上限度量：纯节点数**（可复现性优先；同输入同结果，测试友好）

- Phase 1 / Phase 2 上限均为 120 万节点

- 异步：仅顶部 3 层 DFS 参与 yield（`yieldInterval`），其余同步；
  UI 层维持 EasyLoading 输入屏障

- 预期：targeted 上界收紧 + item 排序修复后，多数场景 phase 2
  可在预算内证明最优

## 8. 与 v1 的交付差异清单

| 模块                   | 处置                     |
| :------------------- | :--------------------- |
| ce\_pool / svt\_pool | 复用，不改动                 |
| solver.dart 搜索核心     | 重写（两阶段 + §5.3/§5.4 修复） |
| 结果层                  | 新增实例化 + 边际贡献过滤         |
| bond\_solver.dart UI | 结果展示改为具体编队；其余不变        |

