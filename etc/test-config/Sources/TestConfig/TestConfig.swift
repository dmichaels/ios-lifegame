// ---------------------------------------------------------------------------------------------------------------------
// ios-cellgridview
// ---------------------------------------------------------------------------------------------------------------------

// FILE: ios-cellgridview/CellGridView+Defaults.swift
//
extension CellGridView
{
    public class Defaults {
        public static let viewBackground: Int     = 123
        public static let viewTransparency: UInt8 = 255
        public static let viewScaling: Bool       = true
        public static let cellSize: Int           = 43
        public static let cellPadding: Int        = 2
    }
}

// FILE: ios-cellgridview/CellGridView+Config.swift
//
extension CellGridView
{
    public class Config {

        public var viewBackground: Int
        public var viewTransparency: UInt8
        public var viewScaling: Bool
        public var cellSize: Int
        public var cellPadding: Int

        public init(_ cellGridView: CellGridView? = nil) {
            self.viewBackground   = cellGridView?.viewBackground   ?? CellGridView.Defaults.viewBackground
            self.viewTransparency = cellGridView?.viewTransparency ?? CellGridView.Defaults.viewTransparency
            self.viewScaling      = cellGridView?.viewScaling      ?? CellGridView.Defaults.viewScaling
            self.cellSize         = cellGridView?.cellSize         ?? CellGridView.Defaults.cellSize
            self.cellPadding      = cellGridView?.cellPadding      ?? CellGridView.Defaults.cellPadding
        }
    }
}

// FILE: ios-cellgridview/CellGridView.swift
//
public class CellGridView
{
    private var _viewBackground: Int
    private var _viewTransparency: UInt8
    private var _viewScaling: Bool
    private var _cellSize: Int
    private var _cellPadding: Int

    public var   viewBackground: Int     { self._viewBackground }
    public var   viewTransparency: UInt8 { self._viewTransparency }
    public var   viewScaling: Bool       { self._viewScaling }
    public var   cellSize: Int           { self._cellSize }
    public var   cellPadding: Int        { self._cellPadding }

    public init(_ config: CellGridView.Config? = nil) {
        self._viewBackground   = config?.viewBackground   ?? CellGridView.Defaults.viewBackground
        self._viewTransparency = config?.viewTransparency ?? CellGridView.Defaults.viewTransparency
        self._viewScaling      = config?.viewScaling      ?? CellGridView.Defaults.viewScaling
        self._cellSize         = config?.cellSize         ?? CellGridView.Defaults.cellSize
        self._cellPadding      = config?.cellPadding      ?? CellGridView.Defaults.cellPadding
    }

    open var config: CellGridView.Config {
        CellGridView.Config(self)
    }

    open func initialize(_ config: CellGridView.Config, fit: Bool = false, center: Bool = false) {
        self.configure(config)
    }

    open func configure(_ config: CellGridView.Config) {
        self._viewBackground   = config.viewBackground
        self._viewTransparency = config.viewTransparency
        self._viewScaling      = config.viewScaling
        self._cellSize         = config.cellSize
        self._cellPadding      = config.cellPadding
        print("CellGridView.configure")
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// ios-lifegame
// ---------------------------------------------------------------------------------------------------------------------

// FILE: ios-lifegame/LifeCellGridView+Defaults.swift
//
extension LifeCellGridView
{
    class Defaults {
        public static let viewBackground: Int = CellGridView.Defaults.viewBackground
        public static let viewScaling: Bool   = CellGridView.Defaults.viewScaling
        public static let cellSize: Int       = 25
        public static let cellPadding: Int    = 1
        public static let activeColor: Int    = 0x06
        public static let inactiveColor: Int  = 0x07
    }
}

// FILE: ios-lifegame/Settings.swift
//
class Settings
{
    public var viewBackground: Int = CellGridView.Defaults.viewBackground
    public var viewScaling: Bool   = CellGridView.Defaults.viewScaling
    public var cellSize: Int       = CellGridView.Defaults.cellSize
    public var cellPadding: Int    = CellGridView.Defaults.cellPadding
    public var activeColor: Int    = LifeCellGridView.Defaults.activeColor
    public var inactiveColor: Int  = LifeCellGridView.Defaults.inactiveColor
}

// FILE: ios-lifegame/LifeCellGridView.swift
//
public class LifeCellGridView: CellGridView {

    private var _activeColor: Int
    private var _inactiveColor: Int

    internal var activeColor: Int   { self._activeColor }
    internal var inactiveColor: Int { self._inactiveColor }

    public override init(_ config: CellGridView.Config? = nil) {
        let config: LifeCellGridView.Config? = config as? LifeCellGridView.Config
        self._activeColor   = config?.activeColor   ?? LifeCellGridView.Defaults.activeColor
        self._inactiveColor = config?.inactiveColor ?? LifeCellGridView.Defaults.inactiveColor
        super.init(config)
    }

    public override var config: LifeCellGridView.Config {
        LifeCellGridView.Config(self)
    }

    public override func initialize(_ config: CellGridView.Config, fit: Bool = false, center: Bool = false) {
        self.configure(config)
    }

    public override func configure(_ config: CellGridView.Config) {
        if let config: LifeCellGridView.Config = config as? LifeCellGridView.Config {
            super.configure(config)
            print("LifeCellGridView.configure")
        }
    }
}

// FILE: ios-lifegame/LifeCellGridView+Config.swift
//
extension LifeCellGridView
{
    public class Config: CellGridView.Config {

        public var activeColor: Int
        public var inactiveColor: Int

        public init(_ cellGridView: LifeCellGridView? = nil) {
            self.activeColor   = cellGridView?.activeColor   ?? LifeCellGridView.Defaults.activeColor
            self.inactiveColor = cellGridView?.inactiveColor ?? LifeCellGridView.Defaults.inactiveColor
            super.init(cellGridView)
            self.viewBackground = cellGridView?.viewBackground ?? LifeCellGridView.Defaults.viewBackground
            self.viewScaling    = cellGridView?.viewScaling    ?? LifeCellGridView.Defaults.viewScaling
            self.cellSize       = cellGridView?.cellSize       ?? LifeCellGridView.Defaults.cellSize
            self.cellPadding    = cellGridView?.cellPadding    ?? LifeCellGridView.Defaults.cellPadding
        }
    }
}

extension Settings
{
    // Sets up this Settings object from the given LifeCellGridView.Config.
    // This is called when we are instantiating/showing the SettingsView.
    // For example in ContentView we will have something like this:
    //
    //     func gotoSettingsView() {
    //         self.settings.fromConfig(self.cellGridView.config)
    //         self.showSettingsView = true
    //     }
    //
    public func fromConfig(_ config: LifeCellGridView.Config)
    {
        self.viewBackground = config.viewBackground
        self.viewScaling    = config.viewScaling
        self.cellSize       = config.cellSize
        self.cellPadding    = config.cellPadding
        self.activeColor    = config.activeColor
        self.inactiveColor  = config.inactiveColor
    }

    // Creates and returns a LifeCellGridView.Config (derived from CellGridView.Config) object,
    // from this Settings object. This is called when we return from the SettingsView.
    // For example in ContentView we will have something like this:
    //
    //     func onSettingsChange() {
    //         let config: LifeCellGridView.Config = self.settings.toConfig(self.cellGridView)
    //         self.cellGridView.configure(config)
    //     }
    //
    internal func toConfig(_ cellGridView: LifeCellGridView) -> LifeCellGridView.Config
    {
        let config: LifeCellGridView.Config = LifeCellGridView.Config(cellGridView)
        config.viewBackground = self.viewBackground
        config.viewScaling    = self.viewScaling
        config.cellSize       = self.cellSize
        config.cellPadding    = self.cellPadding
        config.activeColor    = self.activeColor
        config.inactiveColor  = self.inactiveColor
        return config
    }
}

// FILE: ios-lifegame/ContentView.swift
//
public class ContentView
{
    private var settings: Settings = Settings()
    private var cellGridView: LifeCellGridView = LifeCellGridView()

    internal func showSettingsView() {
        let config: LifeCellGridView.Config = self.cellGridView.config
        self.settings.fromConfig(config)
    }

    internal func onSettingsViewChange() {
        let config: LifeCellGridView.Config = self.settings.toConfig(self.cellGridView)
        self.cellGridView.configure(config)
    }
}

// TESTing ...
//
let cellGridView: CellGridView = CellGridView()
let lifeCellGridView: LifeCellGridView = LifeCellGridView()
let config: CellGridView.Config = CellGridView.Config(cellGridView)
let lifeConfig: LifeCellGridView.Config = LifeCellGridView.Config(lifeCellGridView)
lifeCellGridView.configure(lifeConfig)
print(lifeConfig.cellSize)
print(lifeConfig.activeColor)
