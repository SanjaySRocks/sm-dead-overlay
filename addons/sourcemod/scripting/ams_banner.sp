#include <sourcemod>
#include <sdktools>
#include <overlays>

#pragma newdecls required

ConVar gCvarEnable;
ConVar gCvarIcon;
char BufferBanner[128];

public Plugin myinfo = {
    name        = "CSGO: Dead Overlay",
    author      = "skyin",
    description = "Display overlay banner to player screen when they are dead",
    version     = "1.1.2",
    url         = "http://github.com/sanjaysrocks"
};

public void OnPluginStart(){

    gCvarEnable = CreateConVar("ams_banner_enable", "1", "1/0 - Enable/Disable this plugin");
    gCvarIcon = CreateConVar("ams_banner_file", "amsgamers/icon", "file path of .vmt or .vtf file without extension excluding materials from path");
    
    HookEvent("player_death", PlayerDeath) // Hook Player Death
    HookEvent("player_spawn", PlayerSpawn) // Hook Player Death

    gCvarIcon.GetString(BufferBanner, sizeof(BufferBanner));

    AutoExecConfig(true);
}


public void OnMapStart()
{
    PrecacheDecalAnyDownload(BufferBanner);
}


public Action PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
    int iEnable = GetConVarInt(gCvarEnable);

    if(!iEnable)
        return;

    int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get Player's userid
    
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
        return;

    ClientCommand(client, "r_screenoverlay \"\"");
}


public Action PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{  
    int iEnable = GetConVarInt(gCvarEnable);

    if(!iEnable)
        return;

    int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get Player's userid
    ShowOverlay(client, BufferBanner, 0.0);
}
