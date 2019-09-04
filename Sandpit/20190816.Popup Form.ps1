function QuestionPupup()
{
    Param (
        [string] $PopupTitle = "",
        [string] $QuestionText = "",
        [string] $QuestionProposedResponse = "",
        [string] $ButtonOKText = "Ok",
        [string] $ButtonCancelText = "Close",
        [int] $SizeWidth = 300,
        [int] $SizeHeight = 200
    )

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = $PopupTitle
    $objForm.Size = New-Object System.Drawing.Size($SizeWidth, $SizeHeight)
    $objForm.StartPosition = "CenterParent"
    #$objForm.FormBorderStyle= "FixedDialog"
    $objForm.FormBorderStyle= "None"
    $objForm.BackColor=0xFF2E2E2E

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") {$Script:LastQuestionPupupUserInput=$objTextBox.Text;$objForm.Close()}})
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$Script:LastQuestionPupupUserInput="";$objForm.Close()}})

    $objPanel = New-Object System.Windows.Forms.Panel
    $objPanel.Left=0
    $objPanel.Top=0
    $objPanel.Width=$SizeWidth
    $objPanel.Height=$SizeHeight
    $objPanel.BackColor=0xFF2E2E2E
    $objPanel.BorderStyle="FixedSingle"
    $objForm.Controls.Add($objPanel)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size($($SizeWidth - 180),$($SizeHeight - 40))
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = $ButtonOKText
    $OKButton.Add_Click({$Script:LastQuestionPupupUserInput=$objTextBox.Text;$objForm.Close()})
    $OKButton.FlatStyle="Flat"
    $OKButton.BackColor=0xFF4A4A4A
    $OKButton.ForeColor=0xFFCCCCCC
    $objPanel.Controls.Add($OKButton)

    $CANCELButton = New-Object System.Windows.Forms.Button
    $CANCELButton.Location = New-Object System.Drawing.Size($($SizeWidth - 100),$($SizeHeight - 40))
    $CANCELButton.Size = New-Object System.Drawing.Size(75,23)
    $CANCELButton.Text = $ButtonCancelText
    $CANCELButton.Add_Click({$Script:LastQuestionPupupUserInput="";$objForm.Close()})
    $CANCELButton.BackColor=0xFF4A4A4A
    $CANCELButton.ForeColor=0xFFCCCCCC
    $CANCELButton.FlatStyle="Flat"
    $objPanel.Controls.Add($CANCELButton)

    $objTitle = New-Object System.Windows.Forms.Label
    $objTitle.Location = New-Object System.Drawing.Size(0,0)
    $objTitle.Size = New-Object System.Drawing.Size($($SizeWidth),20)
    $objTitle.Text = $PopupTitle
    $objTitle.BackColor=0xFF101010
    $objTitle.ForeColor=0xFFCCCCCC
    $objTitle.Padding="4,3,0,0"
    $objPanel.Controls.Add($objTitle)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,40)
    $objLabel.Size = New-Object System.Drawing.Size($($SizeWidth - 20),20)
    $objLabel.Text = $QuestionText
    $objLabel.ForeColor=0xFFCCCCCC
    $objPanel.Controls.Add($objLabel)

    $objTextBox = New-Object System.Windows.Forms.TextBox
    $objTextBox.Location = New-Object System.Drawing.Size(10,60)
    $objTextBox.Size = New-Object System.Drawing.Size($($SizeWidth - 40),20)
    $objTextBox.ForeColor=0xFF989898
    $objTextBox.BackColor=0xFF1F2121
    $objTextBox.BorderStyle="FixedSingle"
    $objTextBox.Text=$QuestionProposedResponse
    $objPanel.Controls.Add($objTextBox)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objTextBox.Select()})

    [void] $objForm.ShowDialog()

    return $LastQuestionPupupUserInput
}

#$schema = QuestionPupup -PopupTitle "Pipeline Project" -QuestionText "Enter new Project name:" -QuestionProposedResponse "bidule" -ButtonOKText "Ok" -ButtonCancelText "Nope"
#$schema
$schema = QuestionPupup -PopupTitle "New Pipeline Project" -QuestionText "New Project name:" -QuestionProposedResponse "bidule" -ButtonOKText "Ok" -ButtonCancelText "Nope" -SizeWidth 320 -SizeHeight 150
$schema


