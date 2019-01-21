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
  System.SysUtils
{$ELSE}
  SysUtils
{$ENDIF}
  ;

type
  TLFProcedureCallback = procedure(const Error: Exception);
  TLFMethodCallback = procedure(const Error: Exception) of object;
  {$IFDEF DELPHI_HAS_CLOSURES}
  TLFClosureCallback = reference to procedure(const Error: Exception);
  {$ENDIF}

(*
    PROCEDURE: SetHostProductId()

    PURPOSE: Sets the product id of your application.

    PARAMETERS:
    * ProductId - the unique product id of your application as mentioned
      on the product page in the dashboard.

    EXCEPTIOND: ELFProductIdException
*)

procedure SetHostProductId(const ProductId: UnicodeString);

(*
    PROCEDURE: SetHostUrl()

    PURPOSE: Sets the network address of the LexFloatServer.

    The url format should be: http://[ip or hostname]:[port]

    PARAMETERS:
    * HostUrl - url string having the correct format

    EXCEPTIONS: ELFProductIdException, ELFHostURLException
*)

procedure SetHostUrl(const HostUrl: UnicodeString);

(*
    PROCEDURE: SetFloatingLicenseCallback()

    PURPOSE: Sets the renew license callback function.

    Whenever the license lease is about to expire, a renew request is sent to the
    server. When the request completes, the license callback function
    gets invoked with one of the following status codes:

    LF_OK, LF_E_INET, LF_E_LICENSE_EXPIRED_INET, LF_E_LICENSE_NOT_FOUND, LF_E_CLIENT, LF_E_IP,
    LF_E_SERVER, LF_E_TIME, LF_E_SERVER_LICENSE_NOT_ACTIVATED,LF_E_SERVER_TIME_MODIFIED,
    LF_E_SERVER_LICENSE_SUSPENDED, LF_E_SERVER_LICENSE_EXPIRED, LF_E_SERVER_LICENSE_GRACE_PERIOD_OVER

    PARAMETERS:
    * Callback - name of the callback procedure, method or closure
    * Synchronized - whether callback must be invoked in main (GUI) thread
    using TThread.Synchronize
    Usually True for GUI applications and handlers like TForm1.OnLexFloatClient
    Must be False if there is no GUI message loop, like in console applications,
    but then another thread synchronization measures must be used.

    EXCEPTIONS: ELFProductIdException
*)

procedure SetFloatingLicenseCallback(Callback: TLFProcedureCallback; Synchronized: Boolean); overload;
procedure SetFloatingLicenseCallback(Callback: TLFMethodCallback; Synchronized: Boolean); overload;
{$IFDEF DELPHI_HAS_CLOSURES}
procedure SetFloatingLicenseCallback(Callback: TLFClosureCallback; Synchronized: Boolean); overload;
{$ENDIF}

(*
    PROCEDURE: ResetFloatingLicenseCallback()

    PURPOSE: Resets the renew license callback function.

    EXCEPTIONS: ELFProductIdException
*)

procedure ResetFloatingLicenseCallback;

(*
    PROCEDURE: SetFloatingClientMetadata()

    PURPOSE: Sets the floating client metadata.

    The  metadata appears along with the license details of the license
    in LexFloatServer dashboard.

    PARAMETERS:
    * Key - string of maximum length 256 characters with utf-8 encoding.
    * Value - string of maximum length 256 characters with utf-8 encoding.

    EXCEPTIONS: ELFProductIdException, ELFMetadataKeyLengthException,
    ELFMetadataValueLengthException, ELFFloatingClientMetadataLimitException
*)

procedure SetFloatingClientMetadata(const Key, Value: UnicodeString);

(*
    FUNCTION: GetHostLicenseMetadata()

    PURPOSE: Get the value of the license metadata field associated with the LexFloatServer license.

    PARAMETERS:
    * Key - key of the metadata field whose value you want to get

    RESULT: Value of the license metadata field associated with the LexFloatServer license

    EXCEPTIONS: ELFProductIdException, ELFNoLicenseException,
    ELFBufferSizeException, ELFMetadataKeyNotFoundException
*)

function GetHostLicenseMetadata(const Key: UnicodeString): UnicodeString;

(*
    FUNCTION: GetHostLicenseExpiryDate()

    PURPOSE: Gets the license expiry date timestamp of the LexFloatServer license.

    RESULT: License expiry date timestamp of the LexFloatServer license

    EXCEPTIONS: ELFProductIdException, ELFNoLicenseException
*)

function GetHostLicenseExpiryDate: TDateTime;

(*
    PROCEDURE: RequestFloatingLicense()

    PURPOSE: Sends the request to lease the license from the LexFloatServer.

    EXCEPTIONS: ELFFailException, ELFProductIdException,
    ELFLicenseExistsException, ELFHostURLException, ELFCallbackException,
    ELFLicenseLimitReachedException, ELFInetException, ELFTimeException,
    ELFClientException, ELFIPException, ELFServerException,
    ELFServerLicenseNotActivatedException, ELFServerTimeModifiedException,
    ELFServerLicenseSuspendedException,
    ELFServerLicenseGracePeriodOverException, ELFServerLicenseExpiredException
*)

procedure RequestFloatingLicense;

(*
    PROCEDURE: DropFloatingLicense()

    PURPOSE: Sends the request to the LexFloatServer to free the license.

    Call this function before you exit your application to prevent zombie licenses.

    EXCEPTIONS: ELFProductIdException, ELFNoLicenseException,
    ELFHostURLException, ELFCallbackException, ELFInetException,
    ELFLicenseNotFoundException, ELFClientException, ELFIPException,
    ELFServerException, ELFServerLicenseNotActivatedException,
    ELFServerTimeModifiedException, ELFServerLicenseSuspendedException,
    ELFServerLicenseGracePeriodOverException, ELFServerLicenseExpiredException
*)

procedure DropFloatingLicense;

(*
    FUNCTION: HasFloatingLicense()

    PURPOSE: Checks whether any license has been leased or not. If yes,
    it returns True.

    RESULT: Boolean value

    EXCEPTIONS: LF_E_PRODUCT_ID
*)

function HasFloatingLicense: Boolean;

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
        CODE: LF_E_HOST_URL

        MESSAGE: Missing or invalid server url.
    *)

  ELFHostURLException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_TIME

        MESSAGE: Ensure system date and time settings are correct.
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
        CODE: LF_E_NO_LICENSE

        MESSAGE: License has not been leased yet.
    *)

  ELFNoLicenseException = class(ELFException)
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
        CODE: LF_E_LICENSE_NOT_FOUND

        MESSAGE: License does not exist on server or has already expired. This
        happens when the request to refresh the license is delayed.
    *)

  ELFLicenseNotFoundException = class(ELFException)
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
        CODE: LF_E_LICENSE_LIMIT_REACHED

        MESSAGE: The server has reached it's allowed limit of floating licenses.
    *)

  ELFLicenseLimitReachedException = class(ELFException)
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
        CODE: LF_E_METADATA_KEY_LENGTH

        MESSAGE: Metadata key length is more than 256 characters.
    *)

  ELFMetadataKeyLengthException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_METADATA_VALUE_LENGTH

        MESSAGE: Metadata value length is more than 256 characters.
    *)

  ELFMetadataValueLengthException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_FLOATING_CLIENT_METADATA_LIMIT

        MESSAGE: The floating client has reached it's metadata fields limit.
    *)

  ELFFloatingClientMetadataLimitException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_IP

        MESSAGE: IP address is not allowed.
    *)

  ELFIPException = class(ELFException)
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

    (*
        CODE: LF_E_SERVER

        MESSAGE: Server error.
    *)

  ELFServerException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER_TIME_MODIFIED

        MESSAGE: System time on server has been tampered with. Ensure
        your date and time settings are correct on the server machine.
    *)

  ELFServerTimeModifiedException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER_LICENSE_NOT_ACTIVATED

        MESSAGE: The server has not been activated using a license key.
    *)

  ELFServerLicenseNotActivatedException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER_LICENSE_EXPIRED

        MESSAGE: The server license has expired.
    *)

  ELFServerLicenseExpiredException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER_LICENSE_SUSPENDED

        MESSAGE: The server license has been suspended.
    *)

  ELFServerLicenseSuspendedException = class(ELFException)
  public
    constructor Create;
  end;

    (*
        CODE: LF_E_SERVER_LICENSE_GRACE_PERIOD_OVER

        MESSAGE: The grace period for server license is over.
    *)

  ELFServerLicenseGracePeriodOverException = class(ELFException)
  public
    constructor Create;
  end;

implementation

uses
{$IFDEF DELPHI_UNITS_SCOPED}
  System.TypInfo, System.DateUtils, System.Classes, Winapi.Windows
{$ELSE}
  TypInfo, DateUtils, Classes, Windows
{$ENDIF}
  ;

const
  LexFloatClient_DLL = 'LexFloatClient.dll';

(*** Return Codes ***)

const
  LF_OK = HRESULT(0);
  LF_FAIL = HRESULT(1);
  LF_E_PRODUCT_ID = HRESULT(40);
  LF_E_CALLBACK = HRESULT(41);
  LF_E_HOST_URL = HRESULT(42);
  LF_E_TIME = HRESULT(43);
  LF_E_INET = HRESULT(44);
  LF_E_NO_LICENSE = HRESULT(45);
  LF_E_LICENSE_EXISTS = HRESULT(46);
  LF_E_LICENSE_NOT_FOUND = HRESULT(47);
  LF_E_LICENSE_EXPIRED_INET = HRESULT(48);
  LF_E_LICENSE_LIMIT_REACHED = HRESULT(49);
  LF_E_BUFFER_SIZE = HRESULT(50);
  LF_E_METADATA_KEY_NOT_FOUND = HRESULT(51);
  LF_E_METADATA_KEY_LENGTH = HRESULT(52);
  LF_E_METADATA_VALUE_LENGTH = HRESULT(53);
  LF_E_FLOATING_CLIENT_METADATA_LIMIT = HRESULT(54);
  LF_E_IP = HRESULT(60);
  LF_E_CLIENT = HRESULT(70);
  LF_E_SERVER = HRESULT(71);
  LF_E_SERVER_TIME_MODIFIED = HRESULT(72);
  LF_E_SERVER_LICENSE_NOT_ACTIVATED = HRESULT(73);
  LF_E_SERVER_LICENSE_EXPIRED = HRESULT(74);
  LF_E_SERVER_LICENSE_SUSPENDED = HRESULT(75);
  LF_E_SERVER_LICENSE_GRACE_PERIOD_OVER = HRESULT(76);

function Thin_SetHostProductId(const productId: PWideChar): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetHostProductId';

procedure SetHostProductId(const ProductId: UnicodeString);
begin
  if not ELFError.CheckOKFail(Thin_SetHostProductId(PWideChar(ProductId))) then
    raise ELFFailException.Create
      ('Failed to set the product id of application');
end;

function Thin_SetHostUrl(const hostUrl: PWideChar): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetHostUrl';

procedure SetHostUrl(const HostUrl: UnicodeString);
begin
  if not ELFError.CheckOKFail(Thin_SetHostUrl(PWideChar(HostUrl))) then
    raise ELFFailException.Create
      ('Failed to set the network address of the LexFloatServer');
end;

type
  TLFThin_CallbackType = procedure (StatusCode: LongWord); cdecl;

function Thin_SetFloatingLicenseCallback(callback: TLFThin_CallbackType): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetFloatingLicenseCallback';

type
  TLFFloatingLicenseCallbackKind =
    (lckNone,
     lckProcedure,
     lckMethod
     {$IFDEF DELPHI_HAS_CLOSURES}, lckClosure{$ENDIF});

var
  LFFloatingLicenseCallbackKind: TLFFloatingLicenseCallbackKind = lckNone;
  LFProcedureCallback: TLFProcedureCallback;
  LFMethodCallback: TLFMethodCallback;
  {$IFDEF DELPHI_HAS_CLOSURES}
  LFClosureCallback: TLFClosureCallback;
  {$ENDIF}
  LFFloatingLicenseCallbackSynchronized: Boolean;
  LFStatusCode: HRESULT;
  LFFloatingLicenseCallbackMutex: TRTLCriticalSection;

type
  TLFThin_CallbackProxyClass = class
  public
    class procedure Invoke;
  end;

class procedure TLFThin_CallbackProxyClass.Invoke;
  procedure DoInvoke(const Error: Exception);
  begin
    case LFFloatingLicenseCallbackKind of
      lckNone: Exit;
      lckProcedure:
        if Assigned(LFProcedureCallback) then
          LFProcedureCallback(Error);
      lckMethod:
        if Assigned(LFMethodCallback) then
          LFMethodCallback(Error);
      {$IFDEF DELPHI_HAS_CLOSURES}
      lckClosure:
        if Assigned(LFClosureCallback) then
          LFClosureCallback(Error);
      {$ENDIF}
    else
      // there should be default logging here like NSLog, but there is none in Delphi
    end;
  end;

var
  FailError: Exception;

begin
  try
    EnterCriticalSection(LFFloatingLicenseCallbackMutex);
    try
      case LFFloatingLicenseCallbackKind of
        lckNone: Exit;
        lckProcedure: if not Assigned(LFProcedureCallback) then Exit;
        lckMethod: if not Assigned(LFMethodCallback) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(LFClosureCallback) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      FailError := nil;
      try
        FailError := ELFError.CreateByCode(LFStatusCode);
        DoInvoke(FailError);
      finally
        FreeAndNil(FailError);
      end;
    finally
      // This recursive mutex prevents the following scenario:
      //
      // (Main thread)    SetFloatingLicenseCallback
      // (Tangent thread) LFThin_CallbackProxy going to invoke X.OnLexFloatClient
      // (Main thread)    ResetFloatingLicenseCallback
      // (Main thread)    X.Free
      //
      // Main thread is not allowed to proceed to X.Free until callback is finished
      // On the other hand, if callback removes itself, recursive mutex will allow that
      LeaveCriticalSection(LFFloatingLicenseCallbackMutex);
    end;
  except
    // there should be default logging here like NSLog, but there is none in Delphi
  end;
end;

procedure LFThin_CallbackProxy(StatusCode: LongWord); cdecl;
begin
  try
    EnterCriticalSection(LFFloatingLicenseCallbackMutex);
    try
      case LFFloatingLicenseCallbackKind of
        lckNone: Exit;
        lckProcedure: if not Assigned(LFProcedureCallback) then Exit;
        lckMethod: if not Assigned(LFMethodCallback) then Exit;
        {$IFDEF DELPHI_HAS_CLOSURES}
        lckClosure: if not Assigned(LFClosureCallback) then Exit;
        {$ENDIF}
      else
        // there should be default logging here like NSLog, but there is none in Delphi
      end;

      LFStatusCode := HRESULT(StatusCode);
      if not LFFloatingLicenseCallbackSynchronized then
      begin
        TLFThin_CallbackProxyClass.Invoke;
        Exit;
      end;
    finally
      LeaveCriticalSection(LFFloatingLicenseCallbackMutex);
    end;

    // Race condition here
    //
    // Invoke should probably run exactly the same (captured) handler,
    // but instead it reenters mutex, and handler can be different at
    // that moment. For most sane use cases behavior should be sound
    // anyway.

    TThread.Synchronize(nil, TLFThin_CallbackProxyClass.Invoke);
  except
    // there should be default logging here like NSLog, but there is none in Delphi
  end;
end;

procedure SetFloatingLicenseCallback(Callback: TLFProcedureCallback; Synchronized: Boolean); overload;
begin
  EnterCriticalSection(LFFloatingLicenseCallbackMutex);
  try
    LFProcedureCallback := Callback;
    LFFloatingLicenseCallbackSynchronized := Synchronized;
    LFFloatingLicenseCallbackKind := lckProcedure;

    if not ELFError.CheckOKFail(Thin_SetFloatingLicenseCallback(LFThin_CallbackProxy)) then
      raise
      ELFFailException.Create('Failed to set the renew license callback function');
  finally
    LeaveCriticalSection(LFFloatingLicenseCallbackMutex);
  end;
end;

procedure SetFloatingLicenseCallback(Callback: TLFMethodCallback; Synchronized: Boolean); overload;
begin
  EnterCriticalSection(LFFloatingLicenseCallbackMutex);
  try
    LFMethodCallback := Callback;
    LFFloatingLicenseCallbackSynchronized := Synchronized;
    LFFloatingLicenseCallbackKind := lckMethod;

    if not ELFError.CheckOKFail(Thin_SetFloatingLicenseCallback(LFThin_CallbackProxy)) then
      raise
      ELFFailException.Create('Failed to set the renew license callback function');
  finally
    LeaveCriticalSection(LFFloatingLicenseCallbackMutex);
  end;
end;

{$IFDEF DELPHI_HAS_CLOSURES}
procedure SetFloatingLicenseCallback(Callback: TLFClosureCallback; Synchronized: Boolean); overload;
begin
  EnterCriticalSection(LFFloatingLicenseCallbackMutex);
  try
    LFClosureCallback := Callback;
    LFFloatingLicenseCallbackSynchronized := Synchronized;
    LFFloatingLicenseCallbackKind := lckClosure;

    if not ELFError.CheckOKFail(Thin_SetFloatingLicenseCallback(LFThin_CallbackProxy)) then
      raise
      ELFFailException.Create('Failed to set the renew license callback function');
  finally
    LeaveCriticalSection(LFFloatingLicenseCallbackMutex);
  end;
end;
{$ENDIF}

procedure LFThin_CallbackDummy(StatusCode: LongWord); cdecl;
begin
  ;
end;

procedure ResetFloatingLicenseCallback;
begin
  EnterCriticalSection(LFFloatingLicenseCallbackMutex);
  try
    LFFloatingLicenseCallbackKind := lckNone;

    if not ELFError.CheckOKFail(Thin_SetFloatingLicenseCallback(LFThin_CallbackDummy)) then
      raise
      ELFFailException.Create('Failed to reset the renew license callback function');
  finally
    LeaveCriticalSection(LFFloatingLicenseCallbackMutex);
  end;
end;

function Thin_SetFloatingClientMetadata(const key, value: PWideChar): HRESULT; cdecl;
  external LexFloatClient_DLL name 'SetFloatingClientMetadata';

procedure SetFloatingClientMetadata(const Key, Value: UnicodeString);
begin
  if not ELFError.CheckOKFail(Thin_SetFloatingClientMetadata(PWideChar(Key), PWideChar(Value))) then
    raise ELFFailException.Create
      ('Failed to set the floating client metadata');
end;

function Thin_GetHostLicenseMetadata(const key: PWideChar; out value; length: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'GetHostLicenseMetadata';

function GetHostLicenseMetadata(const Key: UnicodeString): UnicodeString;
var
  Arg1: PWideChar;
  ErrorCode: HRESULT;
  function Try256(var OuterResult: UnicodeString): Boolean;
  var
    Buffer: array[0 .. 255] of WideChar;
  begin
    ErrorCode := Thin_GetHostLicenseMetadata(Arg1, Buffer, Length(Buffer));
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
      ErrorCode := Thin_GetHostLicenseMetadata(Arg1, PWideChar(Buffer)^, Size);
      Result := ErrorCode <> LF_E_BUFFER_SIZE;
    until Result or (Size >= 128 * 1024);
    if ErrorCode = LF_OK then OuterResult := PWideChar(Buffer);
  end;
begin
  Arg1 := PWideChar(Key);
  if not Try256(Result) then TryHigh(Result);
  if not ELFError.CheckOKFail(ErrorCode) then
    raise ELFFailException.CreateFmt('Failed to get the value of the license metadata field %s associated with the LexFloatServer license', [Key]);
end;

function Thin_GetHostLicenseExpiryDate(out expiryDate: LongWord): HRESULT; cdecl;
  external LexFloatClient_DLL name 'GetHostLicenseExpiryDate';

function GetHostLicenseExpiryDate: TDateTime;
var
  ExpiryDate: LongWord;
begin
  if not ELFError.CheckOKFail(Thin_GetHostLicenseExpiryDate(ExpiryDate)) then
    raise
    ELFFailException.Create('Failed to get the license expiry date timestamp of the LexFloatServer license');
  Result := UnixToDateTime(ExpiryDate);
end;

function Thin_RequestFloatingLicense: HRESULT; cdecl;
  external LexFloatClient_DLL name 'RequestFloatingLicense';

procedure RequestFloatingLicense;
begin
  if not ELFError.CheckOKFail(Thin_RequestFloatingLicense) then
    raise
    ELFFailException.Create('Failed to send the request to lease the license from the LexFloatServer');
end;

function Thin_DropFloatingLicense: HRESULT; cdecl;
  external LexFloatClient_DLL name 'DropFloatingLicense';

procedure DropFloatingLicense;
begin
  if not ELFError.CheckOKFail(Thin_DropFloatingLicense) then
    raise
    ELFFailException.Create('Failed to sends the request to the LexFloatServer to free the license');
end;

function Thin_HasFloatingLicense: HRESULT; cdecl;
  external LexFloatClient_DLL name 'HasFloatingLicense';

function HasFloatingLicense: Boolean;
var
  Status: HRESULT;
begin
  Status := Thin_HasFloatingLicense;
  if Status = LF_E_NO_LICENSE then
  begin
    Result := False;
    Exit;
  end;
  if not ELFError.CheckOKFail(Status) then
    raise
    ELFFailException.Create('Failed to check whether any license has been leased or not');
  Result := True;
end;

class function ELFError.CreateByCode(ErrorCode: HRESULT): ELFError;
begin
  case ErrorCode of
    LF_OK: Result := nil;
    LF_FAIL: Result := ELFFailException.Create;
    LF_E_PRODUCT_ID: Result := ELFProductIdException.Create;
    LF_E_CALLBACK: Result := ELFCallbackException.Create;
    LF_E_HOST_URL: Result := ELFHostURLException.Create;
    LF_E_TIME: Result := ELFTimeException.Create;
    LF_E_INET: Result := ELFInetException.Create;
    LF_E_NO_LICENSE: Result := ELFNoLicenseException.Create;
    LF_E_LICENSE_EXISTS: Result := ELFLicenseExistsException.Create;
    LF_E_LICENSE_NOT_FOUND: Result := ELFLicenseNotFoundException.Create;
    LF_E_LICENSE_EXPIRED_INET: Result := ELFLicenseExpiredInetException.Create;
    LF_E_LICENSE_LIMIT_REACHED: Result := ELFLicenseLimitReachedException.Create;
    LF_E_BUFFER_SIZE: Result := ELFBufferSizeException.Create;
    LF_E_METADATA_KEY_NOT_FOUND: Result := ELFMetadataKeyNotFoundException.Create;
    LF_E_METADATA_KEY_LENGTH: Result := ELFMetadataKeyLengthException.Create;
    LF_E_METADATA_VALUE_LENGTH: Result := ELFMetadataValueLengthException.Create;
    LF_E_FLOATING_CLIENT_METADATA_LIMIT: Result := ELFFloatingClientMetadataLimitException.Create;
    LF_E_IP: Result := ELFIPException.Create;
    LF_E_CLIENT: Result := ELFClientException.Create;
    LF_E_SERVER: Result := ELFServerException.Create;
    LF_E_SERVER_TIME_MODIFIED: Result := ELFServerTimeModifiedException.Create;
    LF_E_SERVER_LICENSE_NOT_ACTIVATED: Result := ELFServerLicenseNotActivatedException.Create;
    LF_E_SERVER_LICENSE_EXPIRED: Result := ELFServerLicenseExpiredException.Create;
    LF_E_SERVER_LICENSE_SUSPENDED: Result := ELFServerLicenseSuspendedException.Create;
    LF_E_SERVER_LICENSE_GRACE_PERIOD_OVER: Result := ELFServerLicenseGracePeriodOverException.Create;
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

constructor ELFHostURLException.Create;
begin
  inherited Create('Missing or invalid server url');
  FErrorCode := LF_E_HOST_URL;
end;

constructor ELFTimeException.Create;
begin
  inherited Create('Ensure system date and time settings are correct');
  FErrorCode := LF_E_TIME;
end;

constructor ELFInetException.Create;
begin
  inherited Create('Failed to connect to the server due to network error');
  FErrorCode := LF_E_INET;
end;

constructor ELFNoLicenseException.Create;
begin
  inherited Create('License has not been leased yet');
  FErrorCode := LF_E_NO_LICENSE;
end;

constructor ELFLicenseExistsException.Create;
begin
  inherited Create('License has already been leased');
  FErrorCode := LF_E_LICENSE_EXISTS;
end;

constructor ELFLicenseNotFoundException.Create;
begin
  inherited Create('License does not exist on server or has already expired. This ' +
    'happens when the request to refresh the license is delayed');
  FErrorCode := LF_E_LICENSE_NOT_FOUND;
end;

constructor ELFLicenseExpiredInetException.Create;
begin
  inherited Create('License lease has expired due to network error. This ' +
    'happens when the request to refresh the license fails due to ' +
    'network error');
  FErrorCode := LF_E_LICENSE_EXPIRED_INET;
end;

constructor ELFLicenseLimitReachedException.Create;
begin
  inherited Create('The server has reached it''s allowed limit of floating licenses');
  FErrorCode := LF_E_LICENSE_LIMIT_REACHED;
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

constructor ELFMetadataKeyLengthException.Create;
begin
  inherited Create('Metadata key length is more than 256 characters');
  FErrorCode := LF_E_METADATA_KEY_LENGTH;
end;

constructor ELFMetadataValueLengthException.Create;
begin
  inherited Create('Metadata value length is more than 256 characters');
  FErrorCode := LF_E_METADATA_VALUE_LENGTH;
end;

constructor ELFFloatingClientMetadataLimitException.Create;
begin
  inherited Create('The floating client has reached it''s metadata fields limit');
  FErrorCode := LF_E_FLOATING_CLIENT_METADATA_LIMIT;
end;

constructor ELFIPException.Create;
begin
  inherited Create('IP address is not allowed');
  FErrorCode := LF_E_IP;
end;

constructor ELFClientException.Create;
begin
  inherited Create('Client error');
  FErrorCode := LF_E_CLIENT;
end;

constructor ELFServerException.Create;
begin
  inherited Create('Server error');
  FErrorCode := LF_E_SERVER;
end;

constructor ELFServerTimeModifiedException.Create;
begin
  inherited Create('System time on server has been tampered with. Ensure ' +
    'your date and time settings are correct on the server machine');
  FErrorCode := LF_E_SERVER_TIME_MODIFIED;
end;

constructor ELFServerLicenseNotActivatedException.Create;
begin
  inherited Create('The server has not been activated using a license key');
  FErrorCode := LF_E_SERVER_LICENSE_NOT_ACTIVATED;
end;

constructor ELFServerLicenseExpiredException.Create;
begin
  inherited Create('The server license has expired');
  FErrorCode := LF_E_SERVER_LICENSE_EXPIRED;
end;

constructor ELFServerLicenseSuspendedException.Create;
begin
  inherited Create('The server license has been suspended');
  FErrorCode := LF_E_SERVER_LICENSE_SUSPENDED;
end;

constructor ELFServerLicenseGracePeriodOverException.Create;
begin
  inherited Create('The grace period for server license is over');
  FErrorCode := LF_E_SERVER_LICENSE_GRACE_PERIOD_OVER;
end;

initialization
  InitializeCriticalSection(LFFloatingLicenseCallbackMutex);
finalization
  try ResetFloatingLicenseCallback; except end;
  DeleteCriticalSection(LFFloatingLicenseCallbackMutex);
end.

