unit cred;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls;

type
  TForm2 = class(TForm)
    RichEdit1: TRichEdit;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.FormCreate(Sender: TObject);
begin
     RichEdit1.Lines.LoadFromFile(ExtractFileDir(ParamStr(0))+'\tenebrae\credits.rtf');
end;

end.
