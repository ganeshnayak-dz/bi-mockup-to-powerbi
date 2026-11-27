param([string]$Port, [string]$In, [string]$Out)
# Read-only: runs DAX EVALUATE queries against Power BI Desktop's local model and writes results as JSON.
Add-Type -Path "C:\Program Files\Microsoft Power BI Desktop\bin\Microsoft.PowerBI.AdomdClient.dll"
$conn = New-Object Microsoft.AnalysisServices.AdomdClient.AdomdConnection("Data Source=localhost:$Port")
$conn.Open()
$db = $conn.Database
$queries = Get-Content $In -Raw -Encoding UTF8 | ConvertFrom-Json
$results = @()
foreach ($q in $queries) {
  if ($q.dax -notmatch '^\s*(EVALUATE|DEFINE)') { $results += [pscustomobject]@{ id = $q.id; error = "not a read-only EVALUATE query" }; continue }
  try {
    $cmd = $conn.CreateCommand(); $cmd.CommandText = $q.dax
    $r = $cmd.ExecuteReader()
    $cols = @(); for ($i = 0; $i -lt $r.FieldCount; $i++) { $cols += $r.GetName($i) }
    $rows = @()
    while ($r.Read()) { $row = @(); for ($i = 0; $i -lt $r.FieldCount; $i++) { $v = $r.GetValue($i); if ($v -is [DateTime]) { $v = $v.ToString("yyyy-MM-dd") } elseif ($v -is [DBNull]) { $v = $null }; $row += ,$v }; $rows += ,$row }
    $r.Close()
    $results += [pscustomobject]@{ id = $q.id; columns = $cols; rows = $rows }
  } catch { $results += [pscustomobject]@{ id = $q.id; error = $_.Exception.Message } }
}
$conn.Close()
[pscustomobject]@{ database = $db; results = $results } | ConvertTo-Json -Depth 8 | Out-File $Out -Encoding utf8
"done: $($results.Count) queries on database $db"
