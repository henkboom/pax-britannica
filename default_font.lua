require 'dokidoki.module' [[ load ]]

local stb_image = require 'stb_image'
local graphics = require 'dokidoki.graphics'

local data = "PNG\r\
\
\000\000\000\rIHDR\000\000\000@\000\000\0005\000\000\000[%'\000\000\000sRGB\000®Îé\000\000@IDATXÃíYÛrÅ ¦ÿÿËöÁRä*&éeæÌ¤5Ë²Zïkþ;ézq½ô»rQöbmÆo¸\"\000\000â¹	c Î{ÕZÇÏºFzÑ'¶¸xpëlIl;ý¼5;HigÐ÷{ï= ga VoèCW= u|s^èÂ¿úð\\dú%¢¼o[ñÇ¤ÞýÂÆ\rCK:¶MRU)\
j}aÔNyQöW;ë(Æ#dÏ'\000\000øÂ§p¼cçL×4Å³_1°¢áGPþ¦ã4,Ù/zöÙQ²d]ok Åré>=kú~Þ°rtfÁvläÊÔµRiN¿~\"q;Úi¼«êÊTBÌ©U¯m­éxM#\
ôô¦ÿAC^Ïg²¼wë~~_ AHõðè,÷æ/	nÉ«	t7y4×è¶\"ßa>ËLvûÖ³§zä\\wy:~)Ø.7+§à]Ït_ðäÜÖ<±¼G^RUÙ½j©e½IÙDÁùÙN©=YYZOâôëOÃ,i×5¹&TLæ%Ô¼ä{ÞÄêö{OiÅÅoé\
ËwÛ[>hjÂx	råtôÇX§{,õ«{¿÷0Û¸;2£W]ªA&1¡,1Øòü®QÀ\\jB¶¦£	­í}\\FÕÀõ!«d^ÒUÙÂhÂl«­¡nËþãr\000±»\\_eQð ×(èà\\û)\000\000\000\000IEND®B`"

local chars_per_row = 16

local char_width = 4
local char_height = 9

local char_size = {4, 9}
local char_origin = {0, char_height}

local start_code = string.byte(' ')
local end_code = string.byte('~')

function load()
  local tex, width, height = graphics.texture_from_string(
    --assert(stb_image.load_from_string(data)))
    assert(stb_image.load('/home/henk/documents/pictures/lime-tiny-fit.png')))

  local fontmap = {}

  for code = start_code, end_code do
    local i = code - start_code
    local x = (i % chars_per_row) * char_width
    local y = math.floor(i / chars_per_row) * char_height
    local rect = {x/width, y/height, char_width/width, char_height/height}

    fontmap[string.char(code)] = graphics.make_sprite(
      tex, char_size, char_origin, rect)
  end

  return fontmap
end

return get_module_exports()
