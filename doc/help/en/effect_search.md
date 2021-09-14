Skill Effect/Buff Search
================

Data source: Atlas Academy。

Main Feature: search and filtrate effect/buff of servant's skill&NP, CE and command code.


### 1. Effect Type Filter
Skill effects contains 2 categories: 
- `FuncType`: take effect directly, like NP charge, gain stars.
- `BuffType`: act as buff/debuff and show icons on status bar for 1 or more turns


This page shows the original `FuncType` and `BuffType` filter. 
If you need optimized filter, please goto the filter dialog of servant/CE/command code list page.

Optimizations:
- subdivide: divide **Command Card Up** into **Arts/Quick/Buster Card Up**. They are all `upCommandall` originally.
- combination: combine FuncType and BuffType, similar effects. Like **NP Charge** and **Absorb NP**.

How to decide combination?
- some effects have buff/debuff 2 kinds
- similar effect, target differs: supereffective NP damage against enemy with specific Trait/State(Buff)/Rarity/Self-HP.
- the above combination is based on my own point. Some rarely used effects are dropped.
- If any mistake, please tell me.

**Optimizations above are taken in servant or other list page's filter, NOT HERE**


### 2. Keyword Search

Click on search button, search skill name and effect here(EN/JP/CN). 
Don't support search for card name, illustrator or other fields.
Don't support Chinese Pinyin initials and Japanese Romaji, input the correct words please.

You can specific search scope for servant: active skill/passive skill/noble phantasm, no append skill.

Warning:The scope in filter dialog and in search input box's setting are independent.


### 3. About Command Code
Command Code's effects: 
- some are always taken effect: No.12, this should work.
- some when the card is attacking: filter cannot distinguish them, they are all **Command Code Effect when Attack=commandcodeattackFunction**

Anyway, use keyword search instead.
