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

type
  ILFHandle = interface;
  TLFProcedureCallback = procedure(const Sender: ILFHandle; // Sender can be nil!
    const Error: Exception; Event: TLFCallbackEvent);
  TLFMethodCallback = procedure(const Sender: ILFHandle; // Sender can be nil!
    const Error: Exception; Event: TLFCallbackEvent) of object;
  {$IFDEF DELPHI_HAS_CLOSURES}
  TLFClosureCallback = reference to procedure(const Sender: ILFHandle; // can be nil!
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

    EXCEPTIONS: ELFHandleException, ELFProductIdException, ELFFailException
*)

    procedure SetFloatServer(const HostAddress: UnicodeString; Port: Word);

(*
    PROCEDURE: SetLicenseCallback()

    PURPOSE: Sets refresh license error callback function.

    Whenever the lease expires, a refresh lease request is sent to the
    server. If the lease fails to refresh, refresh license callback function
    gets invoked with the following status error codes: LF_E_LICENSE_EXPIRED,
    LF_E_LICENSE_EXPIRED_INET, LF_E_SERVER_TIME, LF_E_TIME.

    When there are no more references to ILFHandle, DropLicense is being
    invoked automatically. DropLicense might be unsuccessful, and this
    condition is being signaled via Callback too. Callback should not however
    be able to revive ILFHandle, thus Sender is nil.

    PARAMETERS:
    * Callback - name of the callback function
    * Synchronized - whether callback must be invoked in main (GUI) thread
    using TThread.Synchronize
    Usually True for GUI applications and handlers like TForm1.OnLexFloatClient
    Must be False if there is no GUI message loop, like in console applications,
    but then another thread synchronization measures must be used.

    EXCEPTIONS: ELFHandleException, ELFProductIdException
*)

    procedure SetLicenseCallback(Callback: TLFProcedureCallback; Synchronized: Boolean); overload;
    procedure SetLicenseCallback(Callback: TLFMethodCallback; Synchronized: Boolean); overload;
    {$IFDEF DELPHI_HAS_CLOSURES}
    procedure SetLicenseCallback(Callback: TLFClosureCallback; Synchronized: Boolean); overload;
    {$ENDIF}

(*
    PROCEDURE: ResetLicenseCallback()

    PURPOSE: Resets refresh license error callback function.

    EXCEPTIONS: ELFHandleException, ELFProductIdException
*)

    procedure ResetLicenseCallback;

(*
    PROCEDURE: RequestLicense()

    PURPOSE: Sends the request to lease the license from the LexFloatServer.

    EXCEPTIONS: ELFFailException, ELFHandleException, ELFProductIdException,
    ELFServerAddressException, ELFCallbackException, ELFLicenseExistsException,
    ELFInetException, ELFNoFreeLicenseException, ELFTimeException,
    ELFServerTimeException
*)

    procedure RequestLicense;

(*
    PROCEDURE: DropLicense()

    PURPOSE: Sends the request to drop the license from the LexFloatServer.

    Call this function before you exit your application to prevent zombie licenses.

    EXCEPTIONS: ELFFailException, ELFHandleException, ELFProductIdException,
    ELFServerAddressException, ELFCallbackException, ELFInetException, ELFTimeException,
    ELFServerTimeException
*)

    // procedure DropLicense;
    // called automatically after last reference has been released
    // exceptions are being handled by Callback (Sender is nil)

(*
    PROPERTY: HasLicense

    PURPOSE: Checks whether any license has been leased or not. If yes,
    it retuns True.

    RESULT: True, False

    EXCEPTIONS: ELFHandleException, ELFProductIdException, ELFServerAddressException,
    ELFCallbackException
*)

    function GetHasLicense: Boolean;

(*
    PROPERTY: LicenseMetadata

    PURPOSE: Get the value of the license metadata field associated with the float server key.

    PARAMETERS:
    * Key - key of the metadata field whose value you want to get

    RESULT: Value of the license metadata field associated with the float server key

    EXCEPTIONS: ELFFailException, ELFHandleException, ELFProductIdException,
    ELFServerAddressException, ELFCallbackException, ELFBufferSizeException,
    ELFMetadataKeyNotFoundException, ELFInetException, ELFTimeException,
    ELFServerTimeException
*)

    function GetLicenseMetadata(const Key: UnicodeString): UnicodeString;

    // extract LongWord Handle
    property Handle: LongWord read GetHandle;

    // enable/disable license autodrop
    property Owned: Boolean read GetOwned write SetOwned;

    property HasLicense: Boolean read GetHasLicense;
    property LicenseMetadata[const Key: UnicodeString]: UnicodeString read GetLicenseMetadata;
  end;

(*
    FUNCTION: LFGetHandle()

    PURPOSE: Sets the product id of your application and gets the new handle
    which will be used for the product id.

    Dropping the license invalidates the used handle, so make sure you request
    a new handle after dropping the license.

    PARAMETERS:
    * ProductId - the unique product id of your application as mentioned
      on the product page in the dashboard.

    RESULT: the new handle which will be used for the session

    EXCEPTIONS: ELFProductIdException
*)

function LFGetHandle(const ProductId: UnicodeString): ILFHandle;

(*
    FUNCTION: LFFindHandle()

    PURPOSE: Gets the handle set for the product id.

    Dropping the license invalidates the used handle, so make sure you request
    a new handle after dropping the license.

    PARAMETERS:
    * ProductId - the unique product id of your application as mentioned
      on the product page in the dashboard.

    RESULT: The raw handle value.

    EXCEPTIONS: ELFProductIdException, ELFHandleException
*)

function LFFindHandle(const ProductId: UnicodeString): LongWord;
function CreateLFHandleWrapper(Handle: LongWord; AOwned: Boolean = True): ILFHandle;

(*
    PROCEDURE: GlobalCleanUp()

    PURPOSE: Releases the resources acquired for sending network requests.

    Call this function before you exit your application.

    NOTE: This function does not drop any leased license on the LexFloatServer.
*)

procedure GlobalCleanUp; // called on finalization of this unit automatically

(*** Exceptions ***)

type
  {$M+}
  ELFError = class(Exception) // parent of all LexFloatClient exceptions
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
        CODE: LF_E_PRODUCT_ID

        MESSAGE: The product id is incorrect.
    *)

  ELFProductIdException = class(ELFException)
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
        CODE: LF_E_HANDLE

        MESSAGE: Invalid handle.
    *)

  ELFHandleException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER_ADDRESS

        MESSAGE: Missing or invalid server address.
    *)

  ELFServerAddressException = class(ELFException)
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
        CODE: LF_E_TIME

        MESSAGE: The system time has been tampered with. Ensure your date
        and time settings are correct.
    *)

  ELFTimeException = class(ELFException)
  public
    constructor Create;
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
        CODE: LF_E_NO_FREE_LICENSE

        MESSAGE: No free license is available.
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
        CODE: LF_E_BUFFER_SIZE

        MESSAGE: The buffer size was smaller than required.
    *)

  ELFBufferSizeException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_METADATA_KEY_NOT_FOUND

        MESSAGE: The metadata key does not exist.
    *)

  ELFMetadataKeyNotFoundException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER

        MESSAGE: Server error.
    *)

  ELFServerException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_CLIENT

        MESSAGE: Client error.
    *)

  ELFClientException = class(ELFException)
  public
    constructor Create;
  end;

implementation

uses
{$IFDEF DELPHI_UNITS_SCOPED}
  System.TypInfo, System.Classes
{$ELSE}
  TypInfo, Classes
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
  LF_OK = HRESULT(0);
  LF_FAIL = HRESULT(1);
  LF_E_PRODUCT_ID = HRESULT(40);
  LF_E_CALLBACK = HRESULT(41);
  LF_E_HANDLE = HRESULT(42);
  LF_E_SERVER_ADDRESS = HRESULT(43);
  LF_E_SERVER_TIME = HRESULT(44);
  LF_E_TIME = HRESULT(45);
  LF_E_INET = HRESULT(46);
  LF_E_NO_FREE_LICENSE = HRESULT(47);
  LF_E_LICENSE_EXISTS = HRESULT(48);
  LF_E_LICENSE_EXPIRED = HRESULT(49);
  LF_E_LICENSE_EXPIRED_INET = HRESULT(50);
  LF_E_BUFFER_SIZE = HRESULT(51);
  LF_E_METADATA_KEY_NOT_FOUND = HRESULT(52);
  LF_E_SERVER = HRESULT(70);
  LF_E_CLIENT = HRESULT(71);

function Thin_GetHandle(const productId: PWideChar; out handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'GetHandle';

function LFGetHandle(const ProductId: UnicodeString): ILFHandle;
var
  NewHandle: LongWord;
begin
  if not ELFError.CheckOKFail(Thin_GetHandle(PWideChar(ProductId), NewHandle)) then
    raise ELFFailException.Create('Failed to set the product id of the application and get the new handle');
  Result := CreateLFHandleWrapper(NewHandle);
end;

type
  TLFCallbackKind =
    (lckNone,
     lckProcedure,
     lckMethod
     {$IFDEF DELPHI_HAS_CLOSURES}, lckClosure{$ENDIF});

  TLFHandleImplementation = class(TInterfacedObject, ILFHandle)
  protected
    FHandle: LongWord;
    FOwned: Boolean;
    FCallbackSlot: ShortInt;
    FCallbackKind: TLFCallbackKind { = lckNone};
    FLFProcedureCallback: TLFProcedureCallback;
    FLFMethodCallback: TLFMethodCallback;
    {$IFDEF DELPHI_HAS_CLOSURES}
    FLFClosureCallback: TLFClosureCallback;
    {$ENDIF}
    FLFCallbackSynchronized: Boolean;
    FLFStatusCode: HRESULT;
    FLFEvent: TLFCallbackEvent;
    FLFCallbackMutex: TRTLCriticalSection;

    constructor Create(AHandle: LongWord; AOwned: Boolean = True);
    function GetHandle: LongWord;
    function GetOwned: Boolean;
    procedure SetOwned(AOwned: Boolean);

    procedure SetFloatServer(const HostAddress: UnicodeString; Port: Word);
    procedure SetLicenseCallback(Callback: TLFProcedureCallback; Synchronized: Boolean); overload;
    procedure SetLicenseCallback(Callback: TLFMethodCallback; Synchronized: Boolean); overload;
    {$IFDEF DELPHI_HAS_CLOSURES}
    procedure SetLicenseCallback(Callback: TLFClosureCallback; Synchronized: Boolean); overload;
    {$ENDIF}
    procedure ResetLicenseCallback;
    procedure DoCallback(ErrorCode: LongWord; Event: TLFCallbackEvent);
    procedure Invoke;
    procedure RequestLicense;
    procedure DropLicense;
    destructor Destroy; override;
    function GetHasLicense: Boolean;
    function GetLicenseMetadata(const Key: UnicodeString): UnicodeString;
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
  InitializeCriticalSection(FLFCallbackMutex);
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
procedure FreeCallback(Slot: ShortInt); forward;

function Thin_SetLicenseCallback(handle: LongWord; callback: Thin_TLFCallback): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetLicenseCallback';

procedure TLFHandleImplementation.SetLicenseCallback(Callback: TLFProcedureCallback; Synchronized: Boolean);
begin
  EnterCriticalSection(FLFCallbackMutex);
  try
    FLFProcedureCallback := Callback;
    FLFCallbackSynchronized := Synchronized;
    FCallbackKind := lckProcedure;

    if FCallbackSlot < 0 then
    begin
      if not ELFError.CheckOKFail(Thin_SetLicenseCallback(FHandle, AllocateCallback(Self))) then
        raise ELFFailException.Create('Failed to set refresh license error callback function');
    end;
  finally
    LeaveCriticalSection(FLFCallbackMutex);
  end;
end;

procedure TLFHandleImplementation.SetLicenseCallback(Callback: TLFMethodCallback; Synchronized: Boolean);
begin
  EnterCriticalSection(FLFCallbackMutex);
  try
    FLFMethodCallback := Callback;
    FLFCallbackSynchronized := Synchronized;
    FCallbackKind := lckMethod;

    if FCallbackSlot < 0 then
    begin
      if not ELFError.CheckOKFail(Thin_SetLicenseCallback(FHandle, AllocateCallback(Self))) then
        raise ELFFailException.Create('Failed to set refresh license error callback function');
    end;
  finally
    LeaveCriticalSection(FLFCallbackMutex);
  end;
end;

{$IFDEF DELPHI_HAS_CLOSURES}
procedure TLFHandleImplementation.SetLicenseCallback(Callback: TLFClosureCallback; Synchronized: Boolean);
begin
  EnterCriticalSection(FLFCallbackMutex);
  try
    FLFClosureCallback := Callback;
    FLFCallbackSynchronized := Synchronized;
    FCallbackKind := lckClosure;

    if FCallbackSlot < 0 then
    begin
      if not ELFError.CheckOKFail(Thin_SetLicenseCallback(FHandle, AllocateCallback(Self))) then
        raise ELFFailException.Create('Failed to set refresh license error callback function');
    end;
  finally
    LeaveCriticalSection(FLFCallbackMutex);
  end;
end;
{$ENDIF}

procedure Thin_TLFCallback_Dummy(ErrorCode: LongWord); cdecl;
begin
  ;
end;

procedure TLFHandleImplementation.ResetLicenseCallback;
begin
  EnterCriticalSection(FLFCallbackMutex);
  try
    FCallbackKind := lckNone;

    if FCallbackSlot >= 0 then
    begin
      if not ELFError.CheckOKFail(Thin_SetLicenseCallback(FHandle, Thin_TLFCallback_Dummy)) then
        raise ELFFailException.Create('Failed to reset refresh license error callback function');

      FreeCallback(FCallbackSlot);
      FCallbackSlot := -1;
    end;
  finally
    LeaveCriticalSection(FLFCallbackMutex);
  end;
end;

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
  EnterCriticalSection(CallbackSlotsMutex);
  try
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
  EnterCriticalSection(CallbackSlotsMutex);
  try
    CallbackSlots[Slot].IsUsed := False;
    CallbackSlots[Slot].Handler := nil;
  finally
    LeaveCriticalSection(CallbackSlotsMutex);
  end;
end;

procedure TLFHandleImplementation.DoCallback(ErrorCode: LongWord; Event: TLFCallbackEvent);
begin
  try
    EnterCriticalSection(FLFCallbackMutex);
    try
      case FCallbackKind of
        lckNone: Exit;
        lckProcedure: if not Assigned(FLFProcedureCallback) then Exit;
        lckMethod: if not Assigned(FLFMethodCallback) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(FLFClosureCallback) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      FLFStatusCode := HRESULT(ErrorCode);
      FLFEvent := Event;
      if not FLFCallbackSynchronized then
      begin
        Invoke;
        Exit;
      end;
    finally
      LeaveCriticalSection(FLFCallbackMutex);
    end;

    // Race condition here
    //
    // Invoke should proably run exactly the same (captured) handler,
    // but instead it reenters mutex, and handler can be different at
    // that moment. For most sane use cases behavior should be sound
    // anyway.

    TThread.Synchronize(nil, Invoke);
  except
    // there should be default logging here like NSLog, but there is none in Delphi
  end;
end;

procedure TLFHandleImplementation.Invoke;
var
  Sender: ILFHandle;
  
  procedure DoInvoke(const Error: Exception);
  begin
    case FCallbackKind of
      lckNone: Exit;
      lckProcedure:
        if Assigned(FLFProcedureCallback) then
          FLFProcedureCallback(Sender, Error, FLFEvent);
      lckMethod:
        if Assigned(FLFMethodCallback) then
          FLFMethodCallback(Sender, Error, FLFEvent);
      {$IFDEF DELPHI_HAS_CLOSURES}
      lckClosure:
        if Assigned(FLFClosureCallback) then
          FLFClosureCallback(Sender, Error, FLFEvent);
      {$ENDIF}
    else
      // there should be default logging here like NSLog, but there is none in Delphi
    end;
  end;

var
  FailError: Exception;

begin
  try
    EnterCriticalSection(FLFCallbackMutex);
    try
      case FCallbackKind of
        lckNone: Exit;
        lckProcedure: if not Assigned(FLFProcedureCallback) then Exit;
        lckMethod: if not Assigned(FLFMethodCallback) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(FLFClosureCallback) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      if FLFEvent <> leDropLicense then
      begin
        Sender := Self;
      end;

      FailError := nil;
      try
        FailError := ELFError.CreateByCode(FLFStatusCode);
        DoInvoke(FailError);
      finally
        FreeAndNil(FailError);
      end;
    finally
      // This recursive mutex prevents the following scenario:
      //
      // (Main thread)    SetLicenseCallback
      // (Tangent thread) LAThin_CallbackProxy going to invoke X.OnLexFloatClient
      // (Main thread)    ResetLicenseCallback
      // (Main thread)    X.Free
      //
      // Main thread is not allowed to proceed to X.Free until callback is finished
      // On the other hand, if callback removes itself, recursive mutex will allow that
      LeaveCriticalSection(FLFCallbackMutex);
    end;
  except
    // there should be default logging here like NSLog, but there is none in Delphi
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
  try
    if FOwned then
    begin
      try
        DropLicense;
      except
        on E: ELFError do
          DoCallback(E.ErrorCode, leDropLicense);
        on E: Exception do
          DoCallback(LF_FAIL, leDropLicense);
      end;
    end;
  except end;

  try
    if FCallbackSlot >= 0 then ResetLicenseCallback;
  except end;
  DeleteCriticalSection(FLFCallbackMutex);
  inherited Destroy;
end;

function Thin_HasLicense(handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'HasLicense';

function TLFHandleImplementation.GetHasLicense: Boolean;
begin
  Result := ELFError.CheckOKFail(Thin_HasLicense(FHandle));
end;

function Thin_GetLicenseMetadata(handle: LongWord; const key: PWideChar; out value; length: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'GetLicenseMetadata';

function TLFHandleImplementation.GetLicenseMetadata(const Key: UnicodeString): UnicodeString;
var
  Arg1: PWideChar;
  ErrorCode: HRESULT;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetLicenseMetadata(FHandle, Arg1, Buffer, Length(Buffer));
    Result := ErrorCode <> LF_E_BUFFER_SIZE;
    if ErrorCode = LF_OK then OuterResult := Buffer;
  end;
  function TryHigh(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: UnicodeString;
    Size: Integer;
  begin
    Size := 512;
    repeat
      Size := Size * 2;
      SetLength(Buffer, 0);
      SetLength(Buffer, Size);
      ErrorCode := Thin_GetLicenseMetadata(FHandle, Arg1, PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LF_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LF_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  Arg1 := PWideChar(Key);
  if not Try256(Result) then TryHigh(Result);
  if not ELFError.CheckOKFail(ErrorCode) then
    raise ELFFailException.CreateFmt('Failed to get the value of the ' +
      'license metadata field %s associated with the float server key', [Key]);
end;

function Thin_FindHandle(const productId: PWideChar; out handle: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'FindHandle';

function LFFindHandle(const ProductId: UnicodeString): LongWord;
begin
  if not ELFError.CheckOKFail(Thin_FindHandle(PWideChar(ProductId), Result)) then
    raise ELFFailException.Create('Failed to get the handle set for the product id');
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
    LF_E_PRODUCT_ID: Result := ELFProductIdException.Create;
    LF_E_CALLBACK: Result := ELFCallbackException.Create;
    LF_E_HANDLE: Result := ELFHandleException.Create;
    LF_E_SERVER_ADDRESS: Result := ELFServerAddressException.Create;
    LF_E_SERVER_TIME: Result := ELFServerTimeException.Create;
    LF_E_TIME: Result := ELFTimeException.Create;
    LF_E_INET: Result := ELFInetException.Create;
    LF_E_NO_FREE_LICENSE: Result := ELFNoFreeLicenseException.Create;
    LF_E_LICENSE_EXISTS: Result := ELFLicenseExistsException.Create;
    LF_E_LICENSE_EXPIRED: Result := ELFLicenseExpiredException.Create;
    LF_E_LICENSE_EXPIRED_INET: Result := ELFLicenseExpiredInetException.Create;
    LF_E_BUFFER_SIZE: Result := ELFBufferSizeException.Create;
    LF_E_METADATA_KEY_NOT_FOUND: Result := ELFMetadataKeyNotFoundException.Create;
    LF_E_SERVER: Result := ELFServerException.Create;
    LF_E_CLIENT: Result := ELFClientException.Create;
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

constructor ELFProductIdException.Create;
begin
  inherited Create('The product id is incorrect');
  FErrorCode := LF_E_PRODUCT_ID;
end;

constructor ELFCallbackException.Create;
begin
  inherited Create('Invalid or missing callback function');
  FErrorCode := LF_E_CALLBACK;
end;

constructor ELFHandleException.Create;
begin
  inherited Create('Invalid handle');
  FErrorCode := LF_E_HANDLE;
end;

constructor ELFServerAddressException.Create;
begin
  inherited Create('Missing or invalid server address');
  FErrorCode := LF_E_SERVER_ADDRESS;
end;

constructor ELFServerTimeException.Create;
begin
  inherited Create('System time on Server Machine has been tampered ' +
    'with. Ensure your date and time settings are correct on the server machine');
  FErrorCode := LF_E_SERVER_TIME;
end;

constructor ELFTimeException.Create;
begin
  inherited Create('The system time has been tampered with. Ensure your date ' +
    'and time settings are correct');
  FErrorCode := LF_E_TIME;
end;

constructor ELFInetException.Create;
begin
  inherited Create('Failed to connect to the server due to network error');
  FErrorCode := LF_E_INET;
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

constructor ELFLicenseExpiredException.Create;
begin
  inherited Create('License lease has expired. This happens when the ' +
    'request to refresh the license fails due to license been taken ' +
    'up by some other client');
  FErrorCode := LF_E_LICENSE_EXPIRED;
end;

constructor ELFLicenseExpiredInetException.Create;
begin
  inherited Create('License lease has expired due to network error. This ' +
    'happens when the request to refresh the license fails due to ' +
    'network error');
  FErrorCode := LF_E_LICENSE_EXPIRED_INET;
end;

constructor ELFBufferSizeException.Create;
begin
  inherited Create('The buffer size was smaller than required');
  FErrorCode := LF_E_BUFFER_SIZE;
end;

constructor ELFMetadataKeyNotFoundException.Create;
begin
  inherited Create('The metadata key does not exist');
  FErrorCode := LF_E_METADATA_KEY_NOT_FOUND;
end;

constructor ELFServerException.Create;
begin
  inherited Create('Server error');
  FErrorCode := LF_E_SERVER;
end;

constructor ELFClientException.Create;
begin
  inherited Create('Client error');
  FErrorCode := LF_E_CLIENT;
end;

initialization
  InitializeCriticalSection(CallbackSlotsMutex);
  FillChar(CallbackSlots, SizeOf(CallbackSlots), 0);
finalization
  try GlobalCleanup; except end;
  DeleteCriticalSection(CallbackSlotsMutex);
end.
