/* Plugin Template generated by Pawn Studio */

#include <sourcemod>

#define CURRENT_VERSION "1.1"

public Plugin:myinfo = 
{
	name = "Plugin Categories",
	author = "necavi",
	description = "A replacement for sm plugins list that supports categories.",
	version = CURRENT_VERSION,
	url = "http://necavi.com"
}

new Handle:g_hPluginCat = INVALID_HANDLE;
new Handle:g_hPlugins = INVALID_HANDLE;
new Handle:g_hCvarEnabled = INVALID_HANDLE;
public OnPluginStart()
{
	g_hPluginCat = CreateArray(16);
	g_hPlugins = CreateArray(8);
	RegConsoleCmd("sm_plugins_list",Command_PluginList);
	RegConsoleCmd("sm_list_categories",Command_ListCategories);
	g_hCvarEnabled = CreateConVar("plugincats_enabled","1.0","Enables or disables the commands related to plugin categories",FCVAR_PLUGIN,true,0.0,true,1.0);
	CreateConVar("plugincats_version", CURRENT_VERSION, "Current plugin category version", FCVAR_NOTIFY);
}
GetPluginCategory(Handle:plugin,String:category[],size)
{
	GetArrayString(g_hPluginCat,FindValueInArray(g_hPlugins,plugin),category,size);
}
public Action:Command_PluginList(client,args)
{
	if(!GetConVarBool(g_hCvarEnabled))
		return Plugin_Continue;
	BuildPluginList();
	new Handle:iterator = GetPluginIterator();
	new Handle:plugin = INVALID_HANDLE;
	new String:reply[1400];
	decl String:name[256];
	decl String:author[32];
	decl String:version[16];
	decl String:category[16];
	decl String:cat[16];
	new PluginStatus:pluginstatus;
	new iter = 0;
	strcopy(cat,sizeof(cat),"all");
	if(args==1)
		GetCmdArg(1,cat,sizeof(cat));
	while(MorePlugins(iterator))
	{
		if(strlen(reply)>=1200)
		{
			PrintToConsole(client,reply);
			strcopy(reply,sizeof(reply),"");
		}
		plugin = ReadPlugin(iterator);
		GetPluginCategory(plugin,category,sizeof(category))
		if(strcmp(cat,"all")==0||strcmp(category,cat,false)==0)
		{
			
			iter+=1;
			GetPluginInfo(plugin,PlInfo_Name,name,sizeof(name));
			GetPluginInfo(plugin,PlInfo_Version,version,sizeof(version));
			GetPluginInfo(plugin,PlInfo_Author,author,sizeof(author));
			pluginstatus = GetPluginStatus(plugin);
			if(pluginstatus!=Plugin_Running)
			{
				decl String:status[16];
				GetStatusText(pluginstatus,status,sizeof(status));
				Format(reply,sizeof(reply),"%s%02d <%s> %s (%s) by %s\n",reply,iter,status,name,version,author);
			} else {
				Format(reply,sizeof(reply),"%s%02d %s (%s) by %s\n",reply,iter,name,version,author);
			}
		}
	}
	PrintToConsole(client,reply);
	return Plugin_Handled;
}
public Native_SetPluginCategory(Handle:plugin,numParams)
{	
	decl String:category[16];
	GetNativeString(2,category,sizeof(category));
	SetArrayString(g_hPluginCat,FindValueInArray(g_hPlugins,GetNativeCell(1)),category)
}
public Action:Command_ListCategories(client,args)
{
	if(!GetConVarBool(g_hCvarEnabled))
	{
		return Plugin_Continue;
	}
	BuildPluginList();
	new String:categories[32][16];
	decl String:current[16];
	new index = 0;
	new bool:found = false;
	for(new i;i<GetArraySize(g_hPluginCat);i++)
	{
		GetArrayString(g_hPluginCat,i,current,sizeof(current));
		for(new j;j<index;j++)
		{
			if(strcmp(categories[j],current,false)==0)
			{
				found = true;
				break;
			}
		}
		if(!found)
		{
			strcopy(categories[index],sizeof(categories[]),current);
			index++;
		}
		found = false;
	}
	new String:reply[512];
	strcopy(reply,sizeof(reply),"Current Categories: ");
	for(new i = 0; i < index; i++)
	{
		Format(reply, sizeof(reply), "%s%s, ", reply, categories[i]);
	}
	Format(reply, sizeof(reply), "%sall", reply)
	PrintToConsole(client, reply);
	return Plugin_Handled;
}
GetStatusText(PluginStatus:status, String:value[], maxsize)
{
	switch (status)
	{
		case Plugin_Running:
		{
			strcopy(value, maxsize, "Running");
		}
		case Plugin_Paused:
		{
			strcopy(value, maxsize, "Paused");
		}
		case Plugin_Error:
		{
			strcopy(value, maxsize, "Error");
		}
		case Plugin_Uncompiled:
		{
			strcopy(value, maxsize, "Uncompiled");
		}
		case Plugin_BadLoad:
		{
			strcopy(value, maxsize, "Bad Load");
		}
		case Plugin_Failed:
		{
			strcopy(value, maxsize, "Failed");
		}
		default:
		{
			strcopy(value, maxsize, "-");
		}
	}
}
BuildPluginList()
{
	ClearArray(g_hPlugins);
	ClearArray(g_hPluginCat);
	new Handle:plugin = INVALID_HANDLE;
	new Handle:iter = GetPluginIterator();
	new String:file[PLATFORM_MAX_PATH];
	new String:category[16];
	while(MorePlugins(iter))
	{
		plugin = ReadPlugin(iter);
		GetPluginFilename(plugin, file, sizeof(file));
		if(SplitString(file, "/", category, sizeof(category)) != -1)
		{
			PushArrayString(g_hPluginCat, category);
		}
		else
		{
			PushArrayString(g_hPluginCat, "misc");	
			PushArrayCell(g_hPlugins, plugin);	
		}
	}
	CloseHandle(iter);
}