require "dokidoki.module"
[[ draw_text,
   sprite_from_image, make_sprite,
   texture_from_image, texture_from_string,
   get_texture_count ]]

local stb_image = require "stb_image"

import(require "gl")
import(require "glu")
require 'memarray'

local will = require "dokidoki.private.will"

---- Fonts and Text -----------------------------------------------------------

function font_map_line_height (font_map)
  local _, some_glyph = next(font_map)
  return some_glyph.size[2]
end

function draw_text(font_map, text)
  local line_height = font_map_line_height (font_map)

  local current_line = 0

  glPushMatrix()
  for i = 1, #text do
    local char = text:sub(i, i)
    if char == "\n" then
      glPopMatrix()
      current_line = current_line + 1
      glPushMatrix()
      glTranslated(0, current_line * -line_height, 0)
    else
      local sprite = font_map[char]
      if sprite then
        sprite:draw()
        glTranslated(sprite.size[1], 0, 0)
      else
        error("Tried to render an unavailable character code " .. text:byte(i))
      end
    end
  end
  glPopMatrix()
end

---- Sprites ------------------------------------------------------------------

do
  local index =
  {
    draw = function (self)
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
    end
  }

  local mt = {__index = index}

  function make_sprite (tex, size, origin, tex_rect)
    assert(tex)
    assert(size)

    if origin == "center" then
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
  -- See notes about sprite_from_image_string for size/origin info.
  local image_string, width, height, channels =
    assert(stb_image.load(filename))
  return sprite_from_image_string(
    image_string, width, height, channels, size, origin)
end

function sprite_from_image_string (image_string, width, height, channels, size,
                                   origin)
  -- Creates a sprite object from the given surface.
  --
  -- The size is the rendered size of the sprite, given as {x, y}. Its default
  -- value is the pixel size of the surface. origin specifies the point on the
  -- sprite which should be rendered at the origin when the sprite is drawn,
  -- and it's in the same units as the size. origin can either be {x, y} or
  -- "center", which sets it to half the size. origin's default value is
  -- {0, 0}.

  local tex, tex_w, tex_h =
    texture_from_string(image_string, width, height, channels)

  local size = size or {width, height}
  local origin = origin or {0, 0}
  local tex_rect = {0, 0, width/tex_w, height/tex_h}

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
  return texture_from_string(assert(stb_image.load(filename)))
end

function image_string_to_powers_of_two(image_string, width, height, channels)
  assert(#image_string == width * height * channels,
         "image_string length doesn't match")
  assert(1 <= channels and channels <= 4, "invalid channels given")
  
  local new_width = to_power_of_two(width)
  local new_height = to_power_of_two(height)

  if new_width == width and new_height == height then
    return image_string, width, height, channels
  else
    local new_image = {}
    
    -- fill right
    for y = 1, height do
      local begin = (y-1) * width * channels + 1
      local ending = y * width * channels
      local fill = image_string:sub(ending + 1 - channels, ending)

      table.insert(new_image, image_string:sub(begin, ending))
      table.insert(new_image, string.rep(fill, new_width - width))
    end

    -- fill bottom
    local last_row = new_image[#new_image - 1] .. new_image[#new_image]
    for y = height+1, new_height do
      table.insert(new_image, last_row)
    end

    return table.concat(new_image), new_width, new_height, channels
  end
end

function texture_from_string (image_string, width, height, channels)
  -- Creates an OpenGL texture from the data in image_string.
  --
  -- If width and height are not powers of two, the texture will be padded out
  -- to the nearest greater power of two. The bytes in image_string are treated
  -- as unsigned byte values. channels must be 1, 2, 3, or 4 for V, VA, RGB,
  -- and RGBA respectively. #image_string should be width*height*channels.  The
  -- generated texture, the final width, and the final height are returned.

  assert(#image_string == width * height * channels,
         "image_string length doesn't match")
  assert(1 <= channels and channels <= 4, "invalid channels given")

  if not (is_power_of_two(width) and is_power_of_two(height)) then
    image_string, width, height, channels =
      image_string_to_powers_of_two(image_string, width, height, channels)
  end
  
  local tex = texture_from_pointer(image_string, width, height, channels)

  return tex, width, height
end

function texture_from_pointer(pointer, width, height, channels)
  -- Creates an OpenGL texture from the data pointed to by pointer.
  --
  -- width and height must be powers of two. channels must be 1, 2, 3, or 4 for
  -- V, VA, RGB, and RGBA respectively. pointer should point to a native array
  -- of width * height * channels unsigned bytes.
  assert(is_power_of_two(width) and is_power_of_two(height),
         "non-power-of-two dimensions given")
  local format = channels == 1 and GL_LUMINANCE or
                 channels == 2 and GL_LUMINANCE_ALPHA or
                 channels == 3 and GL_RGB or
                 channels == 4 and GL_RGBA
  assert(format, "invalid channels given")

  local name = new_texture_name()
  glBindTexture(GL_TEXTURE_2D, name)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  glTexParameterf(
  --  GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
    GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
  gluBuild2DMipmaps(GL_TEXTURE_2D, format, width, height, format,
                    GL_UNSIGNED_BYTE, pointer)
  glBindTexture(GL_TEXTURE_2D, 0)
  return make_texture(name)
end

---- Utilities ----------------------------------------------------------------

function new_texture_name ()
  local namebuffer = memarray('GLint', 1)
  glGenTextures(1, namebuffer:ptr())
  return namebuffer[0]
end

function delete_texture_name (name)
  local namebuffer = memarray("GLint", 1)
  namebuffer[0] = name
  glDeleteTextures(1, namebuffer:ptr())
end

function is_power_of_two (x)
  return x == to_power_of_two(x)
end

function to_power_of_two (x)
  return 2 ^ math.ceil(math.log(x) / math.log(2))
end

return get_module_exports()
