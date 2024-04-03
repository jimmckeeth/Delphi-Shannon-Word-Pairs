unit ShannonizerExtractLastToken_tests;

interface
uses
  DUnitX.TestFramework,
  Shannonizer; // Ensure this matches the actual unit name where TShannonizer is defined

type

  [TestFixture]
  TExtractLastTokenTests = class(TObject)
  public
    [Test]
    procedure TestWithTrailingSpaces;

    [Test]
    procedure TestWithPunctuation;

    [Test]
    procedure TestWithSingleWord;

    [Test]
    procedure TestWithMultipleWords;

    [Test]
    procedure TestWithNoWords;
  end;

implementation

procedure TExtractLastTokenTests.TestWithTrailingSpaces;
begin
  Assert.AreEqual('token', TShannonizer.ExtractLastToken('This is a token   '));
end;

procedure TExtractLastTokenTests.TestWithPunctuation;
begin
  Assert.AreEqual('sentence.', TShannonizer.ExtractLastToken('This is a sentence.'));
end;

procedure TExtractLastTokenTests.TestWithSingleWord;
begin
  Assert.AreEqual('word', TShannonizer.ExtractLastToken('word'));
end;

procedure TExtractLastTokenTests.TestWithMultipleWords;
begin
  Assert.AreEqual('last', TShannonizer.ExtractLastToken('The very last'));
end;

procedure TExtractLastTokenTests.TestWithNoWords;
begin
  Assert.AreEqual('', TShannonizer.ExtractLastToken('     ')); // Expect an empty string for input of only spaces
end;

initialization
  TDUnitX.RegisterTestFixture(TExtractLastTokenTests);
end.

