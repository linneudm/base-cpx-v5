local ConfigTheme = { -- configuração das cores do tema
  ["currency"] = "R$",
  ["main"] = "#5da1f8",
  ["common"] = "#6fc66a",
  ["rare"] = "#6ac6c5",
  ["epic"] = "#c66a75",
  ["legendary"] = "#c6986a",
  ["accept"] = {
    ["letter"] = "#dcffe9",
    ["background"] = "#3fa466"
  },
  ["reject"] = {
    ["letter"] = "#ffe8e8",
    ["background"] = "#ad4443"
  },
  ["chat"] = {
    ["Families"] = "#ff0000",
    ["Ballas"] = "#00ff00",
    ["Vagos"] = "#0000ff"
  },
  ["hud"] = {
    ["modes"] = {
      ["info"] = 1,      -- [ Opções disponíveis: 1,2,3 ]
      ["icon"] = "fill", -- [ Opções disponíveis: fill,line ]
      ["status"] = 4,    -- [ Opções disponíveis: 1,2,3,4,5,6,7,8,9,10,11,12 ]
      ["vehicle"] = 2    -- [ Opções disponíveis: 1,2,3 ]
    },
    ["percentage"] = true,
    ["icons"] = "#FFFFFF",
    ["nitro"] = "#f69d2a",
    ["rpm"] = "#FFFFFF",
    ["fuel"] = "#f94c54",
    ["engine"] = "#ff4c55",
    ["health"] = "#76B984",
    ["armor"] = "#A66FED",
    ["hunger"] = "#F4B266",
    ["thirst"] = "#5da1f8",
    ["stress"] = "#E287C9",
    ["luck"] = "#F18A7C",
    ["dexterity"] = "#E4E76E",
    ["repose"] = "#7FCCC7",
    ["pointer"] = "#ef4444",
    ["progress"] = {
      ["background"] = "#FFFFFF",
      ["circle"] = "#5da1f8",
      ["letter"] = "#FFFFFF"
    }
  },
  ["notifyitem"] = {
    ["add"] = {
      ["letter"] = "#dcffe9",
      ["background"] = "#3fa466"
    },
    ["remove"] = {
      ["letter"] = "#ffe8e8",
      ["background"] = "#ad4443"
    }
  },
  ["pause"] = {
    ["premium"] = true,
    ["store"] = true,
    ["battlepass"] = false,
    ["boxes"] = true,
    ["marketplace"] = true,
    ["skinweapon"] = false,
    ["map"] = true,
    ["disconnect"] = true
  }
}

function GetTheme()
  return ConfigTheme
end
