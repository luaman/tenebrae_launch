program Tenebrae_launch;

uses
  Forms,
  mainu in 'mainu.pas' {Form1},
  cred in 'cred.pas' {Form2};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
