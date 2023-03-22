$dataGrid = New-Object System.Windows.Forms.DataGridView
$dataGrid.Width = 200
$dataGrid.Height = 600
$dataGrid.location = new-object system.drawing.point(0,0)
#$dataGrid.DataSource = $DataTable
$dataGrid.ReadOnly = $true
$dataGrid.RowHeadersVisible = $false
$dataGrid.AllowUserToAddRows = $false
$dataGrid.AutoSizeColumnsMode = 'Fill'
$dataGrid.SelectionMode = "FullRowSelect"
$datagrid.RowTemplate.Height = 62
$datagrid.MultiSelect = $false
$ImageColumn = New-Object System.Windows.Forms.DataGridViewImageColumn
$ImageColumn.Width = 62
$dataGrid.Columns.Insert($dataGrid.Columns.Count, $ImageColumn)
$dataGrid.Columns[0].HeaderText = "Preview"
$dataGrid.Columns[0].Name = "ImageColumn"
$datagrid.ColumnCount = 2
$dataGrid.Columns[1].Name = "file"
$dataGrid.Columns[1].HeaderText = "file"

for ($loop = 0; $loop -le $Custompalette.count - 1; $loop++){

    if($Custompalette[$loop].file){
    $CutRec  = [System.Drawing.Rectangle]::new($Custompalette[$loop].x,$Custompalette[$loop].y,$Custompalette[$loop].width,$Custompalette[$loop].height)
    $filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension($Custompalette[$loop].file)
    }
    else{
    $filename = "tempvarname" + [io.path]::GetFileNameWithoutExtension("error")
    $CutRec  = [System.Drawing.Rectangle]::new(0,0,32,32)
    }
    $baseimage = (Get-Variable -Scope "Script" -Name "$filename").Value
    $cutimage = $baseimage.Clone($cutrec,$baseimage.PixelFormat)
    [void]$dataGrid.Rows.Add($cutimage,$Custompalette[$loop].image)
   }

$Form = New-Object Windows.Forms.Form  
$Form.Text = "PowerShell Form"                     
$Form.Width = 800
$Form.Height = 600
$Form.StartPosition = "CenterScreen"
$form.Controls.Add($dataGrid)
$dataGrid.Refresh()
$Form.ShowDialog()



$dataGrid.CurrentRow.Cells.value