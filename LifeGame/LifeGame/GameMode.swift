public enum GameMode: String, CaseIterable, Identifiable, Sendable
{
    case life  = "Life"
    case latix = "Circles"
    public var id: String { self.rawValue }
}
