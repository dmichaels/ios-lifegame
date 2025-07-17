public enum GameMode: String, CaseIterable, Identifiable, Sendable
{
    case life  = "Life"
    case lifehash  = "LifeHash"
    case latix = "Circles"
    public var id: String { self.rawValue }
}
