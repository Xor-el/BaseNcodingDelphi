unit Base64Tests;

{$mode delphiunicode}
{$WARNINGS OFF}

interface

uses
  Classes,
  SysUtils,
  fpcunit,
  testregistry,
  Base64,
  BaseTests,
  BcpBase64,
  BcpUtils;

type

  TBase64Tests = class(TTestCase)

  strict private
    class function Helper(const InString: string): string; static;
    class var
    F_btInstance: TBaseNcodingTests;

  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure EncodeDecodeTest(const str: string);
    procedure EncodeDecodeTestDefaultTextEncoding(const str: string);
    procedure EncodeDecodeTestUnicodeTextEncoding(const str: string);
    procedure Base64CompareToStandard(const str: string);

  published
    procedure CallEncodeDecodeTest();
    procedure CallEncodeDecodeTestDefaultTextEncoding();
    procedure CallEncodeDecodeTestUnicodeTextEncoding();
    procedure TailTests;
    procedure CallBase64CompareToStandard();
  end;

implementation

procedure TBase64Tests.SetUp;
begin
  F_btInstance := TBaseNcodingTests.Create();
  F_btInstance.FConverter := TBase64.Create();
end;

procedure TBase64Tests.TearDown;
begin
  F_btInstance.Free;
end;

procedure TBase64Tests.CallEncodeDecodeTest();
var
  i: integer;
begin
  for i := 0 to Length(F_btInstance.sArray) - 1 do
  begin
    EncodeDecodeTest(F_btInstance.sArray[i]);
  end;
end;

procedure TBase64Tests.EncodeDecodeTest(const str: string);
var
  encoded, decoded: string;
begin
  encoded := F_btInstance.FConverter.EncodeString(str);
  decoded := F_btInstance.FConverter.DecodeToString(encoded);

  CheckEquals(str, decoded);
end;

procedure TBase64Tests.CallEncodeDecodeTestDefaultTextEncoding();

begin

    EncodeDecodeTestDefaultTextEncoding(F_btInstance.sArray[0]);

end;

procedure TBase64Tests.EncodeDecodeTestDefaultTextEncoding(const str: string);
var
  encoded, decoded: string;
begin
  F_btInstance.FConverter.Encoding := TEncoding.Default;
  encoded := F_btInstance.FConverter.EncodeString(str);
  decoded := F_btInstance.FConverter.DecodeToString(encoded);

  CheckEquals(str, decoded);
end;

procedure TBase64Tests.CallEncodeDecodeTestUnicodeTextEncoding();
var
  i: integer;
begin
  for i := 0 to Length(F_btInstance.sArray) - 1 do
  begin
    EncodeDecodeTestUnicodeTextEncoding(F_btInstance.sArray[i]);
  end;
end;

procedure TBase64Tests.EncodeDecodeTestUnicodeTextEncoding(const str: string);
var
  encoded, decoded: string;
begin
  F_btInstance.FConverter.Encoding := TEncoding.Default;
  encoded := F_btInstance.FConverter.EncodeString(str);
  decoded := F_btInstance.FConverter.DecodeToString(encoded);

  CheckEquals(str, decoded);
end;

procedure TBase64Tests.TailTests;
var
  testChar: char;
  strBuilder: string;
  bitsPerChar, bitsPerByte, charByteBitsLcm, maxTailLength, Count, i: integer;
  str, encoded: string;
  c: char;
begin
  testChar := 'a';
  strBuilder := '';
  if ((F_btInstance.FConverter.HaveSpecial) and
    (Trunc(F_btInstance.FConverter.BitsPerChars) mod 1 = 0) and
    (TUtils.IsPowerOf2(UInt32(Trunc(F_btInstance.FConverter.BitsPerChars))))) then
  begin
    bitsPerChar := Trunc(F_btInstance.FConverter.BitsPerChars);
    bitsPerByte := 8;
    charByteBitsLcm := TUtils.LCM(bitsPerByte, bitsPerChar);
    maxTailLength := charByteBitsLcm div bitsPerByte - 1;

    for i := 0 to (maxTailLength + 2) do
    begin
      str := strBuilder;
      encoded := F_btInstance.FConverter.EncodeString(str);
      Count := 0;
      for c in encoded do
      begin
        if c = F_btInstance.FConverter.Special then
          Inc(Count);
      end;

      if i = 0 then
        CheckEquals(0, Count)
      else
        CheckEquals
        ((maxTailLength - (i - 1) mod (maxTailLength + 1)), Count);

      CheckEquals(str, F_btInstance.FConverter.DecodeToString(encoded));
      strBuilder := strBuilder + (testChar);
    end;
  end;
end;

class function TBase64Tests.Helper(const InString: string): string;
begin
  Result := EncodeStringBase64(InString);
end;

procedure TBase64Tests.Base64CompareToStandard(const str: string);
var
  encoded, base64standard: string;
begin
  encoded := F_btInstance.FConverter.EncodeString(str);
  base64standard := Helper(str);
  CheckEquals(base64standard, encoded);
end;

procedure TBase64Tests.CallBase64CompareToStandard();
var
  i: integer;
begin
  for i := 0 to Length(F_btInstance.sArray) - 1 do
  begin
    Base64CompareToStandard(F_btInstance.sArray[i]);
  end;
end;

initialization

  RegisterTest(TBase64Tests);
end.
