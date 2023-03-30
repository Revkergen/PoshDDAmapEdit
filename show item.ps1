Function showimage(){
$pictureBox = new-object Windows.Forms.PictureBox 
$pictureBox.width=320
$pictureBox.height=320
$pictureBox.top=0
$pictureBox.left=0
$pictureBox.Image=$cutimage
$pictureBox.SizeMode = "StretchImage"

$Form = New-Object Windows.Forms.Form  
$Form.Text = "PowerShell Form"                     
$Form.Width = 360
$Form.Height = 360
$Form.StartPosition = "CenterScreen"
$form.Controls.add($pictureBox)                  
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()

}

#vp_ap_drill_press
#fd_fire_int1
#mon_bee_small

foreach($item in $imagesorce){

if($item.image -eq "can_beans"){


$baseimagepath = "C:\Users\moorea\desktop\DDA\Ultimate\" + $item.file
$baseimage = [System.Drawing.Bitmap]::new($baseimagepath)
$cutrec  = [System.Drawing.Rectangle]::new($item.x,$item.y,$item.width,$item.height)
$cutimage = $baseimage.Clone($cutrec,$baseimage.PixelFormat)

#$cutrec  = [System.Drawing.Rectangle]::new(512,0,32,32)
#$cutimage = $baseimage.Clone($cutrec,$baseimage.PixelFormat)

showimage
}

#write-host $item.x
#write-host $item.y
#write-host $item.image


}




                                        #x,y,width,height
#$cutrec  = [System.Drawing.Rectangle]::new(32,0,32,32)
#$cutimage = $baseimage.Clone($cutrec,$baseimage.PixelFormat)


#showimage