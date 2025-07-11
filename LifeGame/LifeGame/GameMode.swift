public enum GameMode: String, CaseIterable, Identifiable, Sendable
{
    case life  = "Life"
    case latix = "Latix"
    public var id: String { self.rawValue }
}
