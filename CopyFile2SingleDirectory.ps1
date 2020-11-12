$SrcDir = "C:\Test\Src"
# "\\file01\pictandlog\Picture"

$DestDir = "C:\Test\Dst"

[Array]$Pattans = "mp4", "jpg", "jpeg"

if( Test-Path $SrcDir ){
	$Files = dir $SrcDir -Recurse
}
else{
	echo "$SrcDir not found."
	exit
}

if( -not (Test-Path $DestDir)){
	md $DestDir
}

$TergetFiles = @()
foreach( $Pattan in $Pattans ){
	$TergetFiles += $Files | ? FullName -Match $Pattan
}

foreach( $TergetFile in $TergetFiles ){
	# コピー先に同一名のファイルがあるか
	$DestFileFullName = Join-Path $DestDir $TergetFile.Name

	# 同名ファイルがある
	if( Test-Path $DestFileFullName ){

		# ハッシュ値を取得
		$SrcFileHash = (Get-FileHash $TergetFile.FullName).Hash
		$DestFileHash = (Get-FileHash $DestFileFullName).Hash

		# 異なるファイルなのでファイル名をインクリメントする
		if( $SrcFileHash -ne $DestFileHash ){

			# 拡張子除いたファイル名
			$FileNameBody = ($TergetFile.Name).split( ".")[0]

			# 連番を取る
			$FileNameBody = $FileNameBody -replace "_[0-9]+$", ""

			# スキップフラグ
			$SkipFlag = $false

			$Index = 0
			do{
				$Index++

				# 連番を付ける
				$NewFileNameBody = $FileNameBody + "_" + $Index

				# 拡張子を付ける
				$FileName = $NewFileNameBody + $TergetFile.Extension

				$NewDestFileFullName = Join-Path $DestDir $FileName

				# 同じファイルなら処理スキップ
				if( Test-Path $NewDestFileFullName ){
					$DestFileHash = (Get-FileHash $NewDestFileFullName).Hash
					if( $SrcFileHash -eq $DestFileHash ){
						$SkipFlag = $true
						break
					}
				}

			}while( Test-Path $NewDestFileFullName )

			# コピーする
			if( $SkipFlag -eq $false){
				copy $TergetFile.FullName $NewDestFileFullName
			}
		}
	}
	# 同名ファイルが無いので単純コピー
	else{
		copy $TergetFile.FullName $DestDir
	}
}
