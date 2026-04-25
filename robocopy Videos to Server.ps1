$source = "C:\Users\brob2\Videos\Radeon ReLive"
$destination = "P:\Pictures\Radeon Backup"

robocopy $source $destination /E /Z /R:3 /W:5 /MT:128 /V /NP /XO