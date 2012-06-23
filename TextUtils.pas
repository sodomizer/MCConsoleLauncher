unit TextUtils;

interface

uses Windows, StrUtils;

const
  tucBlack = 0;
  tucDkBlue = 1;
  tucDkGreen = 2;
  tucDkCyan = 3;
  tucDkRed  = 4;
  tucDkPink  = 5;
  tucDkYellow  = 6;
  tucDkWhite  = 7;
  tucGray  = 8;
  tucBlue  = 9;
  tucGreen  = 10;
  tucCyan = 11;
  tucRed  = 12;
  tucPink  = 13;
  tucYellow = 14;
  tucWhite = 15;

type

  TArgs = array of string;

procedure TextOut(Text : string); overload;
procedure TextOut(Text : string; Color: byte); overload;
procedure TextOut(Text : string; NewLine : boolean; Color: byte = tucWhite); overload;
function Explode(sText:string):TArgs;
function HasParam(arg:TArgs; par:string):boolean;

implementation

procedure TextOut(Text : string);
var p:PAnsiChar;
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), tucWhite);
  GetMem(p, Length(Text));
  CharToOem(PWideChar(Text), p);
  Write(p);
  FreeMem(p);
end;

procedure TextOut(Text : string; Color: byte);
var p:PAnsiChar;
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Color);
  GetMem(p, Length(Text));
  CharToOem(PWideChar(Text), p);
  Write(p);
  FreeMem(p);
end;

procedure TextOut(Text : string; NewLine : boolean; Color: byte = tucWhite);
var p:PAnsiChar;
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), Color);
  GetMem(p, Length(Text));
  CharToOem(PWideChar(Text), p);
  if NewLine then
    Writeln(p)
  else
    Write(p);
  FreeMem(p);
end;

function Explode(sText: string):TArgs;
var
  i:integer;
  ps, pc:boolean;
  buf:shortstring;
begin
  ps:=true;
  SetLength(Result, 0);
  buf:='';
  for i:=1 to Length(sText) do
    begin
      if not(sText[i] in [' ', '"']) then
        begin
          buf:=buf+sText[i];
          ps:=false;
        end
      else
        if sText[i]=' ' then
          if pc then
            buf:=buf+sText[i]
          else
            begin
              SetLength(Result, Length(Result)+1);
              Result[High(Result)]:=buf;
              buf:='';
              ps:=true;
            end
        else
          if ps then
            begin
              ps:=false;
              pc:=true;
            end
          else
            if pc then
              pc:=false
            else
              buf:=buf+sText[i];
      if (i=Length(sText))and(buf<>'') then
        begin
          SetLength(Result, Length(Result)+1);
          Result[High(Result)]:=buf;
        end;
    end;
end;

function HasParam(arg:TArgs; par:string):boolean;
var s:string;
begin
  Result:=false;
  for s in arg do
    if s=par then
      begin
        Result:=true;
        Break;
      end;
end;

end.
