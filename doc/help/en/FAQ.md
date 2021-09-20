Common Issues and Bugs
================

**Please check update of app and dataset first. The old version of Chaldea APP may not be compatible
with the latest version of dataset.**


----------

### 1. Servant/Craft Essence/Command Code not found

Check following filters:

* ❤️ "Favorite/Others/All" filter
* 🕟 Outdated event filter
* ☑️ Filter dialog setting

Warning: "searching" is executed in the results filtrated by "filters"

If still cannot find, please contact developer. DON'T forget to provide your email!!!

----------

### 2. Game/UI Text Translation

**Game Text**:

Please check the correctness of data on wiki site. Edit and correct if that's wrong. Otherwise,
feedback is desired.

- Chines wiki: [Mooncell - fgo.wiki](https://fgo.wiki)
- English wiki: [Fandom](https://fategrandorder.fandom.com/wiki/Fate/Grand_Order_Wikia)

**UI Text**:

Any suggestion and contribution on translation is welcomed!


----------

### 3. Skill/Item Recognition

Only **LOCKED** servants are recognized. Low accuracy for 310(10/10/10) servants whose thumbs are
grey. Manual correction is recommended.

Attach skill screenshots and describe details if feedback wanted.


----------

### 4. Duplicated Servants Related

Some pages may went wrong because of duplicated servants. Please let me know to fix it.

Temporary fix: destroy duplicated servants. (servant detail page - popup menu - remove duplicated)


----------

### 6. Failed to Import Data

Including game dataset(dataset.zip), ffo resource(ffo-data.zip). If failed(e.g. Out of Memory), you
can extract the zip to the target folder manually.

All data should be saved inside `app_folder`, which differs from operating system. You can find the
true path in app `Settings/User Data/Data Folder`.

- `app_folder/user`: saving `userdata.json` - all user data, backup and restore manually allowed.
- `app_folder/data`: target folder for extracting game data `dataset.zip`, including `dataset.json`
  and `icons`
- `app_folder/ffo` : target folder for extracting FFO data `ffo-data.zip`
- `app_folder/backup`: daily backup of `userdata.json`

----------

### 5. Cannot Drag Scrollbar

Mostly on desktop platform which scrollbar is alto generated. When two or more scrollbars in one
page(including sub-tabs). Please let me know to fix it.

Dragging on page, mouse wheel and touchpad are still working.


----------

### 7. [Windows] `VCRUNTIME140_1.dll was not found on Windows`

Only x64 is supported on desktop。

You may need to install VC++ runtime(
x64): [Microsoft Visual C++ redistributable package](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads)

----------

### [Windows] Stuck at logo screen

Check your folder path where chaldea.exe saved:

- outside of system folder, e.g. "C:/Program File/" is not permitted. 
