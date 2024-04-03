# Delphi Shannon Word Pairs
An implementation of [Claude Shannon's](https://en.wikipedia.org/wiki/Claude_Shannon) Word Pairs written in Delphi with ChatGPT. Includes DUnitX unit tests, a FireMonkey sample app, and some test data.

![Claude Shannon's Word Pairs with Delphi and ChatGPT](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/blob/main/Documentation/Delphi-Shannon-Word-Pairs(wide).jpg?raw=true)

This was created to demonstrate the process of using ChatGPT to generate Delphi code while also highlighting the similarities between Claude Shannon's word pairs and large langauge models.

 * [Blog post](https://gdksoftware.com/knowledgebase/writing-delphi-code-with-chatgpt-4-thanks-to-claude-shannon) for more information
 * [Conversation log from ChatGPT](https://chat.openai.com/share/4e41c575-c1cc-4fd2-975f-f4f46aa522b7) to see the process
   * [Commentary on the chat log](https://docs.google.com/document/d/e/2PACX-1vSuB7gXH9BO_IN5MgJv3lcImVdrZ6jNtw3kqXG4Gc4GydNNVzHqMf7e27cYFG_wrNDqmLWZCqVTE09R/pub)
   * [PDF version of chat log](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/blob/main/Documentation/Delphi%20Shannon%20Word%20Pairs%20-%20ChatGPT4%20Conversation.pdf)

## Contents:

* [Shannonizer.pas](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/blob/main/Shannonizer.pas) is the core of the word pair analysis and generation system.
* [Sample](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/tree/main/Sample) folder contains a FireMonkey sample app and some test data based on [Shakespeare's Romeo and Juliet](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/blob/main/Sample/Romeo.txt).
* [Tests](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/tree/main/Tests) contains a small battery of DUnitX unit tests.

## Usage:

Here is the interface of the TShannonizer class

```Delphi
  /// Analyzes test for the how frequently one word follows another.
  /// When given a seed word, automatically generates random new text
  /// based on the previously analyzed frequence.
  TShannonizer = class
  private
    FProbabilities: TTokenProbability;
    FFrequencies: TTokenFrequencies;
  public
    constructor Create;
    destructor Destroy; override;
    /// Converts and removes problematic characters and whitespace
    class function CleanInputText(const Text: string): string; static;
    /// Extracts the last token from the input text for use in generating new text
    class function ExtractLastToken(const Text: string): string; static;
    /// Tokenizes the input text and creates a frequency analysis
    /// (Automatically calls CleanInputText)
    procedure AnalyzeText(const Text: string);
    /// Uses the last token from StartWord to seed new generated text.
    /// Stops after Length tokens (words) or if a new word cannot be found.
    /// Uses the RandSeed to randomize the output.
    function GenerateText(const StartWord: string; Length: Integer): string;
    /// Loads a previously saved analysis from file
    procedure LoadFromFile(const FileName: string);
    /// Saves the current analysis to file
    procedure SaveToFile(const FileName: string);
    /// Serializes the current analysis to a string
    function SaveToString: string;
    /// Serializes the current analysis to a steam (used by SaveToFile and SaveToString)
    procedure SaveToStream(Stream: TStream);
    /// Loads analysis data from a string
    procedure LoadFromString(const DataString: string);
    /// Loads analysis data from a stream (used by LoadFromStream and LoadFromFile)
    procedure LoadFromStream(Stream: TStream);
    /// Clears all token and frequency infromation.
    /// Multiple AnalyzeText or Load calls will append to the existing analysis.
    procedure Clear;
  end;
```

## Sample UI:

Same sample program starts with some text from Shakespeare's Romeo and Juliet loaded in and ready for analysis

![Sample program user interface](https://github.com/jimmckeeth/Delphi-Shannon-Word-Pairs/assets/821930/acd9cdc1-02ed-4587-b058-7cbc733e5b30)

1 Load text for analysis.
2 Save the current text from the memo - it could be generated or modified.
3 Analyize the contents of the current memo - appended to any existing analysis
4 Generate text based on the last token in the memo
5 How many tokens to generate
6 Change the random seed
7 Randomize the seed
8 Save the analysis to a file
9 Load analysis from a file (appending to any existing analysis)
10 Clear the analysis
