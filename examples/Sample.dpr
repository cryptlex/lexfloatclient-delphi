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
  HostProductId: UnicodeString = 'PASTE_PRODUCT_ID';
  HostUrl: UnicodeString = 'http://localhost:8090';

procedure LicenseRenewCallback(const Error: Exception);
begin
  // No synchronization, write everything to console
  WriteLn;
  if Assigned(Error) then
  begin
    WriteLn('Asynchronous exception: ',
      ScopedClassName(Error.ClassType));
    WriteLn(Error.Message);
  end else begin
    WriteLn('Asynchronous success');
  end;
end;

procedure Main;
var
  Step: string;
begin
  try
    Step := 'SetHostProductId';
    SetHostProductId(HostProductId);
    Step := 'SetHostUrl'; SetHostUrl(HostUrl);
    Step := 'SetFloatingLicenseCallback';
    // console application has no message loop, thus Synchronized is False
    SetFloatingLicenseCallback(LicenseRenewCallback, False);
    try
      Step := 'RequestFloatingLicense'; RequestFloatingLicense; WriteLn;
	    Write('Success! License Acquired. Press Enter to continue...'); ReadLn;
      try
        WriteLn;
        WriteLn('Metadata: ', GetHostLicenseMetadata('key1'));
      except
        on E: Exception do
        begin
          WriteLn;
          WriteLn('Exception from GetHostLicenseMetadata key1: ', ScopedClassName(E.ClassType));
          WriteLn(E.Message);
        end;
      end;
      Write('Press Enter to drop the license...'); ReadLn;
      Step := 'DropFloatingLicense'; DropFloatingLicense;
      WriteLn;
      WriteLn('Success! License dropped.');
      Step := 'ResetFloatingLicenseCallback';
    finally
      ResetFloatingLicenseCallback;
    end;
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

