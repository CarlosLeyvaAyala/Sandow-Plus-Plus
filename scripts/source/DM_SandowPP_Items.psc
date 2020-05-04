Scriptname DM_SandowPP_Items extends Quest 
{Distributes items among leveled lists}

Import DM_SandowPP_Globals

FormList Property SteroidsList Auto
{List of steroids}

FormList Property BullshitPowdersList Auto
{List of bullshit weight gainers}

FormList Property WeightSacksList Auto
{List of weight sacks}

LeveledItem Property LItemApothecaryIngredienstUncommon75 Auto  
{Leveled items list for vendors to sell powder items}

LeveledItem Property LItemSkooma75 Auto  
{Leveled items list for vendors to sell illegal items}

LeveledItem Property LItemMiscVendorMiscItems75 Auto  
{Leveled items list for vendors to sell misc items}

LeveledItem Property LootBanditChestBossBase  Auto  
LeveledItem Property LootCWImperialsChestBossBase  Auto  
LeveledItem Property LootCWSonsChestBossBase  Auto  
LeveledItem Property LootForswornChestBossBase  Auto
LeveledItem Property LootWerewolfChestBossBase  Auto  

bool Property WeightSacksDistributed = False Auto Hidden
{Have the weight sacks been distributed among vendors?}

bool Property SillyDistributed = False Auto Hidden
{Have the silly items been distributed among vendors?}



Function DistributeSilly()
    {Adds weight gainers to vendors}
    AddFormsToLvlList(SteroidsList, LItemSkooma75)
    AddFormsToLvlList(BullshitPowdersList, LItemApothecaryIngredienstUncommon75, 20)
    AddFormsToLvlList(BullshitPowdersList, LootBanditChestBossBase, 5)
    AddFormsToLvlList(BullshitPowdersList, LootCWImperialsChestBossBase, 5)
    AddFormsToLvlList(BullshitPowdersList, LootCWSonsChestBossBase, 5)
    SillyDistributed = True
EndFunction

Function DistributeWeightSacks()
    {Adds weight sacks to vendors and loot}
    AddFormsToLvlList(WeightSacksList, LItemMiscVendorMiscItems75)
    AddFormsToLvlList(WeightSacksList, LootBanditChestBossBase)
    AddFormsToLvlList(WeightSacksList, LootCWImperialsChestBossBase)
    AddFormsToLvlList(WeightSacksList, LootCWSonsChestBossBase)
    AddFormsToLvlList(WeightSacksList, LootForswornChestBossBase)
    AddFormsToLvlList(WeightSacksList, LootWerewolfChestBossBase)
    WeightSacksDistributed = True
EndFunction

Function AddFormsToLvlList(FormList aFrm, LeveledItem aLvlLst, int aNum = 1, int aLvl = 1)
    {Adds all items from a form list to a leveled list}
    int i = aFrm.GetSize()
    While i > 0
        i -= 1
        aLvlLst.addForm(aFrm.GetAt(i), aLvl, aNum)
    EndWhile
EndFunction