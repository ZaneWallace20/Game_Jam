Add-Type -AssemblyName System.Speech

$input = "What is your name?"

foreach ($name in $input) {
    $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speak.Pitch = 0
    $streamFormat = [System.Speech.AudioFormat.SpeechAudioFormatInfo]::new(8000,[System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen,[System.Speech.AudioFormat.AudioChannel]::Mono)
    $speak.SetOutputToWaveFile("C:\Programming\Godot\Game_Jam\thing.wav",$streamFormat)
    $speak.Speak($name)
    $speak.Dispose()
}