add-type -AssemblyName microsoft.VisualBasic
Add-Type -AssemblyName PresentationFramework
#Add-Type -AssemblyName System.Windows.Controls.visualbrush


$baseimagepath = "C:\Users\moorea\Desktop\DDA\Images\error.png"
$baseimage = [System.Windows.Media.Imaging.BitmapImage]::new($baseimagepath)


#$window = New-Object Windows.Forms.Form  
#  $window.Text = "PowerShell Form"                     
#  $window.Width = 1020
#  $window.Height = 820
#  $window.AutoScroll = $true
#  $window.StartPosition = "CenterScreen"
#  $pictureBox = new-object Windows.Forms.PictureBox 
#  $pictureBox.height= $json.object.rows.count * 32
#  $pictureBox.top=0
#  $pictureBox.left=202
#  $pictureBox.Image=$baseimage
#  $pictureBox.SizeMode = "autosize"
#  $window.Controls.add($pictureBox)                  
#$window.Controls.add($dataGrid)                  
#$window.controls.AddRange(@($pictureBox,$dataGrid))
  
#  $window.Add_Shown({$window.Activate()})


[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Case O Matic" WindowStartupLocation = "CenterScreen"
    Width = "380" Height = "577" ShowInTaskbar = "True" Background = "lightgray">



<StackPanel>
<DockPanel>
	    <Menu DockPanel.Dock="top">
	    <MenuItem  Header="_File" >
        <MenuItem  Header="New" />
        <MenuItem  Header="Open" />
        <MenuItem  Header="save" />
        <MenuItem  Header="SaveAs" />
        </MenuItem >
        <MenuItem  Header="Export" >
        <MenuItem  Header="PNG" />
        <MenuItem  Header="HTML" />
        </MenuItem >
        
         <MenuItem  Header="settings" >
        <MenuItem  Header="1" />
        <MenuItem  Header="2" />
        </MenuItem >
        </Menu>   
    </DockPanel>


<Image Name="image" />




</StackPanel>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$image = $window.FindName("image")
$image.Source = $baseimage

#$image = $baseimage

[VOID]$window.ShowDialog()

#$Form.ShowDialog()
 #$mainForm.ShowDialog()