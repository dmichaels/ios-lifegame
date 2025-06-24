// FILE: ios-cellgridview/CellGridView.swift
//
public class CellGridView
{
    private var _cellSize: Int
    private var _cellPadding: Int

    public var   cellSize: Int { self._cellSize }
    public var   cellPadding: Int { self._cellPadding }

    public init(_ config: CellGridView.Config? = nil) {
        self._cellSize = config?.cellSize ?? CellGridView.Defaults.cellSize
        self._cellPadding = config?.cellPadding ?? CellGridView.Defaults.cellPadding
    }

    open var config: CellGridView.Config {
        CellGridView.Config(self)
    }

    open func configure(_ config: CellGridView.Config) {
        self._cellSize = config.cellSize
        self._cellPadding = config.cellPadding
        print("CellGridView.configure")
    }
}

// FILE: ios-cellgridview/CellGridView+Config.swift
//
extension CellGridView
{
    public class Defaults {
        public static let cellSize: Int    = 43
        public static let cellPadding: Int = 2
    }

    public class Config {

        public var cellSize: Int
        public var cellPadding: Int

        public init(_ cellGridView: CellGridView? = nil) {
            self.cellSize    = cellGridView?.cellSize    ?? CellGridView.Defaults.cellSize
            self.cellPadding = cellGridView?.cellPadding ?? CellGridView.Defaults.cellPadding
        }
    }

}

// FILE: ios-lifegame/LifeCellGridView.swift
//
public class LifeCellGridView: CellGridView {

    private var _activeColor: Int
    private var _inactiveColor: Int

    internal var activeColor: Int { self._activeColor }
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
    class Defaults {
        public static let cellSize: Int      = 25
        public static let cellPadding: Int   = 1
        public static let activeColor: Int   = 0x06
        public static let inactiveColor: Int = 0x07
    }

    public class Config: CellGridView.Config {

        public var activeColor: Int
        public var inactiveColor: Int

        public init(_ cellGridView: LifeCellGridView? = nil) {
            self.activeColor   = cellGridView?.activeColor   ?? LifeCellGridView.Defaults.activeColor
            self.inactiveColor = cellGridView?.inactiveColor ?? LifeCellGridView.Defaults.inactiveColor
            super.init(cellGridView)
            self.cellSize      = cellGridView?.cellSize      ?? LifeCellGridView.Defaults.cellSize
            self.cellPadding   = cellGridView?.cellPadding   ?? LifeCellGridView.Defaults.cellPadding
        }
    }
}

extension Settings
{
    // Sets up this Settings object from the given LifeCellGridView.
    // This is called when we are instantiating the SettingsView.
    // For example in ContentView we will have something like this:
    //
    //     func gotoSettingsView() {
    //         self.settings.setupFrom(self.cellGridView)
    //         self.showSettingsView = true
    //     }
    //
    public func setupFrom(_ cellGridView: LifeCellGridView)
    {
        self.fromConfig(cellGridView.config)
        // let config: LifeCellGridView.Config = cellGridView.config as LifeCellGridView.Config
        // self.cellSize = config.cellSize
        // self.cellPadding = config.cellPadding
        // self.activeColor = config.activeColor
        // self.inactiveColor = config.inactiveColor
    }

    public func fromConfig(_ config: LifeCellGridView.Config)
    {
        self.cellSize = config.cellSize
        self.cellPadding = config.cellPadding
        self.activeColor = config.activeColor
        self.inactiveColor = config.inactiveColor
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
        config.cellSize      = self.cellSize
        config.cellPadding   = self.cellPadding
        config.activeColor   = self.activeColor
        config.inactiveColor = self.inactiveColor
        return config
    }
}

// FILE: ios-lifegame/Settings.swift
//
class Settings
{
    public var cellSize: Int      = CellGridView.Defaults.cellSize
    public var cellPadding: Int   = CellGridView.Defaults.cellPadding
    public var activeColor: Int   = LifeCellGridView.Defaults.activeColor
    public var inactiveColor: Int = LifeCellGridView.Defaults.inactiveColor
}

// FILE: ios-lifegame/ContentView.swift
//
public class ContentView
{
    private var settings: Settings = Settings()
    private var cellGridView: LifeCellGridView = LifeCellGridView()

    internal func showSettingsView() {
        // self.settings.setupFrom(self.cellGridView)
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
