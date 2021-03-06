
local _, addonTable = ...;
local zc = addonTable.zc;

local L = Auctionator.Localization.Localize

-- TODO DOCUMENTATION
-- AUCTIONATOR_V_TIPS: 1 if should show vendor tips
-- AUCTIONATOR_SHIFT_TIPS:
-- AUCTIONATOR_A_TIPS:
function Auctionator.Tooltip.ShowTipWithPricing(tooltipFrame, itemId, itemCount)
  local showStackPrices = IsShiftKeyDown();

  if (AUCTIONATOR_SHIFT_TIPS == 2) then
    showStackPrices = not IsShiftKeyDown();
  end

  local countString = ""
  if itemCount and showStackPrices then
    countString = "|cFFAAAAFF x" .. itemCount .. "|r"
  end

  local auctionPrice = Auctionator.Database.GetPrice(itemId)
  if auctionPrice ~= nil then
    auctionPrice = auctionPrice * (showStackPrices and itemCount or 1)
  end

  local
    name,
    link,
    rarity,
    level,
    minLevel,
    itemType,
    itemSubType,
    stackCount,
    equipLocation,
    icon,
    sellPrice,
    classID,
    bindType = GetItemInfo(itemId);

  local vendorPrice = sellPrice * (showStackPrices and itemCount or 1)

  tooltipFrame:AddDoubleLine("ItemID", itemId)

  Auctionator.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  Auctionator.Tooltip.AddAuctionTip(tooltipFrame, auctionPrice, countString, bindType)

  -- TODO Disenchant price; still need to figure out d/e tables...

  tooltipFrame:Show()
end

-- Each itemId entry should contain
-- id
-- link (which may be an item link or a string name)
-- count
function Auctionator.Tooltip.ShowTipWithMultiplePricing(tooltipFrame, itemIds)
  local auctionPrice
  local total = 0
  local itemCount = 0

  for _, itemEntry in ipairs(itemIds) do
    tooltipFrame:AddLine(itemEntry.link)

    auctionPrice = Auctionator.Database.GetPrice(itemEntry.id)
    if auctionPrice ~= nil then
      total = total + (auctionPrice * itemEntry.count)
    end
    itemCount = itemCount + itemEntry.count

    Auctionator.Tooltip.ShowTipWithPricing(tooltipFrame, itemEntry.id, itemEntry.count)
  end

  tooltipFrame:AddLine("  ")

  tooltipFrame:AddDoubleLine(
    -- TODO Is "Total" localized?
    "Total " .. "|cFFAAAAFF " .. itemCount .. " items|r",
    WHITE_FONT_COLOR:WrapTextInColorCode(
      zc.priceToMoneyString(total)
    )
  )

  tooltipFrame:Show()
end

function Auctionator.Tooltip.AddVendorTip(tooltipFrame, vendorPrice, countString)
  if AUCTIONATOR_V_TIPS == 1 and vendorPrice > 0 then
    tooltipFrame:AddDoubleLine(
      L("Vendor") .. countString,
      WHITE_FONT_COLOR:WrapTextInColorCode(
        zc.priceToMoneyString(vendorPrice)
      )
    )
  end
end

-- TODO bindType constants are wrong (Linen Bolt shows BOA currently?)
function Auctionator.Tooltip.AddAuctionTip (tooltipFrame, auctionPrice, countString, bindType)
  if AUCTIONATOR_A_TIPS == 1 then

    if (bindType == ATR_BIND_ON_PICKUP) then
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("BOP") .. "  "
        )
      )
    elseif (bindType == ATR_BINDS_TO_ACCOUNT) then
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("BOA") .. "  "
        )
      )
    elseif (bindType == ATR_QUEST_ITEM) then
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("Quest Item") .. "  "
        )
      )
    elseif (auctionPrice ~= nil) then
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          zc.priceToMoneyString(auctionPrice)
        )
      )
    else
      tooltipFrame:AddDoubleLine(
        L("Auction") .. countString,
        WHITE_FONT_COLOR:WrapTextInColorCode(
          L("unknown") .. "  "
        )
      )
    end
  end
end