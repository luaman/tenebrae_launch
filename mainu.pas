unit mainu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, IniFiles, ComCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBox2: TComboBox;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    CheckBox1: TCheckBox;
    GroupBox5: TGroupBox;
    CheckBox6: TCheckBox;
    Resolution: TGroupBox;
    GroupBox4: TGroupBox;
    Edit2: TEdit;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Memo1: TMemo;
    GroupBox2: TGroupBox;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton4: TRadioButton;
    Other: TGroupBox;
    CheckBox3: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    TabSheet5: TTabSheet;
    PaintBox1: TPaintBox;
    Image1: TImage;
    Panel1: TPanel;
    ComboBox4: TComboBox;
    ComboBox3: TComboBox;
    Label2: TLabel;
    Label4: TLabel;
    ChkCaustics: TCheckBox;
    ChkWaterShader: TCheckBox;
    Button3: TButton;
    ChkTLerp: TCheckBox;
    ChkViewModel: TCheckBox;
    GrbShadows: TGroupBox;
    ChkPlayerShadow: TCheckBox;
    ChkEntityShadows: TCheckBox;
    ChkWorldShadows: TCheckBox;
    CmbAniso: TComboBox;
    Label5: TLabel;
    GroupBox6: TGroupBox;
    CheckBox5: TCheckBox;
    ChkBump: TCheckBox;
    ChkGloss: TCheckBox;
    ChkSound: TCheckBox;
    ChkCDAudio: TCheckBox;
    ChkBumpmaps: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CurrentConfig : String;
    CreditsList : TStringList;

    Procedure CreateModeList;
    Function AssembleParamString : string;
    Function GetMirIndex : integer;
    Function GetTexIndex : integer;
    Function GetFilter : string;
    Function GetForceWaterIndex : integer;
    Function GetCompressionIndex : integer;
    Function GetSampleRate : integer;
    Function GetSampleBits : integer;
    Procedure LoadConfig(Ident : String);
    Procedure SaveConfig(Ident : String);
    Function FindConfigs : integer;
    Function GetAnisotropy : integer;
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

   CreditsList := TStringList.Create;
   CreditsList.LoadFromFile('credits.txt');

   PageControl1.ActivePage := TabSheet5;
end;

function TForm1.GetMirIndex : integer;
begin
   //cleaner code and shutsup compiler warnings -AdamJ
   if RadioButton2.Checked then
   begin
      result := 1;
      exit;
   end
   else if RadioButton3.Checked then
   begin
      result := 2;
      exit;
   end
   else
      result := 0;
end;

function TForm1.GetTexIndex : integer;
begin
   //cleaner code and shutsup compiler warnings -AdamJ
   if RadioButton5.Checked then
   begin
      result := 1;
      exit;
   end
   else if RadioButton6.Checked then
   begin
      result := 2;
      exit;
   end
   else
    result := 0;
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

function TForm1.GetCompressionIndex : integer;
var lvl:integer;
begin
   lvl:=0;
   if CheckBox5.Checked then lvl:=lvl+1;
   if ChkBump.Checked then lvl:=lvl+2;
   if ChkGloss.Checked then lvl:=lvl+4;
   GetCompressionIndex:=lvl;
end;

function TForm1.GetFilter : string;
begin
     if CheckBox3.Checked then
        result := 'GL_LINEAR_MIPMAP_LINEAR'
     else
        result := 'GL_LINEAR_MIPMAP_NEAREST';
end;

function TForm1.GetSampleRate : integer;
begin
     result := 22050;
     case ComboBox3.ItemIndex of
          0: result := 11025;
          1: result := 22050;
          2: result := 44100;
     end;
end;

function TForm1.GetAnisotropy : integer;
begin
     result := 1;
     case CmbAniso.ItemIndex of
          0: result := 1;
          1: result := 2;
          2: result := 4;
          3: result := 8;
     end;
end;

function TForm1.GetSampleBits : integer;
begin
     result := 16;
     case ComboBox4.ItemIndex of
          0: result := 8;
          1: result := 16;
     end;
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
   s := s+' -anisotropy '+inttostr(GetAnisotropy)+' ';

   if ChkSound.checked=false then s := s+' -nosound ';
   if ChkCDAudio.checked=false then s := s+' -nocdaudio ';
   if ChkBumpmaps.checked=false then s := s+' -nobumpmaps ';

   {You need to do this so when the option is unchecked it is
   properly disabled instead of using default or .cfg setting -Adam}
   s := s+ ' +gl_compress_textures '+inttostr(GetCompressionIndex)+' ';
   s := s+' +sh_glares '+booltostr(CheckBox6.Checked)+' ';
   s := s+' +gl_caustics '+booltostr(ChkCaustics.Checked)+' ';
   s := s+' +gl_watershader '+booltostr(ChkWaterShader.Checked)+' ';
   s := s+' +r_drawviewmodel '+booltostr(ChkViewModel.Checked)+' ';
   s := s+' +gl_transformlerp '+booltostr(ChkTLerp.Checked)+' ';
   s := s+' +sh_playershadow '+booltostr(ChkPlayerShadow.Checked)+' ';
   s := s+' +sh_entityshadows '+booltostr(ChkEntityShadows.Checked)+' ';
   s := s+' +sh_worldshadows '+booltostr(ChkWorldShadows.Checked)+' ';

   s := s+'-sndspeed '+IntToStr(getSampleRate)+' ';
   s := s+'-sndbits '+IntToStr(getSampleBits)+' ';

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
     CmbAniso.ItemIndex := IniFile.ReadInteger('TEXTURE','Anisotropy',0);
     CheckBox5.Checked := IniFile.ReadBool('TEXTURE','Compression',false);
     ChkBump.Checked := IniFile.ReadBool('TEXTURE','CompressBump',false);
     ChkGloss.Checked := IniFile.ReadBool('TEXTURE','CompressGloss',false);
     ChkCaustics.Checked := IniFile.ReadBool('TEXTURE','Caustics',true);
     ChkWaterShader.Checked := IniFile.ReadBool('TEXTURE','WaterShader',true);
     ChkBumpmaps.Checked := IniFile.ReadBool('TEXTURE','Bumpmaps',true);

     ComboBox1.ItemIndex := IniFile.ReadInteger('RESOLUTION','Mode',0);
     CheckBox2.Checked := IniFile.ReadBool('RESOLUTION','Windowed',false);

     Edit1.Text := IniFile.ReadString('LIGHTS','Radiusscale','0.5');
     CheckBox6.Checked := IniFile.ReadBool('LIGHTS','Glares',false);

     ChkPlayerShadow.Checked := IniFile.ReadBool('SHADOWS','Player',true);
     ChkEntityShadows.Checked := IniFile.ReadBool('SHADOWS','Entity',true);
     ChkWorldShadows.Checked := IniFile.ReadBool('SHADOWS','World',true);

     ChkViewModel.Checked := IniFile.ReadBool('MISC','DrawViewModel',true);
     ChkTLerp.Checked := IniFile.ReadBool('MISC','TransformInterpolation',false);
     Edit2.Text := IniFile.ReadString('MISC','Extra','');

     ComboBox3.ItemIndex := IniFile.ReadInteger('SOUND','Hz',1);
     ComboBox4.ItemIndex := IniFile.ReadInteger('SOUND','Bits',1);
     ChkSound.Checked := IniFile.ReadBool('SOUND','SoundEnabled',true);
     ChkCDAudio.Checked := IniFile.ReadBool('SOUND','CDAudio',true);

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
     IniFile.WriteInteger('TEXTURE','Anisotropy',CmbAniso.ItemIndex);
     IniFile.WriteBool('TEXTURE','Compression',CheckBox5.Checked);
     IniFile.WriteBool('TEXTURE','CompressBump',ChkBump.Checked);
     IniFile.WriteBool('TEXTURE','CompressGloss',ChkGloss.Checked);
     IniFile.WriteBool('TEXTURE','Caustics',ChkCaustics.Checked);
     IniFile.WriteBool('TEXTURE','WaterShader',ChkWaterShader.Checked);
     IniFile.WriteBool('TEXTURE','Bumpmaps',ChkBumpmaps.Checked);

     IniFile.WriteInteger('RESOLUTION','Mode',ComboBox1.ItemIndex);
     IniFile.WriteBool('RESOLUTION','Windowed',CheckBox2.Checked);

     IniFile.WriteString('LIGHTS','Radiusscale',Edit1.Text);
     IniFile.WriteBool('LIGHTS','Glares',CheckBox6.Checked);

     IniFile.WriteBool('SHADOWS','Player',ChkPlayerShadow.Checked);
     IniFile.WriteBool('SHADOWS','Entity',ChkEntityShadows.Checked);
     IniFile.WriteBool('SHADOWS','World',ChkWorldShadows.Checked);

     IniFile.WriteBool('MISC','DrawViewModel',ChkViewModel.Checked);
     IniFile.WriteBool('MISC','TransformInterpolation',ChkTLerp.Checked);
     IniFile.WriteString('MISC','Extra',Edit2.Text);

     IniFile.WriteInteger('SOUND','Hz',ComboBox3.ItemIndex);
     IniFile.WriteInteger('SOUND','Bits',ComboBox4.ItemIndex);
     IniFile.WriteBool('SOUND','SoundEnabled',ChkSound.Checked);
     IniFile.WriteBool('SOUND','CDAudio',ChkCDAudio.Checked);

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

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
   rect: TRect;
begin
     Paintbox1.Canvas.Brush.Style := bsClear;

     //simple drop shadow
     rect.Left := 2;
     rect.Right := Paintbox1.Width+2;
     rect.Top := 1;
     rect.Bottom := Paintbox1.Height+1;
     Paintbox1.Canvas.Font.Color := clBlack;
     DrawText(Paintbox1.Canvas.Handle,PChar(CreditsList.text),length(CreditsList.text),rect,DT_CENTER);

     rect.Left := 0;
     rect.Right := Paintbox1.Width;
     rect.Top := 0;
     rect.Bottom := Paintbox1.Height;
     Paintbox1.Canvas.Font.Color := clWhite;
     DrawText(Paintbox1.Canvas.Handle,PChar(CreditsList.text),length(CreditsList.text),rect,DT_CENTER);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  //For those to lazy to do it manaually :P -AdamJ
  if MessageBox(0,PChar('Warning: This will reset all your current settings.'+chr(13)+'Continue?'),PChar('Warning'), +mb_YesNo +mb_ICONWARNING) <> 6 then
    Exit;
  Edit1.Text:='0.4';
  Edit2.Text:='';
  CheckBox1.Checked:=false;
  CheckBox2.Checked:=false;
  CheckBox3.Checked:=false;
  CmbAniso.ItemIndex:=0;
  CheckBox5.Checked:=false;
  CheckBox6.Checked:=false;
  ChkCaustics.Checked:=true;
  ChkWaterShader.Checked:=true;
  ChkViewModel.Checked:=true;
  ChkTLerp.Checked:=false;
  ChkPlayerShadow.Checked:=true;
  ChkEntityShadows.Checked:=true;
  ChkWorldShadows.Checked:=true;
  RadioButton2.Checked:=true;
  RadioButton4.Checked:=true;
  ComboBox3.ItemIndex:=0;
  ComboBox4.ItemIndex:=1;
  if ComboBox1.Items[6]='800 x 600 x 32' then ComboBox1.ItemIndex:=6;
  ChkBump.Checked:=false;
  ChkGloss.Checked:=false;
  ChkSound.Checked:=true;
  ChkCDAudio.Checked:=true;
  ChkBumpmaps.Checked:=true;
end;

end.
