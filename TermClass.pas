unit TermClass;

interface

uses Windows, Classes, SysUtils, TextUtils, PlugInterface, mccontroller;

type

  TPluginObject = class
    public
      Plugin  : IPlugin;
      Handle  : THandle;
      FileName: string;
      Name    : shortstring;
      Desc    : shortstring;
      Enabled: boolean;
      Commands: array of shortstring;
      constructor Create;
      destructor Destroy; override;
  end;

  TTerm = class(TInterfacedObject, IPluginService)
  private
    //---------------------
    CurDir : string;
    PluginDir : string;
    PluginsList : TList;
    //---------------------
    function IndexOfHandle(H:THandle):integer;
    function IndexOfCommand(Cmd:shortstring):integer;
    //---------------------
    procedure OnPluginMessage(var PlugMsg: string); stdcall;
    procedure AddCommand(Handle:THandle; var Cmd:string); stdcall;
    procedure RemoveCommand(Handle:THandle; var Cmd:string);
    //---------------------
  public
    //---------------------
    function GetCDir : String;
    procedure ListCommands(Desc:boolean = false);
    function GetCmd:string;
    procedure ParseCmd(var Cmnd:string; out Params : TArgs);
    procedure Exec(Cmd:string; Params:TArgs);
    procedure ReturnCDir(var Dir:string);
    function ExitPrompt:string;
    //---------------------
    procedure LoadPlugins;
    procedure LoadPlugin(FileName:string);
    procedure UnLoadPlugin(Index:integer);
    //---------------------
    procedure BeforeDestruction; override;
    constructor Create;
    destructor Destroy; override;
    //---------------------
  end;

implementation

constructor TPluginObject.Create;
begin
  Plugin  := nil;
  Handle  := 0;
  Name    := '';
  FileName:= '';
  Desc    := '';
  SetLength(Commands, 0);
end;

destructor TPluginObject.Destroy;
begin
  Plugin := nil;
  if Handle <> 0 then
  begin
    FreeLibrary(Handle);
    Handle := 0;
  end;
  SetLength(Commands, 0);
  SetLength(FileName, 0);
  inherited;
end;

constructor TTerm.Create;
begin
  inherited;
  CurDir := ExtractFilePath(ParamStr(0));
  PluginDir := ExtractFilePath(ParamStr(0))+'\Plugins\';
  PluginsList := TList.Create;
  self._AddRef;
end;

procedure TTerm.BeforeDestruction;
var
  i : integer;
begin
  for i := PluginsList.Count -1 downto 0 do
    if PluginsList.Items[i]<> nil then
      begin
        UnloadPlugin(i);
      end;
      self.FRefCount := self.FRefCount - 1;
  inherited;
end;

destructor TTerm.Destroy;
begin
  PluginsList.Free;
  inherited;
end;

function TTerm.IndexOfHandle(H:THandle):integer;
var i:integer;
begin
  Result:=-1;
  for i:=0 to PluginsList.Count-1 do
    if TPluginObject(PluginsList.Items[i]).Handle=H then
      begin
        Result:=i;
        Break;
      end;
end;

function TTerm.IndexOfCommand(Cmd:shortstring):integer;
var i, j:integer;
begin
  Result:=-1;
  if Cmd='' then
    Exit;
  for i:=0 to PluginsList.Count-1 do
    for j:=0 to Length(TPluginObject(PluginsList.Items[i]).Commands)-1 do
      if TPluginObject(PluginsList.Items[i]).Commands[j]=Cmd then
        begin
          Result:=i;
          Break;
        end;
end;

procedure TTerm.OnPluginMessage(var PlugMsg: string);
begin
  // Do OnPluginMessage
end;

procedure TTerm.AddCommand(Handle:THandle; var Cmd:string);
var i:integer;
begin
  i:=IndexOfHandle(Handle);
  if i<>-1 then
    begin
      SetLength(TPluginObject(PluginsList.Items[i]).Commands, Length(TPluginObject(PluginsList.Items[i]).Commands)+1);
      TPluginObject(PluginsList.Items[i]).Commands[High(TPluginObject(PluginsList.Items[i]).Commands)]:=Cmd;
    end;
end;

procedure TTerm.RemoveCommand(Handle:THandle; var Cmd:string);
var i, j, k:integer;
begin
  k:=MAXINT;
  i:=IndexOfHandle(Handle);
  if i<>-1 then
    begin
      for j:=0 to Length(TPluginObject(PluginsList.Items[i]).Commands)-1 do
        if TPluginObject(PluginsList.Items[i]).Commands[j]=Cmd then
          k:=j;
      for j:=k to Length(TPluginObject(PluginsList.Items[i]).Commands)-2 do
        TPluginObject(PluginsList.Items[i]).Commands[j]:=TPluginObject(PluginsList.Items[i]).Commands[j+1];
      SetLength(TPluginObject(PluginsList.Items[i]).Commands, Length(TPluginObject(PluginsList.Items[i]).Commands)-1);
    end;
end;

procedure TTerm.ReturnCDir(var Dir: string);
begin
  Dir:=CurDir;
end;

procedure TTerm.Exec(Cmd:string; Params:TArgs);
var i:integer;
begin
  if Cmd='' then
    Exit;
  if (Cmd='set') then
    begin
      //Settings.SetLogin;
      TextOut('[STUB]', tucRed);
      TextOut(' Типа изменились настройки...', true, tucYellow);
      Exit;
    end;
  if (Cmd='login') then
    begin
      //Settings.SetLogin;
      if Length(Params)<>2 then
        begin
          TextOut('Неверное количество параметров! Введите help -d для помощи.', true, tucRed);
          Exit;
        end;
      TextOut('[STUB]', tucRed);
      TextOut(' Типа логинится...', true, tucYellow);
      TextOut(MCLogin(Params), true);
      Exit;
    end;
  if (Cmd='launch')or(Cmd='run')or(Cmd='play') then
    begin
      //MC.Run;
      TextOut('[STUB]', tucRed);
      TextOut(' Типа запускается...', true, tucYellow);
      Exit;
    end;
  if (Cmd='help') then
    begin
      ListCommands(HasParam(Params, '-d'));
      Exit;
    end;
  if Cmd='jopa' then
    begin
      TextOut('(_O_)', true, tucRed);
      Exit;
    end;
  i:=IndexOfCommand(Cmd);
  if i<>-1 then
    begin
      TPluginObject(PluginsList.Items[i]).Plugin.Command(Cmd, Params);
    end
  else
    TextOut('Неизвестная команда '''+Cmd+'''! Введите help для справки.', true, tucRed);
end;

function TTerm.ExitPrompt: string;
var s:string;
begin
  TextOut('Вы действительно хотите выйти? (Y(Д)/n(н)): ', tucYellow);
  TextOut('');
  Readln(s);
  if (s='')or(s[1] in ['Y', 'y', 'Д', 'д']) then
    Result:='exit';
end;

function TTerm.GetCDir:string;
begin
  Result := CurDir;
end;

procedure TTerm.ListCommands(Desc:boolean = false);
var i, j:integer;
begin
  TextOut('Список команд:', true);
  TextOut('', true);
  TextOut('Основные', true);
  TextOut('Дополнительные', true, tucDkGreen);
  TextOut('', true);
  if Desc then
    begin
      TextOut('help [-d]'+#9#9#9+' - Помощь', true);
      TextOut('set <setting>'+#9#9#9+' - Изменить настройку', true);
      TextOut('login [<user>] [<password>]'+#9+' - Войти', true);
      TextOut('launch'+#9#9#9#9+' - Запуск', true);
      TextOut('quit, exit'+#9#9#9+' - Выход', true);
      for i := 0 to PluginsList.Count-1 do
        for j := 0 to High(TPluginObject(PluginsList.Items[i]).Commands) do
          begin
            TextOut(TPluginObject(PluginsList.Items[i]).Commands[j], false, tucDkGreen);
            TextOut(#9 +' - ' + TPluginObject(PluginsList.Items[i]).Name + ' - ' + TPluginObject(PluginsList.Items[i]).Desc, true);
          end;
    end
  else
    begin
      TextOut('help', true);
      TextOut('set', true);
      TextOut('login', true);
      TextOut('launch, play, run', true);
      TextOut('exit, quit', true);
      for i := 0 to PluginsList.Count-1 do
        for j := 0 to High(TPluginObject(PluginsList.Items[i]).Commands) do
          TextOut(TPluginObject(PluginsList.Items[i]).Commands[j], true, tucDkGreen);
    end;
  TextOut('', true);
end;

procedure TTerm.LoadPlugins;
var FS : TSearchRec;
    CreatePlugin : function(PluginService: IPluginService): IPlugin; stdcall;
    Hnd : Cardinal;
begin
  If FindFirst(PluginDir+'*.mcp', faAnyFile, FS)=0 Then
    repeat
      Hnd := LoadLibrary(PChar(PluginDir+FS.Name));
      @CreatePlugin := GetProcAddress(Hnd, 'CreateMCCLIPlugin');
      if (@CreatePlugin<>nil) Then
        begin
          LoadPlugin(String(FS.Name));
        end
      else
        begin
          @CreatePlugin := nil;
          FreeLibrary(Hnd);
        end;
    until(FindNext(FS)<>0);
end;

function TTerm.GetCmd:string;
begin
  TextOut('~: ', tucWhite);
  Readln(Result);
end;

procedure TTerm.ParseCmd(var Cmnd:string; out Params : TArgs);
var s:string;
begin
  SetLength(Params, 0);
  Cmnd:=Trim(Cmnd);
  if Cmnd='' then
    Exit;

  if Pos(' ', Cmnd)>0 then
    begin
      s:=Copy(Cmnd, Pos(' ', Cmnd)+1);
      Delete(Cmnd, Pos(' ', Cmnd)+1, Length(Cmnd));
      Params := Explode(s);
    end;
  Cmnd := Trim(Cmnd);
end;

procedure TTerm.LoadPlugin(FileName: string);
var
  CreatePlugin : function(PluginService: IPluginService): IPlugin; stdcall;
  ND : function : shortstring; stdcall;
  R:integer;
begin
    R := PluginsList.Add(TPluginObject.Create());
    TPluginObject(PluginsList.Items[R]).Handle := LoadLibrary(PChar(PluginDir + FileName));
    if TPluginObject(PluginsList.Items[R]).Handle <> 0 then
    begin
      @CreatePlugin:=GetProcAddress(TPluginObject(PluginsList.Items[R]).Handle,'CreateWTermPlugin');
      if (@CreatePlugin <> nil)then
      begin
        TPluginObject(PluginsList.Items[R]).Plugin := CreatePlugin(Self);
        if (TPluginObject(PluginsList.Items[R]).Plugin <> nil)and(TPluginObject(PluginsList.Items[R]).Plugin.Init(TPluginObject(PluginsList.Items[R]).Handle)=1) then
          begin
            TPluginObject(PluginsList.Items[R]).FileName:=FileName;
            @ND := GetProcAddress(TPluginObject(PluginsList.Items[R]).Handle,'GetName');
            if (@ND<>nil)then
              TPluginObject(PluginsList.Items[R]).Name:=ND
            else
              TPluginObject(PluginsList.Items[R]).Name:=FileName;
            @ND := GetProcAddress(TPluginObject(PluginsList.Items[R]).Handle,'GetDesc');
            if (@ND<>nil)then
              TPluginObject(PluginsList.Items[R]).Desc:=ND
            else
                TPluginObject(PluginsList.Items[R]).Desc:='';
            Exit;
          end;
      end;
    end;
    UnloadPlugin(R);
end;

procedure TTerm.UnloadPlugin(Index:Integer);
begin
if (Index < 0) or (Index >= PluginsList.Count) then
    Exit;
  TPluginObject(PluginsList[Index]).Free;
  PluginsList[Index] := nil;
  PluginsList.Delete(Index);
end;

end.
