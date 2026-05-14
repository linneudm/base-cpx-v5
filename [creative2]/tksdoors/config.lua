-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES PRINCIPAIS DO GERENCIADOR DE PORTAS (tksDoors rescripted)
-----------------------------------------------------------------------------------------------------------------------------------------
Config = {}

-- Comandos do Sistema
Config.PanelCommand = "painelportas"
Config.AddCommand = "addporta"
Config.ReloadCommand = "recarregarportas"

-- Permissão global necessária para acessar a Interface NUI (Adicionar/Remover portas, etc)
Config.Permission = "Admin"

-- Função de notificação via FiveM nativo ou VRP notify (Server Side)
Config.Notify = function(source, css, message)
    -- As cores e tipos css que o vRP/Creative utiliza são "sucesso", "nxg", "aviso", "importante" e "negado"
    TriggerClientEvent("Notify", source, css, message, 5000)
end

-- Função de notificação local do painel (Client Side)
Config.NotifyClient = function(css, message)
    TriggerEvent("Notify", css, message, 5000)
end
