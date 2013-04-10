VERSION 5.00
Begin VB.Form frmRubro 
   BorderStyle     =   3  'Fixed Dialog
   ClientHeight    =   1095
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   5115
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmRubro.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1095
   ScaleWidth      =   5115
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtDescripcion 
      Height          =   315
      Left            =   1080
      TabIndex        =   3
      Top             =   120
      Width           =   3915
   End
   Begin VB.CommandButton cmdCancelar 
      Cancel          =   -1  'True
      Caption         =   "&Cancelar"
      Height          =   375
      Left            =   3900
      TabIndex        =   1
      Top             =   600
      Width           =   1095
   End
   Begin VB.CommandButton cmdAceptar 
      Caption         =   "&Aceptar"
      Height          =   375
      Left            =   2700
      TabIndex        =   0
      Top             =   600
      Width           =   1095
   End
   Begin VB.Label Label3 
      AutoSize        =   -1  'True
      Caption         =   "Descripci�n:"
      Height          =   195
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   870
   End
End
Attribute VB_Name = "frmRubro"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private m_Id As Long
Private m_ModalResult As VbMsgBoxResult
Private m_IsNew As Boolean

Public Property Get Id() As Long
    Id = m_Id
End Property

Public Function ShowModal(Optional ByRef OwnerForm As Form) As EModalResult
    Me.Show vbModal, OwnerForm
    ShowModal = m_ModalResult
End Function

Public Function Iniciar(ByVal IsNew As Boolean, _
                        Optional ByVal Id As String) As Boolean
    m_IsNew = IsNew
    m_Id = Val(Id)
End Function

Private Function Mostrar() As Boolean
    Dim rs As ADODB.Recordset
    
On Error GoTo Catch
    Set rs = GetTable("rubros", "id = " & SQLNum(m_Id))
    
    If EmptyRS(rs) Then
        MsgBox "No se encontr� el rubro.", vbExclamation
    Else
        txtDescripcion.Text = Nz(rs.Collect("descripcion"))
        Mostrar = True
    End If
    
Finally:
    CloseRS rs

    Exit Function
Catch:
    ErrorReport "Mostrar", "frmRubro"
    Resume Finally
End Function

Public Function Eliminar() As Boolean
On Error GoTo Catch
    ExecuteDelete "rubros", "id = " & SQLNum(m_Id)
    Eliminar = True
    
    Exit Function
Catch:
    ErrorReport "Eliminar", "frmRubro"
End Function

Private Function Validar() As Boolean
    If Len(txtDescripcion.Text) = 0 Then
        MsgBox "Debe ingresar un descripcion.", vbExclamation
        txtDescripcion.SetFocus
        Exit Function
    End If
    
    Validar = True
End Function

Private Function Guardar() As Boolean
    Dim sql As String
    
    If Not Validar() Then
        Exit Function
    End If
    
On Error GoTo ErrorHandler
    BeginTransaction
    
    If m_IsNew Then
        With New CString
            .Append "INSERT INTO rubros"
            .Append "(descripcion)"
            .Append "VALUES("
            .Append SQLText(txtDescripcion.Text) & ")"
            
            ExecuteQuery .ToString
        End With
        
        m_Id = GetLastId()
    Else
        With New CString
            .Append "UPDATE familias SET"
            .Append " descripcion = " & SQLText(txtDescripcion.Text)
            .Append " WHERE id = " & SQLNum(m_Id)
            
            ExecuteQuery .ToString
        End With
    End If
    
    CommitTransaction
    Guardar = True

    Exit Function
ErrorHandler:
    ErrorReport "frmRubro", "Guardar"
    RollbackTransaction
End Function

Private Sub cmdAceptar_Click()
    If Guardar Then
        m_ModalResult = vbOK
        Unload Me
    End If
End Sub

Private Sub cmdCancelar_Click()
    m_ModalResult = vbCancel
    Unload Me
End Sub

