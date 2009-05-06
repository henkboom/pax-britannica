require "dokidoki.closedmodule"
[[ sprite_from_image, sprite_from_surface, texture_from_image,
   texture_from_surface, texture_from_ptr ]]

require "luagl"
require "luaglut"
require "memarray"
require "SDL"
import(SDL)
require "SDL_image"
import(SDL_image)

---- General Surface ----------------------------------------------------------

function surface_from_image (filename)
  assert(filename)
  local surface = IMG_Load(filename)
  sdl_check(surface)
  return surface
end

---- Sprites ------------------------------------------------------------------

do
  local index =
  {
    draw = function (self)
      glPushMatrix()
      self.tex:enable()
      
      local t = self.tex_rect
      local o = self.origin
      local s = self.size

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
  local image_surface = surface_from_image(filename)

  local sprite = sprite_from_surface(image_surface, size, origin)

  SDL_FreeSurface(image_surface)

  return sprite
end

function sprite_from_surface (surface, size, origin)
  local tex, w, h = texture_from_surface(surface)

  local size = size or {surface.w, surface.h}
  local origin = origin or {0, 0}
  local tex_rect = {0, 0, surface.w/w, surface.h/h}

  return make_sprite(tex, size, origin, tex_rect)
end

---- Textures -----------------------------------------------------------------

-- Stop it from garbage collecting the currently bound texture
bound_texture = false

-- Texture object
do
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
      if bound_texture == self then self:disable() end
      if self.name then delete_texture_name(self.name) end
      self.name = false
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
    tex.will = make_will(function () tex:delete() end)
    return tex
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
  local image_surface = surface_from_image(filename)
  local tex, w, h = texture_from_surface(image_surface)

  SDL_FreeSurface(image_surface)

  return tex, w, h
end

function texture_from_surface (surface)
  -- Creates an OpenGL texture from the given surface.
  --
  -- Returns the created texture object, the final width, and the final height.
  -- The returned texture will have size rounded up to the nearest power of
  -- two, so if you give surfaces with silly sizes then be prepared to handle
  -- it.
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
    -- TODO: this might might fail with colorkeyed images
    SDL_SetAlpha(surface, 0, 255)
    -- The SDL module exports SDL_BlitSurface as SDL_UpperBlit
    SDL_UpperBlit(surface, nil, new_surface, nil)
    -- TODO: extend the image across all the blank space, to emulate GL_CLAMP
  end

  local tex = texture_from_ptr(width, height, new_surface.pixels)
  if not use_original then SDL_FreeSurface(new_surface) end
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

---- Utilities

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
  end
end

function make_will(fn)
  local will = newproxy(true)
  getmetatable(will).__gc = function () fn() end
  return will
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
