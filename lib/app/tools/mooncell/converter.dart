import 'package:flutter/services.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';

class MooncellConverter {
  const MooncellConverter._();

  static String eventShop(Event event) {
    final allShops = event.shop.toList();
    Map<int, List<NiceShop>> payItems = {};
    for (final shop in allShops) {
      if ((shop.cost?.itemId ?? 0) <= 0) continue;
      payItems.putIfAbsent(shop.cost!.itemId, () => []).add(shop);
    }
    final buffer = StringBuffer();
    buffer.writeln("""==活动道具兑换==\n<tabber>""");
    List<int> payItemIds = payItems.keys.toList();
    payItemIds.sort2((e) => -(db.gameData.items[e]?.priority ?? 9999));

    void writeShop(NiceShop shop, bool selected, String name, String color) {
      if (shop.setNum > 1) {
        name += '×${shop.setNum}';
      }
      buffer.writeln(
        [selected ? 1 : 0, name, shop.limitNum > 0 ? shop.limitNum : "----", shop.cost!.amount, color].join(";;"),
      );
    }

    for (int index = 0; index < payItemIds.length; index++) {
      final payItemId = payItemIds[index];
      final payItemName = db.gameData.items[payItemId]!.name;
      buffer.writeln("""$payItemName=
{{#invoke:EventShopList|list
|token_alias=$payItemName
|data=""");
      final shops = payItems[payItemId]!;
      shops.sort2((e) => e.priority);

      for (final shop in shops) {
        final target = shop.targetIds.firstOrNull ?? 0;
        if (shop.purchaseType == PurchaseType.servant) {
          final svt = db.gameData.entities[target]!;
          if (svt.type == SvtType.servantEquip) {
            // CE
            final name = Transl.ceNames(svt.name).l;
            writeShop(shop, true, "{{礼装小图标|$name}} 【概念礼装】★5「[[$name]]」", "#E9D9F9");
          } else if (svt.type == SvtType.statusUp) {
            // Fou, better to use atkBase/hpBase which is in NiceServant
            String name = Transl.svtNames(svt.name).l;
            assert(name.startsWith('英灵结晶·'));
            name = name.substring(5);
            final isAtk = target.toString().startsWith("9670"), isHp = target.toString().startsWith("9570");
            assert(isAtk || isHp);
            name = "{{道具|$name}} 英灵结晶・${name}ALL阶★${svt.rarity}(${isAtk ? "ATK" : "HP"})";
            writeShop(shop, svt.rarity >= 4, name, svt.rarity > 4 ? "#FF8A8A" : "");
          } else if (svt.type == SvtType.combineMaterial) {
            // Ember
            final name = Transl.svtNames(svt.name).l;
            writeShop(shop, false, "{{道具|$name}} ${name}ALL阶★${svt.rarity}", "");
          } else if (svt.type == SvtType.svtMaterialTd) {
            final baseSvt = db.gameData.servantsById[svt.id ~/ 10 * 10]!;
            final name = baseSvt.lName.l;
            writeShop(shop, true, "{{从者小图标|$name}} $name（宝具强化专用）", "");
          } else {
            buffer.writeln("UNKNOWN: $target: ${shop.id}: ${shop.name}");
          }
        } else if (shop.purchaseType == PurchaseType.commandCode) {
          final cc = db.gameData.commandCodesById[target]!;
          final name = cc.lName.l;
          writeShop(shop, true, "{{纹章小图标|$name}} 【指令纹章】★5「[[$name]]」", "#E9D9F9");
        } else if (shop.purchaseType == PurchaseType.item) {
          // coin
          final item = db.gameData.items[target]!;
          String name;
          String color;
          bool selected;
          final category = item.category;

          if (category == ItemCategory.eventAscension) {
            name = "{{道具|${item.name}}} 【灵基再临素材】「${item.name}」";
            color = "#E9D9F9";
            selected = true;
          } else if (item.type == ItemType.svtCoin) {
            final svt = db.gameData.servantsById.values.firstWhere((e) => e.coin!.item.id == item.id);
            name = "[[文件:从者币_${svt.id}.png|30px|link=]] 从者币";
            color = "";
            selected = true;
          } else if (category == ItemCategory.event || item.id == Items.qpId) {
            name = item.name;
            name = "{{道具|$name}} $name";
            color = "";
            selected = false;
          } else if ([ItemCategory.skill, ItemCategory.ascension, ItemCategory.normal].contains(category)) {
            name = item.lName.l;
            name = "{{道具|$name}} $name";
            if (item.background == ItemBGType.gold) {
              color = "#F6EFA6";
            } else if (item.background == ItemBGType.silver) {
              color = "#EAE9E9";
            } else if (item.background == ItemBGType.bronze) {
              color = "#FFEDD6";
            } else {
              color = "";
            }
            selected = category == ItemCategory.normal;
          } else if ([48, 2000, 5000, 5001, 5002, 5003].contains(item.id)) {
            // 巡霊の葉,獣の足跡,QAB Code Opener,Code Remover
            name = item.lName.l;
            name = name.replaceFirstMapped(RegExp(r"^(.)纹章"), (match) {
              // ignore: prefer_interpolation_to_compose_strings
              return {"迅": "Quick", "技": "Arts", "力": "Buster"}[match.group(1)]! + '纹章';
            });
            name = "{{道具|$name}} $name";
            color = "";
            selected = [48, 2000].contains(item.id);
          } else {
            // 1;;[[文件:灵衣开放权.png|30px|link=]] 简易灵衣「回忆中的假日风格」开放权;;1;;200;;
            buffer.writeln("UNKNOWN item: $target: ${shop.id}, ${shop.name}");
            continue;
          }
          writeShop(shop, selected, name, color);
        }
      }
      buffer.writeln("}}");
      if (index != payItemIds.length - 1) {
        buffer.writeln("|-|");
      }
    }
    buffer.writeln("</tabber>");
    final output = buffer.toString();
    print("\n$output");
    Clipboard.setData(ClipboardData(text: output));
    final unknownCount = output.toLowerCase().split("unknown").length - 1;
    assert(unknownCount == 0, "$unknownCount Unknown shops!!!");
    return output;
  }
}
