unit Shannonizer_tests;

interface

uses
  DUnitX.TestFramework, Shannonizer;

type

  [TestFixture]
  TTestShannonizer = class(TObject)
  private
    FShannonizer: TShannonizer;
  public
    [Setup]
    procedure SetUp;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestSaveLoadString;
  end;

implementation

procedure TTestShannonizer.SetUp;
begin
  FShannonizer := TShannonizer.Create;
end;

procedure TTestShannonizer.TearDown;
begin
  FShannonizer.Free;
end;

procedure TTestShannonizer.TestSaveLoadString;
var
  OriginalText: string;
  SavedString: string;
  LoadedShannonizer: TShannonizer;
begin
  // Set up some data in FShannonizer
  OriginalText := 'This is a test. This test is only a test.';
  FShannonizer.AnalyzeText(OriginalText);

  // Save to string
  SavedString := FShannonizer.SaveToString;

  // Create a new Shannonizer instance and load from string
  LoadedShannonizer := TShannonizer.Create;
  try
    LoadedShannonizer.LoadFromString(SavedString);

    // Now, perform tests to verify LoadedShannonizer has correctly loaded data
    // For example, check if a known token generates expected next tokens with correct probabilities
    // This part of the test depends on how you've structured your Shannonizer and what public methods or properties are available to inspect its state

    // Placeholder for actual verification logic:
    Assert.IsNotNull(LoadedShannonizer, 'LoadedShannonizer should not be nil.');
    // Further assertions to verify the state of LoadedShannonizer matches expectations

  finally
    LoadedShannonizer.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestShannonizer);

end.

