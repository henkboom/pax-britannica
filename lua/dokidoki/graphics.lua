require "dokidoki.module"
[[ make_font_map, draw_text,
   sprite_from_image, sprite_from_surface,
   texture_from_image, texture_from_surface, texture_from_ptr,
   get_texture_count ]]

require "luagl"
require "luaglut"
require "memarray"
require "SDL"
require "SDL_image"
require "SDL_ttf"

import(SDL)
import(SDL_image)
import(SDL_ttf)

import(require "dokidoki.base")
will = require "dokidoki.private.will"

---- Fonts and Text -----------------------------------------------------------

function init_fonts()
  if TTF_WasInit() == 0 then sdl_check(TTF_Init() == 0) end
end

local font_map_chars = map(string.char, range((" "):byte(), ("~"):byte()))

function make_font_map (filename, size, chars)
  init_fonts()

  chars = chars or font_map_chars

  -- Keep a padding of this much in glyphs to prevent them from bleeding into
  -- each other when using linear filters. This has to be higher if you're
  -- using strong mipmapping. It should always be at least 1.
  local glyph_padding = 1

  local font = TTF_OpenFont(filename, size)
  local line_height =
    math.max(TTF_FontLineSkip(font), TTF_FontHeight(font))

  -- Start the surface at 512x64, but the height will grow automatically.
  local surface = SDL_CreateRGBSurface(
    SDL_SWSURFACE, 512, 64, 32, rmask, gmask, bmask, amask)

  local x = glyph_padding
  local y = glyph_padding

  local rects = {}

  for _, c in pairs(font_map_chars) do
    local glyph = surface_from_text(font, c)
    -- Go to the next row if this one is full.
    if x + glyph.w + glyph_padding > surface.w then
      x = glyph_padding
      y = y + line_height + glyph_padding
      assert(x + glyph.w + glyph_padding <= surface.w,
             "A glyph is too wide for the texture.")
    end
    -- If there isn't enough room for the current row, grow the texture to fit
    -- it.
    if y + line_height + glyph_padding > surface.h then
      local new_surface = SDL_CreateRGBSurface(
        SDL_SWSURFACE, surface.w,
        to_power_of_two(y + line_height + glyph_padding), 32, rmask, gmask,
        bmask, amask)
      flat_blit(surface, nil, new_surface, nil)
      SDL_FreeSurface(surface)
      surface = new_surface
    end

    -- Blit the glyph!
    flat_blit(glyph, nil, surface, {x, y})

    rects[c] = {x, y, glyph.w, glyph.h}
    x = x + glyph.w + glyph_padding

    SDL_FreeSurface(glyph)
  end

  -- Convert rendered text to a texture
  local tex = texture_from_surface(surface)

  -- Make the sprites
  local sprites = {}
  for c, rect in pairs(rects) do
    -- Transform the pixel coordinates into texture coordinates
    local tex_rect =
    {
      rect[1] / surface.w,
      rect[2] / surface.h,
      rect[3] / surface.w,
      rect[4] / surface.h
    }
    sprites[c] = make_sprite(tex, {rect[3], rect[4]}, nil, tex_rect)
  end

  SDL_FreeSurface(surface)
  TTF_CloseFont(font)

  return sprites;
end

function draw_text(font_map, text)
  glPushMatrix()
  for i = 1, #text do
    local sprite = font_map[text:sub(i, i)]
    if sprite then
      sprite:draw()
      glTranslated(sprite.size[1], 0, 0)
    else
      error("Tried to render an unavailable character code " .. text:byte(i))
    end
  end
  glPopMatrix()
end

function surface_from_text(font, text)
  assert(font)
  assert(text)
  local color = SDL_Color_new()
  color.r, color.g, color.b = 255, 255, 255
  local surface = TTF_RenderUTF8_Blended(font, text, color)
  sdl_check(surface)
  SDL_Color_delete(color)
  return surface
end

---- Sprites ------------------------------------------------------------------

do
  local index =
  {
    draw = function (self)
      glPushMatrix()
      
      local t = self.tex_rect
      local o = self.origin
      local s = self.size

      self.tex:enable()
      glBegin(GL_QUADS)
        glTexCoord2d(t[1], t[2] + t[4])
        glVertex2d(-o[1], -o[2])

        glTexCoord2d(t[1] + t[3], t[2] + t[4])
        glVertex2d(-o[1] + s[1], -o[2])

        glTexCoord2d(t[1] + t[3], t[2])
        glVertex2d(-o[1] + s[1], -o[2] + s[2])

        glTexCoord2d(t[1], t[2])
        glVertex2d(-o[1], -o[2] + s[2])
      glEnd()
      self.tex:disable()
      glPopMatrix()
    end
  }

  local mt = {__index = index}

  function make_sprite (tex, size, origin, tex_rect)
    assert(tex)
    assert(size)

    if origin == "centered" then
      origin = {size[1]/2, size[2]/2}
    end

    return setmetatable(
      {
        tex = tex,
        size = size,
        origin = origin or {0, 0},
        tex_rect = tex_rect or {0, 0, 1, 1}
      },
      mt)
  end
end

function sprite_from_image (filename, size, origin)
  -- Creates a sprite object from the image file given by filename.
  --
  -- See notes about sprite_from_surface for size/origin info.
  return sprite_from_surface(surface_from_image(filename), true, size, origin)
end

function sprite_from_surface (surface, delete_surface, size, origin)
  -- Creates a sprite object from the given surface.
  --
  -- When delete_surface is true, the surface is deleted after the sprite is
  -- created. The size is the rendered size of the sprite, given as {x, y}. Its
  -- default value is the pixel size of the surface. origin specifies the point
  -- on the sprite which should be rendered at the origin when the sprite is
  -- drawn, and it's in the same units as the size. origin can either be {x, y}
  -- or "center", which sets it to half the size. origin's default value is
  -- {0, 0}.
  assert(surface)
  surface_w = surface.w
  surface_h = surface.h
  local tex, tex_w, tex_h = texture_from_surface(surface, delete_surface)

  local size = size or {surface_w, surface_h}
  local origin = origin or {0, 0}
  local tex_rect = {0, 0, surface_w/tex_w, surface_h/tex_h}

  return make_sprite(tex, size, origin, tex_rect)
end

---- Textures -----------------------------------------------------------------

-- Stop it from garbage collecting the currently bound texture
bound_texture = false

-- Texture object
do
  local texture_count = 0

  local index = 
  {
    enable = function (self)
      -- Enables 2D texturing and binds the texture.
      assert(self.name)
      bound_texture = self
      glEnable(GL_TEXTURE_2D)
      glBindTexture(GL_TEXTURE_2D, self.name)
    end,
    disable = function (self)
      -- Disables 2D texturing and unbinds the texture.
      assert(self.name)
      glBindTexture(GL_TEXTURE_2D, 0)
      glDisable(GL_TEXTURE_2D)
      bound_texture = false
    end,
    delete = function (self)
      -- Deletes the texture from video memory.
      --
      -- This invalidates the object, so don't use it anymore.
      if self.name then
        if bound_texture == self then self:disable() end
        delete_texture_name(self.name)
        texture_count = texture_count - 1
        self.name = false
      end
    end
  }

  local mt = {__index = index}

  function make_texture (name)
    -- Makes a new texture object with the given OpenGL texture name.
    --
    -- The texture object is deleted automatically by the garbage collector,
    -- but it is recommended that you delete it manually with :delete() in
    -- order to free up video memory sooner.
    local tex =  setmetatable({name = name}, mt)
    will.attach_will(tex, function () tex:delete() end)
    texture_count = texture_count + 1
    return tex
  end

  function get_texture_count()
    return texture_count
  end
end

function texture_from_image (filename)
  -- Creates an OpenGL texture from the image file given by filename.
  --
  -- Returns the created texture object, the final width, and the final height.
  -- See the note on texture_from_surface for width/height issues. Since
  -- there's no way to determine the original image's size, this function is
  -- only useful if you know its size beforehand, or at least know that it's a
  -- power of two.
  return texture_from_surface(surface_from_image(filename), true)
end

function texture_from_surface (surface, delete_surface)
  -- Creates an OpenGL texture from the given surface.
  --
  -- Returns the created texture object, the final width, and the final height.
  -- The returned texture will have size rounded up to the nearest power of
  -- two, so if you give surfaces with silly sizes then be prepared to handle
  -- it. If delete_surface is true, the surface is deleted after the texture is
  -- generated.
  local format = surface.format
  local use_original =
    is_power_of_two(surface.w) and
    is_power_of_two(surface.h) and
    format.BytesPerPixel == 4 and
    format.Rmask == rmask and
    format.Gmask == gmask and
    format.Bmask == bmask and
    format.Amask == amask

  local new_surface
  local width = to_power_of_two(surface.w)
  local height = to_power_of_two(surface.h)

  if use_original then
    new_surface = surface
  else
    new_surface = SDL_CreateRGBSurface(
      SDL_SWSURFACE, width, height, 32, rmask, gmask, bmask, amask)
    sdl_check(new_surface)

    flat_blit(surface, nil, new_surface, nil)

    -- TODO: extend the image across all the blank space, to emulate GL_CLAMP
    -- free up the old memory if the caller wanted us to
    if delete_surface then SDL_FreeSurface(surface) end
  end

  local tex = texture_from_ptr(width, height, new_surface.pixels)

  -- Clean up our new surface and/or the old surface
  if not use_original then SDL_FreeSurface(new_surface)
  elseif delete_surface then SDL_FreeSurface(surface) end

  return tex, width, height
end

function texture_from_ptr (width, height, ptr)
  -- Creates an OpenGL texture from the RGBA byte array given by ptr.
  --
  -- width and height must be powers of two.
  assert(is_power_of_two(width) and is_power_of_two(height),
         "tried to make texture with non-power-of-two dimensions")

  local name = new_texture_name()
  glBindTexture(GL_TEXTURE_2D, name)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameterf(
    GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, width, height, GL_RGBA,
                    GL_UNSIGNED_BYTE, ptr)
  glBindTexture(GL_TEXTURE_2D, 0)
  return make_texture(name)
end

---- General Surface ----------------------------------------------------------

function surface_from_image (filename)
  assert(filename)
  local surface = IMG_Load(filename)
  sdl_check(surface)
  return surface
end

-- Because it's a pain to use SDL_BlitSurface directly
function flat_blit(src, src_rect, dst, dst_pos)
    local flags = src.flags
    SDL_SetAlpha(src, 0, 255)

    -- convert the rects to SDL_Rect. . . boring!
    local _src_rect, _dst_rect
    if src_rect then
      _src_rect = SDL_Rect_new()
      _src_rect.x, _src_rect.y, _src_rect.w, _src_rect.h = unpack(src_rect)
    end
    if dst_pos then
      _dst_rect = SDL_Rect_new()
      _dst_rect.x, _dst_rect.y = unpack(dst_pos)
    end

    -- This is what the SDL bindings export SDL_BlitSurface as.
    SDL_UpperBlit(src, _src_rect, dst, _dst_rect)

    src.flags = flags
    if _src_rect then SDL_Rect_delete(_src_rect) end
    if _dst_rect then SDL_Rect_delete(_dst_rect) end
end

---- Utilities ----------------------------------------------------------------

function new_texture_name ()
  local namebuffer = memarray("uint", 1)
  glGenTextures(1, namebuffer:ptr())
  return namebuffer[0]
end

function delete_texture_name (name)
  local namebuffer = memarray("uint", 1)
  namebuffer[0] = name
  glDeleteTextures(1, namebuffer:ptr())
end

function is_power_of_two (x)
  return x == to_power_of_two(x)
end

function to_power_of_two (x)
  return 2 ^ math.ceil(math.log(x) / math.log(2))
end

function sdl_check(condition)
  if not condition then
    error(SDL_GetError())
    else
  end
end

---- Color Mask Calculation ---------------------------------------------------

do
  local one = memarray("int", 1)
  one[0] = 1

  local is_little_endian = one:to_str():byte() == 1

  if is_little_endian then
    rmask, gmask, bmask, amask = 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000
  else
    rmask, gmask, bmask, amask = 0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff
  end
end

return get_module_exports()
