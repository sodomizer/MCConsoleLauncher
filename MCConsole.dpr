program MCConsole;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  StrUtils,
  Windows,
  Graphics,
  ShellAPI,
  TermClass in 'TermClass.pas',
  TextUtils in 'TextUtils.pas',
  PlugInterface in 'PlugInterface.pas',
  MCController in 'MCController.pas';

var Cmnd:String;
    Params:TArgs;
    Term : TTerm;

begin
  Term := TTerm.Create;
  Term.LoadPlugins;

  SetConsoleCP(866);
  SetConsoleOutputCP(866);
  SetCurrentDirectory(PChar(Term.GetCDir));

  TextOut('MC Console Launcher. ¬ведите help [-d] дл€ вывода доступных команд.', true, tucYellow);
  try
    repeat

      Cmnd:=Term.GetCmd;
      Term.ParseCmd(Cmnd, Params);

      if (Cmnd<>'quit')and(Cmnd<>'exit') then
        Term.Exec(Cmnd, Params)
      else
        cmnd:=Term.ExitPrompt;

    until (Cmnd='quit')or(Cmnd='exit');
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
