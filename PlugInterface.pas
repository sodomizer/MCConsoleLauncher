unit PlugInterface;

interface

uses TextUtils;

type

  IPluginService = interface
  ['{013527B3-7805-40CF-B0D4-CE81E7199CA6}']
    procedure OnPluginMessage(var PlugMsg: string); stdcall;
    procedure AddCommand(Handle:THandle; var Cmd:string); stdcall;
    procedure RemoveCommand(Handle:THandle; var Cmd:string);
    procedure ReturnCDir(var Dir:string);
  end;
  pIPluginService = ^IPluginService;

  IPlugin = interface
  ['{338C3E89-092A-4E51-91E8-64C4D62907CB}']
    function Init(Handle:THandle) : integer; stdcall;
    procedure UnInit; stdcall;
    function Command(var Cmd:string; Params:TArgs):boolean; stdcall;
    //function OnBeforeLogin...
    //function OnAfterLogin...
    //function OnBeforeLaunch...
    //function OnAfterLaunch...
    //function OnAfterGameExit...
    //function OnPluginEvent...
  end;
  pIPlugin = ^IPlugin;

implementation

end.
