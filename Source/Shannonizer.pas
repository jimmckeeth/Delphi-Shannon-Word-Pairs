// https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/
unit Shannonizer;

interface

uses
  System.SysUtils, System.Classes,
  System.Zip, // Add this for zip compression functionality
  System.Generics.Collections;

type
  TTokenProbability = TDictionary<string, TDictionary<string, Integer>>;
  TTokenFrequencies = TDictionary<string, Integer>;

  TShannonizer = class
  private
    FProbabilities: TTokenProbability;
    FFrequencies: TTokenFrequencies;
  public
    class function CleanInputText(const Text: string): string;
    class function ExtractLastToken(const Text: string): string; static;
    constructor Create;
    destructor Destroy; override;
    procedure AnalyzeText(const Text: string);
    function GenerateText(const StartWord: string; Length: Integer): string;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    function SaveToString: string;
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromString(const DataString: string);
    procedure Clear;
  end;

implementation

{ TShannonizer }

const InternalFileName: string = 'Shannonizer.csv';

// Converts CR/LF/TAB and Double spaces into a single space
class function TShannonizer.CleanInputText(const Text: string): string;
var
  I, ResultLen: Integer;
  InSpace, StartTrimming: Boolean;
begin
  SetLength(Result, Length(Text));
  ResultLen := 0;
  InSpace := False;
  StartTrimming := True; // Assume starting with trimming leading spaces

  for I := 1 to Length(Text) do
  begin
    case Text[I] of
      #13, #10, #9, ' ', '|': // Handle CR, LF, tabs, spaces and pipe (used in saving)
        begin
          if not InSpace and not StartTrimming then // If not already in a space sequence and not at the start
          begin
            InSpace := True; // Mark that we're now handling a space
            Inc(ResultLen);
            Result[ResultLen] := ' '; // Replace with a single space
          end;
        end;
    else
      begin
        InSpace := False; // No longer in a space sequence
        StartTrimming := False; // Stop trimming leading spaces
        Inc(ResultLen);
        Result[ResultLen] := Text[I]; // Copy the non-space character
      end;
    end;
  end;

  SetLength(Result, ResultLen); // Trim the Result to the actual length
  // Trim trailing spaces by adjusting the length of the result if necessary
  if (ResultLen > 0) and (Result[ResultLen] = ' ') then
    SetLength(Result, ResultLen - 1);
end;

procedure TShannonizer.Clear;
begin
  // Clear previous analysis
  FProbabilities.Clear;
  FFrequencies.Clear;
end;

class function TShannonizer.ExtractLastToken(const Text: string): string;
var
  I: Integer;
  TokenStarted: Boolean;
begin
  Result := '';
  TokenStarted := False;

  for I := Length(Text) downto 1 do
  begin
    if not CharInSet(Text[I], [#32, #13, #10, #9]) then
    begin
      TokenStarted := True;
      Result := Text[I] + Result;
    end
    else if TokenStarted then
      Break;
  end;
end;


constructor TShannonizer.Create;
begin
  inherited;
  FProbabilities := TTokenProbability.Create;
  FFrequencies := TTokenFrequencies.Create;
end;

destructor TShannonizer.Destroy;
begin
  FProbabilities.Free;
  FFrequencies.Free;
  inherited;
end;

procedure TShannonizer.AnalyzeText(const Text: string);
(*
Tokenization: It splits the input text into an array of lowercase words (Words).
This is a very basic form of tokenization and might need to be expanded to
correctly handle punctuation, whitespace, and other linguistic nuances depending
on your requirements.

Frequency Counting: For each pair of adjacent tokens (Token and NextToken), the
code increments the frequency count of Token in FFrequencies and the occurrence
count of NextToken following Token in FProbabilities.

Data Structures Update: If a token or token pair does not exist in the respective
dictionaries, it gets added with an initial count of 1. If it already exists,
its count is incremented.
*)
var
  Words: TArray<string>;
  Token, NextToken: string;
  I: Integer;
begin
  // Tokenize the input text into words and punctuation.
  // This example uses a simple space to split words, and does not account for punctuation.
  // You may need a more sophisticated tokenizer based on your requirements.
  Words := CleanInputText(Text.ToLower).Split([' ']);

  for I := 0 to High(Words) - 1 do
  begin
    Token := Words[I];
    NextToken := Words[I + 1];

    // Increase the frequency of the token
    if not FFrequencies.ContainsKey(Token) then
      FFrequencies.Add(Token, 1)
    else
      FFrequencies[Token] := FFrequencies[Token] + 1;

    // Handle the token probability mapping
    if not FProbabilities.ContainsKey(Token) then
      FProbabilities.Add(Token, TDictionary<string, Integer>.Create);

    if not FProbabilities[Token].ContainsKey(NextToken) then
      FProbabilities[Token].Add(NextToken, 1)
    else
      FProbabilities[Token][NextToken] := FProbabilities[Token][NextToken] + 1;
  end;

  // Optionally, handle the last token if needed for your model
  Token := Words[High(Words)];
  if not FFrequencies.ContainsKey(Token) then
    FFrequencies.Add(Token, 1)
  else
    FFrequencies[Token] := FFrequencies[Token] + 1;
end;

function TShannonizer.GenerateText(const StartWord: string; Length: Integer): string;
(*
Starting Point: The function begins with a StartWord and appends it to the
result. It then iterates, generating each subsequent word based on the
probabilities until it reaches the desired length or runs out of known word
sequences.

Random Choice Based on Probabilities: For each word, it looks up the next possible
words and their frequencies. It then makes a "random choice" among these next words
weighted by their frequencies. This is where the Markov chain behavior comes in, as
the choice of the next word depends solely on the current word.

Selecting the Next Word: It randomly selects the next word based on the weighted
probabilities by creating a cumulative distribution and selecting a word once the
random choice falls within its range in the distribution.

Handling Unknown Words: If the method encounters a word with no known followers
(not in FProbabilities), it stops generating further words. This might happen if
the input StartWord is not in the analyzed text or if it only appears at the end.

Resulting Text: The generated words are concatenated into a single string,
forming the generated text.
*)
var
  CurrentWord, NextWord: string;
  TotalOccurrences, RandomChoice, Accumulator, I: Integer;
  WordList: TArray<string>;
begin
  Result := ExtractLastToken(StartWord.ToLower.Trim);
  CurrentWord := Result;

  // Generate words up to the desired length
  for I := 1 to Length - 1 do
  begin
    if not FProbabilities.ContainsKey(CurrentWord) then Break; // Stop if no known next word

    TotalOccurrences := 0;
    WordList := FProbabilities[CurrentWord].Keys.ToArray;

    // Calculate total occurrences of next possible words
    for NextWord in WordList do
    begin
      Inc(TotalOccurrences, FProbabilities[CurrentWord][NextWord]);
    end;

    // Make a random choice among the total occurrences
    RandomChoice := Random(TotalOccurrences) + 1;
    Accumulator := 0;

    // Determine the next word based on the random choice
    for NextWord in WordList do
    begin
      Inc(Accumulator, FProbabilities[CurrentWord][NextWord]);
      if Accumulator >= RandomChoice then
      begin
        Result := Result + ' ' + NextWord;
        CurrentWord := NextWord;
        Break;
      end;
    end;
  end;
end;

procedure TShannonizer.LoadFromString(const DataString: string);
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create(DataString, TEncoding.UTF8);
  try
    LoadFromStream(StringStream);
  finally
    StringStream.Free;
  end;
end;

procedure TShannonizer.LoadFromStream(Stream: TStream);
var
  StreamReader: TStreamReader;
  Line, Token, NextToken: string;
  Parts: TArray<string>;
  Count: Integer;
begin
  FProbabilities.Clear;
  FFrequencies.Clear;

  StreamReader := TStreamReader.Create(Stream, TEncoding.UTF8);
  try
    while not StreamReader.EndOfStream do
    begin
      Line := StreamReader.ReadLine;
      Parts := Line.Split(['|']);
      if Length(Parts) = 3 then
      begin
        Token := Parts[0];
        NextToken := Parts[1];
        Count := StrToInt(Parts[2]);

        // Update FProbabilities
        if not FProbabilities.ContainsKey(Token) then
          FProbabilities.Add(Token, TDictionary<string, Integer>.Create);
        if not FProbabilities[Token].ContainsKey(NextToken) then
          FProbabilities[Token].Add(NextToken, Count)
        else
          FProbabilities[Token][NextToken] := Count; // This case might not be necessary depending on your data uniqueness

        // Safely update FFrequencies
        if not FFrequencies.ContainsKey(Token) then
          FFrequencies.Add(Token, Count)
        else
          FFrequencies[Token] := FFrequencies[Token] + Count;
      end;
    end;
  finally
    StreamReader.Free;
  end;
end;


procedure TShannonizer.SaveToStream(Stream: TStream);
(*
Data Serialization: The probabilities are serialized in a simple
token|nextToken|count
*)
var
  StreamWriter: TStreamWriter;
  Token, NextToken: string;
  Count: Integer;
begin
  // Use a simpler form of the constructor
  StreamWriter := TStreamWriter.Create(Stream, TEncoding.UTF8);
  try
    for Token in FProbabilities.Keys do
    begin
      for NextToken in FProbabilities[Token].Keys do
      begin
        Count := FProbabilities[Token][NextToken];
        StreamWriter.WriteLine(Format('%s|%s|%d', [Token, NextToken, Count]));
      end;
    end;
  finally
    StreamWriter.Free;
  end;
end;


function TShannonizer.SaveToString: String;
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create('', TEncoding.UTF8);
  try
    SaveToStream(StringStream);
    Result := StringStream.DataString;
  finally
    StringStream.Free;
  end;
end;

procedure TShannonizer.SaveToFile(const FileName: string);
var
  MemoryStream: TMemoryStream;
  ZipFile: TZipFile;
begin
  MemoryStream := TMemoryStream.Create;
  try
    // Serialize data to MemoryStream
    SaveToStream(MemoryStream);
    MemoryStream.Position := 0; // Reset the stream position after writing

    // Create a new ZipFile and add the MemoryStream content to it
    ZipFile := TZipFile.Create;
    try
      ZipFile.Open(FileName, zmWrite); // Open the zip file for writing
      ZipFile.Add(MemoryStream, InternalFileName); // Add the stream content as 'InternalFileName inside the zip
    finally
      ZipFile.Free;
    end;
  finally
    MemoryStream.Free;
  end;
end;

procedure TShannonizer.LoadFromFile(const FileName: string);
var
  MemoryStream: TMemoryStream;
  ZipFile: TZipFile;
  LocalHeader: TZipHeader;
begin
  //MemoryStream := TMemoryStream.Create;
  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(FileName, zmRead); // Open the zip file for reading
    if ZipFile.FileCount = 0 then
      raise Exception.Create('Zip file is empty.');

    // Extract the content of the first file in the zip to MemoryStream
    ZipFile.Read(InternalFileName, TStream(MemoryStream), LocalHeader, True);
    MemoryStream.Position := 0; // Reset the stream position before reading

    // Deserialize data from MemoryStream
    LoadFromStream(MemoryStream);
  finally
    ZipFile.Free;
    MemoryStream.Free;
  end;
end;


end.

