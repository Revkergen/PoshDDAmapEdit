[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
$i = "C:\users\moorea\desktop\dda\ultimate\tile_config.json"
$data = Get-Content -raw -path $i -Encoding UTF8
$json = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data)

$filepath = "C:\users\moorea\Desktop\DDA\Ultimate"

function spliter($file,$width,$height,$StartRange,$endrange){

$baseimagepath = "C:\Users\moorea\desktop\DDA\Ultimate\" + $file
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
$GFXindex =@{}

$fileloops = $json.'tiles-new'.file.count
#-2 to skip the fallback.
for ($fileloop = 0; $fileloop -le $fileloops - 2; $fileloop++){

if($json.'tiles-new'[$fileloop].sprite_width){$X = $json.'tiles-new'[$fileloop].sprite_width}
else{$X = 32}

if($json.'tiles-new'[$fileloop].sprite_height){$Y = $json.'tiles-new'[$fileloop].sprite_height}
else{$Y = 32}
$m = Select-String -InputObject $json.'tiles-new'[$fileloop].'//' -Pattern "\d+" -AllMatches
[int]$StartRange = $m.matches.Value[0]
[int]$endRange = $m.matches.Value[1]

$file = $json.'tiles-new'[$fileloop].file
write-host $file

$GFXindex +=  spliter $file $x $y $StartRange $endrange

}


$imagesorce=@()

for ($fileloop = 0; $fileloop -le $fileloops - 2; $fileloop++){
write-host $fileloop
Write-host $json.'tiles-new'[$fileloop].file

$loops = $json.'tiles-new'[$fileloop].tiles.count

for ($loop = 0; $loop -le $loops - 1; $loop++) {

if ($json.'tiles-new'[$fileloop].tiles[$loop].id.GetType().name -eq "String"){

    if($json.'tiles-new'[$fileloop].tiles[$loop].fg.GetType().name -eq "Object[]"){
        if ($json.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite){$FG = $json.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite}
        else{$FG = $json.'tiles-new'[$fileloop].tiles[$loop].fg[0]}
        
    }
    else{$FG = $json.'tiles-new'[$fileloop].tiles[$loop].fg}

if($null-eq $FG){$FG = 1296}

$image = $json.'tiles-new'[$fileloop].tiles[$loop].id

$temp = New-Object psobject -Property @{
                 
        image       = $image
        FG          = $FG
        BG          =$json.'tiles-new'[$fileloop].tiles[$loop].bg#.ToString()
        X           = $GFXindex.$FG.X
        y           = $GFXindex.$FG.Y
        File        =$json.'tiles-new'[$fileloop].file
        width       =$GFXindex.$FG.width
        height      =$GFXindex.$FG.height
        
}
$imagesorce += $temp

}
else{

$subloops = $json.'tiles-new'[$fileloop].tiles[$loop].id.count

for ($subloop = 0; $subloop -le $subloops - 1; $subloop++) {

if($json.'tiles-new'[$fileloop].tiles[$loop].fg){
if($json.'tiles-new'[$fileloop].tiles[$loop].fg.GetType().name -eq "Object[]"){
     if ($json.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite){$FG = $json.'tiles-new'[$fileloop].tiles[$loop].fg[0].sprite}
     else{$FG = $json.'tiles-new'[$fileloop].tiles[$loop].fg[0]}

}
else{$FG = $json.'tiles-new'[$fileloop].tiles[$loop].fg}
}
else{$FG = 0}

if($null -eq $FG){$FG = 1296}
$image = $json.'tiles-new'[$fileloop].tiles[$loop].id[$subloop]
$temp = New-Object psobject -Property @{
                 
        image       = $image
        FG          = $FG
        BG          =$json.'tiles-new'[$fileloop].tiles[$loop].bg#.ToString()
        X           = $GFXindex.$FG.X
        y           = $GFXindex.$FG.Y
        File        =$json.'tiles-new'[$fileloop].file
        width       =$GFXindex.$FG.width
        height      =$GFXindex.$FG.height
        
}
$imagesorce += $temp

}
}
}
}

$imagesorce | out-gridview
