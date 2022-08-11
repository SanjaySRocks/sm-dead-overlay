#include <sourcemod>
#include <sdktools>

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





// Overlay stock

// Precache & prepare download for overlays & decals
stock void PrecacheDecalAnyDownload(char[] sOverlay)
{
    char sBuffer[256];
    Format(sBuffer, sizeof(sBuffer), "%s.vmt", sOverlay);
    PrecacheDecal(sBuffer, true);
    Format(sBuffer, sizeof(sBuffer), "materials/%s.vmt", sOverlay);
    AddFileToDownloadsTable(sBuffer);

    Format(sBuffer, sizeof(sBuffer), "%s.vtf", sOverlay);
    PrecacheDecal(sBuffer, true);
    Format(sBuffer, sizeof(sBuffer), "materials/%s.vtf", sOverlay);
    AddFileToDownloadsTable(sBuffer);
}

// Show overlay to a client with lifetime | 0.0 = no auto remove
stock void ShowOverlay(int client, char[] path, float lifetime)
{
    if (!IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
        return;

    ClientCommand(client, "r_screenoverlay \"%s.vtf\"", path);

    if (lifetime != 0.0)
        CreateTimer(lifetime, DeleteOverlay, GetClientUserId(client));
}

// Show overlay to all clients with lifetime | 0.0 = no auto remove
stock void ShowOverlayAll(char[] path, float lifetime)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || IsFakeClient(i) || IsClientSourceTV(i) || IsClientReplay(i))
            continue;

        ClientCommand(i, "r_screenoverlay \"%s.vtf\"", path);

        if (lifetime != 0.0)
            CreateTimer(lifetime, DeleteOverlay, GetClientUserId(i));
    }
}

// Remove overlay from a client - Timer!
stock Action DeleteOverlay(Handle timer, any userid) 
{
    int client = GetClientOfUserId(userid);
    if (client <= 0 || !IsClientInGame(client) || IsFakeClient(client) || IsClientSourceTV(client) || IsClientReplay(client))
        return;

    ClientCommand(client, "r_screenoverlay \"\"");
}