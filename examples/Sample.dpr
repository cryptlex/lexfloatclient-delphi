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
  LexFloatClient,
  LexFloatClient.DelphiFeatures;

function ScopedClassName(Item: TClass): string;
var
  UnitName: string;
begin
  UnitName := TClass_UnitName(Item);
  if UnitName <> '' then
    Result := UnitName + '.' + Item.ClassName else Result := Item.ClassName;
end;

const
  ProductId: UnicodeString = 'PASTE_PRODUCT_ID';
  LexFloatServerHost: UnicodeString = 'localhost';

procedure OnLexFloatClient(const Sender: ILFHandle;
  const Error: Exception; Event: TLFCallbackEvent);
begin
  // No synchronization, write everything to console
  WriteLn;
  if Assigned(Error) then
  begin
    WriteLn('Asynchronous exception from ', LFCallbackEventToString(Event), ': ',
      ScopedClassName(Error.ClassType));
    WriteLn(Error.Message);
  end else begin
    WriteLn('Asynchronous success from ', LFCallbackEventToString(Event));
  end;
end;

procedure Main;
// Early Delphi versions missed finalization for global variables
var
  Handle: ILFHandle;
  Step: string;
begin
  try
    Step := 'LFGetHandle';
    Handle := LFGetHandle(ProductId);
    Step := 'SetFloatServer'; Handle.SetFloatServer(LexFloatServerHost, 8090);
    Step := 'SetLicenseCallback';
    // console application has no message loop, thus Synchronized is False
    Handle.SetLicenseCallback(OnLexFloatClient, False);
    Step := 'RequestLicense'; Handle.RequestLicense; WriteLn;
	  Write('Success! License Acquired. Press Enter to continue...'); ReadLn;
    try
      WriteLn;
      WriteLn('Metadata: ', Handle.LicenseMetadata['key1']);
    except
      on E: Exception do
      begin
        WriteLn;
        WriteLn('Exception from GetLicenseMetadata key1: ', ScopedClassName(E.ClassType));
        WriteLn(E.Message);
      end;
    end;
    Write('Press Enter to drop the license...'); ReadLn;
    Handle := nil; WriteLn; // drop license
    WriteLn('Success! License dropped.');
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

