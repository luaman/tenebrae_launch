unit mainu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, IniFiles;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    CheckBox1: TCheckBox;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    GroupBox3: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Resolution: TGroupBox;
    ComboBox1: TComboBox;
    CheckBox2: TCheckBox;
    GroupBox4: TGroupBox;
    Edit2: TEdit;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    Label2: TLabel;
    BitBtn3: TBitBtn;
    ComboBox2: TComboBox;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CurrentConfig : String;

    Procedure CreateModeList;
    Function AssembleParamString : string;
    Function GetMirIndex : integer;
    Function GetTexIndex : integer;
    Function GetFilter : string;
    Function GetAnisoIndex : integer;
    Function GetForceWaterIndex : integer;
    Procedure LoadConfig(Ident : String);
    Procedure SaveConfig(Ident : String);
    Function FindConfigs : integer;
  end;

var
  Form1: TForm1;

implementation

uses cred;

{$R *.DFM}

var
   modes : array[0..255] of tdevMode;

function DisplayModeInfo(index : integer) : string;
var
   amode : ^tdevMode;
   succes : boolean;
   i  : integer;
begin
   if index >= 255 then
   begin
      Result := 'STOP';
      exit;
   end;
   
   if not EnumDisplaySettings(nil,index,modes[index]) then
   begin
      Result := 'STOP';
      exit;
   end;

   amode := @modes[index];
   //force 16 or 32 bit modes
   if amode.dmBitsPerPel <> 32 then
   begin
      result := '';
   end else
   begin
      //search if you already have the specified resolution in the list...

      for i := 0 to index-1 do
      begin
         if (modes[index].dmPelsWidth = modes[i].dmPelsWidth)
            and (modes[index].dmPelsHeight = modes[i].dmPelsHeight)
            and (modes[i].dmBitsPerPel = 32) then
         begin
            //yes? then just skip it
            result := '';
            exit;
         end;
      end;

      result := inttostr(amode.dmPelsWidth)+' x '+
                inttostr(amode.dmPelsHeight)+' x '+
                inttostr(amode.dmBitsPerPel);
   end;
end;

procedure TForm1.CreateModeList;
var
   s : string;
   i : integer;
begin
   i := 0;
   s := DisplayModeInfo(i);
   while s <> 'STOP' do
   begin
      if s <> '' then ComboBox1.Items.AddObject(s,Pointer(i));
      inc(i);
      s := DisplayModeInfo(i);      
   end;
   if ComboBox1.Items.Count = 0 then
   begin
      ComboBox1.Items.Add('No 32 bit modes found');
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Application.Title := 'Tenebrae Config';
   CreateModeList;
   ComboBox1.ItemIndex := 0;

   if FindConfigs = 0 then
   begin
        SaveConfig('Standard');
        FindConfigs;
   end;
   ComboBox2.ItemIndex := 0;
   CurrentConfig := ComboBox2.Items.Strings[ComboBox2.ItemIndex];
   LoadConfig(CurrentConfig);
end;

function TForm1.GetMirIndex : integer;
begin
   if RadioButton1.Checked then
   begin
      result := 0;
      exit;
   end;
   if RadioButton2.Checked then
   begin
      result := 1;
      exit;
   end;
   if RadioButton3.Checked then
   begin
      result := 2;
      exit;
   end;
end;

function TForm1.GetTexIndex : integer;
begin
   if RadioButton4.Checked then
   begin
      result := 0;
      exit;
   end;
   if RadioButton5.Checked then
   begin
      result := 1;
      exit;
   end;
   if RadioButton6.Checked then
   begin
      result := 2;
      exit;
   end;
end;

function TForm1.GetForceWaterIndex : integer;
begin
   if CheckBox1.Checked then
   begin
      result := 1;
      exit;
   end;
   result := 0;
   exit;
end;

function TForm1.GetFilter : string;
begin
     if CheckBox3.Checked then
        result := 'GL_LINEAR_MIPMAP_LINEAR'
     else
        result := 'GL_LINEAR_MIPMAP_NEAREST';
end;

function TForm1.GetAnisoIndex : integer;
begin
     if CheckBox4.Checked then
        result := 1
     else
         result := 0;
end;

function TForm1.AssembleParamString : string;
var
   s : string;
   amode : ^tdevMode;
begin
   amode := @modes[integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex])];

   //screen res
   s := ' -width '+IntToStr(amode.dmPelsWidth)+' -height '+IntToStr(amode.dmPelsHeight)+' -bpp 32 ';
   //mirrors
   s := s + '+mir_detail ' + IntToStr(getMirIndex) +  ' +mir_forcewater ' + IntToStr(GetForceWaterIndex) + ' ';
   //textures
   s := s + '+gl_picmip ' + IntToStr(getTexIndex) + ' ';
   //lightgen
   s := s + '+sh_radiusscale '+ Edit1.Text;
   //windowed
   if CheckBox2.Checked then
      s := s+' -window';
   //texture filtering
   s := s+' +gl_texturemode '+GetFilter+' ';

   if CheckBox4.Checked then
      s := s+' -anisotropic ';
   //aditional params
   s := s+' '+edit2.text;

   result := s;
end;

procedure TForm1.LoadConfig(Ident : String);
var
   IniFile : TIniFile;
begin
     IniFile := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\'+ident+'.tcfg');
     RadioButton1.Checked := IniFile.ReadBool('MIRROR','Disabled',false);
     RadioButton2.Checked := IniFile.ReadBool('MIRROR','World',true);
     RadioButton3.Checked := IniFile.ReadBool('MIRROR','Full',false);
     CheckBox1.Checked := IniFile.ReadBool('MIRROR','ForceWater',false);

     RadioButton4.Checked := IniFile.ReadBool('TEXTURE','Full',true);
     RadioButton5.Checked := IniFile.ReadBool('TEXTURE','HalfSize',false);
     RadioButton6.Checked := IniFile.ReadBool('TEXTURE','QuadSize',true);
     CheckBox3.Checked := IniFile.ReadBool('TEXTURE','TriLinear',false);
     CheckBox4.Checked := IniFile.ReadBool('TEXTURE','Anisotropic',false);

     ComboBox1.ItemIndex := IniFile.ReadInteger('RESOLUTION','Mode',0);
     CheckBox2.Checked := IniFile.ReadBool('RESOLUTION','Windowed',false);

     Edit1.Text := IniFile.ReadString('LIGHTS','Radiusscale','0.5');

     Edit2.Text := IniFile.ReadString('MISC','Extra','');

     IniFile.Free;
end;

procedure TForm1.SaveConfig(Ident : String);
var
   IniFile : TIniFile;
begin
     IniFile := TIniFile.Create(ExtractFileDir(ParamStr(0))+'\'+ident+'.tcfg');
     IniFile.WriteBool('MIRROR','Disabled',RadioButton1.Checked);
     IniFile.WriteBool('MIRROR','World',RadioButton2.Checked);
     IniFile.WriteBool('MIRROR','Full',RadioButton3.Checked);
     IniFile.WriteBool('MIRROR','ForceWater',CheckBox1.Checked);

     IniFile.WriteBool('TEXTURE','Full',RadioButton4.Checked);
     IniFile.WriteBool('TEXTURE','HalfSize',RadioButton5.Checked);
     IniFile.WriteBool('TEXTURE','QuadSize',RadioButton6.Checked);
     IniFile.WriteBool('TEXTURE','TriLinear',CheckBox3.Checked);
     IniFile.WriteBool('TEXTURE','Anisotropic',CheckBox4.Checked);

     IniFile.WriteInteger('RESOLUTION','Mode',ComboBox1.ItemIndex);
     IniFile.WriteBool('RESOLUTION','Windowed',CheckBox2.Checked);

     IniFile.WriteString('LIGHTS','Radiusscale',Edit1.Text);

     IniFile.WriteString('MISC','Extra',Edit2.Text);

     Inifile.Free;
end;

Function ExtractFileBase(v : String) : String;
begin
     //hack assume extension is 5 chars (.tcfg)
     result := Copy(v,0,length(v)-5);
end;

Function TForm1.FindConfigs : integer;
var
   F : TSearchRec;
   Res, Count : Integer;
begin
     Res := FindFirst(ExtractFileDir(ParamStr(0))+'\*.tcfg',0,F);
     Count := 0;
     ComboBox2.Items.Clear;
     while (Res = 0) do
     begin
          ComboBox2.Items.Add(ExtractFileBase(F.Name));
          Inc(Count);
          Res := FindNext(F);
     end;
     FindClose(F);

     result := Count;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var
winbestand : array [0..1024] of char;
toexec     : String;
begin
   toexec := 'tenebrae.exe' + AssembleParamString;
   if winexec(StrPCopy(winbestand, toexec),sw_show) < 31 then messagedlg('Windows'+
   ' could not launch Tenebrae'+chr(13)+ToExec,mterror,[mbok],0);
   SaveConfig(CurrentConfig);
   application.terminate;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
   SaveConfig(CurrentConfig);
   Application.Terminate;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
     Form2.ShowModal;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   newname : string;
begin
     NewName := 'NewProfile'+IntToStr(ComboBox2.Items.Count);
     if not InputQuery('Enter profile name','Enter a name for the new profile',newname) then
        exit;
     SaveConfig(CurrentConfig);
     if newname = '' then
     begin
          newname := 'Necrophilia!';
          //Edit2.Text := 'The pale skin, memory''s off the...';
          //Edit1.Text := '... moonlight';
     end;
     SaveConfig(newname);
     CurrentConfig := newname;
     //FindConfigs;
     ComboBox2.Items.Add(newname);
     ComboBox2.ItemIndex :=  ComboBox2.Items.Count-1;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
begin
     SaveConfig(CurrentConfig);
     CurrentConfig := ComboBox2.Items.Strings[ComboBox2.ItemIndex];
     LoadConfig(CurrentConfig);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
     If ComboBox2.Items.Count < 2 then
     begin
          messagedlg('You need at least one profile',mterror,[mbok],0);
          exit;
     end;
     CurrentConfig := ComboBox2.Items.Strings[ComboBox2.ItemIndex];
     DeleteFile(ExtractFileDir(ParamStr(0))+'\'+CurrentConfig+'.tcfg');
     FindConfigs;
     ComboBox2.ItemIndex := 0;
     CurrentConfig := ComboBox2.Items.Strings[ComboBox2.ItemIndex];
     LoadConfig(CurrentConfig);
end;

end.