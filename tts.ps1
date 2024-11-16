Add-Type -AssemblyName System.Speech

$input = Read-Host


$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$streamFormat = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(9000,[System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,[System.Speech.AudioFormat.AudioChannel]::Mono)
$speak.SetOutputToWaveFile("C:\Programming\Godot\Game_Jam\thing.wav",$streamFormat)
$speak.Speak($input)
$speak.Dispose()
