#[System.Windows.Forms.Cursor]::Position

$image = ([System.Drawing.Bitmap]::new("C:\Users\moorea\Desktop\DDA\Images\error.png"))

$pictureBox = new-object Windows.Forms.PictureBox 
$pictureBox.width=320
$pictureBox.height=320
$pictureBox.top=0
$pictureBox.left=0
$pictureBox.Image=$image
$pictureBox.SizeMode = "StretchImage"

$Form = New-Object Windows.Forms.Form  
$Form.Text = "PowerShell Form"                     
$Form.Width = 360
$Form.Height = 360
$Form.StartPosition = "CenterScreen"
$form.Controls.add($pictureBox)                  
$Form.Add_Shown({$Form.Activate()})

$pictureBox.add_click({

#write-host ([System.Windows.Forms.Cursor]::Position.x)
#write-host ([System.Windows.Forms.Cursor]::Position.y)

$formx = ([System.Windows.Forms.Cursor]::Position.x) - $form.Location.x - 9   #padding of frame
$formy = ([System.Windows.Forms.Cursor]::Position.y) - $form.Location.y - 31  #padding of frame

#write-host $formx
#write-host $formy

$formx = $formx / 32
$formy = $formy / 32

write-host $formx
write-host $formy

})


$Form.ShowDialog()



#$form.PointToClient()

#$form.PointToScreen([System.Drawing.Point]::empty)
#$form.PointToClient([System.Drawing.Point]::empty)

#$form.Cursor