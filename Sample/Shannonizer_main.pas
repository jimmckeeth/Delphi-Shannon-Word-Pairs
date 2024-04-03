unit Shannonizer_main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Memo.Types, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Memo, Shannonizer, FMX.Edit, FMX.EditBox, FMX.SpinBox;

type
  TForm12 = class(TForm)
    Memo1: TMemo;
    AnalyizeBtn: TButton;
    GenerateBtn: TButton;
    SaveAnalysisBtn: TButton;
    LoadAnalysisBtn: TButton;
    seedEdit: TSpinBox;
    Label1: TLabel;
    tokenEdit: TSpinBox;
    Label2: TLabel;
    randomBtn: TButton;
    SaveAnalysisDialog: TSaveDialog;
    OpenAnalysisDialog: TOpenDialog;
    Label3: TLabel;
    randomChk: TCheckBox;
    ClearBtn: TButton;
    LoadTextBtn: TButton;
    SaveTextBtn: TButton;
    SaveTextDialog: TSaveDialog;
    OpenTextDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AnalyzeButtonClick(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure randomChkClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure LoadTextBtnClick(Sender: TObject);
    procedure SaveTextBtnClick(Sender: TObject);
  private
    { Private declarations }
    FShannon: TShannonizer;
    procedure CheckRandom;
  public
    { Public declarations }
  end;

var
  Form12: TForm12;

implementation

{$R *.fmx}

procedure TForm12.AnalyzeButtonClick(Sender: TObject);
begin
  FShannon.AnalyzeText(Memo1.Text);
  Memo1.Text := 'Romeo';
end;

procedure TForm12.GenerateButtonClick(Sender: TObject);
begin
  CheckRandom;
  RandSeed := Round(seedEdit.Value);

  Memo1.Lines.Add(FShannon.GenerateText(Memo1.Text, 100));
  Memo1.Lines.Add(sLineBreak);
end;

procedure TForm12.CheckRandom;
begin
  if randomChk.IsChecked then
  begin
    Randomize;
    seedEdit.Value := RandSeed;
  end;
end;

procedure TForm12.ClearBtnClick(Sender: TObject);
begin
  Memo1.ClearContent;
  FShannon.Clear;
end;

procedure TForm12.FormCreate(Sender: TObject);
begin
  FShannon := TShannonizer.Create;
end;

procedure TForm12.FormDestroy(Sender: TObject);
begin
  FShannon.Free;
end;

procedure TForm12.LoadBtnClick(Sender: TObject);
begin
  if OpenAnalysisDialog.Execute then
    FShannon.LoadFromFile(OpenAnalysisDialog.FileName);

end;

procedure TForm12.LoadTextBtnClick(Sender: TObject);
begin
  if OpenTextDialog.Execute then
    Memo1.Lines.LoadFromFile(OpenTextDialog.FileName);

end;

procedure TForm12.randomChkClick(Sender: TObject);
begin
  randomChk.IsChecked := not randomChk.IsChecked;
  CheckRandom;
end;

procedure TForm12.SaveBtnClick(Sender: TObject);
begin
  if SaveAnalysisDialog.Execute then
    FShannon.SaveToFile(SaveAnalysisDialog.FileName);

end;

procedure TForm12.SaveTextBtnClick(Sender: TObject);
begin
  if SaveTextDialog.Execute then
    Memo1.Lines.SaveToFile(SaveTextDialog.FileName);
end;

end.
