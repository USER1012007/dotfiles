/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 0;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int user_bh            = 3;        /* 2 is the default spacing around the bar's font */
static const char *fonts[]          = { "monospace:size=12" };
static const char dmenufont[]       = "monospace:size=13";
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
static const char col_purple[]	    = "#5e0890";
static const char col_white[]	    = "#FFFFFF";
static const char col_black[]	    = "#000000";

static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_white, col_gray1, col_purple },
	[SchemeSel]  = { col_white, col_cyan,  col_purple },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "firefox",  NULL,       NULL,       1 << 8,       1,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *dmenucmd[] = { "dmenu_run", "-fn", dmenufont, "-nb", col_gray1, "-nf", col_white, "-sb", col_cyan, "-sf", col_white, NULL };
static const char *termcmd[]  = { "st", NULL };

static const char *up_vol[]   = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%",   NULL };
static const char *down_vol[] = { "pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%",   NULL };
static const char *mute_vol[] = { "pactl", "set-sink-mute",   "@DEFAULT_SINK@", "toggle", NULL };

static const char *medplaypausecmd[] = { "playerctl", "play-pause", NULL };
static const char *mednextcmd[] = { "playerctl", "next", NULL };
static const char *medprevcmd[] = { "playerctl", "previous", NULL };

/*pipewire
static const char *upvol[]      = { "wpctl",   "set-volume", "-l",	"1.5",     "@DEFAULT_AUDIO_SINK@",    "10%+"};
static const char *downvol[]    = { "wpctl",   "set-volume", "@DEFAULT_AUDIO_SINK@",      "10%-",      NULL };
static const char *mutevol[]    = { "wpctl",   "set-mute",   "@DEFAULT_AUDIO_SOURCE@",      "toggle",   NULL };
*/

static const char *brighter[] = { "brightnessctl", "set", "10%+", NULL };
static const char *dimmer[]   = { "brightnessctl", "set", "10%-", NULL };

static const char *redshift[] = { "redshift", "-O", "4500", NULL };
static const char *redshiftback[] = { "redshift", "-x", NULL };

static const char *keyboarden[] = { "setxkbmap", "-layout", "us", NULL };
static const char *keyboardes[] = { "setxkbmap", "-layout", "es", NULL };

static const char *xsecurelock[] = { "xsecurelock", NULL };

static const char *color_hex[] = { "zenity", "--color-selection", NULL };

#include <X11/XF86keysym.h>
#include "exitdwm.c"

static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
  { MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	/*{ MODKEY,                       XK_space,  setlayout,      {0} }, */
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
	{ MODKEY|ShiftMask,             XK_e,      exitdwm,        {0} },
    { MODKEY|ControlMask|ShiftMask, XK_q,      quit,           {1} },

    { 0, XF86XK_AudioMute,              spawn, {.v = mute_vol } },
    { 0, XF86XK_AudioLowerVolume,       spawn, {.v = down_vol } },
    { 0, XF86XK_AudioRaiseVolume,       spawn, {.v = up_vol   } },
/*
    { 0, XF86XK_AudioMute,              spawn, {.v = mutevol } },
    { 0, XF86XK_AudioLowerVolume,       spawn, {.v = downvol } },
    { 0, XF86XK_AudioRaiseVolume,       spawn, {.v = upvol } },
*/
    { 0, XF86XK_AudioPlay, 	            spawn, {.v = medplaypausecmd } },
    { 0, XF86XK_AudioNext, 	            spawn, {.v = mednextcmd } },
    { 0, XF86XK_AudioPrev,	            spawn, {.v = medprevcmd } },

    { 0, XF86XK_MonBrightnessDown,      spawn, {.v = dimmer } },
    { 0, XF86XK_MonBrightnessUp,        spawn, {.v = brighter } },

    { 0,         XK_Print,	            spawn, SHCMD("/usr/local/bin/screenshot.sh") },
    { ShiftMask, XK_Print,	            spawn, SHCMD("/usr/local/bin/screenshot.sh -s") },

    { MODKEY,             XK_Print,	            spawn, SHCMD("/usr/local/bin/screen_clipb.sh") },
    { Mod4Mask, XK_Print,	            spawn, SHCMD("/usr/local/bin/screen_clipb.sh -s") },

    { ControlMask|ShiftMask, XK_Return, spawn, {.v = redshift} },
    { ControlMask,     	     XK_Return, spawn, {.v = redshiftback} },
    { MODKEY,                XK_space,  spawn, {.v =  keyboarden} },
    { Mod4Mask,              XK_space,  spawn, {.v =  keyboardes} },
    { MODKEY|ShiftMask,      XK_l,      spawn, {.v = xsecurelock} },

    { MODKEY,                XK_r,      spawn, {.v = color_hex} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	// { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	// { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	// { ClkTagBar,            0,              Button1,        view,           {0} },
	// { ClkTagBar,            0,              Button3,        toggleview,     {0} },
	// { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	// { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

