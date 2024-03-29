﻿Add-Type -AssemblyName System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
add-type -AssemblyName microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms
$script:MapLoaded = $false
$MapChanges = New-Object 'object[,]' 32,32
$script:MapNumber = 0  
#Find the root path of the script
$PathToScript = Switch ($Host.name){
  'Visual Studio Code Host' { split-path $psEditor.GetEditorContext().CurrentFile.Path }
  'Windows PowerShell ISE Host' {  Split-Path -Path $psISE.CurrentFile.FullPath }
  'ConsoleHost' { $PSScriptRoot }
}

#tile config load
$i = "$PathToScript\ultimate\tile_config.json"
$data = Get-Content -raw -path $i -Encoding UTF8
$TileConfigJson = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data)

Function TerrainParse($PaletteIn){
  $OutPalette = @()
  
  foreach ($collection in $PaletteIn.terrain.getenumerator())  {
  #$collection.GetType()
  
  if($collection.GetType().name -eq 'Dictionary`2' ){
      foreach ($row in $collection.getenumerator())  {
      write-host $row
      $image = "BLANK"
      $image = [system.String]::Join(" ", $row.Value)  -match "(?<image>t_\w+)" |   Foreach { $Matches.image }
      write-host $image
  
          $tempPalette = New-Object psobject -Property @{
          key = $row.Key
          image = $image
          width = $null
          height = $null
          file = $null
          x = $null
          y = $null
          X_offset = $null
          Y_offset = $null
          ZLayer = $null 
  }
  $OutPalette += $tempPalette
  
  }
  }
  
  else {
      foreach ($row in $collection){
      write-host $row
      $image = "BLANK"
      $image = [system.String]::Join(" ", $row.Value)  -match "(?<image>t_\w+)" |   Foreach { $Matches.image }}
      write-host $image
  
  $tempPalette = New-Object psobject -Property @{
          key = $row.Key
          image = $image
          width = $null
          height = $null
          file = $null
          x = $null
          y = $null
          X_offset = $null
          Y_offset = $null
          ZLayer = $null 
  }
  $OutPalette += $tempPalette
  }
  }
  Return $OutPalette
  }

  Function FurnitureParse($PaletteIn){
    $OutPalette = @()
    
    foreach ($collection in $PaletteIn.furniture.getenumerator())  {
    #$collection.GetType()
    
    if($collection.GetType().name -eq 'Dictionary`2' ){
        foreach ($row in $collection.getenumerator())  {
        write-host $row
        $image = "BLANK"
        $image = [system.String]::Join(" ", $row.Value)  -match "(?<image>f_\w+)" |   Foreach { $Matches.image }
        write-host $image
    
            $tempPalette = New-Object psobject -Property @{
            key = $row.Key
            image = $image
            width = $null
            height = $null
            file = $null
            x = $null
            y = $null
            X_offset = $null
            Y_offset = $null
            ZLayer = $null  
    }
    $OutPalette += $tempPalette
    
    }
    }
    
    else {
        foreach ($row in $collection){
        write-host $row
        $image = "BLANK"
        $image = [system.String]::Join(" ", $row.Value)  -match "(?<image>f_\w+)" |   Foreach { $Matches.image }}
        write-host $image
    
    $tempPalette = New-Object psobject -Property @{
            key = $row.Key
            image = $image
            width = $null
            height = $null
            file = $null
            x = $null
            y = $null
            X_offset = $null
            Y_offset = $null
            ZLayer = $null  

    
    }
    $OutPalette += $tempPalette
    }
    }
    Return $OutPalette
    }

Function LooksLike(){
  $list=@()
  $dir = Get-ChildItem $PathToScript\furniture_and_terrain\ | %{$_.fullname}
  foreach($i in $dir){
  $data = Get-Content -raw -path $i -Encoding UTF8
  $LLjson = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data)
  
  foreach($row in $LLjson){
   if($row.looks_like)   {
   $out = New-Object psobject -Property @{
             Id = $row.id
             Image = $row.looks_like}
      $list += $out
   
  }}}

return $list
}


Function load-palette($MapNumber){

#find a pallete

if( $null -ne $MapJson.object[$MapNumber].palettes ){ 

    $dir = Get-ChildItem $PathToScript\Palettes\ | %{$_.fullname}
    $found = 0
    foreach($i in $dir){
    
    write-host $i
    if($found -ne 1){
    $data = Get-Content -raw -path $i -Encoding UTF8
    $PaletteJson = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data)

    if($PaletteJson.id -eq $MapJson.object[$MapNumber].palettes[0]){write-host "Found matching pallette at $i"
    $found = 1
    
    }}}
#setup pallette
$CustomPalette=@()

#some maps use fill_ter rather than define an area.... add this first as a work around. 
if ($MapJson.object.fill_ter[0]){
  $image = $MapJson.object.fill_ter[0]
  
    $tempPalette = New-Object psobject -Property @{
              key          = " "
              image        = $image
              width = $null
              height = $null
              file = $null
              x = $null
              y = $null
              X_offset = $null
              Y_offset = $null
              ZLayer = $null  

      }
      $CustomPalette += $tempPalette
  }

#pallette terrain 
$CustomPalette += TerrainParse $PaletteJson

#map terrain 
$CustomPalette += TerrainParse $MapJson.object[$MapNumber]

#pallette furniture 
$CustomPalette += FurnitureParse $PaletteJson

#map terrain 
$CustomPalette += FurnitureParse $MapJson.object[$MapNumber]
}
else{
  $CustomPalette += TerrainParse $MapJson.object[$MapNumber]
  $CustomPalette += FurnitureParse $MapJson.object[$MapNumber]
}

#region palette.......... not a real palette, replace t_region with an real image.
$file = "$PathToScript\regional_map_settings.json"
$data = Get-Content -raw -path $file -Encoding UTF8
#[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
$RMSjson = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data) 

#region terrain
$loops = $CustomPalette.count
foreach ($row in $RMSjson.region_terrain_and_furniture.terrain.getenumerator())  {
$image = [system.String]::Join(" ", $row.Value)  -match "(?<image>t_\w+)" |   Foreach { $Matches.image }

for ($loop = 0; $loop -le $loops - 1; $loop++) {

IF($row.key -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image =$image}

#fix for outliers maybe make this into its own real entry?

IF("t_railing_v" -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image = "t_railing"}
IF("t_floor_noroof" -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image = "t_floor"}

}
}
#region furniture
foreach ($row in $RMSjson.region_terrain_and_furniture.furniture.getenumerator())  {
$image = [system.String]::Join(" ", $row.Value)  -match "(?<image>f_\w+)" |   Foreach { $Matches.image }
for ($loop = 0; $loop -le $loops - 1; $loop++) {
IF($row.key -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image =$image}
IF("f_coffee_table" -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image = "f_table"}
}
}

$LooksLike = lookslike

#foreach ($row in $lookslike)  {
#  for ($loop = 0; $loop -le $loops - 1; $loop++) {
#  
#    IF($row.id -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image =$row.image
#    write-host "Got one" $row.id " " $row.image
#    }
#  
#  }
#}


$sorcerows = $CustomPalette.count

for ($loop = 0; $loop -le $sorcerows - 1; $loop++){

foreach($item in $imagesorce){

if($CustomPalette[$loop].image -eq $item.image){

$CustomPalette[$loop].width      = $item.width
$CustomPalette[$loop].height     = $item.height
$CustomPalette[$loop].file       = $item.file
$CustomPalette[$loop].x          = $item.x
$CustomPalette[$loop].y          = $item.y
$CustomPalette[$loop].'X_offset' = $item.'X_offset'
$CustomPalette[$loop].'Y_offset' = $item.'Y_offset'
$CustomPalette[$loop].ZLayer     = $item.ZLayer  
}
}
If(!$CustomPalette[$loop].file){write-host "Missing image  " $CustomPalette[$loop].image
$found = 0
foreach ($row in $lookslike)  {
  IF($row.id -eq $CustomPalette[$loop].image){$CustomPalette[$loop].image =$row.image
    write-host "Got one" "id" $row.id " " "image" $row.image
  $found = 1  
  }
  }
  if($found -eq 1){
  foreach($item in $imagesorce){

    if($CustomPalette[$loop].image -eq $item.image){
    
    $CustomPalette[$loop].width      = $item.width
    $CustomPalette[$loop].height     = $item.height
    $CustomPalette[$loop].file       = $item.file
    $CustomPalette[$loop].x          = $item.x
    $CustomPalette[$loop].y          = $item.y
    $CustomPalette[$loop].'X_offset' = $item.'X_offset'
    $CustomPalette[$loop].'Y_offset' = $item.'Y_offset'
    $CustomPalette[$loop].ZLayer     = $item.ZLayer  
    }
    }}
}
}
Return $CustomPalette
}


function write-html{

write-host "Writing file..."

$header =@'
<!DOCTYPE html>
<html>
<head>
<style>
* {
  box-sizing: border-box;
}

.column {
  float: left;
  width: 2.4%;
  padding: 0px;
}

.row::after {
  content: "";
  clear: both;
  display: table;
}

@media screen and (max-width: 50px) {
  .column {
    width: 2%;
  }
}
</style>
</head>
<body>
'@


$BodyRow =@'
</div>
<div class="row">
'@


$footer =@'
</div>
</div>
</body>
</html>
'@

$body = $null
$body = $header

$gfxcache=@()

foreach($row in $MapJson.object[0].rows){ #[0] only runs the first map.
write-host $row
$body = $body + $BodyRow
foreach($tile in $row.ToCharArray()){
#write-host $tile
$width = $null
$height = $null
$file = $null
$x = $null
$y = $null

#Write-host "cache check"  
foreach ($item in $gfxcache){

if ($tile -ceq $item.key){
      #Write-host "cache found!" $item
      $width = $item.width
      $height = $item.height
      $file = $item.file
      $x = $item.x
      $y = $item.y
      }}  
  
  if($null -eq $file){
  #Write-host "cache miss"
  foreach ($item in $CustomPalette ){
      
      if ($tile -ceq $item.key){
      #Write-host "found" $item
      $width = $item.width
      $height = $item.height
      $file = $item.file
      $x = $item.x
      $y = $item.y
      $gfxcache += $item
      }
     
  }
 }
   
    if($file){
    $url1 = '<div class="icon-layer"'
    $url2 = 'style="width: 32px;height: 32px;background-image: url('
    #$file
    $url3 = ');background-position:' #-128px -7264px
    #-$x + "px" -$y + "px"
    $url4 = ';transform: scale(1) translate(0px, 0px);"></div>'
    
    $url = $url1 + $url2 + "$PathToScript/Ultimate/" + $file + $url3 + " -" + $x + "px " + "-" + $y + "px" + $url4
  
    $body = $body + '<div class="column">' + "`r`n" + $url + "`r`n" + '</div>' + "`r`n"
    }
    else{
    $url = $url1 + $url2 + "$PathToScript/images/" + "error.png" + $url3 + " -" + "0" + "px " + "-" + "0" + "px" + $url4
    $body = $body + '<div class="column">' + "`r`n" + $url + "`r`n" + '</div>' + "`r`n"
    
    
    }
  }
}

$body = $body + $footer

$body | out-file $PathToScript\MapExport.htm
Write-host "Done"
}

function get-sidebar(){

  for ($loop = 0; $loop -le $CustomPalette.count - 1; $loop++){

    if($CustomPalette[$loop].file){
    $CutRec2  = [System.Drawing.Rectangle]::new($CustomPalette[$loop].x,$CustomPalette[$loop].y,$CustomPalette[$loop].width,$CustomPalette[$loop].height)
    $filename2 = "tempvarname" + [io.path]::GetFileNameWithoutExtension($CustomPalette[$loop].file)
    }
    else{
    $filename2 = "tempvarname" + [io.path]::GetFileNameWithoutExtension("error")
    $CutRec2  = [System.Drawing.Rectangle]::new(0,0,32,32)
    }
    $baseimage2 = (Get-Variable -Scope "Script" -Name "$filename2").Value
    $cutimage2 = $baseimage2.Clone($cutrec2,$baseimage2.PixelFormat)
    [void]$script:dataGrid.Rows.Add($cutimage2,$CustomPalette[$loop].image,$CustomPalette[$loop].key,$CustomPalette[$loop].'x_offset',$CustomPalette[$loop].'y_offset')
    #[void]$cutimage2.dispose() 
  
  }
  
   #$script:dataGrid | out-gridview
}

Function show-map(){
  $pictureBox = new-object Windows.Forms.PictureBox 
  $pictureBox.width=768
  $pictureBox.height= $MapJson.object.rows.count * 32
  $pictureBox.top=25
  $pictureBox.left=202
  $pictureBox.Image=$MAPimagePlaceholder
  $pictureBox.SizeMode = "autosize"
  
  $script:dataGrid = New-Object System.Windows.Forms.DataGridView
  $dataGrid.Width = 200
  $dataGrid.Height = 768
  $dataGrid.location = new-object system.drawing.point(0,25)
  #$dataGrid.DataSource = $DataTable
  $dataGrid.ReadOnly = $true
  $dataGrid.RowHeadersVisible = $false
  $dataGrid.AllowUserToAddRows = $false
  #$dataGrid.VirtualMode = $true
  $dataGrid.AutoSizeColumnsMode = 'Fill'
  $dataGrid.SelectionMode = "FullRowSelect"
  $datagrid.RowTemplate.Height = 62
  $datagrid.MultiSelect = $false
  $ImageColumn = New-Object System.Windows.Forms.DataGridViewImageColumn
  $ImageColumn.Width = 64
  $dataGrid.Columns.Insert($dataGrid.Columns.Count, $ImageColumn)
  $dataGrid.Columns[0].HeaderText = "Preview"
  $dataGrid.Columns[0].Name = "ImageColumn"
  $dataGrid.Columns[0].Width = 2
  $datagrid.ColumnCount = 5
  $dataGrid.Columns[1].Name = "file"
  $dataGrid.Columns[1].HeaderText = "Image"
  $dataGrid.Columns[1].Width = 60
  $dataGrid.Columns[2].Name = "ASCII"
  $dataGrid.Columns[2].HeaderText = "ASCII"
  $dataGrid.Columns[2].Width = 40
  $dataGrid.Columns[3].Name = "X_offset"
  $dataGrid.Columns[3].HeaderText = "X_offset"
  $dataGrid.Columns[3].Width = 0
  $dataGrid.Columns[3].visible = $false
  $dataGrid.Columns[4].Name = "Y_offset"
  $dataGrid.Columns[4].HeaderText = "Y_offset"
  $dataGrid.Columns[4].Width = 0
  $dataGrid.Columns[4].visible = $false


#Form stuff
  [Windows.Forms.Application]::EnableVisualStyles()
  $Form = New-Object Windows.Forms.Form  
  $Form.Text = "POSH C:DDA Map Editor"                     
  $Form.Width = 1000
  $Form.Height = 845
  $form.AutoScroll = $false
  $Form.StartPosition = "CenterScreen"

#file menu stuff  
$menuMain         = New-Object System.Windows.Forms.MenuStrip
$menuFile         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuMaps         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuTools        = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOpen         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSave         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuNewMap       = New-Object System.Windows.Forms.ToolStripMenuItem

$menuOptions      = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions1     = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions2     = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp         = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout        = New-Object System.Windows.Forms.ToolStripMenuItem


$Form.MainMenuStrip   = $menuMain
$Form.Controls.Add($menuMain)
[void]$Form.Controls.Add($menuMain)

$menuFile.Text = "&File"
[void]$menuMain.Items.Add($menuFile)

$menuNewMap.ShortcutKeys = "Control, N"
$menuNewMap.Text         = "&New map"
$menuNewMap.Add_Click({NewMAP})
[void]$menuFile.DropDownItems.Add($menuNewMap)

$menuOpen.ShortcutKeys = "Control, O"
$menuOpen.Text         = "&Open"
$menuOpen.Add_Click({load-mapfile "ask"})
[void]$menuFile.DropDownItems.Add($menuOpen)

$menuSave.ShortcutKeys = "F2"
$menuSave.Text         = "&Save"
$menuSave.Add_Click({Save-map $script:MapNumber})
[void]$menuFile.DropDownItems.Add($menuSave)

$menuExit.ShortcutKeys = "Control, X"
$menuExit.Text         = "&Exit"
$menuExit.Add_Click({$Form.Close()})
[void]$menuFile.DropDownItems.Add($menuExit)

$menuMaps.Text      = "&Maps"
$menuMaps.Enabled = $false
[void]$menuMain.Items.Add($menumaps)

$menuTools.Text      = "&Tools"
[void]$menuMain.Items.Add($menuTools)

$menuOptions.Text      = "&Options"
[void]$menuTools.DropDownItems.Add($menuOptions)

$menuOptions1.Text      = "&Options 1"
$menuOptions1.Add_Click({Options1})
[void]$menuOptions.DropDownItems.Add($menuOptions1)

$menuOptions2.Text      = "&Options 2"
$menuOptions2.Add_Click({Options2})
[void]$menuOptions.DropDownItems.Add($menuOptions2)

$menuHelp.Text      = "&Help"
[void]$menuMain.Items.Add($menuHelp)
#$menuAbout.Image     = [System.Drawing.SystemIcons]::Information
$menuAbout.Text      = "About MenuStrip"
$menuAbout.Add_Click({About})
[void]$menuHelp.DropDownItems.Add($menuAbout)

 
  $Form.controls.AddRange(@($pictureBox,$dataGrid,$Mapselector))
  $Form.Add_Shown({$Form.Activate()})

  $pictureBox.add_click({

  if($MapLoaded){
    
  $formx = ([System.Windows.Forms.Cursor]::Position.x) - $form.Location.x - 211 #padding of frame   OG 9 
  $formy = ([System.Windows.Forms.Cursor]::Position.y) - $form.Location.y - 56  #padding of frame    31 before filemenu
      
    $formx = $formx / 32 
    $formy = $formy / 32
    $formx = [math]::floor($formx)
    $formy = [math]::floor($formy)
    write-host "cell x" $formx
    write-host "cell y" $formy
    
    
    $Mapchanges[$formx,$formy] = $datagrid.CurrentRow.Cells.value[2]

    $formx = $formx * 32 + $dataGrid.CurrentRow.Cells.value[3]
    $formy = $formy * 32 + $dataGrid.CurrentRow.Cells.value[4]
    
    $width = $dataGrid.CurrentRow.Cells.value[0].width #$dataGrid.CurrentRow.Cells.value[5] #32
    $height = $dataGrid.CurrentRow.Cells.value[0].Height #$dataGrid.CurrentRow.Cells.value[6] #32
    $x = 0
    $y = 0
    #if($dataGrid.CurrentRow.Cells.value[0].width -eq 32 -and $dataGrid.CurrentRow.Cells.value[0].height -eq 64){$y = $y + 25}

    write-host $dataGrid.CurrentRow.Cells.value[1]
    #$filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension("error")
    $CutRec  = [System.Drawing.Rectangle]::new($x,$y,$width,$height)
    $DesRec = [System.Drawing.Rectangle]::new($formx,$formy,$width,$height)  
    $graphics=[System.Drawing.Graphics]::FromImage($MAPimage)
    $units = [System.Drawing.GraphicsUnit]::Pixel
    $graphics.DrawImage($datagrid.CurrentRow.Cells.value[0], $DesRec, $CutRec,$units)
    $graphics.dispose()
    $pictureBox.Update()
    $form.Refresh()

    #save a hash with the x,y and image changed.
  
  }
    })

    
    $Form.ShowDialog()
  
  }

function get-map($MapNumber){
#preload images.
$dir = Get-ChildItem "$PathToScript\Ultimate" -Filter *.png | %{$_.fullname}  
foreach($i in $dir){
#write-host $i

$filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension($i)
New-Variable -name "$filename" -Scope "Script" -Value ([System.Drawing.Bitmap]::new($i)) -ErrorAction SilentlyContinue

#write-host "cache split name" $filename
#$var = (Get-Variable -Name "$name").Value
#(Get-Variable -Name "$filename").Value = [System.Drawing.Bitmap]::new($i)
}

$filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension("$PathToScript\Images\error.png")
New-Variable -name "$filename" -Scope "Script" -Value ([System.Drawing.Bitmap]::new("$PathToScript\Images\error.png")) -ErrorAction SilentlyContinue

#(Get-Variable).Name | write-host
$gfxcache=@()
$rowcount = 0 - 1
[int]$IamgeY = $MapJson.object[$MapNumber].rows.count * 32
$MAPimage = [System.Drawing.Bitmap]::new(768,$IamgeY) 
foreach($row in $MapJson.object[$MapNumber].rows){ #object[0] only runs the first map.
  write-host $row  # 100 ms faster without this 
  $rowcount++
  $tilecount = 0 - 1
  foreach($tile in $row.ToCharArray()){
  #write-host $tile
  $width = $null
  $height = $null
  $file = $null
  $x = $null
  $y = $null
  $tilecount++
  #Write-host "cache check"  
  :loop foreach ($item in $gfxcache){       #could be slower with a small pallette
  
  if ($tile -ceq $item.key){
        #Write-host "cache found!" $item
        $width = $item.width
        $height = $item.height
        $file = $item.file
        $x = $item.x
        $y = $item.y
        $x_offset = $item.'x_offset'
        $y_offset = $item.'y_offset'
        $ZLayer   = $item.ZLayer
        }
      }  
    
    if($null -eq $file){
    #Write-host "cache miss"
    foreach ($item in $CustomPalette ){
        
        if ($tile -ceq $item.key){
        #Write-host "found" $item
        $width = $item.width
        $height = $item.height
        $file = $item.file
        $x = $item.x
        $y = $item.y
        $x_offset = $item.'x_offset'
        $y_offset = $item.'y_offset'
        $ZLayer   = $item.ZLayer
        $gfxcache += $item
        }
      }
    }

#Stich image code

#if($width -eq 0){$width = 32 #should be unneeded
#Write-host "Width ZERO!"}
#if($height -eq 0){$height = 32}  

[int]$PictureboxX = $tilecount * 32 + $x_offset #$width
[int]$PictureboxY = $rowcount * 32  + $y_offset #$height

#if($width -eq 32 -and $height -eq 64){$y = $y + 25 } #push long images up

IF($file){
$CutRec  = [System.Drawing.Rectangle]::new($x,$y,$width,$height)
$filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension($file)
}
else{
$filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension("error")
$CutRec  = [System.Drawing.Rectangle]::new(0,0,32,32)
$width = 32
$height = 32
}
$DesRec = [System.Drawing.Rectangle]::new($PictureboxX,$PictureboxY,$width,$height)  
$graphics=[System.Drawing.Graphics]::FromImage($MAPimage)
$units = [System.Drawing.GraphicsUnit]::Pixel
$graphics.DrawImage((Get-Variable -Scope "Script" -Name "$filename").Value, $DesRec, $CutRec, $units)
$graphics.dispose()
}
}
$MAPimage.save("$PathToScript\MapExport.png") 
return $MAPimage
}

Function load-mapfile($MapNumber){
  write-host "loading map number "$MapNumber
  #clean up old map if loaded.
if($MapLoaded){Get-Variable | where-object -Property name -like 'tempvarname*' | Remove-Variable -Scope "Script"}

  if($MapNumber -eq "ask"){
  $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
  $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
  $FileBrowser.Filter = 'Mapfiles (*.json) | *.json'
  
  #shows the box
  $null = $FileBrowser.ShowDialog()
  Write-host $FileBrowser.FileName
  $script:loadedmap = $FileBrowser.FileName
  if(!$FileBrowser.FileName){return}
  $script:MapNumber = 0  
  $MapNumber = 0
  }
  
  #if($FileBrowser.FileName){
  $script:dataGrid.rows.Clear()
  $data = Get-Content -raw -path $script:loadedmap -Encoding UTF8
  $script:MapJson = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data) 
  $script:MapLoaded = $true
  
  $script:CustomPalette = load-palette $MapNumber
  $script:MAPimage = get-map $MapNumber
  get-sidebar 

  #show-map
  $pictureBox.Image=$MAPimage
  #}

  $menuMaps.DropDownItems.Clear()
  $menuMaps.Enabled = $true
  $loop = 0
  foreach($map in $MapJson){
    #Write-host 
    if($map.'//'){
    $tempItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $map.'//'
    $tempItem.Tag = $loop
    $tempItem.Add_Click({
    write-host $this $this.tag 
    load-mapfile $this.tag
    $script:MapNumber = $this.tag})
    $menuMaps.DropDownItems.Add($tempItem)
    $loop++
    }
    elseif($map.om_terrain){
    $tempItem = New-Object System.Windows.Forms.ToolStripMenuItem -ArgumentList $map.om_terrain
    $tempItem.Tag = $loop
    $tempItem.Add_Click({
    write-host $this $this.tag 
    load-mapfile $this.tag
    $script:MapNumber = $this.tag})
    $menuMaps.DropDownItems.Add($tempItem)
    $loop++
    }
    else{}
  }
}

Function save-map($MapNumber){
Write-host $MapNumber
  #$MapNumber = 0
  if($MapLoaded){
  $FileBrowser = New-Object System.Windows.Forms.SaveFileDialog
  $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
  $FileBrowser.Filter = 'Mapfiles (*.json) | *.json'
  
  #shows the box
  $null = $FileBrowser.ShowDialog()
  if($FileBrowser.FileName){
    Write-host "Saving.."  
    Write-host $FileBrowser.FileName

    $rowcount = 0
    foreach($row in $MapJson.object[$MapNumber].rows){ 
      #write-host $row
      $tilecount = 0
      [string]$newrow = $null
      foreach($tile in $row.ToCharArray()){
        #write-host $tile
        if($Mapchanges[$tilecount,$rowcount]){$newrow = $newrow + $Mapchanges[$tilecount,$rowcount] }
        else{$newrow = $newrow + $tile}
        $tilecount++
      }
      $MapJson.object[$MapNumber].rows[$rowcount] = $newrow
      $rowcount++
    }

  $out = $MapJson | ConvertTo-Json -depth 100 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }
  set-Content $FileBrowser.FileName $out -Encoding UTF8
  write-host "Save complete"
  }

  }
}

#load tile config code

function spliter($file,$width,$height,$StartRange,$endrange){

  $baseimagepath = "$PathToScript\Ultimate\" + $file
  $baseimage = [System.Drawing.Bitmap]::new($baseimagepath)
  $ImagesPerRow = $baseimage.Width / $width
  $imagerows = $baseimage.Height / $height
  
  $GFXindex=@{}
  $counter = 0
  
  if($StartRange -eq 1){$StartRange = 0}
  
  for ($row = 0; $row -le $imagerows - 1; $row++){
      #write-host "row "$row
      for($item = 0; $item -le $ImagesPerRow - 1; $item++){
      if($counter -le $endrange - 1){
      #write-host "image  "$item    
      $x = $item * $width
      $y = $row  * $height
      $index = $StartRange + $counter
  
      #write-host "index number" $index
      #write-host $x
      #write-host $y
      $GFXindex.$index =  [pscustomobject]@{ X = $x; Y = $y; File = $file; width = $width; height = $height}
      }
      $counter++
      
      }
  
  }
      return $GFXindex
  
  }
  
Function Load-TileConfig(){
if(test-path "$PathToScript\Imagemap.xml"){ $imagesorce =  import-Clixml   "$PathToScript\Imagemap.xml"}
else{

$GFXindex =@{}
  
$fileloops = $TileConfigJson.'tiles-new'.file.count
#-2 to skip the fallback.
for ($fileloop = 0; $fileloop -le $fileloops - 2; $fileloop++){

if($TileConfigJson.'tiles-new'[$fileloop].sprite_width){$X = $TileConfigJson.'tiles-new'[$fileloop].sprite_width}
else{$X = 32}

if($TileConfigJson.'tiles-new'[$fileloop].sprite_height){$Y = $TileConfigJson.'tiles-new'[$fileloop].sprite_height}
else{$Y = 32}
$m = Select-String -InputObject $TileConfigJson.'tiles-new'[$fileloop].'//' -Pattern "\d+" -AllMatches
[int]$StartRange = $m.matches.Value[0]
[int]$endRange = $m.matches.Value[1]

$file = $TileConfigJson.'tiles-new'[$fileloop].file
write-host $file

$GFXindex +=  spliter $file $x $y $StartRange $endrange

}

$imagesorce=@()

for ($fileloop = 0; $fileloop -le $fileloops - 2; $fileloop++){
write-host $fileloop
Write-host $TileConfigJson.'tiles-new'[$fileloop].file

$X_offset    =$tileconfigjson.'tiles-new'[$fileloop].sprite_offset_x     
$Y_offset    =$tileconfigjson.'tiles-new'[$fileloop].sprite_offset_y
if($null -eq $x_offset){$X_offset = 0}
if($null -eq $y_offset){$y_offset = 0}

$sprite_X = $tileconfigjson.'tiles-new'[$fileloop].sprite_width
$sprite_Y = $tileconfigjson.'tiles-new'[$fileloop].sprite_height

if($null -eq $sprite_X){$sprite_X = 32}
if($null -eq $sprite_Y){$sprite_Y = 32}

#normalize the layers a bit.    /45
[int]$ZLayer = ($sprite_X + $sprite_y) / 4

#40		10
#64		16
#68		17
#72		18
#96		24
#128	32
#192	48

$loops = $TileConfigJson.'tiles-new'[$fileloop].tiles.count

for ($loop = 0; $loop -le $loops - 1; $loop++) {

if ($TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].id.GetType().name -eq "String"){

    if($TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg.GetType().name -eq "Object[]"){
        if ($TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite){$FG = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite}
        else{$FG = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg[0]}
        
    }
    else{$FG = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg}

if($null-eq $FG){$FG = 1296}

$image = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].id

$temp = New-Object psobject -Property @{
                 
    image       = $image
    FG          = $FG
    BG          =$TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].bg#.ToString()
    X           = $GFXindex.$FG.X
    y           = $GFXindex.$FG.Y
    File        =$TileConfigJson.'tiles-new'[$fileloop].file
    width       =$GFXindex.$FG.width
    height      =$GFXindex.$FG.height
    X_offset    =$X_offset    
    Y_offset    =$Y_offset
    ZLayer      =$ZLayer  
  }
$imagesorce += $temp

}
else{

$subloops = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].id.count

for ($subloop = 0; $subloop -le $subloops - 1; $subloop++) {

if($TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg){
if($TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg.GetType().name -eq "Object[]"){
  if ($TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite){$FG = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite}
  else{$FG = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg[0]}

}
else{$FG = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].fg}
}
else{$FG = 0}

if($null -eq $FG){$FG = 1296}
$image = $TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].id[$subloop]
$temp = New-Object psobject -Property @{

      image       = $image
      FG          = $FG
      BG          =$TileConfigJson.'tiles-new'[$fileloop].tiles[$loop].bg#.ToString()
      X           = $GFXindex.$FG.X
      y           = $GFXindex.$FG.Y
      File        =$TileConfigJson.'tiles-new'[$fileloop].file
      width       =$GFXindex.$FG.width
      height      =$GFXindex.$FG.height
      X_offset    =$X_offset    
      Y_offset    =$Y_offset
      ZLayer      =$ZLayer      
}
$imagesorce += $temp
  
}
}
}
}
if(!(test-path "$PathToScript\Imagemap.xml")){$imagesorce | Export-Clixml  "$PathToScript\Imagemap.xml"}
}
return $imagesorce
}

if(!$imagesorce){$imagesorce = Load-TileConfig}
else{write-host "Tile config already loaded, skipping..."}
show-map

#load-mapfile
#$MAPimage = get-map
#show-map


#todo

#loading message / bar


#figure out a way to sort the types in the sidebar. 
#change map to draw in three(two?) passes one for each type. also fill in ground under items.
#maybe two passes...hmmm

#fix slowdown with map after side-bar runs
#search box
#file menu / save / load / export / palletes?

#monster / trap placements?

#done
#clean up / remove URL stuff and tileset.csv stuff.
#don't try to cache images we already have loaded.
#filemenu needs renanmed and functions made
#map  choice.
#fix slowdown with map after side-bar runs.
#Split palletes into sub types ter/furn/item