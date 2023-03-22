[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

$valuearray=@()

    $dir = Get-ChildItem "C:\users\moorea\desktop\DDA\Palettes" | %{$_.fullname}
    $found = 0
    foreach($i in $dir){
    
    write-host $i
    #if($found -ne 1){
    $data = Get-Content -raw -path $i -Encoding UTF8
    $palletejson = (New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{MaxJsonLength=67108864}).DeserializeObject($data)


    $FUllpalletejson += $palletejson

    
    }


    #$fullpalletejson.terrain | get-unique




    foreach($collection in $FUllpalletejson.terrain){
    
    #write-host $collection
    
    foreach($row in $collection.getenumerator()){

    #write-host $item

    $valuearray +=  $row.Value.ToString() -match "(?<image>t_\w+)" | Foreach { $Matches.image } #$item.Value | out-string


    }

    
    } 
    ($valuearray |sort | get-unique) | out-gridview










    #$baseurl = 'https://nornagon.github.io/cdda-guide/#/terrain/'


	
