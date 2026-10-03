# Formation bond 最大羁绊求解器：精确算法设计

状态：礼装优先的精确快路径、通用分支定界回退、可取消的原生平台进度流、独立 Formation Bond 页的 Input／Results 标签及验证用例已实现。本文是当前算法的设计依据。无论使用哪条路径，都必须依 `provenOptimal` 区分已证明的最大值和最佳已知队伍。

读者：实现、评审和测试此功能的开发者。本文同时定义求解语义、预处理、搜索、结果接口和可验证的正确性条件。

## 1. 目标和正确性合同

每次求解以当前选定的 `QuestPhase`、六个编队位置、活动与位置设置，以及求解器筛选和 COST 预算作为固定输入，返回最大可行队伍总羁绊。标签页可在两次求解之间重新选择关卡。求解始终按茶壶 ×1；UI 只在显示时乘茶壶倍数。

`provenOptimal=true` 的含义是：全部可行队伍均已搜索，或被有证明的上界排除；输出的队伍可实例化为互不重复的自有从者 ID 和礼装 ID，且用手动计算语义复算得到相同分数。到达节点预算只能返回 `provenOptimal=false` 的最佳已知**可行**队伍，绝不能称其为最大值。

规则提取以手动页为基础，并采用本求解任务明确的范围：自由礼装候选只取**全队生效、与佩戴者无关**的效果；活动限定的自身礼装效果不进入自由候选；从者活动被动只计入自身效果。固定礼装仍需按手动页计算其真实效果，避免把已固定成员悄悄改写。忽略全队从者活动被动的队伍与手动页可有预期差异；`provenOptimal` 只对本节定义的求解范围成立。若今后手动页扩展其他目标范围，求解器必须同步扩展或显式报不支持。

## 2. 规则语义

### 2.1 位置与固定维度

每个位置分别固定或搜索从者、equip1。`QuestPhase.isUseGrandBoard` 且该位置的**编队固定从者**标为 `grandSvt` 时，equip3 也分别固定或搜索；equip3 不计 COST。自由从者位置不启用 equip3；即使编队数据残留了 equip3，也按需求忽略。equip2 不参与羁绊礼装计算。

只固定 equip1 的位置仍搜索从者；固定礼装与所选从者的佩戴者条件必须一起求值。固定从者不受自由候选筛选；固定礼装也不受自由礼装排除条件影响。固定从者不满足关卡特性限制、或某位置没有合法 item 时，预处理报错；固定成员的重复 ID 等冲突由具体身份匹配判为无解。

`svtBonus[position].addRate/addValue` 作用于该位置实际存在的从者。`isBond15` 与 `isBondReachLimit` **仅对编队固定的自有从者有效**：前者提供全队 +250 RateCount，后者令该位置得分为零，但不删除它提供的全队效果。自由位置忽略这两个标志。助战位置忽略两者。

所有标为助战的位置均用无特性的虚拟从者替代。助战不产出羁绊、不消耗 COST、不占自有从者或礼装容量；只搜索未固定的助战礼装。固定的助战 equip3 仅在该位置的 Grand Board 条件成立时生效；自由助战 equip3 不搜索。助战礼装的佩戴者条件对空特性求值，目标条件仍对实际队伍目标求值。前排每个助战提供全队 +40 RateCount；前排自有从者仅自身 +200，均受 `frontlineBonus` 开关控制。多个助战按手动公式逐个计入，不依赖“最多一个助战”的旧假设。

### 2.2 COST、筛选和唯一性

预算默认为 `ConstData.userLevel[ConstData.maxUserLevel]!.maxCost`；`maxUserLevel` getter 已存在。自有位置 COST 为该灵基的 `overwriteCost ?? cost` 加 equip1 礼装 COST；固定与自由位置都计入，助战及 equip3 不计入。

自由从者候选可按当前 region 是否实装、favorite、`bond >= X` 和自定义 ID 排除；自由礼装可按 region 和自定义 ID 排除。固定成员不被过滤。region 发布表缺失时不能把“未知”当成“已实装”：返回明确的数据不可验证状态，或在 UI 中要求关闭此筛选。

关卡中所有 `RestrictionType.individuality` 条目按 `Restriction.checkSvtIndiv` 的 `equal`/`notEqual` 语义逐一判断。从者特性取当前 Quest EventId 与所选灵基下的有效 individuality；自由候选在按特性/COST 去重**之前**筛选，避免合法灵基被错误合并。固定自有从者不受用户设置的排除筛选。`searchFixedAscensions` 默认关闭，此时输入灵基不满足关卡限制则报错；开启时固定 ID 并枚举普通灵基及灵衣，按各灵基判断特性、COST 与限制，只要存在合法灵基即可求解。固定礼装、Bond 15／上限与 Grand 标志保留；虚拟助战没有可验证的实际从者，不进行此项检查。其他 restriction 类型目前不在本求解器支持的编队约束范围内。

关卡输入与恢复优先读取 `db.gameData.getQuestPhase(id, phase)`；本地数据中只有 Grand Board war 关卡需要组队特性限制，本地 phase 的 `restrictions` 按原样使用，普通关卡缺少该字段不意味着需要补请求。输入关卡 ID 并选定 phase 时，只有本地没有该 phase 才通过 Atlas API 加载；连 Quest 元数据也不在本地时，先加载 Quest 再选择 phase。输入加载失败保留原选择并提示错误。恢复时也先本地后 API，恢复完成前不能 Solve。Solve 再检查当前 QuestPhase 已存在，优先复用同 ID／phase 的本地对象，否则使用输入阶段已加载的对象，不因本地缺少 `restrictions` 强制刷新 API。

Formation Bond 是独立于 Bond Bonus 查阅页的模块，提供 `Input` 和 `Results` 两个标签。`User.formationBondOption` 是编队、活动、前排、茶壶、COST 和从者／礼装筛选的唯一持久化配置。默认页面直接引用当前用户的该对象，不在加载时复制；若队伍六个位置均为空，第三位置预设为空助战（`SupportSvtType.friend`）。外部调用方若需临时配置，先深拷贝用户配置、覆盖关卡和编队等字段，再以 `FormationBondPage(option: ...)` 传入；页面直接使用该对象，不写回 User。空助战位须能完整序列化。

页面编辑会立即改变所持有的配置对象；`saveData()` 在离开页面时把运行时编队和关卡写回该对象。对默认页面，点击 Solve 且 QuestPhase 已准备成功后才显式调用 `db.saveUserData()`。由于默认页面持有 User 中的同一对象，其他途径保存 UserData 时，也可能提前持久化已编辑字段；当前实现不提供“点击 Solve 前绝不落盘”的隔离保证。求解时复制一次当前配置，并覆盖为运行时编队和已加载关卡，形成不受随后 UI 编辑影响的搜索输入；算法直接读取其中的 COST 和筛选字段。结果只在当前页面展示，不持久化。切换用户后需重新建立该标签的状态，不能把前一个用户的配置写入新用户。

同一自有从者 ID 在全队最多出现一次，即使它的不同灵基属于不同效果类。同一自有礼装身份最多出现一次，即使普通与满破版本被保留为不同候选；一般身份为具体 ID，`bond_rules.dart` 的 `BondCeIdentity` 可配置多 ID 身份族。英灵逢魔（CollectionNo 1973–1979、ID 9308100–9308160）视为同一身份，自由候选只用 9308100，排除任一成员即排除全族自由候选。1972 是另一张礼装，不属于此族。固定自有礼装保留具体 ID，且与自由 equip1／Grand equip3 共占一个族名额；助战可以与自有位置重复礼装身份。固定自有位置如已违反唯一性，输入不可行。现阶段没有礼装持有份数数据，故按不同礼装 ID 计容量。

### 实装参考与灵衣特性

`FormationBondOption.releaseReference` 使用 `BondReleaseReference` 五项枚举：JP、CN、TW、NA、关卡关闭日期，默认 JP，不跟随当前 User 或显示语言。JP 使用默认数据库，等同不限制实装；CN/TW/NA 使用所选服 `entityRelease` 同时筛选自由从者与礼装。固定输入不受候选实装过滤；不为与羁绊无关的 `ce.region` 添加专属规则。求解 API 不再另传 Region。

日期模式对自由从者使用 `ServantExtra.getReleasedAt()` 的 JP 日期：大于关卡关闭时间才排除，未知日期保留。该日期表不完整且存在按 CollectionNo 回退，因此不能声称精确还原历史实装。礼装无实装日期，灵衣特性无添加时间，两者暂用默认 JP 数据；UI 以英文小字说明 `CE availability and costume traits currently use JP data.`。选项直接显示 JP 时区下的关闭日期。关卡未选择、关闭时间为 0 或达到永久开放阈值时禁用日期模式，原已选日期模式自动回退 JP；直接调用算法同样回退。

`BondReleaseRules.traits` 复制基础灵基特性后添加原有活动/灵基特性，再按所选 Region 的 `svtTraitRelease` 移除未实装的 `hasCostume`。JP 与日期模式保留默认特性。手动计算、求解器、可替换灵基判定、礼装贡献详情共用此逻辑，不修改共享数据库，不额外过滤未实装灵衣灵基本身。修改参考会取消搜索并清空旧结果，与其他共享输入一致。

### 2.3 羁绊公式与效果提取

对每个产出羁绊的自有位置，严格按 `SvtBondBonusResult.totalBond`：

```text
first  = floor(baseBond * (1 + frontlineRate / 1000))
second = floor(first * (1 + min(totalRate, maxFriendShipUpRatio) / 1000))
bond   = second + totalValue
```

叶节点使用与 `calcFormationBondResults` 相同的 Dart `double`/`floor` 顺序。上界可以采用更保守的整数向上取整，但不能用近似值作为最终得分。

每个 `servantFriendshipUp` 函数提取 `scope`（仅 `self` 或 `ptFull`；其余 scope 无效）、`rate`、`value`、佩戴者条件、目标条件、Quest 条件、EventId、助战 `followerVals` 与 `ApplySupportSvt` 规则。`actIndividuality` 和 `vals.Individuality` 分别对佩戴者判断；`overWriteTvalsList` 优先于 `functvals`，对目标判断。自我效果的目标就是佩戴者。固定礼装仍保留定向的 **RateCount 和 AddCount** 及佩戴者条件；自由礼装只保留全队生效且与佩戴者无关的候选，但可以针对**接收者**特性。

活动技能仅在 `enableEvent` 时计算；按手动页的 Quest 时间/EventId 条件、`extraPassive.num` 分组最高 `priority` 解析，并跳过技能 970663。解析后只计入 `self` 效果；所有从者活动被动的 `ptFull` 效果都不进入求解器。已启用的 campaign 按 `targetIds` 和 `calcType` 给目标从者加成；campaign 开关独立于 `enableEvent`。礼装函数的 EventId/Quest 条件始终按当前 Quest 判断。

### 2.4 可比较性边界

手动页接受真实助战从者；本求解器按需求用无特性虚拟助战，因此含真实助战的全固定队伍只在把手动页助战替换为同一虚拟语义后比较。除此之外，全固定队伍须逐位置、逐项效果与手动页一致。

### 2.5 从者全队活动被动

用户限定只考虑从者自己的活动羁绊加成。数据中非玛修从者的 `ptFull` 羁绊被动均为技能 970663（手动页原本就跳过）；其余全队活动被动来自玛修（`collectionNo == 1`）。因此按 `scope == self` 过滤所有从者活动被动，既实现该限定，也无需维护玛修的技能 ID 名单。此处是与手动页有意的语义差异，差分测试要单列说明。

## 3. 数据模块与预处理

模块接口：`FormationBondSolver.solve(...)` 与 `solveAsync(...)` 使用相同的命名参数，包含 Quest、编队、同时承载手动与求解筛选设置的 `FormationBondOption`、region 和搜索预算。预算在礼装优先路径计已评估礼装组合，在通用路径计搜索节点；两者都不改变 `provenOptimal` 的语义。`solveProgressively(...)` 没有节点预算参数：原生平台在工作 isolate 中先发可行改进、后发证明结果，取消订阅即终止 isolate；Web 先运行有界搜索，再从头运行无界搜索。`BondSolverResult` 包含最佳已知具体队伍、`provenOptimal`、最高分同分代表 `ties`、跨分数档的有限候选 `candidates`、耗时与搜索步数；`possibleCombinations` 仅在礼装优先路径中有值。`best=null && provenOptimal=true` 表示无可行队伍；`best=null && provenOptimal=false` 表示尚未找到可行队伍。

当前实现按每次请求重建候选及效果矩阵，没有跨请求的数据集缓存。可以按两层理解预处理；第一层缓存仍是后续性能优化，而非已有机制：

1. **数据集层（规划）**：按游戏数据版本缓存各从者合法灵基的特性与 COST、礼装普通/满破效果原子、发布表。数据更新时失效。
2. **请求层**：套用 Quest、实装参考、筛选、活动、固定维度；解析有效效果与固定来源；建立从者候选、礼装候选、有效目标轮廓和贡献矩阵。只搜索羁绊相关礼装与“不佩戴”。

从者候选首先是 `(svtId, limitCount)`。两个候选只有在 COST、活动自身加成、campaign 加成、作为所有相关效果来源的行为、作为所有相关效果目标的行为、佩戴每个可用礼装后的自身效果都相同时，才进入同一 `SvtClass`。比较的是完整规范化向量，不仅是哈希或原始 indiv，也不能把不同 campaign 目标合并。每类保存成员具体 `(svtId, limitCount)`；同一 ID 可出现在多个类中，故类容量只是局部快速检查，最终还需 ID 匹配。

礼装候选首先是 `(ceId, limitBreak)`。自由自有候选要求当前 Quest 生效的羁绊效果全部是 `ptFull`，且 `actIndividuality`、`vals.Individuality` 均无佩戴者条件；针对接收者的特性条件可以保留。自有礼装按对全部目标轮廓的 `(RateCount, AddCount)` 贡献、COST 及助战效果向量归入 `CeClass`，equip1 与可用的 equip3 共用自有类，但只有 equip1 计 COST；助战礼装按 `followerVals` 贡献另建类。普通与满破版本如效果不同，都保留；若同一 ID 的两版效果相同，可保留其中一版作为显示代表，但类容量仍只计该 ID 一次。无条件 +5%、+2.5%、+50 等**各自**只需一个效果类代表，类内记录所有可用具体 ID；这三种效果不能相互混为一类。固定礼装仍按真实效果计算，不受自由候选筛选。

2026-09-19 数据审计发现四个带自身效果的礼装 ID：9404310、9405110、9407110 都有活动 EventId，自由候选排除；9401060「英灵肖像：大流士三世」的数据标为常驻 `self +50`。用户确认这是数据错误，应视作 `ptFull +50`。此修正在手动计算与求解器使用同一规则，且仅在原始 scope 为 `self` 时生效；若以后数据改正成 `ptFull`，不会重复加成。另两个活动礼装的全队效果还带玛修佩戴者条件，也因此不进入自由自有候选。新数据版本若出现其他自身或佩戴者条件的礼装，默认从自由候选排除，并保留固定礼装的真实计算。

`temp/fgo-calc` 的关键观察是：若礼装来源不依赖佩戴者，而且所选从者不会改变全队来源，先决定礼装组合，就能把每个从者的收益算成独立物品，再解从者 COST 背包。其无条件、同 COST 礼装优先级链可作为后续候选剪枝的思路，但须重新证明具体 ID、固定槽位与普通/满破共享 ID 时的可替换性；不能仅凭单个礼装效果更强就**删除整个弱类**：队伍可能同时需要两类。本实现只在以下充分条件同时成立时删除弱类 `B`：保留类 `A` 的 COST 不高于 `B`；对每个佩戴者和目标轮廓，`A` 的 team rate/value 分别不低于 `B`，且对佩戴者还覆盖 `B` 的 self rate/value；所有此类 `A` 合起来的**不同 ID 数**至少等于全队可能占用的自有礼装槽数。使用 `B` 的队伍最多有 `slots-1` 个其他礼装 ID，故必有一个尚未使用的 `A` ID 能替换 `B`。每删除一类就重新检查剩余类，避免循环支配证明。固定礼装计入槽数但不受筛选和删除影响。

对每种源物品与目标轮廓，预先算好 `(rate, value)` 贡献。固定来源也放入同一矩阵。搜索热路径只读整数数组/位集，不再遍历 `NiceSkill`、礼装技能或个体特性。

## 4. 搜索算法

### 4.1 礼装优先的精确快路径（已实现）

先检查本次请求是否**可分离**。可分离的充分条件是：所有自由自有礼装的全队效果与佩戴者无关，且其自身效果均为零；固定礼装穿在可变从者或可变灵基身上时，其全队效果与该选择无关；可变从者与灵基没有随选择而改变的全队效果。固定礼装的自身效果、活动对从者自身的加成、前后排倍率、目标特性和 campaign 都可留在从者收益函数中。助战礼装单独枚举，助战虚拟从者不进入背包。条件不成立时走 4.2—4.5 的通用精确搜索；绝不能让这条快路径静默忽略条件效果。

可分离时，以 `equip1` 与 Grand Board `equip3` 两种槽分别枚举**礼装效果类的重数**，不枚举类内 ID 的排列或等效自由礼装在槽位间的排列。自有从者仍按位置求解，因为前后排、固定维度和每位置加成可能不同。只给 `equip1` 的礼装计 COST；先从可用 ID 扣除固定自有礼装，然后对每个重数组合做一次具体身份匹配。匹配失败即丢弃该组合。助战礼装的组合在外层单独枚举，先删去被另一助战选项逐目标 rate/value 支配的选项；助战 ID 不与自有礼装互斥。无礼装也是合法选择。固定来源、所选礼装与助战效果相加后，对每个自由位置和 `(svtId, limit, cost)` 用手动页的两次 `floor`、rate cap 与 AddCount **精确**计算得分。固定从者的得分同样在这一阶段计算。

固定灵基搜索开启后，固定自有 ID 的非等效灵基进入从者 DP，其位置必填、ID 不能替换；对应可变 COST 不再预扣为固定单值。若所有合法灵基对本次问题完全等效，保留一个代表并作为固定项，不增加 DP 位置维度。默认关闭时固定从者继续单独计分与计 COST。

令 `F` 为需要选择从者或灵基的自有位置数，`C` 为剩余 COST。对每个 `(位置, 从者 COST)`，先按分数只保留前 `F` 个**不同从者 ID**，同一 ID 的同 COST 多灵基只保留该位置分数最高的灵基。理由：若某个被删候选在最优队伍中占该位置，则至少有 `F` 个同 COST、该位置得分不低的 ID；其他自由位置至多占 `F-1` 个，必有一个可替换。自由从者池先排除所有固定自有 ID；固定灵基池只包含该位置的固定 ID。这个缩减仅在自由从者不产生动态全队效果时成立；否则替换可能改变其他人的分数。

之后按从者 ID 做 0/1 动态规划：状态 `dp[occupiedPositionMask][cost]` 存最高得分和见证。处理每个 ID 时，只能跳过，或选择该 ID 的一个灵基放到一个尚空位置；用下一层 DP 写入，确保同一 ID 绝不入队两次。当前实现始终保留各自由位置的 mask 位；前排三个槽的从者排列不会在此路径额外商掉。**自由从者位置允许留空**：最终接受所有包含“固定礼装但自由从者”必填位，且已占用自由 equip1 槽数足以安放所选 equip1 礼装的 mask；空位得分为零，也不产生该位置的自定义加成。匹配 CE ID 后再把礼装分配给这些已占用的自由 equip1 槽。每个 CE 组合的最优值是固定位置得分加所有合格 `dp[mask][cost<=C]` 的最大值。不同组合的分数用全局 best 比较，同分结果按效果轮廓归类。若枚举与 DP 穷尽，才返回 `provenOptimal=true`。

```text
combos = []
for supportChoice in nondominatedSupportChoices:
  for ownCeCounts in canonicalMultisetsBy(equip1, equip3):
    if ceCost > remainingCost: continue
    ceIds = matchDistinctIds(ownCeCounts, fixedOwnedCeIds)
    if ceIds == none: continue
    sourceVector = fixedSources + supportChoice + sum(ownCeCounts * ceVectors)
    upper = fixedSlotScores(sourceVector)
          + sum(max(0, max score(sourceVector, svt) for svt in freePool) for freePosition)
    combos.add((upper, sourceVector, ceIds))
sort combos by upper descending
for combo in combos:
  if best != none and combo.upper <= best.score: break // 最大分已证明
  scores = exactSlotScores(combo.sourceVector, allServantVariants)
  candidates = topFDistinctIdsPerPositionAndCost(scores)
  dp = {emptyMask, cost0: 0}
  for servantId in candidates.groupById:
    next = dp                                 // skip this ID
    for state in dp:
      for (searchPosition, limit) in servantId.legalChoices:
        update(next[mask | positionBit][cost + svtCost], score)
    dp = next
  updateGlobalBest(dp[eligibleMasks] + fixedScore, combo.ceIds)
```

组合上界忽略 COST、跨位置从者 ID 唯一性、礼装实际安放条件，却逐槽取可行从者的最高精确分数，因此绝不低估该组合真实最优值。按上界降序评估后，下一未评估组合的上界若不超过当前可行分数，就已证明最大分；同分收集可继续，但不影响 `provenOptimal`。这里的 `cost` 状态还可按“相同 mask、COST 不高且分数不低”删除劣解，目前没有启用。不能把 `temp/fgo-calc` 对 15 绊的队外加法直接搬来：本需求的 15 绊只允许固定从者，且手动公式在倍率内部逐人取整。

设 `M` 为通过容量、ID 和 COST 检查的礼装组合数，`E` 为上界排序后真正评估的组合数，`N` 为从者变体数，`F` 为需选择从者或固定灵基的位置数，`C` 为剩余 COST。构造上界约为 `O(M × N × F)`，最坏情形的背包部分为 `O(E × N' × 2^F × C × F × V)`，`N'` 是各位置同 COST 只留前 `F` 个不同 ID 后的数量。以 17 个自由自有礼装效果类、五个 equip1 槽为例，连同“不穿”，最多有 `C(22,5)=26,334` 个无序重数组合。当前实现若不计容量的组合数上界超过 250,000，便转通用搜索，避免在手机上预存过多组合；这个阈值只选择算法，不更改最优性合同。预算中断时只返回已匹配 ID、已复算分数的可行队伍，且 `provenOptimal=false`。

### 4.2 状态与搜索顺序

每个搜索位置由独立固定维度生成合法 item：自由从者 × 固定/自由 equip1；固定从者的允许灵基 × 固定/自由 equip1 × 固定/自由 equip3；助战仅固定/自由 equip1（以及允许的固定 equip3）。item 记录 COST、候选 ID 集、接收轮廓、位置自身效果和对各目标轮廓的全队贡献。搜索顺序可按分支数与全队影响排序，与编队显示顺序无关。

DFS 状态为已选 item、已耗 COST、每类使用次数和当前来源贡献。搜索先按低 COST、少佩戴礼装建立一个具体 ID 可匹配的可行队伍，再对每个位置轮流尝试替换所有 item，进行两轮局部改进。此阶段只提供真实可行的下界，不占证明搜索的节点预算，也不能代替完整空间的证明。随后候选按乐观得分降序搜索，叶节点再做具体身份匹配。

### 4.3 安全上界

对每个剩余来源位置 `p` 与每种接收轮廓 `r`，预计算该位置所有候选可提供的最大非负 rate/value：`M[p][r]`。此最大值忽略 COST、容量与和其他位置的兼容性，因此不会低估任何真实续解。

已确定的接收位置：用已选来源的真实贡献，加上每个未选来源的 `M[p][r]`，得到该位置的乐观分数。实现还按礼装等效类容量给未知来源构造另一上界，两者取较小值。每个 item 只按其第一件受容量限制的礼装分组；这会放松其他容量限制，因而不会低估。未确定的接收位置：对每个候选 item 预计算它在其他来源均取乐观最大贡献时的 `U[position][item]`，再用按位置和剩余 COST 建立的 multiple-choice knapsack DP 求和；DP 故意忽略共享 ID 与容量。

位置与前排开关在搜索前已确定，因此第一乘区 `first = floor(baseBond * (1 + frontlineRate/1000))` 可按手动页精确预计算。乐观第二乘区使用 `ceilDiv(first * (1000 + min(rateUpper, cap)), 1000)`，再加 `valueUpper`；`first >= 0` 使它随 `rateUpper` 单调不减。未知来源的 rate/value 分别取逐项最大值，即使它们来自不同候选也仍是安全上界。DP 的成本索引只使用非负 COST。完整节点上界是“已确定位置乐观分数 + 剩余位置 DP 分数”。两项分别逐位置不低于真实得分，故其和不低于子树最优值。只有 `upperBound < bestFeasibleScore` 才能为了求同分而剪枝；只求最大值时允许 `<=`。

前排与后排分别建立对称类：位置的前排倍率、固定维度、每位置自定义加成、助战性质和 Grand Board 能力均相同时，强制选项类序号非降。不同 profile 不互换；这保留位置特有加成。结果展示时再映射回原槽位。

### 4.4 伪代码

```text
prepared = prepare(request)                     // 完整效果矩阵与等效类
best = feasibleSeed(prepared)                    // 低成本构造 + 两轮局部改进；必须匹配具体 ID
dp = optimisticCostDp(prepared)                  // 忽略共享容量的安全上界

search(k, state):
    if k == numberOfSearchPositions:
        witness = matchDistinctServantAndOwnedCeIds(state, pinnedIds)
        if witness == none: return               // 无效类解不得更新 best
        score = scoreExactlyLikeManual(witness)  // 两次 floor，茶壶 ×1
        updateBest(score, witness)
        if collectingTies: updateEffectGroup(score, witness)
        return

    if best != none and upperBound(k, state, dp) <= best.score:
        return                                  // 最大值证明轮；同分轮改为 <
    for item in orderedItems[k]:
        if item.cost > state.budget: continue
        if classMultiplicityExceedsCapacity(item, state): continue
        if violatesSymmetry(item, state): continue
        next = state + item
        search(k + 1, next)
```

`matchDistinct...` 是最多六个自有从者与有限礼装维度的二分图匹配；固定自有 ID 先占用，助战不占用。必须在更新 best **之前**运行。若一项同时佩戴两件同类礼装，容量检查按重数 2，而不是分别检查两次 `remaining > 0`。

### 4.5 正确性说明

**完整性**：每个真实可行队伍的从者灵基、礼装版本及固定维度都至少映射到一条搜索路径；等效类只合并在所有可能目标与来源上的效果完全相同的成员。对称规范化只删去相同位置 profile 的排列。因此每个可行分数至少保留一条路径。

**可行性**：预算、固定维度和容量先检查；叶节点二分匹配给出互异具体 ID 的见证；精确评分只对见证队伍运行。故 best 永远是实际可行队伍的分数。

**上界**：每个未知来源的 `M` 独立最大化，只会增加每个接收位置的可得效果；成本 DP 再放宽共享容量与 ID 约束，只会增加可能值。第一乘区与手动页相同，第二乘区向上取整不低于其 `floor`。因此被剪去的子树不可能达到更高分。若未因资源上限中断，best 等于全局最优。

## 5. 同分、跨分数候选与中断

分数证明与同分枚举分开记录：`provenOptimal` 只表示最大分数已证明；`allTiesCollected` 仅表示搜索路径中的同分**效果组**是否收集完整，不表示类内具体 ID 排列已穷尽。通用搜索在最大分证明后另跑有独立节点预算的同分轮；礼装优先路径先报告分数证明，再评估最多 `maxTies × 4` 个上界仍可同分的礼装组合，并始终标记 `allTiesCollected=false`。同一组保留 COST 较高的代表。展示前统一规范化自由礼装：在效果、COST 与助战行为一致的通用类内，用最小可用 ID 起依次选取所需数量，跳过排除、未实装与固定占用；助战独立选代表。普通通用礼装仍保留多个独立名额，不能像身份族一样压缩成容量一。

自有自由 equip1 只在保持全队效果与总 COST 的位置间排列，顺序为特性要求优先、比例降序、固定值礼装靠后、ID 降序；固定礼装、助战与 equip3 保留位置。所有已选自由自有礼装均为与佩戴者无关的全队效果，因此前后排间安全重排也不改变任一从者得分。重排同步更新每位置 COST 与候选元数据，规范化先于最终候选去重。候选扩展不再产生只改变通用礼装 ID 的队伍。

通用路径按每个位置的接收轮廓与实际羁绊值归类；礼装优先路径还把全队来源效果向量纳入键。通用路径的分数证明轮会顺带记录有限的可行候选，证明后才收集同分效果组；礼装优先路径在证明轮可顺带收集已评估组合的效果组。`ties` 保留最高分的有限效果组代表，默认上限 20（同步 API 可通过 `maxTies` 调整）。它不代表所有同分具体队伍。

页面另用 `FormationBondOption.maxCandidateTeams` 控制 `candidates` 上限，默认 100，可设置 1–200。搜索遇到的每个候选都先匹配具体 ID，再按真实公式计分；列表按分数降序、同分时按 COST 降序保留。最高分证明与候选收集分离：礼装优先路径在证明后额外评估最多 `maxCandidateTeams × 4` 个组合，并可把可分离问题中替换一个自由从者的可行邻近队伍加入候选；通用路径在证明后最多再访问 100,000 个节点收集候选。即使额外收集被预算截断，`provenOptimal` 仍只表示最高分已证明。对种子队伍还可轮流替换单个从者或定向礼装为同效果类的具体 ID；每个替换都重新检查自有从者 ID 与礼装身份唯一性，保持该队伍的分数和 COST 不变。候选列表只表示**已发现队伍中的前 N 个**，不证明第 2、3 档的全球名次，也不保证凑满 N 个。

达到搜索预算时立即返回最佳已知可行队伍与 `provenOptimal=false`；若尚无可行见证，返回 `best=null` 且 `provenOptimal=false`。若搜索穷尽而无见证，则 `best=null` 且 `provenOptimal=true`。交互页不把预算用作最终停止条件：先显示最佳已知队伍，再继续求证，用户取消时保留未证明的候选。

## 6. 集成与验证

`FormationBondPage` 单独持有手动编队和求解状态；同文件的 `_FormationBondRuntime` 集中管理页面恢复、求解结果、订阅、计时器和搜索版本，持久化配置只在 `FormationBondOption`。`Input` 标签按关卡、编队、手动结果、共用羁绊设置、COST 与过滤器的顺序展示，Solve 按钮固定在滚动输入区下方。点击 Solve 后切换到 `Results` 标签，等待 Tab 动画时长及下一帧绘制完成后才创建搜索输入、保存配置与开始预处理；等待期间取消或修改输入会使该次请求失效。结果通过 `ListView.builder` 按需建立所有已保留候选的卡片，搜索过程中随候选更新，不使用分页。`maxCandidateTeams` 是内存候选上限，默认 100、范围 1–200。固定从者灵基搜索开关在求解器从者设置中，存于 `FormationBondOption.searchFixedAscensions`。复杂排除卡片与候选展示在 `solver/results.dart`，搜索算法仍在 `solver/` 的其他文件中；不再保留独立求解页或结果 Apply 操作。关卡、编队、活动、前排、筛选和候选数量变动立即取消搜索并清除旧结果；已有搜索或结果时提示失效。茶壶只改变显示倍率，保留搜索和结果。

求解器与手动计算共用当前 QuestPhase 和编队。实装参考位于关卡卡片内，用于共享灵衣特性规则与自由候选实装筛选；不再提供 Solver 专用的“排除未实装”开关。排除列表直接展示从者／礼装卡面，行末加号打开相应的可搜索卡片列表，长按已加入的卡面移除；添加排除礼装时，列表初始分类为 `CEObtain.davinciBondBonus`，仍可在列表筛选器中调整。自定义 COST 可高于默认上限，UI 同时显示自定义值与最高御主等级的标准值。活动技能和 campaign 开关放在同一个 `SimpleAccordion` 中。预处理在 UI isolate，已准备的纯搜索问题在原生平台工作 isolate 搜索；通用搜索定期回传已访问节点数和当前可行队伍，礼装优先搜索定期回传已评估组合数。`Results` 标签始终显示搜索状态和诊断信息；搜索期间展示已找到的队伍，取消后保留候选并标明最高分尚未证明。Debug 构建也输出带 `[BondSolver]` 前缀的阶段与计数。取消订阅会终止 isolate。Web 没有工作 isolate，目前用阶段性计算维持相同结果状态，但一次同步搜索期间 UI 不能即时响应取消。每张 `FormationCard` 下方按位置显示 `单人总羁绊－关卡基础羁绊` 与单人总羁绊两行；茶壶仅影响显示。`tieGroupCounts` 只记录搜索访问到的类路径，不是具体 ID 的所有等效队伍数；页面以 `candidates` 的实际数量为准，并提示较低分数档没有全球名次证明。手动计算已支持无特性虚拟助战。

结果中的固定从者预览使用实际求得的灵基。每个自有从者的灵基要求按完整队伍复算：其他成员与礼装保持不变，替换单个灵基，要求满足关卡限制、各位置羁绊不变且总 COST 不变。若不是所有有效灵基都可替换，数字下显示红线，点击弹窗用已有 `ascension` 标题列出可用灵基。复算使用求解器自身活动效果范围，不引入玛修全队活动被动；不保证多名从者各自可用的灵基能同时替换。只对已展示候选计算并按结果对象／位置缓存；搜索热路径不执行此复算。

当前测试位于 `test/app/modules/bond/`：随机小规模 `BondSearch` 与具体 ID 穷举对照；跨类同 ID、双礼装 ID 冲突、预算中断、进度和同分分组；固定编队与手动页差分、助战占位、固定 Grand equip3、特性限制、固定自身活动礼装；少量真实数据池的礼装优先／通用搜索对照，以及支配删除开关对照。页面测试覆盖配置归属、空助战序列化和候选展示。这些测试不能替代对所有活动、条件效果与数据版本的穷尽验证。

新增 `identity_ascension_test.dart` 验证礼装身份族、排除、固定／助战／Grand 容量、通用代表和混合排序、数据顺序稳定性、固定灵基的 COST 与特性变化、关卡限制及与具体灵基穷举的对照；`search_test.dart` 另覆盖身份族匹配的增广重分配。复杂页面 UI 验证由人工进行，编写这类 UI 测试前须先获用户确认。

后续验证门槛：

1. 将每一种 scope、佩戴者/目标条件、RateCount/AddCount、cap、两次取整、助战 followerVals、活动优先级与 campaign 扩展为独立规则测试。
2. 扩大小候选池的具体 ID 穷举 oracle，覆盖跨灵基同 ID、同类多件礼装、仅固定礼装、固定与自由 Grand Board、无效定向礼装、前排对称和 COST 边界；礼装优先快路径还需覆盖可分离判断的正反例。
3. 加入变形性质：提高预算或放宽候选过滤不应降低已证明最优值；每个输出见证须 COST 合法、具体 ID 互异，且能用权威公式复算。
4. 性能基准分别记录数据预处理、礼装组合生成和上界排序、从者 DP、具体身份匹配与结果归类的耗时；通用回退另记 DFS 节点数。在典型与极端 Quest 上测量后再设交互时间目标。不得以提高搜索预算代替正确性验证。

## 7. 对旧文档与代码的处置

第一、二版引擎及调试页已删除；其设计历史可从 Git 历史和 OpenSpec 旧变更记录追溯。当前效果解析与搜索实现均位于 `solver/`。

## 8. 性能边界与后续优化

Grand equip3 或多助战会使礼装组合数相乘。当前按自由 equip1、equip3 的无序组合数与助战选项数估算；若上界超过 250,000，则回退通用精确搜索。这个阈值只选择算法，不限制通用搜索的运行时间，也不改变 `provenOptimal` 的含义。结果中的 `visitedNodes` 在礼装优先路径表示已评估组合数，在通用路径表示已访问节点数，不能直接横向比较。

预处理仍在 UI isolate；原生平台把准备好的纯搜索问题交给工作 isolate，由工作 isolate 生成、排序和评估礼装组合。组合生成与排序结束后才有礼装优先路径的第一条进度快照，因此这一阶段可能没有步数更新。Web 的分阶段求解在同一线程运行同步搜索；即使有取消按钮，单次同步阶段内也无法即时取消。旧版在 2026-09-16 数据上的秒数与节点数只适用于当时的代码和编队，不能作为当前性能保证。后续应先分解预处理、组合生成、上界排序、从者 DP 与实例化耗时，再决定是否增加跨请求数据缓存、更紧的组合树上界，或 Web 可中断的分片搜索。

`temp/fgo-calc/README.md` 与 `backend/internal/service/calculator.go` 是算法参考：它枚举礼装组合，并对从者作 COST 背包，还以同 COST 无条件礼装构造优先级链。其问题定义明确不考虑本求解器的前排倍率，而且其从者前 `k` 筛法、15 绊修正、支持效果与具体 ID 处理均须在本需求条件下重新证明，不能整段移植。
