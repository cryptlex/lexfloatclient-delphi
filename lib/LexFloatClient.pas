{$WARN UNSAFE_TYPE OFF} // PAnsiChar, PWideChar, untyped
{$WARN UNSAFE_CODE OFF} // @ operator

unit LexFloatClient;

interface

{$IF CompilerVersion >= 16.0}
  {$DEFINE DELPHI_HAS_UINT64}
{$IFEND}

{$IF CompilerVersion >= 17.0}
  {$DEFINE DELPHI_HAS_INLINE}
{$IFEND}

{$IF CompilerVersion >= 18.0}
  {$DEFINE DELPHI_CLASS_CAN_BE_ABSTRACT}
  {$DEFINE DELPHI_HAS_RECORDS}
{$IFEND}

{$IF CompilerVersion >= 20.0}
  {$DEFINE DELPHI_IS_UNICODE}
  {$DEFINE DELPHI_HAS_CLOSURES}
{$IFEND}

{$IF CompilerVersion >= 21.0}
  {$DEFINE DELPHI_HAS_RTTI}
{$IFEND}

{$IF CompilerVersion >= 23.0}
  {$DEFINE DELPHI_HAS_INTPTR}
  {$DEFINE DELPHI_UNITS_SCOPED}
{$IFEND}

uses
  LexFloatClient.DelphiFeatures,
{$IFDEF DELPHI_UNITS_SCOPED}
  System.SysUtils, Winapi.Windows
{$ELSE}
  SysUtils, Windows
{$ENDIF}
  ;

type
  TLFCallbackEvent = (leRefreshLicense, leDropLicense);

function LFCallbackEventToString(Item: TLFCallbackEvent): string;

(*
    PROCEDURE: SetProductFile()

    PURPOSE: Sets the path of the Product.dat file. This should be
    used if your application and Product.dat file are in different
    folders or you have renamed the Product.dat file.

    If this function is used, it must be called on every start of
    your program before any other functions are called.

    PARAMETERS:
    * FilePath - path of the product file (Product.dat)

    EXCEPTIONS: ELFFPathException, ELFPFileException

    NOTE: If this function fails to set the path of product file, none of the
    other functions will work.
*)

procedure SetProductFile(const FilePath: UnicodeString);

type
  ILFHandle = interface;
  TLFCallback = procedure(const Sender: ILFHandle; // Sender can be nil!
    const Error: Exception; Event: TLFCallbackEvent) of object;
  {$IFDEF DELPHI_HAS_CLOSURES}
  TLFClosure = reference to procedure(const Sender: ILFHandle; // can be nil!
    const Error: Exception; Event: TLFCallbackEvent);
  {$ENDIF}
  ILFHandle = interface(IInterface) // Delphi-only interface
  ['{FD2CDD77-EAD1-4D20-9CB4-1A7F466912D7}']
    function GetHandle: LongWord;
    function GetOwned: Boolean;
    procedure SetOwned(AOwned: Boolean);

(*
    PROCEDURE: SetFloatServer()

    PURPOSE: Sets the network address of the LexFloatServer.

    PARAMETERS:
    * HostAddress - hostname or the IP address of the LexFloatServer
    * Port - port of the LexFloatServer

    EXCEPTIONS: ELFHandleException, ELFGUIDException, ELFServerAddressException
*)

    procedure SetFloatServer(const HostAddress: UnicodeString; Port: Word);

(*
    PROCEDURE: SetLicenseCallback()

    PURPOSE: Sets refresh license error callback function.

    Whenever the lease expires, a refresh lease request is sent to the
    server. If the lease fails to refresh, refresh license callback function
    gets invoked with the following status error codes: lsLicenseExpired,
    lsLicenseExpiredInet, lsServerTime, lsTime.

    When there are no more references to ILFHandle, DropLicense is being
    invoked automatically. DropLicense might be unsuccessful, and this
    condition is being signaled via Callback too. Callback should not however
    be able to revive ILFHandle, thus Sender is nil.

    PARAMETERS:
    * Callback - name of the callback function

    EXCEPTIONS: ELFHandleException, ELFGUIDException
*)

    procedure SetLicenseCallback(Callback: TLFCallback); overload;
    {$IFDEF DELPHI_HAS_CLOSURES}
    procedure SetLicenseCallback(Callback: TLFClosure); overload;
    {$ENDIF}

(*
    PROCEDURE: RequestLicense()

    PURPOSE: Sends the request to lease the license from the LexFloatServer.

    EXCEPTIONS: ELFFailException, ELFHandleException, ELFGUIDException,
    ELFServerAddressException, ELFCallbackException, ELFLicenseExistsException,
    ELFInetException, ELFNoFreeLicenseException, ELFTimeException,
    ELFProductVersionException, ELFServerTimeException
*)

    procedure RequestLicense;

(*
    PROCEDURE: DropLicense()

    PURPOSE: Sends the request to drop the license from the LexFloatServer.

    Call this function before you exit your application to prevent zombie licenses.

    EXCEPTIONS: ELFFailException, ELFHandleException, ELFGUIDException,
    ELFServerAddressException, ELFCallbackException, ELFInetException,
    ELFTimeException, ELFServerTimeException
*)

    // procedure DropLicense;
    // called automatically after last reference has been released
    // exceptions are being handled by Callback (Sender is nil)

(*
    PROPERTY: HasLicense

    PURPOSE: Checks whether any license has been leased or not. If yes,
    it retuns LF_OK.

    RESULT: True, False

    EXCEPTIONS: ELFHandleException, ELFGUIDException, ELFServerAddressException,
    ELFCallbackException
*)

    function GetHasLicense: Boolean;

(*
    FUNCTION: GetCustomLicenseField()

    PURPOSE: Get the value of the custom field associated with the float server key.

    PARAMETERS:
    * FieldId - id of the custom field whose value you want to get

    EXCEPTIONS: ELFHandle, ELFGUIDExcpetion, ELFServerAddress, ELFCallback,
    ELFBufferSizeException, ELFCustomFieldIdException, ELFInetException,
    ELFTimeException, ELFServerTimeException
*)

    function GetCustomLicenseField(const FieldId: UnicodeString): UnicodeString;

    // extract LongWord Handle
    property Handle: LongWord read GetHandle;

    // enable/disable license autodrop
    property Owned: Boolean read GetOwned write SetOwned;

    property HasLicense: Boolean read GetHasLicense;
    property CustomLicenseField[const FieldId: UnicodeString]: UnicodeString read GetCustomLicenseField;
  end;

(*
    FUNCTION: GetHandle()

    PURPOSE: Sets the version GUID of your application and gets the new handle
    which will be used for the version GUID.

    Dropping the license invalidates the used handle, so make sure you request
    a new handle after dropping the license.

    PARAMETERS:
    * VersionGUID - the unique version GUID of your application as mentioned
      on the product version page of your application in the dashboard.

    RESULT: the new handle which will be used for the session

    EXCEPTION: ELFPFileException, ELFGUIDException
*)

function GetHandle(const VersionGUID: UnicodeString): ILFHandle;

(*
    FUNCTION: FindHandle()

    PURPOSE: Gets the handle set for the version GUID.

    Dropping the license invalidates the used handle, so make sure you request
    a new handle after dropping the license.

    PARAMETERS:
    * VersionGUID - the unique version GUID of your application as mentioned
      on the product version page of your application in the dashboard.

    RESULT: The raw handle value.

    EXCEPTIONS: ELFPFileException, ELFGUIDException, ELFHandleException
*)

function FindHandle(const VersionGUID: UnicodeString): LongWord;
function CreateLFHandleWrapper(Handle: LongWord; AOwned: Boolean = True): ILFHandle;

(*
    FUNCTION: GlobalCleanUp()

    PURPOSE: Releases the resources acquired for sending network requests.

    Call this procedure before you exit your application.

    NOTE: This procedure does not drop any leased license on the LexFloatServer.
*)

procedure GlobalCleanUp; // called on finalization of this unit automatically

(*** Exceptions ***)

type
  {$M+}
  ELFError = class(Exception) // parent of all LexActivator exceptions
  protected
    FErrorCode: HRESULT;
  public
    // create exception of an appropriate class
    class function CreateByCode(ErrorCode: HRESULT): ELFError;

    // check for LF_OK, otherwise raise exception
    class procedure Check(ErrorCode: HRESULT); {$IFDEF DELPHI_HAS_INLINE} inline; {$ENDIF}

    // convert LF_OK into True, LF_FAIL into False, otherwise raise exception
    class function CheckOKFail(ErrorCode: HRESULT): Boolean; {$IFDEF DELPHI_HAS_INLINE} inline; {$ENDIF}

    property ErrorCode: HRESULT read FErrorCode;
  end;
  {$M-}

  // Exceptional situation for LF_E_* codes
  ELFException = class(ELFError);

  // Function returned a code not understandable by Delphi binding yet
  ELFUnknownErrorCodeException = class(ELFException)
  protected
    constructor Create(AErrorCode: HRESULT);
  end;

  // LF_FAIL
  ELFFailException = class(ELFException)
  public
    constructor Create; overload;
    constructor Create(const Msg: string); overload;
    procedure AfterConstruction; override;
  end;

(*
    CODE: LF_E_INET

    MESSAGE: Failed to connect to the server due to network error.
*)

  ELFInetException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_CALLBACK

    MESSAGE: Invalid or missing callback function.
*)

  ELFCallbackException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_NO_FREE_LICENSE

    MESSAGE: No free license is available
*)

  ELFNoFreeLicenseException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_LICENSE_EXISTS

    MESSAGE: License has already been leased.
*)

  ELFLicenseExistsException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_HANDLE

    MESSAGE: Invalid handle.
*)

  ELFHandleException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_LICENSE_EXPIRED

    MESSAGE: License lease has expired. This happens when the
    request to refresh the license fails due to license been taken
    up by some other client.
*)

  ELFLicenseExpiredException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_LICENSE_EXPIRED_INET

    MESSAGE: License lease has expired due to network error. This
    happens when the request to refresh the license fails due to
    network error.
*)

  ELFLicenseExpiredInetException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_SERVER_ADDRESS

    MESSAGE: Missing server address.
*)

  ELFServerAddressException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_PFILE

    MESSAGE: Invalid or corrupted product file.
*)

  ELFPFileException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_FPATH

    MESSAGE: Invalid product file path.
*)

  ELFFPathException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_PRODUCT_VERSION

    MESSAGE: The version GUID of the client and server don't match.
*)

  ELFProductVersionException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_GUID

    MESSAGE: The version GUID doesn't match that of the product file.
*)

  ELFGUIDException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_SERVER_TIME

    MESSAGE: System time on Server Machine has been tampered with. Ensure
    your date and time settings are correct on the server machine.
*)

  ELFServerTimeException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LA_E_TIME

    MESSAGE: The system time has been tampered with. Ensure your date
    and time settings are correct.
*)

  ELFTimeException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_CUSTOM_FIELD_ID

    MESSAGE: Invalid custom field id.
*)

  ELFCustomFieldIdException = class(ELFException)
  public
    constructor Create;
  end;

(*
    CODE: LF_E_BUFFER_SIZE

    MESSAGE: The buffer size was smaller than required.
*)

  ELFBufferSizeException = class(ELFException)
  public
    constructor Create;
  end;

implementation

uses
{$IFDEF DELPHI_UNITS_SCOPED}
  System.TypInfo
{$ELSE}
  TypInfo
{$ENDIF}
  ;

const
  LexFloatClient_DLL = 'LexFloatClient.dll';

function LFCallbackEventToString(Item: TLFCallbackEvent): string;
begin
  if (Item >= Low(TLFCallbackEvent)) and (Item <= High(TLFCallbackEvent)) then
  begin
    // sane value
    Result := GetEnumName(TypeInfo(TLFCallbackEvent), Integer(Item));
  end else begin
    // invalid value, should not appear
    Result := '$' + IntToHex(Integer(Item), 2 * SizeOf(Item));
  end;
end;

(*** Return Codes ***)

const
  LF_OK                     = HRESULT($00000000);

  LF_FAIL                   = HRESULT($00000001);

(*
    CODE: LF_E_INET

    MESSAGE: Failed to connect to the server due to network error.
*)

  LF_E_INET                 = HRESULT($00000002);

(*
    CODE: LF_E_CALLBACK

    MESSAGE: Invalid or missing callback function.
*)

  LF_E_CALLBACK             = HRESULT($00000003);

(*
    CODE: LF_E_NO_FREE_LICENSE

    MESSAGE: No free license is available
*)

  LF_E_NO_FREE_LICENSE      = HRESULT($00000004);

(*
    CODE: LF_E_LICENSE_EXISTS

    MESSAGE: License has already been leased.
*)

  LF_E_LICENSE_EXISTS       = HRESULT($00000005);

(*
    CODE: LF_E_HANDLE

    MESSAGE: Invalid handle.
*)

  LF_E_HANDLE               = HRESULT($00000006);

(*
    CODE: LF_E_LICENSE_EXPIRED

    MESSAGE: License lease has expired. This happens when the
    request to refresh the license fails due to license been taken
    up by some other client.
*)

  LF_E_LICENSE_EXPIRED      = HRESULT($00000007);

(*
    CODE: LF_E_LICENSE_EXPIRED_INET

    MESSAGE: License lease has expired due to network error. This
    happens when the request to refresh the license fails due to
    network error.
*)

  LF_E_LICENSE_EXPIRED_INET = HRESULT($00000008);

(*
    CODE: LF_E_SERVER_ADDRESS

    MESSAGE: Missing server address.
*)

  LF_E_SERVER_ADDRESS       = HRESULT($00000009);

(*
    CODE: LF_E_PFILE

    MESSAGE: Invalid or corrupted product file.
*)

  LF_E_PFILE                = HRESULT($0000000A);

(*
    CODE: LF_E_FPATH

    MESSAGE: Invalid product file path.
*)

  LF_E_FPATH                = HRESULT($0000000B);

(*
    CODE: LF_E_PRODUCT_VERSION

    MESSAGE: The version GUID of the client and server don't match.
*)

  LF_E_PRODUCT_VERSION      = HRESULT($0000000C);

(*
    CODE: LF_E_GUID

    MESSAGE: The version GUID doesn't match that of the product file.
*)

  LF_E_GUID                 = HRESULT($0000000D);

(*
    CODE: LF_E_SERVER_TIME

    MESSAGE: System time on Server Machine has been tampered with. Ensure
    your date and time settings are correct on the server machine.
*)

  LF_E_SERVER_TIME          = HRESULT($0000000E);

(*
    CODE: LA_E_TIME

    MESSAGE: The system time has been tampered with. Ensure your date
    and time settings are correct.
*)

  LF_E_TIME                 = HRESULT($00000010);

(*
    CODE: LF_E_CUSTOM_FIELD_ID

    MESSAGE: Invalid custom field id.
*)

  LF_E_CUSTOM_FIELD_ID      = HRESULT($00000011);

(*
    CODE: LF_E_BUFFER_SIZE

    MESSAGE: The buffer size was smaller than required.
*)

  LF_E_BUFFER_SIZE          = HRESULT($00000012);

function Thin_SetProductFile(const filePath: PWideChar): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetProductFile';

procedure SetProductFile(const FilePath: UnicodeString);
begin
  if not ELFError.CheckOKFail(Thin_SetProductFile(PWideChar(FilePath))) then
    raise
    ELFFailException.CreateFmt('Failed to set the path of the Product.dat ' +
      'file to %s', [FilePath]);
end;

function Thin_GetHandle(const versionGUID: PWideChar; out handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'GetHandle';

function GetHandle(const VersionGUID: UnicodeString): ILFHandle;
var
  NewHandle: LongWord;
begin
  if not ELFError.CheckOKFail(Thin_GetHandle(PWideChar(VersionGUID), NewHandle)) then
    raise ELFFailException.Create('Failed to set the version GUID of application and get the new handle');
  Result := CreateLFHandleWrapper(NewHandle);
end;

type
  TLFHandleImplementation = class(TInterfacedObject, ILFHandle)
  protected
    FHandle: LongWord;
    FOwned: Boolean;
    FCallbackSlot: ShortInt;
    FCallback: TLFCallback;
    {$IFDEF DELPHI_HAS_CLOSURES}
    FClosure: TLFClosure;
    {$ENDIF}
    constructor Create(AHandle: LongWord; AOwned: Boolean = True);
    function GetHandle: LongWord;
    function GetOwned: Boolean;
    procedure SetOwned(AOwned: Boolean);
    procedure SetFloatServer(const HostAddress: UnicodeString; Port: Word);
    procedure SetLicenseCallback(Callback: TLFCallback); overload;
    {$IFDEF DELPHI_HAS_CLOSURES}
    procedure SetLicenseCallback(Callback: TLFClosure); overload;
    {$ENDIF}
    procedure DoCallback(ErrorCode: LongWord; Event: TLFCallbackEvent);
    procedure RequestLicense;
    procedure DropLicense;
    destructor Destroy; override;
    function GetHasLicense: Boolean;
    function GetCustomLicenseField(const FieldId: UnicodeString): UnicodeString;
  end;

function CreateLFHandleWrapper(Handle: LongWord; AOwned: Boolean = True): ILFHandle;
begin
  Result := TLFHandleImplementation.Create(Handle, AOwned);
end;

constructor TLFHandleImplementation.Create(AHandle: LongWord; AOwned: Boolean = True);
begin
  inherited Create;
  FCallbackSlot := -1;
  FHandle := AHandle;
  FOwned := AOwned;
end;

function TLFHandleImplementation.GetHandle: LongWord;
begin
  Result := FHandle;
end;

function TLFHandleImplementation.GetOwned: Boolean;
begin
  Result := FOwned;
end;

procedure TLFHandleImplementation.SetOwned(AOwned: Boolean);
begin
  FOwned := AOwned;
end;

function Thin_SetFloatServer(handle: LongWord; const hostAddress: PWideChar; port: Word): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetFloatServer';

procedure TLFHandleImplementation.SetFloatServer(const HostAddress: UnicodeString; Port: Word);
begin
  if not ELFError.CheckOKFail(Thin_SetFloatServer(FHandle, PWideChar(HostAddress), Port)) then
    raise ELFFailException.CreateFmt
      ('Failed to set the network address of the LexFloatServer to %s',
       [HostAddress]);
end;

type
  Thin_TLFCallback = procedure(ErrorCode: LongWord); cdecl;

function AllocateCallback(Handler: TLFHandleImplementation): Thin_TLFCallback; forward;

function Thin_SetLicenseCallback(handle: LongWord; callback: Thin_TLFCallback): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetLicenseCallback';

procedure TLFHandleImplementation.SetLicenseCallback(Callback: TLFCallback);
begin
  FCallback := Callback;
  {$IFDEF DELPHI_HAS_CLOSURES}
  FClosure := nil;
  {$ENDIF}
  if FCallbackSlot < 0 then
  begin
    if not ELFError.CheckOKFail(Thin_SetLicenseCallback(FHandle, AllocateCallback(Self))) then
      raise ELFFailException.Create('Failed to set refresh license error callback function');
  end;
end;

{$IFDEF DELPHI_HAS_CLOSURES}
procedure TLFHandleImplementation.SetLicenseCallback(Callback: TLFClosure);
begin
  FCallback := nil;
  FClosure := Callback;
  if FCallbackSlot < 0 then
  begin
    if not ELFError.CheckOKFail(Thin_SetLicenseCallback(FHandle, AllocateCallback(Self))) then
      raise ELFFailException.Create('Failed to set refresh license error callback function');
  end;
end;
{$ENDIF}

const
  LFCallbackAmount = 16;

type
  TLFCallbackSlot = record
    IsUsed: Boolean;
    Handler: TLFHandleImplementation;
  end;

var
  CallbackSlots: array[0 .. LFCallbackAmount - 1] of TLFCallbackSlot;
  CallbackSlotsMutex: TRTLCriticalSection;

procedure Thin_TLFCallback0(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[0].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback1(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[1].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback2(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[2].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback3(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[3].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback4(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[4].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback5(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[5].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback6(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[6].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback7(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[7].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback8(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[8].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback9(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[9].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback10(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[10].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback11(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[11].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback12(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[12].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback13(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[13].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback14(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[14].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

procedure Thin_TLFCallback15(ErrorCode: LongWord); cdecl;
begin
  try
    CallbackSlots[15].Handler.DoCallback(ErrorCode, leRefreshLicense);
  except end;
end;

const
  CallbackEntries: array[0 .. LFCallbackAmount - 1] of Thin_TLFCallback =
  (Thin_TLFCallback0, Thin_TLFCallback1, Thin_TLFCallback2, Thin_TLFCallback3,
   Thin_TLFCallback4, Thin_TLFCallback5, Thin_TLFCallback6, Thin_TLFCallback7,
   Thin_TLFCallback8, Thin_TLFCallback9, Thin_TLFCallback10, Thin_TLFCallback11,
   Thin_TLFCallback12, Thin_TLFCallback13, Thin_TLFCallback14, Thin_TLFCallback15);

function AllocateCallback(Handler: TLFHandleImplementation): Thin_TLFCallback;
var
  i: ShortInt;
begin
  Result := nil;
  try
    EnterCriticalSection(CallbackSlotsMutex);
    for i := 0 to LFCallbackAmount - 1 do
    begin
      if not CallbackSlots[i].IsUsed then
      begin
        CallbackSlots[i].IsUsed := True;
        CallbackSlots[i].Handler := Handler;
        Handler.FCallbackSlot := i;
        Result := CallbackEntries[i];
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(CallbackSlotsMutex);
  end;
  raise ELFFailException.Create('Failed to allocate new callback');
end;

procedure FreeCallback(Slot: ShortInt);
begin
  try
    CallbackSlots[Slot].IsUsed := False;
    CallbackSlots[Slot].Handler := nil;
  finally
    LeaveCriticalSection(CallbackSlotsMutex);
  end;
end;

procedure TLFHandleImplementation.DoCallback(ErrorCode: LongWord; Event: TLFCallbackEvent);
var
  E: Exception;
  Sender: ILFHandle;
begin
  {$IFNDEF DELPHI_HAS_CLOSURES}
  if @FCallback = nil then Exit;
  {$ELSE}
  if (@FCallback = nil) and (@FClosure = nil) then Exit;
  {$ENDIF}
  if Event <> leDropLicense then Sender := Self;

  try
    E := ELFError.CreateByCode(ErrorCode);
    if nil <> @FCallback then
      FCallback(Sender, E, Event)
    {$IFDEF DELPHI_HAS_CLOSURES}
    else if nil <> @FClosure then
      FClosure(Sender, E, Event)
    {$ENDIF}
    ;
  finally
    FreeAndNil(E);
  end;
end;

function Thin_RequestLicense(handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'RequestLicense';

procedure TLFHandleImplementation.RequestLicense;
begin
  if not ELFError.CheckOKFail(Thin_RequestLicense(FHandle)) then
    raise ELFFailException.Create('Failed to send the request to lease the license from the LexFloatServer');
end;

function Thin_DropLicense(handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'DropLicense';

procedure TLFHandleImplementation.DropLicense;
begin
  if not ELFError.CheckOKFail(Thin_DropLicense(FHandle)) then
    raise ELFFailException.Create('Failed to send the request to drop the license from the LexFloatServer');
end;

destructor TLFHandleImplementation.Destroy;
begin
  inherited Destroy;
  try
    if FOwned then
    begin
      try
        DropLicense;
      except
        on E: Exception do
          if nil <> @FCallback then
            FCallback(nil, E, leDropLicense)
          {$IFDEF DELPHI_HAS_CLOSURES}
          else if nil <> @FClosure then
            FClosure(nil, E, leDropLicense)
          {$ENDIF}
          ;
      end;
    end;
  except end;
  try
    if FCallbackSlot >= 0 then FreeCallback(FCallbackSlot);
  except end;
end;

function Thin_HasLicense(handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'HasLicense';

function TLFHandleImplementation.GetHasLicense: Boolean;
begin
  Result := ELFError.CheckOKFail(Thin_HasLicense(FHandle));
end;

function Thin_GetCustomLicenseField(handle: LongWord; const fieldId: PWideChar; out fieldValue; length: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'GetCustomLicenseField';

function TLFHandleImplementation.GetCustomLicenseField(const FieldId: UnicodeString): UnicodeString;
var
  Arg1: PWideChar;
  ErrorCode: HRESULT;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetCustomLicenseField(FHandle, Arg1, Buffer, Length(Buffer));
    Result := ErrorCode <> LF_E_BUFFER_SIZE;
    if ErrorCode = LF_OK then OuterResult := Buffer;
  end;
  function Try1024(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 1023] of WideChar;
  begin
    ErrorCode := Thin_GetCustomLicenseField(FHandle, Arg1, Buffer, Length(Buffer));
    Result := ErrorCode <> LF_E_BUFFER_SIZE;
    if ErrorCode = LF_OK then OuterResult := Buffer;
  end;
  function Try4096(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 4095] of WideChar;
  begin
    ErrorCode := Thin_GetCustomLicenseField(FHandle, Arg1, Buffer, Length(Buffer));
    Result := ErrorCode <> LF_E_BUFFER_SIZE;
    if ErrorCode = LF_OK then OuterResult := Buffer;
  end;
begin
  Arg1 := PWideChar(FieldId);
  if not Try256(Result) then if not Try1024(Result) then Try4096(Result);
  if not ELFError.CheckOKFail(ErrorCode) then
    raise ELFFailException.CreateFmt('Failed to get the value of the custom '+
      'field %s associated with the float server key', [FieldId]);
end;

function Thin_FindHandle(const versionGUID: PWideChar; out handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'FindHandle';

function FindHandle(const VersionGUID: UnicodeString): LongWord;
begin
  if not ELFError.CheckOKFail(Thin_FindHandle(PWideChar(VersionGUID), Result)) then
    raise ELFFailException.Create('Failed to get the handle set for the version GUID');
end;

function Thin_GlobalCleanUp: HRESULT; cdecl;
  external LexFloatClient_DLL name 'GlobalCleanUp';

procedure GlobalCleanUp;
begin
  if not ELFError.CheckOKFail(Thin_GlobalCleanUp) then
    raise ELFFailException.Create('Failed to release the resources acquired ' +
      'for sending network requests');
end;

class function ELFError.CreateByCode(ErrorCode: HRESULT): ELFError;
begin
  case ErrorCode of
    LF_OK: Result := nil;
    LF_FAIL: Result := ELFFailException.Create;
    LF_E_INET: Result := ELFInetException.Create;
    LF_E_CALLBACK: Result := ELFCallbackException.Create;
    LF_E_NO_FREE_LICENSE: Result := ELFNoFreeLicenseException.Create;
    LF_E_LICENSE_EXISTS: Result := ELFLicenseExistsException.Create;
    LF_E_HANDLE: Result := ELFHandleException.Create;
    LF_E_LICENSE_EXPIRED: Result := ELFLicenseExpiredException.Create;
    LF_E_LICENSE_EXPIRED_INET: Result := ELFLicenseExpiredInetException.Create;
    LF_E_SERVER_ADDRESS: Result := ELFServerAddressException.Create;
    LF_E_PFILE: Result := ELFPFileException.Create;
    LF_E_FPATH: Result := ELFFPathException.Create;
    LF_E_PRODUCT_VERSION: Result := ELFProductVersionException.Create;
    LF_E_GUID: Result := ELFGUIDException.Create;
    LF_E_SERVER_TIME: Result := ELFServerTimeException.Create;
    LF_E_TIME: Result := ELFTimeException.Create;
    LF_E_CUSTOM_FIELD_ID: Result := ELFCustomFieldIdException.Create;
    LF_E_BUFFER_SIZE: Result := ELFBufferSizeException.Create;
  else
    Result := ELFUnknownErrorCodeException.Create(ErrorCode);
  end;
end;

// check for LF_OK, otherwise raise exception
class procedure ELFError.Check(ErrorCode: HRESULT);
begin
  // E2441 Inline function declared in interface section must not use local
  // symbol 'LF_OK'
  if ErrorCode <> 0 then
    raise CreateByCode(ErrorCode);
end;

class function ELFError.CheckOKFail(ErrorCode: HRESULT): Boolean;
begin
  // E2441 Inline function declared in interface section must not use local
  // symbol 'LF_OK'
  case ErrorCode of
    0: Result := True;
    1: Result := False;
  else
    raise CreateByCode(ErrorCode);
  end;
end;

constructor ELFUnknownErrorCodeException.Create(AErrorCode: HRESULT);
begin
  inherited CreateFmt('LexFloatClient error %.8x', [AErrorCode]);
  FErrorCode := AErrorCode;
end;

constructor ELFFailException.Create;
begin
  inherited Create('Failed');
end;

constructor ELFFailException.Create(const Msg: string);
begin
  inherited;
end;

procedure ELFFailException.AfterConstruction;
begin
  FErrorCode := LF_FAIL;
end;

constructor ELFInetException.Create;
begin
  inherited Create('Failed to connect to the server due to network error');
  FErrorCode := LF_E_INET;
end;

constructor ELFCallbackException.Create;
begin
  inherited Create('Invalid or missing callback function');
  FErrorCode := LF_E_CALLBACK;
end;

constructor ELFNoFreeLicenseException.Create;
begin
  inherited Create('No free license is available');
  FErrorCode := LF_E_NO_FREE_LICENSE;
end;

constructor ELFLicenseExistsException.Create;
begin
  inherited Create('License has already been leased');
  FErrorCode := LF_E_LICENSE_EXISTS;
end;

constructor ELFHandleException.Create;
begin
  inherited Create('Invalid handle');
  FErrorCode := LF_E_HANDLE;
end;

constructor ELFLicenseExpiredException.Create;
begin
  inherited Create('License lease has expired');
  FErrorCode := LF_E_LICENSE_EXPIRED;
end;

constructor ELFLicenseExpiredInetException.Create;
begin
  inherited Create('License lease has expired due to network error');
  FErrorCode := LF_E_LICENSE_EXPIRED_INET;
end;

constructor ELFServerAddressException.Create;
begin
  inherited Create('Missing server address');
  FErrorCode := LF_E_SERVER_ADDRESS;
end;

constructor ELFPFileException.Create;
begin
  inherited Create('Invalid or corrupted product file');
  FErrorCode := LF_E_PFILE;
end;

constructor ELFFPathException.Create;
begin
  inherited Create('Invalid product file path');
  FErrorCode := LF_E_FPATH;
end;

constructor ELFProductVersionException.Create;
begin
  inherited Create('The version GUID of the client and server don''t match');
  FErrorCode := LF_E_PRODUCT_VERSION;
end;

constructor ELFGUIDException.Create;
begin
  inherited Create('The version GUID doesn''t match that of the product file');
  FErrorCode := LF_E_GUID;
end;

constructor ELFServerTimeException.Create;
begin
  inherited Create('System time on Server Machine has been tampered with');
  FErrorCode := LF_E_SERVER_TIME;
end;

constructor ELFTimeException.Create;
begin
  inherited Create('The system time has been tampered with');
  FErrorCode := LF_E_TIME;
end;

constructor ELFCustomFieldIdException.Create;
begin
  inherited Create('Invalid custom field id');
  FErrorCode := LF_E_CUSTOM_FIELD_ID;
end;

constructor ELFBufferSizeException.Create;
begin
  inherited Create('The buffer size was smaller than required');
  FErrorCode := LF_E_BUFFER_SIZE;
end;

initialization
  InitializeCriticalSection(CallbackSlotsMutex);
  FillChar(CallbackSlots, SizeOf(CallbackSlots), 0);
finalization
  try GlobalCleanup; except end;
  DeleteCriticalSection(CallbackSlotsMutex);
end.

