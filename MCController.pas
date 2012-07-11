unit MCController;

interface

uses IdHTTP, Classes, TextUtils, Sysutils;

function mcLogin(params:TArgs):string;

type

  TConsoleController = class
  public
   // function Login(Params:TArgs):string;
   // function Run(Params:TArgs):string;
  end;

implementation

function mcLogin(params:TArgs):string;
var n:integer;
    par:TStringList;
    HTTP:TIdHTTP;
begin
  HTTP:=TIdHTTP.Create(nil);
  par:=TStringList.Create;
  par.Add('user='+params[0]);
  par.Add('password='+params[1]);
  par.Add('version=13');
  Result:=HTTP.Post('http://example.com/auth.php', par);

  //Antibruteforce
  if Pos(':', Result)=0 then
    Sleep(3000);
  par.Free;
  HTTP.Free;
end;

end.
