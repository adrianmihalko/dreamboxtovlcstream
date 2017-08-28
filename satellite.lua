-- boxIp if chane port of openwebif add port like IP:PORT
local boxIp = '192.168.1.5'
-- Sream port
local streamPort = '8001'
-- Playlist Name
local boxName = 'Satellite'

-- Authentication --
local username = 'root'
local password = 'password'
-- if have openwebif authentication make this true
local httpPassword = false
-- if on change channel need password make this true
local streamPassword = false


-- Do Not Touch
local xml = nil
local servicesUrl = 'http://' .. boxIp .. '/web/getservices'
if httpPassword then servicesUrl = 'http://' .. username .. ':' .. password .. '@' .. boxIp .. '/web/getservices' end
local bugetUrl = 'http://' .. boxIp .. '/web/getservices?sRef='
if httpPassword then bugetUrl = 'http://' .. username .. ':' .. password .. '@' .. boxIp .. '/web/getservices?sRef=' end
local streamUrl = 'http://' .. boxIp .. ':' .. streamPort .. '/'
if streamPassword then streamUrl = 'http://' .. username .. ':' .. password .. '@' .. boxIp .. ':' .. streamPort .. '/' end

function descriptor()
    return { title = boxName, capabilities = {} }
end

function activate()
    main()
end

function main()
    loadXmlLib()
    local s = parse_xml(servicesUrl)
    if s ~= nil then
        for _, b in ipairs(s.children_map["e2service"]) do
            local buget = parse_xml(bugetUrl .. b.children_map["e2servicereference"][1].children[1])
            if buget ~= nil then
                local node = vlc.sd.add_node( { title=b.children_map["e2servicename"][1].children[1] } )
        		if (buget.children_map["e2service"]) then
        		    for _, c in ipairs(buget.children_map["e2service"]) do
                        local link = c.children_map["e2servicereference"][1].children[1]
                        if link:match('http%%3a//') then
                            link = link:match('http%%3a//[^:]+')
                            link = link:gsub('%%3a',':')
                        else
                			link = streamUrl .. link
                        end
                        node:add_subitem( {
                            path = link,
                            title = c.children_map["e2servicename"][1].children[1]
                        } )
                    end
                end
            end
        end
    end
end

function loadXmlLib()
    if xml ~= nil then return nil end
    xml = require("simplexml")
end

function parse_xml( url )
    local response = xml.parse_url( url )
    xml.add_name_maps( response )
    return response
end
