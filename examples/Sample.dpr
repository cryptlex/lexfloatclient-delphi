program Sample;

{$APPTYPE CONSOLE}

{$IF CompilerVersion >= 23.0}
  {$DEFINE DELPHI_UNITS_SCOPED}
{$IFEND}

uses
{$IFDEF DELPHI_UNITS_SCOPED}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}
  LexFloatClient in 'LexFloatClient.pas',
  LexFloatClient.DelphiFeatures in 'LexFloatClient.DelphiFeatures.pas';

function ScopedClassName(Item: TClass): string;
var
  UnitName: string;
begin
  UnitName := TClass_UnitName(Item);
  if UnitName <> '' then
    Result := UnitName + '.' + Item.ClassName else Result := Item.ClassName;
end;

type
  TSimpleCallback = class
    class procedure Execute(const Sender: ILFHandle;
      const Error: Exception; Event: TLFCallbackEvent);
  end;

class procedure TSimpleCallback.Execute(const Sender: ILFHandle;
  const Error: Exception; Event: TLFCallbackEvent);
begin
  WriteLn;
  WriteLn('Exception from ', LFCallbackEventToString(Event), ': ',
    ScopedClassName(Error.ClassType));
  WriteLn(Error.Message);
end;

const
  LexFloatServerHost = 'localhost';

procedure Main;
// Early Delphi versions missed finalization for global variables
var
  Handle: ILFHandle;
  Step: string;
begin
  try
    Step := 'SetProductFile'; SetProductFile('Product.dat');
    Step := 'GetHandle';
    Handle := GetHandle('1EEBD7A6-7691-6E91-4524-7B7E68EF5F8B');
    Step := 'SetFloatServer'; Handle.SetFloatServer(LexFloatServerHost, 8090);
    Step := 'SetLicenseCallback';
    Handle.SetLicenseCallback(TSimpleCallback.Execute);
    Step := 'RequestLicense'; Handle.RequestLicense; WriteLn;
	  Write('Success! License Acquired. Press Enter to continue...'); ReadLn;
    try
      WriteLn(#13#10, 'Custom Field Value: ', Handle.CustomLicenseField['300']);
    except
      on E: Exception do
      begin
        WriteLn;
        WriteLn('Exception from GetCustomLicenseField 300: ', ScopedClassName(E.ClassType));
        WriteLn(E.Message);
      end;
    end;
    Write('Press Enter to continue...'); ReadLn;
    try
      WriteLn(#13#10, 'Custom Field Value: ', Handle.CustomLicenseField['301']);
    except
      on E: Exception do
      begin
        WriteLn;
        WriteLn('Exception from GetCustomLicenseField 301: ', ScopedClassName(E.ClassType));
        WriteLn(E.Message);
      end;
    end;
    Write('Press Enter to continue...'); ReadLn;
    try
      WriteLn(#13#10, 'Custom Field Value: ', Handle.CustomLicenseField['302']);
    except
      on E: Exception do
      begin
        WriteLn;
        WriteLn('Exception from GetCustomLicenseField 302: ', ScopedClassName(E.ClassType));
        WriteLn(E.Message);
      end;
    end;
    Write('Press Enter to continue...'); ReadLn;
    Handle := nil; WriteLn; // drop license
    Step := 'GetHandle';
    Handle := GetHandle('1EEBD7A6-7691-6E91-4524-7B7E68EF5F8B');
    WriteLn('New Handle: ', Handle.Handle);
    Step := 'SetFloatServer';
    Handle.SetFloatServer(LexFloatServerHost, 8090);
    Step := 'SetLicenseCallback';
    Handle.SetLicenseCallback(TSimpleCallback.Execute);
    Step := 'RequestLicense'; Handle.RequestLicense; WriteLn;
	  Write('Success! License Acquired. Press Enter to continue...'); ReadLn;
    Handle := nil; WriteLn; // drop license
    Write('Press Enter to continue...'); ReadLn;
  except
    on E: Exception do
    begin
      WriteLn;
      WriteLn('Exception from ', Step, ': ', ScopedClassName(E.ClassType));
      WriteLn(E.Message);
      raise;
    end;
  end;
end;

begin
  try
    Main;
  except
    Write('Exiting on exception. Press Enter to continue...'); ReadLn;
  end;
end.

