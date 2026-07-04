import Speech
import AVFoundation

class VoiceService: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var transcript = ""
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override init() {
        super.init()
        requestMicrophonePermission()
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                // Handle permission result
            }
        }
    }
    
    func startListening() {
        // TODO: Start recording and transcribing
    }
    
    func stopListening() {
        // TODO: Stop recording
    }
}
