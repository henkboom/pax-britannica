#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portaudio.h>
#include "stb_vorbis.h"

//// Types, Constants, Globals ////////////////////////////////////////////////

typedef short sample_t;
typedef int calc_t;
#define SAMPLE_MIN (-0x8000)
#define SAMPLE_MAX 0x7FFF
#define PORTAUDIO_SAMPLE_TYPE paInt16

#define SAMPLE_RATE 44100
#define SAMPLE_TIME (1.0/SAMPLE_RATE)
#define CHANNELS 64
#define BUFFER_SIZE 256

typedef struct
{
    size_t frames;
    sample_t * samples;
} sound_data_t;

typedef struct
{
    float volume[2];
} fade_t;

typedef struct
{
    // shared
    volatile int is_new;
    const sound_data_t * volatile data;
    int loop; // callback-only after init

    volatile int new_fade_duration;
    volatile fade_t new_fade;

    // for use by callback only
    size_t position;
    int fade_duration;
    int fade_remaining;
    fade_t fade_start;
    fade_t fade_end;
} channel_t;

static const char * error_string = NULL;

static int calc_buffer[BUFFER_SIZE * 2];

#define CHECK(condition, message) \
    { if(!(condition)) { if(message) error_string = message; return 0; } }
#define ERROR(message) CHECK(0, message)

//// Fades ////////////////////////////////////////////////////////////////////

static float interp(float t, float start, float end)
{
    return (1-t) * start + t * end;
}

static void fade_interp(const channel_t * chan, fade_t *out)
{
    const fade_t * start = &chan->fade_start;
    const fade_t * end = &chan->fade_end;

    float t = 1;

    if(chan->fade_duration > 0)
        t = 1 - (float)chan->fade_remaining / chan->fade_duration;

    out->volume[0] = interp(t, start->volume[0], end->volume[0]);
    out->volume[1] = interp(t, start->volume[1], end->volume[1]);
}

static void fade_init(fade_t * out)
{
    out->volume[0] = 1;
    out->volume[1] = 1;
}

//// Channels /////////////////////////////////////////////////////////////////

static channel_t channels[CHANNELS];

static int channel_is_valid(int channel)
{
    return 0 <= channel && channel < CHANNELS;
}

static int channel_is_active(int channel)
{
    assert(channel_is_valid(channel));
    return channels[channel].data != NULL;
}

static void channel_stop(int channel)
{
    assert(channel_is_valid(channel));
    channels[channel].data = NULL;
}

static void channel_mix_into(int channel, calc_t * output,
                             size_t frame_count)
{
    assert(channel_is_valid(channel));
    assert(channel_is_active(channel));

    int i;
    channel_t * chan = &channels[channel];
    const sound_data_t * data = chan->data;

    if(chan->is_new)
    {
        chan->is_new = 0;
        chan->position = 0;
        chan->fade_duration = 0;
        chan->fade_remaining = 0;
        fade_init(&chan->fade_start);
        fade_init(&chan->fade_end);
    }

    if(chan->new_fade_duration >= 0)
    {
        fade_t current;
        fade_interp(chan, &current);
        chan->fade_start = current;
        chan->fade_end = chan->new_fade;
        chan->fade_duration = chan->new_fade_duration;
        chan->fade_remaining = chan->fade_duration;
        chan->new_fade_duration = -1;
    }

    size_t position = chan->position;
    size_t to_copy = data->frames - position;
    if(to_copy > frame_count) to_copy = frame_count;

    for(i = 0; i < to_copy; i++)
    {
        fade_t fade;
        fade_interp(chan, &fade);

        output[i*2]   += data->samples[(position + i)*2]   * fade.volume[0];
        output[i*2+1] += data->samples[(position + i)*2+1] * fade.volume[1];

        if(chan->fade_remaining > 0) chan->fade_remaining--;
    }

    chan->position = position + to_copy;

    if(chan->position == data->frames)
    {
        // imprecise looping for now
        if(chan->loop > 0)
        {
            chan->loop--;
            if(chan->loop == 0)
                channel_stop(channel);
            else
                chan->position = 0;
        }
        else
        {
            chan->position = 0;
        }
    }
}

//// General Audio ////////////////////////////////////////////////////////////

static void mix_into(sample_t * output, size_t frame_count)
{
    memset(calc_buffer, 0, frame_count * 2 * sizeof(calc_t));

    int c;
    for(c = 0; c != CHANNELS; c++)
        if(channel_is_active(c))
            channel_mix_into(c, calc_buffer, frame_count);

    int i;
    for(i = 0; i != BUFFER_SIZE * 2; i++)
    {
        if(calc_buffer[i] <= SAMPLE_MIN)
            output[i] = SAMPLE_MIN;
        else if(calc_buffer[i] <= SAMPLE_MAX)
            output[i] = calc_buffer[i];
        else
            output[i] = SAMPLE_MAX;
    }
}

static int play_sound_effect(const sound_data_t * data, float left,
                             float right, int loop)
{
    int c = 0;
    while(c != CHANNELS && channel_is_active(c)) c++;
    if(c == CHANNELS)
    {
        return -1;
    }
    else
    {
        channels[c].is_new = 1;
        channels[c].loop = loop;

        channels[c].new_fade.volume[0] = left;
        channels[c].new_fade.volume[1] = right;
        channels[c].new_fade_duration = 0;

        // this marks the channel as ready, so after this the callback is free
        // to jump on it
        channels[c].data = data;

        return c;
    }
}

static void channel_fade_to(int channel, float duration, float left,
                            float right)
{
    assert(channel_is_valid(channel));
    if(channel_is_active(channel))
    {
        while(channels[channel].new_fade_duration >= 0)
            /* wait for previous fade to be acknowledged */;

        channels[channel].new_fade.volume[0] = left;
        channels[channel].new_fade.volume[1] = right;
        channels[channel].new_fade_duration = (int)(duration * SAMPLE_RATE);
    }
}

//// Sound Data ///////////////////////////////////////////////////////////////

static sound_data_t * new_sound_data(size_t frames)
{
    sound_data_t * data = (sound_data_t *)malloc(sizeof(sound_data_t));
    data->frames = frames;
    data->samples = (sample_t *)malloc(frames * sizeof(sample_t) * 2);
    return data;
}

static void delete_sound_data(sound_data_t * data)
{
    free(data->samples);
    free(data);
}

//// WAV Loading //////////////////////////////////////////////////////////////

static unsigned char get_u8(FILE * file)
{
    int n =  fgetc(file);
    return n == EOF ? 0 : (unsigned char)n;
}

static unsigned short get_u16(FILE * file)
{
    unsigned n = get_u8(file);
    return n + (get_u8(file) << 8);
}

static unsigned short get_s16(FILE * file)
{
    return (signed short)get_u16(file);
}

static unsigned int get_u32(FILE * file)
{
    unsigned n = get_u16(file);
    return n + (get_u16(file) << 16);
}

static int get_chunk_id(const char * id, FILE * file)
{
    size_t read;
    char chunk_id[5];
    chunk_id[4] = 0;
    read = fread(chunk_id, 1, 4, file);
    CHECK(read == 4 && strcmp(chunk_id, id) == 0, NULL);
    return 1;
}

static sound_data_t * load_wav(const char * filename)
{
    FILE * file = fopen(filename, "rb");
    CHECK(file, "file not found");
    
    char chunk_id[5];
    chunk_id[4] = 0;

    // read RIFF header
    CHECK(get_chunk_id("RIFF", file), "didn't get expected \"RIFF\" chunk");
    get_u32(file);
    CHECK(get_chunk_id("WAVE", file), "didn't get expected \"WAVE\" type");

    // read "fmt " chunk
    CHECK(get_chunk_id("fmt ", file), "didn't get expected \"fmt \" chunk");
    CHECK(get_u32(file) == 16, "unexpected \"fmt \" chunk size");
    CHECK(get_u16(file) == 1, "unsupported compression type");
    int channels = get_u16(file);
    CHECK(channels == 1 || channels == 2, "unsupported number of channels");
    CHECK(get_u32(file) == SAMPLE_RATE, "unsupported sample rate");
    get_u32(file); // skip bytes per second
    get_u16(file); // skip block align
    int bits_per_sample = get_u16(file);
    CHECK(bits_per_sample == 8 || bits_per_sample == 16,
          "unsupported bits per sample");

    // read "data" chunk
    CHECK(get_chunk_id("data", file), "didn't get expected \"data\" chunk");
    size_t size = get_u32(file);
    size_t frames = size * 8 / bits_per_sample / channels; // two channels

    sound_data_t * data = new_sound_data(frames);
    sample_t * dest = data->samples;
    sample_t * end = data->samples + frames * 2;

    if(bits_per_sample == 8)
        while(!feof(file) && !ferror(file) && dest != end)
        {
            sample_t sample = ((sample_t)get_u8(file) - 128) << 8;
            *(dest++) = sample;
            if(channels == 1) *(dest++) = sample;
        }
    else
        while(!feof(file) && !ferror(file) && dest != end)
        {
            sample_t sample = get_s16(file);
            *(dest++) = sample;
            if(channels == 1) *(dest++) = sample;
        }
    if(dest != end)
    {
        delete_sound_data(data);
        data = NULL;
        ERROR("error or end of file before finished reading samples");
    }

    return data;
}

//// OGG Loading //////////////////////////////////////////////////////////////

static sound_data_t * load_ogg(const char * filename)
{
    sound_data_t * data = new_sound_data(0);
    int channels;
    int ret = stb_vorbis_decode_filename(
        (char *)filename,
        &channels,
        &data->samples);
    if(channels != 2)
    {
        delete_sound_data(data);
        data = NULL;
        ERROR("only 2-channel ogg files are supported");
    }
    if(ret < 0)
    {
        delete_sound_data(data);
        data = NULL;
        ERROR("some sort of error in stb_vorbis_decode_filename");
    }
    data->frames = ret;

    return data;
}

//// Portaudio ////////////////////////////////////////////////////////////////

#define PA_CHECK(error) \
    { PaError PA_CHECK__err = (error); if(PA_CHECK__err != paNoError) \
        { error_string = Pa_GetErrorText(PA_CHECK__err); return 0; } }

static PaStream * stream = NULL;

static int callback(const void *input, void *output, unsigned long frame_count,
                    const PaStreamCallbackTimeInfo *time_info,
                    PaStreamCallbackFlags status_flags, void *unused)
{
    mix_into((sample_t *)output, frame_count);
    return paContinue;
}

static int init()
{
    int c;
    for(c = 0; c < CHANNELS; c++) channels[c].data = NULL;

    PA_CHECK(Pa_Initialize());

    PaError err;
    err = Pa_OpenDefaultStream(&stream, 0, 2, PORTAUDIO_SAMPLE_TYPE,
                               SAMPLE_RATE, BUFFER_SIZE, callback, NULL);
    if(err != paNoError)
    {
        Pa_Terminate();
        PA_CHECK(err);
    }

    err = Pa_StartStream(stream);
    if(err != paNoError)
    {
        Pa_Terminate();
        PA_CHECK(err);
    }

    return 1;
}

static int uninit()
{
    PA_CHECK(Pa_StopStream(stream));
    PA_CHECK(Pa_CloseStream(stream));
    PA_CHECK(Pa_Terminate());

    return 1;
}

//// Lua //////////////////////////////////////////////////////////////////////

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define LUA_CHECK(L, condition, message) \
    { if(!(condition)) \
        { lua_pushnil(L); lua_pushstring(L, message); return 2; } }
#define LUA_ERROR(L, message) LUA_CHECK(L, 0, message)

static int mixer__initted = 0;

static void check_initted(lua_State *L)
{
    if(!mixer__initted) luaL_error(L, "please call mixer.init() first");
}

static int mixer__init(lua_State *L)
{
    if(!mixer__initted)
    {
        mixer__initted = init();
        LUA_CHECK(L, mixer__initted, error_string);
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int mixer__uninit(lua_State *L)
{
    if(mixer__initted)
    {
        mixer__initted = 0;
        LUA_CHECK(L, uninit(), error_string);
    }
    lua_pushboolean(L, 1);
    return 1;
}

static int generic_sound_loader(
    lua_State *L,
    sound_data_t * (*loader) (const char *filename))
{
    const char * filename = luaL_checkstring(L, 1);
    sound_data_t * sound = loader(filename);
    
    if(sound == NULL)
    {
        lua_pushnil(L);
        lua_pushstring(L, error_string);
        return 2;
    }
    else
    {
        *(sound_data_t **)lua_newuserdata(L, sizeof(sound)) = sound;
        luaL_getmetatable(L, "mixer.sound_effect");
        lua_setmetatable(L, -2);
        return 1;
    }
}

static int mixer__load_wav(lua_State *L)
{
    return generic_sound_loader(L, load_wav);
}

static int mixer__load_ogg(lua_State *L)
{
    return generic_sound_loader(L, load_ogg);
}

static int mixer__channel_fade_to(lua_State *L)
{
    check_initted(L);
    int channel = luaL_checkint(L, 1);
    float duration = luaL_checknumber(L, 2);
    float left = luaL_checknumber(L, 3);
    float right = luaL_optnumber(L, 4, left);

    luaL_argcheck(L, channel_is_valid(channel), 1, "invalid channel given");
    luaL_argcheck(L, duration >= 0, 1, "invalid duration given");

    channel_fade_to(channel, duration, left, right);

    return 0;
}

static int mixer__channel_stop(lua_State *L)
{
    check_initted(L);
    int channel = luaL_checkint(L, 1);

    luaL_argcheck(L, channel_is_valid(channel), 1, "invalid channel given");

    channel_stop(channel);

    return 0;
}

static sound_data_t * check_sound_effect(lua_State *L, int index)
{
    return *(sound_data_t **)luaL_checkudata(L, index, "mixer.sound_effect");
}

static int sound_effect__play(lua_State *L)
{
    check_initted(L);
    sound_data_t * sound = check_sound_effect(L, 1);
    float left = luaL_optnumber(L, 2, 1.0);
    float right = luaL_optnumber(L, 3, left);
    int loop = luaL_optint(L, 4, 1);

    int channel = play_sound_effect(sound, left, right, loop);

    if(channel < 0)
        lua_pushnil(L);
    else
        lua_pushnumber(L, channel);
    return 1;
}

static const luaL_reg sound_effect_lib[] =
{
    {"play", sound_effect__play},
    {NULL, NULL}
};

static const luaL_Reg mixer_lib[] =
{
    {"init", mixer__init},
    {"uninit", mixer__uninit},
    {"load_wav", mixer__load_wav},
    {"load_ogg", mixer__load_ogg},
    {"channel_fade_to", mixer__channel_fade_to},
    {"channel_stop", mixer__channel_stop},
    {NULL, NULL}
};

int luaopen_mixer(lua_State *L)
{
    lua_newuserdata(L, 0);
    lua_newtable(L);
    lua_pushcfunction(L, mixer__uninit);
    lua_setfield(L, -2, "__gc");
    lua_setmetatable(L, -2);
    lua_setfield(L, LUA_REGISTRYINDEX, "mixer.uninitializer");

    luaL_newmetatable(L, "mixer.sound_effect");
    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index");
    luaL_register(L, NULL, sound_effect_lib);

    lua_newtable(L);
    luaL_register(L, NULL, mixer_lib);
    return 1;
}

