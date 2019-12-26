VERSION 2.00
Begin Form Form1 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Muse-O-Matic"
   ClientHeight    =   3945
   ClientLeft      =   2220
   ClientTop       =   2085
   ClientWidth     =   4845
   Height          =   4350
   Icon            =   FORM1.FRX:0000
   Left            =   2160
   LinkTopic       =   "Form1"
   ScaleHeight     =   263
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   323
   Top             =   1740
   Width           =   4965
   Begin TextBox Text1 
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   12
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   420
      Left            =   2430
      TabIndex        =   1
      Text            =   "musical"
      Top             =   2610
      Width           =   2220
   End
   Begin CommandButton Command1 
      Caption         =   "Generate Music"
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   12
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   495
      Left            =   195
      TabIndex        =   0
      Top             =   3225
      Width           =   4455
   End
   Begin Image Image1 
      Height          =   1440
      Left            =   120
      Picture         =   FORM1.FRX:0442
      Stretch         =   -1  'True
      Top             =   75
      Width           =   4515
   End
   Begin Line Line1 
      X1              =   12
      X2              =   302
      Y1              =   112
      Y2              =   112
   End
   Begin Label Label3 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "Enter the word(s):"
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   12
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   300
      Left            =   180
      TabIndex        =   3
      Top             =   2655
      Width           =   2175
   End
   Begin Label Label2 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "based on the letters of a word (or words)."
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   9.75
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   240
      Left            =   180
      TabIndex        =   4
      Top             =   2175
      Width           =   4230
   End
   Begin Label Label1 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "This program generates algorithmic music"
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   9.75
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   240
      Left            =   165
      TabIndex        =   2
      Top             =   1935
      Width           =   4365
   End
End
Declare Function GetModuleUsage% Lib "Kernel" (ByVal hModule%)
Declare Function GetModuleHandle% Lib "kernel" (ByVal FileName$)
' The following Declare statement must be typed on one, single line:
Declare Function GetModuleFileName% Lib "kernel" (ByVal hModule%, ByVal FileName$, ByVal nSize%)

Sub Command1_Click ()
      Command1.Enabled = False
      hModule% = GetModuleHandle("museomat.exe")
      If hModule% = 0 Then
	D$ = "c:\key\museomat"
      Else
	Buffer$ = Space$(255)
	Length% = GetModuleFileName(hModule%, Buffer$, Len(Buffer$))
	D$ = Left$(Buffer$, Length% - 13)
      End If
      q$ = Chr$(34)
      b$ = Chr$(92)
      kd$ = Left$(D$, Len(D$) - 9)
      x% = Shell(kd$ & "\bin\key.exe " & D$ & "\www.k -c wwwalg2(" & q$ & Text1.Text & q$ & "," & q$ & D$ & "\museomat.mid" & q$ & ")")
      While GetModuleUsage(x%) > 0
	    z% = DoEvents()
      Wend
      While FileExists(D$ & "\museomat.mid") = 0
	    z% = DoEvents()
      Wend
      cmd$ = "mplayer " & D$ & "\museomat.mid"
      x% = Shell(cmd$, 1)
      While GetModuleUsage(x%) > 0
	    z% = DoEvents()
      Wend
      Command1.Enabled = True
      Form1.SetFocus
End Sub

Function FileExists (ByVal fname As String)
    Dim Drive, Msg                              ' Declare variables.
    On Error GoTo ErrorHandler                  ' Set up error handler.
    Drive = Chr(Int((26) * Rnd + 1) + 64)   ' Make random drive letter.
    Open fname For Input As #1     ' Try to open file.
    Close #1                    ' Close the file.
    FileExists = 1
    Exit Function               ' Exit before entering error handler.
ErrorHandler:                   ' Error handler line label.
    FileExists = 0
    Exit Function
End Function

Sub Form_Load ()
    ' Set properties needed by MCI to open.
    Rem Form1.MMControl1.Notify = False
    Rem Form1.MMControl1.Wait = True
    Rem Form1.MMControl1.Shareable = False
    Rem Form1.MMControl1.DeviceType = "Sequencer"
    Rem Form1.MMControl1.FileName = "C:\WINNT\canyon.mid"

    ' Open the MCI WaveAudio device.
    Rem Form1.MMControl1.Command = "Open"

End Sub

Sub Form_Unload (Cancel As Integer)
    Rem MMControl1.Command = "Close"
End Sub

Sub Pause (ByVal nSecond As Single)
   Dim t0 As Single
   t0 = Timer
   Do While Timer - t0 < nSecond
      Dim dummy As Integer
      dummy = DoEvents()
      ' if we cross midnight, back up one day
      If Timer < t0 Then
	 t0 = t0 - 24 * 60 * 60
      End If
   Loop
End Sub

