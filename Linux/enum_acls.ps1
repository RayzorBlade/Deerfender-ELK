
# Get all files and folders in the current directory
$items = ls *

# Add new lines at the start to align with remaining output
Write-Host "`n`n"

# Enumerate each file and folder
foreach ($item in $items) {

 # Get the name of the file or folder 
 $name = $item.Name

 # Create a summary line and add the word "FILE: or DIRECTORY:"
 #   depending on whether the item is a file or folder"
 $summary = "FILE: $name"
  If ($item.PSIsContainer){
    $summary = "DIRECTORY: $name"
  }

  # Add a nice colored summary line for readability
  Write-Host $summary -ForegroundColor Green

  # format the ACL details
  Get-Acl $item | Format-List
}