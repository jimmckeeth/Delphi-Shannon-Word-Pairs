program ShannonizerSample;

uses
  System.StartUpCopy,
  FMX.Forms,
  Shannonizer_main in 'Shannonizer_main.pas' {Form12},
  Shannonizer in '..\Shannonizer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm12, Form12);
  Application.Run;
end.
