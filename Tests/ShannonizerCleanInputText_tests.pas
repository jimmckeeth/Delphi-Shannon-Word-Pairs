unit ShannonizerCleanInputText_tests;

interface

uses
  DUnitX.TestFramework, Shannonizer;

type

  [TestFixture]
  TShannonizerCleanInputTextTests = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_CleanInputText_WithSpaces;

    [Test]
    procedure Test_CleanInputText_WithTabs;

    [Test]
    procedure Test_CleanInputText_WithLineBreaks;

    [Test]
    procedure Test_CleanInputText_WithMixedWhitespace;
  end;

implementation

procedure TShannonizerCleanInputTextTests.Test_CleanInputText_WithSpaces;
begin
  Assert.AreEqual('This is a test.',
    TShannonizer.CleanInputText('This  is a  test. '));
end;

procedure TShannonizerCleanInputTextTests.Test_CleanInputText_WithTabs;
begin
  Assert.AreEqual('This is a test.',
    TShannonizer.CleanInputText('This	is	a	test.'));
end;

procedure TShannonizerCleanInputTextTests.Test_CleanInputText_WithLineBreaks;
begin
  Assert.AreEqual('This is a test.',
    TShannonizer.CleanInputText('This' + sLineBreak + 'is' + sLineBreak + 'a' +
    sLineBreak + 'test.'));
end;

procedure TShannonizerCleanInputTextTests.
  Test_CleanInputText_WithMixedWhitespace;
begin
  Assert.AreEqual('This is a test.',
    TShannonizer.CleanInputText(#13#10'This  '#13'is	' + sLineBreak +
    ' a	'#10'test. '));
end;

procedure TShannonizerCleanInputTextTests.Setup;
begin
end;

procedure TShannonizerCleanInputTextTests.TearDown;
begin
end;

initialization

TDUnitX.RegisterTestFixture(TShannonizerCleanInputTextTests);

end.
